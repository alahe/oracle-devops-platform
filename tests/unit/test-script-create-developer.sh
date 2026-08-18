#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🧪 TEST: internal/create-developer.sh${NC}"
TARGET_SCRIPT="$WORKSPACE_DIR/scripts/internal/create-developer.sh"

if [ -f "$TARGET_SCRIPT" ]; then
  bash -n "$TARGET_SCRIPT"
  if grep -q "DB_DEVELOPER_ROLE" "$TARGET_SCRIPT"; then
    echo -e "${GREEN}✅ Test Edukas: create-developer.sh on olemas, süntaks korras ja sisaldab DB_DEVELOPER_ROLE rolli!${NC}"
  else
    echo -e "${RED}❌ Test Ebaõnnestus: DB_DEVELOPER_ROLE puudub skriptist!${NC}"
    exit 1
  fi
else
  echo -e "${RED}❌ Test Ebaõnnestus: scripts/internal/create-developer.sh puudub!${NC}"
  exit 1
fi
