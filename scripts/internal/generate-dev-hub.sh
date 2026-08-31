#!/usr/bin/env bash
# ==============================================================================
# Dynamic Developer & DevOps Hub HTML Generator Wrapper
# Generates a modern, interactive single-page application (SPA) dashboard for active Blueprints
# with real-time live service health checking (🟢 Online / 🟡 Initializing / Latency ms),
# interactive Mermaid.js architecture diagrams, full Blueprints Explorer (22+),
# in-browser Markdown Documentation Reader (with 5 languages embedded), and DevOps Command Dispatcher.
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

OUTPUT_FILE="${1:-$WORKSPACE_DIR/docs/dev-hub.html}"
mkdir -p "$(dirname "$OUTPUT_FILE")"

# Execute Python generator
python3 "$SCRIPT_DIR/generate_dev_hub.py" "$OUTPUT_FILE"

chmod 644 "$OUTPUT_FILE"
