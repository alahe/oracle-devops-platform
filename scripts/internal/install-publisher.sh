#!/usr/bin/env bash
# ============================================================================
# Oracle Analytics Publisher Central Installer Script
# Coordinates RCU initialization, container image build/run, and native fallback
# Logged to install_logs/ and benchmarked in metrics/
# ============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Color definitions
if [ -t 0 ] || { [ -n "$TERM" ] && [ "$TERM" != "dumb" ]; }; then
  GREEN='\033[1;32m'
  YELLOW='\033[0;33m'
  ORANGE='\033[38;5;208m'
  CYAN='\033[1;36m'
  RED='\033[1;31m'
  NC='\033[0m'
else
  GREEN=''
  YELLOW=''
  ORANGE=''
  CYAN=''
  RED=''
  NC=''
fi

LOG_DIR="$WORKSPACE_DIR/install_logs"
METRICS_DIR="$WORKSPACE_DIR/metrics"
mkdir -p "$LOG_DIR" "$METRICS_DIR"

TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
LOG_FILE="$LOG_DIR/publisher_engine_install_${TIMESTAMP}.log"
if [ -f "$SCRIPT_DIR/sanitize-logs.sh" ]; then
  source "$SCRIPT_DIR/sanitize-logs.sh"
  exec > >(sanitize_text | tee -a "$LOG_FILE") 2>&1
else
  exec > >(tee -a "$LOG_FILE") 2>&1
fi

format_duration() {
  local SECS=$1
  local MINS=$((SECS / 60))
  local REM_SECS=$((SECS % 60))
  if [ $MINS -gt 0 ]; then
    echo "${MINS}m ${REM_SECS}s"
  else
    echo "${REM_SECS}s"
  fi
}

# Source central localization engine & credential helper
if [ -f "$SCRIPT_DIR/i18n.sh" ]; then
  # shellcheck source=/dev/null
  source "$SCRIPT_DIR/i18n.sh"
fi
if [ -f "$SCRIPT_DIR/credential-helper.sh" ]; then
  # shellcheck source=/dev/null
  source "$SCRIPT_DIR/credential-helper.sh"
fi

get_pub_stats() {
  local step_key="$1"
  local default_est="$2"
  local values=()
  if [ -d "$METRICS_DIR" ]; then
    for f in "$METRICS_DIR"/publisher_benchmark*.json; do
      if [ -f "$f" ]; then
        local val=$(grep -m1 "\"$step_key\":" "$f" | awk -F: '{print $2}' | tr -d ' ,"\r\n' || echo "")
        if [[ "$val" =~ ^[0-9]+$ ]]; then
          values+=($val)
        fi
      fi
    done
  fi
  local count=${#values[@]}
  if [ $count -eq 0 ]; then
    msg_str "BENCHMARK_ESTIMATE" "${default_est}"
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
  msg_str "BENCHMARK_AVG" "$(format_duration $avg)"
}

print_pub_header() {
  local step_num="$1"
  local title="$2"
  local step_key="$3"
  local default_est="$4"
  echo -e "${CYAN}==================================================================${NC}"
  echo -e "${YELLOW}10.${step_num} ${title}${NC}"
  if [ -n "$step_key" ]; then
    echo -e "   📊 $(msg_str "BENCHMARK_LABEL") ${YELLOW}$(get_pub_stats "$step_key" "$default_est")${NC}"
  fi
  echo -e "${CYAN}==================================================================${NC}"
}

echo -e "${CYAN}==================================================================${NC}"
echo -e "${YELLOW}$(msg_str "PUB_INSTALL_HEADER")${NC}"
echo -e "$(msg_str "LOG_PATH_LABEL") ${CYAN}$LOG_FILE${NC}"
echo -e "${CYAN}==================================================================${NC}"

START_TIME=$(date '+%s')

if [ -f "$SCRIPT_DIR/load-profile.sh" ]; then
  source "$SCRIPT_DIR/load-profile.sh"
  load_db_profile >/dev/null 2>&1 || true
fi

# Ensure Publisher Metadata DB instance is fully OPEN (READ WRITE) before RCU/Domain steps
PUB_DB_CONTAINER=$(get_active_db_instances 2>/dev/null | grep -i "publisher" | head -n 1 | cut -d'|' -f1)
[ -z "$PUB_DB_CONTAINER" ] && PUB_DB_CONTAINER=$(get_active_db_instances 2>/dev/null | head -n 1 | cut -d'|' -f1)
PUB_DB_CONTAINER="${PUB_DB_CONTAINER:-db-proxy}"
if declare -f ensure_db_instance_open >/dev/null 2>&1; then
  ensure_db_instance_open "$PUB_DB_CONTAINER" || true
fi

# 10.1 RCU Schema Provisioning
print_pub_header "1" "Provisioning RCU Schemas (OAS_*)..." "step10_1_rcu_seconds" "2s"
START_STEP1=$(date +%s)
"$SCRIPT_DIR/init-publisher-rcu.sh" >> "$LOG_FILE" 2>&1 || true
END_STEP1=$(date +%s)
ELAPSED_STEP1=$(( END_STEP1 - START_STEP1 ))
echo -e "⏱  [$(msg_str "PUB_STEP_RCU" "${YELLOW}$(format_duration $ELAPSED_STEP1)${NC}")]"

# 10.2 ORDS REST Services for Publisher DB
print_pub_header "2" "Initializing ORDS Services for Publisher DB..." "step10_2_ords_seconds" "0s"
START_STEP2=$(date +%s)
if [ "${SKIP_ORDS}" != "true" ] && [ "${PROFILE_ORDS_ENABLED:-true}" = "true" ]; then
  "$SCRIPT_DIR/init-publisher-ords.sh" >> "$LOG_FILE" 2>&1 || true
else
  echo -e "   ℹ️ ORDS disabled for Publisher DB."
fi
END_STEP2=$(date +%s)
ELAPSED_STEP2=$(( END_STEP2 - START_STEP2 ))
echo -e "⏱  [$(msg_str "PUB_STEP_ORDS" "${YELLOW}$(format_duration $ELAPSED_STEP2)${NC}")]"

# Determine Execution Mode (Container vs Native)
INSTALL_MODE="${PUBLISHER_INSTALL_MODE:-container}"
if ! command -v podman >/dev/null 2>&1 && ! command -v docker >/dev/null 2>&1; then
  INSTALL_MODE="native"
fi

# Auto-resolve Pre-built Publisher Domain Image if available
IS_PREBUILT_DOMAIN=false
if [ -z "$PUBLISHER_CONTAINER_IMAGE" ]; then
  if podman image exists "localhost/oracle-publisher-domain:2025-db23ai" 2>/dev/null; then
    export PUBLISHER_CONTAINER_IMAGE="localhost/oracle-publisher-domain:2025-db23ai"
    IS_PREBUILT_DOMAIN=true
    echo -e "   ✅ Tuvastasin eel-konfigureeritud domeenipildi: ${CYAN}${PUBLISHER_CONTAINER_IMAGE}${NC}"
  elif podman image exists "localhost/oracle-publisher-domain:2025" 2>/dev/null; then
    export PUBLISHER_CONTAINER_IMAGE="localhost/oracle-publisher-domain:2025"
    IS_PREBUILT_DOMAIN=true
    echo -e "   ✅ Tuvastasin eel-konfigureeritud domeenipildi: ${CYAN}${PUBLISHER_CONTAINER_IMAGE}${NC}"
  elif podman image exists "oracle-publisher-domain:2025" 2>/dev/null; then
    export PUBLISHER_CONTAINER_IMAGE="oracle-publisher-domain:2025"
    IS_PREBUILT_DOMAIN=true
    echo -e "   ✅ Tuvastasin eel-konfigureeritud domeenipildi: ${CYAN}${PUBLISHER_CONTAINER_IMAGE}${NC}"
  elif podman image exists "localhost/oracle-publisher-domain-prebuilt:2025" 2>/dev/null; then
    export PUBLISHER_CONTAINER_IMAGE="localhost/oracle-publisher-domain-prebuilt:2025"
    IS_PREBUILT_DOMAIN=true
    echo -e "   ✅ Tuvastasin eel-konfigureeritud domeenipildi: ${CYAN}${PUBLISHER_CONTAINER_IMAGE}${NC}"
  elif podman image exists "localhost/oracle/analyticsserver:2025" 2>/dev/null; then
    export PUBLISHER_CONTAINER_IMAGE="localhost/oracle/analyticsserver:2025"
    echo -e "   ✅ Tuvastasin olemasoleva Publisher konteineripildi: ${CYAN}${PUBLISHER_CONTAINER_IMAGE}${NC}"
  elif podman image exists "oracle/analyticsserver:2025" 2>/dev/null; then
    export PUBLISHER_CONTAINER_IMAGE="oracle/analyticsserver:2025"
    echo -e "   ✅ Tuvastasin olemasoleva Publisher konteineripildi: ${CYAN}${PUBLISHER_CONTAINER_IMAGE}${NC}"
  fi
elif [[ "$PUBLISHER_CONTAINER_IMAGE" == *"domain"* ]] || [[ "$PUBLISHER_CONTAINER_IMAGE" == *"prebuilt"* ]]; then
  IS_PREBUILT_DOMAIN=true
fi

ELAPSED_STEP3=0
ELAPSED_STEP4=0

if [ "$INSTALL_MODE" = "container" ]; then
  # 10.3 Container Build & Startup
  print_pub_header "3" "Building & Starting Analytics Publisher Container..." "step10_3_build_seconds" "9m"
  START_STEP3=$(date +%s)
  if [ -n "$PUBLISHER_CONTAINER_IMAGE" ] && podman image exists "$PUBLISHER_CONTAINER_IMAGE" 2>/dev/null; then
    echo -e "$(msg_str "PUB_EXISTING_IMAGE_READY" "${CYAN}${PUBLISHER_CONTAINER_IMAGE}${NC}")"
  elif [ -f "$WORKSPACE_DIR/docker/publisher/build-publisher-image.sh" ]; then
    set +e
    "$WORKSPACE_DIR/docker/publisher/build-publisher-image.sh" >> "$LOG_FILE" 2>&1 &
    BUILD_PID=$!
    
    ELAPSED_CNT=0
    while kill -0 $BUILD_PID 2>/dev/null; do
      sleep 2
      ELAPSED_CNT=$((ELAPSED_CNT + 2))
      print_step_progress "$(msg_str "PUB_BUILD_PROGRESS")" "$ELAPSED_CNT" 15
    done
    wait $BUILD_PID
    BUILD_STATUS=$?
    set -e
    echo ""
    if [ $BUILD_STATUS -ne 0 ]; then
      echo -e "${RED}$(msg_str "PUB_BUILD_FAILED" "$BUILD_STATUS" "$LOG_FILE")${NC}"
    fi
  fi
  # Ensure clean container initialization if WebLogic domain was not completed
  if podman container exists app-publisher 2>/dev/null; then
    if ! podman exec app-publisher test -f /u01/oracle/user_projects/domains/bi/config/config.xml 2>/dev/null; then
      echo -e "   ⚠️ Incomplete WebLogic domain detected — recreating container with environment secrets..."
      podman rm -f app-publisher 2>/dev/null || true
    fi
  fi

  if ! podman ps --format "{{.Names}}" 2>/dev/null | grep -q "app-publisher"; then
    echo -e "🚀 Starting Analytics Publisher container (${CYAN}app-publisher${NC})..."
    
    TARGET_PUB_DB=$(resolve_service_target_db "publisher")
    TARGET_PUB_DB="${TARGET_PUB_DB:-db-proxy}"



    # Ensure target publisher DB is running
    if podman container exists "$TARGET_PUB_DB" 2>/dev/null && [ "$(podman inspect --format='{{.State.Status}}' "$TARGET_PUB_DB" 2>/dev/null)" != "running" ]; then
      podman start "$TARGET_PUB_DB" >/dev/null 2>&1 || true
    fi

    podman rm -f app-publisher 2>/dev/null || true
    NET_NAME=$(podman inspect "$TARGET_PUB_DB" --format '{{range $k, $v := .NetworkSettings.Networks}}{{$k}}{{end}}' 2>/dev/null || podman inspect "db-publisher" --format '{{range $k, $v := .NetworkSettings.Networks}}{{$k}}{{end}}' 2>/dev/null || podman network ls --format "{{.Name}}" 2>/dev/null | grep -v "bridge" | grep -v "host" | head -n 1 || echo "oracle-free-db-in-prod_default")
    NET_NAME="${NET_NAME:-oracle-free-db-in-prod_default}"
    
    SYS_PWD=$(get_db_sys_password "$TARGET_PUB_DB")
    if [ -z "$SYS_PWD" ]; then
      echo -e "${RED}❌ Error: Could not resolve database SYS password for ${TARGET_PUB_DB}!${NC}"
      exit 1
    fi

    pub_img="${PUBLISHER_CONTAINER_IMAGE:-}"
    if [ -z "$pub_img" ]; then
      if podman image exists "localhost/oracle/analyticsserver:2025" 2>/dev/null; then
        pub_img="localhost/oracle/analyticsserver:2025"
      elif podman image exists "localhost/oracle-publisher:latest" 2>/dev/null; then
        pub_img="localhost/oracle-publisher:latest"
      else
        pub_img="oracle/analyticsserver:2025"
      fi
    fi

    if ! podman image exists "$pub_img" 2>/dev/null; then
      echo -e "${RED}❌ Error: Publisher container image ($pub_img) not found!${NC}"
      exit 1
    fi

    # Ensure publisher_data volume exists and has oracle (1000:1000) ownership
    podman volume exists oracle-free-db-in-prod_publisher_data 2>/dev/null || podman volume create oracle-free-db-in-prod_publisher_data >/dev/null 2>&1 || true
    podman run --rm --user 0 -v oracle-free-db-in-prod_publisher_data:/u01/oracle/user_projects "$pub_img" /bin/bash -c "PATH=/usr/bin:/bin chown -R 1000:1000 /u01/oracle/user_projects && PATH=/usr/bin:/bin chmod 775 /u01/oracle/user_projects" >/dev/null 2>&1 || true

    pub_db_svc="${PROFILE_DEFAULT_SERVICE:-FREEPDB1}"
    [ "$pub_db_svc" = "none" ] && pub_db_svc="FREEPDB1"

    podman run -d --name app-publisher --security-opt=no-new-privileges --network="$NET_NAME" \
      -v oracle-free-db-in-prod_publisher_data:/u01/oracle/user_projects:rw \
      -v "$WORKSPACE_DIR/docker/publisher/dockerfiles/2025/createAndStartDomain.sh:/u01/createAndStartDomain.sh:ro" \
      -e ADMIN_USERNAME=weblogic \
      -e ADMIN_PASSWORD="$SYS_PWD" \
      -e DB_HOST="$TARGET_PUB_DB" \
      -e DB_PORT=1521 \
      -e DB_SERVICE="$pub_db_svc" \
      -e DB_USERNAME=sys \
      -e DB_PASSWORD="$SYS_PWD" \
      -e SCHEMA_PREFIX=OAS \
      -e SCHEMA_PASSWORD="$SYS_PWD" \
      -e BI_APP_LITE_PASSWORD="$SYS_PWD" \
      -e USER_MEM_ARGS="-Xms512m -Xmx1024m" \
      -p 127.0.0.1:9500:9500 -p 127.0.0.1:9502:9502 -p 127.0.0.1:9503:9503 "$pub_img" >> "$LOG_FILE" 2>&1 || true
  fi
  END_STEP3=$(date +%s)
  ELAPSED_STEP3=$(( END_STEP3 - START_STEP3 ))
  echo -e "⏱  [$(msg_str "PUB_STEP_BUILD" "${YELLOW}$(format_duration $ELAPSED_STEP3)${NC}")]"

  # 10.4 WebLogic Service Startup & Health Wait
  print_pub_header "4" "Waiting for WebLogic & Publisher Web UI Readiness..." "step10_4_wait_seconds" "3m 30s"
  START_STEP4=$(date +%s)
  echo "$(msg_str "PUB_WAITING_MSG")"
  ELAPSED_WAIT=0
  until curl -s -k -L --connect-timeout 4 --max-time 5 -o /dev/null -w "%{http_code}" http://localhost:9502/xmlpserver 2>/dev/null | grep -q -E "200|301|302|303|307" || [ $ELAPSED_WAIT -ge 420 ]; do
    sleep 4
    ELAPSED_WAIT=$((ELAPSED_WAIT + 4))
    print_step_progress "Waiting for Publisher Web UI (http://localhost:9502/xmlpserver)" "$ELAPSED_WAIT" 60
  done
  if [ -t 1 ] && [ -t 0 ] && [ -c /dev/tty ]; then
    printf "\r\033[K" >/dev/tty 2>/dev/null || true
  fi
  # Restore non-essential DB containers if they were stopped
  if [ "$IS_PREBUILT_DOMAIN" != "true" ] && [ "${ENABLE_PARALLEL_INIT:-false}" != "true" ]; then
    podman start db-proxy db-alise 2>/dev/null || true
  fi
  END_STEP4=$(date +%s)
  ELAPSED_STEP4=$(( END_STEP4 - START_STEP4 ))
  echo -e "⏱  [$(msg_str "PUB_STEP_WAIT" "${YELLOW}$(format_duration $ELAPSED_STEP4)${NC}")]"
else
  print_pub_header "3" "Native Server Mode Installation..." "step10_3_build_seconds" "5m"
  START_STEP3=$(date +%s)
  "$SCRIPT_DIR/install-publisher-native.sh" >> "$LOG_FILE" 2>&1 || true
  END_STEP3=$(date +%s)
  ELAPSED_STEP3=$(( END_STEP3 - START_STEP3 ))
  echo -e "⏱  [$(msg_str "PUB_STEP_BUILD" "${YELLOW}$(format_duration $ELAPSED_STEP3)${NC}")]"
fi

# 10.5 Deploy User Reports
print_pub_header "5" "Deploying Decoupled Analytics Publisher Reports..." "step10_5_reports_seconds" "1s"
START_STEP5=$(date +%s)
if [ -x "$SCRIPT_DIR/deploy-publisher-reports.sh" ]; then
  "$SCRIPT_DIR/deploy-publisher-reports.sh" >> "$LOG_FILE" 2>&1 || true
fi
END_STEP5=$(date +%s)
ELAPSED_STEP5=$(( END_STEP5 - START_STEP5 ))
echo -e "⏱  [$(msg_str "PUB_STEP_REPORTS" "${YELLOW}$(format_duration $ELAPSED_STEP5)${NC}")]"

# 10.6 Test URLs
print_pub_header "6" "Testing Environment URLs..." "step10_6_url_test_seconds" "5s"
START_TEST=$(date +%s)
if [ "$MASTER_SETUP" = "true" ]; then
  echo -e "   ℹ️ Master Setup: Web endpoints tested centrally in Step 11."
  ELAPSED_TEST=0
else
  if [ -x "$SCRIPT_DIR/test-urls.sh" ]; then
    "$SCRIPT_DIR/test-urls.sh" 24 5 || true
  fi
  END_TEST=$(date +%s)
  ELAPSED_TEST=$(( END_TEST - START_TEST ))
fi
echo -e "⏱  [$(msg_str "PUB_STEP_URL_TEST" "${YELLOW}$(format_duration $ELAPSED_TEST)${NC}")]"

END_TIME=$(date '+%s')
ELAPSED=$(( END_TIME - START_TIME ))

echo -e "${CYAN}==================================================================${NC}"
echo -e "${GREEN}$(msg_str "PUB_COMPLETED_MSG" "${YELLOW}$(format_duration $ELAPSED)${GREEN}")${NC}"
echo -e "${CYAN}==================================================================${NC}"
PUB_DB_CONTAINER="${TARGET_PUB_DB:-db-publisher}"
PUB_DB_UPPER=$(echo "$PUB_DB_CONTAINER" | sed 's/^db-//' | tr '-' '_' | tr '[:lower:]' '[:upper:]')
PUB_DB_PORT="${PROFILE_DB_PORT:-1531}"

echo -e "${YELLOW}$(msg_str "PUB_SUMMARY_HEADER")${NC}"
echo -e "$(msg_str "PUB_SUMMARY_UI" "${GREEN}http://localhost:9502/xmlpserver${NC}")"
echo -e "$(msg_str "PUB_SUMMARY_WLS" "${GREEN}http://localhost:9500/console${NC}")"
echo -e "$(msg_str "PUB_SUMMARY_USER" "${YELLOW}weblogic${NC}")"
echo -e "$(msg_str "PUB_SUMMARY_PWD" "${CYAN}DB_${PUB_DB_UPPER}_SYS${NC}")"
echo -e ""
echo -e "${YELLOW}$(msg_str "PUB_SUMMARY_DB_HEADER")${NC}"
echo -e "$(msg_str "PUB_SUMMARY_DB_TARGET" "${CYAN}${PUB_DB_CONTAINER}${NC}" "${PUB_DB_PORT}" "FREE" "FREEPDB1")"
echo -e "$(msg_str "PUB_SUMMARY_DB_PURPOSE")"
echo -e "$(msg_str "PUB_SUMMARY_DB_SYS" "${GREEN}DB_${PUB_DB_UPPER}_SYS${NC}")"
echo -e "$(msg_str "PUB_SUMMARY_DB_DBA" "${GREEN}DB_${PUB_DB_UPPER}_DBA_ADMIN${NC}")"
echo -e "$(msg_str "PUB_SUMMARY_DB_DEV" "${GREEN}DB_${PUB_DB_UPPER}_DEV${NC}")"
echo -e "$(msg_str "PUB_SUMMARY_DB_VIEWER" "${GREEN}DB_${PUB_DB_UPPER}_VIEWER${NC}")"
echo -e "${CYAN}==================================================================${NC}"

# Record benchmarks JSON
JSON_TS_PUB="$METRICS_DIR/publisher_benchmark_${TIMESTAMP}.json"
cat << EOF > "$JSON_TS_PUB"
{
  "last_updated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "publisher_install_seconds": $ELAPSED,
  "steps": {
    "step10_1_rcu_seconds": $ELAPSED_STEP1,
    "step10_2_ords_seconds": $ELAPSED_STEP2,
    "step10_3_build_seconds": $ELAPSED_STEP3,
    "step10_4_wait_seconds": $ELAPSED_STEP4,
    "step10_5_reports_seconds": $ELAPSED_STEP5,
    "step10_6_url_test_seconds": $ELAPSED_TEST
  }
}
EOF

cp "$JSON_TS_PUB" "$METRICS_DIR/publisher_benchmark.json"
(cd "$METRICS_DIR" && ls -t publisher_benchmark_*.json 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null || true)
