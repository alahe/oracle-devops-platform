#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🧪 TEST: internal/init-db-instance.sh${NC}"
TARGET_SCRIPT="$WORKSPACE_DIR/scripts/internal/init-db-instance.sh"

if [ -f "$TARGET_SCRIPT" ]; then
  bash -n "$TARGET_SCRIPT"
  source "$TARGET_SCRIPT"
  init_db_instance "proxy-adb-oracle" "oracle-db-apex-proxy" >/dev/null 2>&1 || true
  echo -e "${GREEN}✅ Test Edukas: init-db-instance.sh on olemas ja BASH süntaks on korras!${NC}"
else
  echo -e "${RED}❌ Test Ebaõnnestus: scripts/internal/init-db-instance.sh puudub!${NC}"
  exit 1
fi
