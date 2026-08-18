#!/usr/bin/env bash
# ============================================================================
# Automated Test Script for Profile-Driven Instance Initializer Engine
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
echo -e "🧪 PROFIILIPÕHISE INSTANTSI ALGSEADISTAJA TESTIMINE"
echo -e "${CYAN}==================================================================${NC}"

# Source profile initializer
source "$WORKSPACE_DIR/scripts/internal/init-db-instance.sh"

# Test 1: Verify init-db-instance script existence and permissions
echo -e "\n${YELLOW}[Test 1] Kontrollin algseadistaja skripti olemasolu...${NC}"
if [ -x "$WORKSPACE_DIR/scripts/internal/init-db-instance.sh" ] && [ -f "$WORKSPACE_DIR/scripts/internal/init-db-instance.sql" ]; then
  echo -e "${GREEN}✅ Test 1 Edukas: init-db-instance.sh ja init-db-instance.sql failid on olemas!${NC}"
else
  echo -e "${RED}❌ Test 1 Ebaõnnestus: init-db-instance failid puuduvad!${NC}"
  exit 1
fi

# Test 2: Dry-run init_db_instance with proxy-adb-oracle profile
echo -e "\n${YELLOW}[Test 2] Testin ADB profiili algseadistuse loogikat (proxy-adb-oracle)...${NC}"
PRIMARY_CONTAINER=$(get_active_db_instances 2>/dev/null | head -n 1 | cut -d'|' -f1)
PRIMARY_CONTAINER="${PRIMARY_CONTAINER:-db-dev-full}"

if init_db_instance "proxy-adb-oracle" "$PRIMARY_CONTAINER" >/dev/null 2>&1; then
  echo -e "${GREEN}✅ Test 2 Edukas: proxy-adb-oracle algseadistuse mootor käivitus teadete ja vigadeta!${NC}"
else
  echo -e "${RED}❌ Test 2 Ebaõnnestus: proxy-adb-oracle algseadistus ebaõnnestus!${NC}"
  exit 1
fi

# Test 3: Dry-run init_db_instance with appinfra-standard-gvenzl profile
echo -e "\n${YELLOW}[Test 3] Testin Publisher infrasüsteemi algseadistust (appinfra-standard-gvenzl)...${NC}"
if init_db_instance "appinfra-standard-gvenzl" "oracle-db-publisher" >/dev/null 2>&1; then
  echo -e "${GREEN}✅ Test 3 Edukas: appinfra-standard-gvenzl algseadistuse mootor käivitus edukalt!${NC}"
else
  echo -e "${RED}❌ Test 3 Ebaõnnestus: appinfra-standard-gvenzl algseadistus ebaõnnestus!${NC}"
  exit 1
fi

echo -e "\n${CYAN}==================================================================${NC}"
echo -e "${GREEN}🎉 KÕIK INSTANTSI ALGSEADISTAJA TESTID LÄBITUD EDUKALT!${NC}"
echo -e "${CYAN}==================================================================${NC}"
