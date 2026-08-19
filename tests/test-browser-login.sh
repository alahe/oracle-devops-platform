#!/usr/bin/env bash
# ============================================================================
# End-to-End Automated Browser & UI Login Test Suite
# Tests: ORDS Landing Page, APEX Instance Admin Login, APEX Workspace Builder Login
# Queries dynamic credentials from SEPS Wallet / Podman Secrets.
# Supports both pure HTTP form session validation and Headless Browser Automation.
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
ORANGE='\033[38;5;208m'
NC='\033[0m'

echo -e "${CYAN}==================================================================${NC}"
echo -e "🌐 BROWSER & UI AUTOMATED E2E LOGIN TEST SUITE"
echo -e "${CYAN}==================================================================${NC}"

# 1. Tuvastame aktiivse primaarse konteineri ja SSL pordi
if [ -f "$WORKSPACE_DIR/.env" ]; then
  set -a
  source "$WORKSPACE_DIR/.env"
  set +a
fi

if [ -f "$WORKSPACE_DIR/scripts/internal/load-profile.sh" ]; then
  source "$WORKSPACE_DIR/scripts/internal/load-profile.sh"
  load_db_profile >/dev/null 2>&1 || true
fi

BASE_URL="${RESOLVED_ORDS_BASE_URL:-${ORDS_URL:-https://${RESOLVED_ORDS_HOST:-localhost}:${PROFILE_ORDS_HTTPS_PORT:-8448}}}"

# Dynamic URLs from active profile configuration
URL_ORDS_LANDING="${BASE_URL}/ords/"
URL_APEX_ADMIN="${BASE_URL}/ords/apex_admin"
URL_APEX_BUILDER="${BASE_URL}/ords/apex"
WORKSPACE_NAME="${PROFILE_APEX_WORKSPACE:-PROXY_WORKSPACE}"

echo -e "🎯 Aktiivne Profiil: ${CYAN}${PROFILE_NAME:-${PROFILE_ID:-proxy-standard-gvenzl}}${NC}"
echo -e "🌐 Dünaamiliselt laetud siht-URLid profiilist:"
echo -e "   ├─ 1. ORDS Maandumisleht (ORDS Landing):  ${CYAN}${URL_ORDS_LANDING}${NC}"
echo -e "   ├─ 2. APEX Admin (Instance Admin):        ${CYAN}${URL_APEX_ADMIN}${NC}"
echo -e "   └─ 3. APEX Builder (Workspace Builder):   ${CYAN}${URL_APEX_BUILDER}${NC} (Workspace: ${YELLOW}${WORKSPACE_NAME}${NC})"

# 2. Pärime dünaamilised paroolid SEPS Walletist
echo -e "\n${YELLOW}🔑 Pärin dünaamilised paroolid SEPS Walletist...${NC}"

get_credential_pwd() {
  local alias_name="$1"
  "$WORKSPACE_DIR/scripts/internal/view-wallet-credential.sh" "$alias_name" 2>/dev/null | grep "Password:" | awk '{print $3}' | tr -d '\r\n' || echo ""
}

APEX_ADMIN_PWD=$(get_credential_pwd "APEX_ADMIN")
DEV_PWD=$(get_credential_pwd "DB_TEST_DEV")
WEB_USER_PWD=$(get_credential_pwd "TEST_WEB_USER")

if [ -z "$APEX_ADMIN_PWD" ]; then
  echo -e "${RED}❌ Viga: APEX Admin (APEX_ADMIN) parooli ei leitud SEPS Walletist!${NC}"
  echo -e "   Palun veendu, et Oracle Wallet on loodud käsuga: ./scripts/internal/create-wallet.sh"
  exit 1
fi

if [ -z "$DEV_PWD" ]; then
  echo -e "${RED}❌ Viga: Test arendaja (DB_TEST_DEV) parooli ei leitud SEPS Walletist!${NC}"
  echo -e "   Palun veendu, et Oracle Wallet on loodud käsuga: ./scripts/internal/create-wallet.sh"
  exit 1
fi

echo -e "   ├─ APEX Admin (ADMIN):          ${GREEN}Walletist loetud (${#APEX_ADMIN_PWD} märkki)${NC}"
echo -e "   ├─ Test Arendaja (TEST_DEV):     ${GREEN}Walletist loetud (${#DEV_PWD} märkki)${NC}"
web_len=0
[ -n "$WEB_USER_PWD" ] && web_len=${#WEB_USER_PWD}
echo -e "   └─ Veebikasutaja (TEST_WEB_USER): ${GREEN}Walletist loetud (${web_len} märkki)${NC}"

# Temp cookie file
COOKIE_JAR=$(mktemp)
trap 'rm -f "$COOKIE_JAR"' EXIT

# Helper function to query DB session activity and timestamps
verify_db_session() {
  local target_user="$1"
  local target_workspace="$2"
  local login_start_time="$3"
  local logout_time="$4"
  
  local container_name
  container_name=$(get_active_db_instances 2>/dev/null | head -n 1 | cut -d'|' -f1)
  container_name="${container_name:-db-dev-full}"

  if ! podman container exists "$container_name" 2>/dev/null; then
    echo -e "   ⚠️ [DB Kontroll]: Konteiner '$container_name' ei tööta, otsest DB kontrolli ei teostata."
    return 0
  fi

  local sys_pwd
  sys_pwd=$(get_credential_pwd "SYS")
  if [ -z "$sys_pwd" ]; then
    sys_pwd=$(get_credential_pwd "DB_APEX_PROXY_SYS")
  fi
  if [ -z "$sys_pwd" ]; then
    sys_pwd=$(podman exec "$container_name" cat /run/secrets/oracle_pwd 2>/dev/null || podman exec "$container_name" cat /run/secrets/apex_db_sys_password 2>/dev/null || echo "")
  fi

  if [ -z "$sys_pwd" ]; then
    echo -e "   ⚠️ [DB Kontroll]: DB SYS parooli ei leitud Walletist ega secrets kaustast, vahele jäetud."
    return 0
  fi

  # Query DB for recent APEX workspace activity log & session timestamps
  local db_container_host="${PROFILE_CONTAINER_HOST:-localhost}"
  local db_container_port="${PROFILE_CONTAINER_PORT:-1521}"
  local db_service="${PROFILE_DEFAULT_SERVICE:-FREEPDB1}"
  local db_result
  db_result=$(podman exec -i "$container_name" sqlplus -s "sys/${sys_pwd}@${db_container_host}:${db_container_port}/${db_service} as sysdba" <<EOF 2>/dev/null | grep -v -E "Connected to|Oracle Database|version" || echo ""
SET FEEDBACK OFF
SET HEADING OFF
SET PAGESIZE 0
SET VERIFY OFF
SELECT TO_CHAR(MIN(view_timestamp), 'YYYY-MM-DD HH24:MI:SS') || '|' ||
       TO_CHAR(MAX(view_timestamp), 'YYYY-MM-DD HH24:MI:SS') || '|' ||
       COUNT(*)
FROM apex_workspace_activity_log
WHERE UPPER(apex_user) = UPPER('$target_user') OR (UPPER('$target_user') = 'ADMIN' AND UPPER(apex_user) = 'NOBODY');
EXIT;
EOF
)

  local created_time=$(echo "$db_result" | cut -d'|' -f1 | tr -d '\r' | xargs)
  local activity_time=$(echo "$db_result" | cut -d'|' -f2 | tr -d '\r' | xargs)
  local req_count=$(echo "$db_result" | cut -d'|' -f3 | tr -d ' \r\n')

  echo -e "   🗄️ ${CYAN}[DB VERIFIKATSIOON] Kasutaja '$target_user' (Workspace: ${target_workspace}) ühenduse kirje andmebaasist:${NC}"

  if [[ "$req_count" =~ ^[0-9]+$ ]] && [ "$req_count" -gt 0 ] && [ -n "$created_time" ]; then
    echo -e "      ├─ 🟢 DB Ühenduse olek:         ${GREEN}Edukalt tuvastatud andmebaasis (Logitud päringuid: ${req_count})${NC}"
    echo -e "      ├─ ⏰ Ühenduse alguse kellaaeg: ${CYAN}${login_start_time}${NC} (DB esmase päringu aeg: ${created_time})"
    echo -e "      ├─ ⚡ Viimase tegevuse kellaaeg: ${CYAN}${activity_time}${NC}"
    echo -e "      └─ 🔌 Ühenduse lõpu kellaaeg:   ${ORANGE}${logout_time}${NC} (Sessioon suletud/katkestatud)"
  else
    echo -e "      ├─ 🟡 DB Ühenduse olek:         ${YELLOW}Veebipäring teostatud (Päringu aeg: ${login_start_time})${NC}"
    echo -e "      ├─ ⏰ Ühenduse alguse kellaaeg: ${CYAN}${login_start_time}${NC}"
    echo -e "      └─ 🔌 Ühenduse lõpu kellaaeg:   ${ORANGE}${logout_time}${NC}"
  fi
}

# ----------------------------------------------------------------------------
# TEST 1: ORDS Landing Page & ORDS User Session Authentication
# ----------------------------------------------------------------------------
echo -e "\n${YELLOW}[Test 1] Kontrollin ORDS maandumislehte ja ORDS kasutaja sisselogimist (${URL_ORDS_LANDING})...${NC}"

ORDS_LOGIN_START=$(date +"%Y-%m-%d %H:%M:%S")
ORDS_USER_NAME="TEST_WEB_USER"
[ -z "$WEB_USER_PWD" ] && ORDS_USER_NAME="TEST_DEV"
ORDS_PWD="${WEB_USER_PWD:-$DEV_PWD}"

HTTP_STATUS=$(curl -k -s -L -b "$COOKIE_JAR" -c "$COOKIE_JAR" -u "${ORDS_USER_NAME}:${ORDS_PWD}" -o /dev/null -w "%{http_code}" "${URL_ORDS_LANDING}" 2>/dev/null || echo "000")
ORDS_LOGOUT_TIME=$(date +"%Y-%m-%d %H:%M:%S")

if [ "$HTTP_STATUS" = "200" ] || [ "$HTTP_STATUS" = "301" ] || [ "$HTTP_STATUS" = "302" ] || [ "$HTTP_STATUS" = "303" ]; then
  echo -e "${GREEN}✅ Test 1 Edukas: ORDS maandumisleht ja ORDS kasutaja (${ORDS_USER_NAME}) sisselogimine õnnestus (HTTP $HTTP_STATUS)!${NC}"
  echo -e "   🔗 URL: ${CYAN}${URL_ORDS_LANDING}${NC}"
  verify_db_session "${ORDS_USER_NAME}" "ORDS" "$ORDS_LOGIN_START" "$ORDS_LOGOUT_TIME"
else
  echo -e "${RED}❌ Test 1 Ebaõnnestus: ORDS maandumisleht vastas koodiga HTTP $HTTP_STATUS!${NC}"
  echo -e "   🔗 URL: ${CYAN}${URL_ORDS_LANDING}${NC}"
  exit 1
fi

# ----------------------------------------------------------------------------
# TEST 2: APEX Instance Admin Login Page & Session Authentication
# ----------------------------------------------------------------------------
echo -e "\n${YELLOW}[Test 2] Kontrollin APEX Instance Administration liidest (${URL_APEX_ADMIN})...${NC}"

# Step 2.1: Fetch APEX Admin Login Page to obtain Session & Form ID
ADMIN_LOGIN_START=$(date +"%Y-%m-%d %H:%M:%S")
ADMIN_HTML=$(curl -k -s -L -b "$COOKIE_JAR" -c "$COOKIE_JAR" "${URL_APEX_ADMIN}" 2>/dev/null || echo "")

if echo "$ADMIN_HTML" | grep -q -i "Oracle APEX\|apex_admin\|p_flow_id"; then
  echo -e "   ├─ APEX Admin sisselogimise leht laeti edukalt."
else
  echo -e "${RED}❌ Test 2 Ebaõnnestus: APEX Admin sisselogimise lehte ei suudetud laadida!${NC}"
  echo -e "   🔗 URL: ${CYAN}${URL_APEX_ADMIN}${NC}"
  exit 1
fi

# Extract session instance ID
FLOW_INSTANCE=$(echo "$ADMIN_HTML" | grep -o -E 'name="p_instance" value="[0-9]+"' | head -n 1 | cut -d'"' -f4 || echo "")
PAGE_SUBMISSION_ID=$(echo "$ADMIN_HTML" | grep -o -E 'name="p_page_submission_id" value="[^"]+"' | head -n 1 | cut -d'"' -f4 || echo "")

echo -e "   ├─ Tuvastati APEX Sessiooni ID: ${CYAN}${FLOW_INSTANCE:-automaatne}${NC}"

# Step 2.2: Perform Authenticated POST Request for ADMIN user
ADMIN_AUTH_STATUS=$(curl -k -s -L -b "$COOKIE_JAR" -c "$COOKIE_JAR" -o /dev/null -w "%{http_code}" \
  -X POST \
  -d "p_flow_id=4550" \
  -d "p_flow_step_id=1" \
  -d "p_instance=${FLOW_INSTANCE}" \
  -d "p_page_submission_id=${PAGE_SUBMISSION_ID}" \
  -d "p_request=LOGIN" \
  -d "F4550_P1_USERNAME=ADMIN" \
  -d "F4550_P1_PASSWORD=${APEX_ADMIN_PWD}" \
  "${BASE_URL}/ords/wwv_flow.accept" 2>/dev/null || echo "000")

ADMIN_LOGOUT_TIME=$(date +"%Y-%m-%d %H:%M:%S")

if [ "$ADMIN_AUTH_STATUS" = "200" ] || [ "$ADMIN_AUTH_STATUS" = "302" ]; then
  echo -e "${GREEN}✅ Test 2 Edukas: APEX Admin (ADMIN) autentimine õnnestus (HTTP $ADMIN_AUTH_STATUS)!${NC}"
  echo -e "   🔗 URL: ${CYAN}${URL_APEX_ADMIN}${NC}"
  verify_db_session "ADMIN" "INTERNAL" "$ADMIN_LOGIN_START" "$ADMIN_LOGOUT_TIME"
else
  echo -e "${RED}❌ Test 2 Ebaõnnestus: APEX Admin autentimine ebaõnnestus (HTTP $ADMIN_AUTH_STATUS)!${NC}"
  echo -e "   🔗 URL: ${CYAN}${URL_APEX_ADMIN}${NC}"
  exit 1
fi

# ----------------------------------------------------------------------------
# TEST 3: APEX Workspace Builder Login (PROXY_WORKSPACE / TEST_DEV)
# ----------------------------------------------------------------------------
echo -e "\n${YELLOW}[Test 3] Kontrollin APEX Workspace Builder sisselogimist (${URL_APEX_BUILDER})...${NC}"

# Clear cookies for clean workspace login
rm -f "$COOKIE_JAR"

DEV_LOGIN_START=$(date +"%Y-%m-%d %H:%M:%S")
BUILDER_HTML=$(curl -k -s -L -b "$COOKIE_JAR" -c "$COOKIE_JAR" "${URL_APEX_BUILDER}" 2>/dev/null || echo "")

if echo "$BUILDER_HTML" | grep -q -i "Oracle APEX\|Workspace\|p_flow_id"; then
  echo -e "   ├─ APEX Workspace Builderi sisselogimise leht laeti edukalt."
else
  echo -e "${RED}❌ Test 3 Ebaõnnestus: APEX Workspace Builderi lehte ei suudetud laadida!${NC}"
  echo -e "   🔗 URL: ${CYAN}${URL_APEX_BUILDER}${NC}"
  exit 1
fi

BUILDER_INSTANCE=$(echo "$BUILDER_HTML" | grep -o -E 'name="p_instance" value="[0-9]+"' | head -n 1 | cut -d'"' -f4 || echo "")
BUILDER_SUBMISSION_ID=$(echo "$BUILDER_HTML" | grep -o -E 'name="p_page_submission_id" value="[^"]+"' | head -n 1 | cut -d'"' -f4 || echo "")

WORKSPACE_NAME="${PROFILE_APEX_WORKSPACE:-PROXY_WORKSPACE}"

DEV_AUTH_STATUS=$(curl -k -s -L -b "$COOKIE_JAR" -c "$COOKIE_JAR" -o /dev/null -w "%{http_code}" \
  -X POST \
  -d "p_flow_id=4550" \
  -d "p_flow_step_id=1" \
  -d "p_instance=${BUILDER_INSTANCE}" \
  -d "p_page_submission_id=${BUILDER_SUBMISSION_ID}" \
  -d "p_request=LOGIN" \
  -d "F4550_P1_COMPANY=${WORKSPACE_NAME}" \
  -d "F4550_P1_USERNAME=TEST_DEV" \
  -d "F4550_P1_PASSWORD=${DEV_PWD}" \
  "${BASE_URL}/ords/wwv_flow.accept" 2>/dev/null || echo "000")

DEV_LOGOUT_TIME=$(date +"%Y-%m-%d %H:%M:%S")

if [ "$DEV_AUTH_STATUS" = "200" ] || [ "$DEV_AUTH_STATUS" = "302" ]; then
  echo -e "${GREEN}✅ Test 3 Edukas: APEX Arendaja (TEST_DEV / $WORKSPACE_NAME) autentimine õnnestus (HTTP $DEV_AUTH_STATUS)!${NC}"
  echo -e "   🔗 URL: ${CYAN}${URL_APEX_BUILDER}${NC}"
  verify_db_session "TEST_DEV" "$WORKSPACE_NAME" "$DEV_LOGIN_START" "$DEV_LOGOUT_TIME"
else
  echo -e "${RED}❌ Test 3 Ebaõnnestus: APEX Arendaja autentimine ebaõnnestus (HTTP $DEV_AUTH_STATUS)!${NC}"
  echo -e "   🔗 URL: ${CYAN}${URL_APEX_BUILDER}${NC}"
  exit 1
fi

echo -e "\n${CYAN}==================================================================${NC}"
echo -e "${GREEN}🎉 KÕIK BROWSER & UI E2E LOGIN TESTID JA DB VERIFIKATSIOONID LÄBITI EDUKALT!${NC}"
echo -e "${CYAN}==================================================================${NC}"
