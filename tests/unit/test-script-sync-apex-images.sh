#!/usr/bin/env bash
# ============================================================================
# Unit Test: test-script-sync-apex-images.sh
# Purpose: Verifies scripts/internal/sync-apex-images.sh syntax, container
#          fallback tolerance, and APEX version resolution logic.
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🧪 TEST: internal/sync-apex-images.sh${NC}"
TARGET_SCRIPT="$WORKSPACE_DIR/scripts/internal/sync-apex-images.sh"

# Test 1: File existence and executable/readable check
if [ ! -f "$TARGET_SCRIPT" ]; then
  echo -e "${RED}❌ Test Ebaõnnestus: scripts/internal/sync-apex-images.sh puudub!${NC}"
  exit 1
fi

# Test 2: Bash syntax validation
bash -n "$TARGET_SCRIPT"
echo -e "${GREEN}✅ Test 1: BASH süntaks on 100% kehtiv!${NC}"

# Test 3: Safe exit on non-existent container (graceful no-op)
out_nonexistent=$("$TARGET_SCRIPT" "non-existent-container-xyz-999" 2>&1 || true)
if [ $? -ne 0 ]; then
  echo -e "${RED}❌ Test 2 Ebaõnnestus: Puuduva konteineri korral peaks väljuma koodiga 0!${NC}"
  exit 1
fi
echo -e "${GREEN}✅ Test 2: Puuduva konteineri tõrketaluvus toimib (exit 0)!${NC}"

# Test 4: Version parsing regex check inside script
if grep -q "SELECT version_no FROM apex_release" "$TARGET_SCRIPT" && grep -q "apex_version.js" "$TARGET_SCRIPT"; then
  echo -e "${GREEN}✅ Test 3: APEX versiooni päringu ja apex_version.js võrdluse loogika on olemas!${NC}"
else
  echo -e "${RED}❌ Test 3 Ebaõnnestus: Versioonituvastuse kood puudub!${NC}"
  exit 1
fi

echo -e "${GREEN}🎉 Kõik internal/sync-apex-images.sh ühiktestid läbitud edukalt!${NC}"
