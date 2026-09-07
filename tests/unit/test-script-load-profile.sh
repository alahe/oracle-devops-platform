#!/usr/bin/env bash
# ============================================================================
# Dedicated Unit Test for scripts/internal/load-db-profile.sh
# Tests YAML parsing, APEX/ORDS components, dynamic .env key matching,
# hyphenated profile resolution, and precedence rules.
# ============================================================================

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🧪 DEDICATED UNIT TEST: internal/load-profile.sh${NC}"
TARGET_SCRIPT="$WORKSPACE_DIR/scripts/internal/load-profile.sh"

if [ ! -f "$TARGET_SCRIPT" ]; then
  echo -e "${RED}❌ Test Ebaõnnestus: scripts/internal/load-profile.sh puudub!${NC}"
  exit 1
fi

# Syntax Check
bash -n "$TARGET_SCRIPT"
source "$TARGET_SCRIPT"

# ----------------------------------------------------------------------------
# Test 1: Load db-adb Profile & Verify Attributes
# ----------------------------------------------------------------------------
echo -e "${YELLOW}[Test 1] Kontrollin db-adb profiili laadimist ja APEX/ORDS parameetreid...${NC}"
load_db_profile "db-adb"

if [ "$PROFILE_DB_TYPE" = "adb" ] && [ "$IS_ADB" = "true" ] && [ "$PROFILE_CONTAINER_PORT" = "1521" ]; then
  echo -e "   ├─ ${GREEN}ADB profiil tuvastati korrektselt (IS_ADB=true, container_port=1521)${NC}"
else
  echo -e "${RED}❌ Test 1 Ebaõnnestus: ADB profiili parameetrid vigased (IS_ADB=$IS_ADB, port=$PROFILE_CONTAINER_PORT)${NC}"
  exit 1
fi

if [ -n "$PROFILE_DEFAULT_SERVICE" ] && [ "$IS_ADB" = "true" ]; then
  echo -e "   └─ ${GREEN}ADB komponendid parsiti korrektselt (Service: $PROFILE_DEFAULT_SERVICE, IS_ADB: $IS_ADB)${NC}"
else
  echo -e "${RED}❌ Test 1 Ebaõnnestus: Komponentide parsimine YAML failist ebaõnnestus!${NC}"
  exit 1
fi

# ----------------------------------------------------------------------------
# Test 2: Load db-gvenzl Profile & Verify Image Resolution
# ----------------------------------------------------------------------------
echo -e "${YELLOW}[Test 2] Kontrollin db-gvenzl profiili laadimist...${NC}"
load_db_profile "db-gvenzl"

if [ "$PROFILE_VENDOR" = "gvenzl" ] && [ "$IS_ADB" = "false" ] && [[ "$RESOLVED_DB_IMAGE" == *"gvenzl"* ]]; then
  echo -e "   └─ ${GREEN}Gvenzl profiil laeti korrektselt (RESOLVED_DB_IMAGE=$RESOLVED_DB_IMAGE)${NC}"
else
  echo -e "${RED}❌ Test 2 Ebaõnnestus: Standard profiili laadimine ebaõnnestus!${NC}"
  exit 1
fi

# ----------------------------------------------------------------------------
# Test 3: Test Dynamic .env Key Parsing for Active DB Instances
# ----------------------------------------------------------------------------
echo -e "${YELLOW}[Test 3] Testin get_active_db_instances võtmete ja profiilide tuletamist...${NC}"

export DB_PROXY="db-proxy-oracle"
export DB_ALISE="db-alise-oracle"
active_instances=($(get_active_db_instances 2>/dev/null))
unset DB_PROXY DB_ALISE

if [ "${#active_instances[@]}" -eq 2 ] && [[ "${active_instances[0]}" == *"db-proxy|db-proxy-oracle|DB_PROXY"* ]] && [[ "${active_instances[1]}" == *"db-alise|db-alise-oracle|DB_ALISE"* ]]; then
  echo -e "   └─ ${GREEN}Aktiivsed DB rollid (db-proxy ja db-alise) tuletati puhtalt!${NC}"
else
  echo -e "${RED}❌ Test 3 Ebaõnnestus: get_active_db_instances ei parsitud korrektselt! Saadud: ${active_instances[*]}${NC}"
  exit 1
fi

# ----------------------------------------------------------------------------
# Test 4: Default Profile Fallback Resolution without args
# ----------------------------------------------------------------------------
echo -e "${YELLOW}[Test 4] Testin load_db_profile ilma argumentideta vaike-profiili tuletamist...${NC}"
unset MAIN_DB_PROFILE
load_db_profile

if [ -n "$PROFILE_NAME" ] && [ -n "$RESOLVED_DB_IMAGE" ]; then
  echo -e "   └─ ${GREEN}Vaike-profiil tuletati automaatselt: '${PROFILE_NAME}' (${RESOLVED_DB_IMAGE})${NC}"
else
  echo -e "${RED}❌ Test 4 Ebaõnnestus: load_db_profile ilma argumentideta ebaõnnestus!${NC}"
  exit 1
fi

echo -e "${GREEN}✅ KÕIK UNIT TESTIDinternal/load-db-profile.sh SKRIPTILE LÄBITUD EDUKALT!${NC}"
