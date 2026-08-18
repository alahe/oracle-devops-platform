#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🧪 TEST: clean-logs.sh${NC}"
TARGET_SCRIPT="$WORKSPACE_DIR/scripts/clean-logs.sh"

if [ -x "$TARGET_SCRIPT" ]; then
  bash -n "$TARGET_SCRIPT"
  echo -e "${GREEN}✅ Test Edukas: clean-logs.sh on olemas ja BASH süntaks on korras!${NC}"
else
  echo -e "${RED}❌ Test Ebaõnnestus: scripts/clean-logs.sh puudub!${NC}"
  exit 1
fi
