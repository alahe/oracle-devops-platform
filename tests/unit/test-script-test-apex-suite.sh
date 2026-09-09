#!/usr/bin/env bash
# ============================================================================
# Unit Test: test-script-test-apex-suite.sh
# Purpose: Verifies test-apex-suite.sh syntax, CLI flags (--help, --tier, --fast),
#          and ensures 100% parity between scripts/ and tests/ locations.
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🧪 TEST: test-apex-suite.sh${NC}"
TESTS_SCRIPT="$WORKSPACE_DIR/tests/test-apex-suite.sh"
SCRIPTS_SCRIPT="$WORKSPACE_DIR/scripts/test-apex-suite.sh"

# Test 1: File existence checks
if [ ! -f "$TESTS_SCRIPT" ]; then
  echo -e "${RED}❌ Test Ebaõnnestus: tests/test-apex-suite.sh puudub!${NC}"
  exit 1
fi
if [ ! -f "$SCRIPTS_SCRIPT" ]; then
  echo -e "${RED}❌ Test Ebaõnnestus: scripts/test-apex-suite.sh puudub!${NC}"
  exit 1
fi

# Test 2: Bash syntax validation
bash -n "$TESTS_SCRIPT"
bash -n "$SCRIPTS_SCRIPT"
echo -e "${GREEN}✅ Test 1: Mõlema skripti BASH süntaks on 100% kehtiv!${NC}"

# Test 3: Ensure 1:1 file parity between tests/ and scripts/ copies
if diff -q "$TESTS_SCRIPT" "$SCRIPTS_SCRIPT" >/dev/null; then
  echo -e "${GREEN}✅ Test 2: tests/ ja scripts/ koopiad on 100% identsed!${NC}"
else
  echo -e "${RED}❌ Test 2 Ebaõnnestus: tests/test-apex-suite.sh ja scripts/test-apex-suite.sh erinevad teineteisest!${NC}"
  diff -u "$TESTS_SCRIPT" "$SCRIPTS_SCRIPT" || true
  exit 1
fi

# Test 4: --help flag execution
out_help=$("$TESTS_SCRIPT" --help 2>&1)
if [[ "$out_help" == *"Kasutus:"* ]] && [[ "$out_help" == *"--tier"* ]]; then
  echo -e "${GREEN}✅ Test 3: --help kuvab korrektselt APEX testi tasemed (--tier db|rest|e2e|advisor|all)!${NC}"
else
  echo -e "${RED}❌ Test 3 Ebaõnnestus: --help ei kuvanud oodatud parameetreid!${NC}"
  exit 1
fi

# Test 5: Unknown parameter error handling
set +e
out_err=$("$TESTS_SCRIPT" --invalid-flag-xyz 2>&1)
code_err=$?
set -e
if [ $code_err -ne 0 ]; then
  echo -e "${GREEN}✅ Test 4: Tundmatu parameeter püüti kinni ja väljuti veakoodiga ($code_err)!${NC}"
else
  echo -e "${RED}❌ Test 4 Ebaõnnestus: Tundmatu parameeter ei tagastanud viga!${NC}"
  exit 1
fi

echo -e "${GREEN}🎉 Kõik test-apex-suite.sh ühiktestid läbitud edukalt!${NC}"
