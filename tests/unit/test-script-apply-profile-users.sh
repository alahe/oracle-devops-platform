#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🧪 TEST: internal/apply-profile-users.sh${NC}"
TARGET_SCRIPT="$WORKSPACE_DIR/scripts/internal/apply-profile-users.sh"

if [ -f "$TARGET_SCRIPT" ]; then
  bash -n "$TARGET_SCRIPT"
  source "$TARGET_SCRIPT"
  apply_profile_users "proxy-adb-oracle" >/dev/null 2>&1 || true
  echo -e "${GREEN}✅ Test Edukas: apply-profile-users.sh on olemas ja BASH süntaks on korras!${NC}"
else
  echo -e "${RED}❌ Test Ebaõnnestus: scripts/internal/apply-profile-users.sh puudub!${NC}"
  exit 1
fi
