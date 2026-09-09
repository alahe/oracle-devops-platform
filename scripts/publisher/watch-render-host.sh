#!/usr/bin/env bash
# ==============================================================================
# Live Host Watcher: Re-render Oracle BI Publisher PDF on RTF Save (VS Code Sild)
# Monitors RTF template for changes, compiles via XDO engine, and refreshes PDF
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

[ -f "$WORKSPACE_DIR/scripts/internal/common.sh" ] && source "$WORKSPACE_DIR/scripts/internal/common.sh" || true

TPL="${1:-$WORKSPACE_DIR/templates/publisher/samples/arve_test_standard.rtf}"
DATA="${2:-$WORKSPACE_DIR/templates/publisher/samples/arve_test_andmed.xml}"
OUT="${3:-$WORKSPACE_DIR/templates/publisher/samples/valmis_test_arve.pdf}"

echo "================================================================================"
echo "👁️ Oracle BI Publisher Live Watcher (VS Code & GitHub Copilot Bridge)"
echo "   Template: $(basename "$TPL")"
echo "   Data:     $(basename "$DATA")"
echo "   Output:   $(basename "$OUT")"
echo "================================================================================"

if [ ! -f "$TPL" ]; then
  echo "❌ Error: Template file not found: $TPL"
  exit 1
fi

if [ ! -f "$DATA" ]; then
  echo "❌ Error: Data file not found: $DATA"
  exit 1
fi

# Helper to get file modification timestamp portably (macOS BSD stat vs Linux GNU stat)
get_mtime() {
  local target="$1"
  if stat -f %m "$target" >/dev/null 2>&1; then
    stat -f %m "$target"
  else
    stat -c %Y "$target" 2>/dev/null || date +%s
  fi
}

render_now() {
  echo ""
  echo "⚡ [$(date +'%H:%M:%S')] Re-rendering template..."
  if "$SCRIPT_DIR/test-render.sh" "$TPL" "$DATA" "$OUT"; then
    echo "✅ Successfully updated: $OUT"
  else
    echo "⚠️ Render failed. Please check RTF / XDO syntax."
  fi
}

# 1. Initial compile
render_now

# 2. Try to open PDF in default viewer
if [ -f "$OUT" ]; then
  if command -v open >/dev/null 2>&1; then
    open "$OUT" 2>/dev/null || true
  elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$OUT" 2>/dev/null || true
  fi
fi

echo ""
echo "👀 Watching for changes in $(basename "$TPL")..."
echo "💡 Edit the template in VS Code and press Cmd+S / Ctrl+S to re-render automatically."
echo "   Press Ctrl+C to stop watching."
echo "--------------------------------------------------------------------------------"

LAST_MTIME=$(get_mtime "$TPL")

while true; do
  sleep 1
  CURRENT_MTIME=$(get_mtime "$TPL")
  if [ "$CURRENT_MTIME" != "$LAST_MTIME" ]; then
    LAST_MTIME="$CURRENT_MTIME"
    render_now
  fi
done
