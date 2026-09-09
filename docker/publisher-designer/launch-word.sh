#!/usr/bin/env bash
# ==============================================================================
# Launcher for Microsoft Word with Oracle BI Publisher Desktop Template Builder
# Converts POSIX template paths to Windows paths and executes Word under Wine
# ==============================================================================
set -euo pipefail

export WINEPREFIX="${WINEPREFIX:-/u01/oracle/.wine}"
export WINEARCH="${WINEARCH:-win32}"
export WINEDEBUG="-all"

find_installed_word() {
  local prefix="${WINEPREFIX}"
  find "$prefix/drive_c" -type f -name "WINWORD.EXE" 2>/dev/null | head -n 1
}

INSTALLED_WORD="$(find_installed_word || true)"

if [ -z "$INSTALLED_WORD" ] || [ ! -f "$INSTALLED_WORD" ]; then
  echo "⚠️ Microsoft Word is not installed yet in Wine."
  echo "🚀 Launching Word & BI Publisher installer wizard..."
  exec /u01/oracle/bin/install-word-bip.sh
fi

TARGET_FILE="${1:-/u01/templates/samples/arve_eesti_standard.rtf}"

if [ -f "$TARGET_FILE" ]; then
  WIN_PATH="$(winepath -w "$TARGET_FILE" 2>/dev/null || echo "$TARGET_FILE")"
  echo "📝 Launching Microsoft Word with template: $TARGET_FILE ($WIN_PATH)"
  exec wine "$INSTALLED_WORD" "$WIN_PATH"
else
  echo "📝 Launching Microsoft Word..."
  exec wine "$INSTALLED_WORD"
fi
