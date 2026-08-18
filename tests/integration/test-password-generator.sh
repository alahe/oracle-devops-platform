#!/usr/bin/env bash
# ============================================================================
# Automated Test Script for Pure Alphanumeric Password Generator Engine
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
echo -e "🧪 PAROOLIGENERAATORI (gen_random_password) NÕUETE TESTIMINE"
echo -e "${CYAN}==================================================================${NC}"

# Source generate-passwords.sh helper function
source "$WORKSPACE_DIR/scripts/internal/generate-passwords.sh" --force >/dev/null 2>&1 || true

# Test 1: Generate single password and verify format
echo -e "\n${YELLOW}[Test 1] Testin gen_random_password funktsiooni väljundit...${NC}"
TEST_PWD=$(gen_random_password)
echo "   Näidisparool: ${TEST_PWD}"

if [[ "$TEST_PWD" =~ ^[a-zA-Z0-9]{20}$ ]]; then
  echo -e "${GREEN}✅ Test 1 Edukas: Parool on puhtalt alfanumeeriline ja täpselt 20 tähemärki pikkm (${TEST_PWD})!${NC}"
else
  echo -e "${RED}❌ Test 1 Ebaõnnestus: Parool sisaldas keelatud sümboleid või oli vale pikkusega! (${TEST_PWD})${NC}"
  exit 1
fi

# Test 2: Stress test 50 password generations for Oracle ADB regex compliance
echo -e "\n${YELLOW}[Test 2] Jooksutan 50 parooli automaatset vastavuskontrolli (ADB Regex)...${NC}"
SUCCESS_COUNT=0
for i in {1..50}; do
  PWD=$(gen_random_password)
  
  # Must be pure alphanumeric (A-Z, a-z, 0-9), length 20, containing upper, lower, and number
  if [[ "$PWD" =~ ^[a-zA-Z0-9]{20}$ ]] && [[ "$PWD" =~ [A-Z] ]] && [[ "$PWD" =~ [a-z] ]] && [[ "$PWD" =~ [0-9] ]]; then
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
  else
    echo -e "${RED}❌ Ebaõnnestus parooliga: ${PWD}${NC}"
    exit 1
  fi
done

echo -e "${GREEN}✅ Test 2 Edukas: Kõik ${SUCCESS_COUNT}/50 parooli vastasid 100% Oracle ADB nõuetele (Alphanumeric 20-char)!${NC}"

echo -e "\n${CYAN}==================================================================${NC}"
echo -e "${GREEN}🎉 KÕIK PAROOLIGENERAATORI TESTID LÄBITUD EDUKALT!${NC}"
echo -e "${CYAN}==================================================================${NC}"
