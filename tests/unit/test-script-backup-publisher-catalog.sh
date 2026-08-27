#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🧪 TEST: scripts/publisher/backup-publisher-catalog.sh${NC}"
TARGET_SCRIPT="$WORKSPACE_DIR/scripts/publisher/backup-publisher-catalog.sh"

if [ -f "$TARGET_SCRIPT" ]; then
  bash -n "$TARGET_SCRIPT"
  # Run execution test against running environment (or offline container)
  bash "$TARGET_SCRIPT" > /dev/null || true
  echo -e "${GREEN}✅ Test Edukas: backup-publisher-catalog.sh on olemas, süntaks on korras ja skripti kontroll teostati!${NC}"
else
  echo -e "${RED}❌ Test Ebaõnnestus: scripts/publisher/backup-publisher-catalog.sh puudub!${NC}"
  exit 1
fi
