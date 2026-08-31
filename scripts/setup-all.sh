#!/usr/bin/env bash
# ============================================================================
# Master End-to-End Environment Setup & Benchmark Orchestrator
# Measures container image pulls, ORDS & APEX downloads, container healthcheck,
# APEX engine installation, patch application, and exports complete benchmark metrics.
# ============================================================================

set -e

# Vaigistame podman compose hoiatusteate välise teenusepakkuja kohta
export PODMAN_COMPOSE_WARNING_LOGS=false
export MASTER_SETUP="true"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
COMPOSE_FILE="$WORKSPACE_DIR/podman-compose.yml"
OVERRIDE_FILE="$WORKSPACE_DIR/podman-compose.override.yml"

# Kaasame ühise abiteegi ja profiilimootori
if [ -f "$SCRIPT_DIR/internal/common.sh" ]; then
  source "$SCRIPT_DIR/internal/common.sh"
fi
if [ -f "$SCRIPT_DIR/internal/blueprint-info.sh" ]; then
  source "$SCRIPT_DIR/internal/blueprint-info.sh"
fi

trap restore_cursor EXIT INT TERM

# Parameetrite parsimine
export FORCE=false
export SKIP_PUBLISHER=false
export SKIP_ORDS=false
export SKIP_MONITOR_APP=false
export SKIP_WEB_IDE=false
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
      shift
      ;;
    -l|--list|-lb|--list-blueprints|--list-scenarios)
      print_blueprints_table ""
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
    -b|--blueprint|--scenario|-s)
      val="$2"
      if [[ "$val" == *","* ]] || [ "$val" = "all" ] || [ "$val" = "ALL" ] || ! [[ "$val" =~ ^[0-9]+$ ]] || [ "$val" -lt 1 ] || [ "$val" -gt 49 ]; then
        echo -e "\n${RED}❌ VIGA: Toodangu/arenduse režiimis (--blueprint / -b) saab korraga valida AINULT ÜHE arhitektuurimalli vahemikus 1–49!${NC}"
        echo -e "ℹ️  Mitme kavandi järjestikuseks automaattestimiseks kasuta testrežiimi: ${YELLOW}--test-blueprints 1,3,7${NC} või ${YELLOW}--test-blueprints all${NC}\n"
        exit 1
      fi
      export SELECTED_BLUEPRINT="$val"
      shift 2
      ;;
    -b=*|--blueprint=*|--scenario=*|-s=*)
      val="${1#*=}"
      if [[ "$val" == *","* ]] || [ "$val" = "all" ] || [ "$val" = "ALL" ] || ! [[ "$val" =~ ^[0-9]+$ ]] || [ "$val" -lt 1 ] || [ "$val" -gt 49 ]; then
        echo -e "\n${RED}❌ VIGA: Toodangu/arenduse režiimis (--blueprint / -b) saab korraga valida AINULT ÜHE arhitektuurimalli vahemikus 1–49!${NC}"
        echo -e "ℹ️  Mitme kavandi järjestikuseks automaattestimiseks kasuta testrežiimi: ${YELLOW}--test-blueprints 1,3,7${NC} või ${YELLOW}--test-blueprints all${NC}\n"
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
      export ORDS_SKIP_REASON="Kasutaja ei soovi lokaalset ORDS teenust (käsurea võti --no-ords)"
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
    --from-snapshot)
      export RESTORE_FROM_SNAPSHOT=true
      shift
      ;;
    --apex-runtime|--runtime-only)
      export APEX_RUNTIME_ONLY=true
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
    *)
      shift
      ;;
  esac
done

# Dry-run simulatsiooni käsitlemine
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
    simulate_blueprint_dry_run "3" false
    exit 0
  fi
fi

ENV_PATH="$WORKSPACE_DIR/.env"
[ ! -f "$ENV_PATH" ] && ENV_PATH=".env"

# Interaktiivne Blueprintide valik (kui .env puudub või kasutaja kutsus -i/--select)
if { [ ! -f "$ENV_PATH" ] || [ "$INTERACTIVE_SELECT" = "true" ]; } && [ -z "$SELECTED_BLUEPRINT" ] && [ -z "$TEST_BLUEPRINTS" ] && [ "$FORCE" != "true" ] && [ -t 0 ]; then
  print_blueprints_table ""
  read -t 30 -p "👉 Vali blueprint [1-40] (Vaikimisi: 3): " user_choice || true
  user_choice="${user_choice:-3}"
  bp_file_check=$(get_blueprint_file "$user_choice" 2>/dev/null || echo "")
  if [ -z "$bp_file_check" ]; then
    echo -e "${RED}⚠️  Tundmatu valik '${user_choice}'. Kasutan vaikeväärtust: 3${NC}"
    user_choice=3
  fi
  export SELECTED_BLUEPRINT="$user_choice"
fi

# 1. AUTOMAATTESTIMISE REŽIIM (-tb / --test-blueprints): Teeb alati puhta algseisu (reset-all -y)
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

    cp "$BP_FILE" "$WORKSPACE_DIR/.env"
    ENV_PATH="$WORKSPACE_DIR/.env"
  else
    echo -e "${RED}❌ VIGA: Blueprinti '${TEST_BLUEPRINTS}' faili ei leitud kaustast config/blueprints/${NC}"
    exit 1
  fi
fi

# 2. TOODANGU / ARENDUSE REŽIIM (-b / --blueprint): EI TEE reset-all, vaid jätkab idempotentselt
if [ -n "$SELECTED_BLUEPRINT" ] && [ -z "$TEST_BLUEPRINTS" ]; then
  BP_FILE=$(get_blueprint_file "$SELECTED_BLUEPRINT" 2>/dev/null || echo "")
  if [ -n "$BP_FILE" ] && [ -f "$BP_FILE" ]; then
    ACTIVE_BP_ID=$(get_blueprint_number "$BP_FILE")
    planned_c=$(extract_blueprint_containers "$ACTIVE_BP_ID" 2>/dev/null || echo "")
    bp_hist_stats=$(get_blueprint_stats "$ACTIVE_BP_ID" 2>/dev/null || echo "")
    echo -e "${CYAN}🏗️  Aktiveerin arhitektuurse kavandi (Blueprint ${ACTIVE_BP_ID}): $(basename "$BP_FILE")${NC}"
    [ -n "$planned_c" ] && echo -e "   📦 Plaanitavad Konteinerid: ${GREEN}${planned_c}${NC}"
    [ -n "$bp_hist_stats" ] && echo -e "   ⏱️  $(msg_str "BENCHMARK_LABEL") ${YELLOW}${bp_hist_stats}${NC}"
    echo -e "${GREEN}ℹ️  Toodangurežiim: Säilitan olemasolevad andmebaasi andmed ja volumed (No Reset).${NC}"
    cp "$BP_FILE" "$WORKSPACE_DIR/.env"
    ENV_PATH="$WORKSPACE_DIR/.env"
  else
    echo -e "${RED}❌ VIGA: Blueprinti '${SELECTED_BLUEPRINT}' faili ei leitud kaustast config/blueprints/${NC}"
    exit 1
  fi
fi

# Laeme keskkonnamuutujad ja profiilimootori
if [ -f "$ENV_PATH" ]; then
  set -a
  source "$ENV_PATH"
  set +a
fi
[ -n "${SAVED_TEST_SCENARIO:-}" ] && export TEST_SCENARIO="$SAVED_TEST_SCENARIO"
[ -n "${SAVED_TEST_MODE:-}" ] && export IS_TEST_MODE="$SAVED_TEST_MODE"
ACTIVE_BP_ID="${ACTIVE_BP_ID:-${BLUEPRINT:-${TEST_SCENARIO:-}}}"
ACTIVE_BP_ID="${ACTIVE_BP_ID//[^0-9]/}"

if [ -f "$SCRIPT_DIR/internal/load-profile.sh" ]; then
  source "$SCRIPT_DIR/internal/load-profile.sh"
  load_db_profile
  load_web_ide_profile
fi

if [ "${IS_ADB:-false}" = "true" ]; then
  export APEX_DB_SID="${APEX_DB_SID:-${PROFILE_DB_SID:-FREE}}"
  export APEX_DB_PDB="${APEX_DB_PDB:-${PROFILE_DB_PDB:-MYATP}}"
  export APEX_DB_CONTAINER_PORT="${APEX_DB_CONTAINER_PORT:-$PROFILE_CONTAINER_PORT}"
fi

# 1. Resolve Adaptive TLS/HTTPS Mode and validate Blueprint policy level
if [ -f "$SCRIPT_DIR/internal/resolve-tls-mode.sh" ]; then
  source "$SCRIPT_DIR/internal/resolve-tls-mode.sh"
  if ! resolve_tls_mode; then
    echo -e "${RED}❌ Seadistus katkestatud TLS nõuete ebakõla tõttu.${NC}"
    exit 1
  fi
fi

# 2. Genereerime ja usaldame kohalikud SSL/TLS sertifikaadid (vajadusel)
if [ "$RESOLVED_TLS_MODE" = "USER_LOCAL" ] && [ -x "$SCRIPT_DIR/internal/generate-local-certs.sh" ]; then
  "$SCRIPT_DIR/internal/generate-local-certs.sh" --no-prompt || true
  if [[ "$OSTYPE" == "darwin"* ]] && [ -x "$SCRIPT_DIR/certs/trust-local-cert-mac.sh" ]; then
    "$SCRIPT_DIR/certs/trust-local-cert-mac.sh" >/dev/null 2>&1 || true
  fi
fi

# Genereerime podman-compose.override.yml profiilide ja saladuste põhjal
if [ -x "$SCRIPT_DIR/internal/generate-compose-override.sh" ]; then
  "$SCRIPT_DIR/internal/generate-compose-override.sh"
fi

COMPOSE_ARGS=(-f "$COMPOSE_FILE")
[ -f "$OVERRIDE_FILE" ] && COMPOSE_ARGS+=(-f "$OVERRIDE_FILE")

export TNS_ADMIN="$WORKSPACE_DIR/config/tns_admin"

# Dynamically evaluate active DB profiles to check if components.publisher.enabled=true
ANY_PUB_ENABLED=false
for inst in $(get_active_db_instances 2>/dev/null); do
  pname=$(echo "$inst" | cut -d'|' -f2)
  pfile="$WORKSPACE_DIR/config/profiles/databases/${pname}.yaml"
  [ ! -f "$pfile" ] && pfile="$WORKSPACE_DIR/config/profiles/${pname}.yaml"
  if [ -f "$pfile" ]; then
    pub_en=$(grep -A 5 "publisher:" "$pfile" 2>/dev/null | grep -E '^[[:space:]]*enabled:' | head -n 1 | sed -E 's/.*:[[:space:]]*"?([^"]+)"?/\1/' | tr -d '\r\n')
    if [ "$pub_en" = "true" ]; then
      ANY_PUB_ENABLED=true
      break
    fi
  fi
done

if [ "$ANY_PUB_ENABLED" = "true" ] || [ "${PUBLISHER_ENABLED:-false}" = "true" ] || [ "${SKIP_PUBLISHER:-true}" = "false" ]; then
  if [ "$SKIP_PUBLISHER" != "true" ]; then
    SKIP_PUBLISHER=false
    ANY_PUB_ENABLED=true
    PUBLISHER_DB_HOST="${PUBLISHER_DB_HOST:-pub-db}"
  fi
else
  SKIP_PUBLISHER=true
fi

# Dynamically evaluate active DB profiles to check if components.forms.enabled=true
ANY_FORMS_ENABLED=false
for inst in $(get_active_db_instances 2>/dev/null); do
  pname=$(echo "$inst" | cut -d'|' -f2)
  pfile="$WORKSPACE_DIR/config/profiles/databases/${pname}.yaml"
  [ ! -f "$pfile" ] && pfile="$WORKSPACE_DIR/config/profiles/${pname}.yaml"
  if [ -f "$pfile" ]; then
    forms_en=$(awk '/forms:/{flag=1;next}/ords:|apex:|publisher:|users:/{flag=0}flag' "$pfile" | grep -E '^[[:space:]]*enabled:' | head -n 1 | sed -E 's/.*:[[:space:]]*"?([^"]+)"?/\1/' | tr -d '\r\n')
    if [ "$forms_en" = "true" ]; then
      ANY_FORMS_ENABLED=true
      break
    fi
  fi
done

if [ "${SKIP_FORMS:-true}" = "false" ] || [ "${ENABLE_FORMS:-false}" = "true" ]; then
  ANY_FORMS_ENABLED=true
fi

ANY_LOCAL_ORDS_NEEDED=false
is_adb_prof=false
for inst in $(get_active_db_instances 2>/dev/null); do
  pname=$(echo "$inst" | cut -d'|' -f2)
  pfile="$WORKSPACE_DIR/config/profiles/databases/${pname}.yaml"
  [ ! -f "$pfile" ] && pfile="$WORKSPACE_DIR/config/profiles/${pname}.yaml"
  if [ -f "$pfile" ]; then
    if [ "$ords_cnt_req" = "false" ]; then
      is_adb_prof=true
    fi
    if { [ "$ords_en" = "true" ] || [ -z "$ords_en" ]; } && [ "$ords_cnt_req" != "false" ]; then
      ANY_LOCAL_ORDS_NEEDED=true
      break
    fi
  fi
done

if [ "$ANY_LOCAL_ORDS_NEEDED" = "false" ] && [ "${SKIP_ORDS:-false}" = "true" ]; then
  SKIP_ORDS=true
  if [ "${IS_ADB:-false}" = "true" ] || [ "$is_adb_prof" = "true" ]; then
    ORDS_SKIP_REASON="Kasutatakse sisseehitatud ADB ORDS-i ilma eraldiseisva app-ords konteinerita"
  else
    [ -z "$ORDS_SKIP_REASON" ] && ORDS_SKIP_REASON="Profiili YAML failis on eraldi ORDS konteiner välja lülitatud"
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
  [ -z "$ORDS_SKIP_REASON" ] && ORDS_SKIP_REASON="Kasutatakse Oracle ADB-d (Autonomous Database), mis sisaldab sisseehitatud ORDS-i"
elif [ "$IS_LOCAL" = "false" ]; then
  [ -z "$ORDS_SKIP_REASON" ] && ORDS_SKIP_REASON="Tegemist on kaugserveriga (Remote Database)"
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

# Logifaili seadistus
LOG_DIR="$WORKSPACE_DIR/install_logs"
mkdir -p "$LOG_DIR"
METRICS_DIR="$WORKSPACE_DIR/metrics"
mkdir -p "$METRICS_DIR"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$LOG_DIR/env_setup_${TIMESTAMP}.log"
# Säilitame algse TTY väljundi failideskriptoris 3 reaalajas loendurite jaoks
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
if [ "$SKIP_ORDS" = "true" ]; then
  print_header "2" "$(msg_str "STEP_2_TITLE")"
  echo -e "   ℹ️  Standalone ORDS container not required. (Reason: ${CYAN}${ORDS_SKIP_REASON:-disabled}${NC})"
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
    echo "   ✅ Leitud täpne kohalik ORDS tarkvarapakett: $(basename "$FOUND_ORDS_ZIP")"
  elif [ -f "$ORDS_BIN_DIR/ords-latest.zip" ] && unzip -t "$ORDS_BIN_DIR/ords-latest.zip" &>/dev/null; then
    FOUND_ORDS_ZIP="$ORDS_BIN_DIR/ords-latest.zip"
    echo "   ✅ Leitud olemasolev kohalik ORDS tarkvarapakett: ords-latest.zip"
  fi

  if [ -z "$FOUND_ORDS_ZIP" ]; then
    echo "   ℹ️  Laadin ORDS paketi URL-ilt: $ORDS_URL..."
    curl -sSL -k -o "$EXPECTED_ORDS_PATH" "$ORDS_URL" || true
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
      echo "   ✅ Leitud olemasolev kohalik APEX tarkvarapakett: $(basename "$FOUND_APEX_ZIP")"
      ZIP_PATH="$FOUND_APEX_ZIP"
    else
      echo "   Laadin alla APEX $ver ($ZIP_NAME)..."
      rm -f "$ZIP_PATH"
      curl -sSL -k -o "$ZIP_PATH" "$VER_URL" || true
      if ! unzip -t "$ZIP_PATH" &>/dev/null; then
        echo "   ⚠️  Allalaaditud fail ei ole kehtiv ZIP arhiiv. Otsin kohalikku apex-latest.zip..."
        rm -f "$ZIP_PATH"
        if [ -f "$APEX_BIN_DIR/apex-latest.zip" ] && unzip -t "$APEX_BIN_DIR/apex-latest.zip" &>/dev/null; then
          ZIP_PATH="$APEX_BIN_DIR/apex-latest.zip"
        elif [ -f "$WORKSPACE_DIR/binaries/apex-latest.zip" ] && unzip -t "$WORKSPACE_DIR/binaries/apex-latest.zip" &>/dev/null; then
          ZIP_PATH="$WORKSPACE_DIR/binaries/apex-latest.zip"
        fi
      fi
    fi

    TARGET_DIR="$WORKSPACE_DIR/db-install/apex_$ver"
    if [ ! -d "$TARGET_DIR/apex" ]; then
      echo "   Pakin lahti APEX $ver -> $TARGET_DIR..."
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
# SAMM 4: Konteinerite käivitamine ja andmebaaside tervisekontroll (Healthcheck)
# ----------------------------------------------------------------------------
STEP4_START=$(date +%s)
if [ "$IS_LOCAL" = "true" ]; then
  mkdir -p "$WORKSPACE_DIR/config/tns_admin"
  print_header "4" "$(msg_str "STEP_4_TITLE")" "step4_container_startup_seconds" "45s"

  if [ "${RESTORE_FROM_SNAPSHOT:-false}" = "true" ] && [ -f "$SCRIPT_DIR/snapshots/restore-golden-snapshots.sh" ]; then
    echo -e "${CYAN}📸 [TASK-018]: Taastan andmemahud eelnevalt salvestatud Golden Snapshotist...${NC}"
    "$SCRIPT_DIR/snapshots/restore-golden-snapshots.sh" || true
  fi

  LOCAL_COMPOSE_ARGS=("${COMPOSE_ARGS[@]}")
  load_web_ide_profile >/dev/null 2>&1 || true
  if [ "${WEB_IDE_ENABLED:-false}" = "true" ] && [ "$SKIP_WEB_IDE" = "false" ]; then
    LOCAL_COMPOSE_ARGS+=(--profile web-ide)
  fi

  if [ -x "$SCRIPT_DIR/internal/generate-dev-hub.sh" ]; then
    "$SCRIPT_DIR/internal/generate-dev-hub.sh" "$WORKSPACE_DIR/docs/dev-hub.html" >/dev/null 2>&1 || true
  fi

  (
    podman-compose "${LOCAL_COMPOSE_ARGS[@]}" up -d >> "$LOG_FILE" 2>&1
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

  # Kasutame adaptiivset ja iseparanevat tervisekontrolli moodulit
  if [ -x "$SCRIPT_DIR/internal/wait-db-healthy.sh" ]; then
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
# SAMM 4.5: Oracle Wallet ja TNS algseadistamine (SEPS)
# ----------------------------------------------------------------------------
STEP4_5_SECS=0
if [ "$IS_LOCAL" = "true" ]; then
  print_header "4.5" "$(msg_str "STEP_4_5_TITLE")" "step4_5_wallet_tns_config_seconds" "10s"
  STEP4_5_START=$(date +%s)
  
  # Sünkroniseerime andmebaaside kasutajad ja paroolid enne Walleti ja ORDSi tööd
  if [ -x "$SCRIPT_DIR/internal/apply-profile-users.sh" ]; then
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
# SAMM 5: ORDS teenuse käivitamise ja reageerimise kontroll
# ----------------------------------------------------------------------------
STEP5_START=$(date +%s)
if [ "$SKIP_ORDS" = "true" ] || [ "$IS_LOCAL" = "false" ]; then
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
# SAMM 6: APEX Mootori ja Patchi automaatne paigaldamine
# ----------------------------------------------------------------------------
print_header "6" "$(msg_str "STEP_6_TITLE")" "step7_apex_engine_install_seconds" "6m"
ACTIVE_INST_LIST=$(get_active_db_instances 2>/dev/null || echo "")
for inst in $ACTIVE_INST_LIST; do
  c_name=$(echo "$inst" | cut -d'|' -f1)
  prof=$(echo "$inst" | cut -d'|' -f2)
  [ -z "$c_name" ] && continue
  (
    load_db_profile "$prof" >/dev/null 2>&1 || true
    if [ "${PROFILE_APEX_ENABLED:-true}" = "false" ] || [ "${PROFILE_APEX_VERSION:-NONE}" = "NONE" ]; then
      echo -e "   $(msg_str "APEX_NOT_ACTIVE_INFO" "$c_name")"
    else
      echo -e "   🚀 [${c_name}]: $(msg_str "APEX_STARTING_INSTALL" "${PROFILE_APEX_VERSION:-26.1}")"
      INSTALL_ARGS=()
      [ "$FORCE" = "true" ] && INSTALL_ARGS+=("--force")
      [ "${APEX_RUNTIME_ONLY:-false}" = "true" ] && INSTALL_ARGS+=("--runtime-only")
      INSTALL_ARGS+=("--db" "$(echo "$c_name" | sed 's/^db-//' | tr '-' '_')" "--version" "${PROFILE_APEX_VERSION:-26.1}" "--port" "${PROFILE_DB_PORT}" "--service" "${PROFILE_DEFAULT_SERVICE}")
      if [ "${PROFILE_ORDS_ENABLED:-true}" = "false" ] || [ "$SKIP_ORDS" = "true" ]; then
        INSTALL_ARGS+=("--no-ords")
      fi
      "$SCRIPT_DIR/internal/install-apex.sh" "${INSTALL_ARGS[@]}"
    fi
  )
done

# ----------------------------------------------------------------------------
# SAMM 7: Andmebaasi skeemi migratsioonid (Liquibase / Init DB)
# ----------------------------------------------------------------------------
STEP5_5_START=$(date +%s)
print_header "7" "$(msg_str "STEP_7_TITLE")" "step5_5_liquibase_migration_seconds" "15s"
STEP5_5_LOG="$LOG_DIR/db_sqlcl_deploy_${TIMESTAMP}.log"

get_active_db_instances 2>/dev/null | while IFS='|' read -r c_name prof env_key; do
  [ -z "$c_name" ] && continue
  ( "$SCRIPT_DIR/internal/init-db-instance.sh" "$prof" "$c_name" >> "$STEP5_5_LOG" 2>&1 ) &
done
wait

STEP5_5_SECS=$(( $(date +%s) - STEP5_5_START ))
STEP5_5_TIME=$(format_duration $STEP5_5_SECS)
echo -e "⏱  [$(msg_str "STEP_7_NAME"): ${GREEN}$STEP5_5_TIME${NC}]"

# Sünkroniseerime profiili kasutajad, APEX-i töökohad ja ORDS-i metaandmed
if [ -x "$SCRIPT_DIR/internal/apply-profile-users.sh" ]; then
  get_active_db_instances 2>/dev/null | while IFS='|' read -r c_name prof env_key; do
    [ -n "$c_name" ] && "$SCRIPT_DIR/internal/apply-profile-users.sh" "$c_name" >> "$LOG_DIR/apply_profile_users_${TIMESTAMP}.log" 2>&1 || true
  done
fi

if [ "$SKIP_ORDS" = "false" ] && podman container exists app-ords 2>/dev/null; then
  echo -e "🔄 $(msg_str "ORDS_RESTARTING_POOLS")"
  podman restart app-ords >/dev/null 2>&1 || true
  sleep 8
fi

# ----------------------------------------------------------------------------
# SAMM 8: APEX rakenduste paigaldamine (Deploy Packaged APEX Applications)
# ----------------------------------------------------------------------------
STEP8_START=$(date +%s)
print_header "8" "$(msg_str "STEP_8_TITLE")" "step10_deploy_apex_apps_seconds" "10s"

if [ "$SKIP_MONITOR_APP" = "true" ] || [ "${PROFILE_APEX_ENABLED:-true}" = "false" ]; then
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
# SAMM 9: Oracle Analytics Publisher paigaldamine ja initsialiseerimine
# ----------------------------------------------------------------------------
PUB_INSTALL_SECS=0
if [ "$SKIP_PUBLISHER" = "false" ] && { [ "$ANY_PUB_ENABLED" = "true" ] || [ "${PUBLISHER_ENABLED:-false}" = "true" ]; }; then
  PUB_START=$(date '+%s')
  echo -e "\n${YELLOW}🚀 $(msg_str "PUB_STARTING_SETUP")${NC}"
  if [ -x "$SCRIPT_DIR/internal/install-publisher.sh" ]; then
    "$SCRIPT_DIR/internal/install-publisher.sh" || true
  fi
  PUB_INSTALL_SECS=$(( $(date '+%s') - PUB_START ))
  echo -e "⏱  [$(msg_str "STEP_9_COMPLETED"): ${YELLOW}$(format_duration ${PUB_INSTALL_SECS})${NC}]"
fi

# ----------------------------------------------------------------------------
# SAMM 9.5: Oracle Forms 14c paigaldamine ja initsialiseerimine
# ----------------------------------------------------------------------------
FORMS_INSTALL_SECS=0
if [ "${SKIP_FORMS:-false}" != "true" ] && { [ "$ANY_FORMS_ENABLED" = "true" ] || [ "${ENABLE_FORMS:-false}" = "true" ]; }; then
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
# SAMM 10: Hetktõmmise (Golden Snapshot) loomine
# ----------------------------------------------------------------------------
STEP9_SECS=0
if [ "$FORCE" != "true" ] && [ "${IS_TEST_MODE:-false}" != "true" ]; then
  print_header "10" "$(msg_str "STEP_10_TITLE")" "snapshot_duration_seconds" "2m"
  prompt_user_confirm "❓ Kas soovid värskelt paigaldatud keskkonnast kohe teha hetktõmmise (Golden Snapshot)?" MAKE_BACKUP_CONFIRM 45 "N" \
    "Loodakse andmebaasi ja mahutite täielik varukoopia kausta golden-snapshots/." \
    "Hetktõmmise loomine jäetakse vahele."
  
  if [[ "$MAKE_BACKUP_CONFIRM" =~ ^[Yy]$ ]]; then
    SNAP_START=$(date +%s)
    "$SCRIPT_DIR/snapshots/create-golden-snapshots.sh"
    STEP9_SECS=$(( $(date +%s) - SNAP_START ))
  fi
fi

# Arendajakonto ja VS Code ühenduse loomine
if [ "$IS_LOCAL" = "true" ] && [ "${ENVIRONMENT_TYPE:-DEV}" = "DEV" ]; then
  if [ "${PROFILE_APEX_ENABLED:-true}" = "true" ]; then
    "$SCRIPT_DIR/create-developer.sh" --force >/dev/null 2>&1 || true
  fi
fi

if [ "$SKIP_WEB_IDE" = "false" ]; then
  if [ -x "$SCRIPT_DIR/internal/init-web-ide.sh" ]; then
    "$SCRIPT_DIR/internal/init-web-ide.sh" >/dev/null 2>&1 || true
  fi
fi

TOTAL_MASTER_SECS=$(( $(date +%s) - START_MASTER_TOTAL ))
TOTAL_MASTER_TIME=$(format_duration $TOTAL_MASTER_SECS)

# Eksport mõõdikute raporti generaatorile
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

# URL ja Walleti automaattestid (Käivitatakse enne raporti genereerimist, et tulemused jõuaksid raportisse)
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

# Raportite ja JSON mõõdikute genereerimine
if [ -x "$SCRIPT_DIR/internal/generate-setup-report.sh" ]; then
  "$SCRIPT_DIR/internal/generate-setup-report.sh"
fi

# VS Code ühenduste registreerimine
if [ "$IS_LOCAL" = "true" ] && [ -f "$SCRIPT_DIR/register-connections.sh" ]; then
  "$SCRIPT_DIR/register-connections.sh" >/dev/null 2>&1 || true
fi

# Lõplik kokkuvõte ja Live Developer Dashboard
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

if [ "${PROFILE_ORDS_ENABLED:-true}" = "true" ] && [ "$SKIP_ORDS" != "true" ]; then
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
      ords_en=$(awk '/ords:/{flag=1;next}/apex:|publisher:|forms:|sqlcl:|users:/{flag=0}flag' "$pfile" | grep -E '^[[:space:]]*enabled:' | head -n 1 | sed -E 's/.*:[[:space:]]*"?([^"]+)"?/\1/' | tr -d '\r\n')
      apex_en=$(awk '/apex:/{flag=1;next}/ords:|publisher:|forms:|sqlcl:|users:/{flag=0}flag' "$pfile" | grep -E '^[[:space:]]*enabled:' | head -n 1 | sed -E 's/.*:[[:space:]]*"?([^"]+)"?/\1/' | tr -d '\r\n')
      p_ws=$(awk '/apex:/{flag=1;next}/ords:|publisher:|forms:|sqlcl:|users:/{flag=0}flag' "$pfile" | grep -E '^[[:space:]]*workspace:' | head -n 1 | sed -E 's/.*:[[:space:]]*"?([^"]+)"?/\1/' | tr -d '\r\n')
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
fi

if [ "${SKIP_FORMS:-true}" != "true" ] && ([ "${PROFILE_FORMS_ENABLED:-false}" = "true" ] || [ "${ENABLE_FORMS:-false}" = "true" ] || podman container exists app-forms 2>/dev/null); then
  ACTIVE_FORMS_PORT="${FORMS_HTTP_PORT:-9001}"
  printf "│ %-31s │ %-42s │ %-27s │\n" "📐 Forms 14c Services" "http://localhost:${ACTIVE_FORMS_PORT}/forms/frmservlet" "Runtime / test.fmx"
  printf "│ %-31s │ %-42s │ %-27s │\n" "🎨 Forms Builder GUI" "http://localhost:6082/vnc.html" "Visual Builder (noVNC)"
fi

if [ "${SKIP_PUBLISHER:-true}" != "true" ] && ([ "${PROFILE_PUBLISHER_ENABLED:-false}" = "true" ] || [ "${PUBLISHER_ENABLED:-false}" = "true" ] || podman container exists app-publisher 2>/dev/null); then
  printf "│ %-31s │ %-42s │ %-27s │\n" "📑 Analytics Publisher" "http://localhost:${ACTIVE_PUB_PORT}/xmlpserver" "User: weblogic / SYS"
fi

if [ "${SKIP_WEB_IDE:-true}" != "true" ] && podman container exists web-ide-dev 2>/dev/null; then
  printf "│ %-31s │ %-42s │ %-27s │\n" "💻 Web IDE (VS Code)" "http://localhost:${ACTIVE_WEB_IDE_PORT}/" "Zero-Install Workspace"
fi
printf "└─────────────────────────────────┴────────────────────────────────────────────┴─────────────────────────────┘\n"

echo -e "\n${CYAN}$(msg_str "TREE_HEADER")${NC}"
for inst in $(get_active_db_instances 2>/dev/null); do
  c_name=$(echo "$inst" | cut -d'|' -f1)
  prof=$(echo "$inst" | cut -d'|' -f2)
  pfile="$WORKSPACE_DIR/config/profiles/databases/${prof}.yaml"
  [ ! -f "$pfile" ] && pfile="$WORKSPACE_DIR/config/profiles/${prof}.yaml"
  c_port="1521"
  c_svc="FREEPDB1"
  if [ -f "$pfile" ]; then
    c_port=$(grep -E '^[[:space:]]*db_port:' "$pfile" | head -n 1 | awk -F: '{print $2}' | tr -d ' "\r\n')
    c_svc=$(grep -E '^[[:space:]]*default_service:' "$pfile" | head -n 1 | awk -F: '{print $2}' | tr -d ' "\r\n')
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

echo ""
echo -e "${CYAN}==================================================================${NC}"
echo -e "$(msg_str "LABEL_STARTED_AT" "$START_TIME_HUMAN")"
echo -e "$(msg_str "LABEL_FINISHED_AT" "$(date '+%Y-%m-%d %H:%M:%S')")"
echo -e "$(msg_str "TOTAL_DURATION" "${GREEN}${TOTAL_MASTER_TIME}${NC} (${TOTAL_MASTER_SECS}s)")"
echo -e "$(msg_str "LOG_PATH_LABEL") [Log](file://$LOG_FILE)"
echo -e "$(msg_str "METRICS_PATH_LABEL") [Metrics](file://$WORKSPACE_DIR/metrics/setup_benchmarks.json)"
[ -n "${ACTIVE_BP_ID:-}" ] && save_blueprint_benchmark "$ACTIVE_BP_ID" "$TOTAL_MASTER_SECS"
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
    echo -e "   1. Tuvastan andmebaasist (${TARGET_CONTAINER}) siseversioonid..."
    DETECTED_INFO=$(detect_container_db_versions "$TARGET_CONTAINER" 2>/dev/null || echo "23ai:26.1:NONE")
    RAW_DB_VER=$(echo "$DETECTED_INFO" | cut -d':' -f1)
    RAW_APEX_VER=$(echo "$DETECTED_INFO" | cut -d':' -f2)
    RAW_ORDS_VER=$(echo "$DETECTED_INFO" | cut -d':' -f3)
    [ "$RAW_ORDS_VER" = "NONE" ] && RAW_ORDS_VER=""

    SEMANTIC_TAG=$(format_custom_image_tag "$RAW_DB_VER" "$RAW_APEX_VER" "$RAW_ORDS_VER")
    TARGET_IMAGE="localhost/oracle-free-apex:${SEMANTIC_TAG}"

    echo -e "      ├── Tuvastatud DB:   ${GREEN}${RAW_DB_VER:-23ai}${NC}"
    echo -e "      ├── Tuvastatud APEX: ${GREEN}${RAW_APEX_VER:-26.1}${NC}"
    echo -e "      └── Sihtpildi Sildis: ${CYAN}${TARGET_IMAGE}${NC}"

    if $CONTAINER_CLI image exists "$TARGET_IMAGE" 2>/dev/null && [ "$DRY_RUN" != "true" ]; then
      echo -e "\n   ${YELLOW}ℹ️  Pilt ${TARGET_IMAGE} on juba süsteemis olemas! Jätan pildi loomise vahele.${NC}"
      echo -e "   💡 ${BOLD}Soovitus:${NC} Kui soovid pilti uuesti ehitada, kustuta vana pilt käsuga:"
      echo -e "      👉 ${YELLOW}$CONTAINER_CLI rmi ${TARGET_IMAGE}${NC}"
    else
      echo -e "\n   2. Salvestan konteineri oleku immutatavaks pildiks..."
      if [ "$DRY_RUN" = "true" ]; then
        echo -e "      ${YELLOW}[DRY-RUN]${NC} $CONTAINER_CLI commit \"$TARGET_CONTAINER\" \"$TARGET_IMAGE\""
        echo -e "      ${YELLOW}[DRY-RUN]${NC} $CONTAINER_CLI tag \"$TARGET_IMAGE\" \"localhost/oracle-free-apex:latest\""
      else
        $CONTAINER_CLI commit "$TARGET_CONTAINER" "$TARGET_IMAGE" >/dev/null
        $CONTAINER_CLI tag "$TARGET_IMAGE" "localhost/oracle-free-apex:latest" >/dev/null 2>&1 || true
        echo -e "      ${GREEN}✅ Pilt loodud: ${TARGET_IMAGE}${NC}"
      fi

      echo -e "\n   🚀 ${BOLD}Artifactorysse laadimise käsk:${NC}"
      echo -e "      👉 ${YELLOW}./scripts/publish-image-to-artifactory.sh --registry \"artifactory.firma.ee/docker-local/oracle\" --image \"${TARGET_IMAGE}\" --update-env${NC}"
    fi
  fi
  echo -e "${CYAN}==================================================================${NC}\n"
fi
