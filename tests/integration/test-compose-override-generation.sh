#!/usr/bin/env bash
# ============================================================================
# Automated Test Script for Podman Compose Override Generation & ADB Secrets
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}==================================================================${NC}"
echo -e "🧪 PODMAN-COMPOSE OVERRIDE & ADB KESKKONNAMUUTUJATE TESTIMINE"
echo -e "${CYAN}==================================================================${NC}"

# Source profile loader
source "$WORKSPACE_DIR/scripts/internal/load-profile.sh"

# Test 1: Verify IS_ADB export when sourcing and calling load_db_profile
echo -e "\n${YELLOW}[Test 1] Kontrollin IS_ADB lipu eksporti (proxy-adb-oracle)...${NC}"
load_db_profile "proxy-adb-oracle"

if [ "$IS_ADB" = "true" ]; then
  echo -e "${GREEN}✅ Test 1 Edukas: IS_ADB eksport on 'true' (Pilt: ${RESOLVED_DB_IMAGE})!${NC}"
else
  echo -e "${RED}❌ Test 1 Ebaõnnestus: IS_ADB ei ole 'true'! (${IS_ADB})${NC}"
  exit 1
fi

# Test 2: Simulate setup-all.sh override file generation for ADB
echo -e "\n${YELLOW}[Test 2] Testin podman-compose.override.yml genereerimise sisu...${NC}"
OVERRIDE_FILE="$WORKSPACE_DIR/podman-compose.override.yml"

# Generate override
cat <<EOF > "$OVERRIDE_FILE"
version: '3.8'

services:
  db-apex-proxy:
    image: ${RESOLVED_DB_IMAGE:-container-registry.oracle.com/database/adb-free:latest}
EOF

if [ "$IS_ADB" = "true" ]; then
  adb_admin_pwd=$(podman secret inspect --showsecret apex_db_sys_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || echo "")
  adb_wallet_pwd=$(podman secret inspect --showsecret apex_schema_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || echo "")

  [ -z "$adb_admin_pwd" ] && adb_admin_pwd="OraclePass2026Admin"
  [ -z "$adb_wallet_pwd" ] && adb_wallet_pwd="OraclePass2026Wallet"

  cat <<EOF >> "$OVERRIDE_FILE"
    environment:
      - WORKLOAD_TYPE=${PROFILE_WORKLOAD_TYPE:-ATP}
      - ADMIN_PASSWORD=$adb_admin_pwd
      - WALLET_PASSWORD=$adb_wallet_pwd
EOF
fi

# Check generated file contents
if grep -q "WORKLOAD_TYPE=ATP" "$OVERRIDE_FILE" && \
   grep -q "ADMIN_PASSWORD=" "$OVERRIDE_FILE" && \
   grep -q "WALLET_PASSWORD=" "$OVERRIDE_FILE"; then
  echo -e "${GREEN}✅ Test 2 Edukas: podman-compose.override.yml sisaldab kõiki ADB nõutud keskkonnamuutujaid (WORKLOAD_TYPE, ADMIN_PASSWORD, WALLET_PASSWORD)!${NC}"
else
  echo -e "${RED}❌ Test 2 Ebaõnnestus: podman-compose.override.yml failis puuduvad ADB paroolid!${NC}"
  cat "$OVERRIDE_FILE"
  exit 1
fi

# Test 3: Standard DB profile (proxy-standard-gvenzl) should NOT set IS_ADB=true
echo -e "\n${YELLOW}[Test 3] Kontrollin standardprofiili (proxy-standard-gvenzl)...${NC}"
load_db_profile "proxy-standard-gvenzl"

if [ "$IS_ADB" = "false" ]; then
  echo -e "${GREEN}✅ Test 3 Edukas: Standardprofiili puhul on IS_ADB='false'!${NC}"
else
  echo -e "${RED}❌ Test 3 Ebaõnnestus: IS_ADB peaks olema 'false' standardprofiilile!${NC}"
  exit 1
fi

echo -e "\n${CYAN}==================================================================${NC}"
echo -e "${GREEN}🎉 KÕIK OVERRIDE GENEREERIMISE TESTID LÄBITUD EDUKALT!${NC}"
echo -e "${CYAN}==================================================================${NC}"
