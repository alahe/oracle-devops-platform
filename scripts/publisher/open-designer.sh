#!/usr/bin/env bash
# ==============================================================================
# Open Oracle Analytics Publisher Designer noVNC GUI in Default Browser
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

URL="http://localhost:6083/vnc.html"

# Ensure container is running
if ! podman ps --format '{{.Names}}' | grep -q '^app-publisher-designer$'; then
  echo "⚡ app-publisher-designer is not running. Starting container..."
  "$SCRIPT_DIR/start-designer.sh"
fi

echo "🌐 Opening Oracle Analytics Publisher Designer in browser: $URL"

if [[ "$OSTYPE" == "darwin"* ]]; then
  open "$URL"
elif command -v xdg-open &>/dev/null; then
  xdg-open "$URL"
else
  echo "Please open $URL in your web browser."
fi
