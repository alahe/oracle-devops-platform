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
echo "📦 INSTALLING VS CODE EXTENSIONS INTO WEB IDE"
echo "=================================================================="

if ! podman container exists "$WEB_IDE_CONTAINER" 2>/dev/null; then
  echo "⚠️  Web IDE container '$WEB_IDE_CONTAINER' is not running."
  echo "🚀 Starting Web IDE container..."
  "$SCRIPT_DIR/start-containers.sh"
fi

if [ "$(podman inspect --format='{{.State.Status}}' "$WEB_IDE_CONTAINER" 2>/dev/null)" != "running" ]; then
  echo "🚀 Starting container $WEB_IDE_CONTAINER..."
  podman start "$WEB_IDE_CONTAINER" >/dev/null 2>&1 || true
fi

echo "📦 Installing verified extensions into Web IDE container..."

CODE_SERVER_BIN="/app/code-server/bin/code-server"

# 1. Oracle SQL Developer for VS Code
echo "1/4 🗄️ Installing official Oracle SQL Developer extension..."
podman exec -i "$WEB_IDE_CONTAINER" $CODE_SERVER_BIN --install-extension Oracle.sql-developer-for-vscode 2>/dev/null || true
podman exec -i "$WEB_IDE_CONTAINER" $CODE_SERVER_BIN --install-extension oracle.sql-developer 2>/dev/null || true

# 2. Google Antigravity AI Assistant
echo "2/4 🤖 Installing Google Antigravity extension..."
podman exec -i "$WEB_IDE_CONTAINER" $CODE_SERVER_BIN --install-extension google.google-antigravity 2>/dev/null || true
podman exec -i "$WEB_IDE_CONTAINER" $CODE_SERVER_BIN --install-extension google.antigravity 2>/dev/null || true

# 3. GitHub Actions & Workflows
echo "3/4 ⚙️ Installing official GitHub Actions extension..."
podman exec -i "$WEB_IDE_CONTAINER" $CODE_SERVER_BIN --install-extension github.vscode-github-actions 2>/dev/null || true

# 4. Red Hat YAML
echo "4/4 📝 Installing Red Hat YAML extension..."
podman exec -i "$WEB_IDE_CONTAINER" $CODE_SERVER_BIN --install-extension redhat.vscode-yaml 2>/dev/null || true

# 5. Install local binaries/extensions/*.vsix extension packages (if present)
if [ -d "$EXT_DIR" ]; then
  for vsix in "$EXT_DIR/"*.vsix; do
    if [ -f "$vsix" ]; then
      vsix_name=$(basename "$vsix")
      echo "📦 Installing local VSIX extension: $vsix_name..."
      podman exec -i "$WEB_IDE_CONTAINER" $CODE_SERVER_BIN --install-extension "/workspace/binaries/extensions/$vsix_name" 2>/dev/null || true
    fi
  done
fi

# 6. Synchronize local host extensions (if present on local machine)
HOST_EXT_DIR="$HOME/.vscode/extensions"
if [ -d "$HOST_EXT_DIR" ]; then
  podman exec -i "$WEB_IDE_CONTAINER" mkdir -p /config/.local/share/code-server/extensions 2>/dev/null || true
  for ext_match in "oracle.sql-developer" "google.google-antigravity" "google.antigravity"; do
    for dir in "$HOST_EXT_DIR"/$ext_match*; do
      if [ -d "$dir" ]; then
        bname=$(basename "$dir")
        echo "🔄 Synchronizing local extension to container: $bname..."
        podman cp "$dir" "$WEB_IDE_CONTAINER:/config/.local/share/code-server/extensions/$bname" 2>/dev/null || true
      fi
    done
  done
fi

# 7. Register extensions in VS Code extensions.json file
podman exec -i "$WEB_IDE_CONTAINER" /app/code-server/lib/node -e '
const fs = require("fs");
const path = require("path");
const extDir = "/config/.local/share/code-server/extensions";
const metaFile = path.join(extDir, "extensions.json");
let meta = [];
try { meta = JSON.parse(fs.readFileSync(metaFile, "utf8")); } catch (e) { meta = []; }
const installedIds = new Set(meta.map(m => (m.identifier && m.identifier.id ? m.identifier.id.toLowerCase() : "")));
if (fs.existsSync(extDir)) {
  const folders = fs.readdirSync(extDir);
  for (const folder of folders) {
    const pkgPath = path.join(extDir, folder, "package.json");
    if (fs.existsSync(pkgPath)) {
      try {
        const pkg = JSON.parse(fs.readFileSync(pkgPath, "utf8"));
        const pub = pkg.publisher || "oracle";
        const name = pkg.name || folder;
        const ver = pkg.version || "1.0.0";
        const extId = `${pub}.${name}`;
        if (!installedIds.has(extId.toLowerCase())) {
          meta.push({
            identifier: { id: extId },
            version: ver,
            location: {
              $mid: 1,
              fsPath: path.join(extDir, folder),
              external: `file://${path.join(extDir, folder)}`,
              path: path.join(extDir, folder),
              scheme: "file"
            },
            relativeLocation: folder,
            metadata: {
              installedTimestamp: Date.now(),
              source: "custom",
              publisherDisplayName: pub,
              targetPlatform: "universal",
              updated: false,
              isPreReleaseVersion: false,
              hasPreReleaseVersion: false
            }
          });
          installedIds.add(extId.toLowerCase());
        }
      } catch (err) {}
    }
  }
  fs.writeFileSync(metaFile, JSON.stringify(meta, null, 2));
}
' 2>/dev/null || true

# Configure file permissions
podman exec -u root -i "$WEB_IDE_CONTAINER" bash -c 'chown -R abc:abc /config/.local /config/.config 2>/dev/null || true' 2>/dev/null || true

echo "=================================================================="
echo "🎉 VS CODE EXTENSIONS INSTALLED SUCCESSFULLY!"
echo "📋 List of installed extensions:"
podman exec -i "$WEB_IDE_CONTAINER" $CODE_SERVER_BIN --list-extensions 2>/dev/null || true
echo "👉 Open Web IDE in browser: http://localhost:8090"
echo "=================================================================="
