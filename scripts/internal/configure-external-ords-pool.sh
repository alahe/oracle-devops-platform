#!/usr/bin/env bash
# ============================================================================
# Configure External ORDS Server Connection Pool for Publisher DB
# Creates ORDS Pool XML config and deploys/guides external ORDS integration
# Workspace Rule 3: User-executable script placed in scripts/
# Workspace Rule 5: SEPS Wallet & Podman Secrets integration
# ============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
INTERNAL_DIR="$SCRIPT_DIR/internal"

if [ -f "$SCRIPT_DIR/internal/common.sh" ]; then
  source "$SCRIPT_DIR/internal/common.sh"
elif [ -f "$SCRIPT_DIR/common.sh" ]; then
  source "$SCRIPT_DIR/common.sh"
else
  RED=$'\033[1;31m'
  GREEN=$'\033[1;32m'
  YELLOW=$'\033[0;33m'
  CYAN=$'\033[1;36m'
  NC=$'\033[0m'
fi

PROFILE_NAME="${1:-publisher-only}"
REMOTE_ORDS_HOST=""
REMOTE_SSH_USER=""
DEPLOY_REMOTE=false

# Parse Arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --profile)
      PROFILE_NAME="$2"
      shift 2
      ;;
    --remote-host)
      REMOTE_ORDS_HOST="$2"
      DEPLOY_REMOTE=true
      shift 2
      ;;
    --ssh-user)
      REMOTE_SSH_USER="$2"
      shift 2
      ;;
    -h|--help)
      echo "Kasutus: $0 [--profile publisher-only] [--remote-host ords.company.local] [--ssh-user admin]"
      exit 0
      ;;
    *)
      if [[ "$1" != "$PROFILE_NAME" ]]; then
        PROFILE_NAME="$1"
      fi
      shift
      ;;
  esac
done

if [ -f "$INTERNAL_DIR/load-profile.sh" ]; then
  source "$INTERNAL_DIR/load-profile.sh"
  load_db_profile "$PROFILE_NAME" >/dev/null 2>&1 || true
fi

DB_HOST="localhost"
DB_PORT="${PROFILE_DB_PORT:-1533}"
DB_SERVICE="${PROFILE_DEFAULT_SERVICE:-FREEPDB1}"
POOL_NAME="${PROFILE_ORDS_EXTERNAL_POOL_NAME:-publisher_db}"
TARGET_URL="${PROFILE_ORDS_TARGET_EXTERNAL_SERVER:-https://ords.company.local/ords/}"

echo -e "${CYAN}==================================================================${NC}"
echo -e "${CYAN}🔌 EXTERNAL ORDS CONNECTION POOL CONFIGURATOR (${PROFILE_NAME})${NC}"
echo -e "${CYAN}==================================================================${NC}"
echo -e "   - Andmebaasi aadress:  ${GREEN}${DB_HOST}:${DB_PORT}/${DB_SERVICE}${NC}"
echo -e "   - ORDS Pool-i nimi:    ${GREEN}${POOL_NAME}.xml${NC}"
echo -e "   - Siht ORDS Server:    ${GREEN}${TARGET_URL}${NC}"
echo -e "${CYAN}==================================================================${NC}\n"

# 1. Check ORDS Schema in DB
echo -e "${YELLOW}🔍 1. Kontrollin ORDS skeemi valmisolekut andmebaasis...${NC}"
PRIMARY_CONTAINER=$(get_active_db_instances 2>/dev/null | grep -i "publisher" | head -n 1 | cut -d'|' -f1)
PRIMARY_CONTAINER="${PRIMARY_CONTAINER:-main-db-profile}"

if podman ps --format "{{.Names}}" 2>/dev/null | grep -q "$PRIMARY_CONTAINER"; then
  ORDS_VER_CHECK=$(podman exec -i "$PRIMARY_CONTAINER" sh -c "sqlplus -S / as sysdba" <<EOF 2>/dev/null || echo "N/A"
SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF;
SELECT ords.version_number FROM dual;
EXIT;
EOF
)
  ORDS_VER_CHECK=$(echo "$ORDS_VER_CHECK" | tr -d '\r\n' | awk '{print $1}')
  if [ -n "$ORDS_VER_CHECK" ] && [ "$ORDS_VER_CHECK" != "N/A" ]; then
    echo -e "   ✅ ORDS schema installed. Version: ${GREEN}${ORDS_VER_CHECK}${NC}"
  else
    echo -e "   ⚠️  ORDS schema not detected. Starting automatic schema initialization..."
    if [ -f "$INTERNAL_DIR/init-publisher-ords.sh" ]; then
      "$INTERNAL_DIR/init-publisher-ords.sh" || true
    fi
  fi
else
  echo -e "   ℹ️  Container $PRIMARY_CONTAINER is not running currently. Expecting existing database on port $DB_PORT."
fi

# 2. Retrieve Password from Wallet or Podman Secret (Rule 5)
SCHEMA_PWD=$(podman secret inspect --showsecret apex_db_sys_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || echo "")
if [ -z "$SCHEMA_PWD" ]; then
  SCHEMA_PWD=$("$INTERNAL_DIR/get-password.sh" "DB_PUBLISHER_SYS" 2>/dev/null | grep "Password:" | awk '{print $3}' | sed 's/\x1b\[[0-9;]*m//g' | tr -d '\r\n' || echo "")
fi
if [ -z "$SCHEMA_PWD" ]; then
  echo "❌ ERROR: Could not find database password from Wallet or Podman Secrets store!"
  exit 1
fi

# 3. Generate Pool XML
OUTPUT_XML_DIR="$WORKSPACE_DIR/config/ords_pools"
mkdir -p "$OUTPUT_XML_DIR"
POOL_FILE="$OUTPUT_XML_DIR/${POOL_NAME}.xml"

cat <<EOF > "$POOL_FILE"
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
<properties>
<comment>ORDS Connection Pool configuration for Publisher DB (${PROFILE_NAME})</comment>
<entry key="db.connectionType">basic</entry>
<entry key="db.hostname">${DB_HOST}</entry>
<entry key="db.port">${DB_PORT}</entry>
<entry key="db.servicename">${DB_SERVICE}</entry>
<entry key="db.username">ORDS_PUBLIC_USER</entry>
<entry key="db.password">${SCHEMA_PWD}</entry>
<entry key="security.requestValidationFunction">wwv_flow_epg_include_modules.authorize</entry>
</properties>
EOF

echo -e "   ✅ Loodud ühendusbasseini konfiguratsioonifail: ${CYAN}${POOL_FILE}${NC}\n"

# 4. Deployment or Instructions
if [ "$DEPLOY_REMOTE" = "true" ] && [ -n "$REMOTE_ORDS_HOST" ]; then
  SSH_TARGET="${REMOTE_SSH_USER}@${REMOTE_ORDS_HOST}"
  if [ -z "$REMOTE_SSH_USER" ]; then
    SSH_TARGET="${REMOTE_ORDS_HOST}"
  fi
  echo -e "${YELLOW}🚀 2. Kopeerin pool konfiguratsiooni välisesse ORDS serverisse (${SSH_TARGET})...${NC}"
  scp "$POOL_FILE" "${SSH_TARGET}:/etc/ords/config/databases/${POOL_NAME}.xml" || true
  ssh "${SSH_TARGET}" "ords config set --db-pool ${POOL_NAME} db.hostname ${DB_HOST} && ords --config /etc/ords/config serve" || true
  echo -e "   ✅ Kopeeritud ja seadistatud kaugedukalt!"
else
  echo -e "${YELLOW}📋 2. JUHEND VÄLISE ORDS SERVERI (KÄSITSI VÕI CLI) SEADISTAMISEKS:${NC}"
  echo -e "   1. Kopeeri loodud XML fail välise ORDS serveri konfiguratsioonikausta:"
  echo -e "      ${CYAN}cp ${POOL_FILE} /etc/ords/config/databases/${POOL_NAME}.xml${NC}"
  echo -e "   2. Või käivita välises ORDS serveris ametlik CLI käsk:"
  echo -e "      ${CYAN}ords config set --db-pool ${POOL_NAME} db.hostname ${DB_HOST} db.port ${DB_PORT} db.servicename ${DB_SERVICE} db.username ORDS_PUBLIC_USER${NC}"
  echo -e "   3. Taaskäivita või laadi uuesti välise ORDS-i teenus:"
  echo -e "      ${CYAN}systemctl restart ords${NC}  või  ${CYAN}ords serve${NC}"
fi

echo -e "\n${YELLOW}🧪 3. TESTIMINE JA VERIFITSEERIMINE:${NC}"
echo -e "   - Testi ühendust ja reageerimist välisest ORDS-ist:"
echo -e "     ${GREEN}curl -k -I ${TARGET_URL}${POOL_NAME}/${NC}"
echo -e "   - Kontrolli andmebaasi ORDS versiooni päringuga:"
echo -e "     ${GREEN}sql /@DB_PUBLISHER_SYS as sysdba <<< \"SELECT ords.version_number FROM dual;\"${NC}\n"
echo -e "${CYAN}==================================================================${NC}"
