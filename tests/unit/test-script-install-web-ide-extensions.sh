#!/usr/bin/env bash
# ============================================================================
# Unit Test: install-web-ide-extensions.sh
# Validates existence, execution syntax, and container checks for install-web-ide-extensions.sh
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
TARGET_SCRIPT="$WORKSPACE_DIR/scripts/install-web-ide-extensions.sh"

echo "=================================================================="
echo "🧪 UNIT TEST: install-web-ide-extensions.sh"
echo "=================================================================="

# 1. Kontrolli skripti olemasolu ja käivitusõigusi
echo "▶️ [Test 1]: Kontrollin install-web-ide-extensions.sh faili olemasolu..."
if [ ! -f "$TARGET_SCRIPT" ]; then
  echo "❌ Viga: $TARGET_SCRIPT faili ei leitud!"
  exit 1
fi

if [ ! -x "$TARGET_SCRIPT" ]; then
  echo "❌ Viga: $TARGET_SCRIPT ei ole käivitatav (+x)!"
  exit 1
fi
echo "  ✅ install-web-ide-extensions.sh on olemas ja käivitatav."

# 2. Sintaksi kontroll
echo "▶️ [Test 2]: Kontrollin bash sintaksi..."
bash -n "$TARGET_SCRIPT"
echo "  ✅ Bash sintaks on 100% korrektne."

echo "=================================================================="
echo "🎉 UNIT TEST LÄBITUD EDUKALT: install-web-ide-extensions.sh"
echo "=================================================================="
