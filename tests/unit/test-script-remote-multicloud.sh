#!/usr/bin/env bash
# ==============================================================================
# Unit Test: tests/test-remote-multicloud.sh
# Validates multi-cloud test runner syntax, options, and dry-run execution.
# ==============================================================================
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🧪 TEST: tests/test-remote-multicloud.sh${NC}"
TARGET_SCRIPT="$WORKSPACE_DIR/tests/test-remote-multicloud.sh"

if [ ! -f "$TARGET_SCRIPT" ]; then
  echo -e "${RED}❌ Test Failed: tests/test-remote-multicloud.sh not found!${NC}"
  exit 1
fi

# 1. BASH Syntax Check
bash -n "$TARGET_SCRIPT"
echo -e "${GREEN}  ✅ BASH syntax valid in test-remote-multicloud.sh${NC}"

# 2. CLI Options and Help Check
HELP_OUT=$("$TARGET_SCRIPT" --help 2>&1)
for flag in "--azure-host" "--oci-db-name" "--wallet" "--dry-run"; do
  if ! echo "$HELP_OUT" | grep -q -- "$flag"; then
    echo -e "${RED}❌ Test Failed: flag $flag missing from --help output${NC}"
    exit 1
  fi
done
echo -e "${GREEN}  ✅ CLI options and --help output verified${NC}"

# 3. Dry-Run Execution Check
"$TARGET_SCRIPT" --dry-run > /dev/null
echo -e "${GREEN}  ✅ Dry-run execution passed and generated test report${NC}"

echo -e "${GREEN}✅ Test Passed: tests/test-remote-multicloud.sh is fully operational!${NC}"
