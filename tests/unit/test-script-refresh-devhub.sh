#!/usr/bin/env bash
# ==============================================================================
# Unit Test: scripts/refresh-devhub.sh
# Verifies script existence, executable permissions, bash syntax, and --help flag
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🧪 TEST: refresh-devhub.sh${NC}"
TARGET_SCRIPT="$WORKSPACE_DIR/scripts/refresh-devhub.sh"

if [ ! -f "$TARGET_SCRIPT" ]; then
  echo -e "${RED}❌ Test Ebaõnnestus: scripts/refresh-devhub.sh puudub!${NC}"
  exit 1
fi

if [ ! -x "$TARGET_SCRIPT" ]; then
  echo -e "${RED}❌ Test Ebaõnnestus: scripts/refresh-devhub.sh ei ole käivitatav!${NC}"
  exit 1
fi

# 1. Syntax check
bash -n "$TARGET_SCRIPT"
echo -e "   ${GREEN}✓ BASH süntaks kontrollitud ja kehtiv.${NC}"

# 2. Help execution check
HELP_OUTPUT="$("$TARGET_SCRIPT" --help)"
if [[ "$HELP_OUTPUT" != *"Chrome Dev Hub Hard-Refresh Tool"* ]]; then
  echo -e "${RED}❌ Test Ebaõnnestus: --help väljund ei vasta ootustele!${NC}"
  exit 1
fi
echo -e "   ${GREEN}✓ --help väljund kontrollitud ja kehtiv.${NC}"

# 3. Rule 13 Portability check: ASCII characters only in filename
if [[ "$TARGET_SCRIPT" =~ [^a-zA-Z0-9._/-] ]]; then
  echo -e "${RED}❌ Test Ebaõnnestus: Failinimi sisaldab keelatud sümboleid!${NC}"
  exit 1
fi
echo -e "   ${GREEN}✓ Rule 13 failinime porditavus kontrollitud.${NC}"

echo -e "${GREEN}✅ Test Edukas: scripts/refresh-devhub.sh on 100% valmis ja nõuetele vastav!${NC}"
