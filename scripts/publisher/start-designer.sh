#!/usr/bin/env bash
# ==============================================================================
# Start Oracle Analytics Publisher Designer Workstation Container
# Starts the on-demand noVNC GUI container (Port 6083)
# Supports: --lang <et|en|fi|sv|lv|lt> [--rebuild]
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$WORKSPACE_DIR/scripts/internal/common.sh" || true

APP_LANG="et"
FORCE_REBUILD=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --lang|-l)
      APP_LANG="$2"
      shift 2
      ;;
    --lang=*)
      APP_LANG="${1#*=}"
      shift 1
      ;;
    --rebuild|-r)
      FORCE_REBUILD=true
      shift 1
      ;;
    *)
      shift 1
      ;;
  esac
done

APP_LANG="$(echo "$APP_LANG" | tr '[:upper:]' '[:lower:]' | cut -c1-2)"

echo "================================================================================"
echo "🚀 Starting Oracle Analytics Publisher Designer Workstation..."
echo "   Language: $APP_LANG"
echo "================================================================================"

# 1. Build or ensure container image exists
if [ "$FORCE_REBUILD" = true ] || ! podman image exists localhost/oracle-publisher-designer:latest 2>/dev/null; then
  echo "📦 Building oracle-publisher-designer container image..."
  podman build -t localhost/oracle-publisher-designer:latest -f "$WORKSPACE_DIR/docker/publisher-designer/Dockerfile" "$WORKSPACE_DIR/docker/publisher-designer"
fi

# 2. Check if container exists
if podman ps -a --format '{{.Names}}' | grep -q '^app-publisher-designer$'; then
  # If running, we can reconfigure language inside or restart if needed
  if ! podman ps --format '{{.Names}}' | grep -q '^app-publisher-designer$'; then
    echo "▶️ Starting existing app-publisher-designer container..."
    podman start app-publisher-designer
  fi
  echo "🌐 Aligning container language to: $APP_LANG..."
  podman exec -i -e APP_LANG="$APP_LANG" app-publisher-designer /u01/oracle/bin/setup-libreoffice-profile.sh "$APP_LANG" 2>/dev/null || true
else
  echo "🚀 Running new app-publisher-designer container..."
  podman run -d \
    --name app-publisher-designer \
    --hostname publisher-designer-dev \
    -p 6083:6080 \
    -p 5903:5900 \
    -e APP_LANG="$APP_LANG" \
    -v "$WORKSPACE_DIR/templates/publisher:/u01/templates:z" \
    -v "$WORKSPACE_DIR/binaries/publisher:/u01/binaries:z" \
    -v "$WORKSPACE_DIR/install_logs:/u01/logs:z" \
    -v "publisher_designer_wine:/u01/oracle/.wine:z" \
    --memory 2048m \
    --cpus 2.0 \
    localhost/oracle-publisher-designer:latest
fi

# 3. Wait for noVNC port to become active
echo "⏳ Waiting for noVNC web listener on port 6083..."
for i in {1..30}; do
  if nc -z localhost 6083 2>/dev/null || curl -s -I http://localhost:6083/vnc.html 2>/dev/null | grep -q "200\|302"; then
    echo "✅ Oracle Analytics Publisher Designer is LIVE!"
    echo "   🌐 Access URL: http://localhost:6083/vnc.html"
    break
  fi
  sleep 1
done

echo "================================================================================"
echo "💡 To open the designer in your browser, run:"
echo "   ./scripts/publisher/open-designer.sh"
echo "================================================================================"
