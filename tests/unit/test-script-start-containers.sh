#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🧪 TEST: start-containers.sh${NC}"
TARGET_SCRIPT="$WORKSPACE_DIR/scripts/start-containers.sh"

if [ -x "$TARGET_SCRIPT" ]; then
  bash -n "$TARGET_SCRIPT"
  echo -e "${GREEN}✅ Test Edukas: start-containers.sh on olemas ja BASH süntaks on korras!${NC}"
else
  echo -e "${RED}❌ Test Ebaõnnestus: scripts/start-containers.sh puudub!${NC}"
  exit 1
fi
