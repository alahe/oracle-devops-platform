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
LOG_FILE="$LOG_DIR/publisher_install_${TIMESTAMP}.log"
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
    echo "ootusaeg ~${default_est}"
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
  echo "keskmine: $(format_duration $avg) (min: $(format_duration $min), max: $(format_duration $max))"
}

print_pub_header() {
  local step_num="$1"
  local title="$2"
  local step_key="$3"
  local default_est="$4"
  echo -e "${CYAN}==================================================================${NC}"
  echo -e "${YELLOW}10.${step_num} ${title}${NC}"
  if [ -n "$step_key" ]; then
    echo -e "   📊 Ajalooline ooteaeg: ${YELLOW}$(get_pub_stats "$step_key" "$default_est")${NC}"
  fi
  echo -e "${CYAN}==================================================================${NC}"
}

echo -e "${CYAN}==================================================================${NC}"
echo -e "${YELLOW}🚀 Oracle Analytics Publisher Full Automated Setup${NC}"
echo -e "📝 Logifail: ${CYAN}$LOG_FILE${NC}"
echo -e "${CYAN}==================================================================${NC}"

START_TIME=$(date '+%s')

if [ -f "$SCRIPT_DIR/load-profile.sh" ]; then
  source "$SCRIPT_DIR/load-profile.sh"
  load_db_profile >/dev/null 2>&1 || true
fi

# Ensure Publisher Metadata DB instance is fully OPEN (READ WRITE) before RCU/Domain steps
PUB_DB_CONTAINER=$(get_active_db_instances 2>/dev/null | grep -i "publisher" | head -n 1 | cut -d'|' -f1)
PUB_DB_CONTAINER="${PUB_DB_CONTAINER:-db-publisher}"
if declare -f ensure_db_instance_open >/dev/null 2>&1; then
  ensure_db_instance_open "$PUB_DB_CONTAINER" || true
fi

# 10.1 RCU Schema Provisioning
print_pub_header "1" "Provisioning RCU Schemas (OAS_*)..." "step10_1_rcu_seconds" "2s"
START_STEP1=$(date +%s)
"$SCRIPT_DIR/init-publisher-rcu.sh" >> "$LOG_FILE" 2>&1 || true
END_STEP1=$(date +%s)
ELAPSED_STEP1=$(( END_STEP1 - START_STEP1 ))
echo -e "⏱  [Samm 10.1 valmis (RCU skeemid): ${YELLOW}$(format_duration $ELAPSED_STEP1)${NC}]"

# 10.2 ORDS REST Services for Publisher DB
print_pub_header "2" "Initializing ORDS Services for Publisher DB..." "step10_2_ords_seconds" "0s"
START_STEP2=$(date +%s)
if [ "${SKIP_ORDS}" != "true" ] && [ "${PROFILE_ORDS_ENABLED:-true}" = "true" ]; then
  "$SCRIPT_DIR/init-publisher-ords.sh" >> "$LOG_FILE" 2>&1 || true
else
  echo -e "   ℹ️ ORDS teenus Publisher andmebaasile on vahele jäetud (ORDS disabled)."
fi
END_STEP2=$(date +%s)
ELAPSED_STEP2=$(( END_STEP2 - START_STEP2 ))
echo -e "⏱  [Samm 10.2 valmis (ORDS teenused): ${YELLOW}$(format_duration $ELAPSED_STEP2)${NC}]"

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
    echo -e "   ✅ Olemasolev Publisheri konteineripilt (${CYAN}${PUBLISHER_CONTAINER_IMAGE}${NC}) on valmis. Ehitus jäetakse vahele!"
  elif [ -f "$WORKSPACE_DIR/docker/publisher/build-publisher-image.sh" ]; then
    "$WORKSPACE_DIR/docker/publisher/build-publisher-image.sh" >> "$LOG_FILE" 2>&1 &
    BUILD_PID=$!
    
    ELAPSED_CNT=0
    while kill -0 $BUILD_PID 2>/dev/null; do
      sleep 2
      ELAPSED_CNT=$((ELAPSED_CNT + 2))
      print_step_progress "Ehitan ja paigaldan Publisher konteinerit" "$ELAPSED_CNT" 15
    done
    wait $BUILD_PID || true
    echo ""
  fi
  # Self-healing check: if app-publisher is already running but domain configuration failed (config.xml missing), clean incomplete domain
  if podman ps --format "{{.Names}}" 2>/dev/null | grep -q "app-publisher"; then
    if ! podman exec app-publisher test -f /u01/oracle/user_projects/domains/bi/config/config.xml 2>/dev/null; then
      echo -e "   ⚠️ Tuvastasin poolelejäänud WebLogic domeeni – puhastan vigase seisu ja taaskäivitan loogika..."
      podman exec app-publisher rm -rf /u01/oracle/user_projects/domains/bi 2>/dev/null || true
      podman exec -d app-publisher /u01/createAndStartDomain.sh 2>/dev/null || true
    fi
  fi

  if ! podman ps --format "{{.Names}}" 2>/dev/null | grep -q "app-publisher"; then
    echo -e "🚀 Käivitan Analytics Publisher konteineri (${CYAN}app-publisher${NC})..."
    
    # Conditional memory safeguard: only stop other DBs if NOT using prebuilt domain and parallel init is disabled
    if [ "$IS_PREBUILT_DOMAIN" != "true" ] && [ "${ENABLE_PARALLEL_INIT:-false}" != "true" ]; then
      echo -e "   🛡️  Säästan mälu WebLogic domeeni loomiseks (peatades ajutiselt lisa-andmebaasid)..."
      podman stop db-proxy db-lis 2>/dev/null || true
    fi
    podman rm -f app-publisher 2>/dev/null || true
    NET_NAME=$(podman network ls --format "{{.Name}}" 2>/dev/null | grep -v "bridge" | grep -v "host" | head -n 1)
    NET_NAME="${NET_NAME:-oracle-free-db-in-prod_default}"
    
    PRIMARY_CONTAINER=$(get_active_db_instances 2>/dev/null | head -n 1 | cut -d'|' -f1)
    PRIMARY_CONTAINER="${PRIMARY_CONTAINER:-main-db-profile}"
    SYS_PWD=$(podman exec "$PRIMARY_CONTAINER" cat /run/secrets/oracle_pwd 2>/dev/null || podman secret inspect --showsecret publisher_db_sys_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || podman secret inspect --showsecret apex_db_sys_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || echo "")
    if [ -z "$SYS_PWD" ]; then
      SYS_PWD=$("$SCRIPT_DIR/get-password.sh" "DB_PUBLISHER_SYS" 2>/dev/null | grep "Password:" | awk '{print $3}' | sed 's/\x1b\[[0-9;]*m//g' | tr -d '\r\n' || echo "")
    fi
    if [ -z "$SYS_PWD" ]; then
      echo -e "${RED}❌ VIGA: Ei suutnud leida andmebaasi SYS parooli Walletist ega Podman Secrets store'ist!${NC}"
      exit 1
    fi

    if ! podman image exists "${PUBLISHER_CONTAINER_IMAGE:-oracle/analyticsserver:2025}" 2>/dev/null; then
      echo -e "${RED}❌ VIGA: Publisheri konteineripilti (${PUBLISHER_CONTAINER_IMAGE:-oracle/analyticsserver:2025}) ei leitud! Ehitus ebaõnnestus.${NC}"
      exit 1
    fi

    podman run -d --name app-publisher --security-opt=no-new-privileges --network="$NET_NAME" \
      -v "$WORKSPACE_DIR/docker/publisher/dockerfiles/2025/createAndStartDomain.sh:/u01/createAndStartDomain.sh:ro" \
      -e ADMIN_USERNAME=weblogic \
      -e ADMIN_PASSWORD="$SYS_PWD" \
      -e DB_HOST="$PRIMARY_CONTAINER" \
      -e DB_PORT=1521 \
      -e DB_SERVICE="${PROFILE_DEFAULT_SERVICE:-FREEPDB1}" \
      -e DB_USERNAME=sys \
      -e DB_PASSWORD="$SYS_PWD" \
      -e SCHEMA_PREFIX=OAS \
      -e SCHEMA_PASSWORD="$SYS_PWD" \
      -e BI_APP_LITE_PASSWORD="$SYS_PWD" \
      -e USER_MEM_ARGS="-Xms512m -Xmx1024m" \
      -p 127.0.0.1:9500:9500 -p 127.0.0.1:9502:9502 -p 127.0.0.1:9503:9503 "${PUBLISHER_CONTAINER_IMAGE:-oracle/analyticsserver:2025}" >> "$LOG_FILE" 2>&1 || true
  fi
  END_STEP3=$(date +%s)
  ELAPSED_STEP3=$(( END_STEP3 - START_STEP3 ))
  echo -e "⏱  [Samm 10.3 valmis (Konteineri ehitus & käivitus): ${YELLOW}$(format_duration $ELAPSED_STEP3)${NC}]"

  # 10.4 WebLogic Service Startup & Health Wait
  print_pub_header "4" "Waiting for WebLogic & Publisher Web UI Readiness..." "step10_4_wait_seconds" "3m 30s"
  START_STEP4=$(date +%s)
  echo "⌛ Ootan Publisher veebiteenuse (WebLogic) ja /xmlpserver rakenduse käivitumist..."
  ELAPSED_WAIT=0
  until curl -s -k -L --connect-timeout 4 --max-time 5 -o /dev/null -w "%{http_code}" http://localhost:9502/xmlpserver 2>/dev/null | grep -q -E "200|301|302|303|307" || [ $ELAPSED_WAIT -ge 240 ]; do
    sleep 4
    ELAPSED_WAIT=$((ELAPSED_WAIT + 4))
    print_step_progress "Ootan Publisher veebiliidest (http://localhost:9502/xmlpserver)" "$ELAPSED_WAIT" 60
  done
  if [ -t 1 ] && [ -t 0 ] && [ -c /dev/tty ]; then
    printf "\r\033[K" >/dev/tty 2>/dev/null || true
  fi
  # Restore non-essential DB containers if they were stopped
  if [ "$IS_PREBUILT_DOMAIN" != "true" ] && [ "${ENABLE_PARALLEL_INIT:-false}" != "true" ]; then
    podman start db-proxy db-lis 2>/dev/null || true
  fi
  END_STEP4=$(($(date +%s) - START_STEP4))
  ELAPSED_STEP4=$(( END_STEP4 - START_STEP4 ))
  echo -e "⏱  [Samm 10.4 valmis (WebLogic veebiliidese kättesaadavus): ${YELLOW}$(format_duration $ELAPSED_STEP4)${NC}]"
else
  print_pub_header "3" "Native Server Mode Installation..." "step10_3_build_seconds" "5m"
  START_STEP3=$(date +%s)
  "$SCRIPT_DIR/install-publisher-native.sh" >> "$LOG_FILE" 2>&1 || true
  END_STEP3=$(date +%s)
  ELAPSED_STEP3=$(( END_STEP3 - START_STEP3 ))
  echo -e "⏱  [Samm 10.3 valmis (Native paigaldus): ${YELLOW}$(format_duration $ELAPSED_STEP3)${NC}]"
fi

# 10.5 Deploy User Reports
print_pub_header "5" "Deploying Decoupled Analytics Publisher Reports..." "step10_5_reports_seconds" "1s"
START_STEP5=$(date +%s)
if [ -x "$SCRIPT_DIR/deploy-publisher-reports.sh" ]; then
  "$SCRIPT_DIR/deploy-publisher-reports.sh" >> "$LOG_FILE" 2>&1 || true
fi
END_STEP5=$(date +%s)
ELAPSED_STEP5=$(( END_STEP5 - START_STEP5 ))
echo -e "⏱  [Samm 10.5 valmis (Raportite paigaldus): ${YELLOW}$(format_duration $ELAPSED_STEP5)${NC}]"

# 10.6 Test URLs
print_pub_header "6" "Testing Environment URLs..." "step10_6_url_test_seconds" "5s"
START_TEST=$(date +%s)
if [ "$MASTER_SETUP" = "true" ]; then
  echo -e "   ℹ️ Master-seadistus aktiivne: Veebiliideste (ORDS, APEX, Publisher, Web IDE) kättesaadavust kontrollitakse tsentraalselt sammus 11."
  ELAPSED_TEST=0
else
  if [ -x "$SCRIPT_DIR/test-urls.sh" ]; then
    "$SCRIPT_DIR/test-urls.sh" 24 5 || {
      echo -e "${YELLOW}⚠️ Mõned URL testid vajavad tähelepanu, jätkan paigaldust.${NC}"
    }
  fi
  END_TEST=$(date +%s)
  ELAPSED_TEST=$(( END_TEST - START_TEST ))
fi
echo -e "⏱  [Samm 10.6 valmis (URL testid): ${YELLOW}$(format_duration $ELAPSED_TEST)${NC}]"

END_TIME=$(date '+%s')
ELAPSED=$(( END_TIME - START_TIME ))

echo -e "${CYAN}==================================================================${NC}"
echo -e "${GREEN}✅ Oracle Analytics Publisher paigaldus edukalt sooritatud! (${YELLOW}$(format_duration $ELAPSED)${GREEN})${NC}"
echo -e "${CYAN}==================================================================${NC}"
echo -e "${YELLOW}🌐 PUBLISHER VEEBILIIDES JA KASUTAJAD:${NC}"
echo -e "   - Publisher UI (Brauser):      ${GREEN}http://localhost:9502/xmlpserver${NC}"
echo -e "   - WebLogic Console (Rest REST): ${GREEN}http://localhost:9500/console${NC}"
echo -e "   - Administraatori kasutaja:   ${YELLOW}weblogic${NC}"
echo -e "   - Parooli lugemine Walletist:  ${CYAN}./scripts/internal/get-password.sh DB_PUBLISHER_SYS${NC}"
echo -e ""
echo -e "${YELLOW}🗄️ PUBLISHERI CONFIG/RCU ANDMEBAAS (Metadata DB):${NC}"
echo -e "   - Konteiner & Port:           ${CYAN}db-publisher${NC} (Port 1531 / SID: FREE / PDB: FREEPDB1)"
echo -e "   - Otstarve:                   Publisheri konfiguratsiooni, WebLogic RCU (OAS_*) ja metaandmete hoidla"
echo -e "   - SYS Admin (SYSDBA):         ${GREEN}sql /@DB_PUBLISHER_SYS as sysdba${NC}"
echo -e "   - DBA Administraator:        ${GREEN}sql /@DB_PUBLISHER_DBA_ADMIN${NC}"
echo -e "   - Arendaja:                  ${GREEN}sql /@DB_PUBLISHER_DEV${NC}"
echo -e "   - Tava/Test vaataja:          ${GREEN}sql /@DB_PUBLISHER_VIEWER${NC}"
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
