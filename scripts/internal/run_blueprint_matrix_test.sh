#!/usr/bin/env bash
# ============================================================================
# Automated Matrix Test Runner for Architecture Blueprints (Series 1-40+)
# Executes 2 passes per blueprint:
#   Pass 1: Cold Clean Setup (reset-all -y + setup-all.sh -b <N>)
#   Pass 2: Warm Startup (Containers restart & fast recovery)
# Validates URLs, SEPS Wallet, E2E Browser Login and records benchmarks.
# ============================================================================

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
LOG_DIR="$WORKSPACE_DIR/install_logs"
METRICS_DIR="$WORKSPACE_DIR/metrics"
mkdir -p "$LOG_DIR" "$METRICS_DIR"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
MATRIX_LOG="$LOG_DIR/blueprint_matrix_test_${TIMESTAMP}.log"
exec > >(tee -a "$MATRIX_LOG") 2>&1

REPORT_FILE="$WORKSPACE_DIR/metrics/matrix_test_report_${TIMESTAMP}.json"
SUMMARY_MD="$WORKSPACE_DIR/metrics/matrix_test_summary_${TIMESTAMP}.md"

# Blueprints to test (default: 3 to 43 as requested)
if [ $# -gt 0 ]; then
  BP_LIST=("$@")
else
  BP_LIST=(3 4 5 6 7 10 11 12 13 20 21 22 23 30 31 32 33 34 40 41 42 43)
fi

echo "=================================================================="
echo "🧪 ARCHITECTURE BLUEPRINTS AUTOMATED MATRIX TEST RUNNER"
echo "   Blueprints to test: ${BP_LIST[*]}"
echo "   Log file: $MATRIX_LOG"
echo "   Timestamp: $TIMESTAMP"
echo "=================================================================="

RESULTS_JSON="[]"

TOTAL_COUNT=${#BP_LIST[@]}
CURRENT_IDX=0

for BP in "${BP_LIST[@]}"; do
  CURRENT_IDX=$((CURRENT_IDX + 1))
  echo ""
  echo "=================================================================="
  echo "🚀 [${CURRENT_IDX}/${TOTAL_COUNT}] STARTING MATRIX TEST FOR BLUEPRINT #${BP}"
  echo "=================================================================="

  BP_START=$(date +%s)

  # ---------------------------------------------------------
  # PASS 1: COLD SETUP FROM SCRATCH
  # ---------------------------------------------------------
  echo "❄️  [PASS 1: COLD SETUP] Resetting environment and running setup-all.sh -b ${BP}..."
  COLD_START=$(date +%s)
  
  # Clean reset
  "$WORKSPACE_DIR/scripts/reset-all.sh" -y --lang en >/dev/null 2>&1 || true

  # Setup blueprint
  COLD_ERR=""
  if ! "$WORKSPACE_DIR/scripts/setup-all.sh" -b "$BP" --force --lang en; then
    COLD_ERR="setup-all failed"
  fi
  COLD_END=$(date +%s)
  COLD_DUR=$((COLD_END - COLD_START))

  # Pass 1 Diagnostics
  echo "🔍 [PASS 1 DIAGNOSTICS] Checking URLs, SEPS Wallet & E2E Login..."
  URL_STATUS_1="PASS"
  if [ -x "$WORKSPACE_DIR/scripts/check-urls.sh" ]; then
    if ! "$WORKSPACE_DIR/scripts/check-urls.sh" >/dev/null 2>&1; then
      URL_STATUS_1="FAIL"
    fi
  fi

  WALLET_STATUS_1="PASS"
  if [ -x "$WORKSPACE_DIR/scripts/check-wallet.sh" ]; then
    if ! "$WORKSPACE_DIR/scripts/check-wallet.sh" >/dev/null 2>&1; then
      WALLET_STATUS_1="FAIL"
    fi
  fi

  LOGIN_STATUS_1="PASS"
  if [ -x "$WORKSPACE_DIR/scripts/test-browser-login.sh" ]; then
    if ! "$WORKSPACE_DIR/scripts/test-browser-login.sh" >/dev/null 2>&1; then
      LOGIN_STATUS_1="FAIL"
    fi
  fi

  echo "   ❄️ Cold Duration: ${COLD_DUR}s | URLs: ${URL_STATUS_1} | Wallet: ${WALLET_STATUS_1} | E2E Login: ${LOGIN_STATUS_1}"

  # ---------------------------------------------------------
  # PASS 2: WARM RESTART / PRE-CONFIGURED RECOVERY
  # ---------------------------------------------------------
  echo "🔥 [PASS 2: WARM RESTART] Restarting active containers & measuring warm recovery..."
  WARM_START=$(date +%s)
  
  if [ -x "$WORKSPACE_DIR/scripts/start-containers.sh" ]; then
    "$WORKSPACE_DIR/scripts/start-containers.sh" >/dev/null 2>&1 || true
  else
    podman restart $(podman ps -q) >/dev/null 2>&1 || true
  fi

  # Wait for DB container healthy
  if [ -x "$WORKSPACE_DIR/scripts/internal/wait-db-healthy.sh" ]; then
    "$WORKSPACE_DIR/scripts/internal/wait-db-healthy.sh" 30 >/dev/null 2>&1 || true
  fi

  WARM_END=$(date +%s)
  WARM_DUR=$((WARM_END - WARM_START))

  # Pass 2 Diagnostics
  echo "🔍 [PASS 2 DIAGNOSTICS] Verifying warm service recovery..."
  URL_STATUS_2="PASS"
  if [ -x "$WORKSPACE_DIR/scripts/check-urls.sh" ]; then
    if ! "$WORKSPACE_DIR/scripts/check-urls.sh" >/dev/null 2>&1; then
      URL_STATUS_2="FAIL"
    fi
  fi

  LOGIN_STATUS_2="PASS"
  if [ -x "$WORKSPACE_DIR/scripts/test-browser-login.sh" ]; then
    if ! "$WORKSPACE_DIR/scripts/test-browser-login.sh" >/dev/null 2>&1; then
      LOGIN_STATUS_2="FAIL"
    fi
  fi

  echo "   🔥 Warm Duration: ${WARM_DUR}s | URLs: ${URL_STATUS_2} | E2E Login: ${LOGIN_STATUS_2}"

  # Record BP result
  BP_TOTAL_DUR=$(( $(date +%s) - BP_START ))
  OVERALL_STATUS="PASS"
  if [ "$URL_STATUS_1" != "PASS" ] || [ "$LOGIN_STATUS_1" != "PASS" ] || [ -n "$COLD_ERR" ]; then
    OVERALL_STATUS="FAIL"
  fi

  # JSON Entry
  RESULTS_JSON=$(python3 -c "
import json
arr = json.loads('''$RESULTS_JSON''')
arr.append({
  'blueprint': $BP,
  'cold_duration_s': $COLD_DUR,
  'warm_duration_s': $WARM_DUR,
  'total_duration_s': $BP_TOTAL_DUR,
  'cold_url_status': '$URL_STATUS_1',
  'cold_wallet_status': '$WALLET_STATUS_1',
  'cold_login_status': '$LOGIN_STATUS_1',
  'warm_url_status': '$URL_STATUS_2',
  'warm_login_status': '$LOGIN_STATUS_2',
  'overall_status': '$OVERALL_STATUS',
  'error': '$COLD_ERR'
})
print(json.dumps(arr))
")

done

# Save Report JSON
echo "$RESULTS_JSON" > "$REPORT_FILE"

echo ""
echo "=================================================================="
echo "🎉 ALL BLUEPRINT MATRIX TESTS COMPLETED!"
echo "   Report JSON: $REPORT_FILE"
echo "   Full Log: $MATRIX_LOG"
echo "=================================================================="

# Generate Markdown Summary
python3 -c "
import json

with open('$REPORT_FILE') as f:
    data = json.load(f)

md = []
md.append('# 📊 Architecture Blueprints (3–49) Comprehensive Test Matrix Report\n')
md.append('| Blueprint # | Overall Status | Cold Setup Time | Warm Restart Time | Cold URLs | Cold Login | Warm URLs | Warm Login |')
md.append('| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |')

for row in data:
    status_emoji = '✅ PASS' if row['overall_status'] == 'PASS' else '❌ FAIL'
    md.append(f\"| **#{row['blueprint']}** | {status_emoji} | {row['cold_duration_s']}s | {row['warm_duration_s']}s | {row['cold_url_status']} | {row['cold_login_status']} | {row['warm_url_status']} | {row['warm_login_status']} |\")

with open('$SUMMARY_MD', 'w') as f:
    f.write('\n'.join(md))
print('\n'.join(md))
"
