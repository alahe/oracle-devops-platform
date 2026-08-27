#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🧪 TEST: scripts/internal/test-publisher-ds.sh${NC}"
TARGET_SCRIPT="$WORKSPACE_DIR/scripts/internal/test-publisher-ds.sh"

if [ -f "$TARGET_SCRIPT" ]; then
  bash -n "$TARGET_SCRIPT"
  # Run execution test against running environment
  bash "$TARGET_SCRIPT" > /dev/null
  echo -e "${GREEN}✅ Test Edukas: test-publisher-ds.sh on olemas, süntaks on korras ja andmebaasi kontroll teostati ilma vigadeta!${NC}"
else
  echo -e "${RED}❌ Test Ebaõnnestus: scripts/internal/test-publisher-ds.sh puudub!${NC}"
  exit 1
fi
