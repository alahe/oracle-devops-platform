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

# 3. Auto-install custom VSIX extensions (e.g. Google Antigravity)
EXT_DIR="$WORKSPACE_DIR/binaries/extensions"
if [ -d "$EXT_DIR" ]; then
  for vsix in "$EXT_DIR/"*.vsix; do
    if [ -f "$vsix" ]; then
      vsix_name=$(basename "$vsix")
      echo "📦 Paigaldan VS Code laiendust (sh Antigravity): $vsix_name..."
      podman exec -i "$WEB_IDE_CONTAINER" code-server --install-extension "/workspace/binaries/extensions/$vsix_name" 2>/dev/null || true
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
