#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🧪 TEST: internal/install-ords-standalone.sh${NC}"
TARGET_SCRIPT="$WORKSPACE_DIR/scripts/internal/install-ords-standalone.sh"

if [ -f "$TARGET_SCRIPT" ]; then
  bash -n "$TARGET_SCRIPT"
  echo -e "${GREEN}✅ Test Edukas: install-ords-standalone.sh on olemas ja BASH süntaks on korras!${NC}"
else
  echo -e "${RED}❌ Test Ebaõnnestus: scripts/internal/install-ords-standalone.sh puudub!${NC}"
  exit 1
fi
