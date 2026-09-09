#!/usr/bin/env bash
# ==============================================================================
# Setup Helper: Microsoft Word & Oracle BI Publisher Desktop in Container
# Checks host binaries/publisher/ directory and triggers in-container installer
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

[ -f "$WORKSPACE_DIR/scripts/internal/common.sh" ] && source "$WORKSPACE_DIR/scripts/internal/common.sh" || true

echo "================================================================================"
echo "📦 Oracle Analytics Publisher Workstation: Word & BIP Setup"
echo "================================================================================"

BIN_DIR="$WORKSPACE_DIR/binaries/publisher"
mkdir -p "$BIN_DIR"

OFFICE_INSTALLER="$(find "$BIN_DIR" -maxdepth 2 \( -iname "setup.exe" -o -iname "office*.exe" \) 2>/dev/null | head -n 1 || true)"
BIP_INSTALLER="$(find "$BIN_DIR" -maxdepth 2 \( -iname "bipublisherdesktop*.exe" -o -iname "bipdesktop*.exe" \) 2>/dev/null | head -n 1 || true)"

echo "🔍 Kontrollin paigaldusfaile kaustas: binaries/publisher/"

MISSING=0
if [ -n "$OFFICE_INSTALLER" ]; then
  echo "   ✅ Microsoft Office paigaldaja leitud: $(basename "$OFFICE_INSTALLER")"
else
  echo "   ❌ Microsoft Office paigaldaja puudub (vajalik nt Office 2010/2013/2016 32-bit setup.exe)"
  MISSING=1
fi

if [ -n "$BIP_INSTALLER" ]; then
  echo "   ✅ Oracle BI Publisher Desktop leitud: $(basename "$BIP_INSTALLER")"
else
  echo "   ❌ Oracle BI Publisher Desktop puudub (vajalik BIPublisherDesktop32.exe või 64.exe)"
  MISSING=1
fi

if [ "$MISSING" -eq 1 ]; then
  echo "================================================================================"
  echo "⚠️ Palun kopeerige puuduvad paigaldusfailid host-arvutis kausta:"
  echo "   $BIN_DIR"
  echo ""
  echo "Juhised:"
  echo "1. Microsoft Office: asetage Office 32-bit paigaldusfailid kausta binaries/publisher/"
  echo "2. Oracle BI Publisher Desktop: laadige alla Oracle eDelivery / OTN lehelt ja"
  echo "   kopeerige BIPublisherDesktop32.exe kausta binaries/publisher/"
  echo "3. Käivitage see skript uuesti:"
  echo "   ./scripts/publisher/setup-word-designer.sh"
  echo "================================================================================"
  exit 1
fi

# Ensure app-publisher-designer container is running
if ! podman ps --format '{{.Names}}' | grep -q '^app-publisher-designer$'; then
  echo "🚀 Käivitan app-publisher-designer konteineri..."
  "$SCRIPT_DIR/start-designer.sh"
fi

echo "⚙️ Käivitan paigaldusviisardi konteineris..."
podman exec -it app-publisher-designer /u01/oracle/bin/install-word-bip.sh

echo "================================================================================"
echo "🎉 Paigaldus lõpetatud! Töölaua avamiseks brauseris käivitage:"
echo "   ./scripts/publisher/open-designer.sh"
echo "   Või avage brauseris: http://localhost:6083/vnc.html"
echo "================================================================================"
