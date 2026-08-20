#!/usr/bin/env bash
# ============================================================================
# Master End-to-End Environment Setup & Benchmark Script
# Measures container image pulls, ORDS & APEX downloads, container healthcheck,
# APEX engine installation, patch application, and exports complete benchmark metrics.
# ============================================================================

set -e

# Vaigistame podman compose hoiatusteate välise teenusepakkuja kohta
export PODMAN_COMPOSE_WARNING_LOGS=false
export MASTER_SETUP="true"

# Värvide seadistamine (ainult siis kui terminal seda toetab)
if [ -t 0 ] || { [ -n "$TERM" ] && [ "$TERM" != "dumb" ]; }; then
  GREEN='\033[1;32m'
  YELLOW='\033[0;33m'
  ORANGE='\033[38;5;208m'
  CYAN='\033[1;36m'
  RED='\033[1;31m'
  NC='\033[0m'
else
  GREEN=''
  YELLOW=''
  ORANGE=''
  CYAN=''
  RED=''
  NC=''
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
COMPOSE_FILE="$SCRIPT_DIR/../podman-compose.yml"
OVERRIDE_FILE="$SCRIPT_DIR/../podman-compose.override.yml"

# Parameetrite parsimine
FORCE=false
SKIP_PUBLISHER=false
SKIP_ORDS=false
SKIP_MONITOR_APP=false
SKIP_WEB_IDE=false
ORDS_SKIP_REASON=""

for arg in "$@"; do
  case $arg in
    -y|--force)
      FORCE=true
      ;;
    --no-publisher)
      SKIP_PUBLISHER=true
      ;;
    --no-ords)
      SKIP_ORDS=true
      ORDS_SKIP_REASON="Kasutaja ei soovi lokaalset ORDS teenust (käsurea võti --no-ords)"
      ;;
    --no-monitor-app)
      SKIP_MONITOR_APP=true
      ;;
    --no-web-ide)
      SKIP_WEB_IDE=true
      ;;
  esac
done


ENV_PATH="$SCRIPT_DIR/../.env"
[ ! -f "$ENV_PATH" ] && ENV_PATH=".env"

# Laeme keskkonnamuutujad ja profiilimootori
if [ -f "$ENV_PATH" ]; then
  set -a
  source "$ENV_PATH"
  set +a
fi

if [ -f "$SCRIPT_DIR/internal/load-profile.sh" ]; then
  source "$SCRIPT_DIR/internal/load-profile.sh"
  load_db_profile
  load_web_ide_profile
fi

if [ "$IS_ADB" = "true" ]; then
  export APEX_DB_SID="${APEX_DB_SID:-${PROFILE_DB_SID:-FREE}}"
  export APEX_DB_PDB="${APEX_DB_PDB:-${PROFILE_DB_PDB:-MYATP}}"
  export APEX_DB_CONTAINER_PORT="${APEX_DB_CONTAINER_PORT:-$PROFILE_CONTAINER_PORT}"
fi

generate_override_and_secrets() {
  # Kontrollime, kas vajalikud Podman saladused on registreeritud
  local SECRETS_EXIST=true
  if [ -f "$ENV_PATH" ]; then
    for secret in $(get_required_secret_names 2>/dev/null || echo "apex_db_sys_password publisher_db_sys_password apex_schema_password test_dev_password"); do
      if ! podman secret exists "$secret" 2>/dev/null; then
        SECRETS_EXIST=false
        break
      fi
    done
  else
    SECRETS_EXIST=false
  fi

  if [ "$SECRETS_EXIST" = "false" ]; then
    if [ -x "$SCRIPT_DIR/internal/generate-passwords.sh" ]; then
      "$SCRIPT_DIR/internal/generate-passwords.sh" --force
    fi
  fi

  # Genereerime dünaamiliselt podman-compose.override.yml profiili ja lisabaaside jaoks
  local PRIMARY_SERVICE_KEY
  PRIMARY_SERVICE_KEY=$(get_active_db_instances 2>/dev/null | head -n 1 | cut -d'|' -f1)
  PRIMARY_SERVICE_KEY="${PRIMARY_SERVICE_KEY:-db-dev-full}"

  rm -f "$OVERRIDE_FILE"
  echo "   ℹ️  Genereerin profiilipõhise podman-compose.override.yml..."
  cat <<EOF > "$OVERRIDE_FILE"
version: '3.8'

services:
EOF

  local active_instances=($(get_active_db_instances 2>/dev/null))
  for item in "${active_instances[@]}"; do
    IFS='|' read -r c_name prof key <<< "$item"
    db=$(echo "$c_name" | sed 's/^db-//' | tr '-' '_')
    (
      load_db_profile "$prof" >/dev/null 2>&1 || true

      PORT_VAR="${key}_PORT"
      c_port="${!PORT_VAR:-${PROFILE_DB_PORT:-1532}}"

      SERVICE_VAR="${key}_SERVICE"
      c_service="${!SERVICE_VAR:-${PROFILE_DEFAULT_SERVICE:-FREEPDB1}}"

      IMAGE_VAR="${key}_IMAGE"
      c_image="${!IMAGE_VAR:-${RESOLVED_DB_IMAGE:-container-registry.oracle.com/database/free:latest}}"

      c_sid="${PROFILE_DB_SID:-FREE}"
      c_in_port="${PROFILE_CONTAINER_PORT:-1521}"

      ORDS_PORT="${PROFILE_ORDS_HTTP_PORT:-8088}"
      ORDS_SSL="${PROFILE_ORDS_HTTPS_PORT:-8448}"
      ORDS_VER="${PROFILE_ORDS_VERSION:-latest}"

      sys_secret_name="apex_db_sys_password"
      if [ "$item" != "${active_instances[0]}" ]; then
        sys_secret_name="${db}_db_sys_password"
      fi

      cat <<EOF >> "$OVERRIDE_FILE"
  ${c_name}:
    image: ${c_image}
    container_name: ${c_name}
    hostname: ${c_name}
    shm_size: 2g
    ports:
      - "${c_port}:${c_in_port}"
EOF

      apex_ver_slug=$(echo "${PROFILE_APEX_VERSION:-24.1}" | tr '.' '_')
      apex_img_vol="apex_images_${apex_ver_slug}"

      if [ "$IS_ADB" = "true" ]; then
        adb_admin_pwd=$(podman secret inspect --showsecret "$sys_secret_name" 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || echo "")
        adb_wallet_pwd=$(podman secret inspect --showsecret apex_schema_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || echo "")

        cat <<EOF >> "$OVERRIDE_FILE"
    environment:
      - WORKLOAD_TYPE=${PROFILE_WORKLOAD_TYPE:-ATP}
      - ADMIN_PASSWORD=$adb_admin_pwd
      - WALLET_PASSWORD=$adb_wallet_pwd
    healthcheck:
      test:
        - CMD-SHELL
        - tnsping localhost:${PROFILE_CONTAINER_PORT:-1522} || curl -s -k -I https://localhost:${PROFILE_ORDS_HTTPS_PORT:-8443}/ords/ || exit 1
      interval: 15s
      timeout: 10s
      retries: 20
      start_period: 45s
EOF
        if [ -f "$SCRIPT_DIR/../config/certs/localhost.crt" ] && [ -f "$SCRIPT_DIR/../config/certs/localhost.key" ]; then
          cat <<EOF >> "$OVERRIDE_FILE"
    volumes:
      - ./config/certs/localhost.crt:/u01/ords/self-signed.crt:ro
      - ./config/certs/localhost.key:/u01/ords/self-signed.key:ro
EOF
        fi
      else
        cat <<EOF >> "$OVERRIDE_FILE"
    environment:
      - ORACLE_PASSWORD_FILE=/run/secrets/oracle_pwd
      - ORACLE_SID=${c_sid}
      - ORACLE_PDB=${c_service}
      - TNS_ADMIN=/opt/oracle/admin/${c_sid}/wallet
      - CONFIGURE_TDE=${CONFIGURE_TDE:-true}
      - ENCRYPT_TABLESPACES=${ENCRYPT_TABLESPACES:-ALL}
    volumes:
      - ${db}_oradata:/opt/oracle/oradata
      - ./config/tns_admin:/opt/oracle/admin/${c_sid}/wallet:rw
      - ${apex_img_vol}:/opt/oracle/apex_images
    secrets:
      - source: ${sys_secret_name}
        target: oracle_pwd
    deploy:
      resources:
        limits:
          cpus: '2.00'
          memory: ${PROFILE_DB_MEMORY:-3072M}
    healthcheck:
      test:
        - CMD-SHELL
        - (echo "SELECT 'ALIVE' FROM DUAL;" | sqlplus -L -S / as sysdba 2>/dev/null | grep -q 'ALIVE') || (echo "SELECT 'ALIVE' FROM DUAL;" | sqlplus -L -S sys/`cat /run/secrets/oracle_pwd 2>/dev/null`@localhost:1521/${c_service} as sysdba 2>/dev/null | grep -q 'ALIVE') || (nc -z localhost 1521 2>/dev/null) || exit 1
      interval: 10s
      timeout: 10s
      retries: 25
      start_period: 30s
    restart: unless-stopped

EOF
      fi

      if [ "$SKIP_ORDS" != "true" ] && [ "${PROFILE_ORDS_ENABLED:-true}" = "true" ]; then
        mkdir -p "$SCRIPT_DIR/../config/ords/$db"
        raw_svc_name="${PROFILE_ORDS_SERVICE_NAME:-ords-$db}"
        raw_c_name="${PROFILE_ORDS_CONTAINER_NAME:-oracle-ords-$db}"

        ords_svc_name=$(ensure_unique_name "$raw_svc_name" "ORDS teenus")
        ords_c_name=$(ensure_unique_name "$raw_c_name" "ORDS konteiner")
        ords_ssl_val="$ORDS_SSL"
        ords_http_val="$ORDS_PORT"
        if [ "$item" != "${active_instances[0]}" ]; then
          ords_ssl_val=$((ORDS_SSL + 10))
          ords_http_val=$((ORDS_PORT + 10))
        fi

        cat <<EOF >> "$OVERRIDE_FILE"
  ${ords_svc_name}:
    image: ${PROFILE_ORDS_CONTAINER_IMAGE:-container-registry.oracle.com/database/ords:latest}
    container_name: ${ords_c_name}
    ports:
      - "${ords_http_val}:8080"
      - "${ords_ssl_val}:8443"
    entrypoint:
      - /bin/bash
      - -c
      - |
        export ORACLE_PWD=\$\$(cat /run/secrets/oracle_pwd 2>/dev/null || cat /run/secrets/${sys_secret_name})
        export APEX_LISTENER_PWD=\$\$(cat /run/secrets/ords_listener_password 2>/dev/null || cat /run/secrets/apex_schema_password)
        export APEX_REST_PWD=\$\$(cat /run/secrets/ords_listener_password 2>/dev/null || cat /run/secrets/apex_schema_password)
        mkdir -p /etc/ords/config/ssl
        [ -f /etc/ords/certs/localhost.crt ] && cp /etc/ords/certs/localhost.crt /etc/ords/config/ssl/cert.crt 2>/dev/null || true
        [ -f /etc/ords/certs/localhost.key ] && cp /etc/ords/certs/localhost.key /etc/ords/config/ssl/key.key 2>/dev/null || true
        ords --config /etc/ords/config config set standalone.static.path /opt/oracle/apex_images/images 2>/dev/null || true
        exec /usr/bin/docker-entrypoint.sh
    environment:
      - DBHOST=${c_name}
      - DBPORT=${c_in_port}
      - DBSERVICENAME=${c_service}
    secrets:
      - source: ${sys_secret_name}
        target: oracle_pwd
      - ords_listener_password
    depends_on:
      ${c_name}:
        condition: service_healthy
    deploy:
      resources:
        limits:
          cpus: '1.00'
          memory: ${PROFILE_ORDS_MEMORY:-1024M}
    volumes:
      - ${apex_img_vol}:/opt/oracle/apex_images:ro
      - ./config/ords/$db:/etc/ords/config:rw
      - ./config/certs:/etc/ords/certs:ro
    restart: unless-stopped

EOF
      fi
    )
  done

  local has_override_volumes=false
  for item in "${active_instances[@]}"; do
    c_name=$(echo "$item" | cut -d'|' -f1)
    prof=$(echo "$item" | cut -d'|' -f2)
    db=$(echo "$c_name" | sed 's/^db-//' | tr '-' '_')
    load_db_profile "$prof" >/dev/null 2>&1 || true
    apex_ver_slug=$(echo "${PROFILE_APEX_VERSION:-24.1}" | tr '.' '_')
    if [ "$has_override_volumes" = "false" ]; then
      echo -e "\nvolumes:" >> "$OVERRIDE_FILE"
      has_override_volumes=true
    fi
    if ! grep -q "  ${db}_oradata:" "$OVERRIDE_FILE" 2>/dev/null; then
      echo "  ${db}_oradata:" >> "$OVERRIDE_FILE"
    fi
    if ! grep -q "  apex_images_${apex_ver_slug}:" "$OVERRIDE_FILE" 2>/dev/null; then
      echo "  apex_images_${apex_ver_slug}:" >> "$OVERRIDE_FILE"
    fi
  done

  cat <<EOF >> "$OVERRIDE_FILE"

secrets:
EOF
  for item in "${active_instances[@]}"; do
    c_name=$(echo "$item" | cut -d'|' -f1)
    db=$(echo "$c_name" | sed 's/^db-//' | tr '-' '_')
    if [ "$item" != "${active_instances[0]}" ]; then
      cat <<EOF >> "$OVERRIDE_FILE"
  ${db}_db_sys_password:
    external: true
EOF
    fi
  done

  cat <<EOF >> "$OVERRIDE_FILE"
  apex_db_sys_password:
    external: true
  ords_listener_password:
    external: true
EOF

  COMPOSE_ARGS=(-f "$COMPOSE_FILE")
  [ -f "$OVERRIDE_FILE" ] && COMPOSE_ARGS+=(-f "$OVERRIDE_FILE")
}

# Konfigureerime COMPOSE argumendid
COMPOSE_ARGS=(-f "$COMPOSE_FILE")
[ -f "$OVERRIDE_FILE" ] && COMPOSE_ARGS+=(-f "$OVERRIDE_FILE")

# Seadistame TNS_ADMIN kataloogi tee (Oracle Wallet)
export TNS_ADMIN="$SCRIPT_DIR/../config/tns_admin"

# Parameetrite parsimine ja IS_ADB tuvastamine on sooritatud skripti alguses.

# Dynamically evaluate active DB profiles to check if components.publisher.enabled=true
ANY_PUB_ENABLED=false
for inst in $(get_active_db_instances 2>/dev/null); do
  pname=$(echo "$inst" | cut -d'|' -f2)
  pfile="$SCRIPT_DIR/../config/profiles/databases/${pname}.yaml"
  [ ! -f "$pfile" ] && pfile="$SCRIPT_DIR/../config/profiles/${pname}.yaml"
  if [ -f "$pfile" ]; then
    pub_en=$(awk '/publisher:/{flag=1;next}/ords:|apex:|sqlcl:|users:/{flag=0}flag' "$pfile" | grep -E '^[[:space:]]*enabled:' | head -n 1 | sed -E 's/.*:[[:space:]]*"?([^"]+)"?/\1/' | tr -d '\r\n')
    if [ "$pub_en" = "true" ]; then
      ANY_PUB_ENABLED=true
      break
    fi
  fi
done

if [ "$ANY_PUB_ENABLED" = "true" ] || [ "${PUBLISHER_ENABLED:-false}" = "true" ]; then
  if [ "$SKIP_PUBLISHER" != "true" ]; then
    SKIP_PUBLISHER=false
    PUBLISHER_DB_HOST="${PUBLISHER_DB_HOST:-pub-db}"
  fi
else
  SKIP_PUBLISHER=true
fi

ORDS_URL="${ORDS_URL:-${PROFILE_ORDS_DOWNLOAD_URL:-https://download.oracle.com/otn_software/java/ords/ords-latest.zip}}"
ORDS_HTTP_PORT="${ORDS_HTTP_PORT:-${PROFILE_ORDS_HTTP_PORT:-8088}}"
ORDS_HTTPS_PORT="${ORDS_HTTPS_PORT:-${PROFILE_ORDS_HTTPS_PORT:-8448}}"

if [ "${PROFILE_ORDS_ENABLED}" = "false" ]; then
  SKIP_ORDS=true
  [ -z "$ORDS_SKIP_REASON" ] && ORDS_SKIP_REASON="Profiili YAML failis on ORDS välja lülitatud (components.ords.enabled=false)"
fi

if [ "$IS_ADB" = "true" ]; then
  [ -z "$ORDS_SKIP_REASON" ] && ORDS_SKIP_REASON="Kasutatakse Oracle ADB-d (Autonomous Database), mis sisaldab sisseehitatud ORDS-i"
elif [ "$IS_LOCAL" = "false" ]; then
  [ -z "$ORDS_SKIP_REASON" ] && ORDS_SKIP_REASON="Tegemist on kaugserveriga (Remote Database)"
fi

START_LOCAL_PUBLISHER=true
if [ "$SKIP_PUBLISHER" = "true" ]; then
  START_LOCAL_PUBLISHER=false
fi


DB_HOST="${APEX_DB_HOST:-localhost}"
DB_PORT="${APEX_DB_PORT:-${PROFILE_DB_PORT:-1532}}"
DB_SERVICE="${APEX_DB_SERVICE:-${PROFILE_DEFAULT_SERVICE:-FREEPDB1}}"

echo -e "${CYAN}==================================================================${NC}"
echo -e "${CYAN}🚀 Oracle Free DB & APEX Full Automated Setup${NC}"
echo -e "${YELLOW}🎯 TARGET CONFIGURATIONS (Aktiivsed Profiilid ja Sihtseadistused):${NC}"
get_active_db_instances | while IFS='|' read -r container prof env_key; do
  [ -z "$container" ] && continue
  (
    load_db_profile "$prof" >/dev/null 2>&1 || true
    p_port="${PROFILE_DB_PORT:-1532}"
    p_service="${PROFILE_DEFAULT_SERVICE:-FREEPDB1}"
    ords_h_port="${ORDS_HTTP_PORT:-${PROFILE_ORDS_HTTP_PORT:-8088}}"
    ords_s_port="${ORDS_HTTPS_PORT:-${PROFILE_ORDS_HTTPS_PORT:-8448}}"
    ords_c_name="${PROFILE_ORDS_CONTAINER_NAME:-oracle-ords-${container#db-}}"
    ords_s_name="${PROFILE_ORDS_SERVICE_NAME:-ords-${container#db-}}"
    if [ "$IS_ADB" = "true" ]; then
      echo -e "   - ${CYAN}${container}${NC} (Profiil: ${YELLOW}${prof}${NC})"
      echo -e "     ├─ Andmebaas: ${CYAN}localhost:${p_port}/${p_service}${NC}"
      echo -e "     └─ Veebiliides (mTLS/HTTPS): ${CYAN}https://localhost:${ords_s_port}/ords/${NC}"
    else
      echo -e "   - ${CYAN}${container}${NC} (Profiil: ${YELLOW}${prof}${NC})"
      echo -e "     └─ Andmebaas: ${CYAN}localhost:${p_port}/${p_service}${NC}"
      if [ "$SKIP_ORDS" = "false" ] && [ "${PROFILE_ORDS_ENABLED:-true}" = "true" ]; then
        echo -e "   - ${CYAN}${ords_c_name}${NC} (ORDS Teenus: ${YELLOW}${ords_s_name}${NC})"
        echo -e "     ├─ Sihtbaas: ${CYAN}${container}${NC} (${p_service})"
        echo -e "     └─ ORDS HTTP / SSL: ${CYAN}localhost:${ords_h_port}${NC} / SSL:${CYAN}${ords_s_port}${NC}"
      fi
    fi
  )
done

load_web_ide_profile >/dev/null 2>&1 || true
if [ "$SKIP_WEB_IDE" = "false" ] && [ "${WEB_IDE_ENABLED:-false}" = "true" ]; then
  echo -e "   - ${CYAN}${WEB_IDE_CONTAINER_NAME:-web-ide-dev}${NC} (Web IDE Profiil: ${YELLOW}${WEB_IDE_PROFILE:-web-ide-standard}${NC})"
  echo -e "     ├─ Brauseri liides (HTTP): ${CYAN}http://localhost:${WEB_IDE_HTTP_PORT:-8090}${NC}"
  echo -e "     └─ Turvatud liides (HTTPS): ${CYAN}https://localhost:${WEB_IDE_HTTPS_PORT:-8449}${NC}"
fi
if [ "$SKIP_PUBLISHER" = "false" ] && { [ "$ANY_PUB_ENABLED" = "true" ] || [ "${PUBLISHER_ENABLED:-false}" = "true" ]; }; then
  echo -e "   - ${CYAN}${PUBLISHER_CONTAINER_NAME:-oracle-publisher-dev}${NC} (Analytics Publisher & Fusion Middleware)"
  echo -e "     ├─ Sihtbaas: ${CYAN}${PUBLISHER_DB_HOST:-pub-db}${NC} (${PUBLISHER_DB_SERVICE:-FREEPDB1})"
  echo -e "     ├─ Veebiliides (HTTP): ${CYAN}http://localhost:${PUBLISHER_HTTP_PORT:-9502}/xmlpserver${NC}"
  echo -e "     └─ Turvatud liides (HTTPS): ${CYAN}https://localhost:${PUBLISHER_HTTPS_PORT:-9503}/xmlpserver${NC}"
fi

echo -e "${CYAN}==================================================================${NC}"
echo -e "${YELLOW}💡 Seadistuse muutmine:${NC}"
echo -e "   - Lokaalne seadistus: [.env](file://${SCRIPT_DIR}/../.env) (loo koopia failist [.env.example](file://${SCRIPT_DIR}/../.env.example))"
echo -e "${CYAN}==================================================================${NC}"

# Git-is jälgitav mõõdikute kataloog ja bazi funktsioonid
METRICS_DIR="$SCRIPT_DIR/../metrics"

format_duration() {
  local SECS=$1
  local MINS=$((SECS / 60))
  local REM_SECS=$((SECS % 60))
  if [ $MINS -gt 0 ]; then
    echo "${MINS}m ${REM_SECS}s"
  else
    echo "${REM_SECS}s"
  fi
}

print_progress() {
  echo -ne "$@"
}
export -f print_progress

download_file() {
  local url="$1"
  local dest="$2"
  
  mkdir -p "$(dirname "$dest")"
  
  if grep -qi microsoft /proc/version 2>/dev/null && command -v powershell.exe &>/dev/null; then
    echo "WSL2 tuvastatud. Kasutan faili allalaadimiseks Windowsi PowerShelli (korporatiivse VPN/Proxy läbimiseks)..."
    local win_dest=$(wslpath -w "$dest" 2>/dev/null || echo "$dest")
    
    if powershell.exe -NoProfile -Command "Invoke-WebRequest -Uri '$url' -OutFile '$win_dest' -UseBasicParsing" &>/dev/null; then
      echo "✅ Allalaadimine õnnestus PowerShelliga (otseühendus)."
      return 0
    fi
    
    if powershell.exe -NoProfile -Command "Invoke-WebRequest -Uri '$url' -OutFile '$win_dest' -UseBasicParsing -ProxyUseDefaultCredentials" &>/dev/null; then
      echo "✅ Allalaadimine õnnestus PowerShelliga (süsteemi proxy auth)."
      return 0
    fi
    echo "PowerShell allalaadimine ebaõnnestus, proovin kohalikku curl-i..."
  fi
  
  curl -L -o "$dest" "$url"
}

get_total_setup_stats() {
  local values=()
  if [ -d "$METRICS_DIR" ]; then
    for f in "$METRICS_DIR"/setup_benchmarks_*.json; do
      if [ -f "$f" ]; then
        local val=$(grep -m1 '"total_duration_seconds":' "$f" | awk -F: '{print $2}' | tr -d ' ,"\r\n' || echo "")
        if [[ "$val" =~ ^[0-9]+$ ]]; then
          values+=($val)
        fi
      fi
    done
  fi
  local count=${#values[@]}
  if [ $count -eq 0 ]; then
    echo "~15 minutit (kui pilte tõmmatakse esimest korda)"
    return 0
  fi
  local sum=0
  local min=${values[0]}
  local max=${values[0]}
  for val in "${values[@]}"; do
    sum=$((sum + val))
    if [ $val -lt $min ]; then
      min=$val
    fi
    if [ $val -gt $max ]; then
      max=$val
    fi
  done
  local avg=$((sum / count))
  echo "keskmiselt $(format_duration $avg) (min: $(format_duration $min), max: $(format_duration $max))"
}

# FORCE is already parsed in the argument loop above

# Kettaruumi kontroll stabiilsuse tagamiseks (min 15GB)
if [ "$FORCE" = "false" ] && command -v podman &> /dev/null; then
  AVAIL_GB=""
  if podman machine list &>/dev/null; then
    # macOS/Windows Podman VM
    AVAIL_GB=$(podman machine ssh df -BG /sysroot 2>/dev/null | tail -1 | awk '{print $4}' | tr -d 'G')
  else
    # Linux host
    AVAIL_GB=$(df -BG "$SCRIPT_DIR" 2>/dev/null | tail -1 | awk '{print $4}' | tr -d 'G')
  fi

  if [ -n "$AVAIL_GB" ] && [[ "$AVAIL_GB" =~ ^[0-9]+$ ]]; then
    if [ "$AVAIL_GB" -lt 15 ]; then
      echo -e "${CYAN}==================================================================${NC}"
      echo -e "${RED}⚠️  HOIATUS: Süsteemis on vähe vaba kettaruumi (ainult ${AVAIL_GB}GB vaba)!${NC}"
      echo "   Oracle andmebaaside ja ORDS-i paigaldus vajab stabiilsuse tagamiseks vähemalt 15GB."
      echo "   Kettaruumi vabastamiseks võid käivitada: ./scripts/reset-all.sh --system"
      echo -e "${CYAN}==================================================================${NC}"
      read -p "$(echo -e "${YELLOW}❓ Kas soovid riskida ja jätkata paigaldust? (y/N): ${NC}")" RISK_CONFIRM
      if [[ ! "$RISK_CONFIRM" =~ ^[Yy]$ ]]; then
        echo -e "${RED}❌ Paigaldus katkestatud madala kettaruumi tõttu.${NC}"
        exit 1
      fi
    fi
  fi
fi

# Kontrollime ja häälestame Podman VM swap mälu, et ennetada andmebaasi krahhe (OOM killer)
if [ "$IS_LOCAL" = "true" ] && command -v podman &>/dev/null; then
  if podman machine list 2>/dev/null | grep -q -E "AppleHV|WSL|hyperv|qemu"; then
    SWAP_TOTAL=$(podman machine ssh free 2>/dev/null | grep -i swap | awk '{print $2}' || echo "0")
    if [ "$SWAP_TOTAL" = "0B" ] || [ "$SWAP_TOTAL" = "0" ]; then
      echo -e "${YELLOW}⚠️  HOIATUS: Podman VM-il puudub swap mälu (võib põhjustada andmebaasi OOM krahhe APEX installil).${NC}"
      echo "   Aktiveerin stabiilsuse tagamiseks ajutiselt 2GB swap faili..."
      podman machine ssh "sudo dd if=/dev/zero of=/var/swapfile bs=1M count=2048 && sudo chmod 600 /var/swapfile && sudo mkswap /var/swapfile && sudo swapon /var/swapfile" >/dev/null 2>&1 || true
    fi
  fi
fi
# Otsime SQLcl-i VS Code SQL Developer laiendusest või süsteemist
VSCODE_SQLCL=$(find "$HOME/.vscode/extensions" -name "sql" -path "*/oracle.sql-developer-*/dbtools/sqlcl/bin/sql" 2>/dev/null | head -n 1)

SQLCL_BIN=""
if [ -n "$VSCODE_SQLCL" ] && [ -x "$VSCODE_SQLCL" ]; then
  SQLCL_BIN="$VSCODE_SQLCL"
elif command -v sql &> /dev/null; then
  SQLCL_BIN="sql"
fi

if [ -z "$SQLCL_BIN" ]; then
  RUN_IMAGE="${SQLCL_CONTAINER_IMAGE:-container-registry.oracle.com/database/sqlcl:latest}"
  echo "=================================================================="
  echo "ℹ️  INFO: Ei leidnud kohalikku SQLcl tööriista."
  echo "   Kõik andmebaasi skeemide (Liquibase) ja rakenduste paigaldused"
  echo "   käivitatakse automaatselt läbi SQLcl konteineri."
  echo "   Konteineri pilt: $RUN_IMAGE"
  echo "=================================================================="
else
  export SQLCL_BIN
fi

# Lipuke, et kontrollida kohaliku SQLcl toimivust vaid üks kord
SQLCL_CHECKED=false

# Defineerime run_sqlcl abifunktsiooni
run_sqlcl() {
  if [ -n "$SQLCL_BIN" ] && [ "$SQLCL_CHECKED" = "false" ]; then
    SQLCL_CHECKED=true
    local TEST_CONN=""
    for arg in "$@"; do
      if [[ "$arg" == /@* ]] || [[ "$arg" == sys/* ]] || [[ "$arg" == admin/* ]]; then
        TEST_CONN="$arg"
        break
      fi
    done
    TEST_CONN="${TEST_CONN:-/@DB_APEX_PROXY_SCHEMA}"
    if ! echo "exit;" | "$SQLCL_BIN" -s $TEST_CONN >/dev/null 2>&1; then
      echo "==================================================================" >&2
      echo "⚠️  HOIATUS: Kohalik SQLcl ($SQLCL_BIN) ei suutnud ühenduda." >&2
      echo "   Lülitun automaatselt ümber turvalise SQLcl konteineri fallbackile." >&2
      echo "==================================================================" >&2
      SQLCL_BIN=""
    fi
  fi

  if [ -n "$SQLCL_BIN" ]; then
    # Lokaalne käivitus host-süsteemist
    "$SQLCL_BIN" "$@"
  else
    # Konteiner-põhine fallback
    local RUN_IMAGE="${SQLCL_CONTAINER_IMAGE:-container-registry.oracle.com/database/sqlcl:latest}"
    local project_root="$(cd "$SCRIPT_DIR/.." && pwd)"
    [ -d "$WORKSPACE_DIR" ] && project_root="$WORKSPACE_DIR"
    
    podman run --rm -i --network="${PROJECT_NAME}_default" \
      -v "${project_root}:/workspace" \
      -v "${project_root}/config/tns_admin_container:/tns:ro" \
      -e JAVA_TOOL_OPTIONS="-Doracle.net.tns_admin=/tns -Doracle.net.wallet_location=(SOURCE=(METHOD=FILE)(METHOD_DATA=(DIRECTORY=/tns)))" \
      -e TNS_ADMIN=/tns \
      -w /workspace "$RUN_IMAGE" "$@"
  fi
}
export -f run_sqlcl



if [ "$FORCE" = "false" ]; then
  echo -e "📊 Eeldatav kogu paigalduse ajakulu: ${YELLOW}$(get_total_setup_stats)${NC}"
  read -p "$(echo -e "${YELLOW}❓ Kas soovid jätkata paigaldust nende seadistustega? (y/N): ${NC}")" CONFIRM
  if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo -e "${RED}❌ Paigaldus tühistatud kasutaja poolt.${NC}"
    exit 0
  fi
fi

# Genereerime vajalikud Podman saladused ja override faili AINULT pärast kinnituse saamist
generate_override_and_secrets

# 1. Logifaili seadistus (lokaalne, ei lähe Git-i)
LOG_DIR="$SCRIPT_DIR/../install_logs"
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$LOG_DIR/setup_all_${TIMESTAMP}.log"
exec > >(tee -a "$LOG_FILE") 2>&1

# 2. Git-is jälgitav mõõdikute kataloog
mkdir -p "$METRICS_DIR"
JSON_BENCHMARK="$METRICS_DIR/setup_benchmarks.json"
ENV_BENCHMARK="$METRICS_DIR/setup_benchmarks.env"

START_MASTER_TOTAL=$(date +%s)

get_step_stats() {
  local step_key="$1"
  local default_est="$2"
  local file_pattern="${3:-setup_benchmarks_*.json}"
  local values=()
  if [ -d "$METRICS_DIR" ]; then
    for f in "$METRICS_DIR"/$file_pattern; do
      if [ -f "$f" ]; then
        local val=$(grep -m1 "\"$step_key\":" "$f" | awk -F: '{print $2}' | tr -d ' ,"\r\n' || echo "")
        if [[ "$val" =~ ^[0-9]+$ ]]; then
          values+=($val)
        fi
      fi
    done
  fi
  local count=${#values[@]}
  if [ $count -eq 0 ]; then
    echo "ootusaeg ~${default_est}"
    return 0
  fi
  local sum=0
  local min=${values[0]}
  local max=${values[0]}
  for val in "${values[@]}"; do
    sum=$((sum + val))
    if [ $val -lt $min ]; then
      min=$val
    fi
    if [ $val -gt $max ]; then
      max=$val
    fi
  done
  local avg=$((sum / count))
  echo "keskmine: $(format_duration $avg) (min: $(format_duration $min), max: $(format_duration $max))"
}

print_header() {
  local step_num="$1"
  local title="$2"
  local step_key="$3"
  local default_est="$4"
  local file_pattern="$5"
  echo -e "${CYAN}==================================================================${NC}"
  echo -e "${YELLOW}${step_num}. ${title}${NC}"
  if [ -n "$step_key" ]; then
    echo -e "   📊 Ajalooline ooteaeg: ${YELLOW}$(get_step_stats "$step_key" "$default_est" "$file_pattern")${NC}"
  fi
  echo -e "${CYAN}==================================================================${NC}"
}

echo "=================================================================="
echo "🚀 Oracle Free DB & APEX Full Automated Setup"
echo "------------------------------------------------------------------"
echo "📝 Lokaalne logi: $LOG_FILE"
echo "📊 Git mõõdikud:  $JSON_BENCHMARK"
echo "=================================================================="

IS_LOCAL=true
if [ "$DB_HOST" != "localhost" ] && [ "$DB_HOST" != "127.0.0.1" ] && [ "$DB_HOST" != "db-apex-proxy" ]; then
  IS_LOCAL=false
fi

# ----------------------------------------------------------------------------
# SAMM 1: Konteinerite piltide allalaadimine (Container Images Pull)
# ----------------------------------------------------------------------------
PULL_START=$(date +%s)
if [ "$IS_LOCAL" = "true" ]; then
  print_header "1" "Checking / Pulling Container Images (${PROFILE_NAME:-Oracle DB & ORDS})..." "step1_container_images_pull_seconds" "1m"
  if [ "$SKIP_ORDS" = "true" ]; then
    podman-compose "${COMPOSE_ARGS[@]}" pull >/dev/null 2>&1 &
  else
    ords_prof_name="${PROFILE_ORDS_SERVICE_NAME:-dev-ords}"
    ( podman-compose "${COMPOSE_ARGS[@]}" --profile "$ords_prof_name" pull >/dev/null 2>&1 || podman-compose "${COMPOSE_ARGS[@]}" pull >/dev/null 2>&1 ) &
  fi
  PULL_PID=$!

  ELAPSED=0
  while kill -0 $PULL_PID 2>/dev/null; do
    sleep 3
    ELAPSED=$((ELAPSED + 3))
    print_progress "   Laadin pilte... kestus: ${ORANGE}$(format_duration $ELAPSED)${NC}\r"
  done
  wait $PULL_PID || true
  echo ""

  PULL_SECS=$(( $(date +%s) - PULL_START ))
  PULL_TIME=$(format_duration $PULL_SECS)
  echo -e "⏱  [Samm 1 valmis (Konteinerite piltide allalaadimine/kontroll): ${YELLOW}$PULL_TIME${NC}]"
else
  echo "=================================================================="
  echo "1. Kaug-andmebaas tuvastatud. Jätan konteinerite piltide pullimise vahele."
  echo "=================================================================="
  PULL_SECS=0
  PULL_TIME="vahele jäetud"
fi

# ----------------------------------------------------------------------------
# SAMM 2: ORDS tarkvarapaketi allalaadimine (ORDS Download)
# ----------------------------------------------------------------------------
ORDS_DL_START=$(date +%s)
if [ "$SKIP_ORDS" = "true" ]; then
  print_header "2" "ORDS tarkvarapaketi allalaadimine"
  echo -e "   ℹ️  Eraldi lokaalset ORDS konteinerit ei vajata. (Põhjus: ${CYAN}${ORDS_SKIP_REASON:-välja lülitatud}${NC})"
  echo "   Jätan ORDS tarkvarapaketi allalaadimise vahele."
  ORDS_DL_SECS=0
  ORDS_DL_TIME="vahele jäetud"
else
  print_header "2" "Checking / Downloading ORDS Software Package..." "step2_ords_download_seconds" "10s"
  ORDS_URL="${ORDS_URL:-${PROFILE_ORDS_DOWNLOAD_URL:-https://download.oracle.com/otn_software/java/ords/ords-latest.zip}}"
  ORDS_BIN_DIR="$SCRIPT_DIR/../binaries/ords"
  mkdir -p "$ORDS_BIN_DIR"

  EXISTING_ORDS_ZIP=$(ls -1 "$ORDS_BIN_DIR"/*.zip 2>/dev/null | head -n 1 || echo "")
  if [ -n "$EXISTING_ORDS_ZIP" ]; then
    echo "   ✅ Leitud olemasolev ORDS tarkvarapakett kaustast binaries/ords/ ($(basename "$EXISTING_ORDS_ZIP"))."
  else
    ZIP_NAME=$(basename "$ORDS_URL")
    [ -z "$ZIP_NAME" ] && ZIP_NAME="ords-latest.zip"
    TARGET_ORDS_ZIP="$ORDS_BIN_DIR/$ZIP_NAME"
    echo "   ℹ️  ORDS paketti kaustas binaries/ords/ ei leitud. Laadin alla URL-ilt: $ORDS_URL"
    download_file "$ORDS_URL" "$TARGET_ORDS_ZIP"
  fi
  ORDS_DL_SECS=$(( $(date +%s) - ORDS_DL_START ))
  ORDS_DL_TIME=$(format_duration $ORDS_DL_SECS)
  echo -e "⏱  [Samm 2 valmis (ORDS allalaadimine): ${YELLOW}$ORDS_DL_TIME${NC}]"
fi

# ----------------------------------------------------------------------------
# SAMM 3: APEX tarkvarapaketi allalaadimine ja lahtipakkimine (APEX Download)
# ----------------------------------------------------------------------------
APEX_DL_START=$(date +%s)
print_header "3" "Checking / Downloading APEX Software Packages..." "step3_apex_download_unzip_seconds" "30s"

# Kogume kokku kõik aktiivsed APEX versioonid, mida andmebaasid vajavad
APEX_VERSIONS=()
for inst in $(get_active_db_instances 2>/dev/null); do
  container=$(echo "$inst" | cut -d'|' -f1)
  prof=$(echo "$inst" | cut -d'|' -f2)
  [ -z "$container" ] && continue
  ver=$(
    load_db_profile "$prof" >/dev/null 2>&1 || true
    if [ "${PROFILE_APEX_ENABLED:-true}" = "true" ] && [ "${PROFILE_APEX_VERSION:-NONE}" != "NONE" ] && [ -n "$PROFILE_APEX_VERSION" ]; then
      echo "$PROFILE_APEX_VERSION"
    fi
  )
  [ -n "$ver" ] && APEX_VERSIONS+=("$ver")
done

# Eemaldame duplikaadid
UNIQUE_APEX_VERSIONS=($(echo "${APEX_VERSIONS[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

mkdir -p "$SCRIPT_DIR/../binaries"

for ver in "${UNIQUE_APEX_VERSIONS[@]}"; do
  # Tuvastame allalaadimise URL-i vastavalt versioonile / profiilile
  URL_VAR="APEX_$(echo "$ver" | tr '.' '_')_URL"
  VER_URL="${!URL_VAR:-${RESOLVED_APEX_URL}}"
  ZIP_NAME=$(basename "$VER_URL")
  ZIP_PATH="$SCRIPT_DIR/../binaries/$ZIP_NAME"

  echo "   Checking APEX version $ver ($ZIP_NAME)..."
  if [ ! -f "$ZIP_PATH" ]; then
    download_file "$VER_URL" "$ZIP_PATH"
  fi

  # Pakime alati lahti host-masinasse versioonikausta
  TARGET_DIR="$SCRIPT_DIR/../db-install/apex_$ver"
  NEED_UNZIP=false
  if [ ! -d "$TARGET_DIR/apex" ] || [ ! -f "$TARGET_DIR/.unzipped_source" ] || [ "$(cat "$TARGET_DIR/.unzipped_source" 2>/dev/null)" != "$ZIP_NAME" ]; then
    NEED_UNZIP=true
  fi

  if [ "$NEED_UNZIP" = "true" ]; then
    rm -rf "$TARGET_DIR"
    mkdir -p "$TARGET_DIR"
    unzip -o -q "$ZIP_PATH" -d "$TARGET_DIR"
    echo "$ZIP_NAME" > "$TARGET_DIR/.unzipped_source"
  fi
done

APEX_DL_SECS=$(( $(date +%s) - APEX_DL_START ))
APEX_DL_TIME=$(format_duration $APEX_DL_SECS)
echo -e "⏱  [Samm 3 valmis (APEX allalaadimine & lahtipakkimine): ${YELLOW}$APEX_DL_TIME${NC}]"

# ----------------------------------------------------------------------------
# SAMM 4: Konteinerite käivitamine ja andmebaaside tervisekontroll (Healthcheck)
# ----------------------------------------------------------------------------
STEP4_START=$(date +%s)
if [ "$IS_LOCAL" = "true" ]; then
  # Initsialiseerime tns_admin kataloogi, et konteiner saaks selle mountida
  mkdir -p "$SCRIPT_DIR/../config/tns_admin"

  # Saladused on juba initsialiseeritud ja registreeritud Podman daemoni tasemel (generate-passwords.sh utiliidiga)
  echo -e "${YELLOW}🔑 Kontrollin Podman Secrets registreeringut...${NC}"

  print_header "4" "Käivitan konteinerid ja ootan andmebaaside valmisolekut (Healthcheck)..." "step4_container_startup_seconds" "45s"
  UP_SERVICES=()
  CONTAINERS_TO_CHECK=()
  for inst in $(get_active_db_instances 2>/dev/null); do
    cname=$(echo "$inst" | cut -d'|' -f1)
    [ -z "$cname" ] && continue
    CONTAINERS_TO_CHECK+=("$cname")
    sname="${cname#oracle-}"
    UP_SERVICES+=("$sname")
  done
  
  LOCAL_COMPOSE_ARGS=("${COMPOSE_ARGS[@]}")
  load_web_ide_profile >/dev/null 2>&1 || true
  if [ "$SKIP_WEB_IDE" = "false" ] && [ "${WEB_IDE_ENABLED:-false}" = "true" ]; then
    LOCAL_COMPOSE_ARGS+=(--profile web-ide)
  fi

  podman-compose "${LOCAL_COMPOSE_ARGS[@]}" up -d >> "$LOG_FILE" 2>&1 &

  COMPOSE_PID=$!

  MAX_WAIT=450
  if [ "$IS_ADB" = "true" ]; then
    MAX_WAIT=2400
  fi
  WAIT_COUNT=0
  while kill -0 $COMPOSE_PID 2>/dev/null; do
    sleep 3
    WAIT_COUNT=$((WAIT_COUNT + 3))
    print_progress "   Käivitan konteinereid... ${ORANGE}$(format_duration $WAIT_COUNT)${NC}\r"
  done
  echo ""

  echo -e "${YELLOW}⌛ Ootan kuni kõik andmebaasid on terved (healthy)...${NC}"
  for container in "${CONTAINERS_TO_CHECK[@]}"; do
    WAIT_COUNT=0
    while [ "$(podman inspect --format='{{.State.Status}}' "$container" 2>/dev/null)" != "running" ] || \
          [ "$(podman inspect --format='{{.State.Health.Status}}' "$container" 2>/dev/null)" != "healthy" ] || \
          { [ "$IS_ADB" = "true" ] && [[ "$container" == *"proxy"* ]] && ! podman exec "$container" sh -c "ls /u01/container_state/.installed_ords" &>/dev/null; } || \
          { { [ "$IS_ADB" = "false" ] || [[ "$container" != *"proxy"* ]]; } && ! echo -e "SHOW PDBS;\nexit;" | podman exec -i "$container" sqlplus -S / as sysdba 2>/dev/null | grep -q "READ WRITE"; }; do
      sleep 7
      WAIT_COUNT=$((WAIT_COUNT + 7))
      print_progress "   Ootan konteinerit ${CYAN}$container${NC}... ${ORANGE}$(format_duration $WAIT_COUNT)${NC}\r"
      if [ $WAIT_COUNT -ge $MAX_WAIT ]; then
        echo ""
        echo "❌ Viga: Konteiner $container ei saavutanud 'healthy' olekut $MAX_WAIT sekundi jooksul!"
        exit 1
      fi
    done
    echo -e "\n   ✅ Konteiner ${GREEN}$container${NC} on TERVE!"
  done

  if [ "$SKIP_ORDS" = "false" ] && [ "$IS_ADB" = "false" ]; then
    get_active_db_instances | while IFS='|' read -r cname prof env_key; do
      [ -z "$cname" ] && continue
      (
        load_db_profile "$prof" >/dev/null 2>&1 || true
        if [ "${PROFILE_ORDS_ENABLED:-true}" = "true" ]; then
          ords_c_name="${PROFILE_ORDS_CONTAINER_NAME:-oracle-ords-${cname#db-}}"
          ords_s_name="${PROFILE_ORDS_SERVICE_NAME:-ords-${cname#db-}}"
          if [ "$(podman inspect --format='{{.State.Status}}' "$ords_c_name" 2>/dev/null)" != "running" ]; then
            podman start "$ords_c_name" >/dev/null 2>&1 || podman-compose "${LOCAL_COMPOSE_ARGS[@]}" up -d "$ords_s_name" >/dev/null 2>&1 || true
          fi
          WAIT_COUNT=0
          while [ "$(podman inspect --format='{{.State.Status}}' "$ords_c_name" 2>/dev/null)" != "running" ]; do
            sleep 2
            WAIT_COUNT=$((WAIT_COUNT + 2))
            print_progress "   Ootan ORDS konteinerit ${CYAN}$ords_c_name${NC}... ${ORANGE}$(format_duration $WAIT_COUNT)${NC}\r"
            if [ $WAIT_COUNT -ge 60 ]; then
              echo ""
              echo "❌ Viga: ORDS konteiner $ords_c_name ei käivitunud 60 sekundi jooksul!"
              exit 1
            fi
          done
          echo -e "\n   ✅ ORDS teenuse konteiner ${GREEN}$ords_c_name${NC} on KÄIVITATUD!"
        fi
      )
    done
  fi

  if [ "$SKIP_WEB_IDE" = "false" ] && [ "${WEB_IDE_ENABLED:-false}" = "true" ]; then
    echo -e "   🚀 Käivitan Konteineriseeritud Web IDE (${CYAN}${WEB_IDE_CONTAINER_NAME:-web-ide-dev}${NC})..."
    podman-compose "${LOCAL_COMPOSE_ARGS[@]}" --profile web-ide up -d web-ide >> "$LOG_FILE" 2>&1 || true
  fi

  STEP4_CONTAINER_SECS=$(( $(date +%s) - STEP4_START ))
  STEP4_TIME=$(format_duration $STEP4_CONTAINER_SECS)
  echo -e "⏱  [Samm 4 valmis (Konteinerite käivitamine & DB Healthcheck): ${YELLOW}$STEP4_TIME${NC}]"
else
  echo "=================================================================="
  echo "4. Kaug-andmebaas tuvastatud. Jätan kohalike konteinerite käivitamise vahele."
  echo "=================================================================="
  STEP4_CONTAINER_SECS=0
  STEP4_TIME="vahele jäetud"
fi

# Kui tegemist on kohaliku paigaldusega, loome ja seadistame Oracle Walleti
STEP4_5_SECS=0
if [ "$IS_LOCAL" = "true" ]; then
  print_header "4.5" "Oracle Walleti ja TNS algseadistamine (SEPS)..." "step4_5_wallet_tns_config_seconds" "10s"
  STEP4_5_START=$(date +%s)
  "$SCRIPT_DIR/internal/create-wallet.sh"
  STEP4_5_SECS=$(( $(date +%s) - STEP4_5_START ))
  STEP4_5_TIME=$(format_duration $STEP4_5_SECS)
  echo -e "⏱  [Samm 4.5 valmis (Wallet & TNS seadistus): ${YELLOW}$STEP4_5_TIME${NC}]"
fi

PRIMARY_CONTAINER=$(get_active_db_instances 2>/dev/null | head -n 1 | cut -d'|' -f1)
PRIMARY_CONTAINER="${PRIMARY_CONTAINER:-db-dev-full}"
PRIMARY_UPPER=$(echo "$PRIMARY_CONTAINER" | tr '-' '_' | tr '[:lower:]' '[:upper:]')

# Valime ühenduse tüübi (Wallet vs parool)
if [ -f "$TNS_ADMIN/cwallet.sso" ]; then
  CONN_STR_SCHEMA="/@DB_${PRIMARY_UPPER}_SCHEMA"
  if [ "$IS_ADB" = "true" ]; then
    CONN_STR_SYS="/@DB_${PRIMARY_UPPER}_SYS"
  else
    SYS_PWD=$(podman exec "$PRIMARY_CONTAINER" cat /run/secrets/oracle_pwd 2>/dev/null || podman secret inspect --showsecret apex_db_sys_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || echo "$APEX_DB_SYS_PASSWORD")
    CONN_STR_SYS="sys/${SYS_PWD}@${DB_HOST}:${DB_PORT}/${DB_SERVICE} as sysdba"
  fi
else
  CONN_STR_SCHEMA="${APEX_SCHEMA_USER:-APEX_PROXY_SCHEMA}/${APEX_SCHEMA_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_SERVICE}"
  if [ "$IS_ADB" = "true" ]; then
    CONN_STR_SYS="${APEX_ADMIN_USER:-admin}/${APEX_DB_SYS_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_SERVICE}"
  else
    CONN_STR_SYS="sys/${APEX_DB_SYS_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_SERVICE} as sysdba"
  fi
fi

# ----------------------------------------------------------------------------
# SAMM 5: ORDS teenuse käivitamise ja reageerimise kontroll
# ----------------------------------------------------------------------------
STEP5_START=$(date +%s)
if [ "$SKIP_ORDS" = "true" ] || [ "$IS_LOCAL" = "false" ]; then
  echo "=================================================================="
  echo -e "5. Eraldi lokaalset ORDS konteinerit ei vajata. (Põhjus: ${CYAN}${ORDS_SKIP_REASON:-kaug-andmebaas või seadistus}${NC})"
  echo "   Jätan lokaalse ORDS teenuse kontrolli vahele."
  echo "=================================================================="
  STEP5_ORDS_SECS=0
  STEP5_TIME="vahele jäetud"
else
  ords_h_port="${ORDS_HTTP_PORT:-${PROFILE_ORDS_HTTP_PORT:-8088}}"
  ords_check_url="http://localhost:${ords_h_port}/ords/"
  print_header "5" "Kontrollin ORDS teenuse valmisolekut (URL: $ords_check_url)..." "step5_ords_service_seconds" "30s"
  echo -e "   ℹ️  Kontrollitakse: Kas lokaalne ORDS veebiserver reageerib HTTP päringutele aadressil ${CYAN}$ords_check_url${NC} (HTTP 200/301/302/303/404)."
  
  if curl -s -I "$ords_check_url" 2>/dev/null | grep -q "200\|301\|302\|303\|404"; then
    echo -e "   ✅ ORDS teenus on juba valmis ja kättesaadav (${GREEN}$ords_check_url${NC})."
  else
    ORDS_WAIT=0
    until curl -s -I "$ords_check_url" 2>/dev/null | grep -q "200\|301\|302\|303\|404"; do
      sleep 3
      ORDS_WAIT=$((ORDS_WAIT + 3))
      print_progress "   Ootan ORDS-i ($ords_check_url)... kestus: ${ORANGE}$(format_duration $ORDS_WAIT)${NC}\r"
      if [ $ORDS_WAIT -ge 60 ]; then
        echo ""
        echo "Hoiatus: ORDS HTTP porti ($ords_check_url) ei saavutatud 60s jooksul, jätkan APEX paigaldusega."
        break
      fi
    done
    echo ""
  fi
  STEP5_ORDS_SECS=$(( $(date +%s) - STEP5_START ))
  STEP5_TIME=$(format_duration $STEP5_ORDS_SECS)
  echo -e "⏱  [Samm 5 valmis (ORDS teenus): ${YELLOW}$STEP5_TIME${NC}]"
fi

# Liquibase migratsioonid viidud APEX installi järgseks (Samm 7)


# ----------------------------------------------------------------------------
# SAMM 6 & 7: APEX Mootori ja Patchi automaatne paigaldamine
# ----------------------------------------------------------------------------
print_header "6" "Käivitan APEX mootori ja patchide paigaldamise skriptid..." "step7_apex_engine_install_seconds" "6m"

# APEX paigaldus kõikidele aktiivsetele andmebaasidele profiilide põhjal
while IFS='|' read -r c_name prof env_key; do
  [ -z "$c_name" ] && continue
  db_suffix=$(echo "$c_name" | sed 's/^db-//' | tr '-' '_')
  (
    load_db_profile "$prof" >/dev/null 2>&1 || true
    if [ "$IS_ADB" = "true" ]; then
      echo -e "   ℹ️  Andmebaas ${c_name} (Profiil: ${prof}) on ADB. APEX on eelinstalleeritud. Jätan vahele."
    elif [ "${PROFILE_APEX_ENABLED:-true}" = "false" ] || [ "${PROFILE_APEX_VERSION:-NONE}" = "NONE" ]; then
      echo -e "   ℹ️  Andmebaasil ${c_name} (Profiil: ${prof}) ei ole APEX paigaldus aktiivne."
    else
      echo -e "   🚀 [${c_name}]: Käivitan APEX ${PROFILE_APEX_VERSION:-26.1} paigalduse..."
      INSTALL_ARGS=()
      if [ "$FORCE" = "true" ]; then
        INSTALL_ARGS+=("--force")
      fi
      INSTALL_ARGS+=("--db" "$(echo "$c_name" | sed 's/^db-//' | tr '-' '_')" "--version" "${PROFILE_APEX_VERSION:-26.1}" "--port" "${PROFILE_DB_PORT}" "--service" "${PROFILE_DEFAULT_SERVICE}")
      if [ "${PROFILE_ORDS_ENABLED:-true}" = "false" ] || [ "$SKIP_ORDS" = "true" ]; then
        INSTALL_ARGS+=("--no-ords")
      fi
      "$SCRIPT_DIR/internal/install-apex.sh" "${INSTALL_ARGS[@]}"
    fi
  )
done

# Konfiguratsiooni sünkroniseerimine ja REST-aktiveerimine on viidud üle SQLcl Projects (Database Application CI/CD) alla.


# ----------------------------------------------------------------------------
# SAMM 7: Andmebaasi skeemi migratsioonid (Liquibase)
# ----------------------------------------------------------------------------
STEP5_5_START=$(date +%s)
print_header "7" "Käivitan andmebaasi skeemi installeerimise..." "step5_5_liquibase_migration_seconds" "15s"

STEP5_5_LOG="$LOG_DIR/liquibase_migration_$(date +%Y%m%d_%H%M%S).log"

# Algseadistan andmebaasi skeemid (loome kasutajad ja tablespaced)
T7_1_START=$(date +%s)
echo -e "${CYAN}├─${NC} ${YELLOW}[Alamsamm 7.1]: Algseadistan aktiivsete andmebaaside skeemid ja kasutajad...${NC}"

get_active_db_instances 2>/dev/null | while IFS='|' read -r c_name prof env_key; do
  [ -z "$c_name" ] && continue
  "$SCRIPT_DIR/internal/init-db-instance.sh" "$prof" "$c_name" >> "$STEP5_5_LOG" 2>&1
done

T7_1_SECS=$(($(date +%s) - T7_1_START))
echo -e "${CYAN}│${NC}  ⏱  [Alamsamm 7.1 valmis: ${GREEN}$(format_duration $T7_1_SECS)${NC}]"

T7_3_START=$(date +%s)
echo -e "${CYAN}├─${NC} ${YELLOW}[Alamsamm 7.3]: Käivitan Liquibase skeemi migratsioonid...${NC}"

HAS_MIGRATION=false
get_active_db_instances 2>/dev/null | while IFS='|' read -r c_name prof env_key; do
  [ -z "$c_name" ] && continue
  db_suffix=$(echo "$c_name" | sed 's/^db-//' | tr '-' '_')
  UPPER_NAME=$(echo "$c_name" | tr '-' '_' | tr '[:lower:]' '[:upper:]')
  
  CHANGELOG_PATH=""
  if [ -f "$WORKSPACE_DIR/db-install/${c_name}/changelog.xml" ]; then
    CHANGELOG_PATH="db-install/${c_name}/changelog.xml"
  elif [ -f "$WORKSPACE_DIR/db-install/${db_suffix}/changelog.xml" ]; then
    CHANGELOG_PATH="db-install/${db_suffix}/changelog.xml"
  fi

  if [ -n "$CHANGELOG_PATH" ]; then
    HAS_MIGRATION=true
    echo "Käivitan Liquibase migratsiooni instantsile ${c_name} (${CHANGELOG_PATH})..."
    CONN_STR_SCHEMA="/@DB_${UPPER_NAME}_SCHEMA"
    set +e
    run_sqlcl -s "$CONN_STR_SCHEMA" >> "$STEP5_5_LOG" 2>&1 <<EOF
lb update -changelog-file ${CHANGELOG_PATH}
EXIT;
EOF
    RC=$?
    set -e
    if [ $RC -ne 0 ]; then
      echo -e "${RED}❌ Viga: Liquibase migratsioon instantsile ${c_name} ebaõnnestus!${NC}"
      echo -e "   Vaata logi: [Logi](file://$STEP5_5_LOG)"
      exit $RC
    fi
  fi
done

if [ "$HAS_MIGRATION" = "false" ]; then
  echo "📊 Liquibase migratsiooni asukohad ei leitud. Jätan vahele."
fi

T7_3_SECS=$(($(date +%s) - T7_3_START))
echo -e "${CYAN}│${NC}  ⏱  [Alamsamm 7.3 valmis: ${GREEN}$(format_duration $T7_3_SECS)${NC}]"

STEP5_5_SECS=$(( $(date +%s) - STEP5_5_START ))
STEP5_5_TIME=$(format_duration $STEP5_5_SECS)
echo -e "⏱  [Samm 7 valmis (Liquibase migratsioonid): ${GREEN}$STEP5_5_TIME${NC}]"




# ----------------------------------------------------------------------------
# SAMM 8: APEX rakenduste paigaldamine (Deploy Packaged APEX Applications)
# ----------------------------------------------------------------------------
STEP8_START=$(date +%s)
print_header "8" "APEX rakenduste paigaldamine (Deploy Packaged APEX Apps)..." "step10_deploy_apex_apps_seconds" "10s"

STEP8_LOG="$LOG_DIR/deploy_apps_$(date +%Y%m%d_%H%M%S).log"

if [ "$SKIP_MONITOR_APP" = "true" ]; then
  echo "   Jätan APEX rakenduste paigaldamise vahele."
  STEP8_DEPLOY_SECS=0
  STEP8_DEPLOY_TIME="vahele jäetud"
else
  if [ "$IS_LOCAL" = "true" ]; then
    mkdir -p "$SCRIPT_DIR/../binaries/apex_apps"
  fi
  
  echo "   Paigaldan APEX rakendusi failidest (binaries/apex_apps/)..."
  set +e
  "$SCRIPT_DIR/internal/deploy-apex-apps.sh" > "$STEP8_LOG" 2>&1
  RC=$?
  set -e
  
  if [ $RC -ne 0 ]; then
    echo -e "${RED}❌ Viga: APEX rakenduste paigaldamine ebaõnnestus!${NC}"
    echo -e "   Vaata logi: [Logi](file://$STEP8_LOG)"
    exit $RC
  fi
  
  STEP8_DEPLOY_SECS=$(( $(date +%s) - STEP8_START ))
  STEP8_DEPLOY_TIME=$(format_duration $STEP8_DEPLOY_SECS)
  echo -e "⏱  [Samm 8 valmis (APEX rakenduste paigaldus): ${YELLOW}$STEP8_DEPLOY_TIME${NC}]"
fi

# ----------------------------------------------------------------------------
# SAMM 9: Automaatne/Küsitav hetktõmmise tegemine peale õnnestunud paigaldust
# ----------------------------------------------------------------------------
BACKUP_COUNT=0
if [ -d "$SCRIPT_DIR/../golden-snapshots" ]; then
  BACKUP_COUNT=$(find "$SCRIPT_DIR/../golden-snapshots" -maxdepth 1 -name "apex_proxy_oradata_*.tar.gz" 2>/dev/null | wc -l | tr -d ' ')
fi

if [ "$FORCE" = "true" ]; then
  echo -e "${CYAN}==================================================================${NC}"
  echo "Automaatse käivituse režiim (--force): Jätan hetktõmmise küsimuse vahele."
  echo -e "Olemasolevate hetktõmmiste arv kaustas golden-snapshots/: ${CYAN}$BACKUP_COUNT${NC}"
  echo -e "${CYAN}==================================================================${NC}"
  STEP9_SECS=0
  STEP9_TIME="vahele jäetud"
else
  print_header "9" "Andmebaasi hetktõmmise loomine (Golden Snapshot)..." "snapshot_duration_seconds" "2m" "golden_snapshot_benchmarks_*.json"
  echo -e "📊 Sinu golden-snapshots/ kaustas on praegu ${CYAN}$BACKUP_COUNT${NC} hetktõmmis(t):"
  if [ "$BACKUP_COUNT" -gt 0 ]; then
    (cd "$SCRIPT_DIR/../golden-snapshots" && for f in apex_proxy_oradata_*.tar.gz; do
      if [ -f "$f" ]; then
        sz=$(du -sh "$f" | awk '{print $1}')
        dt=$(date -r "$f" +"%Y-%m-%d %H:%M:%S" 2>/dev/null || stat -c "%y" "$f" 2>/dev/null | cut -d'.' -f1 || echo "")
        echo -e "   - ${CYAN}$f${NC} (Suurus: ${YELLOW}$sz${NC}, loodud: ${YELLOW}$dt${NC})"
      fi
    done)
  else
    echo "   (Puuduvad)"
  fi
  echo -e "${CYAN}==================================================================${NC}"
  read -p "$(echo -e "${YELLOW}❓ Kas soovid värskelt paigaldatud andmebaasi volumist kohe teha hetktõmmise (Golden Snapshot)? (y/N): ${NC}")" MAKE_BACKUP_CONFIRM
  
  STEP9_START=$(date +%s)
  if [[ "$MAKE_BACKUP_CONFIRM" =~ ^[Yy]$ ]]; then
    "$SCRIPT_DIR/create-golden-snapshots.sh"
    STEP9_SECS=$(( $(date +%s) - STEP9_START ))
    STEP9_TIME=$(format_duration $STEP9_SECS)
  else
    STEP9_SECS=0
    STEP9_TIME="vahele jäetud"
  fi
fi



# Küsime/teostame arendajakonto ja VS Code ühenduse loomise (lokaalses DEV keskkonnas)
env_type=$(echo "${ENVIRONMENT_TYPE:-DEV}" | tr '[:lower:]' '[:upper:]')
if [ "$IS_LOCAL" = "true" ] && [ "$env_type" = "DEV" ]; then
  if [ "$FORCE" = "true" ]; then
    echo "   ℹ️  Automaatne režiim (--force): Loon ja registreerin APEX arendajakonto ning VS Code ühenduse..."
    "$SCRIPT_DIR/internal/create-developer.sh" --force >/dev/null 2>&1 || true
  else
    echo ""
    read -p "$(echo -e "${YELLOW}❓ Kas soovid luua endale isikliku APEX arendajakonto ja registreerida ühenduse VS Code-is? (y/N): ${NC}")" CREATE_DEV_CONFIRM
    if [[ "$CREATE_DEV_CONFIRM" =~ ^[Yy]$ ]]; then
      "$SCRIPT_DIR/internal/create-developer.sh"
    fi
  fi
fi



# Loeme APEX install-skriptist saadud mõõdikud
if [ -f "$JSON_BENCHMARK" ]; then
  APEX_COPY_SECS=$(grep '"step3_copy_container_seconds":' "$JSON_BENCHMARK" | awk -F: '{print $2}' | tr -d ' ,"\r\n' || echo "20")
  APEX_ENGINE_SECS=$(grep '"step4_apex_engine_install_seconds":' "$JSON_BENCHMARK" | awk -F: '{print $2}' | tr -d ' ,"\r\n' || echo "348")
  ORDS_CONF_SECS=$(grep '"step4_1_ords_config_seconds":' "$JSON_BENCHMARK" | awk -F: '{print $2}' | tr -d ' ,"\r\n' || echo "10")
  APEX_PATCH_SECS=$(grep '"step5_apex_patch_install_seconds":' "$JSON_BENCHMARK" | awk -F: '{print $2}' | tr -d ' ,"\r\n' || echo "41")
fi

TOTAL_MASTER_SECS=$(( $(date +%s) - START_MASTER_TOTAL ))
TOTAL_MASTER_TIME=$(format_duration $TOTAL_MASTER_SECS)

# Define timestamped JSON file name
JSON_TS_BENCHMARK="$METRICS_DIR/setup_benchmarks_${TIMESTAMP}.json"

cat << EOF > "$JSON_TS_BENCHMARK"
{
  "last_updated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "total_duration_seconds": $TOTAL_MASTER_SECS,
  "total_duration_formatted": "$TOTAL_MASTER_TIME",
  "parameters": {
    "is_local": "$IS_LOCAL",
    "db_host": "$DB_HOST",
    "db_port": "$DB_PORT",
    "db_service": "$DB_SERVICE",
    "ords_port": "${ORDS_PORT:-8088}",
    "ords_ssl_port": "${ORDS_SSL_PORT:-8448}"
  },
  "steps": {
    "step1_container_images_pull_seconds": $PULL_SECS,
    "step2_ords_download_seconds": $ORDS_DL_SECS,
    "step3_apex_download_unzip_seconds": $APEX_DL_SECS,
    "step4_container_startup_seconds": $STEP4_CONTAINER_SECS,
    "step4_5_wallet_tns_config_seconds": $STEP4_5_SECS,
    "step5_ords_service_seconds": $STEP5_ORDS_SECS,
    "step5_5_liquibase_migration_seconds": ${STEP5_5_SECS:-0},
    "step6_apex_copy_container_seconds": ${APEX_COPY_SECS:-20},
    "step7_apex_engine_install_seconds": ${APEX_ENGINE_SECS:-348},
    "step8_ords_config_seconds": ${ORDS_CONF_SECS:-10},
    "step9_apex_patch_install_seconds": ${APEX_PATCH_SECS:-41},
    "step10_deploy_apex_apps_seconds": ${STEP8_DEPLOY_SECS:-0},
    "step11_snapshot_seconds": ${STEP9_SECS:-0}
  }
}
EOF

# Copy the latest to setup_benchmarks.json
cp "$JSON_TS_BENCHMARK" "$JSON_BENCHMARK"

# Keep only the last 10 setup benchmark runs in metrics/
(cd "$METRICS_DIR" && ls -t setup_benchmarks_*.json 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null || true)

cat << EOF > "$ENV_BENCHMARK"
# APEX & DB Full Setup Benchmark Metrics (Updated: $(date))
SETUP_TOTAL_SECS=$TOTAL_MASTER_SECS
SETUP_STEP1_PULL_SECS=$PULL_SECS
SETUP_STEP2_ORDS_DOWNLOAD_SECS=$ORDS_DL_SECS
SETUP_STEP3_APEX_DOWNLOAD_SECS=$APEX_DL_SECS
SETUP_STEP4_CONTAINER_STARTUP_SECS=$STEP4_CONTAINER_SECS
SETUP_STEP4_5_WALLET_TNS_CONFIG_SECS=$STEP4_5_SECS
SETUP_STEP5_ORDS_SERVICE_SECS=$STEP5_ORDS_SECS
SETUP_STEP5_5_LIQUIBASE_SECS=${STEP5_5_SECS:-0}
SETUP_STEP6_COPY_SECS=${APEX_COPY_SECS:-20}
SETUP_STEP7_ENGINE_SECS=${APEX_ENGINE_SECS:-348}
SETUP_STEP8_ORDS_CONF_SECS=${ORDS_CONF_SECS:-10}
SETUP_STEP9_PATCH_SECS=${APEX_PATCH_SECS:-41}
SETUP_STEP10_DEPLOY_APPS_SECS=${STEP8_DEPLOY_SECS:-0}
SETUP_STEP11_SNAPSHOT_SECS=${STEP9_SECS:-0}
EOF

# HTTPS sertifikaadi usaldamine OS hoidlas (macOS, Windows, WSL)
ACTIVE_SSL_PORT="${ORDS_SSL_PORT:-${PROFILE_ORDS_HTTPS_PORT:-8448}}"
if [ "$IS_ADB" = "true" ]; then
  ACTIVE_SSL_PORT="${ORDS_HTTPS_PORT:-${PROFILE_ORDS_HTTPS_PORT:-8443}}"
fi

# Genereerime ja usaldame kohaliku SSL sertifikaadi (macOS, Windows, WSL)
if [ "$IS_LOCAL" = "true" ] && [ -x "$SCRIPT_DIR/internal/generate-local-certs.sh" ]; then
  "$SCRIPT_DIR/internal/generate-local-certs.sh" --no-prompt >/dev/null 2>&1 || true
fi

# Andmebaasist versioonide pärimine
DB_NAME="Tundmatu"
DB_EXACT_VER=""
APEX_VER="Tundmatu"
ORDS_VER="Tundmatu"

print_progress "Pärin andmebaasist installeeritud tarkvara versioone...\r"
set +e
VERSION_OUTPUT=$(podman exec -i "$PRIMARY_CONTAINER" sqlplus -s "sys/${SYS_PWD}@//localhost:1521/${DB_SERVICE} as sysdba" <<EOF 2>/dev/null
SET SERVEROUTPUT ON SIZE UNLIMITED
SET FEEDBACK OFF
SET HEADING OFF
SET PAGESIZE 0
DECLARE
  v_apex VARCHAR2(100) := 'Tundmatu';
  v_banner VARCHAR2(150);
  v_ver VARCHAR2(50);
BEGIN
  BEGIN
    SELECT banner_full INTO v_banner FROM v\$version WHERE rownum = 1;
    v_banner := REGEXP_REPLACE(v_banner, ' Release.*', '');
  EXCEPTION WHEN OTHERS THEN v_banner := 'Oracle Database';
  END;

  BEGIN
    SELECT version_full INTO v_ver FROM v\$instance;
  EXCEPTION WHEN OTHERS THEN v_ver := 'Tundmatu';
  END;

  BEGIN
    SELECT version INTO v_apex FROM dba_registry WHERE comp_id = 'APEX';
  EXCEPTION WHEN OTHERS THEN
    BEGIN
      EXECUTE IMMEDIATE 'SELECT version_no FROM apex_release' INTO v_apex;
    EXCEPTION WHEN OTHERS THEN v_apex := 'Tundmatu';
    END;
  END;

  DBMS_OUTPUT.PUT_LINE('DB_NAME:' || v_banner);
  DBMS_OUTPUT.PUT_LINE('DB_EXACT_VER:' || v_ver);
  DBMS_OUTPUT.PUT_LINE('APEX_VERSION:' || v_apex);
END;
/
EXIT;
EOF
)
set -e
# Kustutame ajutise rea ekraanilt
echo -ne "                                                           \r"

if [ -n "$VERSION_OUTPUT" ]; then
  DB_NAME=$(echo "$VERSION_OUTPUT" | grep "DB_NAME:" | cut -d':' -f2- | tr -d '\r' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
  DB_EXACT_VER=$(echo "$VERSION_OUTPUT" | grep "DB_EXACT_VER:" | cut -d':' -f2- | tr -d '\r' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
  APEX_VER=$(echo "$VERSION_OUTPUT" | grep "APEX_VERSION:" | cut -d':' -f2- | tr -d '\r' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
fi

if [ "$SKIP_ORDS" = "true" ]; then
  ORDS_VER="vahele jäetud (${ORDS_SKIP_REASON:-välja lülitatud})"
else
  ORDS_VER=$(podman exec oracle-ords-dev ords --version 2>/dev/null | grep -i "Release" | head -n 1 | awk '{print $3}' || echo "")
  [ -z "$ORDS_VER" ] && ORDS_VER="${PROFILE_ORDS_VERSION:-26.2}"
fi

DB_NAME="${DB_NAME:-Oracle Database}"
APEX_VER="${APEX_VER:-Tundmatu}"

echo ""
echo -e "${CYAN}==================================================================${NC}"
echo -e "${CYAN}⏱   KOGU KESKKONNA AJALINE KOKKUVÕTE (FULL SETUP BENCHMARKS)${NC}"
echo -e "${CYAN}==================================================================${NC}"
echo -e "  1. Konteinerite piltide allalaadimine: ${YELLOW}$PULL_TIME (${PULL_SECS}s)${NC}"
echo -e "  2. ORDS tarkvara allalaadimine:       ${YELLOW}$ORDS_DL_TIME (${ORDS_DL_SECS}s)${NC}"
echo -e "  3. APEX tarkvara allalaadimine:       ${YELLOW}$APEX_DL_TIME (${APEX_DL_SECS}s)${NC}"
echo -e "  4. Konteinerite käivitamine & DB:     ${YELLOW}$STEP4_TIME (${STEP4_CONTAINER_SECS}s)${NC}"
echo -e "  5. ORDS teenuse käivitamine:         ${YELLOW}$STEP5_TIME (${STEP5_ORDS_SECS}s)${NC}"
echo -e "  6. APEX Mootori & Patchide install:"
echo -e "     └─ Failide kopeerimine DB-sse:     ${YELLOW}$(format_duration ${APEX_COPY_SECS:-20})${NC}"
echo -e "     └─ APEX Mootori install (DB):      ${YELLOW}$(format_duration ${APEX_ENGINE_SECS:-348})${NC}"
echo -e "     └─ ORDS konfigureerimine:          ${YELLOW}$(format_duration ${ORDS_CONF_SECS:-10})${NC}"
echo -e "     └─ APEX Patchi install (DB):       ${YELLOW}$(format_duration ${APEX_PATCH_SECS:-41})${NC}"
echo -e "  7. Andmebaasi skeemi installeerimine: ${YELLOW}$STEP5_5_TIME (${STEP5_5_SECS}s)${NC}"
echo -e "  8. APEX rakenduste paigaldus:         ${YELLOW}$STEP8_DEPLOY_TIME (${STEP8_DEPLOY_SECS:-0}s)${NC}"
echo -e "  9. Hetktõmmise (Golden Snapshot) loomine:     ${YELLOW}$STEP9_TIME (${STEP9_SECS:-0}s)${NC}"

if [ "$SKIP_PUBLISHER" = "false" ] && { [ "$ANY_PUB_ENABLED" = "true" ] || [ "${PUBLISHER_ENABLED:-false}" = "true" ]; }; then
  echo -e "\n${YELLOW}🚀 Paigaldan ja initsialiseerin Oracle Analytics Publisheri...${NC}"
  if [ -x "$SCRIPT_DIR/install-publisher.sh" ]; then
    "$SCRIPT_DIR/install-publisher.sh" || true
  fi
fi

echo "  ------------------------------------------------------------"
echo -e "  ⌛ KOGU ÜLESSEADISTAMISE KESTUS:     ${GREEN}$TOTAL_MASTER_TIME (${TOTAL_MASTER_SECS}s)${NC}"
echo -e "  📦 PAIGALDATUD TARKVARA VERSIOONID (DB QUERY):"
echo -e "     ├─ Andmebaas: ${GREEN}$DB_NAME${NC}"
if [ -n "$DB_EXACT_VER" ] && [ "$DB_EXACT_VER" != "Tundmatu" ]; then
  echo -e "     │  └─ Versioon:  ${GREEN}$DB_EXACT_VER${NC}"
fi
echo -e "     ├─ APEX:      ${GREEN}$APEX_VER${NC}"
if [ "$SKIP_ORDS" = "false" ]; then
  echo -e "     └─ ORDS:      ${GREEN}$ORDS_VER${NC} (Konteiner: ${CYAN}${PROFILE_ORDS_CONTAINER_NAME:-oracle-ords-dev}${NC}, Teenus: ${CYAN}${PROFILE_ORDS_SERVICE_NAME:-dev-ords}${NC})"
else
  echo -e "     └─ ORDS:      ${GREEN}$ORDS_VER${NC}"
fi
echo -e "  📊 Seadistuse parameetrid: is_local=${CYAN}$IS_LOCAL${NC}, db_host=${CYAN}$DB_HOST${NC}, db_service=${CYAN}$DB_SERVICE${NC}, ords_port=${CYAN}${ORDS_PORT:-8088}${NC}"
echo -e "${CYAN}==================================================================${NC}"
echo -e "📊 Mõõdikud salvestati Git-i kausta: ${CYAN}$JSON_BENCHMARK${NC}"
echo "------------------------------------------------------------------"
echo -e "📝 Lokaalne logi salvestati:        ${CYAN}$LOG_FILE${NC}"
echo -e "${CYAN}==================================================================${NC}"
if [ "$IS_ADB" = "true" ]; then
  ACTIVE_SSL_PORT="${ORDS_HTTPS_PORT:-${PROFILE_ORDS_HTTPS_PORT:-8443}}"
else
  ACTIVE_SSL_PORT="${ORDS_SSL_PORT:-${PROFILE_ORDS_HTTPS_PORT:-8448}}"
fi

if [ "$SKIP_ORDS" = "true" ]; then
  echo -e "${YELLOW}ℹ️  Eraldi lokaalset ORDS konteinerit ei vajata.${NC}"
  echo -e "   - Põhjus: ${CYAN}${ORDS_SKIP_REASON:-välja lülitatud}${NC}"
else
  CHECK_URL="https://localhost:${ACTIVE_SSL_PORT}/ords/apex"
  echo -e "${YELLOW}🔍 Kontrollin veebiteenuse (APEX/ORDS) kättesaadavust aadressil ${CYAN}$CHECK_URL${NC}...${NC}"
  echo -e "   ℹ️  Kontrollitakse: Kas APEX Builder / REST veebiliides vastab päringule HTTPS pordi kaudu (HTTP 200/301/302/303)."
  URL_STATUS="000"
  CHECK_WAIT=0
  for i in {1..30}; do
    URL_STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" "$CHECK_URL" 2>/dev/null || echo "000")
    if [ "$URL_STATUS" = "200" ] || [ "$URL_STATUS" = "301" ] || [ "$URL_STATUS" = "302" ] || [ "$URL_STATUS" = "303" ]; then
      break
    fi
    sleep 3
    CHECK_WAIT=$((CHECK_WAIT + 3))
    print_progress "   Ootan ORDS veebiliidest... kestus: ${ORANGE}$(format_duration $CHECK_WAIT)${NC}\r"
  done
  echo ""

  if [ "$URL_STATUS" = "200" ] || [ "$URL_STATUS" = "301" ] || [ "$URL_STATUS" = "302" ] || [ "$URL_STATUS" = "303" ]; then
    echo -e "   ✅ APEX/ORDS veebiliides (${CYAN}$CHECK_URL${NC}) vastab edukalt: ${GREEN}HTTP $URL_STATUS (Kättesaadav)${NC}"
  else
    echo -e "   ❌ VIGA: Veebiliides (${CYAN}$CHECK_URL${NC}) ei ole kättesaadav (HTTP $URL_STATUS)!"
    echo -e "      ORDS veebiteenus on kohustuslik ning peab enne paigalduse lõpetamist kättesaadav olema."
    exit 1
  fi
fi

if [ "$SKIP_WEB_IDE" = "false" ] && [ "${WEB_IDE_ENABLED:-false}" = "true" ]; then
  WEB_IDE_CHECK_URL="http://localhost:${WEB_IDE_HTTP_PORT:-8090}/?folder=/config/workspace"
  echo -e "${YELLOW}🔍 Kontrollin Web IDE (VS Code) kättesaadavust aadressil ${CYAN}$WEB_IDE_CHECK_URL${NC}...${NC}"
  echo -e "   ℹ️  Kontrollitakse: Kas brauseripõhine VS Code liides vastab päringule (HTTP 200/301/302)."
  WEB_IDE_STATUS="000"
  WEB_IDE_WAIT=0
  for i in {1..20}; do
    WEB_IDE_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$WEB_IDE_CHECK_URL" 2>/dev/null || echo "000")
    if [ "$WEB_IDE_STATUS" = "200" ] || [ "$WEB_IDE_STATUS" = "301" ] || [ "$WEB_IDE_STATUS" = "302" ]; then
      break
    fi
    sleep 2
    WEB_IDE_WAIT=$((WEB_IDE_WAIT + 2))
    print_progress "   Ootan Web IDE veebiliidest... kestus: ${ORANGE}$(format_duration $WEB_IDE_WAIT)${NC}\r"
  done
  echo ""

  if [ "$WEB_IDE_STATUS" = "200" ] || [ "$WEB_IDE_STATUS" = "301" ] || [ "$WEB_IDE_STATUS" = "302" ]; then
    echo -e "   ✅ Web IDE veebiliides (${CYAN}$WEB_IDE_CHECK_URL${NC}) vastab edukalt: ${GREEN}HTTP $WEB_IDE_STATUS (Kättesaadav)${NC}"
  else
    echo -e "   ⚠️  HOIATUS: Web IDE veebiliides (${CYAN}$WEB_IDE_CHECK_URL${NC}) ei vastanud 40s jooksul (HTTP $WEB_IDE_STATUS)."
  fi
fi
echo ""
echo -e "${YELLOW}🌐 APEX / ORDS TEENUSTE LINGID (Kasuta turvalist HTTPS linki):${NC}"
echo -e "   - ORDS Landing Page:             ${GREEN}https://localhost:${ACTIVE_SSL_PORT}/ords/${NC}"
echo -e "   - APEX Tööruum (Workspace):      ${GREEN}https://localhost:${ACTIVE_SSL_PORT}/ords/apex${NC}"
echo -e "   - APEX Administraator (Admin):   ${GREEN}https://localhost:${ACTIVE_SSL_PORT}/ords/apex_admin${NC}"
echo -e "   💡 Märkus: Lokaalselt on kasutusel HTTPS krüpteering. Brauseris vali 'Täpsemalt/Advanced' -> 'Jätka/Proceed', et usaldada kohalikku sertifikaati."
echo ""
echo -e "${YELLOW}🔑 KASUTAJAD JA PAROOLID (SEPS Wallet):${NC}"
echo -e "   - APEX Admin (ADMIN):          ${GREEN}./scripts/internal/view-wallet-credential.sh APEX_ADMIN${NC}"
echo -e "   - Database SYSDBA (SYS):       ${GREEN}./scripts/internal/view-wallet-credential.sh DB_APEX_PROXY_SYS${NC}"
if [ "$IS_LOCAL" = "true" ]; then
  echo -e "   - Proxy Schema (SCHEMA):       ${GREEN}./scripts/internal/view-wallet-credential.sh DB_APEX_PROXY_SCHEMA${NC}"
  echo -e "   - Test Arendaja (TEST_DEV):     ${GREEN}./scripts/internal/view-wallet-credential.sh DB_TEST_DEV${NC}"
  ACTUAL_DEV_USER=$(echo "${DEVELOPER_USER:-$USER}" | tr '[:lower:]' '[:upper:]')
  if [ -n "$ACTUAL_DEV_USER" ] && [ "$ACTUAL_DEV_USER" != "TEST_DEV" ] && [ "$ACTUAL_DEV_USER" != "SYS" ] && [ "$ACTUAL_DEV_USER" != "ADMIN" ]; then
    echo -e "   - Arendaja (${ACTUAL_DEV_USER}):          ${GREEN}./scripts/internal/view-wallet-credential.sh ${ACTUAL_DEV_USER}${NC}"
  fi
  echo -e "   - Veebikasutaja (TEST_WEB_USER): ${GREEN}./scripts/internal/view-wallet-credential.sh TEST_WEB_USER${NC}"
fi
echo ""
echo -e "${YELLOW}🔌 ANDMEBAASI ÜHENDUSED (SQLcl Connect Strings):${NC}"
if [ "$IS_LOCAL" = "true" ] && [ -f "$TNS_ADMIN/cwallet.sso" ]; then
  SYS_ALIAS=$(python3 -c "import sys, yaml; data = yaml.safe_load(open('$PROFILE_YAML')); [print(u.get('wallet_alias')) for u in data.get('users',[]) if u.get('role') == 'SYSDBA' and u.get('wallet_alias')]" 2>/dev/null | head -n 1)
  SYS_ALIAS="${SYS_ALIAS:-DB_APEX_PROXY_SYS}"

  SCHEMA_ALIAS=$(python3 -c "import sys, yaml; data = yaml.safe_load(open('$PROFILE_YAML')); [print(u.get('wallet_alias')) for u in data.get('users',[]) if u.get('username') == 'APEX_PROXY_SCHEMA' and u.get('wallet_alias')]" 2>/dev/null | head -n 1)
  SCHEMA_ALIAS="${SCHEMA_ALIAS:-DB_APEX_PROXY_SCHEMA}"

  DEV_ALIAS=$(python3 -c "import sys, yaml; data = yaml.safe_load(open('$PROFILE_YAML')); [print(u.get('wallet_alias')) for u in data.get('users',[]) if u.get('username') == 'TEST_DEV' and u.get('wallet_alias')]" 2>/dev/null | head -n 1)
  DEV_ALIAS="${DEV_ALIAS:-DB_TEST_DEV}"

  echo -e "   - APEX Proxy DB:   ${GREEN}sql /@${SYS_ALIAS} as sysdba${NC}"
  echo -e "   - Proxy Schema:    ${GREEN}sql /@${SCHEMA_ALIAS}${NC}"
  echo -e "   - Test arendaja:    ${GREEN}sql /@${DEV_ALIAS}${NC}"
  ACTUAL_DEV_USER=$(echo "${DEVELOPER_USER:-$USER}" | tr '[:lower:]' '[:upper:]')
  if [ -n "$ACTUAL_DEV_USER" ] && [ "$ACTUAL_DEV_USER" != "TEST_DEV" ] && [ "$ACTUAL_DEV_USER" != "SYS" ] && [ "$ACTUAL_DEV_USER" != "ADMIN" ]; then
    echo -e "   - Arendaja (${ACTUAL_DEV_USER}): ${GREEN}sql /@${ACTUAL_DEV_USER}${NC}"
  fi
  echo ""
  echo -e "${YELLOW}🧪 AUTOMATSETE ÜHENDUSTESTIDE TULEMUSED:${NC}"

  TEST_SYS_OUT=$("$SCRIPT_DIR/sqlcl.sh" "/@${SYS_ALIAS}" as sysdba <<< "SELECT USER FROM dual;" 2>&1 || true)
  if echo "$TEST_SYS_OUT" | grep -iq "SYS" || echo "$TEST_SYS_OUT" | grep -iq "Connected to"; then
    echo -e "   - SYS test:        ${GREEN}✅ Ühendus testitud ja toimib (sql /@${SYS_ALIAS} as sysdba)${NC}"
  else
    echo -e "   - SYS test:        ${YELLOW}⚠️  Ühendus vajab tähelepanu (sql /@${SYS_ALIAS} as sysdba)${NC}"
  fi

  TEST_SCH_OUT=$("$SCRIPT_DIR/sqlcl.sh" "/@${SCHEMA_ALIAS}" <<< "SELECT USER FROM dual;" 2>&1 || true)
  if echo "$TEST_SCH_OUT" | grep -iq "APEX_PROXY_SCHEMA" || echo "$TEST_SCH_OUT" | grep -iq "Connected to"; then
    echo -e "   - Schema test:     ${GREEN}✅ Ühendus testitud ja toimib (sql /@${SCHEMA_ALIAS})${NC}"
  else
    echo -e "   - Schema test:     ${YELLOW}⚠️  Ühendus vajab tähelepanu (sql /@${SCHEMA_ALIAS})${NC}"
  fi

  TEST_DEV_OUT=$("$SCRIPT_DIR/sqlcl.sh" "/@${DEV_ALIAS}" <<< "SELECT USER FROM dual;" 2>&1 || true)
  if echo "$TEST_DEV_OUT" | grep -iq "TEST_DEV" || echo "$TEST_DEV_OUT" | grep -iq "Connected to"; then
    echo -e "   - Arendaja test:   ${GREEN}✅ Ühendus testitud ja toimib (sql /@${DEV_ALIAS})${NC}"
  else
    echo -e "   - Arendaja test:   ${YELLOW}⚠️  Ühendus vajab tähelepanu (sql /@${DEV_ALIAS})${NC}"
  fi

  if [ -n "$ACTUAL_DEV_USER" ] && [ "$ACTUAL_DEV_USER" != "TEST_DEV" ] && [ "$ACTUAL_DEV_USER" != "SYS" ] && [ "$ACTUAL_DEV_USER" != "ADMIN" ]; then
    TEST_ACT_OUT=$("$SCRIPT_DIR/sqlcl.sh" "/@${ACTUAL_DEV_USER}" <<< "SELECT USER FROM dual;" 2>&1 || true)
    if echo "$TEST_ACT_OUT" | grep -iq "$ACTUAL_DEV_USER" || echo "$TEST_ACT_OUT" | grep -iq "Connected to"; then
      echo -e "   - Dev (${ACTUAL_DEV_USER}) test:  ${GREEN}✅ Ühendus testitud ja toimib (sql /@${ACTUAL_DEV_USER})${NC}"
    else
      echo -e "   - Dev (${ACTUAL_DEV_USER}) test:  ${YELLOW}⚠️  Ühendus vajab tähelepanu (sql /@${ACTUAL_DEV_USER})${NC}"
    fi
  fi



  # Kesta integratsiooni tagamine kõigis kesta konfiguratsioonifailides (.zshrc, .zshenv, .bashrc, .bash_profile)
  for rc_file in "$HOME/.zshrc" "$HOME/.zshenv" "$HOME/.bashrc" "$HOME/.bash_profile"; do
    touch "$rc_file" 2>/dev/null || true
    if ! grep -q "oracle-devops-platform/scripts/sqlcl.sh" "$rc_file" 2>/dev/null && ! grep -q "oracle-free-db-in-prod/scripts/sqlcl.sh" "$rc_file" 2>/dev/null; then
      cat << EOF >> "$rc_file"

# Oracle DevOps Platform - SQLcl Environment Settings
export TNS_ADMIN="$TNS_ADMIN"
export JAVA_TOOL_OPTIONS="-Doracle.net.tns_admin=\$TNS_ADMIN"
alias sql="$SCRIPT_DIR/sqlcl.sh"

EOF

    fi
  done
  echo -e "   - Kesta seadistus: ${GREEN}✅ Lisatud kesta integratsioon macOS (zsh) ja Linux (bash) kesta profiilidesse${NC}"

else
  get_active_db_instances 2>/dev/null | while IFS='|' read -r container prof env_key; do
    [ -z "$container" ] && continue
    (
      load_db_profile "$prof" >/dev/null 2>&1 || true
      p_port="${PROFILE_DB_PORT:-1532}"
      p_service="${PROFILE_DEFAULT_SERVICE:-FREEPDB1}"
      p_admin="${PROFILE_ADMIN_USER:-sys}"
      p_role="${PROFILE_ADMIN_ROLE:-SYSDBA}"
      r_suffix=""
      [ "$p_role" = "SYSDBA" ] && r_suffix=" as sysdba"
      echo -e "   - ${container}:   ${GREEN}sql ${p_admin}@localhost:${p_port}/${p_service}${r_suffix}${NC}"
    )
  done
fi
echo ""
echo -e "${YELLOW}📂 VS Code ühenduse manager (SQL Developer Connection):${NC}"
if [ "$IS_LOCAL" = "true" ] && [ -f "$SCRIPT_DIR/internal/register-connections-sqlcl.sh" ]; then
  "$SCRIPT_DIR/internal/register-connections-sqlcl.sh" >/dev/null 2>&1 || true
  echo -e "   - VS Code ühendused registreeriti automaatselt (/APEX või /MYATP ja /Publisher)!"
fi
if [ "$SKIP_WEB_IDE" = "false" ] && [ "${WEB_IDE_ENABLED:-false}" = "true" ]; then
  "$SCRIPT_DIR/internal/init-web-ide.sh" >/dev/null 2>&1 || true
  echo -e "   - Konteineriseeritud Web IDE (VS Code): ${GREEN}http://localhost:${WEB_IDE_HTTP_PORT:-8090}${NC} (Profiil: ${YELLOW}${WEB_IDE_PROFILE:-web-ide-standard}${NC})"
fi
echo -e "   - [connections/README.md](file://${SCRIPT_DIR}/../connections/README.md)"

echo ""
echo -e "${YELLOW}🧪 VEEBILIIDESE AUTOMAATNE BROWSER/UI TESTIMINE:${NC}"
echo -e "   - E2E Sisselogimistest (ORDS / APEX Admin / APEX Builder): ${GREEN}./tests/test-browser-login.sh${NC}"
echo -e "${CYAN}==================================================================${NC}"
echo -e "${GREEN}✅ Kogu keskkonna ülesseadistamine edukalt lõpetatud!${NC}"
echo -e "${CYAN}==================================================================${NC}"
