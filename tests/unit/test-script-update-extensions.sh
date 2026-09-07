#!/usr/bin/env bash
# ==============================================================================
# Unit Test: scripts/update-extensions.sh
# Validates VS Code & extensions version management, JSON output and status checks.
# ==============================================================================

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🧪 TEST: scripts/update-extensions.sh (VS Code Version Manager)${NC}"
TARGET_SCRIPT="$WORKSPACE_DIR/scripts/update-extensions.sh"

if [ ! -f "$TARGET_SCRIPT" ]; then
  echo -e "${RED}❌ Test Ebaõnnestus: scripts/update-extensions.sh puudub!${NC}"
  exit 1
fi

# 1. BASH Syntax Check
bash -n "$TARGET_SCRIPT"
echo -e "${GREEN}  ✅ BASH syntax valid in update-extensions.sh${NC}"

# 2. Help Flag Execution
HELP_OUT=$("$TARGET_SCRIPT" --help 2>&1)
if [[ "$HELP_OUT" == *"Usage:"* ]]; then
  echo -e "${GREEN}  ✅ CLI --help output verified.${NC}"
else
  echo -e "${RED}  ❌ CLI --help output failed.${NC}"
  exit 1
fi

# 3. Check Mode Execution and JSON Metrics Generation
"$TARGET_SCRIPT" --check >/dev/null 2>&1 || true
STATUS_JSON="$WORKSPACE_DIR/metrics/extensions_status.json"

if [ -f "$STATUS_JSON" ]; then
  TOTAL_EXT=$(jq -r '.total_extensions // 0' "$STATUS_JSON" 2>/dev/null || echo "0")
  if [ "$TOTAL_EXT" -ge 5 ]; then
    echo -e "${GREEN}  ✅ metrics/extensions_status.json generated with $TOTAL_EXT extensions.${NC}"
  else
    echo -e "${RED}  ❌ metrics/extensions_status.json has invalid extension count ($TOTAL_EXT).${NC}"
    exit 1
  fi
else
  echo -e "${RED}  ❌ metrics/extensions_status.json was not created.${NC}"
  exit 1
fi

# 4. JSON Mode Check
JSON_OUT=$("$TARGET_SCRIPT" --json 2>/dev/null || true)
if echo "$JSON_OUT" | jq . >/dev/null 2>&1; then
  echo -e "${GREEN}  ✅ --json flag returns valid parseable JSON output.${NC}"
else
  echo -e "${RED}  ❌ --json flag returned invalid JSON.${NC}"
  exit 1
fi

echo -e "${GREEN}🎉 TEST PASSED: scripts/update-extensions.sh verified successfully!${NC}"
