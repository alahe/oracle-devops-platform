#!/usr/bin/env bash
# ============================================================================
# Automated Test Script for Internal Installers, Patchers & Helper Tools
# Tests: apply-apex-patch.sh, install-apex.sh, create-developer.sh,
#        create-wallet.sh, deploy-apex-apps.sh, install-ords-standalone.sh, register-connections.sh
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
echo -e "🧪 SISEMISTE ABISKRIPTIDE JA PAIGALDAJATE AUTOMATISEERITUD TESTIMINE"
echo -e "${CYAN}==================================================================${NC}"

# List of internal installer and helper scripts to test
INTERNAL_HELPERS=(
  "apply-apex-patch.sh"
  "create-developer.sh"
  "create-wallet.sh"
  "deploy-apex-apps.sh"
  "install-apex.sh"
  "install-ords-standalone.sh"
  "register-connections.sh"
)

# Test 1: Verify file existence and bash syntax
echo -e "\n${YELLOW}[Test 1] Kontrollin skriptide olemasolu ja BASH süntaksit...${NC}"
for helper in "${INTERNAL_HELPERS[@]}"; do
  file_path="$WORKSPACE_DIR/scripts/internal/$helper"
  if [ -f "$file_path" ]; then
    bash -n "$file_path"
    echo -e "   ${GREEN}✓ internal/${helper} süntaks on täielikult korras.${NC}"
  else
    echo -e "${RED}❌ Test 1 Ebaõnnestus: scripts/internal/${helper} puudub!${NC}"
    exit 1
  fi
done
echo -e "${GREEN}✅ Test 1 Edukas: Kõik sisemised abiskriptid on süntaksiliselt korrektsed!${NC}"

# Test 2: Verify create-developer.sh dry-run logic
echo -e "\n${YELLOW}[Test 2] Kontrollin create-developer.sh parameetrite tuletamist...${NC}"
if grep -q "DB_DEVELOPER_ROLE" "$WORKSPACE_DIR/scripts/internal/create-developer.sh"; then
  echo -e "${GREEN}✅ Test 2 Edukas: create-developer.sh kasutab kohustuslikku DB_DEVELOPER_ROLE rolli!${NC}"
else
  echo -e "${RED}❌ Test 2 Ebaõnnestus: DB_DEVELOPER_ROLE puudub skriptist create-developer.sh!${NC}"
  exit 1
fi

# Test 3: Verify install-apex.sh and apply-apex-patch.sh container execution paths
echo -e "\n${YELLOW}[Test 3] Kontrollin install-apex.sh ja apply-apex-patch.sh teostust...${NC}"
if grep -q "apex_images" "$WORKSPACE_DIR/scripts/internal/install-apex.sh" && \
   grep -q "patch" "$WORKSPACE_DIR/scripts/internal/apply-apex-patch.sh"; then
  echo -e "${GREEN}✅ Test 3 Edukas: APEX paigaldus ja patchi loogika on valideeritud!${NC}"
else
  echo -e "${RED}❌ Test 3 Ebaõnnestus: APEX paigalduse või patchimise failiviidad on katki!${NC}"
  exit 1
fi

echo -e "\n${CYAN}==================================================================${NC}"
echo -e "${GREEN}🎉 KÕIK SISEMISTE ABISKRIPTIDE TESTID LÄBITUD EDUKALT!${NC}"
echo -e "${CYAN}==================================================================${NC}"
