#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🧪 TEST: restore-golden-snapshots.sh${NC}"
TARGET_SCRIPT="$WORKSPACE_DIR/scripts/snapshots/restore-golden-snapshots.sh"

if [ -x "$TARGET_SCRIPT" ]; then
  bash -n "$TARGET_SCRIPT"
  help_out=$("$TARGET_SCRIPT" --help)
  if echo "$help_out" | grep -q -- "--name"; then
    echo -e "${GREEN}  ✓ restore-golden-snapshots.sh toetab --name parameetrit ja BASH süntaks on korras${NC}"
  else
    echo -e "${RED}❌ Test Ebaõnnestus: --name puudub restore-golden-snapshots.sh abitekstist!${NC}"
    exit 1
  fi

  # Verify start and finish timestamp output in dry-run mode
  dry_out=$("$TARGET_SCRIPT" --dry-run --force)
  if echo "$dry_out" | grep -q "Started at" && echo "$dry_out" | grep -q "Finished at"; then
    echo -e "${GREEN}  ✓ restore-golden-snapshots.sh väljastab korrektselt algusaja ja lõpuaja${NC}"
  else
    echo -e "${RED}❌ Test Ebaõnnestus: restore-golden-snapshots.sh ei väljastanud algusaega või lõpuaega!${NC}"
    exit 1
  fi
  echo -e "${GREEN}✅ Test Edukas: restore-golden-snapshots.sh kõik testid läbitud!${NC}"
else
  echo -e "${RED}❌ Test Ebaõnnestus: scripts/snapshots/restore-golden-snapshots.sh puudub!${NC}"
  exit 1
fi
