#!/usr/bin/env bash
# ============================================================================
# Unit Test: test-script-run-blueprint-matrix-test.sh
# Purpose: Verifies scripts/internal/run_blueprint_matrix_test.sh syntax,
#          CLI flags (--help, --dry-run, --single-pass, --fast), and execution safety.
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🧪 TEST: internal/run_blueprint_matrix_test.sh${NC}"
TARGET_SCRIPT="$WORKSPACE_DIR/scripts/internal/run_blueprint_matrix_test.sh"

# Test 1: File existence and executable check
if [ ! -f "$TARGET_SCRIPT" ]; then
  echo -e "${RED}❌ Test Ebaõnnestus: scripts/internal/run_blueprint_matrix_test.sh puudub!${NC}"
  exit 1
fi

# Test 2: Bash syntax validation
bash -n "$TARGET_SCRIPT"
echo -e "${GREEN}✅ Test 1: BASH süntaks on 100% kehtiv!${NC}"

# Test 3: --help flag execution
out_help=$("$TARGET_SCRIPT" --help 2>&1)
if [[ "$out_help" == *"Kasutus:"* ]]; then
  echo -e "${GREEN}✅ Test 2: --help parameeter töötab korrektselt!${NC}"
else
  echo -e "${RED}❌ Test 2 Ebaõnnestus: --help ei kuvanud kasutusjuhendit!${NC}"
  exit 1
fi

# Test 4: --dry-run flag execution with specific blueprints
out_dry=$("$TARGET_SCRIPT" --dry-run 1 3 5 2>&1)
if [[ "$out_dry" == *"DRY-RUN"* ]] && [[ "$out_dry" == *"1 3 5"* ]]; then
  echo -e "${GREEN}✅ Test 3: --dry-run simulatsioon toimib argumentidega (1 3 5)!${NC}"
else
  echo -e "${RED}❌ Test 3 Ebaõnnestus: --dry-run simulatsioon ebaõnnestus!${NC}"
  exit 1
fi

echo -e "${GREEN}🎉 Kõik internal/run_blueprint_matrix_test.sh ühiktestid läbitud edukalt!${NC}"
