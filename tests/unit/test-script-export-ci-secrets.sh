#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "▶️ [Ühikutest]: scripts/internal/export-ci-secrets.sh"
if [ ! -f "$WORKSPACE_DIR/scripts/internal/export-ci-secrets.sh" ]; then
  echo "❌ Viga: export-ci-secrets.sh puudub!"
  exit 1
fi

OUT=$("$WORKSPACE_DIR/scripts/internal/export-ci-secrets.sh")
if ! echo "$OUT" | grep -qiE "SEPS Wallet (edukalt pakitud|compressed and converted)"; then
  echo "❌ Viga: export-ci-secrets.sh ebaõnnestus!"
  exit 1
fi

echo "  ✅ export-ci-secrets.sh ühikutest edukas."
