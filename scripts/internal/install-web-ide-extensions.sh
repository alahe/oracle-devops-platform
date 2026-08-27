#!/usr/bin/env bash
# ============================================================================
# Web IDE Extensions Installer Script
# Downloads and installs VS Code extensions (Oracle SQL Developer, GitHub Actions, VSIX)
# Usage: ./scripts/install-web-ide-extensions.sh
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
EXT_DIR="$WORKSPACE_DIR/binaries/extensions"
mkdir -p "$EXT_DIR"

WEB_IDE_CONTAINER="${WEB_IDE_CONTAINER_NAME:-web-ide-dev}"

echo "=================================================================="
echo "📦 VS CODE LAIENDUSTE PAIGALDAMINE WEB IDE-SSE"
echo "=================================================================="

if ! podman container exists "$WEB_IDE_CONTAINER" 2>/dev/null; then
  echo "⚠️  Web IDE konteiner '$WEB_IDE_CONTAINER' ei jookse."
  echo "🚀 Käivitan Web IDE konteineri..."
  "$SCRIPT_DIR/start-containers.sh"
fi

if [ "$(podman inspect --format='{{.State.Status}}' "$WEB_IDE_CONTAINER" 2>/dev/null)" != "running" ]; then
  echo "🚀 Käivitan konteineri $WEB_IDE_CONTAINER..."
  podman start "$WEB_IDE_CONTAINER" >/dev/null 2>&1 || true
fi

echo "📦 Paigaldan kontrollitud laiendused Web IDE konteinerisse..."

CODE_SERVER_BIN="/app/code-server/bin/code-server"

# 1. Oracle SQL Developer for VS Code (Ametlik Oracle laiendus)
echo "1/2 🗄️ Paigaldan ametliku Oracle SQL Developer laienduse..."
podman exec -i "$WEB_IDE_CONTAINER" $CODE_SERVER_BIN --install-extension Oracle.sql-developer-for-vscode 2>/dev/null || true

# 2. GitHub Actions & Workflows (Ametlik GitHub laiendus)
echo "2/2 ⚙️ Paigaldan ametliku GitHub Actions laienduse..."
podman exec -i "$WEB_IDE_CONTAINER" $CODE_SERVER_BIN --install-extension github.vscode-github-actions 2>/dev/null || true

# 3. Paigaldame kohalikud binaries/extensions/*.vsix failid (kui need on olemas)
if [ -d "$EXT_DIR" ]; then
  for vsix in "$EXT_DIR/"*.vsix; do
    if [ -f "$vsix" ]; then
      vsix_name=$(basename "$vsix")
      echo "📦 Paigaldan lokaalset VSIX laiendust: $vsix_name..."
      podman exec -i "$WEB_IDE_CONTAINER" $CODE_SERVER_BIN --install-extension "/workspace/binaries/extensions/$vsix_name" 2>/dev/null || true
    fi
  done
fi

# Seadistame failiõigused
podman exec -u root -i "$WEB_IDE_CONTAINER" bash -c 'chown -R abc:abc /config/.local /config/.config 2>/dev/null || true' 2>/dev/null || true

echo "=================================================================="
echo "🎉 VS CODE LAIENDUSED ON EDUKALT PAIGALDANUD!"
echo "👉 Ava Web IDE brauseris: http://localhost:8090"
echo "=================================================================="
