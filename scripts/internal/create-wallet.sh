#!/usr/bin/env bash
# ============================================================================
# Oracle Wallet & TNS Configuration Generator
# Initializes SEPS Client Wallet and TNS files using container toolchain
# Dynamic Profile & Active Instances Engine (No Hardcoded DB Names or Aliases)
# Optimized single-pass container execution
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Laeme keskkonnamuutujad ja profiilimootori
if [ -f "$WORKSPACE_DIR/.env" ]; then
  set -a
  source "$WORKSPACE_DIR/.env"
  set +a
fi

if [ -f "$SCRIPT_DIR/load-profile.sh" ]; then
  source "$SCRIPT_DIR/load-profile.sh"
  load_db_profile >/dev/null 2>&1 || true
fi

# Tuvastame esmase aktiivse andmebaasi konteineri nime ja dünaamilise aliase
PRIMARY_CONTAINER=$(get_active_db_instances 2>/dev/null | head -n 1 | cut -d'|' -f1)
PRIMARY_CONTAINER="${PRIMARY_CONTAINER:-db-dev-full}"
if ! podman container exists "$PRIMARY_CONTAINER" 2>/dev/null; then
  for c_entry in $(get_active_db_instances 2>/dev/null); do
    c_name=$(echo "$c_entry" | cut -d'|' -f1)
    if podman container exists "$c_name" 2>/dev/null; then
      PRIMARY_CONTAINER="$c_name"
      break
    fi
  done
fi
PROXY_CONTAINER="$PRIMARY_CONTAINER"
PRIMARY_UPPER=$(echo "$PRIMARY_CONTAINER" | tr '-' '_' | tr '[:lower:]' '[:upper:]')

# Abifunktsioon saladuse turvaliseks pärimiseks käimasolevast konteinerist või Podman Secrets hoidlast
get_container_secret() {
  local container="$1"
  local name="$2"
  local val=""

  val=$(podman secret inspect --showsecret "$name" 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)

  if [ -z "$val" ] && { [ "$name" = "oracle_pwd" ] || [[ "$name" == *_sys_password ]]; }; then
    val=$(podman secret inspect --showsecret apex_db_sys_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
  fi

  if [ -z "$val" ] && podman container exists "$container" 2>/dev/null && [ "$(podman inspect --format='{{.State.Status}}' "$container" 2>/dev/null)" = "running" ]; then
    val=$(podman exec "$container" cat "/run/secrets/$name" 2>/dev/null || podman exec "$container" cat "/run/secrets/apex_db_sys_password" 2>/dev/null || true)
  fi

  echo "$val"
}

# Värvide seadistamine
if [ -t 0 ] || { [ -n "$TERM" ] && [ "$TERM" != "dumb" ]; }; then
  GREEN='\033[1;32m'
  YELLOW='\033[0;33m'
  CYAN='\033[1;36m'
  NC='\033[0m'
else
  GREEN=''
  YELLOW=''
  CYAN=''
  NC=''
fi

WALLET_PWD=$(get_wallet_password)

if [ -f "$WORKSPACE_DIR/.env" ] && grep -q "ORACLE_WALLET_PASSWORD=" "$WORKSPACE_DIR/.env"; then
  sed -i.bak '/ORACLE_WALLET_PASSWORD=/d' "$WORKSPACE_DIR/.env" && rm -f "$WORKSPACE_DIR/.env.bak"
fi

TNS_DIR="$WORKSPACE_DIR/config/tns_admin"
mkdir -p "$TNS_DIR"

IS_ADB=false
if [ "$PROFILE_DB_TYPE" = "adb" ] || [ "$IS_ADB" = "true" ] || [ "$APEX_DB_TYPE" = "ADB" ] || [[ "$APEX_DB_IMAGE" == *"adb-free"* ]]; then
  IS_ADB=true
fi

if [ "$IS_ADB" = "true" ]; then
  echo -e "${CYAN}├─${NC} ${YELLOW}[Autonomous Database]: Kasutan ADB-siseselt genereeritud mTLS Walletit...${NC}"
  echo -e "${CYAN}│${NC}  ⌛ Ootan kuni ADB on loonud wallet failid (ewallet.p12 ja cwallet.sso)..."

  WAIT_S=0
  until podman exec "$PROXY_CONTAINER" sh -c "[ -f /u01/app/oracle/wallets/tls_wallet/cwallet.sso ] && [ -f /u01/app/oracle/wallets/tls_wallet/tnsnames.ora ]" &>/dev/null; do
    sleep 3
    WAIT_S=$((WAIT_S + 3))
    print_progress "   Ootan walleti ja tnsnames faile konteineris... ${ORANGE}${WAIT_S}s${NC}\r"
    if [ $WAIT_S -ge 180 ]; then
      echo ""
      echo -e "${CYAN}│${NC}  ❌ Viga: ADB ei genereerinud wallet faile konteineris 180 sekundi jooksul!"
      exit 1
    fi
  done
  echo ""

  echo -e "${CYAN}│${NC}  🔐 Registreerin süsteemsed SEPS tunnused ADB Walletisse..."
  DB_SYS_PWD=$(get_container_secret "$PROXY_CONTAINER" "apex_db_sys_password")
  APEX_SCHEMA_PWD=$(get_container_secret "$PROXY_CONTAINER" "apex_schema_password")
  TEST_DEV_PWD=$(get_container_secret "$PROXY_CONTAINER" "test_dev_password")
  WEB_DEV_PWD=$(get_container_secret "$PROXY_CONTAINER" "test_web_password")
  ADMIN_PWD="$DB_SYS_PWD"
  
  podman exec -i "$PROXY_CONTAINER" sh -s <<ADB_EOF >/dev/null 2>&1 || true
export JAVA_HOME=/usr/java/latest
export PATH=\$JAVA_HOME/bin:\$PATH
WALLET_PATH="/u01/app/oracle/wallets/tls_wallet"

echo "$WALLET_PWD" | mkstore -wrl \$WALLET_PATH -deleteCredential "DB_${PRIMARY_UPPER}_SYS" >/dev/null 2>&1 || true
echo "$WALLET_PWD" | mkstore -wrl \$WALLET_PATH -createCredential "DB_${PRIMARY_UPPER}_SYS" admin "$DB_SYS_PWD" >/dev/null

echo "$WALLET_PWD" | mkstore -wrl \$WALLET_PATH -deleteCredential "DB_${PRIMARY_UPPER}_SCHEMA" >/dev/null 2>&1 || true
echo "$WALLET_PWD" | mkstore -wrl \$WALLET_PATH -createCredential "DB_${PRIMARY_UPPER}_SCHEMA" "${APEX_SCHEMA_USER:-APEX_PROXY_SCHEMA}" "$APEX_SCHEMA_PWD" >/dev/null

echo "$WALLET_PWD" | mkstore -wrl \$WALLET_PATH -deleteCredential "DB_${PRIMARY_UPPER}_DEV" >/dev/null 2>&1 || true
echo "$WALLET_PWD" | mkstore -wrl \$WALLET_PATH -createCredential "DB_${PRIMARY_UPPER}_DEV" "${TEST_DEV_USER:-TEST_DEV}" "$TEST_DEV_PWD" >/dev/null

echo "$WALLET_PWD" | mkstore -wrl \$WALLET_PATH -deleteCredential TEST_WEB_USER >/dev/null 2>&1 || true
echo "$WALLET_PWD" | mkstore -wrl \$WALLET_PATH -createCredential TEST_WEB_USER "${TEST_WEB_USER:-TEST_WEB_USER}" "$WEB_DEV_PWD" >/dev/null

echo "$WALLET_PWD" | mkstore -wrl \$WALLET_PATH -deleteCredential APEX_ADMIN >/dev/null 2>&1 || true
echo "$WALLET_PWD" | mkstore -wrl \$WALLET_PATH -createCredential APEX_ADMIN "${APEX_ADMIN_USER:-ADMIN}" "$ADMIN_PWD" >/dev/null
ADB_EOF

  echo -e "${CYAN}│${NC}  📥 Kopeerin mTLS Wallet failid konteinerist hosti..."
  podman cp "$PROXY_CONTAINER":/u01/app/oracle/wallets/tls_wallet/. "$TNS_DIR/"

  sed -i.bak "s/port=1522/port=${APEX_DB_PORT:-1532}/g" "$TNS_DIR/tnsnames.ora" && rm -f "$TNS_DIR/tnsnames.ora.bak"
  sed -i.bak -e "s/myatp/MYATP/g" -e "s/my_adw/MY_ADW/g" "$TNS_DIR/tnsnames.ora" && rm -f "$TNS_DIR/tnsnames.ora.bak"

  if grep -q "MYATP" "$TNS_DIR/tnsnames.ora"; then
    cat << EOF >> "$TNS_DIR/tnsnames.ora"

DB_${PRIMARY_UPPER}_SYS = (description=(retry_count=0)(retry_delay=3)(address=(protocol=tcps)(port=${APEX_DB_PORT:-1532})(host=localhost))(connect_data=(service_name=MYATP_low.adb.oraclecloud.com))(security=(SSL_SERVER_DN_MATCH=TRUE)(SSL_SERVER_CERT_DN="CN=${PROXY_CONTAINER}")))

DB_${PRIMARY_UPPER}_SCHEMA = (description=(retry_count=0)(retry_delay=3)(address=(protocol=tcps)(port=${APEX_DB_PORT:-1532})(host=localhost))(connect_data=(service_name=MYATP_low.adb.oraclecloud.com))(security=(SSL_SERVER_DN_MATCH=TRUE)(SSL_SERVER_CERT_DN="CN=${PROXY_CONTAINER}")))

DB_${PRIMARY_UPPER}_DEV = (description=(retry_count=0)(retry_delay=3)(address=(protocol=tcps)(port=${APEX_DB_PORT:-1532})(host=localhost))(connect_data=(service_name=MYATP_low.adb.oraclecloud.com))(security=(SSL_SERVER_DN_MATCH=TRUE)(SSL_SERVER_CERT_DN="CN=${PROXY_CONTAINER}")))
EOF
  elif grep -q "MY_ADW" "$TNS_DIR/tnsnames.ora"; then
    cat << EOF >> "$TNS_DIR/tnsnames.ora"

DB_${PRIMARY_UPPER}_SYS = (description=(retry_count=0)(retry_delay=3)(address=(protocol=tcps)(port=${APEX_DB_PORT:-1532})(host=localhost))(connect_data=(service_name=MY_ADW_low.adb.oraclecloud.com))(security=(SSL_SERVER_DN_MATCH=TRUE)(SSL_SERVER_CERT_DN="CN=${PROXY_CONTAINER}")))

DB_${PRIMARY_UPPER}_SCHEMA = (description=(retry_count=0)(retry_delay=3)(address=(protocol=tcps)(port=${APEX_DB_PORT:-1532})(host=localhost))(connect_data=(service_name=MY_ADW_low.adb.oraclecloud.com))(security=(SSL_SERVER_DN_MATCH=TRUE)(SSL_SERVER_CERT_DN="CN=${PROXY_CONTAINER}")))

DB_${PRIMARY_UPPER}_DEV = (description=(retry_count=0)(retry_delay=3)(address=(protocol=tcps)(port=${APEX_DB_PORT:-1532})(host=localhost))(connect_data=(service_name=MY_ADW_low.adb.oraclecloud.com))(security=(SSL_SERVER_DN_MATCH=TRUE)(SSL_SERVER_CERT_DN="CN=${PROXY_CONTAINER}")))
EOF
  fi

  CONTAINER_TNS_DIR="${TNS_DIR}_container"
  mkdir -p "$CONTAINER_TNS_DIR"

  cp "$TNS_DIR/cwallet.sso" "$CONTAINER_TNS_DIR/cwallet.sso"
  [ -f "$TNS_DIR/ewallet.p12" ] && cp "$TNS_DIR/ewallet.p12" "$CONTAINER_TNS_DIR/ewallet.p12"
  
  if [ -f "$TNS_DIR/tnsnames.ora" ]; then
    cp "$TNS_DIR/tnsnames.ora" "$CONTAINER_TNS_DIR/tnsnames.ora"
    sed -i.bak -e "s/host=localhost/host=${PROXY_CONTAINER}/g" -e "s/port=${APEX_DB_PORT:-1532}/port=1522/g" "$CONTAINER_TNS_DIR/tnsnames.ora" && rm -f "$CONTAINER_TNS_DIR/tnsnames.ora.bak"
  fi

  cat << EOF > "$TNS_DIR/sqlnet.ora"
# SQL*Net Client Profile for Host (Auto-generated: $(date))
WALLET_LOCATION =
  (SOURCE =
    (METHOD = FILE)
    (METHOD_DATA =
      (DIRECTORY = $TNS_DIR)
    )
  )
SQLNET.WALLET_OVERRIDE = TRUE
SSL_SERVER_DN_MATCH = ON
EOF

  cat << EOF > "$CONTAINER_TNS_DIR/sqlnet.ora"
# SQL*Net Client Profile for Container (Auto-generated: $(date))
WALLET_LOCATION =
  (SOURCE =
    (METHOD = FILE)
    (METHOD_DATA =
      (DIRECTORY = /tns)
    )
  )
SQLNET.WALLET_OVERRIDE = TRUE
SSL_SERVER_DN_MATCH = ON
EOF

  chmod 644 "$TNS_DIR"/cwallet.sso "$TNS_DIR"/*.ora 2>/dev/null || true
  chmod 644 "$CONTAINER_TNS_DIR"/* 2>/dev/null || true

  echo -e "${CYAN}│${NC}  ✅ ADB Wallet ja TNS konfiguratsioonid on edukalt sünkroniseeritud!"
  exit 0
fi

# Standard (Gvenzl / Oracle Free) Wallet loomine
rm -f "$TNS_DIR/ewallet.p12" "$TNS_DIR/cwallet.sso" "$TNS_DIR/ewallet.p12.lck" "$TNS_DIR/cwallet.sso.lck"
if podman container exists "$PROXY_CONTAINER" 2>/dev/null; then
  podman exec "$PROXY_CONTAINER" rm -f /opt/oracle/admin/FREE/wallet/ewallet.p12 /opt/oracle/admin/FREE/wallet/cwallet.sso /opt/oracle/admin/FREE/wallet/ewallet.p12.lck /opt/oracle/admin/FREE/wallet/cwallet.sso.lck || true
fi

echo -e "${CYAN}├─${NC} ${YELLOW}[Alamsamm 4.5.1]: Loon uue paroolivaba Walleti (Auto-Login)...${NC}"
echo -e "${CYAN}│${NC}  📊 Ajalooline ooteaeg: ${YELLOW}ootusaeg ~2s${NC}"
ATTEMPT=1
MAX_ATTEMPTS=5
until podman exec "$PROXY_CONTAINER" orapki wallet create -wallet /opt/oracle/admin/FREE/wallet -pwd "$WALLET_PWD" -auto_login >/dev/null 2>&1; do
  if [ $ATTEMPT -ge $MAX_ATTEMPTS ]; then
    echo -e "${CYAN}│${NC}  ❌ Viga: Walleti loomine orapki abil ebaõnnestus pärast $MAX_ATTEMPTS katset!"
    exit 255
  fi
  echo -e "${CYAN}│${NC}  ⚠️  orapki käivitus ebaõnnestus (transientne viga). Proovin uuesti... (Katse $ATTEMPT/$MAX_ATTEMPTS)"
  sleep 2
  ATTEMPT=$((ATTEMPT + 1))
done

echo -e "${CYAN}├─${NC} ${YELLOW}[Alamsamm 4.5.2]: Lisanduvad ühenduse andmed Walletisse (SEPS)...${NC}"
echo -e "${CYAN}│${NC}  📊 Ajalooline ooteaeg: ${YELLOW}ootusaeg ~2s${NC}"

get_active_db_instances 2>/dev/null | while IFS='|' read -r cname prof env_key; do
  [ -z "$cname" ] && continue
  UPPER_NAME=$(echo "$cname" | tr '-' '_' | tr '[:lower:]' '[:upper:]')
  
  SYS_PWD=$(get_container_secret "$cname" "oracle_pwd")
  [ -z "$SYS_PWD" ] && SYS_PWD=$(get_container_secret "$cname" "apex_db_sys_password")
  SCH_PWD=$(get_container_secret "$cname" "apex_schema_password")
  DEV_PWD=$(get_container_secret "$cname" "test_dev_password")
  WEB_PWD=$(get_container_secret "$cname" "test_web_password")
  ADMIN_PWD=$(get_container_secret "$cname" "apex_admin_password")

  (
    load_db_profile "$prof" >/dev/null 2>&1 || true
    yaml_file="$WORKSPACE_DIR/${PROFILE_YAML#$WORKSPACE_DIR/}"

    USER_DEFS=$(python3 -c "import sys, yaml; data = yaml.safe_load(open('$yaml_file')); [print(f\"{u.get('wallet_alias')}|{u.get('username')}|{u.get('role','NORMAL')}\") for u in data.get('users',[]) if u.get('wallet_alias')]" 2>/dev/null || true)


    if [ -z "$USER_DEFS" ]; then
      USER_DEFS="DB_${UPPER_NAME}_SYS|sys|SYSDBA
DB_${UPPER_NAME}_SCHEMA|APEX_PROXY_SCHEMA|NORMAL
DB_${UPPER_NAME}_DEV|TEST_DEV|NORMAL"
    fi

    while IFS='|' read -r alias uname urole; do
      [ -z "$alias" ] && continue
      
      pwd_var=""
      if [ "$uname" = "sys" ] || [ "$uname" = "SYS" ]; then
        pwd_var="$SYS_PWD"
      elif [ "$uname" = "APEX_PROXY_SCHEMA" ]; then
        pwd_var="$SCH_PWD"
      elif [ "$uname" = "TEST_DEV" ]; then
        pwd_var="$DEV_PWD"
      elif [ "$uname" = "TEST_WEB_USER" ]; then
        pwd_var="$WEB_PWD"
      elif [ "$uname" = "ADMIN" ]; then
        pwd_var="$ADMIN_PWD"
      else
        pwd_var=$(get_container_secret "$cname" "${uname}_password")
      fi

      podman exec -i \
        -e WALLET_PWD="$WALLET_PWD" \
        -e ALIAS="$alias" \
        -e UNAME="$uname" \
        -e PWD_VAR="$pwd_var" \
        "$cname" sh -c '
export JAVA_HOME=/usr/java/latest
export PATH=$JAVA_HOME/bin:$PATH
WALLET_PATH="/opt/oracle/admin/FREE/wallet"

echo "$WALLET_PWD" | mkstore -wrl $WALLET_PATH -deleteCredential "$ALIAS" >/dev/null 2>&1 || true
echo "$WALLET_PWD" | mkstore -wrl $WALLET_PATH -createCredential "$ALIAS" "$UNAME" "$PWD_VAR" >/dev/null 2>&1 || true
'
    done <<< "$USER_DEFS"

    # Always generate container-specific fallback aliases (DB_<CONTAINER>_SYS, etc.) and standardized aliases
    podman exec -i \
      -e WALLET_PWD="$WALLET_PWD" \
      -e SYS_PWD="$SYS_PWD" \
      -e SCH_PWD="$SCH_PWD" \
      -e DEV_PWD="$DEV_PWD" \
      -e UPPER_NAME="$UPPER_NAME" \
      "$cname" sh -c '
export JAVA_HOME=/usr/java/latest
export PATH=$JAVA_HOME/bin:$PATH
WALLET_PATH="/opt/oracle/admin/FREE/wallet"

echo "$WALLET_PWD" | mkstore -wrl $WALLET_PATH -deleteCredential "DB_${UPPER_NAME}_SYS" >/dev/null 2>&1 || true
echo "$WALLET_PWD" | mkstore -wrl $WALLET_PATH -createCredential "DB_${UPPER_NAME}_SYS" sys "$SYS_PWD" >/dev/null 2>&1 || true
echo "$WALLET_PWD" | mkstore -wrl $WALLET_PATH -deleteCredential "DB_${UPPER_NAME}_SCHEMA" >/dev/null 2>&1 || true
echo "$WALLET_PWD" | mkstore -wrl $WALLET_PATH -createCredential "DB_${UPPER_NAME}_SCHEMA" "${APEX_SCHEMA_USER:-APEX_PROXY_SCHEMA}" "$SCH_PWD" >/dev/null 2>&1 || true
echo "$WALLET_PWD" | mkstore -wrl $WALLET_PATH -deleteCredential "DB_${UPPER_NAME}_DEV" >/dev/null 2>&1 || true
echo "$WALLET_PWD" | mkstore -wrl $WALLET_PATH -createCredential "DB_${UPPER_NAME}_DEV" "${TEST_DEV_USER:-TEST_DEV}" "$DEV_PWD" >/dev/null 2>&1 || true

echo "$WALLET_PWD" | mkstore -wrl $WALLET_PATH -deleteCredential "DB_APEX_PROXY_SYS" >/dev/null 2>&1 || true
echo "$WALLET_PWD" | mkstore -wrl $WALLET_PATH -createCredential "DB_APEX_PROXY_SYS" sys "$SYS_PWD" >/dev/null 2>&1 || true
echo "$WALLET_PWD" | mkstore -wrl $WALLET_PATH -deleteCredential "DB_APEX_PROXY_SCHEMA" >/dev/null 2>&1 || true
echo "$WALLET_PWD" | mkstore -wrl $WALLET_PATH -createCredential "DB_APEX_PROXY_SCHEMA" "${APEX_SCHEMA_USER:-APEX_PROXY_SCHEMA}" "$SCH_PWD" >/dev/null 2>&1 || true
echo "$WALLET_PWD" | mkstore -wrl $WALLET_PATH -deleteCredential "APEX_PROXY_SCHEMA" >/dev/null 2>&1 || true
echo "$WALLET_PWD" | mkstore -wrl $WALLET_PATH -createCredential "APEX_PROXY_SCHEMA" "${APEX_SCHEMA_USER:-APEX_PROXY_SCHEMA}" "$SCH_PWD" >/dev/null 2>&1 || true
echo "$WALLET_PWD" | mkstore -wrl $WALLET_PATH -deleteCredential "DB_TEST_DEV" >/dev/null 2>&1 || true
echo "$WALLET_PWD" | mkstore -wrl $WALLET_PATH -createCredential "DB_TEST_DEV" "${TEST_DEV_USER:-TEST_DEV}" "$DEV_PWD" >/dev/null 2>&1 || true
'

  )

done < <(get_active_db_instances 2>/dev/null)

podman cp "$PROXY_CONTAINER:/opt/oracle/admin/FREE/wallet/cwallet.sso" "$TNS_DIR/cwallet.sso"
podman cp "$PROXY_CONTAINER:/opt/oracle/admin/FREE/wallet/ewallet.p12" "$TNS_DIR/ewallet.p12"

if [ -f "$WORKSPACE_DIR/config/certs/localCA.pem" ]; then
  echo -e "${CYAN}├─${NC} ${YELLOW}[Alamsamm 4.5.3]: Importin kohaliku juursertifikaadi (Root CA) kliendi walletisse...${NC}"
  echo -e "${CYAN}│${NC}  📊 Ajalooline ooteaeg: ${YELLOW}ootusaeg ~1s${NC}"
  cp "$WORKSPACE_DIR/config/certs/localCA.pem" "$TNS_DIR/localCA.pem"
  podman exec "$PROXY_CONTAINER" orapki wallet add -wallet /opt/oracle/admin/FREE/wallet -pwd "$WALLET_PWD" -trusted_cert -cert /opt/oracle/admin/FREE/wallet/localCA.pem >/dev/null 2>&1 || true
  rm -f "$TNS_DIR/localCA.pem"
fi

echo -e "${CYAN}├─${NC} ${YELLOW}[Alamsamm 4.5.4]: Genereerin TNS konfiguratsioonifailid...${NC}"
echo -e "${CYAN}│${NC}  📊 Ajalooline ooteaeg: ${YELLOW}ootusaeg ~1s${NC}"

# Genereerime hosti tnsnames.ora dünaamiliselt kõigi aktiivsete instantside ja profiilide jaoks
cat << EOF > "$TNS_DIR/tnsnames.ora"
# TNS Names Configuration for Host (Auto-generated: $(date))
EOF

get_active_db_instances 2>/dev/null | while IFS='|' read -r cname prof env_key; do
  [ -z "$cname" ] && continue
  UPPER_NAME=$(echo "$cname" | tr '-' '_' | tr '[:lower:]' '[:upper:]')
  (
    load_db_profile "$prof" >/dev/null 2>&1 || true
    port="${PROFILE_DB_PORT:-1532}"
    service="${PROFILE_DEFAULT_SERVICE:-FREEPDB1}"
    yaml_file="$WORKSPACE_DIR/${PROFILE_YAML#$WORKSPACE_DIR/}"

    USER_DEFS=$(python3 -c "import sys, yaml; data = yaml.safe_load(open('$yaml_file')); [print(f\"{u.get('wallet_alias')}|{u.get('username')}|{u.get('role','NORMAL')}\") for u in data.get('users',[]) if u.get('wallet_alias')]" 2>/dev/null || true)


    if [ -z "$USER_DEFS" ]; then
      USER_DEFS="DB_${UPPER_NAME}_SYS|sys|SYSDBA
DB_${UPPER_NAME}_SCHEMA|APEX_PROXY_SCHEMA|NORMAL
DB_${UPPER_NAME}_DEV|TEST_DEV|NORMAL"
    fi

    while IFS='|' read -r alias uname urole; do
      [ -z "$alias" ] && continue
      cat << EOF >> "$TNS_DIR/tnsnames.ora"

${alias} =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = ${port}))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ${service})
    )
  )
EOF
    done <<< "$USER_DEFS"

    # Always generate container-specific fallback aliases (DB_<CONTAINER>_SYS, etc.)
    cat << EOF >> "$TNS_DIR/tnsnames.ora"

DB_${UPPER_NAME}_SYS =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = ${port}))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ${service})
    )
  )

DB_${UPPER_NAME}_SCHEMA =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = ${port}))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ${service})
    )
  )

DB_${UPPER_NAME}_DEV =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = ${port}))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ${service})
    )
  )

DB_APEX_PROXY_SCHEMA =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = ${port}))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ${service})
    )
  )

APEX_PROXY_SCHEMA =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = ${port}))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ${service})
    )
  )

EOF
  )
done

CONTAINER_TNS_DIR="${TNS_DIR}_container"
mkdir -p "$CONTAINER_TNS_DIR"

cat << EOF > "$TNS_DIR/sqlnet.ora"
# SQL*Net Client Profile for Host (Auto-generated: $(date))
WALLET_LOCATION =
  (SOURCE =
    (METHOD = FILE)
    (METHOD_DATA =
      (DIRECTORY = $TNS_DIR)
    )
  )
SQLNET.WALLET_OVERRIDE = TRUE
EOF

cp "$TNS_DIR/cwallet.sso" "$CONTAINER_TNS_DIR/cwallet.sso"
cp "$TNS_DIR/ewallet.p12" "$CONTAINER_TNS_DIR/ewallet.p12"

cat << EOF > "$CONTAINER_TNS_DIR/sqlnet.ora"
# SQL*Net Client Profile for Container (Auto-generated: $(date))
WALLET_LOCATION =
  (SOURCE =
    (METHOD = FILE)
    (METHOD_DATA =
      (DIRECTORY = /tns)
    )
  )
SQLNET.WALLET_OVERRIDE = TRUE
EOF

# Genereerime konteineri tnsnames.ora dünaamiliselt
cat << EOF > "$CONTAINER_TNS_DIR/tnsnames.ora"
# TNS Names Configuration for Container (Auto-generated: $(date))
EOF

while IFS='|' read -r cname prof env_key; do
  [ -z "$cname" ] && continue
  UPPER_NAME=$(echo "$cname" | tr '-' '_' | tr '[:lower:]' '[:upper:]')
  (
    load_db_profile "$prof" >/dev/null 2>&1 || true
    service="${PROFILE_DEFAULT_SERVICE:-FREEPDB1}"
    yaml_file="$WORKSPACE_DIR/${PROFILE_YAML#$WORKSPACE_DIR/}"

    USER_DEFS=$(python3 -c "import sys, yaml; data = yaml.safe_load(open('$yaml_file')); [print(f\"{u.get('wallet_alias')}|{u.get('username')}|{u.get('role','NORMAL')}\") for u in data.get('users',[]) if u.get('wallet_alias')]" 2>/dev/null || true)


    if [ -z "$USER_DEFS" ]; then
      USER_DEFS="DB_${UPPER_NAME}_SYS|sys|SYSDBA
DB_${UPPER_NAME}_SCHEMA|APEX_PROXY_SCHEMA|NORMAL
DB_${UPPER_NAME}_DEV|TEST_DEV|NORMAL"
    fi

    while IFS='|' read -r alias uname urole; do
      [ -z "$alias" ] && continue
      cat << EOF >> "$CONTAINER_TNS_DIR/tnsnames.ora"

${alias} =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = ${cname})(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ${service})
    )
  )
EOF
    done <<< "$USER_DEFS"

    cat << EOF >> "$CONTAINER_TNS_DIR/tnsnames.ora"

DB_${UPPER_NAME}_SYS =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = ${cname})(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ${service})
    )
  )

DB_${UPPER_NAME}_SCHEMA =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = ${cname})(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ${service})
    )
  )

DB_${UPPER_NAME}_DEV =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = ${cname})(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ${service})
    )
  )
EOF
  )
done < <(get_active_db_instances 2>/dev/null)


chmod 644 "$TNS_DIR"/ewallet.p12 "$TNS_DIR"/cwallet.sso "$TNS_DIR"/*.ora 2>/dev/null || true
chmod 644 "$CONTAINER_TNS_DIR"/* 2>/dev/null || true

# TNS fallback sümbollingid kasutaja kodukaustas raw SQLcl käivituseks
ln -sf "$TNS_DIR/tnsnames.ora" "$HOME/tnsnames.ora" 2>/dev/null || true
ln -sf "$TNS_DIR/sqlnet.ora" "$HOME/sqlnet.ora" 2>/dev/null || true
ln -sf "$TNS_DIR/cwallet.sso" "$HOME/cwallet.sso" 2>/dev/null || true
ln -sf "$TNS_DIR/ewallet.p12" "$HOME/ewallet.p12" 2>/dev/null || true

# Süsteemse sql wrapperi tagamine kasutaja PATH kaustades
for bin_dir in "$HOME/Applications/sqlcl/bin" "$HOME/.local/bin" "$HOME/bin"; do
  if [ -d "$bin_dir" ]; then
    cat << 'EOF' > "$bin_dir/sql"
#!/usr/bin/env bash
set -e
PROJ_DIR=""
CURR_DIR="$(pwd)"
while [ "$CURR_DIR" != "/" ]; do
  if [ -f "$CURR_DIR/scripts/sqlcl.sh" ]; then
    PROJ_DIR="$CURR_DIR"
    break
  fi
  CURR_DIR="$(dirname "$CURR_DIR")"
done

if [ -n "$PROJ_DIR" ] && [ -f "$PROJ_DIR/scripts/sqlcl.sh" ]; then
  exec "$PROJ_DIR/scripts/sqlcl.sh" "$@"
fi

DEFAULT_WORKSPACE="/Users/allanlahe/Oracle/oracle-free-db-in-prod"
if [ -f "$DEFAULT_WORKSPACE/scripts/sqlcl.sh" ]; then
  exec "$DEFAULT_WORKSPACE/scripts/sqlcl.sh" "$@"
fi

HB_SQL="/opt/homebrew/Caskroom/sqlcl/24.3.1.311.1631/sqlcl/bin/sql"
if [ -x "$HB_SQL" ]; then
  exec "$HB_SQL" "$@"
fi

echo "❌ Viga: SQLcl utiliiti ei leitud!"
exit 1
EOF
    chmod +x "$bin_dir/sql" 2>/dev/null || true
  fi
done

if command -v zip &>/dev/null; then
  (cd "$TNS_DIR" && zip -q -r "$WORKSPACE_DIR/config/oracle_db_wallet.zip" .) 2>/dev/null || true
fi


echo -e "${CYAN}│${NC}  ✅ Wallet ja TNS failid loodud asukohta: ${GREEN}$TNS_DIR${NC}"
echo -e "${CYAN}│${NC}  📦 GUI Wallet ZIP pakk loodud asukohta: ${GREEN}$WORKSPACE_DIR/config/oracle_db_wallet.zip${NC}"
