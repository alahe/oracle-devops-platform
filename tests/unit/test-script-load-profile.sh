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
# Test 1: Load proxy-adb-oracle Profile & Verify Attributes
# ----------------------------------------------------------------------------
echo -e "${YELLOW}[Test 1] Kontrollin proxy-adb-oracle profiili laadimist ja APEX/ORDS parameetreid...${NC}"
load_db_profile "proxy-adb-oracle"

if [ "$PROFILE_DB_TYPE" = "adb" ] && [ "$IS_ADB" = "true" ] && [ "$PROFILE_CONTAINER_PORT" = "1522" ]; then
  echo -e "   ├─ ${GREEN}ADB profiil tuvastati korrektselt (IS_ADB=true, container_port=1522)${NC}"
else
  echo -e "${RED}❌ Test 1 Ebaõnnestus: ADB profiili parameetrid vigased (IS_ADB=$IS_ADB, port=$PROFILE_CONTAINER_PORT)${NC}"
  exit 1
fi

if [ -n "$PROFILE_APEX_VERSION" ] && [ -n "$PROFILE_APEX_DOWNLOAD_URL" ] && [ -n "$PROFILE_ORDS_DOWNLOAD_URL" ]; then
  echo -e "   └─ ${GREEN}APEX/ORDS komponendid parsiti korrektselt (APEX ver: $PROFILE_APEX_VERSION, ORDS http: $PROFILE_ORDS_HTTP_PORT)${NC}"
else
  echo -e "${RED}❌ Test 1 Ebaõnnestus: Komponentide parsimine YAML failist ebaõnnestus!${NC}"
  exit 1
fi

# ----------------------------------------------------------------------------
# Test 2: Load proxy-standard-gvenzl Profile
# ----------------------------------------------------------------------------
echo -e "${YELLOW}[Test 2] Kontrollin proxy-standard-gvenzl profiili laadimist...${NC}"
load_db_profile "proxy-standard-gvenzl"

if [ "$PROFILE_VENDOR" = "gvenzl" ] && [ "$IS_ADB" = "false" ] && [[ "$RESOLVED_DB_IMAGE" == *"gvenzl"* ]]; then
  echo -e "   └─ ${GREEN}Gvenzl profiil laeti korrektselt (RESOLVED_DB_IMAGE=$RESOLVED_DB_IMAGE)${NC}"
else
  echo -e "${RED}❌ Test 2 Ebaõnnestus: Standard profiili laadimine ebaõnnestus!${NC}"
  exit 1
fi

# ----------------------------------------------------------------------------
# Test 3: Test Dynamic .env Key Parsing with Hyphenated Names (e.g. DB_DEV_FULL=proxy-standard-gvenzl)
# ----------------------------------------------------------------------------
echo -e "${YELLOW}[Test 3] Testin get_active_db_instances sidekriipsudega võtmete ja profiilide tuletamist...${NC}"

TEST_ENV_TEMP="$WORKSPACE_DIR/.env.test_tmp"
cat <<EOF > "$TEST_ENV_TEMP"
# Ajutine testkeskkonna fail
DB_DEV_FULL=proxy-standard-gvenzl
DB_CUSTOM_TEST=app-free
EOF

# Temporarily point WORKSPACE_DIR .env to test file logic
saved_env="$WORKSPACE_DIR/.env"
if [ -f "$saved_env" ]; then
  mv "$saved_env" "${saved_env}.bak_unittest"
fi
cp "$TEST_ENV_TEMP" "$saved_env"

active_instances=($(get_active_db_instances 2>/dev/null))
rm -f "$TEST_ENV_TEMP"

# Restore original .env
if [ -f "${saved_env}.bak_unittest" ]; then
  mv "${saved_env}.bak_unittest" "$saved_env"
fi

if [ "${#active_instances[@]}" -eq 2 ] && [[ "${active_instances[0]}" == *"db-dev-full|proxy-standard-gvenzl|DB_DEV_FULL"* ]]; then
  echo -e "   └─ ${GREEN}Sidekriipsudega võti DB_DEV_FULL ja profiil proxy-standard-gvenzl tuletati puhtalt!${NC}"
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
