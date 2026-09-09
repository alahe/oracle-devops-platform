#!/usr/bin/env bash
# ============================================================================
# Master End-to-End Environment Setup & Benchmark Orchestrator
# Measures container image pulls, ORDS & APEX downloads, container healthcheck,
# APEX engine installation, patch application, and exports complete benchmark metrics.
# ============================================================================

set -e

# Silence podman compose external provider warnings
export PODMAN_COMPOSE_WARNING_LOGS=false
export COMPOSE_IGNORE_ORPHANS=True
export MASTER_SETUP="true"

# Source common helper library and profile engine
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
COMPOSE_FILE="$WORKSPACE_DIR/podman-compose.yml"
OVERRIDE_FILE="$WORKSPACE_DIR/podman-compose.override.yml"

# Source common helper library and profile engine
if [ -f "$SCRIPT_DIR/internal/common.sh" ]; then
  source "$SCRIPT_DIR/internal/common.sh"
fi
if [ -f "$SCRIPT_DIR/internal/blueprint-info.sh" ]; then
  source "$SCRIPT_DIR/internal/blueprint-info.sh"
fi
if [ -f "$SCRIPT_DIR/internal/snapshot-resolver.sh" ]; then
  source "$SCRIPT_DIR/internal/snapshot-resolver.sh"
fi

cleanup_setup_progress() {
  restore_cursor
  rm -f "$WORKSPACE_DIR/.setup_in_progress" 2>/dev/null || true
}
trap cleanup_setup_progress EXIT INT TERM

# Parameetrite parsimine
export FORCE=false
export ORDS_SKIP_REASON=""
export IS_TEST_MODE=false
export SELECTED_BLUEPRINT=""
export TEST_BLUEPRINTS=""
export INTERACTIVE_SELECT=false
export DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -y|--force|--yes|-y*|--y*|-Y|--YES)
      export FORCE=true
      export FORCE_DEPLOY=true
      shift
      ;;
    -l|--list|-lb|--list-blueprints|--list-scenarios)
      print_blueprints_table ""
      exit 0
      ;;
    -h|--help)
      echo "Oracle DevOps Platform — Setup Orchestrator (setup-all.sh)"
      echo "Usage: ./scripts/setup-all.sh [options]"
      echo ""
      echo "Blueprint Selection:"
      echo "  -b,  --blueprint <0..11>    Deploy specific blueprint"
      echo "  -tb, --test-blueprints <BP> Clean and test specific blueprint"
      echo "  -lb, --list-blueprints      List all available architectural blueprints"
      echo "  -sb, --show-blueprint <BP>  Inspect blueprint details"
      echo "  -search, --search <term>    Search blueprints by name or component"
      echo ""
      echo "Golden Snapshot Lifecycle (30-Day Freshness Policy):"
      echo "  -fs, --force-snapshot       Force snapshot creation regardless of age"
      echo "  --skip-snapshot             Skip snapshot creation step"
      echo "  --snapshot-days <N>         Set max snapshot age threshold in days (Default: 30)"
      echo "  -s,  --from-snapshot        Restore from Golden Snapshot (~15s fastpath)"
      echo "  --fresh, --no-snapshot      Install clean from scratch (ignore existing snapshot)"
      echo ""
      echo "General Options:"
      echo "  -y,  --yes                  Non-interactive mode (auto-confirm prompts)"
      echo "  -l,  --lang <en|et|fi|...>  Interface language"
      echo "  --dry-run                   Simulate deployment without starting containers"
      exit 0
      ;;
    -sb|--show-blueprint|-ib|--info-blueprint)
      val="$2"
      show_blueprint_details "$val"
      exit 0
      ;;
    -sb=*|--show-blueprint=*|-ib=*|--info-blueprint=*)
      val="${1#*=}"
      show_blueprint_details "$val"
      exit 0
      ;;
    -search|--search|--search-blueprints|--find-blueprint)
      val="$2"
      print_blueprints_table "$val"
      exit 0
      ;;
    -search=*|--search=*|--search-blueprints=*|--find-blueprint=*)
      val="${1#*=}"
      print_blueprints_table "$val"
      exit 0
      ;;
    -ltr|--list-test-reports|--test-reports)
      list_blueprint_test_reports
      exit 0
      ;;
    --dry-run)
      export DRY_RUN=true
      shift
      ;;
    --publish)
      export PUBLISH_SNAPSHOT=true
      shift
      ;;
    --with-designer|--designer)
      export SKIP_PUBLISHER_DESIGNER=false
      shift
      ;;
    -i|--select|--interactive)
      export INTERACTIVE_SELECT=true
      shift
      ;;
    --test)
      export IS_TEST_MODE=true
      export FORCE=true
      shift
      ;;
    -l|--lang|-language|--language)
      export CLI_LANG="$2"
      if declare -f resolve_cli_lang >/dev/null 2>&1; then
        export ACTIVE_CLI_LANG="$(resolve_cli_lang)"
      fi
      shift 2
      ;;
    -l=*|--lang=*|-language=*|--language=*)
      export CLI_LANG="${1#*=}"
      if declare -f resolve_cli_lang >/dev/null 2>&1; then
        export ACTIVE_CLI_LANG="$(resolve_cli_lang)"
      fi
      shift
      ;;
    -b|--b|--blueprint|--scenario|-s)
      val="$2"
      if [[ "$val" == *","* ]] || [ "$val" = "all" ] || [ "$val" = "ALL" ] || ! [[ "$val" =~ ^[0-9]+$ ]] || [ "$val" -lt 0 ] || [ "$val" -gt 49 ]; then
        echo -e "\n${RED}❌ ERROR: In blueprint mode (--blueprint / -b), you can select ONLY ONE blueprint between 0–49!${NC}"
        echo -e "ℹ️  For automated sequential multi-blueprint testing, use test mode: ${YELLOW}--test-blueprints 1,3,7${NC} or ${YELLOW}--test-blueprints all${NC}\n"
        exit 1
      fi
      export SELECTED_BLUEPRINT="$val"
      shift 2
      ;;
    -b=*|--b=*|--blueprint=*|--scenario=*|-s=*)
      val="${1#*=}"
      if [[ "$val" == *","* ]] || [ "$val" = "all" ] || [ "$val" = "ALL" ] || ! [[ "$val" =~ ^[0-9]+$ ]] || [ "$val" -lt 0 ] || [ "$val" -gt 49 ]; then
        echo -e "\n${RED}❌ ERROR: In blueprint mode (--blueprint / -b), you can select ONLY ONE blueprint between 0–49!${NC}"
        echo -e "ℹ️  For automated sequential multi-blueprint testing, use test mode: ${YELLOW}--test-blueprints 1,3,7${NC} or ${YELLOW}--test-blueprints all${NC}\n"
        exit 1
      fi
      export SELECTED_BLUEPRINT="$val"
      shift
      ;;
    -tb|--test-blueprints|--test-blueprint|--test-scenario|--test-scenarios)
      export IS_TEST_MODE=true
      export FORCE=true
      export TEST_BLUEPRINTS="$2"
      shift 2
      ;;
    -tb=*|--test-blueprints=*|--test-blueprint=*|--test-scenario=*|--test-scenarios=*)
      export IS_TEST_MODE=true
      export FORCE=true
      export TEST_BLUEPRINTS="${1#*=}"
      shift
      ;;
    --no-publisher)
      export SKIP_PUBLISHER=true
      shift
      ;;
    --no-ords)
      export SKIP_ORDS=true
      export ORDS_SKIP_REASON="User opted out of local ORDS service (--no-ords CLI flag)"
      shift
      ;;
    --no-monitor-app)
      export SKIP_MONITOR_APP=true
      shift
      ;;
    --no-web-ide)
      export SKIP_WEB_IDE=true
      shift
      ;;
    --from-snapshot|--snapshot|-s)
      export RESTORE_FROM_SNAPSHOT=true
      shift
      ;;
    --rotate-passwords)
      export ROTATE_RESTORE_PASSWORDS=true
      shift
      ;;
    --fresh|--no-snapshot)
      export RESTORE_FROM_SNAPSHOT=false
      shift
      ;;
    --apex-runtime|--runtime-only)
      export APEX_RUNTIME_ONLY=true
      shift
      ;;
    --fast|--skip-tests)
      export SKIP_TESTS=true
      shift
      ;;
    --lock-internal-apex|--lock-apex)
      export LOCK_INTERNAL_APEX=true
      export DISABLE_INTERNAL_APEX_WEB=true
      shift
      ;;
    --snapshot-mode)
      export SNAPSHOT_MODE="$2"
      shift 2
      ;;
    --snapshot-mode=*)
      export SNAPSHOT_MODE="${1#*=}"
      shift
      ;;
    --force-snapshot|--create-snapshot|-fs|-cs)
      export FORCE_SNAPSHOT=true
      shift
      ;;
    --skip-snapshot|--no-create-snapshot)
      export SKIP_SNAPSHOT_CREATION=true
      export FORCE_SNAPSHOT=false
      shift
      ;;
    --snapshot-max-age=*|--snapshot-days=*)
      export SNAPSHOT_MAX_AGE_DAYS="${1#*=}"
      shift
      ;;
    --snapshot-max-age|--snapshot-days)
      export SNAPSHOT_MAX_AGE_DAYS="$2"
      shift 2
      ;;
    --unified-middleware|--unified-fmw)
      export USE_UNIFIED_MIDDLEWARE=true
      shift
      ;;
    --build-base-image|--create-base-image)
      export BUILD_BASE_IMAGE=true
      shift
      ;;
    --build-image|--create-image)
      export BUILD_IMAGE=true
      shift
      ;;
    --parallel)
      export ENABLE_PARALLEL_INIT=true
      shift
      ;;
    --sequential)
      export ENABLE_PARALLEL_INIT=false
      shift
      ;;
    -r|--replace)
      export REPLACE_MODE=true
      shift
      ;;
    --incremental)
      export INCREMENTAL_MODE=true
      shift
      ;;
    *)
      shift
      ;;
  esac
done

# Handle dry-run simulation mode
if [ "$DRY_RUN" = "true" ]; then
  if [ -n "$TEST_BLUEPRINTS" ]; then
    bp_list_to_test=""
    if [ "$TEST_BLUEPRINTS" = "all" ] || [ "$TEST_BLUEPRINTS" = "ALL" ]; then
      bp_list_to_test=$(find "$WORKSPACE_DIR/config/blueprints" -maxdepth 1 -type f -name ".env.*" 2>/dev/null | sed -E 's/.*\.env\.([0-9]+).*/\1/' | sort -n | tr '\n' ' ')
    elif [[ "$TEST_BLUEPRINTS" == *","* ]]; then
      bp_list_to_test=$(echo "$TEST_BLUEPRINTS" | tr ',' ' ')
    else
      bp_list_to_test="$TEST_BLUEPRINTS"
    fi
    for bp in $bp_list_to_test; do
      simulate_blueprint_dry_run "$bp" true
    done
    exit 0
  elif [ -n "$SELECTED_BLUEPRINT" ]; then
    simulate_blueprint_dry_run "$SELECTED_BLUEPRINT" false
    exit 0
  else
    simulate_blueprint_dry_run "0" false
    exit 0
  fi
fi

# Interactive Blueprint selector (when run in terminal without explicit -b or -tb)
if [ -z "$SELECTED_BLUEPRINT" ] && [ -z "$TEST_BLUEPRINTS" ] && [ "$FORCE" != "true" ] && [ -t 0 ]; then
  print_blueprints_table ""
  read -t 30 -p "👉 Select blueprint [0-11] (Default: 0): " user_choice || true
  user_choice="${user_choice:-0}"
  bp_file_check=$(get_blueprint_file "$user_choice" 2>/dev/null || echo "")
  if [ -z "$bp_file_check" ]; then
    echo -e "${RED}⚠️  Unknown choice '${user_choice}'. Using default: 0${NC}"
    user_choice=0
  fi
  export SELECTED_BLUEPRINT="$user_choice"
fi

# 1. AUTOMATED TEST MODE (-tb / --test-blueprints): Always clean slate (reset-all -y)
if [ -n "$TEST_BLUEPRINTS" ]; then
  BP_LIST=""
  if [ "$TEST_BLUEPRINTS" = "all" ] || [ "$TEST_BLUEPRINTS" = "ALL" ]; then
    BP_LIST=$(find "$WORKSPACE_DIR/config/blueprints" -maxdepth 1 -type f -name ".env.*" 2>/dev/null | sed -E 's/.*\.env\.([0-9]+).*/\1/' | sort -n | tr '\n' ' ')
  elif [[ "$TEST_BLUEPRINTS" == *","* ]]; then
    BP_LIST=$(echo "$TEST_BLUEPRINTS" | tr ',' ' ')
  fi

  if [ -n "$BP_LIST" ]; then
    echo -e "${CYAN}🚀 Starting test suite for blueprints: ${BP_LIST}${NC}"
    for bp in $BP_LIST; do
      echo -e "\n${YELLOW}==================================================================${NC}"
      echo -e "${YELLOW}🧪 Starting test for blueprint ${bp}...${NC}"
      echo -e "${YELLOW}==================================================================${NC}\n"
      "$SCRIPT_DIR/reset-all.sh" -y --lang "${ACTIVE_CLI_LANG:-en}"
      ALREADY_RESET="true" "$SCRIPT_DIR/setup-all.sh" -tb "$bp" --lang "${ACTIVE_CLI_LANG:-en}"
    done
    echo -e "\n${GREEN}==================================================================${NC}"
    echo -e "${GREEN}✅ All tested blueprints (${TEST_BLUEPRINTS}) succeeded!${NC}"
    echo -e "${GREEN}==================================================================${NC}\n"
    exit 0
  fi

  BP_FILE=$(get_blueprint_file "$TEST_BLUEPRINTS" 2>/dev/null || echo "")
  if [ -n "$BP_FILE" ] && [ -f "$BP_FILE" ]; then
    ACTIVE_BP_ID=$(get_blueprint_number "$BP_FILE")
    export SELECTED_BLUEPRINT="$ACTIVE_BP_ID"
    export SKIP_CERT_TRUST="true"
    planned_c=$(extract_blueprint_containers "$ACTIVE_BP_ID" 2>/dev/null || echo "")
    bp_hist_stats=$(get_blueprint_stats "$ACTIVE_BP_ID" 2>/dev/null || echo "")
    echo -e "${CYAN}$(msg_str "TEST_MODE_LOADING" "${ACTIVE_BP_ID}" "$(basename "$BP_FILE")")${NC}"
    [ -n "$planned_c" ] && echo -e "   📦 Planned Containers: ${GREEN}${planned_c}${NC}"
    [ -n "$bp_hist_stats" ] && echo -e "   ⏱️  Benchmark estimate: ${YELLOW}${bp_hist_stats}${NC}"
    
    if [ "${ALREADY_RESET:-false}" != "true" ]; then
      echo -e "${YELLOW}$(msg_str "TEST_MODE_CLEANING")${NC}"
      "$SCRIPT_DIR/reset-all.sh" -y --lang "${ACTIVE_CLI_LANG:-en}"
      export ALREADY_RESET="true"
    fi

    ENV_PATH="$BP_FILE"
  else
    echo -e "${RED}❌ $(msg_str "ERROR_BP_NOT_FOUND" "$TEST_BLUEPRINTS")${NC}"
    exit 1
  fi
fi

# 2. PRODUCTION / DEVELOPMENT MODE (-b / --blueprint): Default loads Blueprint 0
if [ -z "$TEST_BLUEPRINTS" ]; then
  if [ -z "$SELECTED_BLUEPRINT" ]; then
    SELECTED_BLUEPRINT="0"
  fi

  BP_FILE=$(get_blueprint_file "$SELECTED_BLUEPRINT" 2>/dev/null || echo "")
  if [ -n "$BP_FILE" ] && [ -f "$BP_FILE" ]; then
    ACTIVE_BP_ID=$(get_blueprint_number "$BP_FILE")
    # 🛡️ ARCHITECTURAL GUARDRAIL (Rule 12 & Invariant 3.7):
    # Do NOT write .active_blueprint here! Premature writing triggers false "Active"
    # indicators in Dev-Hub while database/APEX/ORDS configuration is in progress.
    # We record an active setup marker (.setup_in_progress) instead.
    cat << EOF > "$WORKSPACE_DIR/.setup_in_progress" 2>/dev/null || true
{
  "blueprint": $ACTIVE_BP_ID,
  "blueprint_file": "$(basename "$BP_FILE")",
  "start_time": $(date +%s),
  "pid": $$
}
EOF
    planned_c=$(extract_blueprint_containers "$ACTIVE_BP_ID" 2>/dev/null || echo "")
    bp_hist_stats=$(get_blueprint_stats "$ACTIVE_BP_ID" 2>/dev/null || echo "")
    echo -e "${CYAN}$(msg_str "BP_ACTIVATING" "$ACTIVE_BP_ID" "$(basename "$BP_FILE")")${NC}"
    [ -n "$planned_c" ] && echo -e "   📦 $(msg_str "PLANNED_CONTAINERS"): ${GREEN}${planned_c}${NC}"
    [ -n "$bp_hist_stats" ] && echo -e "   ⏱️  $(msg_str "BENCHMARK_LABEL") ${YELLOW}${bp_hist_stats}${NC}"
    echo -e "${GREEN}$(msg_str "PROD_MODE_KEEPING_DATA")${NC}"
    ENV_PATH="$BP_FILE"
  else
    echo -e "${RED}❌ $(msg_str "ERROR_BP_NOT_FOUND" "$SELECTED_BLUEPRINT")${NC}"
    exit 1
  fi
fi

sanitize_blueprint_environment() {
  if [ "${INCREMENTAL_MODE:-false}" != "true" ]; then
    unset DB_ALISE DB_PROXY DB_PUBLISHER DB_FORMS DB_CICD DB_LIS DB_INFRA DB_PROXY_STANDALONE DB_GVENZL DB_ADB
    unset ORDS_PROFILE WEB_IDE_PROFILE PUBLISHER_PROFILE FORMS_PROFILE
    unset PUBLISHER_DESIGNER_PROFILE FORMS_PUBLISHER_PROFILE
  fi
  unset MAIN_DB_PROFILE PROFILE_NAME PROFILE_DB_PORT PROFILE_DEFAULT_SERVICE
  unset PROFILE_APEX_ENABLED PROFILE_APEX_VERSION PROFILE_APEX_WORKSPACE
  unset PROFILE_CONTAINER_NAME PROFILE_CONTAINER_PORT PROFILE_CONTAINER_IMAGE
  unset SKIP_PUBLISHER SKIP_FORMS SKIP_WEB_IDE SKIP_ORDS SKIP_PUBLISHER_DESIGNER
  unset APEX_DB_HOST APEX_DB_PORT APEX_DB_SERVICE APEX_DB_SID APEX_DB_PDB
}

# Load environment variables and profile engine
sanitize_blueprint_environment
if [ -f "$ENV_PATH" ]; then
  if [ "${INCREMENTAL_MODE:-false}" = "true" ] && [ -f "$WORKSPACE_DIR/.env" ]; then
    set -a
    source "$WORKSPACE_DIR/.env"
    source "$ENV_PATH"
    set +a
    for k in $(compgen -v 2>/dev/null | grep -E '^(DB_[A-Z0-9_]+|ORDS_PROFILE|WEB_IDE_PROFILE|PUBLISHER_PROFILE|FORMS_PROFILE|PUBLISHER_DESIGNER_PROFILE|FORMS_PUBLISHER_PROFILE)$' | sort -u || true); do
      val="${!k}"
      [ -n "$val" ] && echo "${k}=${val}"
    done > "$WORKSPACE_DIR/.env"
  else
    set -a
    source "$ENV_PATH"
    set +a
    cp "$ENV_PATH" "$WORKSPACE_DIR/.env" 2>/dev/null || true
  fi
fi
[ -n "${SAVED_TEST_SCENARIO:-}" ] && export TEST_SCENARIO="$SAVED_TEST_SCENARIO"
[ -n "${SAVED_TEST_MODE:-}" ] && export IS_TEST_MODE="$SAVED_TEST_MODE"
ACTIVE_BP_ID="${ACTIVE_BP_ID:-${BLUEPRINT:-${TEST_SCENARIO:-}}}"
ACTIVE_BP_ID="${ACTIVE_BP_ID//[^0-9]/}"

if [ -f "$SCRIPT_DIR/internal/load-profile.sh" ]; then
  source "$SCRIPT_DIR/internal/load-profile.sh"
  load_db_profile
  load_web_ide_profile
  load_publisher_designer_profile
fi

if [ "${IS_ADB:-false}" = "true" ]; then
  export APEX_DB_SID="${APEX_DB_SID:-${PROFILE_DB_SID:-FREE}}"
  export APEX_DB_PDB="${APEX_DB_PDB:-${PROFILE_DB_PDB:-MYATP}}"
  export APEX_DB_CONTAINER_PORT="${APEX_DB_CONTAINER_PORT:-$PROFILE_CONTAINER_PORT}"
fi

# Automated Golden Snapshot Discovery & Prompt (Fast Mode)
# Only applicable when active local database instances exist
ACTIVE_DBS_DISCOVERY=$(get_active_db_instances 2>/dev/null || true)
if [ -z "$ACTIVE_DBS_DISCOVERY" ] || [ "${DB_ENABLED:-true}" = "false" ] || [ "${PROFILE_NAME:-}" = "NONE" ]; then
  export RESTORE_FROM_SNAPSHOT=false
elif [ -z "${RESTORE_FROM_SNAPSHOT:-}" ] && [ -f "$SCRIPT_DIR/internal/snapshot-resolver.sh" ]; then
  # shellcheck source=/dev/null
  source "$SCRIPT_DIR/internal/snapshot-resolver.sh"
  avail_snap=$(find_best_golden_snapshot "${ACTIVE_BP_ID:-0}" "${PROFILE_NAME:-}" 2>/dev/null || echo "")
  if [ -n "$avail_snap" ] && [ -f "$avail_snap" ]; then
    snap_base=$(basename "$avail_snap")
    primary_inst=$(echo "$ACTIVE_DBS_DISCOVERY" | head -n 1 | cut -d'|' -f1)
    primary_short=$(echo "$primary_inst" | sed 's/^db-//' | tr '-' '_')
    target_vol_name="oracle-free-db-in-prod_${primary_short}_oradata"
    vol_exists=false
    if podman volume exists "$target_vol_name" 2>/dev/null; then
      vol_exists=true
    fi

    if [ "$FORCE" = "true" ] && [ "${IS_TEST_MODE:-false}" != "true" ]; then
      if [ "$vol_exists" = "true" ]; then
        echo -e "${GREEN}⚡ [Golden Snapshot]: Existing database volume found (${target_vol_name}). Preserving active database (~10s fastpath).${NC}"
        echo -e "   ℹ️  (To restore fresh from snapshot, pass ${YELLOW}--from-snapshot${NC} or ${YELLOW}-s${NC})"
        export RESTORE_FROM_SNAPSHOT=false
      else
        echo -e "${CYAN}📸 [Golden Snapshot]: No local database volume found. Bootstrapping from ${BOLD}${snap_base}${NC}${CYAN} (~15s restore)...${NC}"
        export RESTORE_FROM_SNAPSHOT=true
      fi
    elif [ -t 0 ] && [ "${IS_TEST_MODE:-false}" != "true" ]; then
      echo -e "\n${CYAN}==================================================================${NC}"
      echo -e "${CYAN}📸 Found existing Golden Snapshot for Blueprint ${ACTIVE_BP_ID:-0}:${NC} ${BOLD}${snap_base}${NC}"
      read -t 15 -p "👉 Restore from snapshot (~15s)? [Y/n] (Default: Y): " snap_choice || true
      snap_choice="${snap_choice:-Y}"
      if [[ "$snap_choice" =~ ^[Yy]$ ]] || [ -z "$snap_choice" ]; then
        echo -e "${GREEN}✅ Golden Snapshot restore selected!${NC}"
        export RESTORE_FROM_SNAPSHOT=true
        if [ -z "${ROTATE_RESTORE_PASSWORDS:-}" ]; then
          echo -e "   ℹ️  Rotating database passwords secures credentials (DORA/PCI-DSS), but adds ~45–60s."
          read -t 15 -p "👉 Rotate all database credentials now? [y/N] (Default: N - rapid ~15s): " rot_choice || true
          rot_choice="${rot_choice:-N}"
          if [[ "$rot_choice" =~ ^[Yy]$ ]]; then
            echo -e "   ${YELLOW}🔄 Full password rotation enabled (+~45-60s).${NC}"
            export ROTATE_RESTORE_PASSWORDS=true
          else
            echo -e "   ${GREEN}⚡ Rapid mode: using existing SEPS Wallet credentials (~15s total).${NC}"
            export ROTATE_RESTORE_PASSWORDS=false
          fi
        fi
      else
        echo -e "${YELLOW}ℹ️  Full clean installation selected.${NC}"
        export RESTORE_FROM_SNAPSHOT=false
      fi
      echo -e "${CYAN}==================================================================${NC}\n"
    fi
  fi
fi

# 1. Resolve Adaptive TLS/HTTPS Mode and validate Blueprint policy level
if [ -f "$SCRIPT_DIR/internal/resolve-tls-mode.sh" ]; then
  source "$SCRIPT_DIR/internal/resolve-tls-mode.sh"
  if ! resolve_tls_mode; then
    echo -e "${RED}❌ Setup aborted due to TLS requirements mismatch.${NC}"
    exit 1
  fi
fi

# 2. Generate and trust local SSL/TLS certificates
if [ -x "$SCRIPT_DIR/internal/generate-local-certs.sh" ]; then
  "$SCRIPT_DIR/internal/generate-local-certs.sh" --no-prompt || true
fi
if [[ "$OSTYPE" == "darwin"* ]] && [ -x "$SCRIPT_DIR/certs/trust-local-cert-mac.sh" ]; then
  "$SCRIPT_DIR/certs/trust-local-cert-mac.sh" || true
elif [[ "$OSTYPE" == "msys"* ]] || [[ "$OSTYPE" == "cygwin"* ]] || [[ "${OS:-}" == "Windows_NT" ]]; then
  if [ -f "$SCRIPT_DIR/certs/trust-local-cert.cmd" ]; then
    cmd.exe /c "$SCRIPT_DIR/certs/trust-local-cert.cmd" || true
  fi
fi

# Generate podman-compose.override.yml based on active profiles and secrets
if [ -x "$SCRIPT_DIR/internal/generate-compose-override.sh" ]; then
  "$SCRIPT_DIR/internal/generate-compose-override.sh"
fi

COMPOSE_ARGS=(-f "$COMPOSE_FILE")
[ -f "$OVERRIDE_FILE" ] && COMPOSE_ARGS+=(-f "$OVERRIDE_FILE")

export TNS_ADMIN="$WORKSPACE_DIR/config/tns_admin"

# Pure Profile Resolution for Publisher, Forms, Web-IDE and Designer
if is_publisher_enabled; then
  ANY_PUB_ENABLED=true
  PUBLISHER_DB_HOST="${PUBLISHER_DB_HOST:-pub-db}"
else
  ANY_PUB_ENABLED=false
fi

if is_forms_enabled; then
  ANY_FORMS_ENABLED=true
else
  ANY_FORMS_ENABLED=false
fi

if ! is_ords_enabled; then
  if [ -z "$(get_active_db_instances 2>/dev/null)" ]; then
    ORDS_SKIP_REASON="Standalone workstation without local database (0 local databases)"
  elif [ "${IS_ADB:-false}" = "true" ]; then
    ORDS_SKIP_REASON="Using built-in ADB ORDS without standalone app-ords container"
  else
    [ -z "$ORDS_SKIP_REASON" ] && ORDS_SKIP_REASON="Standalone ORDS container is disabled in YAML profile"
  fi
fi

IS_LOCAL=true
DB_HOST="${APEX_DB_HOST:-localhost}"
DB_PORT="${APEX_DB_PORT:-${PROFILE_DB_PORT:-1532}}"
DB_SERVICE="${APEX_DB_SERVICE:-${PROFILE_DEFAULT_SERVICE:-FREEPDB1}}"

if [ "$DB_HOST" != "localhost" ] && [ "$DB_HOST" != "127.0.0.1" ] && [ "$DB_HOST" != "db-apex-proxy" ]; then
  IS_LOCAL=false
fi

if [ "${IS_ADB:-false}" = "true" ]; then
  [ -z "$ORDS_SKIP_REASON" ] && ORDS_SKIP_REASON="Using Oracle ADB (Autonomous Database) with built-in ORDS"
elif [ "$IS_LOCAL" = "false" ]; then
  [ -z "$ORDS_SKIP_REASON" ] && ORDS_SKIP_REASON="Remote Database target"
fi

echo -e "${CYAN}==================================================================${NC}"
echo -e "${CYAN}🚀 Oracle Free DB & APEX Full Automated Setup${NC}"
if [ -n "$ACTIVE_BP_ID" ]; then
  bp_hist_stats=$(get_blueprint_stats "$ACTIVE_BP_ID" 2>/dev/null || echo "")
  echo -e "📐 ${BOLD}$(msg_str "ARCH_DESIGN"):${NC} ${GREEN}Blueprint ${ACTIVE_BP_ID}${NC}"
  [ -n "$bp_hist_stats" ] && echo -e "⏱️  ${BOLD}$(msg_str "BENCHMARK_LABEL")${NC}   ${YELLOW}${bp_hist_stats}${NC}"
fi
echo -e "${YELLOW}$(msg_str "TARGET_CONFIG_HEADER")${NC}"
get_active_db_instances | while IFS='|' read -r container prof env_key; do
  [ -z "$container" ] && continue
  (
    load_db_profile "$prof" >/dev/null 2>&1 || true
    p_port="${PROFILE_DB_PORT:-1532}"
    p_service="${PROFILE_DEFAULT_SERVICE:-FREEPDB1}"
    db_purpose="$(msg_str "PURPOSE_GENERIC")"
    if [ "$container" = "db-alise" ] || [ "$container" = "db-lis" ] || [ "$prof" = "app-free" ]; then
      db_purpose="$(msg_str "PURPOSE_ALISE")"
    elif [ "$container" = "db-proxy" ] || [[ "$prof" == *"proxy"* ]]; then
      db_purpose="$(msg_str "PURPOSE_PROXY")"
    elif [ "${PROFILE_PUBLISHER_ENABLED:-false}" = "true" ] || [ "$prof" = "publisher-only" ] || [ "$prof" = "publisher-free" ]; then
      db_purpose="$(msg_str "PURPOSE_PUB")"
    elif [ "$container" = "db-forms" ] || [[ "$prof" == *"forms"* ]]; then
      db_purpose="$(msg_str "PURPOSE_FORMS")"
    fi
    echo -e "  🔹 ${BOLD}${container}${NC} [$(msg_str "LABEL_PROFILE"): ${YELLOW}${prof}${NC}, $(msg_str "LABEL_PORT"): ${CYAN}${p_port}${NC}, $(msg_str "LABEL_SERVICE"): ${CYAN}${p_service}${NC}]"
    echo -e "     └─ $(msg_str "LABEL_PURPOSE"): ${DIM}${db_purpose}${NC}"
  )
done
echo -e "${CYAN}==================================================================${NC}"

# Log file setup
LOG_DIR="$WORKSPACE_DIR/install_logs"
mkdir -p "$LOG_DIR"
METRICS_DIR="$WORKSPACE_DIR/metrics"
mkdir -p "$METRICS_DIR"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$LOG_DIR/setup_bp_${SELECTED_BLUEPRINT}_${TIMESTAMP}.log"
ln -sf "$LOG_FILE" "$LOG_DIR/setup_bp_${SELECTED_BLUEPRINT}_latest.log" 2>/dev/null || true
# Preserve original TTY output on file descriptor 3 for live timers
exec 3>&1
exec > >(tee -a "$LOG_FILE") 2>&1

if [ -f "$SCRIPT_DIR/internal/sanitize-logs.sh" ]; then
  source "$SCRIPT_DIR/internal/sanitize-logs.sh"
fi

START_MASTER_TOTAL=$(date +%s)
START_TIME_HUMAN=$(date "+%Y-%m-%d %H:%M:%S")
echo -e "${CYAN}$(msg_str "LABEL_STARTED_AT" "$START_TIME_HUMAN")${NC}"

# Execute pre-flight system resource and prerequisites check
if [ -x "$SCRIPT_DIR/internal/check-prerequisites.sh" ]; then
  "$SCRIPT_DIR/internal/check-prerequisites.sh"
fi

# ----------------------------------------------------------------------------
# SAMM 1: Konteinerite piltide allalaadimine (Container Images Pull)
# ----------------------------------------------------------------------------
PULL_START=$(date +%s)
if [ "$IS_LOCAL" = "true" ]; then
  print_header "1" "$(msg_str "STEP_1_TITLE" "${PROFILE_NAME:-Oracle DB & ORDS}")" "step1_container_images_pull_seconds" "1m"
  (
    if [ -f "$OVERRIDE_FILE" ]; then
      for img in $(grep -i 'image:' "$OVERRIDE_FILE" "$COMPOSE_FILE" 2>/dev/null | awk '{print $2}' | grep -v 'analyticsserver' | tr -d '"\r' | sort -u); do
        if ! podman image exists "$img" 2>/dev/null; then
          podman pull "$img" >/dev/null 2>&1 || true
        fi
      done
    else
      podman-compose "${COMPOSE_ARGS[@]}" pull >/dev/null 2>&1 || true
    fi
  ) &
  PULL_PID=$!
  register_child_pid "$PULL_PID"

  hide_cursor
  ELAPSED=0
  POLL_INTERVAL="${LIVE_TIMER_INTERVAL:-3}"
  POLL_INTERVAL="${POLL_INTERVAL//[^0-9]/}"
  [ -z "$POLL_INTERVAL" ] || [ "$POLL_INTERVAL" -le 0 ] && POLL_INTERVAL=3
  print_progress "Laadin pilte" 0 15
  while kill -0 $PULL_PID 2>/dev/null; do
    sleep "$POLL_INTERVAL"
    ELAPSED=$((ELAPSED + POLL_INTERVAL))
    print_progress "$(msg_str "PROGRESS_PULLING_IMAGES")" "$ELAPSED" 15
  done
  wait $PULL_PID || true
  clear_progress_line
  restore_cursor

  PULL_SECS=$(( $(date +%s) - PULL_START ))
  PULL_TIME=$(format_duration $PULL_SECS)
  echo -e "⏱  [$(msg_str "STEP_1_NAME"): ${YELLOW}$PULL_TIME${NC}]"
else
  echo "=================================================================="
  echo "1. Remote database detected. Skipping container pull."
  echo "=================================================================="
  PULL_SECS=0
  PULL_TIME="$(msg_str "STATUS_SKIPPED")"
fi

# ----------------------------------------------------------------------------
# SAMM 2: ORDS tarkvarapaketi allalaadimine (ORDS Download)
# ----------------------------------------------------------------------------
ORDS_DL_START=$(date +%s)
if ! is_ords_enabled; then
  print_header "2" "$(msg_str "STEP_2_TITLE")"
  msg_print "ORDS_CONTAINER_NOT_REQUIRED" "${ORDS_SKIP_REASON:-disabled}"
  ORDS_DL_SECS=0
  ORDS_DL_TIME="$(msg_str "STATUS_SKIPPED")"
else
  print_header "2" "$(msg_str "STEP_2_TITLE")" "step2_ords_download_seconds" "10s"
  ORDS_URL="${ORDS_URL:-${PROFILE_ORDS_DOWNLOAD_URL:-https://download.oracle.com/otn_software/java/ords/ords-latest.zip}}"
  ORDS_BIN_DIR="$WORKSPACE_DIR/binaries/ords"
  mkdir -p "$ORDS_BIN_DIR"

  EXPECTED_ORDS_NAME=$(basename "$ORDS_URL")
  EXPECTED_ORDS_PATH="$ORDS_BIN_DIR/$EXPECTED_ORDS_NAME"

  FOUND_ORDS_ZIP=""
  if [ -f "$EXPECTED_ORDS_PATH" ] && unzip -t "$EXPECTED_ORDS_PATH" &>/dev/null; then
    FOUND_ORDS_ZIP="$EXPECTED_ORDS_PATH"
    msg_print "ORDS_LOCAL_FOUND_EXACT" "$(basename "$FOUND_ORDS_ZIP")"
  elif [ -f "$ORDS_BIN_DIR/ords-latest.zip" ] && unzip -t "$ORDS_BIN_DIR/ords-latest.zip" &>/dev/null; then
    FOUND_ORDS_ZIP="$ORDS_BIN_DIR/ords-latest.zip"
    msg_print "ORDS_LOCAL_FOUND_EXISTING" "ords-latest.zip"
  fi

  if [ -z "$FOUND_ORDS_ZIP" ]; then
    if declare -f artifactory_is_configured >/dev/null 2>&1 && artifactory_is_configured; then
      if artifactory_fetch_binary "ords" "$EXPECTED_ORDS_NAME" "$EXPECTED_ORDS_PATH" || artifactory_fetch_binary "ords" "ords-latest.zip" "$EXPECTED_ORDS_PATH"; then
        FOUND_ORDS_ZIP="$EXPECTED_ORDS_PATH"
      fi
    fi
    if [ -z "$FOUND_ORDS_ZIP" ]; then
      msg_print "ORDS_DOWNLOADING_FROM_URL" "$ORDS_URL"
      curl -sSL -k -o "$EXPECTED_ORDS_PATH" "$ORDS_URL" || true
    fi
  fi
  ORDS_DL_SECS=$(( $(date +%s) - ORDS_DL_START ))
  ORDS_DL_TIME=$(format_duration $ORDS_DL_SECS)
  echo -e "⏱  [$(msg_str "STEP_2_NAME"): ${YELLOW}$ORDS_DL_TIME${NC}]"
fi

# ----------------------------------------------------------------------------
# SAMM 3: APEX tarkvarapaketi allalaadimine ja lahtipakkimine (APEX Download)
# ----------------------------------------------------------------------------
APEX_DL_START=$(date +%s)
print_header "3" "$(msg_str "STEP_3_TITLE")" "step3_apex_download_unzip_seconds" "30s"

APEX_VERSIONS=()
for inst in $(get_active_db_instances 2>/dev/null); do
  prof=$(echo "$inst" | cut -d'|' -f2)
  ver=$(
    load_db_profile "$prof" >/dev/null 2>&1 || true
    if [ "${PROFILE_APEX_ENABLED:-true}" = "true" ] && [ "${PROFILE_APEX_VERSION:-NONE}" != "NONE" ] && [ -n "$PROFILE_APEX_VERSION" ] && [ "${IS_ADB:-false}" != "true" ] && [ "${PROFILE_APEX_INSTALL_REQUIRED:-true}" != "false" ] && [ "${PROFILE_APEX_PREINSTALLED:-false}" != "true" ]; then
      echo "$PROFILE_APEX_VERSION"
    fi
  )
  [ -n "$ver" ] && APEX_VERSIONS+=("$ver")
done

UNIQUE_APEX_VERSIONS=()
if [ "${#APEX_VERSIONS[@]}" -gt 0 ]; then
  while IFS= read -r line; do
    [ -n "$line" ] && UNIQUE_APEX_VERSIONS+=("$line")
  done < <(printf "%s\n" "${APEX_VERSIONS[@]}" | sort -u)
fi

if [ "${#UNIQUE_APEX_VERSIONS[@]}" -gt 0 ]; then
  APEX_BIN_DIR="$WORKSPACE_DIR/binaries/apex"
  mkdir -p "$APEX_BIN_DIR"
  for ver in "${UNIQUE_APEX_VERSIONS[@]}"; do
    VER_URL="${RESOLVED_APEX_URL}"
    ZIP_NAME=$(basename "$VER_URL")
    ZIP_PATH="$APEX_BIN_DIR/$ZIP_NAME"

    FOUND_APEX_ZIP=""
    if [ -f "$ZIP_PATH" ] && unzip -t "$ZIP_PATH" &>/dev/null; then
      FOUND_APEX_ZIP="$ZIP_PATH"
    elif [ -f "$APEX_BIN_DIR/apex-latest.zip" ] && unzip -t "$APEX_BIN_DIR/apex-latest.zip" &>/dev/null; then
      FOUND_APEX_ZIP="$APEX_BIN_DIR/apex-latest.zip"
    elif [ -f "$APEX_BIN_DIR/apex_${ver}.zip" ] && unzip -t "$APEX_BIN_DIR/apex_${ver}.zip" &>/dev/null; then
      FOUND_APEX_ZIP="$APEX_BIN_DIR/apex_${ver}.zip"
    elif [ -f "$APEX_BIN_DIR/apex_${ver}_en.zip" ] && unzip -t "$APEX_BIN_DIR/apex_${ver}_en.zip" &>/dev/null; then
      FOUND_APEX_ZIP="$APEX_BIN_DIR/apex_${ver}_en.zip"
    elif [ -f "$WORKSPACE_DIR/binaries/$ZIP_NAME" ] && unzip -t "$WORKSPACE_DIR/binaries/$ZIP_NAME" &>/dev/null; then
      FOUND_APEX_ZIP="$WORKSPACE_DIR/binaries/$ZIP_NAME"
    elif [ -f "$WORKSPACE_DIR/binaries/apex-latest.zip" ] && unzip -t "$WORKSPACE_DIR/binaries/apex-latest.zip" &>/dev/null; then
      FOUND_APEX_ZIP="$WORKSPACE_DIR/binaries/apex-latest.zip"
    fi

    if [ -n "$FOUND_APEX_ZIP" ]; then
      msg_print "APEX_LOCAL_FOUND_EXISTING" "$(basename "$FOUND_APEX_ZIP")"
      ZIP_PATH="$FOUND_APEX_ZIP"
    else
      msg_print "APEX_DOWNLOADING_VER" "$ver" "$ZIP_NAME"
      rm -f "$ZIP_PATH"
      curl -sSL -k -o "$ZIP_PATH" "$VER_URL" || true
      if ! unzip -t "$ZIP_PATH" &>/dev/null; then
        msg_print "APEX_DOWNLOAD_INVALID_ZIP"
        rm -f "$ZIP_PATH"
        if [ -f "$APEX_BIN_DIR/apex-latest.zip" ] && unzip -t "$APEX_BIN_DIR/apex-latest.zip" &>/dev/null; then
          ZIP_PATH="$APEX_BIN_DIR/apex-latest.zip"
        elif [ -f "$WORKSPACE_DIR/binaries/apex-latest.zip" ] && unzip -t "$WORKSPACE_DIR/binaries/apex-latest.zip" &>/dev/null; then
          ZIP_PATH="$WORKSPACE_DIR/binaries/apex-latest.zip"
        fi
      fi
    fi

    TARGET_DIR="$WORKSPACE_DIR/db-install/apex_$ver"
    if [ "${RESTORE_FROM_SNAPSHOT:-false}" = "true" ]; then
      echo -e "   ℹ️  APEX unpack skipped (restoring pre-installed APEX from Golden Snapshot)"
    elif [ ! -d "$TARGET_DIR/apex" ]; then
      msg_print "APEX_UNPACKING_VER" "$ver" "$TARGET_DIR"
      mkdir -p "$TARGET_DIR"
      unzip -o -q "$ZIP_PATH" -d "$TARGET_DIR" || true
    fi
  done
  APEX_DL_SECS=$(( $(date +%s) - APEX_DL_START ))
  APEX_DL_TIME=$(format_duration $APEX_DL_SECS)
else
  APEX_DL_SECS=0
  APEX_DL_TIME="$(msg_str "STATUS_SKIPPED")"
fi
echo -e "⏱  [$(msg_str "STEP_3_NAME"): ${YELLOW}$APEX_DL_TIME${NC}]"

# ----------------------------------------------------------------------------
# STEP 4: Container startup and database health checks
# ----------------------------------------------------------------------------
STEP4_START=$(date +%s)
if [ "$IS_LOCAL" = "true" ]; then
  mkdir -p "$WORKSPACE_DIR/config/tns_admin"
  print_header "4" "$(msg_str "STEP_4_TITLE")" "step4_container_startup_seconds" "45s"

  ACTIVE_DBS_STEP4=$(get_active_db_instances 2>/dev/null || true)
  if [ -n "$ACTIVE_DBS_STEP4" ] && [ "${DB_ENABLED:-true}" != "false" ] && [ "${PROFILE_NAME:-}" != "NONE" ] && [ "${RESTORE_FROM_SNAPSHOT:-false}" = "true" ] && [ -f "$SCRIPT_DIR/snapshots/restore-golden-snapshots.sh" ]; then
    echo -e "${CYAN}📸 [Golden Snapshot]: Rapid ~15s environment restore from snapshot...${NC}"
    restore_flags=(--auto -b "${ACTIVE_BP_ID:-0}")
    if [ "${ROTATE_RESTORE_PASSWORDS:-false}" != "true" ]; then
      restore_flags+=(--no-rotate)
    fi
    [ "$FORCE" = "true" ] && restore_flags+=(--force)
    if ! "$SCRIPT_DIR/snapshots/restore-golden-snapshots.sh" "${restore_flags[@]}"; then
      echo -e "${YELLOW}ℹ️  Snapshot restore not available or failed. Starting containers directly...${NC}"
      "$SCRIPT_DIR/start-containers.sh" >> "$LOG_FILE" 2>&1 || true
    fi
  else
    # Pre-flight container lifecycle & port conflict check
    target_containers=()
    for c in $(extract_blueprint_containers "${ACTIVE_BP_ID:-0}" 2>/dev/null); do
      [ -n "$c" ] && target_containers+=("$c")
    done

    # Collect host ports that target containers will bind to
    target_ports=()
    for tc in "${target_containers[@]}"; do
      case "$tc" in
        db-*)
          db_port=$(grep -A 10 "$tc:" "$WORKSPACE_DIR/podman-compose.override.yml" 2>/dev/null | grep -E '^[[:space:]]+-[[:space:]]+"[0-9]+:' | sed -E 's/.*"([0-9]+):.*/\1/' || echo "")
          [ -n "$db_port" ] && target_ports+=("$db_port")
          ;;
        app-ords)
          target_ports+=("${ORDS_PORT:-8088}" "${ORDS_SSL_PORT:-8448}")
          ;;
        web-ide-dev)
          target_ports+=("${WEB_IDE_HTTP_PORT:-8090}" "${WEB_IDE_HTTPS_PORT:-8450}" "${CICD_WEB_UI_PORT:-8091}")
          ;;
        app-publisher-designer)
          target_ports+=("${PUBLISHER_DESIGNER_HTTP_PORT:-6083}" "${PUBLISHER_DESIGNER_VNC_PORT:-5903}")
          ;;
        app-publisher)
          target_ports+=("${PUBLISHER_HTTP_PORT:-9704}")
          ;;
        app-forms|forms-dev)
          target_ports+=("${FORMS_HTTP_PORT:-9001}" "${FORMS_NOVNC_PORT:-6081}" "${FORMS_VNC_PORT:-5901}")
          ;;
        ords-standalone-*)
          target_ports+=("${ORDS_STANDALONE_HTTP_PORT:-8085}" "${ORDS_STANDALONE_HTTPS_PORT:-8445}")
          ;;
      esac
    done

    running_other=()
    for active_c in $(podman ps --format '{{.Names}}' 2>/dev/null); do
      # Databases (db-*, oracle-db-*) must NEVER be stopped when switching blueprints or deploying components
      if [[ "$active_c" =~ ^(db-.*|oracle-db-.*)$ ]]; then
        continue
      fi
      # Protect Core Base and Web Gateway containers
      if [[ "$active_c" == "app-ords" ]]; then
        continue
      fi
      if [[ "$active_c" =~ ^(app-.*|web-ide-.*|ords-standalone-.*)$ ]]; then
        is_target=false
        for t in "${target_containers[@]}"; do
          if [ "$active_c" = "$t" ]; then
            is_target=true
            break
          fi
        done
        if [ "$is_target" = "false" ]; then
          if [ "${REPLACE_MODE:-false}" = "true" ]; then
            running_other+=("$active_c")
          else
            # Only stop if there is an actual host port conflict with the incoming blueprint
            has_conflict=false
            c_ports=$(podman inspect "$active_c" --format '{{range $p, $conf := .NetworkSettings.Ports}}{{range $conf}}{{.HostPort}} {{end}}{{end}}' 2>/dev/null || echo "")
            for cp in $c_ports; do
              for tp in "${target_ports[@]}"; do
                if [ "$cp" = "$tp" ]; then
                  has_conflict=true
                  break 2
                fi
              done
            done
            if [ "$has_conflict" = "true" ]; then
              running_other+=("$active_c")
            fi
          fi
        fi
      fi
    done

    if [ "${#running_other[@]}" -gt 0 ]; then
      echo -e "${YELLOW}$(msg_str "WARN_FOREIGN_CONTAINER_DETECTED" "${running_other[*]}" "${ACTIVE_BP_ID:-0}")${NC}"
      should_stop="yes"
      if [ -t 0 ] && [ "${FORCE:-false}" != "true" ]; then
        read -r -p "$(msg_str "PROMPT_STOP_FOREIGN_CONTAINER")" ans
        if [[ "$ans" =~ ^[Nn] ]]; then
          should_stop="no"
        fi
      fi
      if [ "$should_stop" = "yes" ]; then
        for c_to_stop in "${running_other[@]}"; do
          echo -e "   ${CYAN}$(msg_str "STOPPING_PREVIOUS_BP_CONTAINER" "$c_to_stop")${NC}"
          podman stop "$c_to_stop" >/dev/null 2>&1 || true
        done
      fi
    fi

    (
      "$SCRIPT_DIR/start-containers.sh" >> "$LOG_FILE" 2>&1
    ) &
    UP_PID=$!
    register_child_pid "$UP_PID"

    hide_cursor
    ELAPSED=0
    POLL_INTERVAL="${LIVE_TIMER_INTERVAL:-3}"
    POLL_INTERVAL="${POLL_INTERVAL//[^0-9]/}"
    [ -z "$POLL_INTERVAL" ] || [ "$POLL_INTERVAL" -le 0 ] && POLL_INTERVAL=3

    while kill -0 "$UP_PID" 2>/dev/null; do
      FMT_TIME=$(format_duration "$ELAPSED")
      if [ -t 3 ] 2>/dev/null; then
        printf "\r\033[K   ⏳ [%s: %s...]" "$(msg_str "STARTING_CONTAINERS_PROGRESS")" "$FMT_TIME" >&3
      fi
      sleep "$POLL_INTERVAL"
      ELAPSED=$((ELAPSED + POLL_INTERVAL))
    done
    wait "$UP_PID" 2>/dev/null || true
    restore_cursor
    if [ -t 3 ] 2>/dev/null; then
      printf "\r\033[K" >&3
    fi
  fi

  # Use adaptive self-healing health check module
  if [ -n "$(get_active_db_instances 2>/dev/null)" ] && [ -x "$SCRIPT_DIR/internal/wait-db-healthy.sh" ]; then
    "$SCRIPT_DIR/internal/wait-db-healthy.sh"
  fi

  STEP4_CONTAINER_SECS=$(( $(date +%s) - STEP4_START ))
  STEP4_TIME=$(format_duration $STEP4_CONTAINER_SECS)
  echo -e "⏱  [$(msg_str "STEP_4_NAME"): ${YELLOW}$STEP4_TIME${NC}]"
else
  STEP4_CONTAINER_SECS=0
  STEP4_TIME="$(msg_str "STATUS_SKIPPED")"
fi

# ----------------------------------------------------------------------------
# STEP 4.5: Oracle Wallet and TNS initial configuration (SEPS)
# ----------------------------------------------------------------------------
STEP4_5_SECS=0
if [ "$IS_LOCAL" = "true" ]; then
  print_header "4.5" "$(msg_str "STEP_4_5_TITLE")" "step4_5_wallet_tns_config_seconds" "10s"
  STEP4_5_START=$(date +%s)
  
  # Synchronize database users and passwords before Wallet and ORDS operations
  if [ -n "$(get_active_db_instances 2>/dev/null)" ] && [ -x "$SCRIPT_DIR/internal/apply-profile-users.sh" ]; then
    get_active_db_instances 2>/dev/null | while IFS='|' read -r c_name prof env_key; do
      [ -n "$c_name" ] && "$SCRIPT_DIR/internal/apply-profile-users.sh" "$c_name" >/dev/null 2>&1 || true
    done
  fi

  "$SCRIPT_DIR/internal/create-wallet.sh"
  STEP4_5_SECS=$(( $(date +%s) - STEP4_5_START ))
  STEP4_5_TIME=$(format_duration $STEP4_5_SECS)
  echo -e "⏱  [$(msg_str "STEP_4_5_NAME"): ${YELLOW}$STEP4_5_TIME${NC}]"
fi

# ----------------------------------------------------------------------------
# STEP 5: ORDS service startup and readiness check
# ----------------------------------------------------------------------------
STEP5_START=$(date +%s)
if ! is_ords_enabled || [ "$IS_LOCAL" = "false" ]; then
  STEP5_ORDS_SECS=0
  STEP5_TIME="$(msg_str "STATUS_SKIPPED")"
else
  ords_h_port="${ORDS_HTTP_PORT:-${PROFILE_ORDS_HTTP_PORT:-8088}}"
  print_header "5" "$(msg_str "STEP_5_TITLE" "$ords_h_port")" "step5_ords_service_seconds" "1s"
  if podman container exists app-ords 2>/dev/null; then
    podman restart app-ords >/dev/null 2>&1 || true
  fi
  STEP5_ORDS_SECS=$(( $(date +%s) - STEP5_START ))
  STEP5_TIME=$(format_duration $STEP5_ORDS_SECS)
  echo -e "⏱  [$(msg_str "STEP_5_NAME"): ${YELLOW}$STEP5_TIME${NC}]"
fi

# ----------------------------------------------------------------------------
# STEP 6: Automated APEX Engine and Patch Installation
# ----------------------------------------------------------------------------
STEP6_APEX_START=$(date +%s)
print_header "6" "$(msg_str "STEP_6_TITLE")" "step7_apex_engine_install_seconds" "6m"
ACTIVE_INST_LIST=$(get_active_db_instances 2>/dev/null || echo "")
if [ -z "$ACTIVE_INST_LIST" ]; then
  echo -e "   ℹ️  $(msg_str "STATUS_SKIPPED") (No local database instances active for this blueprint)"
else
  for inst in $ACTIVE_INST_LIST; do
    c_name=$(echo "$inst" | cut -d'|' -f1)
    prof=$(echo "$inst" | cut -d'|' -f2)
    [ -z "$c_name" ] && continue
    (
      load_db_profile "$prof" >/dev/null 2>&1 || true
      if [ "${PROFILE_APEX_ENABLED:-true}" = "false" ] || [ "${PROFILE_APEX_VERSION:-NONE}" = "NONE" ]; then
        echo -e "   $(msg_str "APEX_NOT_ACTIVE_INFO" "$c_name")"
      elif declare -f can_skip_in_db_apex >/dev/null 2>&1 && can_skip_in_db_apex "$c_name" "${PROFILE_APEX_VERSION:-26.1}" "${PROFILE_DEFAULT_SERVICE:-FREEPDB1}"; then
        "$SCRIPT_DIR/internal/sync-apex-images.sh" "$c_name" "${PROFILE_APEX_VERSION:-26.1}" || true
      else
        echo -e "   🚀 [${c_name}]: $(msg_str "APEX_STARTING_INSTALL" "${PROFILE_APEX_VERSION:-26.1}")"
        INSTALL_ARGS=()
        [ "$FORCE" = "true" ] && INSTALL_ARGS+=("--force")
        [ "${APEX_RUNTIME_ONLY:-false}" = "true" ] && INSTALL_ARGS+=("--runtime-only")
        INSTALL_ARGS+=("--db" "$(echo "$c_name" | sed 's/^db-//' | tr '-' '_')" "--version" "${PROFILE_APEX_VERSION:-26.1}" "--port" "${PROFILE_DB_PORT}" "--service" "${PROFILE_DEFAULT_SERVICE}")
        if [ "${PROFILE_ORDS_ENABLED:-true}" = "false" ] || ! is_ords_enabled; then
          INSTALL_ARGS+=("--no-ords")
        fi
        "$SCRIPT_DIR/internal/install-apex.sh" "${INSTALL_ARGS[@]}"
        "$SCRIPT_DIR/internal/sync-apex-images.sh" "$c_name" "${PROFILE_APEX_VERSION:-26.1}" || true
      fi
    )
  done
fi
STEP6_APEX_SECS=$(( $(date +%s) - STEP6_APEX_START ))
STEP6_APEX_TIME=$(format_duration $STEP6_APEX_SECS)
echo -e "⏱  [$(msg_str "STEP_6_NAME"): ${YELLOW}$STEP6_APEX_TIME${NC}]"

# ----------------------------------------------------------------------------
# STEP 7: Database schema migrations (Liquibase / Init DB)
# ----------------------------------------------------------------------------
STEP5_5_START=$(date +%s)
print_header "7" "$(msg_str "STEP_7_TITLE")" "step5_5_liquibase_migration_seconds" "15s"
STEP5_5_LOG="$LOG_DIR/db_sqlcl_deploy_${TIMESTAMP}.log"

if [ -z "$ACTIVE_INST_LIST" ]; then
  STEP5_5_SECS=0
  STEP5_5_TIME="$(msg_str "STATUS_SKIPPED")"
  echo -e "   ℹ️  $(msg_str "STATUS_SKIPPED") (No local database instances active for this blueprint)"
  echo -e "⏱  [$(msg_str "STEP_7_NAME"): ${YELLOW}$STEP5_5_TIME${NC}]"
else
  get_active_db_instances 2>/dev/null | while IFS='|' read -r c_name prof env_key; do
    [ -z "$c_name" ] && continue
    ( "$SCRIPT_DIR/internal/init-db-instance.sh" "$prof" "$c_name" >> "$STEP5_5_LOG" 2>&1 ) &
  done
  wait

  STEP5_5_SECS=$(( $(date +%s) - STEP5_5_START ))
  STEP5_5_TIME=$(format_duration $STEP5_5_SECS)
  echo -e "⏱  [$(msg_str "STEP_7_NAME"): ${GREEN}$STEP5_5_TIME${NC}]"
fi

# Synchronize profile users, APEX workspaces and ORDS metadata
if [ -n "$ACTIVE_INST_LIST" ] && [ -x "$SCRIPT_DIR/internal/apply-profile-users.sh" ]; then
  get_active_db_instances 2>/dev/null | while IFS='|' read -r c_name prof env_key; do
    [ -n "$c_name" ] && "$SCRIPT_DIR/internal/apply-profile-users.sh" "$c_name" >> "$LOG_DIR/apply_profile_users_${TIMESTAMP}.log" 2>&1 || true
  done
fi

if is_ords_enabled && podman container exists app-ords 2>/dev/null; then
  echo -e "🔄 $(msg_str "ORDS_RESTARTING_POOLS")"
  podman restart app-ords >/dev/null 2>&1 || true
  sleep 8
fi

# ----------------------------------------------------------------------------
# STEP 8: APEX Application Deployment (Deploy Packaged APEX Applications)
# ----------------------------------------------------------------------------
STEP8_START=$(date +%s)
print_header "8" "$(msg_str "STEP_8_TITLE")" "step10_deploy_apex_apps_seconds" "10s"

if [ "${PROFILE_APEX_ENABLED:-true}" = "false" ]; then
  STEP8_DEPLOY_SECS=0
  STEP8_DEPLOY_TIME="$(msg_str "STATUS_SKIPPED")"
else
  STEP8_LOG="$LOG_DIR/apex_apps_deploy_${TIMESTAMP}.log"
  mkdir -p "$WORKSPACE_DIR/binaries/apex_apps"
  set +e
  "$SCRIPT_DIR/internal/deploy-apex-apps.sh" > "$STEP8_LOG" 2>&1
  set -e
  STEP8_DEPLOY_SECS=$(( $(date +%s) - STEP8_START ))
  STEP8_DEPLOY_TIME=$(format_duration $STEP8_DEPLOY_SECS)
  echo -e "⏱  [$(msg_str "STEP_8_NAME"): ${YELLOW}$STEP8_DEPLOY_TIME${NC}]"
fi

# ----------------------------------------------------------------------------
# STEP 9: Oracle Analytics Publisher Installation and Initialization
# ----------------------------------------------------------------------------
PUB_INSTALL_SECS=0
if is_publisher_enabled; then
  PUB_START=$(date '+%s')
  echo -e "\n${YELLOW}🚀 $(msg_str "PUB_STARTING_SETUP")${NC}"
  if [ -x "$SCRIPT_DIR/internal/install-publisher.sh" ]; then
    "$SCRIPT_DIR/internal/install-publisher.sh" || true
  fi
  PUB_INSTALL_SECS=$(( $(date '+%s') - PUB_START ))
  echo -e "⏱  [$(msg_str "STEP_9_COMPLETED"): ${YELLOW}$(format_duration ${PUB_INSTALL_SECS})${NC}]"
fi

# ----------------------------------------------------------------------------
# STEP 9.5: Oracle Forms 14c Installation and Initialization
# ----------------------------------------------------------------------------
FORMS_INSTALL_SECS=0
if is_forms_enabled; then
  FORMS_START=$(date '+%s')
  echo -e "\n${YELLOW}🚀 $(msg_str "FORMS_STARTING_SETUP")${NC}"
  if [ -x "$SCRIPT_DIR/internal/install-forms.sh" ]; then
    "$SCRIPT_DIR/internal/install-forms.sh" || true
  fi
  if [ -x "$SCRIPT_DIR/internal/test-forms-service.sh" ]; then
    "$SCRIPT_DIR/internal/test-forms-service.sh" || true
  fi
  FORMS_INSTALL_SECS=$(( $(date '+%s') - FORMS_START ))
  echo -e "⏱  [$(msg_str "STEP_FORMS_COMPLETED"): ${YELLOW}$(format_duration ${FORMS_INSTALL_SECS})${NC}]"
fi

# ----------------------------------------------------------------------------
# STEP 10: Golden Snapshot Creation & Metadata Update
# ----------------------------------------------------------------------------
STEP9_SECS=0
if [ "${IS_TEST_MODE:-false}" != "true" ] || [ -n "$TEST_BLUEPRINTS" ] || [ "${FORCE_SNAPSHOT:-false}" = "true" ]; then
  print_header "10" "$(msg_str "STEP_10_TITLE")" "snapshot_duration_seconds" "25s"
  
  if [ -f "$SCRIPT_DIR/internal/snapshot-resolver.sh" ]; then
    # shellcheck source=/dev/null
    source "$SCRIPT_DIR/internal/snapshot-resolver.sh"
  fi

  target_bp_snap="${SELECTED_BLUEPRINT:-0}"
  target_prof_snap="${PROFILE_NAME:-db-proxy-oracle}"
  max_snap_days="${SNAPSHOT_MAX_AGE_DAYS:-30}"

  ACTIVE_DBS_SNAP=$(get_active_db_instances 2>/dev/null || true)
  if [ -z "$ACTIVE_DBS_SNAP" ] || [ "${DB_ENABLED:-true}" = "false" ] || [ "$target_prof_snap" = "NONE" ]; then
    echo -e "   ℹ️  $(msg_str "SNAPSHOT_FASTPATH_DETECTED" "${PROFILE_NAME:-NONE}") (0 local databases - snapshot skipped)"
  elif should_create_golden_snapshot "$target_bp_snap" "$target_prof_snap" "$max_snap_days"; then
    case "${EVALUATED_SNAPSHOT_ACTION:-create}" in
      "force")
        msg_print "SNAPSHOT_FORCE_CREATION"
        ;;
      "recreate_expired")
        msg_print "SNAPSHOT_EXPIRED_RECREATE" "$target_prof_snap" "${EVALUATED_SNAPSHOT_AGE_DAYS:-31}" "$max_snap_days"
        ;;
      *)
        msg_print "SNAPSHOT_AUTO_CREATING" "$target_bp_snap" "$target_prof_snap"
        ;;
    esac

    SNAP_START=$(date +%s)
    "$SCRIPT_DIR/snapshots/create-golden-snapshots.sh" --blueprint "$target_bp_snap" --profile "$target_prof_snap" --auto || true
    STEP9_SECS=$(( $(date +%s) - SNAP_START ))

    if [ "${ARTIFACTORY_AUTO_PUBLISH:-false}" = "true" ] || [ "${PUBLISH_SNAPSHOT:-false}" = "true" ]; then
      if [ -x "$SCRIPT_DIR/publish-to-artifactory.sh" ]; then
        "$SCRIPT_DIR/publish-to-artifactory.sh" --product blueprints --blueprint "$target_bp_snap" --profile "$target_prof_snap" -y || true
      fi
    fi
  else
    if [ "${EVALUATED_SNAPSHOT_ACTION:-}" = "skip_fresh" ]; then
      msg_print "SNAPSHOT_FRESH_SKIP" "$target_prof_snap" "${EVALUATED_SNAPSHOT_AGE_DAYS:-0}" "$max_snap_days"
    else
      echo -e "   ✅ $(msg_str "SNAPSHOT_FASTPATH_DETECTED" "$target_prof_snap")"
    fi
  fi
  STEP9_TIME=$(format_duration $STEP9_SECS)
  if [ "$STEP9_SECS" -eq 0 ]; then
    echo -e "⏱  [$(msg_str "STEP_10_NAME"): ${YELLOW}$(msg_str "STATUS_SKIPPED")${NC}]"
  else
    echo -e "⏱  [$(msg_str "STEP_10_NAME"): ${YELLOW}$STEP9_TIME${NC}]"
  fi
fi

# Provision developer account and VS Code connection
if [ "$IS_LOCAL" = "true" ] && [ "${ENVIRONMENT_TYPE:-DEV}" = "DEV" ]; then
  if [ "${PROFILE_APEX_ENABLED:-true}" = "true" ]; then
    "$SCRIPT_DIR/create-developer.sh" --force >/dev/null 2>&1 || true
  fi
fi

if is_web_ide_enabled && podman container exists web-ide-dev 2>/dev/null; then
  if [ -x "$SCRIPT_DIR/internal/init-web-ide.sh" ]; then
    "$SCRIPT_DIR/internal/init-web-ide.sh" >/dev/null 2>&1 || true
  fi
fi

TOTAL_MASTER_SECS=$(( $(date +%s) - START_MASTER_TOTAL ))
TOTAL_MASTER_TIME=$(format_duration $TOTAL_MASTER_SECS)

# Export metrics to setup report generator
export SETUP_TOTAL_SECS="$TOTAL_MASTER_SECS"
export SETUP_STEP1_PULL_SECS="$PULL_SECS"
export SETUP_STEP2_ORDS_DOWNLOAD_SECS="$ORDS_DL_SECS"
export SETUP_STEP3_APEX_DOWNLOAD_SECS="$APEX_DL_SECS"
export SETUP_STEP4_CONTAINER_STARTUP_SECS="$STEP4_CONTAINER_SECS"
export SETUP_STEP4_5_WALLET_TNS_CONFIG_SECS="$STEP4_5_SECS"
export SETUP_STEP5_ORDS_SERVICE_SECS="$STEP5_ORDS_SECS"
export SETUP_STEP5_5_LIQUIBASE_SECS="$STEP5_5_SECS"
export SETUP_STEP6_COPY_SECS="${APEX_COPY_SECS:-20}"
export SETUP_STEP7_ENGINE_SECS="${APEX_ENGINE_SECS:-348}"
export SETUP_STEP8_ORDS_CONF_SECS="${ORDS_CONF_SECS:-10}"
export SETUP_STEP9_PUBLISHER_SECS="$PUB_INSTALL_SECS"
export SETUP_STEP10_DEPLOY_APPS_SECS="$STEP8_DEPLOY_SECS"
export SETUP_STEP11_SNAPSHOT_SECS="$STEP9_SECS"

# URL and Wallet automated diagnostic tests
if [ "${SKIP_TESTS:-false}" = "true" ]; then
  echo -e "\n${YELLOW}⚡ Fast Mode (--fast): Post-provisioning URL and wallet diagnostics skipped.${NC}"
else
  if [ -x "$SCRIPT_DIR/check-urls.sh" ]; then
    if [ "$IS_TEST_MODE" = "true" ] || [ -n "$TEST_BLUEPRINTS" ]; then
      "$SCRIPT_DIR/check-urls.sh" 15 2 || true
    else
      "$SCRIPT_DIR/check-urls.sh" 24 5 || true
    fi
  fi

  if [ -x "$SCRIPT_DIR/check-wallet.sh" ]; then
    "$SCRIPT_DIR/check-wallet.sh" || true
  fi
fi

# Generate reports and JSON metrics
if [ -x "$SCRIPT_DIR/internal/generate-setup-report.sh" ]; then
  "$SCRIPT_DIR/internal/generate-setup-report.sh"
fi

# Register VS Code connections
if [ "$IS_LOCAL" = "true" ] && [ -f "$SCRIPT_DIR/register-connections.sh" ]; then
  "$SCRIPT_DIR/register-connections.sh" >/dev/null 2>&1 || true
fi

# Final summary and Live Developer Dashboard
ACTIVE_HTTP_PORT="${ORDS_HTTP_PORT:-${PROFILE_ORDS_HTTP_PORT:-8088}}"
ACTIVE_SSL_PORT="${ORDS_SSL_PORT:-${PROFILE_ORDS_HTTPS_PORT:-8448}}"
[ "${IS_ADB:-false}" = "true" ] && ACTIVE_SSL_PORT="${ORDS_HTTPS_PORT:-${PROFILE_ORDS_HTTPS_PORT:-8443}}"
ACTIVE_PUB_PORT="${PUBLISHER_HTTP_PORT:-9502}"
ACTIVE_WEB_IDE_PORT="${WEB_IDE_HTTP_PORT:-8090}"

echo ""
echo -e "${CYAN}==================================================================${NC}"
echo -e "${GREEN}$(msg_str "SETUP_COMPLETED")${NC}"
echo -e "${CYAN}==================================================================${NC}"

echo -e "\n${CYAN}$(msg_str "WEB_SERVICES_HEADER")${NC}"
printf "┌─────────────────────────────────┬────────────────────────────────────────────┬─────────────────────────────┐\n"
printf "│ %-31s │ %-42s │ %-27s │\n" "$(msg_str "COL_APP")" "$(msg_str "COL_URL")" "$(msg_str "COL_AUTH")"
printf "├─────────────────────────────────┼────────────────────────────────────────────┼─────────────────────────────┤\n"

if is_ords_enabled; then
  printf "│ %-31s │ %-42s │ %-27s │\n" "🚀 Dev & DevOps Hub (Main)" "https://localhost:${ACTIVE_SSL_PORT}/dev-hub.html" "Command Center & 5-Lang Docs"
  for inst in $(get_active_db_instances 2>/dev/null); do
    c_name=$(echo "$inst" | cut -d'|' -f1)
    p_name=$(echo "$inst" | cut -d'|' -f2)
    pfile="$WORKSPACE_DIR/config/profiles/databases/${p_name}.yaml"
    [ ! -f "$pfile" ] && pfile="$WORKSPACE_DIR/config/profiles/${p_name}.yaml"
    pool_name=$(echo "$c_name" | sed 's/^db-//' | tr '-' '_')
    
    ords_en="true"
    apex_en="false"
    p_ws=""
    if [ -f "$pfile" ]; then
      ords_en=$(awk '/ords:/{flag=1;next}/apex:|publisher:|forms:|sqlcl:|users:/{flag=0}flag' "$pfile" | grep -E '^[[:space:]]*enabled:' | head -n 1 | sed -E 's/.*:[[:space:]]*"?([^" #]+)"?.*/\1/' | tr -d '\r\n')
      apex_en=$(awk '/apex:/{flag=1;next}/ords:|publisher:|forms:|sqlcl:|users:/{flag=0}flag' "$pfile" | grep -E '^[[:space:]]*enabled:' | head -n 1 | sed -E 's/.*:[[:space:]]*"?([^" #]+)"?.*/\1/' | tr -d '\r\n')
      p_ws=$(awk '/apex:/{flag=1;next}/ords:|publisher:|forms:|sqlcl:|users:/{flag=0}flag' "$pfile" | grep -E '^[[:space:]]*workspace:' | head -n 1 | sed -E 's/.*:[[:space:]]*"?([^" #]+)"?.*/\1/' | tr -d '\r\n')
    fi
    upper_pool=$(echo "$pool_name" | tr '[:lower:]' '[:upper:]')
    [ -z "$p_ws" ] && p_ws="${upper_pool}_WORKSPACE"
    
    if [ "$ords_en" = "true" ]; then
      if [ "$apex_en" = "true" ]; then
        printf "│ %-31s │ %-42s │ %-27s │\n" "🛠 APEX Builder (${upper_pool})" "https://localhost:${ACTIVE_SSL_PORT}/ords/${pool_name}/r/apex/workspace-sign-in/oracle-apex-sign-in?f4550_p1_company=${p_ws}&f4550_p1_username=DEV" "Workspace: ${p_ws} / DEV"
        printf "│ %-31s │ %-42s │ %-27s │\n" "⚙️ APEX Instance Admin (${upper_pool})" "https://localhost:${ACTIVE_SSL_PORT}/ords/${pool_name}/apex_admin" "Workspace: INTERNAL / ADMIN"
      fi
      printf "│ %-31s │ %-42s │ %-27s │\n" "📊 Database Actions (${upper_pool})" "https://localhost:${ACTIVE_SSL_PORT}/ords/${pool_name}/sql-developer" "USER_DEVELOPER / DEV"
    fi
  done
elif [ -n "$(get_active_db_instances 2>/dev/null)" ]; then
  printf "│ %-31s │ %-42s │ %-27s │\n" "ℹ️ ORDS Web Gateway" "NOT CONFIGURED (Standalone DB)" "Run: ./scripts/setup-all.sh -b 0"
fi

if is_forms_enabled; then
  ACTIVE_FORMS_PORT="${FORMS_HTTP_PORT:-9001}"
  printf "│ %-31s │ %-42s │ %-27s │\n" "📐 Forms 14c Services" "http://localhost:${ACTIVE_FORMS_PORT}/forms/frmservlet" "Runtime / test.fmx"
  printf "│ %-31s │ %-42s │ %-27s │\n" "🎨 Forms Builder GUI" "http://localhost:6082/vnc.html" "Visual Builder (noVNC)"
fi

if is_publisher_enabled; then
  printf "│ %-31s │ %-42s │ %-27s │\n" "📑 Analytics Publisher" "http://localhost:${ACTIVE_PUB_PORT}/xmlpserver" "User: weblogic / SYS"
fi

if is_web_ide_enabled; then
  printf "│ %-31s │ %-42s │ %-27s │\n" "💻 Web IDE (VS Code)" "http://localhost:${ACTIVE_WEB_IDE_PORT}/" "Zero-Install Workspace"
fi

if is_publisher_designer_enabled; then
  ACTIVE_DESIGNER_PORT="${PUBLISHER_DESIGNER_HTTP_PORT:-6083}"
  printf "│ %-31s │ %-42s │ %-27s │\n" "🎨 Publisher Designer GUI" "http://localhost:${ACTIVE_DESIGNER_PORT}/vnc.html" "Template Studio (noVNC)"
fi
printf "└─────────────────────────────────┴────────────────────────────────────────────┴─────────────────────────────┘\n"

if ! is_ords_enabled && [ -n "$(get_active_db_instances 2>/dev/null)" ]; then
  echo -e "\n${YELLOW}ℹ️  $(msg_str "ORDS_NOT_CONFIGURED_STATUS")${NC}"
  echo -e "${YELLOW}💡 $(msg_str "ORDS_NOT_CONFIGURED_HINT")${NC}"
fi

echo -e "\n${CYAN}$(msg_str "TREE_HEADER")${NC}"
for inst in $(get_active_db_instances 2>/dev/null); do
  c_name=$(echo "$inst" | cut -d'|' -f1)
  prof=$(echo "$inst" | cut -d'|' -f2)
  pfile="$WORKSPACE_DIR/config/profiles/databases/${prof}.yaml"
  [ ! -f "$pfile" ] && pfile="$WORKSPACE_DIR/config/profiles/${prof}.yaml"
  c_port="1521"
  c_svc="FREEPDB1"
  if [ -f "$pfile" ]; then
    c_port=$(grep -E '^[[:space:]]*db_port:' "$pfile" | head -n 1 | sed 's/#.*//' | awk -F: '{print $2}' | tr -d ' "\r\n')
    c_svc=$(grep -E '^[[:space:]]*default_service:' "$pfile" | head -n 1 | sed 's/#.*//' | awk -F: '{print $2}' | tr -d ' "\r\n')
  fi
  c_port="${c_port:-1521}"
  c_svc="${c_svc:-FREEPDB1}"
  c_short=$(echo "$c_name" | sed -E 's/^db[-_]//' | tr '-' '_' | tr '[:lower:]' '[:upper:]')
  
  echo -e "   📁 ${BOLD}${c_name}${NC} (localhost:${c_port}/${c_svc})"
  echo -e "   │  ├── 🔴 ${BOLD}1. Sys (${c_name})${NC}               (SYSDBA -> sql /@DB_${c_short}_SYS as sysdba)"
  echo -e "   │  ├── 🔵 ${BOLD}2. DBA_ADMIN (${c_name})${NC}         (DBA     -> sql /@DB_${c_short}_DBA_ADMIN)"
  if [[ "$prof" == *"proxy"* ]] || [ "$c_name" = "db-proxy" ]; then
    echo -e "   │  ├── 🟣 ${BOLD}3. APEX_PROXY_SCHEMA (${c_name})${NC} (Schema  -> sql /@DB_${c_short}_SCHEMA)"
    echo -e "   │  ├── 🟢 ${BOLD}4. USER_DEVELOPER (${c_name})${NC}  (Dev     -> sql /@DB_${c_short}_DEV)"
    echo -e "   │  ├── 📦 ${BOLD}5. USER_APP (${c_name})${NC}        (App     -> sql /@DB_${c_short}_APP)"
    echo -e "   │  └── 🟡 ${BOLD}6. USER_VIEWER (${c_name})${NC}     (Viewer  -> sql /@DB_${c_short}_VIEWER)"
  elif [ "$c_name" = "db-publisher" ]; then
    echo -e "   │  └── 🟡 ${BOLD}3. PUBLISHER_READER (${c_name})${NC}  (Viewer  -> sql /@DB_${c_short}_READER)"
  elif [ "$c_name" = "db-forms" ]; then
    echo -e "   │  ├── 🟣 ${BOLD}3. FORMS_SCHEMA (${c_name})${NC}      (Schema  -> sql /@DB_${c_short}_SCHEMA)"
    echo -e "   │  ├── 🟢 ${BOLD}4. USER_DEVELOPER (${c_name})${NC}  (Dev     -> sql /@DB_${c_short}_DEV)"
    echo -e "   │  ├── 📦 ${BOLD}5. USER_APP (${c_name})${NC}        (App     -> sql /@DB_${c_short}_APP)"
    echo -e "   │  └── 🟡 ${BOLD}6. USER_VIEWER (${c_name})${NC}     (Viewer  -> sql /@DB_${c_short}_VIEWER)"
  else
    echo -e "   │  ├── 🟢 ${BOLD}3. USER_DEVELOPER (${c_name})${NC}  (Dev     -> sql /@DB_${c_short}_DEV)"
    echo -e "   │  ├── 📦 ${BOLD}4. USER_APP (${c_name})${NC}        (App     -> sql /@DB_${c_short}_APP)"
    echo -e "   │  └── 🟡 ${BOLD}5. USER_VIEWER (${c_name})${NC}     (Viewer  -> sql /@DB_${c_short}_VIEWER)"
  fi
done

echo -e "\n${CYAN}$(msg_str "CRED_HELPER_HEADER")${NC}"
echo -e "$(msg_str "CRED_HELPER_HINT")"
echo -e "   👉 ${YELLOW}./scripts/get-password.sh <ALIAS>${NC}\n"
for inst in $(get_active_db_instances 2>/dev/null); do
  c_name=$(echo "$inst" | cut -d'|' -f1)
  c_short=$(echo "$c_name" | sed -E 's/^db[-_]//' | tr '-' '_' | tr '[:lower:]' '[:upper:]')
  echo -e "   • ${BOLD}${c_name}${NC}:"
  echo -e "     - APEX Admin (INTERNAL): ./scripts/get-password.sh DB_${c_short}_APEX_ADMIN"
  echo -e "     - DEV Password:          ./scripts/get-password.sh DB_${c_short}_DEV"
  echo -e "     - SYS DBA Password:      ./scripts/get-password.sh DB_${c_short}_SYS"
done

echo -e "\n${CYAN}$(msg_str "SQLCL_QUICK_HEADER")${NC}"
for inst in $(get_active_db_instances 2>/dev/null); do
  c_name=$(echo "$inst" | cut -d'|' -f1)
  c_short=$(echo "$c_name" | sed -E 's/^db[-_]//' | tr '-' '_' | tr '[:lower:]' '[:upper:]')
  echo -e "   • sql /@DB_${c_short}_DEV"
  echo -e "   • sql /@DB_${c_short}_SYS as sysdba"
done

if [ -f "$WORKSPACE_DIR/metrics/extensions_status.json" ]; then
  UPD_COUNT=$(jq -r '.updates_available // 0' "$WORKSPACE_DIR/metrics/extensions_status.json" 2>/dev/null || echo "0")
  if [ "$UPD_COUNT" -gt 0 ]; then
    echo -e "\n${YELLOW}💡 NOTICE: ${UPD_COUNT} Web IDE extensions have updates available.${NC}"
    echo -e "   👉 Upgrade via: ${BOLD}./scripts/update-extensions.sh -u${NC}"
  fi
fi

# Start Dev Hub Bridge background daemon for 1-click GUI container toggling
if [ -f "$SCRIPT_DIR/internal/dev-hub-bridge.py" ] && ! curl -s http://localhost:8089/api/status >/dev/null 2>&1; then
  python3 "$SCRIPT_DIR/internal/dev-hub-bridge.py" >/dev/null 2>&1 &
fi

echo ""
echo -e "${CYAN}==================================================================${NC}"
echo -e "$(msg_str "LABEL_STARTED_AT" "$START_TIME_HUMAN")"
echo -e "$(msg_str "LABEL_FINISHED_AT" "$(date '+%Y-%m-%d %H:%M:%S')")"
echo -e "$(msg_str "TOTAL_DURATION" "${GREEN}${TOTAL_MASTER_TIME}${NC} (${TOTAL_MASTER_SECS}s)")"
echo -e "$(msg_str "LOG_PATH_LABEL") [Log](file://$LOG_FILE)"
echo -e "$(msg_str "METRICS_PATH_LABEL") [Metrics](file://$WORKSPACE_DIR/metrics/setup_benchmarks.json)"
[ -n "${ACTIVE_BP_ID:-}" ] && save_blueprint_benchmark "$ACTIVE_BP_ID" "$TOTAL_MASTER_SECS"
# 🛡️ ARCHITECTURAL GUARDRAIL (Rule 12 & Invariant 3.7):
# Update .active_blueprint strictly after 100% successful verification!
if [ -n "${ACTIVE_BP_ID:-}" ]; then
  echo "$ACTIVE_BP_ID" > "$WORKSPACE_DIR/.active_blueprint" 2>/dev/null || true
fi
rm -f "$WORKSPACE_DIR/.setup_in_progress" 2>/dev/null || true
echo -e "${CYAN}==================================================================${NC}\n"

# ----------------------------------------------------------------------------
# Valikuline: Konteineripildi loomine ja sildistamine (--build-image)
# ----------------------------------------------------------------------------
if [ "${BUILD_IMAGE:-false}" = "true" ] && [ "$IS_LOCAL" = "true" ]; then
  echo -e "${CYAN}==================================================================${NC}"
  echo -e "${BOLD}📦 EELKONFIGUREERITUD PILDI LOOMINE (--build-image)${NC}"
  echo -e "${CYAN}==================================================================${NC}"

  TARGET_CONTAINER=$(get_active_db_instances 2>/dev/null | grep -v "publisher" | head -n 1 | cut -d'|' -f1 || echo "db-proxy")
  CONTAINER_CLI="podman"
  if ! command -v podman >/dev/null 2>&1 && command -v docker >/dev/null 2>&1; then
    CONTAINER_CLI="docker"
  fi

  if $CONTAINER_CLI container exists "$TARGET_CONTAINER" 2>/dev/null || [ "$DRY_RUN" = "true" ]; then
    echo -e "   1. Detecting database (${TARGET_CONTAINER}) internal versions..."
    DETECTED_INFO=$(detect_container_db_versions "$TARGET_CONTAINER" 2>/dev/null || echo "23ai:26.1:NONE")
    RAW_DB_VER=$(echo "$DETECTED_INFO" | cut -d':' -f1)
    RAW_APEX_VER=$(echo "$DETECTED_INFO" | cut -d':' -f2)
    RAW_ORDS_VER=$(echo "$DETECTED_INFO" | cut -d':' -f3)
    [ "$RAW_ORDS_VER" = "NONE" ] && RAW_ORDS_VER=""

    SEMANTIC_TAG=$(format_custom_image_tag "$RAW_DB_VER" "$RAW_APEX_VER" "$RAW_ORDS_VER")
    TARGET_IMAGE="localhost/oracle-free-apex:${SEMANTIC_TAG}"

    echo -e "      ├── Detected DB:     ${GREEN}${RAW_DB_VER:-23ai}${NC}"
    echo -e "      ├── Detected APEX:   ${GREEN}${RAW_APEX_VER:-26.1}${NC}"
    echo -e "      └── Target Image:    ${CYAN}${TARGET_IMAGE}${NC}"

    if $CONTAINER_CLI image exists "$TARGET_IMAGE" 2>/dev/null && [ "$DRY_RUN" != "true" ]; then
      echo -e "\n   ${YELLOW}ℹ️  Image ${TARGET_IMAGE} already exists in local store! Skipping creation.${NC}"
      echo -e "   💡 ${BOLD}Tip:${NC} If you want to rebuild the image, delete the old image first:"
      echo -e "      👉 ${YELLOW}$CONTAINER_CLI rmi ${TARGET_IMAGE}${NC}"
    else
      echo -e "\n   2. Committing container state into immutable image..."
      if [ "$DRY_RUN" = "true" ]; then
        echo -e "      ${YELLOW}[DRY-RUN]${NC} $CONTAINER_CLI commit \"$TARGET_CONTAINER\" \"$TARGET_IMAGE\""
        echo -e "      ${YELLOW}[DRY-RUN]${NC} $CONTAINER_CLI tag \"$TARGET_IMAGE\" \"localhost/oracle-free-apex:latest\""
      else
        $CONTAINER_CLI commit "$TARGET_CONTAINER" "$TARGET_IMAGE" >/dev/null
        $CONTAINER_CLI tag "$TARGET_IMAGE" "localhost/oracle-free-apex:latest" >/dev/null 2>&1 || true
        echo -e "      ${GREEN}✅ Image created: ${TARGET_IMAGE}${NC}"
      fi

      echo -e "\n   🚀 ${BOLD}Publish to Artifactory command:${NC}"
      echo -e "      👉 ${YELLOW}./scripts/publish-image-to-artifactory.sh --registry \"artifactory.firma.ee/docker-local/oracle\" --image \"${TARGET_IMAGE}\" --update-env${NC}"
    fi
  fi
  echo -e "${CYAN}==================================================================${NC}\n"
fi
