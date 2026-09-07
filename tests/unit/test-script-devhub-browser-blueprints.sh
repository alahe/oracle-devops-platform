#!/usr/bin/env bash
# ==============================================================================
# Unit Test: tests/test-devhub-browser-blueprints.sh
# Validates Dev-Hub browser blueprints test runner syntax, options, and dry-run.
# ==============================================================================
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🧪 TEST: tests/test-devhub-browser-blueprints.sh${NC}"
TARGET_SCRIPT="$WORKSPACE_DIR/tests/test-devhub-browser-blueprints.sh"

if [ ! -f "$TARGET_SCRIPT" ]; then
  echo -e "${RED}❌ Test Failed: tests/test-devhub-browser-blueprints.sh not found!${NC}"
  exit 1
fi

# 1. BASH Syntax Check
bash -n "$TARGET_SCRIPT"
echo -e "${GREEN}  ✅ BASH syntax valid in test-devhub-browser-blueprints.sh${NC}"

# 2. CLI Options and Help Check
HELP_OUT=$("$TARGET_SCRIPT" --help 2>&1)
for flag in "--all" "--blueprint" "--min-ram" "--dry-run" "--stop-on-fail"; do
  if ! echo "$HELP_OUT" | grep -q -- "$flag"; then
    echo -e "${RED}❌ Test Failed: flag $flag missing from --help output${NC}"
    exit 1
  fi
done
echo -e "${GREEN}  ✅ CLI options and --help output verified${NC}"

# 3. Dry-Run Execution Check
DRY_OUT=$("$TARGET_SCRIPT" --dry-run 2>&1)
if ! echo "$DRY_OUT" | grep -q "DEV-HUB BROWSER TESTIMISE KOKKUVÕTE"; then
  echo -e "${RED}❌ Test Failed: dry-run execution did not complete summary block${NC}"
  exit 1
fi
echo -e "${GREEN}  ✅ Dry-run execution passed through all blueprints${NC}"

# 4. Report and Metrics Existence Check
if [ ! -f "$WORKSPACE_DIR/tests/reports/devhub_browser_blueprints_test_report.md" ]; then
  echo -e "${RED}❌ Test Failed: devhub_browser_blueprints_test_report.md was not created!${NC}"
  exit 1
fi
if [ ! -f "$WORKSPACE_DIR/metrics/devhub_browser_blueprints_benchmarks.json" ]; then
  echo -e "${RED}❌ Test Failed: devhub_browser_blueprints_benchmarks.json was not created!${NC}"
  exit 1
fi
echo -e "${GREEN}  ✅ Markdown report and JSON benchmarks generated successfully${NC}"

echo -e "${GREEN}✅ Test Passed: tests/test-devhub-browser-blueprints.sh is fully verified!${NC}"
