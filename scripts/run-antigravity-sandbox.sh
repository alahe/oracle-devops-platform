#!/usr/bin/env bash
# ============================================================================
# Google Antigravity Desktop GUI Sandbox Runner for Podman (macOS / Linux)
# Runs native desktop Antigravity IDE inside an isolated Podman container.
# Usage: ./scripts/run-antigravity-sandbox.sh [--build] [--stop]
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
JAIL_DIR="$HOME/Antigravity-Jail"
LOG_DIR="$WORKSPACE_DIR/install_logs"
METRICS_DIR="$WORKSPACE_DIR/metrics"

mkdir -p "$LOG_DIR" "$METRICS_DIR" "$JAIL_DIR"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$LOG_DIR/antigravity_sandbox_${TIMESTAMP}.log"
START_TIME=$(date +%s)

echo "==================================================================" | tee -a "$LOG_FILE"
echo "🚀 GOOGLE ANTIGRAVITY DESKTOP GUI PODMAN SANDBOX" | tee -a "$LOG_FILE"
echo "==================================================================" | tee -a "$LOG_FILE"

# Handle --stop option
if [ "$1" = "--stop" ]; then
  echo "🛑 Peatan ja eemaldan Antigravity liivakasti konteineri..." | tee -a "$LOG_FILE"
  podman rm -f antigravity-sandbox >/dev/null 2>&1 || true
  echo "✅ Konteiner 'antigravity-sandbox' on hävitatud ja taustaprotsessid meeles mälust vabastatud." | tee -a "$LOG_FILE"
  exit 0
fi

# 1. Kontrollime XQuartz / X11 olemasolu macOS-is
if [[ "$OSTYPE" == "darwin"* ]]; then
  if ! command -v xhost &>/dev/null; then
    echo "📦 Paigaldan XQuartz tarkvara macOS X11 GUI edastuseks..." | tee -a "$LOG_FILE"
    if command -v brew &>/dev/null; then
      brew install --cask xquartz >> "$LOG_FILE" 2>&1
    else
      echo "❌ Viga: Homebrew puudub. Paigalda XQuartz käsitsi: brew install --cask xquartz" | tee -a "$LOG_FILE"
      exit 1
    fi
  fi

  # Seadistame XQuartz seaded
  defaults write org.xquartz.X11 nolisten_tcp 0 2>/dev/null || true
  defaults write org.xquartz.X11 allow_public_access 1 2>/dev/null || true

  if ! pgrep -x "XQuartz" &>/dev/null; then
    echo "🚀 Käivitan XQuartz teenuse..." | tee -a "$LOG_FILE"
    open -a XQuartz 2>/dev/null || true
    sleep 2
  fi

  LOCAL_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -n 1)
  LOCAL_IP="${LOCAL_IP:-127.0.0.1}"
  echo "🔑 Luban X11 võrguühendused IP-lt $LOCAL_IP..." | tee -a "$LOG_FILE"
  xhost + "$LOCAL_IP" >> "$LOG_FILE" 2>&1 || xhost + 127.0.0.1 >> "$LOG_FILE" 2>&1 || true
  DISPLAY_VAL="$LOCAL_IP:0"
else
  DISPLAY_VAL="${DISPLAY:-:0}"
  xhost + local:root >> "$LOG_FILE" 2>&1 || true
fi

# 2. Ehitame Podman pildi kui seda pole või küsiti --build
if [ "$1" = "--build" ] || ! podman image exists ag-jail-image:latest 2>/dev/null; then
  echo "🏗️ Ehitan Podman konteineri pilti 'ag-jail-image:latest'..." | tee -a "$LOG_FILE"
  podman build -t ag-jail-image:latest -f "$WORKSPACE_DIR/docker/antigravity-gui/Dockerfile" "$WORKSPACE_DIR" >> "$LOG_FILE" 2>&1
fi

# 3. Peatame vana liivakasti kui see jookseb
podman rm -f antigravity-sandbox >/dev/null 2>&1 || true

# 4. Käivitame Antigravity Desktop GUI konteineris
echo "🚀 Käivitan Antigravity Desktop GUI rakenduse Podman konteineris..." | tee -a "$LOG_FILE"
podman run -d \
  --name antigravity-sandbox \
  -e DISPLAY="$DISPLAY_VAL" \
  -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
  -v "$JAIL_DIR:/workspace:Z" \
  ag-jail-image:latest >> "$LOG_FILE" 2>&1

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

# Rule 1: Benchmarks timing logging
cat << EOF > "$METRICS_DIR/antigravity_sandbox_benchmarks.env"
ANTIGRAVITY_SANDBOX_STARTUP_SECONDS=$DURATION
ANTIGRAVITY_SANDBOX_TIMESTAMP="$TIMESTAMP"
EOF

echo "==================================================================" | tee -a "$LOG_FILE"
echo "🎉 GOOGLE ANTIGRAVITY GUI CONTIANER KÄIVITATUD PODMANIS!" | tee -a "$LOG_FILE"
echo "   Konteiner:       antigravity-sandbox" | tee -a "$LOG_FILE"
echo "   Isoleeritud kaust: $JAIL_DIR" | tee -a "$LOG_FILE"
echo "   Kestus:          ${DURATION}s" | tee -a "$LOG_FILE"
echo "   Peatamise käsk:   ./scripts/run-antigravity-sandbox.sh --stop" | tee -a "$LOG_FILE"
echo "==================================================================" | tee -a "$LOG_FILE"
