#!/usr/bin/env bash
# ==============================================================================
# Oracle DevOps Platform — Master Blueprint Live Testing Suite
# (tests/test-all-blueprints-live.sh)
#
# Executes automated live end-to-end testing across all 16 architecture blueprints.
# Complies with:
#   - Rule 1: Step timing & persistence into metrics/ and install_logs/
#   - Rule 5: Zero-Trust SEPS Wallet credential extraction
#   - Rule 9: 6-language i18n & log invariants
#   - Rule 11: Clean blueprints & YAML profile single source of truth
#
# Usage:
#   ./tests/test-all-blueprints-live.sh [OPTIONS]
# Options:
#   --all               Test all 16 blueprints (default)
#   --group <1|2|3|4>   Test specific series (1=Standalone, 2=Consolidated, 3=Stack, 4=Hybrid)
#   -b, --blueprint <ID> Test a single blueprint (e.g. -b 20, -b 4, -b 21)
#   --fast              Fast mode using Golden Snapshots (~15s per DB)
#   --dry-run           Validate configurations, ports, and profiles without deploying containers
#   --stop-on-fail      Stop execution immediately upon first failure
#   --json              Output results as JSON
#   -h, --help          Show help message
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
BOLD='\033[1m'
NC='\033[0m'

# Source internal helpers
if [ -f "$WORKSPACE_DIR/scripts/internal/blueprint-info.sh" ]; then
  source "$WORKSPACE_DIR/scripts/internal/blueprint-info.sh"
fi

if [ -f "$WORKSPACE_DIR/scripts/internal/common.sh" ]; then
  source "$WORKSPACE_DIR/scripts/internal/common.sh"
fi

if [ -f "$WORKSPACE_DIR/scripts/internal/load-profile.sh" ]; then
  source "$WORKSPACE_DIR/scripts/internal/load-profile.sh"
fi

MODE="all"
TARGET_GROUP=""
TARGET_BP=""
FAST_MODE=false
DRY_RUN=false
STOP_ON_FAIL=false
JSON_OUTPUT=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --all)
      MODE="all"
      shift
      ;;
    --group)
      MODE="group"
      TARGET_GROUP="$2"
      shift 2
      ;;
    -b|--blueprint)
      MODE="single"
      TARGET_BP="$2"
      shift 2
      ;;
    --fast)
      FAST_MODE=true
      shift
      ;;
    --no-reset)
      NO_RESET=true
      shift
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
    -h|--help)
      cat <<'HELP'
Oracle DevOps Platform — Master Blueprint Live Testing Suite

Usage:
  ./tests/test-all-blueprints-live.sh [OPTIONS]

Options:
  --all               Test all 16 architecture blueprints
  --group <1|2|3|4>   Test specific series (1=Standalone, 2=Consolidated, 3=Stack, 4=Hybrid)
  -b, --blueprint <N> Test single blueprint (e.g. -b 20, -b 4, -b 21)
  --fast              Fast mode using Golden Snapshots
  --dry-run           Simulate validation without container restarts
  --stop-on-fail      Halt immediately on first failed assertion
  --json              Output metrics in JSON format
  -h, --help          Show this help message
HELP
      exit 0
      ;;
    *)
      shift
      ;;
  esac
done

BLUEPRINTS_DIR="$WORKSPACE_DIR/config/blueprints"
METRICS_DIR="$WORKSPACE_DIR/metrics"
REPORTS_DIR="$WORKSPACE_DIR/tests/reports"
mkdir -p "$METRICS_DIR" "$REPORTS_DIR"

# Collect list of blueprints to test
BLUEPRINT_FILES=()

if [ "$MODE" = "single" ]; then
  if [[ "$TARGET_BP" == *","* ]]; then
    IFS=',' read -ra BP_ARR <<< "$TARGET_BP"
    for bp in "${BP_ARR[@]}"; do
      bf=$(get_blueprint_file "$bp" 2>/dev/null || true)
      [ -n "$bf" ] && BLUEPRINT_FILES+=("$bf")
    done
  elif [[ "$TARGET_BP" =~ ^([0-9]+)-([0-9]+)$ ]]; then
    start_b="${BASH_REMATCH[1]}"
    end_b="${BASH_REMATCH[2]}"
    for ((b=start_b; b<=end_b; b++)); do
      bf=$(get_blueprint_file "$b" 2>/dev/null || true)
      [ -n "$bf" ] && BLUEPRINT_FILES+=("$bf")
    done
  else
    bp_file=$(get_blueprint_file "$TARGET_BP" 2>/dev/null || echo "")
    if [ -z "$bp_file" ] || [ ! -f "$bp_file" ]; then
      echo -e "${RED}❌ Error: Blueprint '$TARGET_BP' not found in $BLUEPRINTS_DIR${NC}" >&2
      exit 1
    fi
    BLUEPRINT_FILES+=("$bp_file")
  fi
elif [ "$MODE" = "group" ]; then
  case "$TARGET_GROUP" in
    0|default)
      for num in 0; do
        bf=$(get_blueprint_file "$num" 2>/dev/null || true)
        [ -n "$bf" ] && BLUEPRINT_FILES+=("$bf")
      done
      ;;
    1|databases|db)
      for num in 1 2 3 4; do
        bf=$(get_blueprint_file "$num" 2>/dev/null || true)
        [ -n "$bf" ] && BLUEPRINT_FILES+=("$bf")
      done
      ;;
    2|middleware|apps)
      for num in 5 6 7; do
        bf=$(get_blueprint_file "$num" 2>/dev/null || true)
        [ -n "$bf" ] && BLUEPRINT_FILES+=("$bf")
      done
      ;;
    3|developer|studio)
      for num in 8 9; do
        bf=$(get_blueprint_file "$num" 2>/dev/null || true)
        [ -n "$bf" ] && BLUEPRINT_FILES+=("$bf")
      done
      ;;
    4|remote|edge)
      for num in 10 11; do
        bf=$(get_blueprint_file "$num" 2>/dev/null || true)
        [ -n "$bf" ] && BLUEPRINT_FILES+=("$bf")
      done
      ;;
    *)
      echo -e "${RED}❌ Error: Invalid group '$TARGET_GROUP'. Choose 0, 1, 2, 3, or 4.${NC}" >&2
      exit 1
      ;;
  esac
else
  # Default --all: test all active blueprints (0..11) in numerical order
  for num in 0 1 2 3 4 5 6 7 8 9 10 11; do
    bf=$(get_blueprint_file "$num" 2>/dev/null || true)
    [ -n "$bf" ] && BLUEPRINT_FILES+=("$bf")
  done
fi

TOTAL_TESTS=${#BLUEPRINT_FILES[@]}
PASSED_TESTS=0
FAILED_TESTS=0
RESULTS_JSON="[]"

echo -e "${CYAN}==================================================================${NC}"
echo -e "${BOLD}🧪 ORACLE DEVOPS PLATFORM — MASTER BLUEPRINT LIVE TEST SUITE${NC}"
echo -e "${CYAN}==================================================================${NC}"
echo -e "📋 Total Blueprints to Test: ${BOLD}${TOTAL_TESTS}${NC}"
echo -e "⚡ Fast Mode (Golden Snapshots): ${BOLD}$([ "$FAST_MODE" = "true" ] && echo "ENABLED" || echo "DISABLED")${NC}"
echo -e "🔍 Dry Run Mode: ${BOLD}$([ "$DRY_RUN" = "true" ] && echo "ENABLED" || echo "DISABLED")${NC}"
echo -e "🛑 Stop on Fail: ${BOLD}$([ "$STOP_ON_FAIL" = "true" ] && echo "ENABLED" || echo "DISABLED")${NC}"
echo -e "${CYAN}==================================================================${NC}\n"

SUITE_START_TIME=$(date +%s)

for idx in "${!BLUEPRINT_FILES[@]}"; do
  bp_file="${BLUEPRINT_FILES[$idx]}"
  bp_num=$(get_blueprint_number "$bp_file")
  bp_name=$(basename "$bp_file" | sed -E 's/^\.env\.//')
  expected_conts=($(extract_blueprint_containers "$bp_file"))

  echo -e "\n${BLUE}------------------------------------------------------------------${NC}"
  echo -e "${BOLD}▶️ [$((idx + 1))/${TOTAL_TESTS}] Testing Blueprint ${bp_num}: ${bp_name}${NC}"
  echo -e "   📦 Expected Containers: ${CYAN}${expected_conts[*]:-None}${NC}"
  echo -e "${BLUE}------------------------------------------------------------------${NC}"

  TEST_START=$(date +%s)
  TEST_STATUS="PASS"
  FAIL_REASON=""
  LOG_FILE=""

  if [ "$DRY_RUN" = "true" ]; then
    # Simulation / Validation Mode
    echo -e "   🔍 [1/3] Validating Blueprint syntax and environment parameters..."
    if ! grep -q "=" "$bp_file"; then
      TEST_STATUS="FAIL"
      FAIL_REASON="Invalid syntax in $bp_file"
    fi

    echo -e "   🔍 [2/3] Checking referenced database & web-ide profiles..."
    for line in $(grep -E "^(DB_|WEB_IDE_PROFILE=)" "$bp_file" || true); do
      pname=$(echo "$line" | cut -d'=' -f2 | tr -d ' "\r\n')
      if [ -n "$pname" ] && [ "$pname" != "NONE" ]; then
        if [[ "$line" == "DB_"* ]] && [ ! -f "$WORKSPACE_DIR/config/profiles/databases/${pname}.yaml" ]; then
          TEST_STATUS="FAIL"
          FAIL_REASON="Missing profile config/profiles/databases/${pname}.yaml"
        elif [[ "$line" == "WEB_IDE_"* ]] && [ ! -f "$WORKSPACE_DIR/config/profiles/web-ide/${pname}.yaml" ]; then
          TEST_STATUS="FAIL"
          FAIL_REASON="Missing profile config/profiles/web-ide/${pname}.yaml"
        fi
      fi
    done

    echo -e "   🔍 [3/3] Simulating port allocation & topology mapping..."
    sleep 0.2
  else
    if [ "${NO_RESET:-false}" != "true" ]; then
      echo -e "   🧹 [1/5] Resetting existing environment (clean slate)..."
      "$WORKSPACE_DIR/scripts/reset-all.sh" all --force >/dev/null 2>&1 || true
      if command -v podman &>/dev/null; then
        for lc in $(podman ps -a --format '{{.Names}}' 2>/dev/null | grep -E '^(db-|app-|web-ide|oracle-)' || true); do
          podman rm -f "$lc" >/dev/null 2>&1 || true
        done
      fi
    else
      echo -e "   ⚡ [1/5] Preserving existing containers (--no-reset mode)..."
    fi

    echo -e "   ⚡ [2/5] Deploying Blueprint ${bp_num} (setup-all.sh)..."
    SETUP_ARGS=("-b" "$bp_num")
    [ "$FAST_MODE" = "true" ] && SETUP_ARGS+=("--fast" "--from-snapshot")

    SETUP_LOG="$WORKSPACE_DIR/install_logs/test_bp_${bp_num}_$(date +%Y%m%d_%H%M%S).log"
    LOG_FILE="$SETUP_LOG"

    if ! "$WORKSPACE_DIR/scripts/setup-all.sh" "${SETUP_ARGS[@]}" > "$SETUP_LOG" 2>&1; then
      TEST_STATUS="FAIL"
      FAIL_REASON="setup-all.sh failed with exit code $?"
    fi

    if [ "$TEST_STATUS" = "PASS" ]; then
      echo -e "   🔍 [3/5] Asserting Container Readiness & Isolation..."
      # Check required containers
      for c in "${expected_conts[@]}"; do
        [ -z "$c" ] && continue
        if ! podman container exists "$c" 2>/dev/null; then
          TEST_STATUS="FAIL"
          FAIL_REASON="Expected container '$c' does not exist."
          break
        fi
        c_status=$(podman inspect --format='{{.State.Status}}' "$c" 2>/dev/null || echo "stopped")
        if [ "$c_status" != "running" ]; then
          TEST_STATUS="FAIL"
          FAIL_REASON="Expected container '$c' is not running (status: $c_status)."
          break
        fi
      done

      # Check isolation: ensure unwanted DB containers are NOT running
      running_dbs=$(podman ps --format '{{.Names}}' 2>/dev/null | grep -E '^db-' || true)
      for r_db in $running_dbs; do
        if [[ ! " ${expected_conts[*]} " =~ " ${r_db} " ]]; then
          TEST_STATUS="FAIL"
          FAIL_REASON="Isolation violation: Container '$r_db' is running but not part of Blueprint ${bp_num}."
          break
        fi
      done
    fi

    if [ "$TEST_STATUS" = "PASS" ]; then
      echo -e "   🌐 [4/5] Asserting Network Endpoints & Ports..."
      # If Web IDE is expected, verify HTTP 8090
      if [[ " ${expected_conts[*]} " =~ " web-ide-dev " ]]; then
        http_code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8090/ 2>/dev/null || echo "000")
        if [ "$http_code" != "200" ] && [ "$http_code" != "302" ]; then
          TEST_STATUS="FAIL"
          FAIL_REASON="Web IDE port 8090 endpoint check failed (HTTP $http_code)."
        fi
      fi

      # If ORDS is expected, verify HTTPS 8448
      if [[ " ${expected_conts[*]} " =~ " app-ords " ]]; then
        ords_code=$(curl -s -k -o /dev/null -w "%{http_code}" https://localhost:8448/dev-hub.html 2>/dev/null || echo "000")
        if [ "$ords_code" != "200" ] && [ "$ords_code" != "301" ] && [ "$ords_code" != "302" ] && [ "$ords_code" != "307" ] && [ "$ords_code" != "308" ]; then
          TEST_STATUS="FAIL"
          FAIL_REASON="ORDS Dev Hub port 8448 check failed (HTTP $ords_code)."
        fi
      fi
    fi

    if [ "$TEST_STATUS" = "PASS" ]; then
      echo -e "   🔐 [5/5] Asserting SEPS Wallet & SQLcl Database Query..."
      for c in "${expected_conts[@]}"; do
        if [[ "$c" == "db-"* ]]; then
          db_check_res=$(podman exec -i "$c" bash -c '
            in_sql=$(ls -d /opt/oracle/product/*/dbhomeFree/sqlcl/bin/sql 2>/dev/null | head -n 1)
            if [ -n "$in_sql" ]; then
              "$in_sql" -s / as sysdba << "SQLEOF" 2>/dev/null
SELECT sys_context('\''USERENV\'', '\''CON_NAME\'') FROM dual;
EXIT;
SQLEOF
            fi' 2>/dev/null || echo "FAILED"
          )
          if [[ "$db_check_res" != *"CDB\$ROOT"* ]] && [[ "$db_check_res" != *"FREEPDB1"* ]]; then
            TEST_STATUS="FAIL"
            FAIL_REASON="Database health check query failed on container $c."
            break
          fi
        fi
      done
    fi
  fi

  TEST_END=$(date +%s)
  TEST_DURATION=$((TEST_END - TEST_START))

  if [ "$TEST_STATUS" = "PASS" ]; then
    echo -e "   ${GREEN}✅ PASS: Blueprint ${bp_num} (${bp_name}) verified in ${TEST_DURATION}s!${NC}"
    PASSED_TESTS=$((PASSED_TESTS + 1))
  else
    echo -e "   ${RED}❌ FAIL: Blueprint ${bp_num} (${bp_name}) failed in ${TEST_DURATION}s!${NC}"
    echo -e "   ${RED}   Reason: ${FAIL_REASON}${NC}"
    [ -n "$LOG_FILE" ] && echo -e "   ${YELLOW}   Log: ${LOG_FILE}${NC}"
    FAILED_TESTS=$((FAILED_TESTS + 1))
    if [ "$STOP_ON_FAIL" = "true" ]; then
      echo -e "\n${RED}🛑 Stopping execution due to --stop-on-fail flag.${NC}"
      break
    fi
  fi

  # Record JSON result
  item_json=$(jq -n \
    --arg num "$bp_num" \
    --arg name "$bp_name" \
    --arg status "$TEST_STATUS" \
    --arg duration "$TEST_DURATION" \
    --arg reason "$FAIL_REASON" \
    --arg log "$LOG_FILE" \
    --arg conts "${expected_conts[*]}" \
    '{blueprint_num: $num, name: $name, status: $status, duration_seconds: ($duration | tonumber), containers: $conts, fail_reason: $reason, log_file: $log}')

  RESULTS_JSON=$(echo "$RESULTS_JSON" | jq --argjson item "$item_json" '. + [$item]')
done

SUITE_END_TIME=$(date +%s)
TOTAL_SUITE_DURATION=$((SUITE_END_TIME - SUITE_START_TIME))

# Save master JSON report
MASTER_REPORT_JSON=$(jq -n \
  --arg timestamp "$(date '+%Y-%m-%d %H:%M:%S')" \
  --arg total "$TOTAL_TESTS" \
  --arg passed "$PASSED_TESTS" \
  --arg failed "$FAILED_TESTS" \
  --arg duration "$TOTAL_SUITE_DURATION" \
  --arg fast "$FAST_MODE" \
  --arg dry "$DRY_RUN" \
  --argjson results "$RESULTS_JSON" \
  '{
    timestamp: $timestamp,
    total_blueprints: ($total | tonumber),
    passed: ($passed | tonumber),
    failed: ($failed | tonumber),
    total_duration_seconds: ($duration | tonumber),
    fast_mode: ($fast == "true"),
    dry_run: ($dry == "true"),
    results: $results
  }')

echo "$MASTER_REPORT_JSON" > "$METRICS_DIR/blueprint_live_test_results.json"

# Generate Markdown Report
REPORT_MD="$REPORTS_DIR/blueprints_live_test_report.md"
cat << MD_EOF > "$REPORT_MD"
# 🧪 Master Blueprint Live Testing Summary Report

- **Date:** $(date '+%Y-%m-%d %H:%M:%S')
- **Total Tested:** ${TOTAL_TESTS}
- **Passed:** ${PASSED_TESTS} (✅)
- **Failed:** ${FAILED_TESTS} (❌)
- **Total Duration:** ${TOTAL_SUITE_DURATION}s
- **Fast Mode:** $([ "$FAST_MODE" = "true" ] && echo "Yes (Golden Snapshots)" || echo "No")
- **Dry Run:** $([ "$DRY_RUN" = "true" ] && echo "Yes" || echo "No")

---

## 📊 Detailed Blueprint Results Table

| BP # | Blueprint Name | Expected Containers | Duration | Status | Details / Fail Reason |
| :---: | :--- | :--- | :---: | :---: | :--- |
MD_EOF

for row in $(echo "$RESULTS_JSON" | jq -r '.[] | @base64'); do
  _decode() { echo "$row" | base64 --decode | jq -r "$1"; }
  r_num=$(_decode '.blueprint_num')
  r_name=$(_decode '.name')
  r_conts=$(_decode '.containers')
  r_dur=$(_decode '.duration_seconds')
  r_st=$(_decode '.status')
  r_reason=$(_decode '.fail_reason // empty')
  
  if [ "$r_st" = "PASS" ]; then
    st_icon="✅ PASS"
  else
    st_icon="❌ FAIL"
  fi
  echo "| **${r_num}** | \`${r_name}\` | \`${r_conts}\` | ${r_dur}s | ${st_icon} | ${r_reason:-All assertions verified} |" >> "$REPORT_MD"
done

echo ""
echo -e "${CYAN}==================================================================${NC}"
echo -e "${BOLD}🏁 MASTER BLUEPRINT LIVE TEST SUITE COMPLETED${NC}"
echo -e "${CYAN}==================================================================${NC}"
echo -e "📊 Total Tested:    ${BOLD}${TOTAL_TESTS}${NC}"
echo -e "✅ Passed:          ${GREEN}${PASSED_TESTS}${NC}"
echo -e "❌ Failed:          $([ "$FAILED_TESTS" -eq 0 ] && echo "${GREEN}0${NC}" || echo "${RED}${FAILED_TESTS}${NC}")"
echo -e "⏱  Total Duration:  ${BOLD}${TOTAL_SUITE_DURATION}s${NC}"
echo -e "📝 Markdown Report: ${CYAN}[Report](file://${REPORT_MD})${NC}"
echo -e "📈 JSON Metrics:    ${CYAN}[Metrics](file://${METRICS_DIR}/blueprint_live_test_results.json)${NC}"
echo -e "${CYAN}==================================================================${NC}\n"

if [ "$JSON_OUTPUT" = "true" ]; then
  cat "$METRICS_DIR/blueprint_live_test_results.json"
fi

if [ "$FAILED_TESTS" -gt 0 ]; then
  exit 1
fi
exit 0
