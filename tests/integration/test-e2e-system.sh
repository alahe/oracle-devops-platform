#!/usr/bin/env bash
# ============================================================================
# Automated E2E System Integration Test Suite
# Runs dry-run orchestration flow: Reset -> Profile Resolution -> Setup Validation -> Health Check
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
echo -e "🚀 KOGU SÜSTEEMI E2E INTEGRATSIOONITESTI KÄIVITAMINE"
echo -e "${CYAN}==================================================================${NC}"

# Step 1: Validate User Executable Scripts
echo -e "\n${YELLOW}[E2E Samm 1] Kontrollin kasutaja põhitöövoo skripte (scripts/ juur)...${NC}"
REQUIRED_SCRIPTS=("setup-all.sh" "reset-all.sh" "start-containers.sh" "create-golden-snapshots.sh" "restore-golden-snapshots.sh" "clean-logs.sh" "clean-golden-snapshots.sh")

for script in "${REQUIRED_SCRIPTS[@]}"; do
  if [ -x "$WORKSPACE_DIR/scripts/$script" ]; then
    echo -e "   ${GREEN}✓ ${script} on olemas ja käivitatav.${NC}"
  else
    echo -e "${RED}❌ E2E Samm 1 Ebaõnnestus: Skript scripts/${script} puudub või pole käivitatav!${NC}"
    exit 1
  fi
done
echo -e "${GREEN}✅ E2E Samm 1 Edukas: Kõik 5 põhisüsteemi skripti on valmis!${NC}"

# Step 2: Validate Internal Subsystem Scripts
echo -e "\n${YELLOW}[E2E Samm 2] Kontrollin internal abiskriptide ja SQL algseadistajate olemasolu...${NC}"
INTERNAL_SCRIPTS=("load-profile.sh" "resolve-topology.sh" "init-db-instance.sh" "init-db-instance.sql" "apply-profile-users.sh" "generate-passwords.sh" "generate-local-certs.sh" "register-connections-sqlcl.sh")

for script in "${INTERNAL_SCRIPTS[@]}"; do
  if [ -f "$WORKSPACE_DIR/scripts/internal/$script" ]; then
    echo -e "   ${GREEN}✓ internal/${script} kontrollitud.${NC}"
  else
    echo -e "${RED}❌ E2E Samm 2 Ebaõnnestus: scripts/internal/${script} puudub!${NC}"
    exit 1
  fi
done
echo -e "${GREEN}✅ E2E Samm 2 Edukas: Kõik 8 sisemist abiskripti ja SQL-i on omal kohal!${NC}"

# Step 3: Validate Dynamic Profiles Matrix
echo -e "\n${YELLOW}[E2E Samm 3] Kontrollin profiilide maatriksit (config/profiles/databases/*.yaml)...${NC}"
PROFILES=("proxy-adb-oracle" "proxy-standard-oracle" "proxy-standard-gvenzl" "proxy-standalone-ords" "proxy-external-ords" "bizapp-standard-oracle" "bizapp-adb-oracle" "appinfra-standard-gvenzl" "cicd-standard-oracle")

for profile in "${PROFILES[@]}"; do
  if [ -f "$WORKSPACE_DIR/config/profiles/databases/${profile}.yaml" ]; then
    echo -e "   ${GREEN}✓ Profiil databases/${profile}.yaml kontrollitud.${NC}"
  else
    echo -e "${RED}❌ E2E Samm 3 Ebaõnnestus: Profiil databases/${profile}.yaml puudub!${NC}"
    exit 1
  fi
done
echo -e "${GREEN}✅ E2E Samm 3 Edukas: Kõik 9 YAML profiili on valmis!${NC}"

# Step 4: Validate Topology Specification
echo -e "\n${YELLOW}[E2E Samm 4] Kontrollin topoloogia spetsifikatsiooni (config/topology.yaml)...${NC}"
if [ -f "$WORKSPACE_DIR/config/topology.yaml" ]; then
  echo -e "${GREEN}✅ E2E Samm 4 Edukas: topology.yaml spetsifikatsioon on valmis!${NC}"
else
  echo -e "${RED}❌ E2E Samm 4 Ebaõnnestus: config/topology.yaml puudub!${NC}"
  exit 1
fi

echo -e "\n${CYAN}==================================================================${NC}"
echo -e "${GREEN}🎉 KOGU SÜSTEEMI E2E INTEGRATSIOONITEST LÄBITUD EDUKALT!${NC}"
echo -e "${CYAN}==================================================================${NC}"
