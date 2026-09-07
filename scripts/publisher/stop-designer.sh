#!/usr/bin/env bash
# ==============================================================================
# Stop Oracle Analytics Publisher Designer Workstation Container
# Frees memory and CPU resources when not actively designing templates
# ==============================================================================
set -euo pipefail

echo "🛑 Stopping app-publisher-designer container..."
if podman ps --format '{{.Names}}' | grep -q '^app-publisher-designer$'; then
  podman stop app-publisher-designer
  echo "✅ app-publisher-designer stopped. System resources (1.5 GB RAM) freed."
else
  echo "ℹ️ app-publisher-designer was not running."
fi
