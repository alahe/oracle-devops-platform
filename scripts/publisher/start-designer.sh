#!/usr/bin/env bash
# ==============================================================================
# Start Oracle Analytics Publisher Designer Workstation Container
# Starts the on-demand noVNC GUI container (Port 6083)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$WORKSPACE_DIR/scripts/internal/common.sh" || true

echo "================================================================================"
echo "🚀 Starting Oracle Analytics Publisher Designer Workstation..."
echo "================================================================================"

# 1. Build or ensure container image exists
if ! podman image exists localhost/oracle-publisher-designer:latest 2>/dev/null; then
  echo "📦 Building oracle-publisher-designer container image..."
  podman build -t localhost/oracle-publisher-designer:latest -f "$WORKSPACE_DIR/docker/publisher-designer/Dockerfile" "$WORKSPACE_DIR/docker/publisher-designer"
fi

# 2. Start container via podman compose or direct podman run
if podman ps -a --format '{{.Names}}' | grep -q '^app-publisher-designer$'; then
  echo "▶️ Restarting existing app-publisher-designer container..."
  podman start app-publisher-designer
else
  echo "🚀 Running new app-publisher-designer container..."
  podman run -d \
    --name app-publisher-designer \
    --hostname publisher-designer-dev \
    -p 6083:6080 \
    -p 5903:5900 \
    -v "$WORKSPACE_DIR/templates/publisher:/u01/templates:z" \
    -v "$WORKSPACE_DIR/install_logs:/u01/logs:z" \
    --memory 1536m \
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
