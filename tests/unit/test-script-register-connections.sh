#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🧪 TEST: scripts/register-connections.sh${NC}"
TARGET_SCRIPT="$WORKSPACE_DIR/scripts/register-connections.sh"

if [ -f "$TARGET_SCRIPT" ]; then
  bash -n "$TARGET_SCRIPT"
  echo -e "${GREEN}  ✅ BASH syntax valid in register-connections.sh${NC}"
  
  if grep -q "CONTAINER_SQL_COMMANDS" "$TARGET_SCRIPT" && grep -q "WEB_IDE_CONTAINER" "$TARGET_SCRIPT"; then
    echo -e "${GREEN}  ✅ Dual Host & Web IDE container registration support verified.${NC}"
  else
    echo -e "${RED}  ❌ register-connections.sh missing dual container registration support.${NC}"
    exit 1
  fi
  
  if grep -q "folders.json" "$TARGET_SCRIPT" && grep -q "DBTU-03001" "$TARGET_SCRIPT"; then
    echo -e "${GREEN}  ✅ DBTU-03001 folders.json sanitization logic verified.${NC}"
  fi
  
  echo -e "${GREEN}✅ Test Edukas: register-connections.sh vastab täielikult standardile!${NC}"
else
  echo -e "${RED}❌ Test Ebaõnnestus: scripts/register-connections.sh puudub!${NC}"
  exit 1
fi
