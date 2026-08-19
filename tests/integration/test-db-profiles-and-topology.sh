#!/usr/bin/env bash
# ============================================================================
# Automated Test Script for Dynamic Database Profiles & Topology Engine
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
echo -e "🧪 DÜNAAMILISTE PROFIILIDE JA TOPOLOOGIA TESTIMINE"
echo -e "${CYAN}==================================================================${NC}"

# Source profile loader
source "$WORKSPACE_DIR/scripts/internal/load-profile.sh"

# Test 1: Load proxy-adb-oracle profile
echo -e "\n${YELLOW}[Test 1] Laen ADB profiili (proxy-adb-oracle)...${NC}"
load_db_profile "proxy-adb-oracle"

if [ "$PROFILE_DB_TYPE" = "adb" ] && [ "$IS_ADB" = "true" ] && [[ "$RESOLVED_DB_IMAGE" == *"adb-free"* ]]; then
  echo -e "${GREEN}✅ Test 1 Edukas: ADB profiil laeti korrektselt (IS_ADB=true)!${NC}"
else
  echo -e "${RED}❌ Test 1 Ebaõnnestus: ADB profiili parameetrid olid valed!${NC}"
  exit 1
fi

# Test 2: Load proxy-standard-gvenzl profile
echo -e "\n${YELLOW}[Test 2] Laen Gvenzl profiili (proxy-standard-gvenzl)...${NC}"
load_db_profile "proxy-standard-gvenzl"

if [ "$PROFILE_VENDOR" = "gvenzl" ] && [ "$IS_ADB" = "false" ] && [[ "$RESOLVED_DB_IMAGE" == *"gvenzl"* ]]; then
  echo -e "${GREEN}✅ Test 2 Edukas: Gvenzl profiil laeti korrektselt!${NC}"
else
  echo -e "${RED}❌ Test 2 Ebaõnnestus: Gvenzl profiili parameetrid olid valed!${NC}"
  exit 1
fi

# Test 3: Enterprise Artifactory Mirror Override Test
echo -e "\n${YELLOW}[Test 3] Testin Artifactory sise-registri globaalset ülekirjutust...${NC}"
export ARTIFACTORY_DOCKER_REGISTRY="artifactory.minufirma.ee"

load_db_profile "proxy-adb-oracle"

if [[ "$RESOLVED_DB_IMAGE" == "artifactory.minufirma.ee/database/adb-free:latest" ]]; then
  echo -e "${GREEN}✅ Test 3 Edukas: Artifactory globaalne register rakendus automaatselt (${RESOLVED_DB_IMAGE})!${NC}"
else
  echo -e "${RED}❌ Test 3 Ebaõnnestus: Artifactory register ei rakendunud! Output: ${RESOLVED_DB_IMAGE}${NC}"
  unset ARTIFACTORY_DOCKER_REGISTRY
  exit 1
fi
unset ARTIFACTORY_DOCKER_REGISTRY

# Test 4: Topology Port Collision Resolver
echo -e "\n${YELLOW}[Test 4] Käivitan topoloogia ja portide konflikti lahendaja...${NC}"
source "$WORKSPACE_DIR/scripts/internal/resolve-topology.sh"
resolve_topology

if [ -n "$RESOLVED_DB_PORT" ] && [ -n "$RESOLVED_HTTPS_PORT" ]; then
  echo -e "${GREEN}✅ Test 4 Edukas: Topoloogia pordid lahendati ilma konfliktideta (DB: ${RESOLVED_DB_PORT}, HTTPS: ${RESOLVED_HTTPS_PORT})!${NC}"
else
  echo -e "${RED}❌ Test 4 Ebaõnnestus: Topoloogia portide lahendamine ebaõnnestus!${NC}"
  exit 1
fi

echo -e "\n${CYAN}==================================================================${NC}"
echo -e "${GREEN}🎉 KÕIK PROFIILIDE JA TOPOLOOGIA TESTID LÄBITUD EDUKALT!${NC}"
echo -e "${CYAN}==================================================================${NC}"
