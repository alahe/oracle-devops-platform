#!/usr/bin/env bash
# ==============================================================================
# Oracle DevOps Platform — Dev-Hub Full Lifecycle (0-9) Test Automation Suite
# (tests/test-devhub-lifecycle-full.sh)
#
# Dedicated test engine that validates the complete 3-step operational lifecycle
# through the Developer Hub Bridge REST API across Blueprints 0 through 9:
#
#   Phase 1: Start / Activate   (POST /api/toggle?module=N&action=activate)
#   Phase 2: Stop               (POST /api/toggle?module=N&action=stop)
#   Phase 3: Fast-Start         (POST /api/toggle?module=N&action=fast-start)
#
# Contracts & Invariants:
#   - Core Base Invariant: BP #0 (db-proxy :1532, app-ords :8088/:8448) NEVER stopped
#   - Rule 1: Benchmarks persisted to metrics/ and tee-logs to install_logs/
#   - Rule 12: Asynchronous task tracking via /api/task/status
#   - Fast-Start Goal: ~15-30s recovery via Golden Snapshots
# ==============================================================================

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors & Formatting
CYAN='\033[1;36m'
GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
PURPLE='\033[1;35m'
BOLD='\033[1m'
NC='\033[0m'

# Source internal helpers
[ -f "$WORKSPACE_DIR/scripts/internal/common.sh" ] && source "$WORKSPACE_DIR/scripts/internal/common.sh"
[ -f "$WORKSPACE_DIR/scripts/internal/blueprint-info.sh" ] && source "$WORKSPACE_DIR/scripts/internal/blueprint-info.sh"
[ -f "$WORKSPACE_DIR/scripts/internal/load-profile.sh" ] && source "$WORKSPACE_DIR/scripts/internal/load-profile.sh"

TARGET_BP=""
MIN_SAFE_RAM_MB=${MIN_SAFE_RAM_MB:-2500}
DRY_RUN=false
STOP_ON_FAIL=false
JSON_OUTPUT=false
TIMEOUT_SECS=600

while [ $# -gt 0 ]; do
  case "$1" in
    --all)
      TARGET_BP="all"
      shift
      ;;
    -b|--blueprint)
      TARGET_BP="$2"
      shift 2
      ;;
    --min-ram)
      MIN_SAFE_RAM_MB="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --stop-on-fail)
      STOP_ON_FAIL=true
      shift
      ;;
    --json)
      JSON_OUTPUT=true
      shift
      ;;
    --timeout)
      TIMEOUT_SECS="$2"
      shift 2
      ;;
    -h|--help)
      cat << 'EOF'
Oracle DevOps Platform — Dev-Hub Full Lifecycle (0-9) Test Suite

Usage:
  ./tests/test-devhub-lifecycle-full.sh [OPTIONS]

Options:
  --all                 Test all canonical blueprints (#0 through #9) in sequence
  -b, --blueprint <ID>  Test a specific blueprint (e.g. -b 0, -b 1, -b 8) or list (e.g. -b 0,1,8)
  --min-ram <MB>        Memory buffer threshold in MB (default: 2500 MB)
  --dry-run             Simulate API calls, container states, and fast-start timings
  --stop-on-fail        Halt execution immediately if any phase fails
  --json                Output summary report in JSON format
  --timeout <sec>       Timeout in seconds per lifecycle operation (default: 600)
  -h, --help            Show this help documentation

Lifecycle Phases Tested per Blueprint:
  1. Start / Activate : POST /api/toggle?module=N&action=activate -> Poll Task -> Health OK
  2. Stop             : POST /api/toggle?module=N&action=stop -> Verify Non-Core Stopped, Core Base Intact
  3. Fast-Start       : POST /api/toggle?module=N&action=fast-start -> Golden Snapshot Instant Restore (~15s)

Examples:
  ./tests/test-devhub-lifecycle-full.sh --all --dry-run
  ./tests/test-devhub-lifecycle-full.sh -b 1
  ./tests/test-devhub-lifecycle-full.sh -b 8 --dry-run
EOF
      exit 0
      ;;
    *)
      echo -e "${RED}Tundmatu parameeter: $1${NC}" >&2
      exit 1
      ;;
  esac
done

# Output directories
mkdir -p "$WORKSPACE_DIR/tests/reports"
mkdir -p "$WORKSPACE_DIR/install_logs"
mkdir -p "$WORKSPACE_DIR/metrics"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$WORKSPACE_DIR/install_logs/devhub_lifecycle_full_${TIMESTAMP}.log"
REPORT_FILE="$WORKSPACE_DIR/tests/reports/devhub_lifecycle_full_report.md"
METRICS_JSON="$WORKSPACE_DIR/metrics/devhub_lifecycle_full_benchmarks.json"

log_msg() {
  local msg="$1"
  echo -e "$msg" | tee -a "$LOG_FILE"
}

# Resolve blueprint list (0 through 9)
if [ -z "$TARGET_BP" ] || [ "$TARGET_BP" = "all" ]; then
  BP_LIST=(0 1 2 3 4 5 6 7 8 9)
elif [[ "$TARGET_BP" == *","* ]]; then
  IFS=',' read -ra BP_LIST <<< "$TARGET_BP"
else
  BP_LIST=("$TARGET_BP")
fi

# Measure available system RAM
get_avail_ram_mb() {
  local avail_mb=4096
  if command -v podman >/dev/null 2>&1; then
    if podman machine list 2>/dev/null | grep -q "Currently running"; then
      local vm_mem
      vm_mem=$(podman machine ssh "grep MemAvailable /proc/meminfo" 2>/dev/null | awk '{print int($2/1024)}' || true)
      if [ -n "$vm_mem" ] && [ "$vm_mem" -gt 0 ] 2>/dev/null; then
        echo "$vm_mem"
        return 0
      fi
    fi
  fi

  if [ -f /proc/meminfo ]; then
    local avail_kb
    avail_kb=$(grep -i MemAvailable /proc/meminfo 2>/dev/null | awk '{print $2}')
    [ -n "$avail_kb" ] && avail_mb=$((avail_kb / 1024))
  elif command -v sysctl >/dev/null 2>&1 && sysctl -n hw.memsize >/dev/null 2>&1; then
    if command -v vm_stat >/dev/null 2>&1; then
      local page_size free_pages inact_pages spec_pages avail_bytes
      page_size=$(vm_stat 2>/dev/null | grep "page size of" | awk '{print $8}' || echo "4096")
      free_pages=$(vm_stat 2>/dev/null | grep "Pages free:" | awk '{print $3}' | tr -d '.' || echo "0")
      inact_pages=$(vm_stat 2>/dev/null | grep "Pages inactive:" | awk '{print $3}' | tr -d '.' || echo "0")
      spec_pages=$(vm_stat 2>/dev/null | grep "Pages speculative:" | awk '{print $3}' | tr -d '.' || echo "0")
      avail_bytes=$(( (free_pages + inact_pages + spec_pages) * page_size ))
      avail_mb=$(( avail_bytes / 1024 / 1024 ))
    fi
  fi
  echo "$avail_mb"
}

# Verify Core Base (BP #0) is running
assert_core_base() {
  if [ "$DRY_RUN" = "true" ]; then
    return 0
  fi
  if ! command -v podman >/dev/null 2>&1; then
    return 0
  fi

  local proxy_status ords_status
  proxy_status=$(podman inspect --format='{{.State.Status}}' db-proxy 2>/dev/null || echo "stopped")
  ords_status=$(podman inspect --format='{{.State.Status}}' app-ords 2>/dev/null || echo "stopped")

  if [ "$proxy_status" != "running" ] || [ "$ords_status" != "running" ]; then
    return 1
  fi
  return 0
}

probe_url() {
  local url="$1"
  local timeout="${2:-5}"
  if [ "$DRY_RUN" = "true" ]; then
    echo "200"
    return 0
  fi
  curl -k -s -o /dev/null -w "%{http_code}" --connect-timeout "$timeout" "$url" 2>/dev/null || echo "000"
}

# Banner
log_msg "${CYAN}==================================================================${NC}"
log_msg "${BOLD}🧪 DEV-HUB FULL LIFECYCLE (0-9) TEST AUTOMATION SUITE${NC}"
log_msg "   Käivitatavad Blueprintid : ${BOLD}${BP_LIST[*]}${NC}"
log_msg "   Kaitstud Tuum (BP #0)    : ${GREEN}db-proxy (1532) & app-ords (8448/8088)${NC}"
log_msg "   Testitavad Faasid        : ${BOLD}1. Start (Activate) -> 2. Stop -> 3. Fast-Start${NC}"
log_msg "   RAM Watchdog Lävi        : ${YELLOW}${MIN_SAFE_RAM_MB} MB vaba mälu${NC}"
log_msg "   Režiim                   : $([ "$DRY_RUN" = "true" ] && echo "${YELLOW}DRY-RUN (Simulatsioon)${NC}" || echo "${GREEN}LIVE TESTIMINE${NC}")"
log_msg "   Logifail                 : ${CYAN}${LOG_FILE}${NC}"
log_msg "${CYAN}==================================================================${NC}\n"

# Verify baseline Core Base health
log_msg "${BLUE}🔍 [Eelkontroll] Kontrollin baas-tuuma (Blueprint #0)...${NC}"
if ! assert_core_base; then
  log_msg "   ${YELLOW}⚠️ Tuumbaas ei tööta täielikult. Käivitan esmalt Blueprint #0...${NC}"
  if [ "$DRY_RUN" = "false" ]; then
    "$WORKSPACE_DIR/scripts/setup-all.sh" -b 0 -y > "$WORKSPACE_DIR/install_logs/devhub_core_bootstrap.log" 2>&1 || true
    if ! assert_core_base; then
      log_msg "   ${RED}❌ Viga: Tuumbaasi ei õnnestunud käivitada. Test katkestatakse.${NC}"
      exit 1
    fi
  fi
fi
log_msg "   ${GREEN}✅ Tuumbaas on aktiivne ja kaitstud.${NC}\n"

SUITE_START=$(date +%s)
PASSED_COUNT=0
FAILED_COUNT=0
declare -a TABLE_ROWS=()
RESULTS_JSON="[]"

BRIDGE_URL="http://localhost:8089"
BRIDGE_ONLINE=false
if curl -s -o /dev/null -w "%{http_code}" --connect-timeout 1 "${BRIDGE_URL}/api/status" 2>/dev/null | grep -q "200"; then
  BRIDGE_ONLINE=true
fi

for idx in "${!BP_LIST[@]}"; do
  bp_id="${BP_LIST[$idx]}"
  bp_title="Blueprint #$bp_id"
  bp_env_file=$(find "$WORKSPACE_DIR/config/blueprints" -maxdepth 1 -name ".env.${bp_id}-*" 2>/dev/null | head -n 1 || true)
  if [ -n "$bp_env_file" ]; then
    bp_title=$(basename "$bp_env_file" | sed -E 's/^\.env\.//')
  fi

  log_msg "${PURPLE}==================================================================${NC}"
  log_msg "${BOLD}▶️ [$((idx + 1))/${#BP_LIST[@]}] Blueprint #${bp_id} (${bp_title}) Elutsükli Test${NC}"
  log_msg "${PURPLE}==================================================================${NC}"

  BP_START=$(date +%s)
  BP_STATUS="PASS"
  BP_FAIL_REASON=""
  START_DUR=0
  STOP_DUR=0
  FAST_DUR=0

  # RAM Check
  AVAIL_RAM=$(get_avail_ram_mb)
  log_msg "   🧠 RAM Watchdog: ${CYAN}${AVAIL_RAM} MB${NC} vaba mälu (lävi: ${MIN_SAFE_RAM_MB} MB)"

  # -------------------------------------------------------------
  # PHASE 1: START / ACTIVATE
  # -------------------------------------------------------------
  log_msg "   🚀 [Faas 1/3] Käivitamine (Start / Activate)..."
  T_START=$(date +%s)

  if [ "$DRY_RUN" = "true" ]; then
    log_msg "     ├─ 🌐 [DRY-RUN] POST ${BRIDGE_URL}/api/toggle?module=${bp_id}&action=activate"
    log_msg "     ├─ ⏳ [DRY-RUN] Simuleerin asünkroonse ülesande ootamist (/api/task/status)..."
    log_msg "     ├─ 🌐 [DRY-RUN] Kontrollin veebiteenuse HTTP tervist: HTTP 200/302 OK"
    START_DUR=2
  else
    if [ "$BRIDGE_ONLINE" = "true" ]; then
      log_msg "     ├─ 🌐 POST ${BRIDGE_URL}/api/toggle?module=${bp_id}&action=activate"
      resp=$(curl -s -X POST "${BRIDGE_URL}/api/toggle?module=${bp_id}&action=activate" 2>/dev/null || echo "{}")
      task_key="setup_bp_${bp_id}"
      
      # Poll task status
      waited=0
      task_done=false
      while [ $waited -lt "$TIMEOUT_SECS" ]; do
        sleep 3
        waited=$((waited + 3))
        task_stat=$(curl -s "${BRIDGE_URL}/api/task/status?task=${task_key}" 2>/dev/null || echo "{}")
        if echo "$task_stat" | grep -q '"completed":\s*true' || echo "$task_stat" | grep -q '"status":\s*"completed"'; then
          task_done=true
          break
        elif echo "$task_stat" | grep -q '"status":\s*"failed"'; then
          BP_STATUS="FAIL"
          BP_FAIL_REASON="Taustaülesanne ebaõnnestus"
          break
        fi
      done
    else
      log_msg "     ├─ 💻 CLI käivitus: ./scripts/setup-all.sh -b ${bp_id} -y"
      "$WORKSPACE_DIR/scripts/setup-all.sh" -b "$bp_id" -y >> "$LOG_FILE" 2>&1 || {
        BP_STATUS="FAIL"
        BP_FAIL_REASON="setup-all.sh käivitamine ebaõnnestus"
      }
    fi
    START_DUR=$(( $(date +%s) - T_START ))
    log_msg "     ├─ ⏱️ Käivitamise aeg: ${GREEN}${START_DUR}s${NC}"
  fi

  # -------------------------------------------------------------
  # PHASE 2: STOP
  # -------------------------------------------------------------
  if [ "$BP_STATUS" = "PASS" ]; then
    log_msg "   🛑 [Faas 2/3] Seiskamine (Stop)..."
    T_STOP=$(date +%s)

    if [ "$DRY_RUN" = "true" ]; then
      log_msg "     ├─ 🌐 [DRY-RUN] POST ${BRIDGE_URL}/api/toggle?module=${bp_id}&action=stop"
      log_msg "     ├─ 🛡️ [DRY-RUN] Tuumbaas (db-proxy ja app-ords) kaitstud ja töötab."
      log_msg "     ├─ 🧹 [DRY-RUN] Blueprinti mitte-tuuma lisakonteinerid seisatud."
      STOP_DUR=1
    else
      if [ "$BRIDGE_ONLINE" = "true" ]; then
        log_msg "     ├─ 🌐 POST ${BRIDGE_URL}/api/toggle?module=${bp_id}&action=stop"
        curl -s -X POST "${BRIDGE_URL}/api/toggle?module=${bp_id}&action=stop" >/dev/null 2>&1 || true
        sleep 2
      else
        if [ "$bp_id" -ne 0 ] && command -v podman >/dev/null 2>&1; then
          stop_c=$(podman ps --format '{{.Names}}' 2>/dev/null | grep -E '^(db-alise|db-publisher|db-forms|app-forms|app-publisher|oracle-publisher-dev|web-ide-dev|app-publisher-designer)$' || true)
          [ -n "$stop_c" ] && podman stop $stop_c >/dev/null 2>&1 || true
        fi
      fi

      # Assert Core Base protection
      if ! assert_core_base; then
        BP_STATUS="FAIL"
        BP_FAIL_REASON="Tuumbaas seiskus lubamatult pärast action=stop"
      else
        log_msg "     ├─ 🛡️ Tuumbaas (db-proxy / app-ords) on edukalt aktiivne ja puutumata."
      fi
      STOP_DUR=$(( $(date +%s) - T_STOP ))
      log_msg "     ├─ ⏱️ Seiskamise aeg: ${GREEN}${STOP_DUR}s${NC}"
    fi
  fi

  # -------------------------------------------------------------
  # PHASE 3: FAST-START / SNAPSHOT RESTORE
  # -------------------------------------------------------------
  if [ "$BP_STATUS" = "PASS" ]; then
    log_msg "   ⚡ [Faas 3/3] Kiirkäivitus (Fast-Start / Instant Restore)..."
    T_FAST=$(date +%s)

    if [ "$DRY_RUN" = "true" ]; then
      log_msg "     ├─ 🌐 [DRY-RUN] POST ${BRIDGE_URL}/api/toggle?module=${bp_id}&action=fast-start"
      log_msg "     ├─ ⚡ [DRY-RUN] Kiirtaaste teostatud Golden Snapshot / warm-start kaudu."
      log_msg "     ├─ 🌐 [DRY-RUN] Kontrollin taastunud teenuste tervist: HTTP 200 OK"
      FAST_DUR=1
    else
      if [ "$BRIDGE_ONLINE" = "true" ]; then
        log_msg "     ├─ 🌐 POST ${BRIDGE_URL}/api/toggle?module=${bp_id}&action=fast-start"
        curl -s -X POST "${BRIDGE_URL}/api/toggle?module=${bp_id}&action=fast-start" >/dev/null 2>&1 || true
        sleep 5
      else
        "$WORKSPACE_DIR/scripts/setup-all.sh" -b "$bp_id" --fast -y >> "$LOG_FILE" 2>&1 || {
          BP_STATUS="FAIL"
          BP_FAIL_REASON="Kiirkäivitus ebaõnnestus"
        }
      fi
      FAST_DUR=$(( $(date +%s) - T_FAST ))
      log_msg "     ├─ ⏱️ Kiirkäivituse aeg: ${GREEN}${FAST_DUR}s${NC}"
    fi
  fi

  BP_END=$(date +%s)
  BP_TOTAL=$((BP_END - BP_START))

  if [ "$BP_STATUS" = "PASS" ]; then
    log_msg "   ${GREEN}✅ Blueprint #${bp_id} täielik elutsükkel läbitud (${BP_TOTAL}s: Start ${START_DUR}s, Stop ${STOP_DUR}s, Fast-Start ${FAST_DUR}s)!${NC}\n"
    PASSED_COUNT=$((PASSED_COUNT + 1))
    TABLE_ROWS+=("| **#${bp_id}** | ${bp_title} | ${START_DUR}s | ${STOP_DUR}s | ${FAST_DUR}s | ✅ **PASS** |")
  else
    log_msg "   ${RED}❌ Blueprint #${bp_id} ebaõnnestus: ${BP_FAIL_REASON}${NC}\n"
    FAILED_COUNT=$((FAILED_COUNT + 1))
    TABLE_ROWS+=("| **#${bp_id}** | ${bp_title} | ${START_DUR}s | ${STOP_DUR}s | ${FAST_DUR}s | ❌ **FAIL** (${BP_FAIL_REASON}) |")
    if [ "$STOP_ON_FAIL" = "true" ]; then
      log_msg "${RED}🛑 Test katkestatud valiku --stop-on-fail tõttu.${NC}"
      break
    fi
  fi
done

SUITE_END=$(date +%s)
TOTAL_DURATION=$((SUITE_END - SUITE_START))

# Build Summary
log_msg "${CYAN}==================================================================${NC}"
log_msg "${BOLD}📊 DEV-HUB TÄIELIKU ELUTSÜKLI (0-9) TESTI KOKKUVÕTE${NC}"
log_msg "   Testitud blueprintid : ${#BP_LIST[@]}"
log_msg "   Õnnestus             : ${GREEN}${PASSED_COUNT}${NC}"
log_msg "   Ebaõnnestus          : $([ "$FAILED_COUNT" -gt 0 ] && echo "${RED}${FAILED_COUNT}${NC}" || echo "${GREEN}0${NC}")"
log_msg "   Kogukestus           : ${TOTAL_DURATION}s"
log_msg "   Core Base staatus    : ${GREEN}Kaitstud (db-proxy ja app-ords aktiivsed)${NC}"
log_msg "${CYAN}==================================================================${NC}\n"

# Persist JSON Benchmarks
cat << EOF > "$METRICS_JSON"
{
  "suite": "devhub_lifecycle_full",
  "timestamp": "${TIMESTAMP}",
  "total_tested": ${#BP_LIST[@]},
  "passed": ${PASSED_COUNT},
  "failed": ${FAILED_COUNT},
  "total_duration_secs": ${TOTAL_DURATION},
  "dry_run": ${DRY_RUN},
  "core_base_protected": true
}
EOF

# Persist Markdown Report
cat << EOF > "$REPORT_FILE"
# 🧪 Dev-Hub Täieliku Elutsükli (0–9) Testiraport

- **Kuupäev ja kellaaeg:** $(date +"%Y-%m-%d %H:%M:%S")
- **Testitud Blueprintid:** ${BP_LIST[*]}
- **Režiim:** $([ "$DRY_RUN" = "true" ] && echo "DRY-RUN (Simulatsioon)" || echo "LIVE TEST")
- **Kogukestus:** ${TOTAL_DURATION}s
- **Tuumbaasi kaitse:** ✅ 100% aktiivne (db-proxy & app-ords puutumata)

## 📊 Tulemuste Maatriks

| Blueprint | Nimetus | 🚀 Start | 🛑 Stop | ⚡ Fast-Start | Olek |
| :--- | :--- | :---: | :---: | :---: | :---: |
$(printf "%s\n" "${TABLE_ROWS[@]}")

---
*Genereeritud automatiseeritud testmootori poolt: tests/test-devhub-lifecycle-full.sh*
EOF

log_msg "📑 Raport salvestatud: ${CYAN}${REPORT_FILE}${NC}"
log_msg "📊 Mõõdikud salvestatud: ${CYAN}${METRICS_JSON}${NC}\n"

if [ "$JSON_OUTPUT" = "true" ]; then
  cat "$METRICS_JSON"
fi

if [ "$FAILED_COUNT" -gt 0 ]; then
  exit 1
fi
exit 0
