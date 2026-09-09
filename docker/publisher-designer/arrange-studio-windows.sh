#!/usr/bin/env bash
# ==============================================================================
# Arrange Oracle Analytics Publisher Studio Windows into 3-pane Layout
# LibreOffice (Left: 1200x990) | Evince (Top-Right: 700x490) | XML (Bottom-Right: 700x490)
# ==============================================================================
set -euo pipefail

export DISPLAY="${DISPLAY:-:1}"

# 1. Unmaximize and position LibreOffice Writer (Left ~63% width)
if wmctrl -lx 2>/dev/null | grep -qi "libreoffice.libreoffice-writer"; then
  wmctrl -x -r libreoffice.libreoffice-writer -b remove,maximized_vert,maximized_horz 2>/dev/null || true
  wmctrl -x -r libreoffice.libreoffice-writer -e 0,5,30,1195,990 2>/dev/null || true
fi

# 2. Unmaximize and position Evince PDF Viewer (Top-Right ~37% width)
if wmctrl -lx 2>/dev/null | grep -qi "evince.Evince"; then
  wmctrl -x -r evince.Evince -b remove,maximized_vert,maximized_horz 2>/dev/null || true
  wmctrl -x -r evince.Evince -e 0,1210,30,700,490 2>/dev/null || true
fi

# 3. Unmaximize and position XML Field Inspector (Bottom-Right ~37% width)
if wmctrl -lx 2>/dev/null | grep -qi "tk.Tk"; then
  wmctrl -x -r tk.Tk -b remove,maximized_vert,maximized_horz 2>/dev/null || true
  wmctrl -x -r tk.Tk -e 0,1210,530,700,490 2>/dev/null || true
fi
