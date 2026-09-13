#!/usr/bin/env bash
# ============================================================================
# Utility Script: Dev Hub Bridge Lifecycle Manager
# Purpose: Start, restart, or check the status of Dev Hub Bridge background daemon.
# Usage: ./scripts/start-bridge.sh [--restart] [--stop] [--status] [--help]
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BRIDGE_PY="$SCRIPT_DIR/internal/dev-hub-bridge.py"
LOG_FILE="$WORKSPACE_DIR/install_logs/dev-hub-bridge.log"
VERSION_FILE="$WORKSPACE_DIR/VERSION"

ACTION="start"
for arg in "$@"; do
  case "$arg" in
    --restart|-r) ACTION="restart" ;;
    --stop|-s)    ACTION="stop" ;;
    --status)     ACTION="status" ;;
    --help|-h)
      echo "Kasutus: $0 [--restart] [--stop] [--status] [--help]"
      echo "  --restart, -r : Taaskäivitab taustal oleva Dev Hub Bridge serveri"
      echo "  --stop, -s    : Peatab jooksva Dev Hub Bridge serveri"
      echo "  --status      : Kontrollib Dev Hub Bridge serveri olekut ja versiooni"
      exit 0
      ;;
  esac
done

TARGET_VER="2.4.0"
[ -f "$VERSION_FILE" ] && TARGET_VER=$(cat "$VERSION_FILE" | tr -d '[:space:]')

get_running_pid() {
  pgrep -f "scripts/internal/dev-hub-bridge.py" 2>/dev/null | head -n 1 || true
}

get_running_version() {
  curl -s http://localhost:8089/api/version 2>/dev/null | grep -o '"version": *"[^"]*"' | cut -d'"' -f4 || true
}

RUNNING_PID=$(get_running_pid)
RUNNING_VER=$(get_running_version)

if [ "$ACTION" = "status" ]; then
  if [ -n "$RUNNING_PID" ]; then
    echo "🟢 Dev Hub Bridge töötab (PID: $RUNNING_PID, Versioon: v${RUNNING_VER:-tundmatu})"
    echo "   URL: http://localhost:8089/ (või https://localhost:8449/)"
    echo "   Logi: $LOG_FILE"
    if [ -n "$RUNNING_VER" ] && [ "$RUNNING_VER" != "$TARGET_VER" ]; then
      echo "   ⚠️ Hoiatus: Silla versioon (v$RUNNING_VER) ei kattu platvormi versiooniga (v$TARGET_VER)."
      echo "   Käivita taaskäivitus: $0 --restart"
    fi
  else
    echo "⚪ Dev Hub Bridge ei tööta."
  fi
  exit 0
fi

if [ "$ACTION" = "stop" ]; then
  if [ -n "$RUNNING_PID" ]; then
    echo "🛑 Peatan Dev Hub Bridge protsessi (PID: $RUNNING_PID)..."
    kill "$RUNNING_PID" 2>/dev/null || pkill -f "scripts/internal/dev-hub-bridge.py" 2>/dev/null || true
    echo "✅ Dev Hub Bridge edukalt peatatud."
  else
    echo "ℹ️ Dev Hub Bridge ei töötanud."
  fi
  exit 0
fi

# Action is start or restart
mkdir -p "$WORKSPACE_DIR/install_logs"

if [ -n "$RUNNING_PID" ]; then
  if [ "$ACTION" = "restart" ] || [ "$RUNNING_VER" != "$TARGET_VER" ]; then
    echo "🔄 Taaskäivitan Dev Hub Bridge (PID: $RUNNING_PID, v${RUNNING_VER:-vana} -> v$TARGET_VER)..."
    kill "$RUNNING_PID" 2>/dev/null || pkill -f "scripts/internal/dev-hub-bridge.py" 2>/dev/null || true
    sleep 0.8
  else
    echo "✅ Dev Hub Bridge juba töötab aktiivselt (PID: $RUNNING_PID, Versioon: v$RUNNING_VER)."
    echo "   URL: http://localhost:8089/"
    exit 0
  fi
fi

echo "🚀 Käivitan Dev Hub Bridge taustal..."
nohup python3 "$BRIDGE_PY" > "$LOG_FILE" 2>&1 &
NEW_PID=$!
sleep 1

if pgrep -f "scripts/internal/dev-hub-bridge.py" >/dev/null 2>&1; then
  echo "✅ Dev Hub Bridge aktiivne (PID: $NEW_PID, Versioon: v$TARGET_VER)."
  echo "   🌐 HTTP:  http://localhost:8089/"
  echo "   🔒 HTTPS: https://localhost:8449/"
  echo "   📄 Logi:  $LOG_FILE"
  echo "   ⚡ Automaatne taaskäivitus (Hot-Reload) failimuudatuste korral on sees!"
else
  echo "⚠️ Käivitamisel ilmnes tõrge. Vaata logi: $LOG_FILE"
  tail -n 10 "$LOG_FILE" 2>/dev/null || true
  exit 1
fi
