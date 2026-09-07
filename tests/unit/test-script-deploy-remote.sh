#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🧪 TEST: scripts/deploy-remote.sh${NC}"
TARGET_SCRIPT="$WORKSPACE_DIR/scripts/deploy-remote.sh"

if [ -f "$TARGET_SCRIPT" ]; then
  bash -n "$TARGET_SCRIPT"
  # Run dry-run execution test
  bash "$TARGET_SCRIPT" --dry-run > /dev/null
  bash "$TARGET_SCRIPT" -b 10 -w config/oracle_db_wallet.zip --dry-run > /dev/null
  echo -e "${GREEN}✅ Test Edukas: deploy-remote.sh toetab -b/--blueprint ja -w/--wallet valikuid ning --dry-run toimib!${NC}"
else
  echo -e "${RED}❌ Test Ebaõnnestus: scripts/deploy-remote.sh puudub!${NC}"
  exit 1
fi
