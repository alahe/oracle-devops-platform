#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "▶️ [Ühikutest]: scripts/internal/init-web-ide.sh"
if [ ! -f "$WORKSPACE_DIR/scripts/internal/init-web-ide.sh" ]; then
  echo "❌ Viga: init-web-ide.sh puudub!"
  exit 1
fi

OUT=$("$WORKSPACE_DIR/scripts/internal/init-web-ide.sh")
if ! echo "$OUT" | grep -q "INITIALIZING CONTAINERIZED WEB IDE"; then
  echo "❌ Viga: init-web-ide.sh ebaõnnestus!"
  exit 1
fi

echo "  ✅ init-web-ide.sh ühikutest edukas."
