#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🧪 TEST: internal/generate-passwords.sh${NC}"
TARGET_SCRIPT="$WORKSPACE_DIR/scripts/internal/generate-passwords.sh"

if [ -f "$TARGET_SCRIPT" ]; then
  bash -n "$TARGET_SCRIPT"
  source "$TARGET_SCRIPT"
  TEST_PWD=$(gen_random_password)
  if [[ "$TEST_PWD" =~ ^[a-zA-Z0-9]{20}$ ]]; then
    echo -e "${GREEN}✅ Test Edukas: generate-passwords.sh gen_random_password vastab ADB alfanumeerilistele nõuetele! (${TEST_PWD})${NC}"
  else
    echo -e "${RED}❌ Test Ebaõnnestus: Parool pole alfanumeeriline 20-char! (${TEST_PWD})${NC}"
    exit 1
  fi
else
  echo -e "${RED}❌ Test Ebaõnnestus: scripts/internal/generate-passwords.sh puudub!${NC}"
  exit 1
fi
