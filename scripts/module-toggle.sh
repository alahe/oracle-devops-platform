#!/usr/bin/env bash
# ==============================================================================
# Dynamic Module Controller: Start, Stop & Status for Modular Building Blocks (3–9)
# Enforces Core Base Protection (db-alise & app-ords cannot be stopped)
# Usage: ./scripts/module-toggle.sh [status|start|stop|restart] <module_name>
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source common helpers and i18n
[ -f "$SCRIPT_DIR/internal/common.sh" ] && source "$SCRIPT_DIR/internal/common.sh"
[ -f "$SCRIPT_DIR/internal/load-profile.sh" ] && source "$SCRIPT_DIR/internal/load-profile.sh"

ACTION="${1:-status}"
MODULE="${2:-all}"

# Map human-friendly module name to container and compose profile
resolve_module_container() {
  local mod="$1"
  case "$mod" in
    "core"|"alise"|"db-alise") echo "db-alise" ;;
    "ords"|"app-ords"|"gateway") echo "app-ords" ;;
    "proxy"|"db-proxy"|"3") echo "db-proxy" ;;
    "web-ide"|"webide"|"4") echo "web-ide-dev" ;;
    "publisher"|"app-publisher"|"5") echo "oracle-publisher-dev" ;;
    "forms"|"app-forms"|"6") echo "app-forms" ;;
    "gvenzl"|"db-gvenzl"|"7") echo "db-proxy" ;;
    "designer"|"publisher-designer"|"8") echo "app-publisher-designer" ;;
    "forms-publisher"|"forms-pub"|"unified"|"9") echo "app-forms-publisher" ;;
    *) echo "$mod" ;;
  esac
}

resolve_compose_profile() {
  local mod="$1"
  case "$mod" in
    "web-ide"|"webide"|"4") echo "web-ide" ;;
    "publisher"|"app-publisher"|"5") echo "publisher" ;;
    "forms"|"app-forms"|"6") echo "forms" ;;
    "designer"|"publisher-designer"|"8") echo "publisher-designer" ;;
    "forms-publisher"|"forms-pub"|"unified"|"9") echo "forms-publisher" ;;
    *) echo "" ;;
  esac
}

# 1. Action: STATUS
show_status() {
  echo "================================================================================"
  echo "🎛️  ORACLE DEVOPS PLATFORM: DYNAMIC MODULES STATUS (9 BUILDING BLOCKS)"
  echo "================================================================================"
  
  # Core status (Protected)
  echo "🛡️  PROTECTED CORE BASE (Always Active):"
  for core_c in "db-proxy" "app-ords"; do
    if podman container exists "$core_c" 2>/dev/null && [ "$(podman inspect --format='{{.State.Status}}' "$core_c" 2>/dev/null)" = "running" ]; then
      echo "   🟢 $core_c: RUNNING (Protected Core - Cannot be stopped)"
    else
      echo "   ⚪ $core_c: STOPPED (Core offline - run ./scripts/start-containers.sh)"
    fi
  done
  
  echo ""
  echo "🧩 DYNAMIC MODULES (On-Demand / 0 MB Idle RAM when stopped):"
  local modules=("db-proxy:3:APEX SSO Gateway (Port 1532)" \
                 "web-ide-dev:4:VS Code Web IDE (Port 8090)" \
                 "oracle-publisher-dev:5:Analytics Publisher (Port 9502)" \
                 "app-forms:6:Oracle Forms 14c (Port 9001/6082)" \
                 "app-publisher-designer:8:Template Builder Word noVNC (Port 6083)" \
                 "app-forms-publisher:9:Unified Forms+Publisher FMW (Port 9001/9502)")
                 
  for m in "${modules[@]}"; do
    IFS=':' read -r cname nr label <<< "$m"
    if podman container exists "$cname" 2>/dev/null && [ "$(podman inspect --format='{{.State.Status}}' "$cname" 2>/dev/null)" = "running" ]; then
      echo "   🟢 [Module $nr] $cname: RUNNING ($label)"
    else
      echo "   ⚪ [Module $nr] $cname: STOPPED ($label - 0 MB RAM)"
    fi
  done
  echo "================================================================================"
}

# 2. Action: START
start_module() {
  local mod="$1"
  local cname
  cname=$(resolve_module_container "$mod")
  local prof
  prof=$(resolve_compose_profile "$mod")

  echo "🚀 Starting Module: '$mod' (Container: $cname)..."

  # If container already exists, simply start it
  if podman container exists "$cname" 2>/dev/null; then
    podman start "$cname" >/dev/null 2>&1 || true
    echo "✅ Module '$mod' ($cname) is now RUNNING."
    return 0
  fi

  # Otherwise invoke podman-compose with profile
  if [ -n "$prof" ]; then
    podman-compose -f "$WORKSPACE_DIR/podman-compose.yml" --profile "$prof" up -d "$cname" 2>/dev/null || \
    podman-compose -f "$WORKSPACE_DIR/podman-compose.yml" --profile "$prof" up -d 2>/dev/null || true
    echo "✅ Module '$mod' ($cname) started via profile '$prof'."
  else
    podman-compose -f "$WORKSPACE_DIR/podman-compose.yml" up -d "$cname" 2>/dev/null || true
    echo "✅ Module '$mod' ($cname) started."
  fi
}

# 3. Action: STOP
stop_module() {
  local mod="$1"
  local cname
  cname=$(resolve_module_container "$mod")

  # Enforce Core Protection
  if [ "$cname" = "db-proxy" ] || [ "$cname" = "app-ords" ]; then
    echo "❌ ERROR: Container '$cname' belongs to the PROTECTED CORE BASE and cannot be stopped individually!" >&2
    echo "ℹ️  To reset the entire environment, use: ./scripts/reset-all.sh" >&2
    return 1
  fi

  echo "⏹️ Stopping Module: '$mod' ($cname) to free RAM..."
  if podman container exists "$cname" 2>/dev/null; then
    podman stop "$cname" >/dev/null 2>&1 || true
    echo "✅ Module '$mod' ($cname) STOPPED (0 MB RAM)."
  else
    echo "ℹ️  Module '$mod' ($cname) is not currently created/running."
  fi
}

case "$ACTION" in
  status|list)
    show_status
    ;;
  start|setup|activate)
    [ "$MODULE" = "all" ] && { echo "Specify module to start (e.g. ./scripts/module-toggle.sh start web-ide)"; exit 1; }
    start_module "$MODULE"
    ;;
  stop)
    [ "$MODULE" = "all" ] && { echo "Specify module to stop (e.g. ./scripts/module-toggle.sh stop web-ide)"; exit 1; }
    stop_module "$MODULE"
    ;;
  restart)
    [ "$MODULE" = "all" ] && { echo "Specify module to restart"; exit 1; }
    stop_module "$MODULE" || true
    start_module "$MODULE"
    ;;
  *)
    echo "Usage: $0 [status|start|stop|restart] <module_name>"
    exit 1
    ;;
esac
