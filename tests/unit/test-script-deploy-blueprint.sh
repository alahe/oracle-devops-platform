#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🧪 TEST: deploy-blueprint.sh${NC}"
TARGET_SCRIPT="$WORKSPACE_DIR/scripts/deploy-blueprint.sh"

if [ -x "$TARGET_SCRIPT" ]; then
  bash -n "$TARGET_SCRIPT"
  
  # Test --list execution
  "$TARGET_SCRIPT" --list >/dev/null
  
  # Test --status execution
  "$TARGET_SCRIPT" --status >/dev/null
  
  # Test --dry-run for Blueprint 3
  "$TARGET_SCRIPT" -b 3 --dry-run >/dev/null
  
  echo -e "${GREEN}✅ Test Edukas: deploy-blueprint.sh on olemas, BASH süntaks on korras ja --list/--status/--dry-run toimivad!${NC}"
else
  echo -e "${RED}❌ Test Ebaõnnestus: scripts/deploy-blueprint.sh puudub või pole käivitatav!${NC}"
  exit 1
fi
