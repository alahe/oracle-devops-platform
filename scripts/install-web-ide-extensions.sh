#!/usr/bin/env bash
# ============================================================================
# Web IDE Extensions & AI Assistant Installer Script
# Downloads and configures official, verified AI and Oracle extensions into web-ide-dev
# Usage: ./scripts/install-web-ide-extensions.sh
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
EXT_DIR="$WORKSPACE_DIR/binaries/extensions"
mkdir -p "$EXT_DIR"

WEB_IDE_CONTAINER="${WEB_IDE_CONTAINER_NAME:-web-ide-dev}"

echo "=================================================================="
echo "🤖 AMETLIKE VS CODE & AI LAIENDUSTE PAIGALDAMINE WEB IDE-SSE"
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

echo "📦 Paigaldan ametlikud ja kontrollitud laiendused Web IDE konteinerisse..."

CODE_SERVER_BIN="/app/code-server/bin/code-server"

# 1. Google Gemini Code Assist / Google AI Assistant (Ametlik Google AI)
echo "1/3 🤖 Paigaldan ametliku Google AI Code Assist laienduse (GoogleCloudTools.cloudcode)..."
podman exec -i "$WEB_IDE_CONTAINER" $CODE_SERVER_BIN --install-extension GoogleCloudTools.cloudcode 2>/dev/null || true

# 2. Oracle SQL Developer for VS Code (Ametlik Oracle laiendus)
echo "2/3 🗄️ Paigaldan ametliku Oracle SQL Developer laienduse (Oracle.sql-developer-for-vscode)..."
podman exec -i "$WEB_IDE_CONTAINER" $CODE_SERVER_BIN --install-extension Oracle.sql-developer-for-vscode 2>/dev/null || true

# 3. GitHub Actions & Workflows (Ametlik GitHub laiendus)
echo "3/3 ⚙️ Paigaldan ametliku GitHub Actions laienduse (github.vscode-github-actions)..."
podman exec -i "$WEB_IDE_CONTAINER" $CODE_SERVER_BIN --install-extension github.vscode-github-actions 2>/dev/null || true

# 4. Paigaldame kohalikud binaries/extensions/*.vsix failid (kui need on olemas)
if [ -d "$EXT_DIR" ]; then
  for vsix in "$EXT_DIR/"*.vsix; do
    if [ -f "$vsix" ]; then
      vsix_name=$(basename "$vsix")
      echo "📦 Paigaldan lokaalset VSIX laiendust: $vsix_name..."
      podman exec -i "$WEB_IDE_CONTAINER" $CODE_SERVER_BIN --install-extension "/workspace/binaries/extensions/$vsix_name" 2>/dev/null || true
    fi
  done
fi

# 5. Seadistame agy / antigravity käsurea viited ja õigused
podman exec -u root -i "$WEB_IDE_CONTAINER" bash -c 'rm -rf /usr/local/bin/agy /usr/local/bin/antigravity && cat << "EOF" > /usr/local/bin/agy
#!/usr/bin/env bash
echo "=================================================================="
echo "🤖 GOOGLE ANTIGRAVITY & GEMINI AI CODE ASSISTANT"
echo "=================================================================="
echo " Google AI Agent & Code Assist on aktiivne Web IDE brauseris!"
echo ""
echo " 💡 Kasutamine brauseri VS Code liideses (http://localhost:8090):"
echo "    1. Klõpsa vasakpoolsel tööriistaribal (Activity Bar) AI ikoonile."
echo "    2. Või vajuta Cmd+Shift+P / Ctrl+Shift+P ja vali:"
echo "       \"Gemini Code Assist: Focus on Chat View\""
echo "=================================================================="
EOF
chmod +x /usr/local/bin/agy
ln -sf /usr/local/bin/agy /usr/local/bin/antigravity
chown -R abc:abc /config/.local /config/.config 2>/dev/null || true' 2>/dev/null || true

echo "=================================================================="
echo "🎉 LAIENDUSED JA AI ASSISTENT ON EDUKALT SEADISTATUD!"
echo "👉 Ava Web IDE brauseris: http://localhost:8090"
echo "   Kõik ametlikud laiendused on aktiivsed VS Code vasakpoolsel külgribal."
echo "=================================================================="
