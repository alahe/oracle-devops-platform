#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🧪 TEST: certs/clean-certs.sh${NC}"
TARGET_SCRIPT="$WORKSPACE_DIR/scripts/certs/clean-certs.sh"

if [ -f "$TARGET_SCRIPT" ]; then
  bash -n "$TARGET_SCRIPT"
  echo -e "${GREEN}✅ Test Edukas: clean-certs.sh on olemas ja BASH süntaks on korras!${NC}"
else
  echo -e "${RED}❌ Test Ebaõnnestus: scripts/certs/clean-certs.sh puudub!${NC}"
  exit 1
fi

# Verify CLI symlink exists
if [ -L "$WORKSPACE_DIR/scripts/clean-certs.sh" ] || [ -f "$WORKSPACE_DIR/scripts/clean-certs.sh" ]; then
  echo -e "${GREEN}✅ Test Edukas: scripts/clean-certs.sh CLI wrapper on olemas!${NC}"
else
  echo -e "${RED}❌ Test Ebaõnnestus: scripts/clean-certs.sh CLI wrapper puudub!${NC}"
  exit 1
fi

# Verify help flag runs and exits with 0
"$TARGET_SCRIPT" --help >/dev/null 2>&1
echo -e "${GREEN}✅ Test Edukas: clean-certs.sh --help töötab puhtalt!${NC}"
