#!/usr/bin/env bash
# ============================================================================
# Automated Test Script for Profile Users & Roles Applicator
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
echo -e "🧪 PROFIILI KASUTAJATE JA ROLLIDE RAKENDAJA TESTIMINE"
echo -e "${CYAN}==================================================================${NC}"

source "$WORKSPACE_DIR/scripts/internal/apply-profile-users.sh"

# Test 1: Check script existence
echo -e "\n${YELLOW}[Test 1] Kontrollin apply-profile-users.sh skripti...${NC}"
if [ -x "$WORKSPACE_DIR/scripts/internal/apply-profile-users.sh" ]; then
  echo -e "${GREEN}✅ Test 1 Edukas: apply-profile-users.sh on olemas ja käivitatav!${NC}"
else
  echo -e "${RED}❌ Test 1 Ebaõnnestus: apply-profile-users.sh puudub!${NC}"
  exit 1
fi

# Test 2: Dry-run user provisioning logic for ADB profile
echo -e "\n${YELLOW}[Test 2] Testin kasutajate ja rollide loogikat (proxy-adb-oracle)...${NC}"
if apply_profile_users "proxy-adb-oracle" >/dev/null 2>&1; then
  echo -e "${GREEN}✅ Test 2 Edukas: proxy-adb-oracle kasutajate ja rollide mootor käivitus teadete ja vigadeta!${NC}"
else
  echo -e "${RED}❌ Test 2 Ebaõnnestus: proxy-adb-oracle kasutajate mootor ebaõnnestus!${NC}"
  exit 1
fi

# Test 3: Dry-run user provisioning logic for Business App profile
echo -e "\n${YELLOW}[Test 3] Testin kasutajate ja rollide loogikat (app-free)...${NC}"
if apply_profile_users "app-free" >/dev/null 2>&1; then
  echo -e "${GREEN}✅ Test 3 Edukas: app-free kasutajate mootor käivitus edukalt!${NC}"
else
  echo -e "${RED}❌ Test 3 Ebaõnnestus: app-free kasutajate mootor ebaõnnestus!${NC}"
  exit 1
fi

echo -e "\n${CYAN}==================================================================${NC}"
echo -e "${GREEN}🎉 KÕIK KASUTAJATE JA ROLLIDE TESTID LÄBITUD EDUKALT!${NC}"
echo -e "${CYAN}==================================================================${NC}"
