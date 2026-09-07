#!/usr/bin/env bash
# ==============================================================================
# Unit Test: tests/test-all-blueprints-live.sh
# Validates master blueprint live test runner syntax, help, options, and dry-run.
# ==============================================================================

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🧪 TEST: tests/test-all-blueprints-live.sh${NC}"
TARGET_SCRIPT="$WORKSPACE_DIR/tests/test-all-blueprints-live.sh"

if [ ! -f "$TARGET_SCRIPT" ]; then
  echo -e "${RED}❌ Test Failed: tests/test-all-blueprints-live.sh not found!${NC}"
  exit 1
fi

# 1. BASH Syntax Check
bash -n "$TARGET_SCRIPT"
echo -e "${GREEN}  ✅ BASH syntax valid in test-all-blueprints-live.sh${NC}"

# 2. CLI Options and Help Check
HELP_OUT=$("$TARGET_SCRIPT" --help 2>&1)
if [[ "$HELP_OUT" == *"Usage:"* ]] && [[ "$HELP_OUT" == *"--group"* ]]; then
  echo -e "${GREEN}  ✅ CLI --help and option flags verified.${NC}"
else
  echo -e "${RED}  ❌ CLI --help output invalid.${NC}"
  exit 1
fi

# 3. Dry Run Single Blueprint Check
DRY_OUT=$("$TARGET_SCRIPT" -b 4 --dry-run 2>&1)
if [[ "$DRY_OUT" == *"PASS: Blueprint 4"* ]]; then
  echo -e "${GREEN}  ✅ Single blueprint dry-run assertion verified.${NC}"
else
  echo -e "${RED}  ❌ Single blueprint dry-run failed.${NC}"
  exit 1
fi

# 4. Dry Run Group Check
GROUP_OUT=$("$TARGET_SCRIPT" --group 2 --dry-run 2>&1)
if [[ "$GROUP_OUT" == *"PASS: Blueprint 5"* ]]; then
  echo -e "${GREEN}  ✅ Group 2 dry-run assertions verified.${NC}"
else
  echo -e "${RED}  ❌ Group dry-run failed.${NC}"
  exit 1
fi

# 5. Metrics & Markdown Report Generation Check
if [ -f "$WORKSPACE_DIR/metrics/blueprint_live_test_results.json" ] && [ -f "$WORKSPACE_DIR/tests/reports/blueprints_live_test_report.md" ]; then
  echo -e "${GREEN}  ✅ Metrics JSON and Markdown report outputs verified.${NC}"
else
  echo -e "${RED}  ❌ Metrics or report file missing.${NC}"
  exit 1
fi

echo -e "${GREEN}🎉 TEST PASSED: tests/test-all-blueprints-live.sh verified successfully!${NC}"
