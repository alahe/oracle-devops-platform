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
    -b|--blueprint|--scenario|-s)
      val="$2"
      if [[ "$val" == *","* ]] || [ "$val" = "all" ] || [ "$val" = "ALL" ] || ! [[ "$val" =~ ^[0-9]+$ ]] || [ "$val" -lt 1 ] || [ "$val" -gt 13 ]; then
        echo -e "\n${RED}❌ VIGA: Toodangu/arenduse režiimis (--blueprint / -b) saab korraga valida AINULT ÜHE arhitektuurimalli vahemikus 1–13!${NC}"
        echo -e "ℹ️  Mitme kavandi järjestikuseks automaattestimiseks kasuta testrežiimi: ${YELLOW}--test-blueprints 1,3,7${NC} või ${YELLOW}--test-blueprints all${NC}\n"
        exit 1
      fi
      export SELECTED_BLUEPRINT="$val"
      shift 2
      ;;
    -b=*|--blueprint=*|--scenario=*|-s=*)
      val="${1#*=}"
      if [[ "$val" == *","* ]] || [ "$val" = "all" ] || [ "$val" = "ALL" ] || ! [[ "$val" =~ ^[0-9]+$ ]] || [ "$val" -lt 1 ] || [ "$val" -gt 13 ]; then
        echo -e "\n${RED}❌ VIGA: Toodangu/arenduse režiimis (--blueprint / -b) saab korraga valida AINULT ÜHE arhitektuurimalli vahemikus 1–13!${NC}"
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
      bp_list_to_test="1 2 3 4 5 6 7 8 9 10 11 12 13"
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
  read -t 30 -p "👉 Vali blueprint [1-13] (Vaikimisi: 3): " user_choice || true
  user_choice="${user_choice:-3}"
  if ! [[ "$user_choice" =~ ^[0-9]+$ ]] || [ "$user_choice" -lt 1 ] || [ "$user_choice" -gt 13 ]; then
    echo -e "${RED}⚠️  Tundmatu valik '${user_choice}'. Kasutan vaikeväärtust: 3${NC}"
    user_choice=3
  fi
  export SELECTED_BLUEPRINT="$user_choice"
fi

# 1. AUTOMAATTESTIMISE REŽIIM (-tb / --test-blueprints): Teeb alati puhta algseisu (reset-all -y)
if [ -n "$TEST_BLUEPRINTS" ]; then
  BP_LIST=""
  if [ "$TEST_BLUEPRINTS" = "all" ] || [ "$TEST_BLUEPRINTS" = "ALL" ]; then
    BP_LIST="1 2 3 4 5 6 7 8 9 10 11 12 13"
  elif [[ "$TEST_BLUEPRINTS" == *","* ]]; then
    BP_LIST=$(echo "$TEST_BLUEPRINTS" | tr ',' ' ')
  fi

  if [ -n "$BP_LIST" ]; then
    echo -e "${CYAN}🚀 KÄIVITAN MITME BLUEPRINTI AUTOMATISEERITUD TESTIDE JADA: ${BP_LIST}${NC}"
    for bp in $BP_LIST; do
      echo -e "\n${YELLOW}==================================================================${NC}"
      echo -e "${YELLOW}🧪 ALUSTAN BLUEPRINTI ${bp} TESTIMIST (Puhas Algseis)...${NC}"
      echo -e "${YELLOW}==================================================================${NC}\n"
      "$SCRIPT_DIR/reset-all.sh" -y
      "$SCRIPT_DIR/setup-all.sh" -tb "$bp"
    done
    echo -e "\n${GREEN}==================================================================${NC}"
    echo -e "${GREEN}✅ KÕIK VALITUD BLUEPRINTID (${TEST_BLUEPRINTS}) ON EDUKALT TESTITUD!${NC}"
    echo -e "${GREEN}==================================================================${NC}\n"
    exit 0
  fi

  BP_FILE=$(ls "$WORKSPACE_DIR/config/blueprints/.env.${TEST_BLUEPRINTS}-"* 2>/dev/null | head -n 1)
  if [ -n "$BP_FILE" ] && [ -f "$BP_FILE" ]; then
    ACTIVE_BP_ID="$TEST_BLUEPRINTS"
    planned_c=$(extract_blueprint_containers "$TEST_BLUEPRINTS" 2>/dev/null || echo "")
    bp_hist_stats=$(get_blueprint_stats "$TEST_BLUEPRINTS" 2>/dev/null || echo "")
    echo -e "${CYAN}🧪 Test-moodus: Laen blueprinti ${TEST_BLUEPRINTS}: $(basename "$BP_FILE")${NC}"
    [ -n "$planned_c" ] && echo -e "   📦 Plaanitavad Konteinerid: ${GREEN}${planned_c}${NC}"
    [ -n "$bp_hist_stats" ] && echo -e "   ⏱️  Ajalooline ooteaeg: ${YELLOW}${bp_hist_stats}${NC}"
    
    if [ "${ALREADY_RESET:-false}" != "true" ]; then
      echo -e "${YELLOW}🧹 Test-moodus: Puhastan eelmise keskkonna (reset-all.sh -y)...${NC}"
      "$SCRIPT_DIR/reset-all.sh" -y
      export ALREADY_RESET="true"
    fi

    cp "$BP_FILE" "$WORKSPACE_DIR/.env"
    ENV_PATH="$WORKSPACE_DIR/.env"
  else
    echo -e "${RED}❌ VIGA: Blueprinti ${TEST_BLUEPRINTS} faili ei leitud kaustast config/blueprints/${NC}"
    exit 1
  fi
fi

# 2. TOODANGU / ARENDUSE REŽIIM (-b / --blueprint): EI TEE reset-all, vaid jätkab idempotentselt
if [ -n "$SELECTED_BLUEPRINT" ] && [ -z "$TEST_BLUEPRINTS" ]; then
  BP_FILE=$(ls "$WORKSPACE_DIR/config/blueprints/.env.${SELECTED_BLUEPRINT}-"* 2>/dev/null | head -n 1)
  if [ -n "$BP_FILE" ] && [ -f "$BP_FILE" ]; then
    ACTIVE_BP_ID="$SELECTED_BLUEPRINT"
    planned_c=$(extract_blueprint_containers "$SELECTED_BLUEPRINT" 2>/dev/null || echo "")
    bp_hist_stats=$(get_blueprint_stats "$SELECTED_BLUEPRINT" 2>/dev/null || echo "")
    echo -e "${CYAN}🏗️  Aktiveerin arhitektuurse kavandi (Blueprint ${SELECTED_BLUEPRINT}): $(basename "$BP_FILE")${NC}"
    [ -n "$planned_c" ] && echo -e "   📦 Plaanitavad Konteinerid: ${GREEN}${planned_c}${NC}"
    [ -n "$bp_hist_stats" ] && echo -e "   ⏱️  Ajalooline ooteaeg: ${YELLOW}${bp_hist_stats}${NC}"
    echo -e "${GREEN}ℹ️  Toodangurežiim: Säilitan olemasolevad andmebaasi andmed ja volumed (No Reset).${NC}"
    cp "$BP_FILE" "$WORKSPACE_DIR/.env"
    ENV_PATH="$WORKSPACE_DIR/.env"
  else
    echo -e "${RED}❌ VIGA: Blueprinti ${SELECTED_BLUEPRINT} faili ei leitud kaustast config/blueprints/${NC}"
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

if [ "$ANY_PUB_ENABLED" = "true" ] || [ "${PUBLISHER_ENABLED:-false}" = "true" ]; then
  if [ "$SKIP_PUBLISHER" != "true" ]; then
    SKIP_PUBLISHER=false
    PUBLISHER_DB_HOST="${PUBLISHER_DB_HOST:-pub-db}"
  fi
else
  SKIP_PUBLISHER=true
fi

ANY_LOCAL_ORDS_NEEDED=false
is_adb_prof=false
for inst in $(get_active_db_instances 2>/dev/null); do
  pname=$(echo "$inst" | cut -d'|' -f2)
  pfile="$WORKSPACE_DIR/config/profiles/databases/${pname}.yaml"
  [ ! -f "$pfile" ] && pfile="$WORKSPACE_DIR/config/profiles/${pname}.yaml"
  if [ -f "$pfile" ]; then
    if grep -qE "db_type:[[:space:]]*(autonomous|adb)" "$pfile" 2>/dev/null || grep -q "adb-free" "$pfile" 2>/dev/null; then
      is_adb_prof=true
    fi
    ords_en=$(grep -A 8 "ords:" "$pfile" 2>/dev/null | grep -E '^[[:space:]]*enabled:' | head -n 1 | sed -E 's/.*:[[:space:]]*"?([^"]+)"?/\1/' | tr -d '\r\n')
    ords_cnt_req=$(grep -A 8 "ords:" "$pfile" 2>/dev/null | grep -E '^[[:space:]]*container_required:' | head -n 1 | sed -E 's/.*:[[:space:]]*"?([^"]+)"?/\1/' | tr -d '\r\n')
    if { [ "$ords_en" = "true" ] || [ -z "$ords_en" ]; } && [ "$ords_cnt_req" != "false" ] && [ "$is_adb_prof" != "true" ]; then
      ANY_LOCAL_ORDS_NEEDED=true
      break
    fi
  fi
done

if [ "$ANY_LOCAL_ORDS_NEEDED" = "false" ]; then
  SKIP_ORDS=true
  if [ "${IS_ADB:-false}" = "true" ] || [ "$is_adb_prof" = "true" ]; then
    ORDS_SKIP_REASON="Kasutatakse Oracle ADB-d (Autonomous Database), mis sisaldab sisseehitatud ORDS-i ja APEX-it"
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
echo -e "${YELLOW}🎯 TARGET CONFIGURATIONS (Aktiivsed Profiilid ja Sihtseadistused):${NC}"
get_active_db_instances | while IFS='|' read -r container prof env_key; do
  [ -z "$container" ] && continue
  (
    load_db_profile "$prof" >/dev/null 2>&1 || true
    p_port="${PROFILE_DB_PORT:-1532}"
    p_service="${PROFILE_DEFAULT_SERVICE:-FREEPDB1}"
    db_purpose="Kliendi äriandmete, PL/SQL loogika ja APEX rakenduse hoidla"
    if [ "$container" = "db-lis" ] || [ "$prof" = "app-free" ]; then
      db_purpose="LIS Labori Äriandmed, PL/SQL loogika ja LIS APEX rakendus (Restricted DB Zone - 0 outbound internet)"
    elif [ "$container" = "db-proxy" ] || [[ "$prof" == *"proxy"* ]]; then
      db_purpose="APEX Proxy vahekiht, Outbound REST Data Source, Azure Entra-ID (OIDC) ja Kafka puhver"
    elif [ "${PROFILE_PUBLISHER_ENABLED:-false}" = "true" ] || [ "$prof" = "publisher-only" ] || [ "$prof" = "publisher-free" ]; then
      db_purpose="Analytics Publisher RCU metaandmete & WebLogic infrastruktuuri hoidla"
    fi
    echo -e "  🔹 ${BOLD}${container}${NC} [Profiil: ${YELLOW}${prof}${NC}, Port: ${CYAN}${p_port}${NC}, Teenus: ${CYAN}${p_service}${NC}]"
    echo -e "     └─ Otstarve: ${DIM}${db_purpose}${NC}"
  )
done
echo -e "${CYAN}==================================================================${NC}"

# Logifaili seadistus
LOG_DIR="$WORKSPACE_DIR/install_logs"
mkdir -p "$LOG_DIR"
METRICS_DIR="$WORKSPACE_DIR/metrics"
mkdir -p "$METRICS_DIR"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$LOG_DIR/setup_benchmarks_${TIMESTAMP}.log"
exec > >(tee -a "$LOG_FILE") 2>&1

if [ -f "$SCRIPT_DIR/internal/sanitize-logs.sh" ]; then
  source "$SCRIPT_DIR/internal/sanitize-logs.sh"
fi

START_MASTER_TOTAL=$(date +%s)

# Execute pre-flight system resource and prerequisites check
if [ -x "$SCRIPT_DIR/internal/check-prerequisites.sh" ]; then
  "$SCRIPT_DIR/internal/check-prerequisites.sh"
fi

# ----------------------------------------------------------------------------
# SAMM 1: Konteinerite piltide allalaadimine (Container Images Pull)
# ----------------------------------------------------------------------------
PULL_START=$(date +%s)
if [ "$IS_LOCAL" = "true" ]; then
  print_header "1" "Checking / Pulling Container Images (${PROFILE_NAME:-Oracle DB & ORDS})..." "step1_container_images_pull_seconds" "1m"
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

  ELAPSED=0
  while kill -0 $PULL_PID 2>/dev/null; do
    sleep 2
    ELAPSED=$((ELAPSED + 2))
    print_progress "Laadin pilte" "$ELAPSED" 15
  done
  wait $PULL_PID || true
  clear_progress_line
  echo ""

  PULL_SECS=$(( $(date +%s) - PULL_START ))
  PULL_TIME=$(format_duration $PULL_SECS)
  echo -e "⏱  [Samm 1 valmis (Konteinerite piltide allalaadimine/kontroll): ${YELLOW}$PULL_TIME${NC}]"
else
  echo "=================================================================="
  echo "1. Kaug-andmebaas tuvastatud. Jätan konteinerite piltide pullimise vahele."
  echo "=================================================================="
  PULL_SECS=0
  PULL_TIME="vahele jäetud"
fi

# ----------------------------------------------------------------------------
# SAMM 2: ORDS tarkvarapaketi allalaadimine (ORDS Download)
# ----------------------------------------------------------------------------
ORDS_DL_START=$(date +%s)
if [ "$SKIP_ORDS" = "true" ]; then
  print_header "2" "ORDS tarkvarapaketi allalaadimine"
  echo -e "   ℹ️  Eraldi lokaalset ORDS konteinerit ei vajata. (Põhjus: ${CYAN}${ORDS_SKIP_REASON:-välja lülitatud}${NC})"
  ORDS_DL_SECS=0
  ORDS_DL_TIME="vahele jäetud"
else
  print_header "2" "Checking / Downloading ORDS Software Package..." "step2_ords_download_seconds" "10s"
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
  echo -e "⏱  [Samm 2 valmis (ORDS allalaadimine): ${YELLOW}$ORDS_DL_TIME${NC}]"
fi

# ----------------------------------------------------------------------------
# SAMM 3: APEX tarkvarapaketi allalaadimine ja lahtipakkimine (APEX Download)
# ----------------------------------------------------------------------------
APEX_DL_START=$(date +%s)
print_header "3" "Checking / Downloading APEX Software Packages..." "step3_apex_download_unzip_seconds" "30s"

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
  APEX_DL_TIME="vahele jäetud"
fi
echo -e "⏱  [Samm 3 valmis (APEX allalaadimine & lahtipakkimine): ${YELLOW}$APEX_DL_TIME${NC}]"

# ----------------------------------------------------------------------------
# SAMM 4: Konteinerite käivitamine ja andmebaaside tervisekontroll (Healthcheck)
# ----------------------------------------------------------------------------
STEP4_START=$(date +%s)
if [ "$IS_LOCAL" = "true" ]; then
  mkdir -p "$WORKSPACE_DIR/config/tns_admin"
  print_header "4" "Käivitan konteinerid ja ootan andmebaaside valmisolekut (Healthcheck)..." "step4_container_startup_seconds" "45s"

  if [ "${RESTORE_FROM_SNAPSHOT:-false}" = "true" ] && [ -f "$SCRIPT_DIR/snapshots/restore-golden-snapshots.sh" ]; then
    echo -e "${CYAN}📸 [TASK-018]: Taastan andmemahud eelnevalt salvestatud Golden Snapshotist...${NC}"
    "$SCRIPT_DIR/snapshots/restore-golden-snapshots.sh" || true
  fi

  LOCAL_COMPOSE_ARGS=("${COMPOSE_ARGS[@]}")
  load_web_ide_profile >/dev/null 2>&1 || true
  if [ "$SKIP_WEB_IDE" = "false" ] && [ "${WEB_IDE_ENABLED:-false}" = "true" ]; then
    LOCAL_COMPOSE_ARGS+=(--profile web-ide)
  fi

  podman-compose "${LOCAL_COMPOSE_ARGS[@]}" up -d >> "$LOG_FILE" 2>&1

  # Kasutame adaptiivset ja iseparanevat tervisekontrolli moodulit
  if [ -x "$SCRIPT_DIR/internal/wait-db-healthy.sh" ]; then
    "$SCRIPT_DIR/internal/wait-db-healthy.sh"
  fi

  STEP4_CONTAINER_SECS=$(( $(date +%s) - STEP4_START ))
  STEP4_TIME=$(format_duration $STEP4_CONTAINER_SECS)
  echo -e "⏱  [Samm 4 valmis (Konteinerite käivitamine & DB Healthcheck): ${YELLOW}$STEP4_TIME${NC}]"
else
  STEP4_CONTAINER_SECS=0
  STEP4_TIME="vahele jäetud"
fi

# ----------------------------------------------------------------------------
# SAMM 4.5: Oracle Wallet ja TNS algseadistamine (SEPS)
# ----------------------------------------------------------------------------
STEP4_5_SECS=0
if [ "$IS_LOCAL" = "true" ]; then
  print_header "4.5" "Oracle Walleti ja TNS algseadistamine (SEPS)..." "step4_5_wallet_tns_config_seconds" "10s"
  STEP4_5_START=$(date +%s)
  "$SCRIPT_DIR/internal/create-wallet.sh"
  STEP4_5_SECS=$(( $(date +%s) - STEP4_5_START ))
  STEP4_5_TIME=$(format_duration $STEP4_5_SECS)
  echo -e "⏱  [Samm 4.5 valmis (Wallet & TNS seadistus): ${YELLOW}$STEP4_5_TIME${NC}]"
fi

# ----------------------------------------------------------------------------
# SAMM 5: ORDS teenuse käivitamise ja reageerimise kontroll
# ----------------------------------------------------------------------------
STEP5_START=$(date +%s)
if [ "$SKIP_ORDS" = "true" ] || [ "$IS_LOCAL" = "false" ]; then
  STEP5_ORDS_SECS=0
  STEP5_TIME="vahele jäetud"
else
  ords_h_port="${ORDS_HTTP_PORT:-${PROFILE_ORDS_HTTP_PORT:-8088}}"
  print_header "5" "ORDS teenuse liidese valmisolek (Port: $ords_h_port)..." "step5_ords_service_seconds" "1s"
  STEP5_ORDS_SECS=$(( $(date +%s) - STEP5_START ))
  STEP5_TIME=$(format_duration $STEP5_ORDS_SECS)
  echo -e "⏱  [Samm 5 valmis (ORDS teenus): ${YELLOW}$STEP5_TIME${NC}]"
fi

# ----------------------------------------------------------------------------
# SAMM 6: APEX Mootori ja Patchi automaatne paigaldamine
# ----------------------------------------------------------------------------
print_header "6" "Käivitan APEX mootori ja patchide paigaldamise skriptid..." "step7_apex_engine_install_seconds" "6m"
ACTIVE_INST_LIST=$(get_active_db_instances 2>/dev/null || echo "")
for inst in $ACTIVE_INST_LIST; do
  c_name=$(echo "$inst" | cut -d'|' -f1)
  prof=$(echo "$inst" | cut -d'|' -f2)
  [ -z "$c_name" ] && continue
  (
    load_db_profile "$prof" >/dev/null 2>&1 || true
    if [ "${IS_ADB:-false}" = "true" ] || [ "${PROFILE_APEX_INSTALL_REQUIRED:-true}" = "false" ] || [ "${PROFILE_APEX_PREINSTALLED:-false}" = "true" ]; then
      echo -e "   ℹ️  Andmebaas ${c_name} (Profiil: ${prof}) on Autonomous Database (ADB). APEX on eelinstalleeritud (Pre-installed) ja mootori paigaldamist ei teostata."
    elif [ "${PROFILE_APEX_ENABLED:-true}" = "false" ] || [ "${PROFILE_APEX_VERSION:-NONE}" = "NONE" ]; then
      echo -e "   ℹ️  Andmebaasil ${c_name} ei ole APEX paigaldus aktiivne."
    else
      echo -e "   🚀 [${c_name}]: Käivitan APEX ${PROFILE_APEX_VERSION:-26.1} paigalduse..."
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
print_header "7" "Käivitan andmebaasi skeemi installeerimise..." "step5_5_liquibase_migration_seconds" "15s"
STEP5_5_LOG="$LOG_DIR/liquibase_migration_${TIMESTAMP}.log"

get_active_db_instances 2>/dev/null | while IFS='|' read -r c_name prof env_key; do
  [ -z "$c_name" ] && continue
  ( "$SCRIPT_DIR/internal/init-db-instance.sh" "$prof" "$c_name" >> "$STEP5_5_LOG" 2>&1 ) &
done
wait

STEP5_5_SECS=$(( $(date +%s) - STEP5_5_START ))
STEP5_5_TIME=$(format_duration $STEP5_5_SECS)
echo -e "⏱  [Samm 7 valmis (Skeemide initsialiseerimine): ${GREEN}$STEP5_5_TIME${NC}]"

if [ "$SKIP_ORDS" = "false" ] && podman container exists app-ords 2>/dev/null; then
  echo -e "🔄 Värskendan ORDS teenuse ühendusbasseinid (app-ords taaskäivitus)..."
  podman restart app-ords >/dev/null 2>&1 || true
fi

# ----------------------------------------------------------------------------
# SAMM 8: APEX rakenduste paigaldamine (Deploy Packaged APEX Applications)
# ----------------------------------------------------------------------------
STEP8_START=$(date +%s)
print_header "8" "APEX rakenduste paigaldamine (Deploy Packaged APEX Apps)..." "step10_deploy_apex_apps_seconds" "10s"

if [ "$SKIP_MONITOR_APP" = "true" ] || [ "${PROFILE_APEX_ENABLED:-true}" = "false" ]; then
  STEP8_DEPLOY_SECS=0
  STEP8_DEPLOY_TIME="vahele jäetud"
else
  STEP8_LOG="$LOG_DIR/deploy_apps_${TIMESTAMP}.log"
  mkdir -p "$WORKSPACE_DIR/binaries/apex_apps"
  set +e
  "$SCRIPT_DIR/internal/deploy-apex-apps.sh" > "$STEP8_LOG" 2>&1
  set -e
  STEP8_DEPLOY_SECS=$(( $(date +%s) - STEP8_START ))
  STEP8_DEPLOY_TIME=$(format_duration $STEP8_DEPLOY_SECS)
  echo -e "⏱  [Samm 8 valmis (APEX rakenduste paigaldus): ${YELLOW}$STEP8_DEPLOY_TIME${NC}]"
fi

# ----------------------------------------------------------------------------
# SAMM 9: Oracle Analytics Publisher paigaldamine ja initsialiseerimine
# ----------------------------------------------------------------------------
PUB_INSTALL_SECS=0
if [ "$SKIP_PUBLISHER" = "false" ] && { [ "$ANY_PUB_ENABLED" = "true" ] || [ "${PUBLISHER_ENABLED:-false}" = "true" ]; }; then
  PUB_START=$(date '+%s')
  echo -e "\n${YELLOW}🚀 Paigaldan ja initsialiseerin Oracle Analytics Publisheri...${NC}"
  if [ -x "$SCRIPT_DIR/internal/install-publisher.sh" ]; then
    "$SCRIPT_DIR/internal/install-publisher.sh" || true
  fi
  PUB_INSTALL_SECS=$(( $(date '+%s') - PUB_START ))
  echo -e "⏱  [Samm 9 valmis (Analytics Publisher paigaldus & käivitus): ${YELLOW}$(format_duration ${PUB_INSTALL_SECS})${NC}]"
fi

# ----------------------------------------------------------------------------
# SAMM 10: Hetktõmmise (Golden Snapshot) loomine
# ----------------------------------------------------------------------------
STEP9_SECS=0
if [ "$FORCE" != "true" ] && [ "${IS_TEST_MODE:-false}" != "true" ]; then
  print_header "10" "Andmebaasi ja teenuste hetktõmmise loomine (Golden Snapshot)..." "snapshot_duration_seconds" "2m"
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
echo -e "${GREEN}🎉 KESKKOND ON EDUKALT VALMIS JA KONTROLLITUD!${NC}"
echo -e "${CYAN}==================================================================${NC}"

echo -e "\n${CYAN}🌐 VEEBIRAKENDUSTE LIGIPÄÄSUD (Web Services & Portals):${NC}"
printf "┌─────────────────────────────────┬────────────────────────────────────────────┬─────────────────────────────┐\n"
printf "│ %-31s │ %-42s │ %-27s │\n" "Rakendus / Teenus" "Sihtkoha URL" "Autentimise / Kasutaja Info"
printf "├─────────────────────────────────┼────────────────────────────────────────────┼─────────────────────────────┤\n"

if [ "${PROFILE_ORDS_ENABLED:-true}" = "true" ] && [ "$SKIP_ORDS" != "true" ]; then
  for inst in $(get_active_db_instances 2>/dev/null); do
    c_name=$(echo "$inst" | cut -d'|' -f1)
    p_name=$(echo "$inst" | cut -d'|' -f2)
    pfile="$WORKSPACE_DIR/config/profiles/databases/${p_name}.yaml"
    [ ! -f "$pfile" ] && pfile="$WORKSPACE_DIR/config/profiles/${p_name}.yaml"
    pool_name=$(echo "$c_name" | sed 's/^db-//' | tr '-' '_')
    apex_en="false"
    if [ -f "$pfile" ]; then
      apex_en=$(grep -A 8 "apex:" "$pfile" 2>/dev/null | grep -E '^[[:space:]]*enabled:' | head -n 1 | sed -E 's/.*:[[:space:]]*"?([^"]+)"?/\1/' | tr -d '\r\n')
    fi
    upper_pool=$(echo "$pool_name" | tr '[:lower:]' '[:upper:]')
    if [ "$apex_en" = "true" ]; then
      printf "│ %-31s │ %-42s │ %-27s │\n" "🛠 APEX Builder (${upper_pool})" "https://localhost:${ACTIVE_SSL_PORT}/ords/${pool_name}/r/apex/workspace-sign-in/oracle-apex-sign-in" "Workspace: ${APEX_WORKSPACE_NAME:-DEV_WS} / DEV"
      printf "│ %-31s │ %-42s │ %-27s │\n" "⚙️ APEX Instance Admin (${upper_pool})" "https://localhost:${ACTIVE_SSL_PORT}/ords/${pool_name}/apex_admin" "Workspace: INTERNAL / ADMIN"
      printf "│ %-31s │ %-42s │ %-27s │\n" "📊 Database Actions (${upper_pool})" "https://localhost:${ACTIVE_SSL_PORT}/ords/${pool_name}/_/landing" "DB Skeem / ADMIN"
    else
      printf "│ %-31s │ %-42s │ %-27s │\n" "📊 Database Actions (${upper_pool})" "https://localhost:${ACTIVE_SSL_PORT}/ords/${pool_name}/_/landing" "DB Skeem / ADMIN"
    fi
  done
fi

if [ "${PROFILE_PUBLISHER_ENABLED:-false}" = "true" ] || [ "$SKIP_PUBLISHER" != "true" ]; then
  printf "│ %-31s │ %-42s │ %-27s │\n" "📑 Analytics Publisher" "http://localhost:${ACTIVE_PUB_PORT}/xmlpserver" "User: Administrator / Dev"
fi

if podman ps --format "{{.Names}}" 2>/dev/null | grep -q "web-ide"; then
  printf "│ %-31s │ %-42s │ %-27s │\n" "💻 Web IDE (VS Code)" "http://localhost:${ACTIVE_WEB_IDE_PORT}/" "Zero-Install Workspace"
fi
printf "└─────────────────────────────────┴────────────────────────────────────────────┴─────────────────────────────┘\n"

echo -e "\n${CYAN}📂 VS CODE ORACLE SQL DEVELOPER ÜHENDUSTE HIERARHIA (Connection Tree):${NC}"
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
    echo -e "   │  ├── 🟣 ${BOLD}3. APEX_PROXY_SCHEMA (${c_name})${NC} (Skeem   -> sql /@DB_${c_short}_SCHEMA)"
    echo -e "   │  ├── 🟢 ${BOLD}4. TEST_DEV (${c_name})${NC}          (Arendaja-> sql /@DB_${c_short}_DEV)"
    echo -e "   │  └── 🟡 ${BOLD}5. TEST_VIEWER (${c_name})${NC}       (Vaataja -> sql /@DB_${c_short}_VIEWER)"
  elif [ "$c_name" = "db-publisher" ]; then
    echo -e "   │  └── 🟡 ${BOLD}3. PUBLISHER_READER (${c_name})${NC}  (Vaataja -> sql /@DB_${c_short}_READER)"
  else
    echo -e "   │  ├── 🟢 ${BOLD}3. TEST_DEV (${c_name})${NC}          (Arendaja-> sql /@DB_${c_short}_DEV)"
    echo -e "   │  └── 🟡 ${BOLD}4. TEST_VIEWER (${c_name})${NC}       (Vaataja -> sql /@DB_${c_short}_VIEWER)"
  fi
done

echo -e "\n${CYAN}🔑 PAROOLIDE PÄRIMINE SEPS WALLETIST (Credentials Helper):${NC}"
echo -e "   Arendaja või administraator saab vajalikud paroolid turvaliselt kätte käsuga:"
echo -e "   👉 ${YELLOW}./scripts/get-password.sh <ALIAS>${NC}\n"
echo -e "   Peamised veebi ja süsteemi aliased:"
for inst in $(get_active_db_instances 2>/dev/null); do
  c_name=$(echo "$inst" | cut -d'|' -f1)
  c_short=$(echo "$c_name" | sed -E 's/^db[-_]//' | tr '-' '_' | tr '[:lower:]' '[:upper:]')
  echo -e "   • ${BOLD}${c_name}${NC}:"
  echo -e "     - APEX Admin (INTERNAL): ./scripts/get-password.sh DB_${c_short}_APEX_ADMIN"
  echo -e "     - DEV arendaja parool:   ./scripts/get-password.sh DB_${c_short}_DEV"
  echo -e "     - SYS DBA parool:        ./scripts/get-password.sh DB_${c_short}_SYS"
done

echo -e "\n${CYAN}💾 KÄSUREA KIIRLIGIPÄÄSUD (SQLcl SEPS Wallet Aliases):${NC}"
for inst in $(get_active_db_instances 2>/dev/null); do
  c_name=$(echo "$inst" | cut -d'|' -f1)
  c_short=$(echo "$c_name" | sed -E 's/^db[-_]//' | tr '-' '_' | tr '[:lower:]' '[:upper:]')
  echo -e "   • sql /@DB_${c_short}_DEV"
  echo -e "   • sql /@DB_${c_short}_SYS as sysdba"
done

echo ""
echo -e "${CYAN}==================================================================${NC}"
echo -e "⏱   KOGU PAIGALDUSE KULUNUD AEG: ${GREEN}$TOTAL_MASTER_TIME${NC} (${TOTAL_MASTER_SECS}s)"
echo -e "📝  Täielik paigalduslogi: [Logi](file://$LOG_FILE)"
echo -e "📊  Git mõõdikud: [Mõõdikud](file://$WORKSPACE_DIR/metrics/setup_benchmarks.json)"
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
