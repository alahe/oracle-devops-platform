#!/usr/bin/env bash
# ============================================================================
# Unit Test: test-standalone-ords-emulation.sh
# Validates script existence, execution permissions, and syntax
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
TARGET_SCRIPT="$WORKSPACE_DIR/scripts/test-standalone-ords-emulation.sh"

echo "=================================================================="
echo "🧪 UNIT TEST: test-standalone-ords-emulation.sh"
echo "=================================================================="

# 1. Check File Existence & Permissions
echo "▶️ [Test 1]: Kontrollin test-standalone-ords-emulation.sh faili..."
if [ ! -f "$TARGET_SCRIPT" ]; then
  echo "❌ Viga: $TARGET_SCRIPT faili ei leitud!"
  exit 1
fi

if [ ! -x "$TARGET_SCRIPT" ]; then
  echo "❌ Viga: $TARGET_SCRIPT ei ole käivitatav (+x)!"
  exit 1
fi
echo "  ✅ test-standalone-ords-emulation.sh on olemas ja käivitatav."

# 2. Syntax Check
echo "▶️ [Test 2]: Kontrollin bash sintaksi..."
bash -n "$TARGET_SCRIPT"
echo "  ✅ Bash sintaks on 100% korrektne."

echo "=================================================================="
echo "🎉 UNIT TEST LÄBITUD EDUKALT: test-standalone-ords-emulation.sh"
echo "=================================================================="
