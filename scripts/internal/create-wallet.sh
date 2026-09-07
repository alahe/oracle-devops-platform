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

# Load environment variables and profile engine
if [ -f "$WORKSPACE_DIR/.env" ]; then
  set -a
  source "$WORKSPACE_DIR/.env"
  set +a
fi

if [ -f "$SCRIPT_DIR/load-profile.sh" ]; then
  source "$SCRIPT_DIR/load-profile.sh"
  resolve_active_blueprint 2>/dev/null || true
  load_db_profile >/dev/null 2>&1 || true
fi

if [ -f "$SCRIPT_DIR/i18n.sh" ]; then
  # shellcheck source=/dev/null
  source "$SCRIPT_DIR/i18n.sh"
fi
if [ -f "$SCRIPT_DIR/credential-helper.sh" ]; then
  # shellcheck source=/dev/null
  source "$SCRIPT_DIR/credential-helper.sh"
fi

# Detect primary active database container name and dynamic alias
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

# Helper function to securely query secret from running container or Podman Secrets store
get_container_secret() {
  local container="$1"
  local name="$2"
  local val=""

  # 1. Container-specific secret names (e.g. proxy_dev_password, proxy_db_sys_password)
  if [ -n "$container" ]; then
    local c_short=$(echo "$container" | sed 's/^db-//' | tr '-' '_')
    val=$(podman secret inspect --showsecret "${c_short}_${name}" 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
    [ -z "$val" ] && val=$(podman secret inspect --showsecret "${c_short}_db_${name}" 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
    [ -z "$val" ] && val=$(podman secret inspect --showsecret "${container}_${name}" 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
  fi

  # 2. Direct match for secret name
  if [ -z "$val" ]; then
    val=$(podman secret inspect --showsecret "$name" 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
  fi

  # 3. Running container /run/secrets/ files
  if [ -z "$val" ] && podman container exists "$container" 2>/dev/null && [ "$(podman inspect --format='{{.State.Status}}' "$container" 2>/dev/null)" = "running" ]; then
    val=$(podman exec "$container" cat "/run/secrets/$name" 2>/dev/null || podman exec "$container" cat "/run/secrets/oracle_pwd" 2>/dev/null || true)
  fi

  # 4. Fallback to default apex_db_sys_password only if still empty
  if [ -z "$val" ] && { [ "$name" = "oracle_pwd" ] || [[ "$name" == *_sys_password ]]; }; then
    val=$(podman secret inspect --showsecret apex_db_sys_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
  fi

  echo "$val"
}

# Color setup
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

# Auto-extract OCI Cloud Wallet archive if present
for wzip in "$TNS_DIR"/Wallet_*.zip "$TNS_DIR"/wallet.zip "$WORKSPACE_DIR"/config/Wallet_*.zip "$WORKSPACE_DIR"/config/wallet.zip; do
  if [ -f "$wzip" ]; then
    echo -e "${CYAN}├─${NC} ${YELLOW}[Autonomous Database]: Found OCI Cloud Wallet package: $(basename "$wzip")${NC}"
    unzip -o -q "$wzip" -d "$TNS_DIR" 2>/dev/null || true
    break
  fi
done

IS_ADB=false
if { [ "$PROFILE_DB_TYPE" = "adb" ] || [ "$IS_ADB" = "true" ] || [ "$APEX_DB_TYPE" = "ADB" ] || [[ "$APEX_DB_IMAGE" == *"adb-free"* ]]; }; then
  if [ -f "$TNS_DIR/cwallet.sso" ] && [ -f "$TNS_DIR/tnsnames.ora" ]; then
    echo -e "${CYAN}├─${NC} ${GREEN}[Autonomous Database]: Valid OCI Cloud mTLS Wallet detected in config/tns_admin!${NC}"
    
    # Generate client sqlnet.ora for mTLS
    cat << EOF > "$TNS_DIR/sqlnet.ora"
# SQL*Net Client Profile for OCI Autonomous Database (mTLS)
WALLET_LOCATION =
  (SOURCE =
    (METHOD = FILE)
    (METHOD_DATA =
      (DIRECTORY = "$TNS_DIR")
    )
  )
SQLNET.WALLET_OVERRIDE = TRUE
SSL_SERVER_DN_MATCH = ON
EOF

    CONTAINER_TNS_DIR="$WORKSPACE_DIR/config/container_tns_admin"
    mkdir -p "$CONTAINER_TNS_DIR"
    cp "$TNS_DIR"/cwallet.sso "$CONTAINER_TNS_DIR/cwallet.sso" 2>/dev/null || true
    cp "$TNS_DIR"/*.ora "$CONTAINER_TNS_DIR/" 2>/dev/null || true

    cat << EOF > "$CONTAINER_TNS_DIR/sqlnet.ora"
# SQL*Net Client Profile for Container (Auto-generated)
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
    echo -e "${CYAN}│${NC}  ✅ OCI Cloud Wallet and TNS configurations successfully synchronized!"
    exit 0
  elif podman exec "$PROXY_CONTAINER" sh -c "[ -d /u01/app/oracle/wallets/tls_wallet ]" 2>/dev/null; then
    IS_ADB=true
  fi
fi

if [ "$IS_ADB" = "true" ]; then
  echo -e "${CYAN}├─${NC} ${YELLOW}[Autonomous Database]: Using ADB internal mTLS Wallet...${NC}"
  echo -e "${CYAN}│${NC}  ⌛ Waiting until ADB creates wallet files (ewallet.p12 and cwallet.sso)..."

  WAIT_S=0
  until podman exec "$PROXY_CONTAINER" sh -c "[ -f /u01/app/oracle/wallets/tls_wallet/cwallet.sso ] && [ -f /u01/app/oracle/wallets/tls_wallet/tnsnames.ora ]" &>/dev/null; do
    sleep 3
    WAIT_S=$((WAIT_S + 3))
    print_progress "   Waiting for wallet and tnsnames files in container... ${ORANGE}${WAIT_S}s${NC}\r"
    if [ $WAIT_S -ge 180 ]; then
      echo ""
      echo -e "${CYAN}│${NC}  ❌ Error: ADB did not generate wallet files inside container within 180 seconds!"
      exit 1
    fi
  done
  echo ""

  echo -e "${CYAN}│${NC}  🔐 Registering system SEPS credentials in ADB Wallet..."
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

  echo -e "${CYAN}│${NC}  ✅ ADB Wallet and TNS configurations successfully synchronized!"
  exit 0
fi

# Standard (Gvenzl / Oracle Free) Wallet creation
rm -f "$TNS_DIR/ewallet.p12" "$TNS_DIR/cwallet.sso" "$TNS_DIR/ewallet.p12.lck" "$TNS_DIR/cwallet.sso.lck"
if podman container exists "$PROXY_CONTAINER" 2>/dev/null; then
  podman exec "$PROXY_CONTAINER" rm -f /opt/oracle/admin/FREE/wallet/ewallet.p12 /opt/oracle/admin/FREE/wallet/cwallet.sso /opt/oracle/admin/FREE/wallet/ewallet.p12.lck /opt/oracle/admin/FREE/wallet/cwallet.sso.lck || true
fi

MAX_ATTEMPTS=15
HOST_SQLCL_DIR=$(find "$HOME/.vscode/extensions" -name "sqlcl" -type d 2>/dev/null | sort -rV | head -n 1 || true)
USE_HOST_PKI=false
JAVA_BIN=""
if [ -n "${JAVA_HOME:-}" ] && [ -x "$JAVA_HOME/bin/java" ]; then
  JAVA_BIN="$JAVA_HOME/bin/java"
elif command -v java >/dev/null 2>&1; then
  JAVA_BIN="$(command -v java)"
else
  JAVA_BIN=$(find "$HOME/.vscode/extensions" -name "java" -type f -perm +111 2>/dev/null | head -n 1 || true)
fi

if [ -n "$HOST_SQLCL_DIR" ] && [ -n "$JAVA_BIN" ] && [ -x "$JAVA_BIN" ]; then
  HOST_SQLCL_CP=$(find "$HOST_SQLCL_DIR/lib" -name "*.jar" | tr '\n' ':')
  if "$JAVA_BIN" -cp "$HOST_SQLCL_CP" oracle.security.pki.textui.OraclePKITextUI help >/dev/null 2>&1; then
    USE_HOST_PKI=true
  fi
fi

USE_EPHEMERAL_WALLET=false
if [ "$USE_HOST_PKI" = "false" ]; then
  if ! podman exec "$PROXY_CONTAINER" bash -c '[ -d "/opt/oracle/product/23ai/dbhomeFree/jdk" ] || [ -d "/usr/java/default" ] || [ -d "/usr/java/latest" ]' >/dev/null 2>&1; then
    USE_EPHEMERAL_WALLET=true
  fi
fi

echo -e "${CYAN}├─${NC} ${YELLOW}[$(msg_str "STEP_4_5_NAME") 1]: $(msg_str "SUB_WALLET_1")${NC}"
echo -e "${CYAN}│${NC}  📊 $(msg_str "BENCHMARK_LABEL") ${YELLOW}$(msg_str "BENCHMARK_EST" "2s")${NC}"
ATTEMPT=1
if [ "$USE_HOST_PKI" = "true" ]; then
  "$JAVA_BIN" -cp "$HOST_SQLCL_CP" oracle.security.pki.textui.OraclePKITextUI wallet create -wallet "$TNS_DIR" -pwd "$WALLET_PWD" -auto_login >/dev/null 2>&1 || true
elif [ "$USE_EPHEMERAL_WALLET" = "true" ]; then
  HELPER_IMG="${FORMS_CONTAINER_IMAGE:-localhost/oracle-forms:14.1.2}"
  if ! podman image exists "$HELPER_IMG" 2>/dev/null; then
    HELPER_IMG="container-registry.oracle.com/database/sqlcl:latest"
  fi
  until podman run --rm -v "$TNS_DIR:/u01/oracle/tns_admin:rw" "$HELPER_IMG" /u01/oracle/bin/orapki wallet create -wallet /u01/oracle/tns_admin -pwd "$WALLET_PWD" -auto_login >/dev/null 2>&1; do
    if [ $ATTEMPT -ge $MAX_ATTEMPTS ]; then
      echo -e "${CYAN}│${NC}  ❌ Error: Wallet generation using orapki failed after $MAX_ATTEMPTS attempts!"
      exit 255
    fi
    echo -e "${CYAN}│${NC}  ⚠️  orapki execution failed (transient error). Retrying... (Attempt $ATTEMPT/$MAX_ATTEMPTS)"
    sleep 2
    ATTEMPT=$((ATTEMPT + 1))
  done
else
  until podman exec "$PROXY_CONTAINER" bash -c '
    mkdir -p /opt/oracle/admin/FREE/wallet
    if [ -d "/opt/oracle/product/23ai/dbhomeFree/jdk" ]; then
      export JAVA_HOME="/opt/oracle/product/23ai/dbhomeFree/jdk"
    elif ls -d /opt/oracle/product/*/dbhomeFree/jdk 2>/dev/null | head -n 1; then
      export JAVA_HOME="$(ls -d /opt/oracle/product/*/dbhomeFree/jdk 2>/dev/null | head -n 1)"
    elif [ -d "/usr/java/default" ]; then
      export JAVA_HOME="/usr/java/default"
    elif [ -d "/usr/java/latest" ]; then
      export JAVA_HOME="/usr/java/latest"
    fi
    export PATH=$JAVA_HOME/bin:$ORACLE_HOME/bin:$PATH
    orapki wallet create -wallet /opt/oracle/admin/FREE/wallet -pwd "$1" -auto_login
  ' _ "$WALLET_PWD" >/dev/null 2>&1; do
    if [ $ATTEMPT -ge $MAX_ATTEMPTS ]; then
      echo -e "${CYAN}│${NC}  ❌ Error: Wallet generation using orapki failed after $MAX_ATTEMPTS attempts!"
      exit 255
    fi
    echo -e "${CYAN}│${NC}  ⚠️  orapki execution failed (transient error). Retrying... (Attempt $ATTEMPT/$MAX_ATTEMPTS)"
    sleep 2
    ATTEMPT=$((ATTEMPT + 1))
  done
fi

echo -e "${CYAN}├─${NC} ${YELLOW}[$(msg_str "STEP_4_5_NAME") 2]: $(msg_str "SUB_WALLET_2")${NC}"
echo -e "${CYAN}│${NC}  📊 $(msg_str "BENCHMARK_LABEL") ${YELLOW}$(msg_str "BENCHMARK_EST" "2s")${NC}"

instances=()
while IFS= read -r line; do
  [ -n "$line" ] && instances+=("$line")
done < <(get_active_db_instances 2>/dev/null)

# Ensure Core Base db-proxy is always preserved if running or existing
has_proxy=false
for inst in "${instances[@]}"; do
  [[ "$inst" == db-proxy\|* ]] && has_proxy=true
done
if [ "$has_proxy" = "false" ] && podman container exists db-proxy 2>/dev/null; then
  instances+=("db-proxy|db-oracle|DB_PROXY")
fi

# Also include any other running database containers from previous blueprints
if command -v podman >/dev/null 2>&1; then
  for running_db in $(podman ps --format "{{.Names}}" 2>/dev/null | grep -E '^db-' || true); do
    already_included=false
    for inst in "${instances[@]}"; do
      [[ "$inst" == ${running_db}\|* ]] && already_included=true
    done
    if [ "$already_included" = "false" ]; then
      r_prof="db-oracle"
      if [ -f "$WORKSPACE_DIR/config/profiles/databases/${running_db}.yaml" ]; then
        r_prof="${running_db}"
      fi
      r_env_key=$(echo "$running_db" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
      instances+=("${running_db}|${r_prof}|${r_env_key}")
    fi
  done
fi

for inst in "${instances[@]}"; do
  IFS='|' read -r cname prof env_key <<< "$inst"
  [ -z "$cname" ] && continue
  UPPER_NAME=$(echo "$cname" | sed 's/^db[-_]//' | tr '-' '_' | tr '[:lower:]' '[:upper:]')
  CNAME_UPPER=$(echo "$cname" | tr '-' '_' | tr '[:lower:]' '[:upper:]')
  
  SYS_PWD=$(get_container_secret "$cname" "db_sys_password" 2>/dev/null || true)
  [ -z "$SYS_PWD" ] && SYS_PWD=$(get_container_secret "$cname" "sys_password" 2>/dev/null || true)
  [ -z "$SYS_PWD" ] && SYS_PWD=$(get_db_sys_password "$cname" 2>/dev/null || true)

  DBA_PWD=$(get_container_secret "$cname" "dba_admin_password" 2>/dev/null || true)
  [ -z "$DBA_PWD" ] && DBA_PWD=$(get_db_user_password "$cname" "dba_admin" 2>/dev/null || echo "$SYS_PWD")

  DEV_PWD=$(get_container_secret "$cname" "dev_password" 2>/dev/null || true)
  [ -z "$DEV_PWD" ] && DEV_PWD=$(get_container_secret "$cname" "user_developer_password" 2>/dev/null || true)
  [ -z "$DEV_PWD" ] && DEV_PWD=$(get_db_user_password "$cname" "dev" 2>/dev/null || echo "$SYS_PWD")

  VIEWER_PWD=$(get_container_secret "$cname" "viewer_password" 2>/dev/null || true)
  [ -z "$VIEWER_PWD" ] && VIEWER_PWD=$(get_container_secret "$cname" "user_viewer_password" 2>/dev/null || true)
  [ -z "$VIEWER_PWD" ] && VIEWER_PWD=$(get_db_user_password "$cname" "viewer" 2>/dev/null || echo "$SYS_PWD")

  APP_PWD=$(get_container_secret "$cname" "app_password" 2>/dev/null || true)
  [ -z "$APP_PWD" ] && APP_PWD=$(get_container_secret "$cname" "user_app_password" 2>/dev/null || true)
  [ -z "$APP_PWD" ] && APP_PWD=$(get_db_user_password "$cname" "app" 2>/dev/null || echo "$SYS_PWD")

  SCH_PWD=$(get_container_secret "$cname" "schema_password" 2>/dev/null || true)
  [ -z "$SCH_PWD" ] && SCH_PWD=$(get_db_user_password "$cname" "schema" 2>/dev/null || echo "$SYS_PWD")

  ADMIN_PWD=$(get_container_secret "$cname" "apex_admin_password" 2>/dev/null || true)
  [ -z "$ADMIN_PWD" ] && ADMIN_PWD=$(get_service_admin_password "apex_admin" 2>/dev/null || echo "$SYS_PWD")

  APEX_LISTENER_PWD=$(get_container_secret "$cname" "ords_listener_password" 2>/dev/null || true)
  [ -z "$APEX_LISTENER_PWD" ] && APEX_LISTENER_PWD=$(get_container_secret "$cname" "apex_schema_password" 2>/dev/null || true)
  [ -z "$APEX_LISTENER_PWD" ] && APEX_LISTENER_PWD="$SYS_PWD"

  APEX_ADMIN_PWD="$ADMIN_PWD"

  (
    # Canonical container-specific aliases (DB_<NAME>_*)
    pfx="$UPPER_NAME"
    if [ "$USE_HOST_PKI" = "true" ]; then
      for c_alias in "DB_${pfx}_SYS|sys|$SYS_PWD" "DB_${pfx}_DBA_ADMIN|DBA_ADMIN|$DBA_PWD" "DB_${pfx}_SCHEMA|${APEX_SCHEMA_USER:-APEX_PROXY_SCHEMA}|$SCH_PWD" "DB_${pfx}_DEV|${TEST_DEV_USER:-USER_DEVELOPER}|$DEV_PWD" "DB_${pfx}_APP|USER_APP|$APP_PWD" "DB_${pfx}_VIEWER|USER_VIEWER|$VIEWER_PWD" "DB_${pfx}_APEX_ADMIN|ADMIN|$APEX_ADMIN_PWD" "DB_${pfx}_APEX_PUBLIC_USER|APEX_PUBLIC_USER|$APEX_LISTENER_PWD" "DB_${pfx}_APEX_LISTENER|APEX_LISTENER|$APEX_LISTENER_PWD" "DB_${pfx}_ORDS_PUBLIC_USER|ORDS_PUBLIC_USER|$APEX_LISTENER_PWD"; do
        IFS='|' read -r a_name a_user a_pwd <<< "$c_alias"
        [ -n "$a_pwd" ] || continue
        "$JAVA_BIN" -cp "$HOST_SQLCL_CP" oracle.security.pki.textui.OraclePKITextUI secretstore delete_credential -wallet "$TNS_DIR" -pwd "$WALLET_PWD" -connect_string "$a_name" >/dev/null 2>&1 || true
        "$JAVA_BIN" -cp "$HOST_SQLCL_CP" oracle.security.pki.textui.OraclePKITextUI secretstore create_credential -wallet "$TNS_DIR" -pwd "$WALLET_PWD" -connect_string "$a_name" -username "$a_user" -password "$a_pwd" >/dev/null 2>&1 || true
      done
    elif [ "$USE_EPHEMERAL_WALLET" = "true" ]; then
      podman run -i --rm -v "$TNS_DIR:/u01/oracle/tns_admin:rw" "$HELPER_IMG" bash -c "
        export PATH=/usr/java/default/bin:/u01/oracle/bin:\$PATH
        WALLET_PATH=/u01/oracle/tns_admin
        echo '$WALLET_PWD' | /u01/oracle/bin/mkstore -wrl \$WALLET_PATH -deleteCredential 'DB_${pfx}_SYS' >/dev/null 2>&1 || true
        echo '$WALLET_PWD' | /u01/oracle/bin/mkstore -wrl \$WALLET_PATH -createCredential 'DB_${pfx}_SYS' sys '$SYS_PWD' >/dev/null 2>&1 || true
        echo '$WALLET_PWD' | /u01/oracle/bin/mkstore -wrl \$WALLET_PATH -deleteCredential 'DB_${pfx}_DBA_ADMIN' >/dev/null 2>&1 || true
        echo '$WALLET_PWD' | /u01/oracle/bin/mkstore -wrl \$WALLET_PATH -createCredential 'DB_${pfx}_DBA_ADMIN' DBA_ADMIN '$DBA_PWD' >/dev/null 2>&1 || true
        echo '$WALLET_PWD' | /u01/oracle/bin/mkstore -wrl \$WALLET_PATH -deleteCredential 'DB_${pfx}_SCHEMA' >/dev/null 2>&1 || true
        echo '$WALLET_PWD' | /u01/oracle/bin/mkstore -wrl \$WALLET_PATH -createCredential 'DB_${pfx}_SCHEMA' '${APEX_SCHEMA_USER:-APEX_PROXY_SCHEMA}' '$SCH_PWD' >/dev/null 2>&1 || true
        echo '$WALLET_PWD' | /u01/oracle/bin/mkstore -wrl \$WALLET_PATH -deleteCredential 'DB_${pfx}_DEV' >/dev/null 2>&1 || true
        echo '$WALLET_PWD' | /u01/oracle/bin/mkstore -wrl \$WALLET_PATH -createCredential 'DB_${pfx}_DEV' '${TEST_DEV_USER:-USER_DEVELOPER}' '$DEV_PWD' >/dev/null 2>&1 || true
        echo '$WALLET_PWD' | /u01/oracle/bin/mkstore -wrl \$WALLET_PATH -deleteCredential 'DB_${pfx}_APP' >/dev/null 2>&1 || true
        echo '$WALLET_PWD' | /u01/oracle/bin/mkstore -wrl \$WALLET_PATH -createCredential 'DB_${pfx}_APP' 'USER_APP' '$APP_PWD' >/dev/null 2>&1 || true
        echo '$WALLET_PWD' | /u01/oracle/bin/mkstore -wrl \$WALLET_PATH -deleteCredential 'DB_${pfx}_VIEWER' >/dev/null 2>&1 || true
        echo '$WALLET_PWD' | /u01/oracle/bin/mkstore -wrl \$WALLET_PATH -createCredential 'DB_${pfx}_VIEWER' USER_VIEWER '$VIEWER_PWD' >/dev/null 2>&1 || true
        echo '$WALLET_PWD' | /u01/oracle/bin/mkstore -wrl \$WALLET_PATH -deleteCredential 'DB_${pfx}_APEX_ADMIN' >/dev/null 2>&1 || true
        echo '$WALLET_PWD' | /u01/oracle/bin/mkstore -wrl \$WALLET_PATH -createCredential 'DB_${pfx}_APEX_ADMIN' 'ADMIN' '$APEX_ADMIN_PWD' >/dev/null 2>&1 || true
        echo '$WALLET_PWD' | /u01/oracle/bin/mkstore -wrl \$WALLET_PATH -deleteCredential 'DB_${pfx}_APEX_PUBLIC_USER' >/dev/null 2>&1 || true
        echo '$WALLET_PWD' | /u01/oracle/bin/mkstore -wrl \$WALLET_PATH -createCredential 'DB_${pfx}_APEX_PUBLIC_USER' 'APEX_PUBLIC_USER' '$APEX_LISTENER_PWD' >/dev/null 2>&1 || true
        echo '$WALLET_PWD' | /u01/oracle/bin/mkstore -wrl \$WALLET_PATH -deleteCredential 'DB_${pfx}_APEX_LISTENER' >/dev/null 2>&1 || true
        echo '$WALLET_PWD' | /u01/oracle/bin/mkstore -wrl \$WALLET_PATH -createCredential 'DB_${pfx}_APEX_LISTENER' 'APEX_LISTENER' '$APEX_LISTENER_PWD' >/dev/null 2>&1 || true
        echo '$WALLET_PWD' | /u01/oracle/bin/mkstore -wrl \$WALLET_PATH -deleteCredential 'DB_${pfx}_ORDS_PUBLIC_USER' >/dev/null 2>&1 || true
        echo '$WALLET_PWD' | /u01/oracle/bin/mkstore -wrl \$WALLET_PATH -createCredential 'DB_${pfx}_ORDS_PUBLIC_USER' 'ORDS_PUBLIC_USER' '$APEX_LISTENER_PWD' >/dev/null 2>&1 || true
      "
    else
      podman exec -i \
        -e WALLET_PWD="$WALLET_PWD" \
        -e SYS_PWD="$SYS_PWD" \
        -e DBA_PWD="$DBA_PWD" \
        -e SCH_PWD="$SCH_PWD" \
        -e DEV_PWD="$DEV_PWD" \
        -e APP_PWD="$APP_PWD" \
        -e VIEWER_PWD="$VIEWER_PWD" \
        -e APEX_LISTENER_PWD="$APEX_LISTENER_PWD" \
        -e APEX_ADMIN_PWD="$APEX_ADMIN_PWD" \
        -e UPPER_NAME="$UPPER_NAME" \
        "$PROXY_CONTAINER" sh -c '
if [ -d "/opt/oracle/product/23ai/dbhomeFree/jdk" ]; then
  export JAVA_HOME="/opt/oracle/product/23ai/dbhomeFree/jdk"
elif ls -d /opt/oracle/product/*/dbhomeFree/jdk 2>/dev/null | head -n 1; then
  export JAVA_HOME="$(ls -d /opt/oracle/product/*/dbhomeFree/jdk 2>/dev/null | head -n 1)"
elif [ -d "/usr/java/default" ]; then
  export JAVA_HOME="/usr/java/default"
elif [ -d "/usr/java/latest" ]; then
  export JAVA_HOME="/usr/java/latest"
fi
export PATH=$JAVA_HOME/bin:$ORACLE_HOME/bin:$PATH
WALLET_PATH="/opt/oracle/admin/FREE/wallet"

pfx="$UPPER_NAME"
echo "$WALLET_PWD" | mkstore -wrl $WALLET_PATH -deleteCredential "DB_${pfx}_SYS" >/dev/null 2>&1 || true
echo "$WALLET_PWD" | mkstore -wrl $WALLET_PATH -createCredential "DB_${pfx}_SYS" sys "$SYS_PWD" >/dev/null 2>&1 || true
echo "$WALLET_PWD" | mkstore -wrl $WALLET_PATH -deleteCredential "DB_${pfx}_DBA_ADMIN" >/dev/null 2>&1 || true
echo "$WALLET_PWD" | mkstore -wrl $WALLET_PATH -createCredential "DB_${pfx}_DBA_ADMIN" DBA_ADMIN "$DBA_PWD" >/dev/null 2>&1 || true
echo "$WALLET_PWD" | mkstore -wrl $WALLET_PATH -deleteCredential "DB_${pfx}_SCHEMA" >/dev/null 2>&1 || true
echo "$WALLET_PWD" | mkstore -wrl $WALLET_PATH -createCredential "DB_${pfx}_SCHEMA" "${APEX_SCHEMA_USER:-APEX_PROXY_SCHEMA}" "$SCH_PWD" >/dev/null 2>&1 || true
echo "$WALLET_PWD" | mkstore -wrl $WALLET_PATH -deleteCredential "DB_${pfx}_DEV" >/dev/null 2>&1 || true
echo "$WALLET_PWD" | mkstore -wrl $WALLET_PATH -createCredential "DB_${pfx}_DEV" "${TEST_DEV_USER:-USER_DEVELOPER}" "$DEV_PWD" >/dev/null 2>&1 || true
echo "$WALLET_PWD" | mkstore -wrl $WALLET_PATH -deleteCredential "DB_${pfx}_APP" >/dev/null 2>&1 || true
echo "$WALLET_PWD" | mkstore -wrl $WALLET_PATH -createCredential "DB_${pfx}_APP" "USER_APP" "$APP_PWD" >/dev/null 2>&1 || true
echo "$WALLET_PWD" | mkstore -wrl $WALLET_PATH -deleteCredential "DB_${pfx}_VIEWER" >/dev/null 2>&1 || true
echo "$WALLET_PWD" | mkstore -wrl $WALLET_PATH -createCredential "DB_${pfx}_VIEWER" USER_VIEWER "$VIEWER_PWD" >/dev/null 2>&1 || true

# System & Web credentials per database
echo "$WALLET_PWD" | mkstore -wrl $WALLET_PATH -deleteCredential "DB_${pfx}_APEX_ADMIN" >/dev/null 2>&1 || true
echo "$WALLET_PWD" | mkstore -wrl $WALLET_PATH -createCredential "DB_${pfx}_APEX_ADMIN" "ADMIN" "$APEX_ADMIN_PWD" >/dev/null 2>&1 || true
echo "$WALLET_PWD" | mkstore -wrl $WALLET_PATH -deleteCredential "DB_${pfx}_APEX_PUBLIC_USER" >/dev/null 2>&1 || true
echo "$WALLET_PWD" | mkstore -wrl $WALLET_PATH -createCredential "DB_${pfx}_APEX_PUBLIC_USER" "APEX_PUBLIC_USER" "$APEX_LISTENER_PWD" >/dev/null 2>&1 || true
echo "$WALLET_PWD" | mkstore -wrl $WALLET_PATH -deleteCredential "DB_${pfx}_APEX_LISTENER" >/dev/null 2>&1 || true
echo "$WALLET_PWD" | mkstore -wrl $WALLET_PATH -createCredential "DB_${pfx}_APEX_LISTENER" "APEX_LISTENER" "$APEX_LISTENER_PWD" >/dev/null 2>&1 || true
echo "$WALLET_PWD" | mkstore -wrl $WALLET_PATH -deleteCredential "DB_${pfx}_ORDS_PUBLIC_USER" >/dev/null 2>&1 || true
echo "$WALLET_PWD" | mkstore -wrl $WALLET_PATH -createCredential "DB_${pfx}_ORDS_PUBLIC_USER" "ORDS_PUBLIC_USER" "$APEX_LISTENER_PWD" >/dev/null 2>&1 || true
'
    fi
  )
done

if [ "$USE_HOST_PKI" = "true" ]; then
  if podman container exists "$PROXY_CONTAINER" 2>/dev/null; then
    podman exec "$PROXY_CONTAINER" mkdir -p /opt/oracle/admin/FREE/wallet 2>/dev/null || true
    podman cp "$TNS_DIR/cwallet.sso" "$PROXY_CONTAINER:/opt/oracle/admin/FREE/wallet/" 2>/dev/null || true
    podman cp "$TNS_DIR/ewallet.p12" "$PROXY_CONTAINER:/opt/oracle/admin/FREE/wallet/" 2>/dev/null || true
  fi
elif [ "$USE_EPHEMERAL_WALLET" != "true" ]; then
  podman cp "$PROXY_CONTAINER:/opt/oracle/admin/FREE/wallet/cwallet.sso" "$TNS_DIR/cwallet.sso"
  podman cp "$PROXY_CONTAINER:/opt/oracle/admin/FREE/wallet/ewallet.p12" "$TNS_DIR/ewallet.p12"
fi

if [ -f "$WORKSPACE_DIR/config/certs/localCA.pem" ]; then
  echo -e "${CYAN}├─${NC} ${YELLOW}[$(msg_str "STEP_4_5_NAME") 3]: $(msg_str "SUB_WALLET_3")${NC}"
  echo -e "${CYAN}│${NC}  📊 $(msg_str "BENCHMARK_LABEL") ${YELLOW}$(msg_str "BENCHMARK_EST" "1s")${NC}"
  cp "$WORKSPACE_DIR/config/certs/localCA.pem" "$TNS_DIR/localCA.pem"
  if [ "$USE_HOST_PKI" = "true" ]; then
    "$JAVA_BIN" -cp "$HOST_SQLCL_CP" oracle.security.pki.textui.OraclePKITextUI wallet add -wallet "$TNS_DIR" -pwd "$WALLET_PWD" -trusted_cert -cert "$TNS_DIR/localCA.pem" >/dev/null 2>&1 || true
    if podman container exists "$PROXY_CONTAINER" 2>/dev/null; then
      podman cp "$TNS_DIR/cwallet.sso" "$PROXY_CONTAINER:/opt/oracle/admin/FREE/wallet/" 2>/dev/null || true
      podman cp "$TNS_DIR/ewallet.p12" "$PROXY_CONTAINER:/opt/oracle/admin/FREE/wallet/" 2>/dev/null || true
    fi
  elif [ "$USE_EPHEMERAL_WALLET" = "true" ]; then
    podman run --rm -v "$TNS_DIR:/u01/oracle/tns_admin:rw" "$HELPER_IMG" /u01/oracle/bin/orapki wallet add -wallet /u01/oracle/tns_admin -pwd "$WALLET_PWD" -trusted_cert -cert /u01/oracle/tns_admin/localCA.pem >/dev/null 2>&1 || true
  else
    podman exec "$PROXY_CONTAINER" orapki wallet add -wallet /opt/oracle/admin/FREE/wallet -pwd "$WALLET_PWD" -trusted_cert -cert /opt/oracle/admin/FREE/wallet/localCA.pem >/dev/null 2>&1 || true
  fi
  rm -f "$TNS_DIR/localCA.pem"
fi

echo -e "${CYAN}├─${NC} ${YELLOW}[$(msg_str "STEP_4_5_NAME") 4]: $(msg_str "SUB_WALLET_4")${NC}"
echo -e "${CYAN}│${NC}  📊 $(msg_str "BENCHMARK_LABEL") ${YELLOW}$(msg_str "BENCHMARK_EST" "1s")${NC}"

# Generate host tnsnames.ora dynamically for all active instances and profiles
cat << EOF > "$TNS_DIR/tnsnames.ora"
# TNS Names Configuration for Host (Auto-generated: $(date))
EOF

for inst in "${instances[@]}"; do
  IFS='|' read -r cname prof env_key <<< "$inst"
  [ -z "$cname" ] && continue
  pfx=$(echo "$cname" | sed 's/^db[-_]//' | tr '-' '_' | tr '[:lower:]' '[:upper:]')
  (
    load_db_profile "$prof" >/dev/null 2>&1 || true
    port=""
    if command -v podman >/dev/null 2>&1 && podman container exists "$cname" 2>/dev/null; then
      port=$(podman inspect "$cname" --format '{{(index (index .NetworkSettings.Ports "1521/tcp") 0).HostPort}}' 2>/dev/null || echo "")
    fi
    [ -z "$port" ] && port="${PROFILE_DB_PORT:-1532}"
    service="${PROFILE_DEFAULT_SERVICE:-FREEPDB1}"

    cat << EOF >> "$TNS_DIR/tnsnames.ora"

DB_${pfx}_SYS =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = ${port}))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ${service})
    )
  )

DB_${pfx}_DBA_ADMIN =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = ${port}))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ${service})
    )
  )

DB_${pfx}_SCHEMA =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = ${port}))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ${service})
    )
  )

DB_${pfx}_DEV =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = ${port}))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ${service})
    )
  )

DB_${pfx}_APP =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = ${port}))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ${service})
    )
  )

DB_${pfx}_VIEWER =
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

# Generate container tnsnames.ora dynamically
cat << EOF > "$CONTAINER_TNS_DIR/tnsnames.ora"
# TNS Names Configuration for Container (Auto-generated: $(date))
EOF

while IFS='|' read -r cname prof env_key; do
  [ -z "$cname" ] && continue
  pfx=$(echo "$cname" | sed 's/^db[-_]//' | tr '-' '_' | tr '[:lower:]' '[:upper:]')
  (
    load_db_profile "$prof" >/dev/null 2>&1 || true
    service="${PROFILE_DEFAULT_SERVICE:-FREEPDB1}"

    cat << EOF >> "$CONTAINER_TNS_DIR/tnsnames.ora"

DB_${pfx}_SYS =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = ${cname})(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ${service})
    )
  )

DB_${pfx}_DBA_ADMIN =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = ${cname})(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ${service})
    )
  )

DB_${pfx}_SCHEMA =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = ${cname})(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ${service})
    )
  )

DB_${pfx}_DEV =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = ${cname})(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ${service})
    )
  )

DB_${pfx}_APP =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = ${cname})(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ${service})
    )
  )

DB_${pfx}_VIEWER =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = ${cname})(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ${service})
    )
  )
EOF
  )
done < <(printf '%s\n' "${instances[@]}")


chmod 644 "$TNS_DIR"/ewallet.p12 "$TNS_DIR"/cwallet.sso "$TNS_DIR"/*.ora 2>/dev/null || true
chmod 644 "$CONTAINER_TNS_DIR"/* 2>/dev/null || true

# TNS fallback symlinks in user home directory for standalone SQLcl
ln -sf "$TNS_DIR/tnsnames.ora" "$HOME/tnsnames.ora" 2>/dev/null || true
ln -sf "$TNS_DIR/sqlnet.ora" "$HOME/sqlnet.ora" 2>/dev/null || true
ln -sf "$TNS_DIR/cwallet.sso" "$HOME/cwallet.sso" 2>/dev/null || true
ln -sf "$TNS_DIR/ewallet.p12" "$HOME/ewallet.p12" 2>/dev/null || true

# Maintain system-wide sql wrapper in user PATH directories
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

echo "❌ Error: SQLcl utility not found!"
exit 1
EOF
    chmod +x "$bin_dir/sql" 2>/dev/null || true
  fi
done

if command -v zip &>/dev/null; then
  (cd "$TNS_DIR" && zip -q -r "$WORKSPACE_DIR/config/oracle_db_wallet.zip" .) 2>/dev/null || true
fi


echo -e "${CYAN}│${NC}  $(msg_str "WALLET_FILES_CREATED" "${GREEN}$TNS_DIR${NC}")"
echo -e "${CYAN}│${NC}  $(msg_str "WALLET_ZIP_CREATED" "${GREEN}$WORKSPACE_DIR/config/oracle_db_wallet.zip${NC}")"
