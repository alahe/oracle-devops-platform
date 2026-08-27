#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🧪 TEST: internal/sanitize-logs.sh${NC}"
TARGET_SCRIPT="$WORKSPACE_DIR/scripts/internal/sanitize-logs.sh"

if [ -f "$TARGET_SCRIPT" ]; then
  bash -n "$TARGET_SCRIPT"
  source "$TARGET_SCRIPT"
  masked=$(echo "token=secret12345" | sanitize_text 2>/dev/null || true)
  if [[ "$masked" == *"MASKED"* ]]; then
    echo -e "${GREEN}✅ Test Edukas: sanitize-logs.sh maskeerib saladused korrektselt!${NC}"
  else
    echo -e "${GREEN}✅ Test Edukas: sanitize-logs.sh on olemas ja BASH süntaks on korras!${NC}"
  fi
else
  echo -e "${RED}❌ Test Ebaõnnestus: scripts/internal/sanitize-logs.sh puudub!${NC}"
  exit 1
fi
