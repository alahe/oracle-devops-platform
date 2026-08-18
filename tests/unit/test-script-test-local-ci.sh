#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "▶️ [Ühikutest]: scripts/test-local-ci.sh"
if [ ! -f "$WORKSPACE_DIR/scripts/test-local-ci.sh" ]; then
  echo "❌ Viga: test-local-ci.sh puudub!"
  exit 1
fi

OUT=$("$WORKSPACE_DIR/scripts/test-local-ci.sh" --dry-run)
if ! echo "$OUT" | grep -q "LOKAALNE CI/CD TEST EDUKALT LÕPETATUD"; then
  echo "❌ Viga: test-local-ci.sh --dry-run ebaõnnestus!"
  exit 1
fi

echo "  ✅ test-local-ci.sh ühikutest edukas."
