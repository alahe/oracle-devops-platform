#!/usr/bin/env bash
# ============================================================================
# Oracle Free DB in Prod — Profile-Driven Selective & Full Reset Script
# Stops and resets selected components, profiles, or the entire environment.
# Usage: ./scripts/reset-all.sh [all|<container_name>] [--profile <profile_name>] [--force] [--system]
# ============================================================================

set -e

# Silence podman compose warning logs about external providers
export PODMAN_COMPOSE_WARNING_LOGS=false

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_NAME="oracle-devops-platform"
COMPOSE_FILE="$WORKSPACE_DIR/podman-compose.yml"

# Source shared common library and profile engine
if [ -f "$SCRIPT_DIR/internal/common.sh" ]; then
  source "$SCRIPT_DIR/internal/common.sh"
fi

# Load environment variables if available
if [ -f "$WORKSPACE_DIR/.env" ]; then
  set -a
  source "$WORKSPACE_DIR/.env"
  set +a
fi

# Source profile loader functions
if [ -f "$SCRIPT_DIR/internal/load-profile.sh" ]; then
  source "$SCRIPT_DIR/internal/load-profile.sh"
fi

# Arguments: by default ALL components are removed (COMPONENT="all")
COMPONENT="all"
TARGET_PROFILE=""
FORCE=false
SYSTEM_RESET=false
CLEAN_LOGS=false
CLEAN_CERTS=false

while [[ $# -gt 0 ]]; do
  case $1 in
    -l=*|--lang=*|-language=*|--language=*)
      export CLI_LANG="${1#*=}"
      if declare -f resolve_cli_lang >/dev/null 2>&1; then
        export ACTIVE_CLI_LANG="$(resolve_cli_lang)"
      fi
      shift
      ;;
    -l|--lang|-language|--language)
      export CLI_LANG="$2"
      if declare -f resolve_cli_lang >/dev/null 2>&1; then
        export ACTIVE_CLI_LANG="$(resolve_cli_lang)"
      fi
      shift 2
      ;;
    -y|--force|--yes|-y*|--y*|-Y|--YES)
      FORCE=true
      shift
      ;;
    --logs)
      CLEAN_LOGS=true
      shift
      ;;
    --clean-certs|--certs)
      CLEAN_CERTS=true
      shift
      ;;
    --system)
      SYSTEM_RESET=true
      shift
      ;;
    --profile)
      TARGET_PROFILE="$2"
      shift 2
      ;;
    *)
      COMPONENT="$1"
      shift
      ;;
  esac
done

if [ "$SYSTEM_RESET" = "true" ]; then
  echo "=================================================================="
  echo "$(msg_str "RESET_SYSTEM_WARN_HEADER")"
  echo "$(msg_str "RESET_SYSTEM_WARN_BODY")"
  echo "=================================================================="
  if [ "$FORCE" = "false" ]; then
    read -p "$(msg_str "RESET_SYSTEM_CONFIRM_PROMPT")" CONFIRM
    if [ "$CONFIRM" != "YES" ] && [ "$CONFIRM" != "JAH" ]; then
      msg_print "RESET_SYSTEM_CANCELLED"
      exit 0
    fi
  fi
  
  msg_print "RESET_STOPPING_PODMAN_VM"
  podman machine stop || true
  
  msg_print "RESET_STARTING_PODMAN_VM"
  podman machine start || true
  
  podman system prune -a -f --volumes
  
  msg_print "RESET_COMPLETED_MSG" "0s"
  exit 0
fi

# Load target profile specification dynamically
if [ -z "$TARGET_PROFILE" ]; then
  FIRST_PROF=$(get_active_db_instances 2>/dev/null | head -n 1 | cut -d'|' -f2)
  TARGET_PROFILE="${FIRST_PROF:-${MAIN_DB_PROFILE:-${ORDS_PROFILE:-${WEB_IDE_PROFILE:-}}}}"
fi

if [ -n "$TARGET_PROFILE" ] && declare -f load_db_profile >/dev/null 2>&1; then
  load_db_profile "$TARGET_PROFILE" >/dev/null 2>&1 || true
fi

SKIP_PUBLISHER=false
if [ -z "$PUBLISHER_DB_HOST" ]; then
  SKIP_PUBLISHER=true
fi

APEX_HOST="${APEX_DB_HOST:-localhost}"
APEX_PORT="${PROFILE_DB_PORT:-${APEX_DB_PORT:-1532}}"
APEX_SERVICE="${PROFILE_DEFAULT_SERVICE:-${APEX_DB_SERVICE:-FREEPDB1}}"

PUB_HOST="${PUBLISHER_DB_HOST:-localhost}"
PUB_PORT="${PUBLISHER_DB_PORT:-1531}"
PUB_SERVICE="${PUBLISHER_DB_SERVICE:-FREEPDB1}"
# Active Blueprint and Profile resolution
ACTIVE_BP_NAME=$(grep -E "^# Blueprint [0-9]+" "$WORKSPACE_DIR/.env" 2>/dev/null | head -n 1 | sed -E 's/^#[[:space:]]*//' || echo "")
FIRST_PROF=$(get_active_db_instances 2>/dev/null | head -n 1 | cut -d'|' -f2)
RESOLVED_PROFILE="${FIRST_PROF:-${ORDS_PROFILE:-${WEB_IDE_PROFILE:-$TARGET_PROFILE}}}"

# Query live Podman state
LIVE_CONTAINERS=($(podman ps -a --format "{{.Names}}" 2>/dev/null || echo ""))
LIVE_VOLUMES=($(podman volume ls --format "{{.Name}}" 2>/dev/null || echo ""))

echo -e "${CYAN}==================================================================${NC}"
echo -e "${RED}$(msg_str "RESET_WARN_TITLE")${NC}"
echo -e "   $(msg_str "LABEL_PROJECT"):     ${CYAN}$PROJECT_NAME${NC}"
if [ "$COMPONENT" = "all" ]; then
  echo -e "   $(msg_str "LABEL_TARGET"):    ${YELLOW}$(msg_str "RESET_TARGET_ALL")${NC}"
else
  echo -e "   $(msg_str "LABEL_COMPONENT"):   ${YELLOW}$COMPONENT${NC}"
fi
[ -n "$ACTIVE_BP_NAME" ] && echo -e "   $(msg_str "LABEL_BLUEPRINT")     ${CYAN}${ACTIVE_BP_NAME}${NC}"
echo -e "   $(msg_str "LABEL_PROFILE"):     ${CYAN}${PROFILE_NAME:-$RESOLVED_PROFILE}${NC}"
echo -e "   📦 $(msg_str "LABEL_LIVE_PODMAN") ${YELLOW}$(msg_str "LABEL_CONTAINERS_COUNT" "${#LIVE_CONTAINERS[@]}")${NC}${LIVE_CONTAINERS:+ (${LIVE_CONTAINERS[*]})}, ${YELLOW}$(msg_str "LABEL_VOLUMES_COUNT" "${#LIVE_VOLUMES[@]}")${NC}"
echo -e "${CYAN}==================================================================${NC}"

if [ "${#LIVE_CONTAINERS[@]}" -eq 0 ] && [ "${#LIVE_VOLUMES[@]}" -eq 0 ]; then
  echo -e "$(msg_str "RESET_PODMAN_ALREADY_CLEAN")"
  echo -e "$(msg_str "RESET_PODMAN_ALREADY_CLEAN_HINT")"
elif [ "$COMPONENT" = "all" ]; then
  get_active_db_instances 2>/dev/null | while IFS='|' read -r container prof env_key; do
    [ -z "$container" ] && continue
    (
      load_db_profile "$prof" >/dev/null 2>&1 || true
      p_port="${PROFILE_DB_PORT:-1532}"
      p_service="${PROFILE_DEFAULT_SERVICE:-FREEPDB1}"
      c_vol=$(echo "$container" | sed 's/^db-//' | tr '-' '_')
      echo -e "   - ${CYAN}${container}${NC} ($(msg_str "LABEL_PROFILE"): ${YELLOW}${prof}${NC})"
      echo -e "     ├─ $(msg_str "LABEL_DATABASE"): ${CYAN}localhost:${p_port}/${p_service}${NC}"
      echo -e "     └─ $(msg_str "LABEL_VOLUME"): ${CYAN}${PROJECT_NAME}_${c_vol}_oradata${NC}"
    )
  done
  load_web_ide_profile >/dev/null 2>&1 || true
  if [ "${WEB_IDE_ENABLED:-false}" = "true" ]; then
    echo -e "   - ${CYAN}${WEB_IDE_CONTAINER_NAME:-web-ide-dev}${NC} (Web IDE $(msg_str "LABEL_PROFILE"): ${YELLOW}${WEB_IDE_PROFILE:-web-ide-standard}${NC})"
    echo -e "     └─ $(msg_str "LABEL_VOLUME"): ${CYAN}${PROJECT_NAME}_web_ide_data${NC}"
  fi
  echo -e "   - $(msg_str "LABEL_NETWORK"): ${CYAN}${PROJECT_NAME}_default${NC}"
else
  c_vol=$(echo "$COMPONENT" | sed 's/^db-//' | tr '-' '_')
  echo -e "   - $(msg_str "LABEL_CONTAINER"): ${CYAN}${COMPONENT}${NC}"
  echo -e "   - $(msg_str "LABEL_VOLUME"): ${CYAN}${PROJECT_NAME}_${c_vol}_oradata${NC}"
fi
echo -e "${CYAN}==================================================================${NC}"

if [ "$FORCE" = "false" ]; then
  read -p "$(msg_str "PROMPT_CONFIRM_CONTINUE")" CONFIRM
  if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo -e "${RED}$(msg_str "RESET_CANCELLED_BY_USER")${NC}"
    exit 0
  fi
  if [ "$CLEAN_LOGS" = "false" ]; then
    read -p "$(msg_str "PROMPT_CONFIRM_CLEAN_LOGS")" LOG_CONFIRM
    if [[ "$LOG_CONFIRM" =~ ^[Yy]$ ]]; then
      CLEAN_LOGS=true
    fi
  fi
fi

# Configure file tee-logging
LOG_DIR="$SCRIPT_DIR/../install_logs"
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$LOG_DIR/env_reset_${TIMESTAMP}.log"
ln -sf "$LOG_FILE" "$LOG_DIR/env_reset_latest.log" 2>/dev/null || true
exec > >(tee -a "$LOG_FILE") 2>&1

START_RESET=$(date +%s)

get_reset_stats() {
  local default_est="$1"
  local values=()
  local m_dir="$SCRIPT_DIR/../metrics"
  if [ -d "$m_dir" ]; then
    for f in "$m_dir"/reset_benchmarks_*.json; do
      if [ -f "$f" ]; then
        local val=$(grep -m1 '"reset_duration_seconds":' "$f" | awk -F: '{print $2}' | tr -d ' ,"\r\n' || echo "")
        if [[ "$val" =~ ^[0-9]+$ ]]; then
          values+=($val)
        fi
      fi
    done
  fi
  local count=${#values[@]}
  if [ $count -eq 0 ]; then
    echo "estimated ~${default_est}"
    return 0
  fi
  local sum=0
  local min=${values[0]}
  local max=${values[0]}
  for val in "${values[@]}"; do
    sum=$((sum + val))
    if [ $val -lt $min ]; then
      min=$val
    fi
    if [ $val -gt $max ]; then
      max=$val
    fi
  done
  local avg=$((sum / count))
  msg_str "BENCHMARK_AVG" "${avg}s"
}

echo -e "${CYAN}==================================================================${NC}"
echo -e "📝 $(msg_str "RESET_LOG_LABEL") ${CYAN}$LOG_FILE${NC}"
echo -e "📊 $(msg_str "BENCHMARK_LABEL") ${YELLOW}$(get_reset_stats "15s")${NC}"
echo -e "${CYAN}==================================================================${NC}"

# Helper function to remove a container
cleanup_container() {
  local container=$1
  if podman container exists "$container" 2>/dev/null; then
    echo -e "$(msg_str "RESET_CONTAINER_STOP" "$container")"
    podman stop "$container" 2>/dev/null || true
    podman rm -f "$container" 2>/dev/null || true
  else
    echo -e "$(msg_str "RESET_CONTAINER_NOT_EXIST" "$container")"
  fi
}

# Helper function to remove volume
cleanup_volume() {
  local volume=$1
  if podman volume exists "$volume" 2>/dev/null; then
    echo -e "$(msg_str "RESET_VOLUME_REMOVING" "$volume")"
    podman volume rm "$volume" 2>/dev/null || true
  else
    echo -e "$(msg_str "RESET_VOLUME_NOT_EXIST" "$volume")"
  fi
}

case $COMPONENT in
  all)
    echo "$(msg_str "RESET_PERFORMING")"
    COMPOSE_ARGS=(-f "$COMPOSE_FILE")
    OVERRIDE_FILE="$SCRIPT_DIR/../podman-compose.override.yml"
    [ -f "$OVERRIDE_FILE" ] && COMPOSE_ARGS+=(-f "$OVERRIDE_FILE")
    podman-compose "${COMPOSE_ARGS[@]}" --profile dev-ords down -v >> "$LOG_FILE" 2>&1 || true
    
    # 1. Dynamically stop and remove all active containers and volumes defined in .env
    get_active_db_instances 2>/dev/null | while IFS='|' read -r container prof env_key; do
      [ -z "$container" ] && continue
      cleanup_container "$container"
      cleanup_container "oracle-$container"
      cleanup_container "oracle-ords-$container"
      c_vol=$(echo "$container" | sed 's/^db-//' | tr '-' '_')
      cleanup_volume "${PROJECT_NAME}_${c_vol}_oradata"
      cleanup_volume "${PROJECT_NAME}_${c_vol}_data"
      rm -rf "$SCRIPT_DIR/../config/ords/${container}" "$SCRIPT_DIR/../config/ords/${c_vol}"
    done
    rm -rf "$SCRIPT_DIR/../config/ords"/* 2>/dev/null || true

    cleanup_container "app-forms"
    cleanup_container "app-publisher"
    cleanup_container "app-ords"
    cleanup_container "web-ide-dev"
    cleanup_container "ords-standalone-emulator"
    cleanup_container "ords-standalone-dev"
    cleanup_container "oracle-ords-standalone-test"
    cleanup_volume "${PROJECT_NAME}_web_ide_data"

    # Ensure all project containers are stopped and pruned across all blueprint configurations
    if command -v podman &>/dev/null; then
      for any_c in $(podman ps -a --format '{{.Names}}' 2>/dev/null | grep -E '^(db-|app-|web-ide|oracle-)' || true); do
        cleanup_container "$any_c"
      done
    fi


    # 2. Scan .env for all container definitions and verify existence in Podman
    raw_env_containers=()
    if [ -f "$SCRIPT_DIR/../.env" ]; then
      while IFS= read -r env_line || [ -n "$env_line" ]; do
        env_line=$(echo "$env_line" | sed 's/#.*//' | xargs)
        [ -z "$env_line" ] && continue
        if [[ "$env_line" =~ ^([A-Za-z0-9_.-]+)=([A-Za-z0-9_.-]+) ]]; then
          k_raw="${BASH_REMATCH[1]}"
          v_raw="${BASH_REMATCH[2]}"
          k_slug=$(echo "$k_raw" | tr '[:upper:]' '[:lower:]' | tr '_' '-')
          for candidate in "$k_raw" "$k_slug" "$v_raw"; do
            if podman container exists "$candidate" 2>/dev/null; then
              raw_env_containers+=("$candidate")
            fi
          done
        fi
      done < "$SCRIPT_DIR/../.env"
    fi

    # 3. Discover ALL running or stopped containers related to this project directly from Podman daemon
    live_containers=$(podman ps -a --filter "label=com.docker.compose.project=$PROJECT_NAME" --format "{{.Names}}" 2>/dev/null || true)
    profile_containers=$(get_all_profile_container_names 2>/dev/null || true)
    prefix_containers=$(podman ps -a --format "{{.Names}}" 2>/dev/null | grep -E "^(db-|oracle-|ords-|web-ide-|pub-db)" || true)
    
    # Merge all 4 sources into a unique list
    all_target_containers=$(printf "%s\n" "${raw_env_containers[@]}" "${live_containers}" "${profile_containers}" "${prefix_containers}" | sort -u)

    for c in $all_target_containers; do
      [ -n "$c" ] && cleanup_container "$c"
    done

    # 3. Discover ALL volumes related to this project directly from Podman daemon
    live_vols=$(podman volume ls --filter "label=com.docker.compose.project=$PROJECT_NAME" --format "{{.Name}}" 2>/dev/null || true)
    if [ -z "$live_vols" ]; then
      folder_basename=$(basename "$(cd "$SCRIPT_DIR/.." && pwd)")
      live_vols=$(podman volume ls --format "{{.Name}}" 2>/dev/null | grep -E "^(${PROJECT_NAME}|${folder_basename}|apex_images)" || true)
    fi
    for v in $live_vols; do
      [ -n "$v" ] && cleanup_volume "$v"
    done
    # Remove Podman Pods
    echo "$(msg_str "RESET_PODS_REMOVING")"
    folder_basename=$(basename "$(cd "$SCRIPT_DIR/.." && pwd)")
    for pod in $(podman pod ls --format "{{.Name}}" 2>/dev/null | grep -E "${PROJECT_NAME}|${folder_basename}|pod_" || true); do
      if [ -n "$pod" ]; then
        echo "   Stopping and removing pod: $pod"
        podman pod stop "$pod" 2>/dev/null || true
        podman pod rm -f "$pod" 2>/dev/null || true
      fi
    done
    podman pod prune -f 2>/dev/null || true

    # Remove container network
    NETWORK="${PROJECT_NAME}_default"
    if podman network exists "$NETWORK" 2>/dev/null; then
      podman network rm "$NETWORK" >/dev/null 2>&1 || true
    fi

    # Prune dangling containers, intermediate layers, and build cache (frees disk space)
    echo "$(msg_str "RESET_PRUNING_DANGLING")"
    podman system prune -f >> "$LOG_FILE" 2>&1 || true
    
    # Clean extracted temporary patch directories
    for pdir in "$SCRIPT_DIR/../patches" "$SCRIPT_DIR/../binaries"/*/patches; do
      if [ -d "$pdir" ]; then
        find "$pdir" -type d -name "unzipped_*" -exec rm -rf {} + 2>/dev/null || true
      fi
    done

    # Securely purge Podman secrets at daemon level
    echo "$(msg_str "RESET_SECRETS_REMOVING")"
    for sec in $(get_required_secret_names 2>/dev/null || echo "publisher_db_sys_password apex_db_sys_password apex_schema_password ords_listener_password apex_admin_password test_dev_password"); do
      podman secret rm "$sec" >> "$LOG_FILE" 2>&1 || true
    done
    
    # Clean host files and temporary installation artifacts
    echo "$(msg_str "RESET_WALLET_REMOVING")"
    rm -rf "$SCRIPT_DIR/../config/tns_admin"
    rm -rf "$SCRIPT_DIR/../config/secrets"
    rm -f "$OVERRIDE_FILE"
    rm -f "$SCRIPT_DIR/../.active_blueprint"
    rm -f "$SCRIPT_DIR/../.env"
    rm -rf "$SCRIPT_DIR/../db-install"

    # Clean temporary APEX installation directory /tmp/apex_install from all running containers
    for c in $(podman ps --format '{{.Names}}' 2>/dev/null | grep -E '^db-|^oracle-db-' || echo ""); do
      if [ -n "$c" ]; then
        podman exec -u root "$c" rm -rf /tmp/apex_install /tmp/apex-latest.zip >/dev/null 2>&1 || true
      fi
    done

    # Clean VS Code registered database connections and configurations
    echo "$(msg_str "RESET_VSCODE_REMOVING")"
    folder_name="${VSCODE_FOLDER_NAME:-${DB_CONN_NAME:-${CONTAINER_NAME:-db-dev-full}}}"
    VSCODE_SQLCL=$(find "$HOME/.vscode/extensions" -name "sql" -path "*/oracle.sql-developer-*/dbtools/sqlcl/bin/sql" 2>/dev/null | sort -rV | head -n 1)
    if [ -n "$VSCODE_SQLCL" ] && [ -x "$VSCODE_SQLCL" ]; then
      "$VSCODE_SQLCL" /nolog >/dev/null 2>&1 <<EOF || true
connmgr delete -folder /${folder_name} -force
EXIT
EOF
    fi

    # Clean connection JSON files and orphaned folders
    DBTOOLS_CONNS_DIR="$HOME/.dbtools/connections"
    FOLDERS_FILE="$HOME/.dbtools/connection_folders/folders.json"
    if [ -d "$DBTOOLS_CONNS_DIR" ]; then
      for prop in "$DBTOOLS_CONNS_DIR"/*/dbtools.properties; do
        [ -f "$prop" ] || continue
        if grep -iq "folderName=/${folder_name}" "$prop" 2>/dev/null || grep -iq "FREEPDB1" "$prop" 2>/dev/null; then
          conn_dir="$(dirname "$prop")"
          rm -rf "$conn_dir"
        fi
      done
    fi

    if [ -f "$FOLDERS_FILE" ] && command -v jq &>/dev/null; then
      valid_ids=($(find "$DBTOOLS_CONNS_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2>/dev/null || true))
      VALID_IDS_JSON=$(printf '%s\n' "${valid_ids[@]}" | jq -R . 2>/dev/null | jq -s . 2>/dev/null || echo "[]")
      jq --argjson valid "$VALID_IDS_JSON" '
        .folders = [
          .folders[]? |
          .connections = [ .connections[]? | select(. as $c | $valid | index($c)) ]
        ] |
        .folders = [ .folders[]? | select((.connections | length) > 0) ]
      ' "$FOLDERS_FILE" > "${FOLDERS_FILE}.tmp" 2>/dev/null || true
      [ -f "${FOLDERS_FILE}.tmp" ] && mv "${FOLDERS_FILE}.tmp" "$FOLDERS_FILE" 2>/dev/null || true
      rm -f "${FOLDERS_FILE}.tmp" 2>/dev/null || true
    fi

    for json_path in "$HOME/.sqldev/connections.json" "$HOME/.dbtools/connections.json"; do
      if [ -f "$json_path" ]; then
        rm -f "$json_path" 2>/dev/null || true
      fi
    done
    ;;

  *)
    echo -e "$(msg_str "RESET_CLEANING_COMP" "$COMPONENT")"
    c_vol=$(echo "$COMPONENT" | sed 's/^db-//' | tr '-' '_')
    cleanup_container "$COMPONENT"
    cleanup_container "oracle-$COMPONENT"
    cleanup_container "oracle-ords-$COMPONENT"
    cleanup_volume "${PROJECT_NAME}_${c_vol}_oradata"
    cleanup_volume "${PROJECT_NAME}_${c_vol}_data"
    rm -rf "$SCRIPT_DIR/../config/ords/${COMPONENT}"
    ;;
esac

if [ "$CLEAN_LOGS" = "true" ] && [ -x "$SCRIPT_DIR/clean-logs.sh" ]; then
  echo -e "\n${YELLOW}$(msg_str "RESET_CLEANING_LOGS")${NC}"
  "$SCRIPT_DIR/clean-logs.sh" -y || true
fi

if [ "$CLEAN_CERTS" = "true" ] && [ -x "$SCRIPT_DIR/certs/clean-certs.sh" ]; then
  "$SCRIPT_DIR/certs/clean-certs.sh" -y || true
fi

# Verify reset results
echo ""
echo "$(msg_str "RESET_CHECKING")"
CLEAN=true

if [ "$COMPONENT" = "all" ]; then
  rem_containers=$(podman ps -a --filter "label=com.docker.compose.project=$PROJECT_NAME" --format "{{.Names}}" 2>/dev/null || true)
  if [ -n "$rem_containers" ]; then
    for c in $rem_containers; do
      echo -e "${RED}$(msg_str "RESET_WARN_CONTAINER_REMAINS" "$c")${NC}"
      CLEAN=false
    done
  fi

  rem_vols=$(podman volume ls --filter "label=com.docker.compose.project=$PROJECT_NAME" --format "{{.Name}}" 2>/dev/null || true)
  if [ -n "$rem_vols" ]; then
    for v in $rem_vols; do
      echo -e "${RED}$(msg_str "RESET_WARN_VOLUME_REMAINS" "$v")${NC}"
      CLEAN=false
    done
  fi
else
  c_vol="${COMPONENT//-/_}"
  if podman container exists "$COMPONENT" 2>/dev/null; then
    echo -e "${RED}$(msg_str "RESET_WARN_CONTAINER_REMAINS" "$COMPONENT")${NC}"
    CLEAN=false
  fi
  if podman volume exists "${PROJECT_NAME}_${c_vol}_oradata" 2>/dev/null; then
    echo -e "${RED}$(msg_str "RESET_WARN_VOLUME_REMAINS" "${PROJECT_NAME}_${c_vol}_oradata")${NC}"
    CLEAN=false
  fi
fi

echo ""
if [ "$CLEAN" = "true" ]; then
  echo -e "${CYAN}==================================================================${NC}"
  echo -e "${GREEN}$(msg_str "RESET_ALL_CLEAN")${NC}"
  echo -e "${CYAN}==================================================================${NC}"
else
  echo -e "${CYAN}==================================================================${NC}"
  echo -e "${RED}⚠️  WARNING: Some components could not be removed!${NC}"
  echo -e "${CYAN}==================================================================${NC}"
fi

DURATION_RESET=$(( $(date +%s) - START_RESET ))

# Write metrics to metrics/ directory
METRICS_DIR="$SCRIPT_DIR/../metrics"
mkdir -p "$METRICS_DIR"

# Define timestamped JSON file name
JSON_TS_RESET="$METRICS_DIR/reset_benchmarks_${TIMESTAMP}.json"

cat << EOF > "$JSON_TS_RESET"
{
  "last_updated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "component": "$COMPONENT",
  "profile": "${TARGET_PROFILE}",
  "reset_duration_seconds": $DURATION_RESET
}
EOF

# Copy the latest to reset_benchmarks.json
cp "$JSON_TS_RESET" "$METRICS_DIR/reset_benchmarks.json"

# Keep only the last 10 reset benchmark runs in metrics/
(cd "$METRICS_DIR" && ls -t reset_benchmarks_*.json 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null || true)

cat << EOF > "$METRICS_DIR/reset_benchmarks.env"
# APEX & DB Reset Benchmark Metrics (Updated: $(date))
RESET_COMPONENT=$COMPONENT
RESET_PROFILE=$TARGET_PROFILE
RESET_TOTAL_SECS=$DURATION_RESET
EOF

echo ""
echo -e "${YELLOW}$(msg_str "RESET_DURATION" "${DURATION_RESET}s")${NC}"
echo "------------------------------------------------------------------"
echo -e "$(msg_str "LOG_PATH_LABEL") ${CYAN}$LOG_FILE${NC}"
echo -e "$(msg_str "METRICS_PATH_LABEL") ${CYAN}$METRICS_DIR/reset_benchmarks.json${NC}"
echo -e "${CYAN}==================================================================${NC}"
echo ""
echo -e "$(msg_str "RESET_RESTART_HINT")"
case "$COMPONENT" in
  ${TARGET_SERVICE:-db-apex-proxy}|db-apex-proxy)
    echo "  1. Start container:          podman compose up -d ${TARGET_SERVICE:-db-apex-proxy}"
    echo "  2. Initialize DB instance:   ./scripts/internal/init-db-instance.sh ${TARGET_PROFILE} ${TARGET_SERVICE:-db-apex-proxy}"
    echo "  3. Install APEX engine:      ./scripts/internal/install-apex.sh"
    ;;
  db-publisher)
    echo "  1. Start container:          podman compose up -d db-publisher"
    echo "  2. Initialize DB instance:   ./scripts/internal/init-db-instance.sh appinfra-standard-gvenzl db-publisher"
    ;;
  ords)
    echo "  1. Start ORDS service:       podman compose --profile dev-ords up -d dev-ords"
    ;;
  all)
    echo -e "$(msg_str "RESET_HINT_FULL_PROCESS")"
    echo "    ./scripts/setup-all.sh"
    echo ""
    echo -e "$(msg_str "RESET_HINT_MANUAL_START")"
    echo "    ./scripts/start-containers.sh"
    ;;
esac
echo "=================================================================="
