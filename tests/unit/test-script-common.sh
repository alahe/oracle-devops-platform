#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🧪 TEST: internal/common.sh${NC}"
TARGET_SCRIPT="$WORKSPACE_DIR/scripts/internal/common.sh"

if [ -f "$TARGET_SCRIPT" ]; then
  bash -n "$TARGET_SCRIPT"
  source "$TARGET_SCRIPT"
  dur=$(format_duration 75)
  if [ "$dur" = "1m 15s" ]; then
    echo -e "${GREEN}✅ Test Edukas: common.sh on olemas, BASH süntaks on korras ja format_duration toimib!${NC}"
  else
    echo -e "${RED}❌ Test Ebaõnnestus: format_duration tagastas: $dur${NC}"
    exit 1
  fi
else
  echo -e "${RED}❌ Test Ebaõnnestus: scripts/internal/common.sh puudub!${NC}"
  exit 1
fi
