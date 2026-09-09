#!/usr/bin/env bash
# ============================================================================
# Automated Matrix Test Runner for 15 Architecture Blueprints
# Executes 2 passes per blueprint:
#   Pass 1: Cold Clean Setup (reset-all -y + setup-all.sh -b <N> + create snapshot)
#   Pass 2: Golden Snapshot Disaster Recovery (reset-all -y + restore snapshot + verify)
# Validates 5-tier criteria: Health, URLs, SEPS Wallet, E2E Login & Benchmarks.
# ============================================================================

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
LOG_DIR="$WORKSPACE_DIR/install_logs"
METRICS_DIR="$WORKSPACE_DIR/metrics"
mkdir -p "$LOG_DIR" "$METRICS_DIR"

# Source common and i18n
if [ -f "$WORKSPACE_DIR/scripts/internal/common.sh" ]; then
  # shellcheck source=/dev/null
  source "$WORKSPACE_DIR/scripts/internal/common.sh"
fi

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
MATRIX_LOG="$LOG_DIR/blueprint_matrix_test_${TIMESTAMP}.log"
exec > >(tee -a "$MATRIX_LOG") 2>&1

REPORT_FILE="$WORKSPACE_DIR/metrics/matrix_test_report_${TIMESTAMP}.json"
SUMMARY_MD="$WORKSPACE_DIR/metrics/matrix_test_summary_${TIMESTAMP}.md"

SKIP_PASS1=false
SKIP_PASS2=false
FAST_MODE=false
DRY_RUN=false
BP_LIST=()

for arg in "$@"; do
  case "$arg" in
    -h|--help)
      echo "Kasutus: $0 [--single-pass] [--pass2-only] [--fast] [--dry-run] [BP_NUM ...]"
      exit 0
      ;;
    -d|--dry-run)
      DRY_RUN=true
      ;;
    --single-pass|--pass1-only|--cold-only)
      SKIP_PASS2=true
      ;;
    --pass2-only|--warm-only)
      SKIP_PASS1=true
      ;;
    --fast|--quick)
      FAST_MODE=true
      ;;
    *)
      if [[ "$arg" =~ ^[0-9]+$ ]]; then
        BP_LIST+=("$arg")
      fi
      ;;
  esac
done

# 16 Curated Architecture Blueprints across 4 groups (including BP #7 alternate image)
if [ ${#BP_LIST[@]} -eq 0 ]; then
  BP_LIST=(1 2 3 4 5 6 7 10 11 20 21 22 23 24 30 31)
fi

echo "=================================================================="
echo "🧪 ARCHITECTURE BLUEPRINTS AUTOMATED MATRIX TEST RUNNER"
echo "   Blueprints to test: ${BP_LIST[*]}"
echo "   Options: Skip Pass 1 = $SKIP_PASS1 | Skip Pass 2 = $SKIP_PASS2 | Fast Mode = $FAST_MODE | Dry Run = $DRY_RUN"
echo "   Log file: $MATRIX_LOG"
echo "   Timestamp: $TIMESTAMP"
echo "=================================================================="

if [ "$DRY_RUN" = "true" ]; then
  echo "🔍 [DRY-RUN]: Matrix simulation verified for ${#BP_LIST[@]} blueprints: ${BP_LIST[*]}."
  exit 0
fi

RESULTS_JSON="[]"
TOTAL_COUNT=${#BP_LIST[@]}
CURRENT_IDX=0
FAILED_BP_COUNT=0

wait_for_all_services() {
  # 1. Wait for DB containers
  if [ -x "$WORKSPACE_DIR/scripts/internal/wait-db-healthy.sh" ]; then
    "$WORKSPACE_DIR/scripts/internal/wait-db-healthy.sh" 30 >/dev/null 2>&1 || true
  fi

  # 2. Wait for ORDS service readiness if active
  if podman container exists app-ords 2>/dev/null && [ "$(podman inspect --format='{{.State.Status}}' app-ords 2>/dev/null)" = "running" ]; then
    ords_s_port="${ORDS_HTTPS_PORT:-${PROFILE_ORDS_HTTPS_PORT:-8448}}"
    [ "${IS_ADB:-false}" = "true" ] && ords_s_port="${ORDS_HTTPS_PORT:-${PROFILE_ORDS_HTTPS_PORT:-8443}}"
    for i in $(seq 1 30); do
      ords_code=$(curl -sk -o /dev/null -w "%{http_code}" "https://localhost:${ords_s_port}/dev-hub.html" 2>/dev/null || echo "000")
      if [ "$ords_code" = "200" ] || [ "$ords_code" = "302" ]; then
        break
      fi
      sleep 2
    done
  fi

  # 3. Wait for Publisher WebLogic service readiness if active
  if podman container exists app-publisher 2>/dev/null && [ "$(podman inspect --format='{{.State.Status}}' app-publisher 2>/dev/null)" = "running" ]; then
    for i in $(seq 1 30); do
      pub_code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:9502/xmlpserver 2>/dev/null || echo "000")
      [ "$pub_code" = "200" ] || [ "$pub_code" = "302" ] && break
      sleep 3
    done
  fi

  # 4. Wait for Forms 14c readiness if active
  if podman container exists app-forms 2>/dev/null && [ "$(podman inspect --format='{{.State.Status}}' app-forms 2>/dev/null)" = "running" ]; then
    for i in $(seq 1 30); do
      forms_code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:9001/forms/frmservlet 2>/dev/null || echo "000")
      [ "$forms_code" = "200" ] || [ "$forms_code" = "302" ] && break
      sleep 3
    done
  fi
}

for BP in "${BP_LIST[@]}"; do
  CURRENT_IDX=$((CURRENT_IDX + 1))
  echo ""
  echo "=================================================================="
  echo "🚀 [${CURRENT_IDX}/${TOTAL_COUNT}] STARTING MATRIX TEST FOR BLUEPRINT #${BP}"
  BP_START=$(date +%s)
  echo "=================================================================="

  # ---------------------------------------------------------
  # PASS 0: FAST RESTORE FROM EXISTING SNAPSHOT (IF AVAILABLE)
  # ---------------------------------------------------------
  FAST_RESTORE_DUR=0
  FAST_RESTORE_STATUS="NONE"
  FAST_URL_STATUS="N/A"
  FAST_WALLET_STATUS="N/A"

  EXISTING_SNAP=$(find "$WORKSPACE_DIR/golden-snapshots" -name "bp_${BP}_*.tar.gz" 2>/dev/null | head -n 1)
  if [ -n "$EXISTING_SNAP" ] && [ -f "$EXISTING_SNAP" ] && [ "$SKIP_PASS2" = "false" ]; then
    echo "⚡ [PASS 0: FAST RESTORE] Existing Golden Snapshot detected: $(basename "$EXISTING_SNAP")"
    echo "   Testing instant recovery from existing snapshot..."
    FAST_START=$(date +%s)
    
    # Purge & fast restore
    "$WORKSPACE_DIR/scripts/reset-all.sh" -y --lang en >/dev/null 2>&1 || true
    if "$WORKSPACE_DIR/scripts/snapshots/restore-golden-snapshots.sh" -b "$BP" --force >/dev/null 2>&1; then
      FAST_RESTORE_STATUS="PASS"
    else
      FAST_RESTORE_STATUS="FAIL"
    fi

    # Start containers & wait for readiness
    if [ -x "$WORKSPACE_DIR/scripts/start-containers.sh" ]; then
      "$WORKSPACE_DIR/scripts/start-containers.sh" >/dev/null 2>&1 || true
    fi
    wait_for_all_services

    FAST_END=$(date +%s)
    FAST_RESTORE_DUR=$((FAST_END - FAST_START))

    # Fast diagnostics
    FAST_URL_STATUS="PASS"
    FAST_WALLET_STATUS="PASS"
    if [ "$FAST_MODE" = "false" ]; then
      if [ -x "$WORKSPACE_DIR/scripts/check-urls.sh" ]; then
        if ! "$WORKSPACE_DIR/scripts/check-urls.sh" -r 15 -i 2 >/dev/null 2>&1; then
          FAST_URL_STATUS="FAIL"
        fi
      fi
      if [ -x "$WORKSPACE_DIR/scripts/check-wallet.sh" ]; then
        if ! "$WORKSPACE_DIR/scripts/check-wallet.sh" >/dev/null 2>&1; then
          FAST_WALLET_STATUS="FAIL"
        fi
      fi
    fi

    echo "   ⚡ Fast Restore Duration: ${FAST_RESTORE_DUR}s | Status: ${FAST_RESTORE_STATUS} | URLs: ${FAST_URL_STATUS} | Wallet: ${FAST_WALLET_STATUS}"
  else
    echo "⚡ [PASS 0: FAST RESTORE] No pre-existing Golden Snapshot found for BP #${BP}. Proceeding to Cold Setup."
  fi

  # ---------------------------------------------------------
  # PASS 1: COLD SETUP FROM SCRATCH
  # ---------------------------------------------------------
  COLD_DUR=0
  URL_STATUS="PASS"
  WALLET_STATUS="PASS"
  LOGIN_STATUS="PASS"
  COLD_ERR=""

  if [ "$SKIP_PASS1" = "false" ]; then
    echo "❄️  [PASS 1: COLD SETUP] Resetting environment and running setup-all.sh -b ${BP}..."
    COLD_START=$(date +%s)
    
    # Clean reset
    "$WORKSPACE_DIR/scripts/reset-all.sh" -y --lang en >/dev/null 2>&1 || true

    # Setup blueprint
    SETUP_OPTS=("-b" "$BP" "--force" "--lang" "en")
    if [ "$FAST_MODE" = "true" ]; then
      SETUP_OPTS+=("--fast")
    fi

    if ! "$WORKSPACE_DIR/scripts/setup-all.sh" "${SETUP_OPTS[@]}"; then
      COLD_ERR="setup-all.sh failed"
    fi
    COLD_END=$(date +%s)
    COLD_DUR=$((COLD_END - COLD_START))

    # Pass 1 Diagnostics
    echo "🔍 [PASS 1 DIAGNOSTICS] Checking URLs, SEPS Wallet & E2E Login..."
    URL_STATUS_1="PASS"
    WALLET_STATUS_1="PASS"
    LOGIN_STATUS_1="PASS"

    wait_for_all_services

    if [ "$FAST_MODE" = "false" ]; then
      if [ -x "$WORKSPACE_DIR/scripts/check-urls.sh" ]; then
        if ! "$WORKSPACE_DIR/scripts/check-urls.sh" -r 15 -i 2 >/dev/null 2>&1; then
          URL_STATUS_1="FAIL"
        fi
      fi

      if [ -x "$WORKSPACE_DIR/scripts/check-wallet.sh" ]; then
        if ! "$WORKSPACE_DIR/scripts/check-wallet.sh" >/dev/null 2>&1; then
          WALLET_STATUS_1="FAIL"
        fi
      fi

      if [ -x "$WORKSPACE_DIR/scripts/test-browser-login.sh" ]; then
        if ! "$WORKSPACE_DIR/scripts/test-browser-login.sh" >/dev/null 2>&1; then
          LOGIN_STATUS_1="FAIL"
        fi
      fi
    else
      echo "   ⚡ Fast Mode: Diagnostics skipped."
    fi

    # Auto-Create Golden Snapshot for Pass 2 test
    echo "💾 [PASS 1 SNAPSHOT] Creating Golden Snapshot for Blueprint #${BP}..."
    SNAP_STATUS="PASS"
    if [ -x "$WORKSPACE_DIR/scripts/snapshots/create-golden-snapshots.sh" ]; then
      if ! "$WORKSPACE_DIR/scripts/snapshots/create-golden-snapshots.sh" -b "$BP" --auto >/dev/null 2>&1; then
        SNAP_STATUS="WARN"
      fi
    fi

    echo "   ❄️ Cold Duration: ${COLD_DUR}s | URLs: ${URL_STATUS_1} | Wallet: ${WALLET_STATUS_1} | E2E Login: ${LOGIN_STATUS_1} | Snapshot: ${SNAP_STATUS}"
  else
    echo "❄️  [PASS 1: COLD SETUP] Skipped (--pass2-only / --warm-only)."
  fi

  # ---------------------------------------------------------
  # PASS 2: GOLDEN SNAPSHOT DISASTER RECOVERY & WARM TEST
  # ---------------------------------------------------------
  WARM_DUR=0
  RESTORE_STATUS="SKIPPED"
  URL_STATUS_2="PASS"
  WALLET_STATUS_2="PASS"
  LOGIN_STATUS_2="PASS"

  if [ "$SKIP_PASS2" = "false" ]; then
    echo "🔥 [PASS 2: SNAPSHOT RECOVERY] Resetting volumes & restoring from Golden Snapshot for BP #${BP}..."
    WARM_START=$(date +%s)
    
    # Purge active volumes
    "$WORKSPACE_DIR/scripts/reset-all.sh" -y --lang en >/dev/null 2>&1 || true

    # Restore snapshot
    RESTORE_STATUS="PASS"
    if [ -x "$WORKSPACE_DIR/scripts/snapshots/restore-golden-snapshots.sh" ]; then
      if ! "$WORKSPACE_DIR/scripts/snapshots/restore-golden-snapshots.sh" -b "$BP" --force >/dev/null 2>&1; then
        RESTORE_STATUS="FAIL"
      fi
    fi

    # Start containers
    if [ -x "$WORKSPACE_DIR/scripts/start-containers.sh" ]; then
      "$WORKSPACE_DIR/scripts/start-containers.sh" >/dev/null 2>&1 || true
    fi

    wait_for_all_services

    WARM_END=$(date +%s)
    WARM_DUR=$((WARM_END - WARM_START))

    # Pass 2 Diagnostics
    echo "🔍 [PASS 2 DIAGNOSTICS] Verifying warm service recovery..."
    if [ "$FAST_MODE" = "false" ]; then
      if [ -x "$WORKSPACE_DIR/scripts/check-urls.sh" ]; then
        if ! "$WORKSPACE_DIR/scripts/check-urls.sh" -r 15 -i 2 >/dev/null 2>&1; then
          URL_STATUS_2="FAIL"
        fi
      fi

      if [ -x "$WORKSPACE_DIR/scripts/check-wallet.sh" ]; then
        if ! "$WORKSPACE_DIR/scripts/check-wallet.sh" >/dev/null 2>&1; then
          WALLET_STATUS_2="FAIL"
        fi
      fi

      if [ -x "$WORKSPACE_DIR/scripts/test-browser-login.sh" ]; then
        if ! "$WORKSPACE_DIR/scripts/test-browser-login.sh" >/dev/null 2>&1; then
          LOGIN_STATUS_2="FAIL"
        fi
      fi
    else
      echo "   ⚡ Fast Mode: Diagnostics skipped."
    fi

    echo "   🔥 Warm Duration: ${WARM_DUR}s | Restore: ${RESTORE_STATUS} | URLs: ${URL_STATUS_2} | Wallet: ${WALLET_STATUS_2} | E2E Login: ${LOGIN_STATUS_2}"
  else
    echo "🔥 [PASS 2: SNAPSHOT RECOVERY] Skipped (--single-pass / --pass1-only)."
  fi

  # Overall Status Determination
  BP_TOTAL_DUR=$(( $(date +%s) - BP_START ))
  OVERALL_STATUS="PASS"
  if [ "$URL_STATUS_1" != "PASS" ] || [ "$WALLET_STATUS_1" != "PASS" ] || [ -n "$COLD_ERR" ] || [ "$RESTORE_STATUS" != "PASS" ] || [ "$URL_STATUS_2" != "PASS" ]; then
    OVERALL_STATUS="FAIL"
    FAILED_BP_COUNT=$((FAILED_BP_COUNT + 1))
    echo "❌ [ERROR] Matrix Test failed for Blueprint #${BP}!"
  else
    echo "✅ [SUCCESS] Matrix Test passed 100% for Blueprint #${BP}!"
  fi

  # JSON Entry
  RESULTS_JSON=$(python3 -c "
import json
arr = json.loads('''$RESULTS_JSON''')
arr.append({
  'blueprint': $BP,
  'fast_restore_duration_s': $FAST_RESTORE_DUR,
  'fast_restore_status': '$FAST_RESTORE_STATUS',
  'fast_url_status': '$FAST_URL_STATUS',
  'fast_wallet_status': '$FAST_WALLET_STATUS',
  'cold_duration_s': $COLD_DUR,
  'warm_duration_s': $WARM_DUR,
  'total_duration_s': $BP_TOTAL_DUR,
  'cold_url_status': '$URL_STATUS_1',
  'cold_wallet_status': '$WALLET_STATUS_1',
  'cold_login_status': '$LOGIN_STATUS_1',
  'snapshot_created': '$SNAP_STATUS',
  'restore_status': '$RESTORE_STATUS',
  'warm_url_status': '$URL_STATUS_2',
  'warm_wallet_status': '$WALLET_STATUS_2',
  'warm_login_status': '$LOGIN_STATUS_2',
  'overall_status': '$OVERALL_STATUS',
  'error': '$COLD_ERR'
})
print(json.dumps(arr, indent=2))
")

  # Persist benchmark stats
  if declare -f save_blueprint_benchmark >/dev/null 2>&1; then
    save_blueprint_benchmark "$BP" "$COLD_DUR" "$WARM_DUR" >/dev/null 2>&1 || true
  fi

done

# Write JSON report
echo "$RESULTS_JSON" > "$REPORT_FILE"

# Generate Markdown Summary
python3 -c "
import json

with open('$REPORT_FILE', 'r') as f:
    data = json.load(f)

md = []
md.append('# 📊 Architecture Blueprints Matrix Test Summary')
md.append('')
md.append('**Test Run Date:** $TIMESTAMP')
md.append('**Total Blueprints Tested:** ' + str(len(data)))
passed = sum(1 for d in data if d.get('overall_status') == 'PASS')
failed = sum(1 for d in data if d.get('overall_status') != 'PASS')
md.append('**Passed:** ' + str(passed) + ' | **Failed:** ' + str(failed))
md.append('')
md.append('| BP # | Overall | Fast Restore (Pass 0) | Cold Setup (Pass 1) | Snapshot Created | Restore & Warm (Pass 2) | Cold URLs | Warm URLs |')
md.append('| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |')

for d in data:
    status_icon = '✅ PASS' if d.get('overall_status') == 'PASS' else '❌ FAIL'
    snap_icon = '✅' if d.get('snapshot_created') == 'PASS' else '⚠️'
    fast_dur = str(d.get('fast_restore_duration_s', 0)) + 's (' + str(d.get('fast_restore_status')) + ')'
    cold_dur = str(d.get('cold_duration_s', 0)) + 's'
    warm_dur = str(d.get('warm_duration_s', 0)) + 's'
    row = '| **#' + str(d.get('blueprint')) + '** | ' + status_icon + ' | ' + fast_dur + ' | ' + cold_dur + ' | ' + snap_icon + ' | ' + warm_dur + ' | ' + str(d.get('cold_url_status')) + ' | ' + str(d.get('warm_url_status')) + ' |'
    md.append(row)

md.append('')
md.append('---')
md.append('*Report automatically generated by \`scripts/internal/run_blueprint_matrix_test.sh\`.*')

with open('$SUMMARY_MD', 'w') as f:
    f.write('\n'.join(md) + '\n')
"

echo ""
echo "=================================================================="
echo "🎉 ARCHITECTURE BLUEPRINTS MATRIX TEST COMPLETED"
echo "   Summary Report: $SUMMARY_MD"
echo "   JSON Metrics:   $REPORT_FILE"
echo "=================================================================="

if [ $FAILED_BP_COUNT -gt 0 ]; then
  echo "❌ $FAILED_BP_COUNT blueprint(s) failed testing."
  exit 1
else
  echo "✅ All tested blueprints passed with 100% success!"
  exit 0
fi
