#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🧪 TEST: scripts/publisher/deploy-publisher-reports.sh${NC}"
TARGET_SCRIPT="$WORKSPACE_DIR/scripts/publisher/deploy-publisher-reports.sh"

if [ -f "$TARGET_SCRIPT" ]; then
  bash -n "$TARGET_SCRIPT"
  # Run execution test
  bash "$TARGET_SCRIPT" > /dev/null
  echo -e "${GREEN}✅ Test Edukas: deploy-publisher-reports.sh on olemas, süntaks on korras ja aruannete paigaldus teostati ilma vigadeta!${NC}"
else
  echo -e "${RED}❌ Test Ebaõnnestus: scripts/publisher/deploy-publisher-reports.sh puudub!${NC}"
  exit 1
fi
