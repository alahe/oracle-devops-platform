#!/usr/bin/env bash
# ==============================================================================
# Oracle Analytics Publisher Integrated Template Studio
# Launches LibreOffice Writer (RTF Designer) + Evince (PDF Preview) + XML Inspector
# Arranges windows in a 3-pane layout on display :1 with live auto-reload
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="/u01"
DISPLAY="${DISPLAY:-:1}"
export DISPLAY

TPL="${1:-/u01/templates/samples/arve_test_standard.rtf}"
XML="${2:-/u01/templates/samples/arve_test_andmed.xml}"
PDF="${3:-/u01/templates/samples/valmis_arve.pdf}"

echo "================================================================================"
echo "🚀 Launching Oracle BI Publisher Integrated Template Studio..."
echo "   Template: $TPL"
echo "   Data:     $XML"
echo "   Output:   $PDF"
echo "================================================================================"

# 1. Setup LibreOffice Profile if not configured
"$SCRIPT_DIR/setup-libreoffice-profile.sh"

# 2. Pre-generate initial PDF if not present
if [ ! -f "$PDF" ] && [ -f "$TPL" ] && [ -f "$XML" ]; then
  echo "⚡ Generating initial PDF preview..."
  "$SCRIPT_DIR/render-template.sh" "$TPL" "$XML" "$PDF" || true
fi

# 3. Start background Live Watcher Daemon (monitors directory to handle LibreOffice atomic saves)
WATCHER_PID="/tmp/publisher_studio_watcher.pid"
if [ -f "$WATCHER_PID" ] && kill -0 "$(cat "$WATCHER_PID")" 2>/dev/null; then
  kill "$(cat "$WATCHER_PID")" 2>/dev/null || true
fi

TPL_DIR="$(dirname "$TPL")"
TPL_BASE="$(basename "$TPL")"

(
  set +e
  echo "👀 Starting inotify file watcher for $TPL_BASE in $TPL_DIR..."
  inotifywait -m -e close_write,moved_to "$TPL_DIR" --format "%f" 2>/dev/null | while read -r changed_file; do
    if [ "$changed_file" = "$TPL_BASE" ]; then
      echo "💾 Change detected in $TPL_BASE! Re-rendering PDF..."
      "$SCRIPT_DIR/render-template.sh" "$TPL" "$XML" "$PDF" || true
      echo "✅ Re-render complete!"
    fi
  done
) &
echo $! > "$WATCHER_PID"

# 4. Launch Evince PDF Viewer (Top Right)
if [ -f "$PDF" ]; then
  echo "📄 Opening Evince PDF Live Viewer..."
  evince "$PDF" &
  EVINCE_PID=$!
fi

# 5. Launch XML Field Inspector (Bottom Right)
echo "🏷️ Launching XML Field Inspector..."
"$SCRIPT_DIR/xml-field-inspector.py" --xml "$XML" --rtf "$TPL" &
INSPECTOR_PID=$!

# 6. Launch LibreOffice Writer (Left Main Screen)
echo "📝 Launching LibreOffice Writer with template..."
libreoffice --norestore --writer "$TPL" &
LO_PID=$!

# 7. Robust 3-Pane Window Arrangement using wmctrl
echo "📐 Arranging windows into 3-pane layout..."
for i in $(seq 1 12); do
  sleep 0.5
  if wmctrl -lx 2>/dev/null | grep -qi "libreoffice.libreoffice-writer"; then
    "$SCRIPT_DIR/arrange-studio-windows.sh" 2>/dev/null || true
    break
  fi
done

# Secondary settle pass to ensure LibreOffice does not maximize after loading document
(
  sleep 2
  "$SCRIPT_DIR/arrange-studio-windows.sh" 2>/dev/null || true
) &

echo "================================================================================"
echo "🎉 Template Studio is fully arranged on Display :1!"
echo "   LibreOffice (Left: 1200x990) | Evince PDF (Top-Right: 700x490) | XML Inspector (Bottom-Right: 700x490)"
echo "================================================================================"

# Wait for LibreOffice to exit
wait "$LO_PID" 2>/dev/null || true

# Cleanup background processes when LibreOffice is closed
if [ -f "$WATCHER_PID" ]; then
  kill "$(cat "$WATCHER_PID")" 2>/dev/null || true
  rm -f "$WATCHER_PID"
fi
kill "$INSPECTOR_PID" 2>/dev/null || true
kill "${EVINCE_PID:-0}" 2>/dev/null || true
echo "🛑 Template Studio session finished."
