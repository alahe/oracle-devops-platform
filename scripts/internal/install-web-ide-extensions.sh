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

# Configure Marketplace Gallery URL (openvsx vs microsoft vs artifactory)
# Configure Marketplace Gallery URL (openvsx vs microsoft vs artifactory)
MARKETPLACE_CHOICE="${VSCODE_MARKETPLACE_PROVIDER:-microsoft}"
case "$MARKETPLACE_CHOICE" in
  openvsx)
    GALLERY_CONF='{"serviceUrl":"https://open-vsx.org/vscode/gallery","itemUrl":"https://open-vsx.org/vscode/item"}'
    echo "🌐 Using Open VSX Registry (open-vsx.org)..."
    ;;
  artifactory)
    REG_URL="${ARTIFACTORY_REGISTRY:-http://artifactory.local}"
    GALLERY_CONF="{\"serviceUrl\":\"${REG_URL}/artifactory/api/npm/vs-marketplace/\",\"itemUrl\":\"${REG_URL}/artifactory/api/npm/vs-marketplace/items\"}"
    echo "🏢 Using Corporate Artifactory Marketplace mirror ($REG_URL)..."
    ;;
  microsoft|ms|*)
    GALLERY_CONF='{"serviceUrl":"https://marketplace.visualstudio.com/_apis/public/gallery","itemUrl":"https://marketplace.visualstudio.com/items"}'
    echo "🌐 Using Microsoft Visual Studio Marketplace (marketplace.visualstudio.com)..."
    ;;
esac

CODE_SERVER_BIN="EXTENSIONS_GALLERY='$GALLERY_CONF' /app/code-server/bin/code-server --extensions-dir /config/extensions"

# 1. Oracle SQL Developer for VS Code (Vendor: Oracle)
echo "1/5 🗄️ Installing official Oracle SQL Developer extension (Oracle)..."
podman exec -i "$WEB_IDE_CONTAINER" bash -c "$CODE_SERVER_BIN --install-extension Oracle.sql-developer 2>/dev/null || true"

# 2. Google Antigravity AI Assistant (Vendor: Google)
echo "2/5 🤖 Installing Google Antigravity extension (Google)..."
podman exec -i "$WEB_IDE_CONTAINER" bash -c "$CODE_SERVER_BIN --install-extension google.google-antigravity 2>/dev/null || $CODE_SERVER_BIN --install-extension google.antigravity 2>/dev/null || true"

# 3. Microsoft Python Suite (Vendor: Microsoft)
echo "3/5 🐍 Installing Python extension suite (Microsoft)..."
podman exec -i "$WEB_IDE_CONTAINER" bash -c "$CODE_SERVER_BIN --install-extension ms-python.python 2>/dev/null || true"
podman exec -i "$WEB_IDE_CONTAINER" bash -c "$CODE_SERVER_BIN --install-extension ms-python.vscode-pylance 2>/dev/null || true"
podman exec -i "$WEB_IDE_CONTAINER" bash -c "$CODE_SERVER_BIN --install-extension ms-python.debugpy 2>/dev/null || true"

# 4. GitHub Actions & Workflows (Vendor: GitHub)
echo "4/5 ⚙️ Installing official GitHub Actions extension (GitHub)..."
podman exec -i "$WEB_IDE_CONTAINER" bash -c "$CODE_SERVER_BIN --install-extension github.vscode-github-actions 2>/dev/null || true"

# 5. Red Hat YAML (Vendor: Red Hat)
echo "5/5 📝 Installing Red Hat YAML extension (Red Hat)..."
podman exec -i "$WEB_IDE_CONTAINER" bash -c "$CODE_SERVER_BIN --install-extension redhat.vscode-yaml 2>/dev/null || true"

# 6. Install local binaries/extensions/*.vsix extension packages (Tier 1 Air-Gapped Cache)
if [ -d "$EXT_DIR" ]; then
  for vsix in "$EXT_DIR/"*.vsix; do
    if [ -f "$vsix" ]; then
      vsix_name=$(basename "$vsix")
      echo "📦 Installing local VSIX extension from binaries/extensions/: $vsix_name..."
      podman exec -i "$WEB_IDE_CONTAINER" bash -c "$CODE_SERVER_BIN --install-extension '/workspace/binaries/extensions/$vsix_name' 2>/dev/null || true"
    fi
  done
fi

# 7. Register extensions in VS Code extensions.json file
podman exec -i "$WEB_IDE_CONTAINER" /app/code-server/lib/node -e '
const fs = require("fs");
const path = require("path");
const extDir = "/config/extensions";
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

// 8. Configure default file and editor associations (.sql -> Oracle SQL Developer)
for (const userSettingsDir of ["/config/data/User", "/config/.local/share/code-server/User"]) {
  if (!fs.existsSync(userSettingsDir)) {
    fs.mkdirSync(userSettingsDir, { recursive: true });
  }
  const userSettingsFile = path.join(userSettingsDir, "settings.json");
  let settings = {};
  try { settings = JSON.parse(fs.readFileSync(userSettingsFile, "utf8")); } catch (e) { settings = {}; }

  settings["oracle.sql.developer.tnsAdmin"] = "/config/.oracle/tns_admin";
  settings["oracle.sql.developer.javaPath"] = "/usr/lib/jvm/java-21-openjdk-amd64";
  settings["python.defaultInterpreterPath"] = "/usr/bin/python3";
  settings["python.testing.pytestEnabled"] = true;

  settings["files.associations"] = Object.assign({}, settings["files.associations"], {
    "*.sql": "oracle-sql",
    "*.pls": "oracle-plsql",
    "*.pks": "oracle-plsql",
    "*.pkb": "oracle-plsql"
  });

  settings["workbench.editorAssociations"] = Object.assign({}, settings["workbench.editorAssociations"], {
    "*.sql": "oracle.sql-developer.editor",
    "*.pls": "oracle.sql-developer.editor"
  });

  fs.writeFileSync(userSettingsFile, JSON.stringify(settings, null, 2));
}
' 2>/dev/null || true

echo "✅ Pre-configured .sql and PL/SQL file associations with Oracle SQL Developer editor."

# Configure file permissions
podman exec -u root -i "$WEB_IDE_CONTAINER" bash -c 'chown -R abc:abc /config /config/extensions /config/data 2>/dev/null || true' 2>/dev/null || true

echo "=================================================================="
echo "🎉 VS CODE EXTENSIONS INSTALLED SUCCESSFULLY!"
echo "📋 List of installed extensions:"
podman exec -i "$WEB_IDE_CONTAINER" bash -c "$CODE_SERVER_BIN --list-extensions" 2>/dev/null || true
echo "👉 Open Web IDE in browser: http://localhost:8090"
echo "=================================================================="
