#!/usr/bin/env bash
# ============================================================================
# Google Antigravity Desktop GUI Sandbox Setup Script for macOS (X11 / XQuartz)
# Automates XQuartz configuration, xhost IP permissions, Podman image build, and GUI launch.
# Usage: ./scripts/setup-antigravity-gui-sandbox.sh
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
JAIL_DIR="$HOME/Antigravity-Jail"

echo "=================================================================="
echo "🚀 GOOGLE ANTIGRAVITY DESKTOP GUI SANDBOX SETUP (macOS / Podman)"
echo "=================================================================="

# 1. Kontrollime XQuartz olemasolu macOS masinas
if ! command -v xhost &>/dev/null; then
  echo "📦 XQuartz ei ole paigaldatud. Paigaldan Homebrew kaudu..."
  if command -v brew &>/dev/null; then
    brew install --cask xquartz
  else
    echo "❌ Viga: Homebrew ei ole paigaldatud. Paigalda XQuartz käsitsi: brew install --cask xquartz"
    exit 1
  fi
fi

# 2. Seadistame XQuartz võrguühenduste lubamise
echo "🔧 Konfigureerin XQuartz võrguhäälestust (Allow network clients)..."
defaults write org.xquartz.X11 nolisten_tcp 0 2>/dev/null || true
defaults write org.xquartz.X11 allow_public_access 1 2>/dev/null || true

# 3. Käivitame XQuartz rakenduse taustal
if ! pgrep -x "XQuartz" &>/dev/null; then
  echo "🚀 Käivitan XQuartz teenuse..."
  open -a XQuartz 2>/dev/null || true
  sleep 3
fi

# 4. Tuvastame kohaliku IP aadressi ja lubame X11 ühendused
LOCAL_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -n 1)
if [ -z "$LOCAL_IP" ]; then
  LOCAL_IP="127.0.0.1"
fi

echo "🌐 Tuvastati kohalik IP-aadress: $LOCAL_IP"
echo "🔑 Luban X11 võrguühendused IP-lt $LOCAL_IP..."
xhost + "$LOCAL_IP" 2>/dev/null || xhost + 127.0.0.1 2>/dev/null || true

# 5. Loome isoleeritud töökausta Antigravity-Jail
mkdir -p "$JAIL_DIR"
echo "📁 Isoleeritud töökaust: $JAIL_DIR"

# 6. Ehitame Antigravity Desktop GUI Podman konteineri pildi
echo "🏗️ Ehitan Antigravity Desktop GUI Podman konteineri pilti (ag-jail-image:latest)..."
podman build -t ag-jail-image:latest -f "$WORKSPACE_DIR/docker/antigravity-gui/Dockerfile" "$WORKSPACE_DIR"

# 7. Peatame ja eemaldame vana konteineri (kui see on olemas)
if podman container exists antigravity-sandbox 2>/dev/null; then
  echo "🧹 Eemaldan vana konteineri 'antigravity-sandbox'..."
  podman rm -f antigravity-sandbox >/dev/null 2>&1 || true
fi

# 8. Käivitame Google Antigravity Desktop GUI isoleeritud liivakastis
echo "🚀 Käivitan Google Antigravity Desktop GUI konteineri..."
podman run -d \
  --name antigravity-sandbox \
  -e DISPLAY="$LOCAL_IP:0" \
  -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
  -v "$JAIL_DIR:/workspace:Z" \
  ag-jail-image:latest

echo "=================================================================="
echo "🎉 GOOGLE ANTIGRAVITY DESKTOP GUI SANDBOX ON KÄIVITATUD!"
echo "   Konteineri nimi: antigravity-sandbox"
echo "   Töökaust:        $JAIL_DIR"
echo "   Kuva (DISPLAY):  $LOCAL_IP:0"
echo "=================================================================="
