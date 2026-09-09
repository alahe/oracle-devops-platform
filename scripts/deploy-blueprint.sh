#!/usr/bin/env bash
# ==============================================================================
# Oracle DevOps Platform — Blueprint Deployment & Lifecycle Manager
# (scripts/deploy-blueprint.sh)
#
# Provides user-friendly CLI commands to inspect, deploy, update, or switch
# between the 11 curated architecture blueprints.
#
# Usage:
#   ./scripts/deploy-blueprint.sh --status
#   ./scripts/deploy-blueprint.sh -b 3
#   ./scripts/deploy-blueprint.sh -b 41 --replace -y
#   ./scripts/deploy-blueprint.sh -b 34 --dry-run
#   ./scripts/deploy-blueprint.sh --list
# ==============================================================================

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source localization and common utilities
# shellcheck source=scripts/internal/i18n.sh
source "$WORKSPACE_DIR/scripts/internal/i18n.sh"
# shellcheck source=scripts/internal/common.sh
source "$WORKSPACE_DIR/scripts/internal/common.sh"
# shellcheck source=scripts/internal/blueprint-info.sh
source "$WORKSPACE_DIR/scripts/internal/blueprint-info.sh"
# shellcheck source=scripts/internal/snapshot-resolver.sh
source "$WORKSPACE_DIR/scripts/internal/snapshot-resolver.sh"

# Default settings
SELECTED_BP=""
ACTION="deploy"
DRY_RUN=false
FORCE=false
LIST_ONLY=false
STATUS_ONLY=false

# ------------------------------------------------------------------------------
# 1. Parse Arguments
# ------------------------------------------------------------------------------
show_help() {
  echo -e "${CYAN}${BOLD}$(msg_str "BP_DEPLOY_HEADER")${NC}"
  echo ""
  echo "Usage: $0 [options]"
  echo ""
  echo "Options:"
  echo "  -b, --blueprint <ID|NAME>  Target blueprint ID (e.g. 3, 7, 11, 13, 21, 22, 31, 34, 41, 42, 43)"
  echo "  -s, --status               Check current active blueprint and container health"
  echo "  -u, --update               Update/restart active blueprint in-place without data reset"
  echo "  -r, --replace              Clean switchover to target blueprint"
  echo "  -d, --dry-run              Simulate deployment without modifying containers"
  echo "  -l, --list                 List all 11 curated architecture blueprints"
  echo "  -y, --yes, --force         Skip interactive confirmations"
  echo "      --lang <LANG>          Language (en, et, fi, sv, lv, lt)"
  echo "  -h, --help                 Show this help message"
  echo ""
  echo "Examples:"
  echo "  $0 --status"
  echo "  $0 -b 3"
  echo "  $0 -b 41"
  echo "  $0 -b 34 --dry-run"
  echo ""
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -b|--blueprint)
      SELECTED_BP="$2"
      shift 2
      ;;
    -s|--status)
      STATUS_ONLY=true
      shift
      ;;
    -u|--update)
      ACTION="update"
      INCREMENTAL=true
      export UPDATE_MODE=true
      export INCREMENTAL_MODE=true
      shift
      ;;
    -r|--replace)
      ACTION="replace"
      shift
      ;;
    -d|--dry-run)
      DRY_RUN=true
      shift
      ;;
    --fast|--skip-tests)
      FAST_MODE=true
      shift
      ;;
    --lock-internal-apex|--lock-apex)
      LOCK_INTERNAL_APEX=true
      shift
      ;;
    --snapshot-mode)
      SNAPSHOT_MODE="$2"
      shift 2
      ;;
    --snapshot-mode=*)
      SNAPSHOT_MODE="${1#*=}"
      shift
      ;;
    --unified-middleware|--unified-fmw)
      UNIFIED_MIDDLEWARE=true
      shift
      ;;
    --incremental)
      INCREMENTAL=true
      shift
      ;;
    -l|--list)
      LIST_ONLY=true
      shift
      ;;
    -y|--yes|--force)
      FORCE=true
      shift
      ;;
    --lang)
      export CLI_LANG="$2"
      export ACTIVE_CLI_LANG="$(resolve_cli_lang)"
      shift 2
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      if [[ "$1" =~ ^[0-9]+$ ]]; then
        SELECTED_BP="$1"
        shift
      else
        echo -e "${RED}Unknown argument: $1${NC}"
        show_help
        exit 1
      fi
      ;;
  esac
done

# ------------------------------------------------------------------------------
# 2. Execute List Only
# ------------------------------------------------------------------------------
if [ "$LIST_ONLY" = true ]; then
  print_blueprints_table
  exit 0
fi

# ------------------------------------------------------------------------------
# 3. Execute Status Only
# ------------------------------------------------------------------------------
detect_active_blueprint() {
  local active_num=""
  if [ -f "$WORKSPACE_DIR/.env" ]; then
    for bpf in $(find "$WORKSPACE_DIR/config/blueprints" -maxdepth 1 -type f -name ".env.*" | sort -V); do
      if cmp -s "$WORKSPACE_DIR/.env" "$bpf" 2>/dev/null; then
        active_num=$(echo "$bpf" | sed -E 's/.*\.env\.([0-9]+).*/\1/')
        echo "$active_num"
        return 0
      fi
    done
  fi
  
  if [ -f "$WORKSPACE_DIR/metrics/setup_benchmarks.env" ]; then
    active_num=$(grep -E "^BENCHMARK_BLUEPRINT=" "$WORKSPACE_DIR/metrics/setup_benchmarks.env" 2>/dev/null | cut -d'=' -f2 | tr -d '"' || true)
    if [ -n "$active_num" ]; then
      echo "$active_num"
      return 0
    fi
  fi
  echo "3"
}

CURRENT_BP="$(detect_active_blueprint)"
CURRENT_BP_FILE="$(get_blueprint_file "$CURRENT_BP" || true)"
CURRENT_BP_NAME="Standard Production Stack"
if [ -n "$CURRENT_BP_FILE" ]; then
  CURRENT_BP_NAME="$(basename "$CURRENT_BP_FILE" | sed -E 's/^\.env\.[0-9]+[-_]?//')"
fi

if [ "$STATUS_ONLY" = true ]; then
  echo ""
  echo -e "${CYAN}${BOLD}==================================================================${NC}"
  echo -e "${CYAN}${BOLD}📊 $(msg_str "BP_DEPLOY_HEADER")${NC}"
  echo -e "${CYAN}${BOLD}==================================================================${NC}"
  msg_print "BP_DEPLOY_ACTIVE_STATUS" "$CURRENT_BP" "$CURRENT_BP_NAME"
  echo ""
  
  if [ -n "$CURRENT_BP_FILE" ]; then
    show_blueprint_details "$CURRENT_BP_FILE"
  fi
  
  echo ""
  echo -e "${BOLD}Active Container Processes:${NC}"
  if command -v podman >/dev/null 2>&1 && podman ps >/dev/null 2>&1; then
    podman ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || true
  elif command -v docker >/dev/null 2>&1 && docker ps >/dev/null 2>&1; then
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || true
  else
    echo "  (Container engine is offline or no containers running)"
  fi
  
  echo ""
  echo -e "💡 ${YELLOW}DevOps Command Center:${NC} ${CYAN}http://localhost:8088/${NC}"
  echo -e "💡 ${YELLOW}Deploy or switch blueprint:${NC} ${GREEN}./scripts/deploy-blueprint.sh -b <ID>${NC}"
  echo ""
  exit 0
fi

# ------------------------------------------------------------------------------
# 4. Validate Target Blueprint
# ------------------------------------------------------------------------------
if [ -z "$SELECTED_BP" ]; then
  echo -e "${YELLOW}No blueprint specified. Defaulting to current active Blueprint #$CURRENT_BP.${NC}"
  SELECTED_BP="$CURRENT_BP"
fi

TARGET_BP_FILE="$(get_blueprint_file "$SELECTED_BP" || true)"
if [ -z "$TARGET_BP_FILE" ] || [ ! -f "$TARGET_BP_FILE" ]; then
  msg_err "BP_DEPLOY_NOT_FOUND" "$SELECTED_BP"
  echo ""
  echo "Available Curated Blueprints:"
  print_blueprints_table
  exit 1
fi

TARGET_BP_NUM=$(echo "$TARGET_BP_FILE" | sed -E 's/.*\.env\.([0-9]+).*/\1/')
TARGET_BP_NAME=$(basename "$TARGET_BP_FILE" | sed -E 's/^\.env\.[0-9]+[-_]?//')

# ------------------------------------------------------------------------------
# 5. Handle Dry-Run Simulation
# ------------------------------------------------------------------------------
if [ "$DRY_RUN" = true ]; then
  msg_print "BP_DEPLOY_DRY_RUN" "$TARGET_BP_NUM"
  simulate_blueprint_dry_run "$TARGET_BP_FILE" "prod"
  exit 0
fi

# ------------------------------------------------------------------------------
# 6. Execute Deployment / Switchover
# ------------------------------------------------------------------------------
echo ""
echo -e "${CYAN}${BOLD}==================================================================${NC}"
echo -e "${CYAN}${BOLD}🚀 $(msg_str "BP_DEPLOY_HEADER")${NC}"
echo -e "${CYAN}${BOLD}==================================================================${NC}"
msg_print "BP_DEPLOY_ACTIVE_STATUS" "$CURRENT_BP" "$CURRENT_BP_NAME"
msg_print "BP_DEPLOY_TARGET" "$TARGET_BP_NUM" "$TARGET_BP_NAME"
echo ""

START_TIME=$(date +%s)
export SELECTED_BLUEPRINT="$TARGET_BP_NUM"
LOG_FILE="$WORKSPACE_DIR/install_logs/deploy_blueprint_${TARGET_BP_NUM}_$(date +"%Y%m%d_%H%M%S").log"
mkdir -p "$(dirname "$LOG_FILE")"
ln -sf "$LOG_FILE" "$WORKSPACE_DIR/install_logs/deploy_bp_${TARGET_BP_NUM}_latest.log" 2>/dev/null || true

if [ "$CURRENT_BP" != "$TARGET_BP_NUM" ]; then
  msg_print "BP_DEPLOY_SWITCHING" "$CURRENT_BP" "$TARGET_BP_NUM"
else
  msg_print "BP_DEPLOY_RESTARTING" "$TARGET_BP_NUM"
fi

# Duplicate Blueprint Execution Prevention (Rule 10):
# If all planned containers are already up and running healthy, report STATUS_ALREADY_ACTIVE
if [ "$ACTION" != "update" ] && [ "${FORCE:-false}" != "true" ] && command -v podman >/dev/null 2>&1; then
  planned_c=$(extract_blueprint_containers "$TARGET_BP_NUM" 2>/dev/null || echo "")
  if [ -n "$planned_c" ]; then
    all_running=true
    for c in $planned_c; do
      if ! podman container exists "$c" 2>/dev/null; then
        all_running=false
        break
      fi
      c_status=$(podman inspect "$c" --format "{{.State.Status}}" 2>/dev/null || echo "")
      if [ "$c_status" != "running" ]; then
        all_running=false
        break
      fi
    done
    if [ "$all_running" = true ]; then
      echo ""
      echo -e "${GREEN}${BOLD}==================================================================${NC}"
      msg_print "BP_ALREADY_ACTIVE" "$TARGET_BP_NUM"
      echo -e "   Running containers: ${CYAN}${planned_c}${NC}"
      echo -e "   💡 To restart or reapply, use: ${YELLOW}./scripts/deploy-blueprint.sh -b ${TARGET_BP_NUM} -u${NC}"
      echo -e "   💡 To run another instance, create a new blueprint file (e.g. .env.<N>) with decoupled ports."
      echo -e "${GREEN}${BOLD}==================================================================${NC}"
      echo ""
      exit 0
    fi
  fi
fi

# Execute setup-all with targeted blueprint and language
SETUP_ARGS=("-b" "$TARGET_BP_NUM")
if [ "$FORCE" = true ]; then
  SETUP_ARGS+=("-y")
  export FORCE=true
  export FORCE_DEPLOY=true
fi
if [ -n "${CLI_LANG:-}" ]; then
  SETUP_ARGS+=("--lang" "$CLI_LANG")
fi
if [ "${FAST_MODE:-false}" = "true" ]; then
  SETUP_ARGS+=("--fast")
fi
if [ "${LOCK_INTERNAL_APEX:-false}" = "true" ]; then
  SETUP_ARGS+=("--lock-internal-apex")
fi
if [ -n "${SNAPSHOT_MODE:-}" ]; then
  SETUP_ARGS+=("--snapshot-mode" "$SNAPSHOT_MODE")
fi
if [ "${UNIFIED_MIDDLEWARE:-false}" = "true" ]; then
  SETUP_ARGS+=("--unified-middleware")
fi
if [ "$ACTION" = "replace" ]; then
  SETUP_ARGS+=("--replace")
fi
if [ "${INCREMENTAL:-false}" = "true" ] || [ "$ACTION" = "update" ]; then
  SETUP_ARGS+=("--incremental")
  export INCREMENTAL_MODE=true
  export UPDATE_MODE=true
fi

"$WORKSPACE_DIR/scripts/setup-all.sh" "${SETUP_ARGS[@]}" 2>&1 | tee -a "$LOG_FILE"

END_TIME=$(date +%s)
TOTAL_SECS=$((END_TIME - START_TIME))
TOTAL_DUR="$(format_duration "$TOTAL_SECS")"

echo ""
echo -e "${GREEN}${BOLD}==================================================================${NC}"
msg_print "BP_DEPLOY_SUCCESS" "$TARGET_BP_NUM"
echo -e "   ⌛ Total Deployment Time: ${CYAN}${TOTAL_DUR}${NC}"
echo -e "   🌐 Dev Hub Command Center: ${CYAN}http://localhost:8088/${NC}"
echo -e "   📋 Log saved to:          ${BLUE}${LOG_FILE}${NC}"
echo -e "${GREEN}${BOLD}==================================================================${NC}"
echo ""
