#!/usr/bin/env bash
# ============================================================================
# Containerized Web IDE Initializer
# Pre-configures code-server settings, SEPS Wallet sync, and SQL Developer connections
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Rule 1: Local full logging setup
LOG_DIR="$WORKSPACE_DIR/install_logs"
METRICS_DIR="$WORKSPACE_DIR/metrics"
mkdir -p "$LOG_DIR" "$METRICS_DIR"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$LOG_DIR/init_web_ide_${TIMESTAMP}.log"
exec > >(tee -a "$LOG_FILE") 2>&1

START_TIME=$(date +%s)

# Load environment
if [ -f "$WORKSPACE_DIR/.env" ]; then
  set -a
  source "$WORKSPACE_DIR/.env"
  set +a
fi

echo "=================================================================="
echo "💻 INITIALIZING CONTAINERIZED WEB IDE ENVIRONMENT"
echo "=================================================================="

WEB_IDE_CONTAINER="${WEB_IDE_CONTAINER_NAME:-web-ide-dev}"

if ! podman container exists "$WEB_IDE_CONTAINER" 2>/dev/null; then
  echo "ℹ️  Web IDE konteiner '$WEB_IDE_CONTAINER' ei ole veel käivitatud. Jätkan seadistust."
  exit 0
fi

# 1. Sync SEPS Wallet to Web IDE container
TNS_DIR="$WORKSPACE_DIR/config/tns_admin_container"
[ ! -d "$TNS_DIR" ] && TNS_DIR="$WORKSPACE_DIR/config/tns_admin"

if [ -d "$TNS_DIR" ]; then
  echo "🔒 Sünkroniseerin SEPS Walleti Web IDE konteineriga..."
  podman exec -i "$WEB_IDE_CONTAINER" mkdir -p /config/.oracle/tns_admin 2>/dev/null || true
  podman cp "$TNS_DIR/." "$WEB_IDE_CONTAINER:/config/.oracle/tns_admin/" 2>/dev/null || true
  echo "✅ SEPS Wallet edukalt sünkroniseeritud Web IDE konteinerisse!"
fi

# 2. Register VS Code SQL Developer Connections inside Web IDE
echo "🔌 Registreerin SQL Developer ühendused Web IDE sisse..."
"$SCRIPT_DIR/register-connections-sqlcl.sh" >/dev/null 2>&1 || true

# 3. Dynamic Profile-Driven Extension & Tool Initializer
if [ -f "$SCRIPT_DIR/load-profile.sh" ]; then
  source "$SCRIPT_DIR/load-profile.sh"
  load_web_ide_profile >/dev/null 2>&1 || true
fi

# A. Handle Google Antigravity Tool
if [ "${WEB_IDE_ANTIGRAVITY_ENABLED:-true}" = "true" ]; then
  echo "🤖 Kontrollin Google Antigravity olemasolu Web IDE konteineris..."
  podman exec -i "$WEB_IDE_CONTAINER" bash -c "command -v antigravity || command -v agy || curl -fsSL ${WEB_IDE_ANTIGRAVITY_INSTALL_URL:-https://antigravity.google/install.sh} | bash" 2>/dev/null || true
fi

# B. Download & Auto-install VSIX extensions configured in profile or local directory
EXT_DIR="$WORKSPACE_DIR/binaries/extensions"
mkdir -p "$EXT_DIR"

if [ -f "$WEB_IDE_PROFILE_YAML" ]; then
  echo "📦 Parsin VS Code laiendusi profiilist: $(basename "$WEB_IDE_PROFILE_YAML")..."
  # Download extensions with explicit download_url if not present
  awk '/extensions:/{flag=1;next}flag' "$WEB_IDE_PROFILE_YAML" 2>/dev/null | grep -E "vsix_path|download_url|id" | while read -r line; do
    if [[ "$line" =~ download_url:[[:space:]]*\"?([^\"]+)\"? ]] && [ -n "${BASH_REMATCH[1]}" ]; then
      url="${BASH_REMATCH[1]}"
      fname=$(basename "$url")
      if [ ! -f "$EXT_DIR/$fname" ]; then
        echo "⬇️  Laen alla laienduse URL-ilt: $url..."
        curl -sL "$url" -o "$EXT_DIR/$fname" 2>/dev/null || true
      fi
    fi
  done
fi

if [ -d "$EXT_DIR" ]; then
  for vsix in "$EXT_DIR/"*.vsix; do
    if [ -f "$vsix" ]; then
      vsix_name=$(basename "$vsix")
      CODE_SERVER_BIN="/app/code-server/bin/code-server"
      echo "📦 Paigaldan VS Code laiendust: $vsix_name..."
      podman exec -i "$WEB_IDE_CONTAINER" $CODE_SERVER_BIN --install-extension "/workspace/binaries/extensions/$vsix_name" 2>/dev/null || true
    fi
  done
fi


END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

# Rule 1: Record metrics
python3 -c "
import json, os
metrics_file = '$METRICS_DIR/setup_benchmarks.json'
data = {}
if os.path.exists(metrics_file):
    try:
        with open(metrics_file, 'r') as f:
            data = json.load(f)
    except: data = {}
data['init_web_ide_duration_seconds'] = $DURATION
with open(metrics_file, 'w') as f:
    json.dump(data, f, indent=2)
" 2>/dev/null || true

echo "=================================================================="
echo "✅ WEB IDE SEADISTUS VALMIS (${DURATION}s)"
echo "=================================================================="
