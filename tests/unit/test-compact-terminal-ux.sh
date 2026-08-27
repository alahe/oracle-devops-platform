#!/usr/bin/env bash
# ============================================================================
# Unit Test: test-compact-terminal-ux.sh
# Purpose: Verifies compact terminal UX, blueprint benchmarks, and live timers
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source common helpers
source "$WORKSPACE_DIR/scripts/internal/common.sh"

# Test 1: Bash syntax check
bash -n "$WORKSPACE_DIR/scripts/internal/common.sh"
bash -n "$WORKSPACE_DIR/scripts/internal/blueprint-info.sh"
bash -n "$WORKSPACE_DIR/scripts/setup-all.sh"
bash -n "$WORKSPACE_DIR/scripts/internal/install-apex.sh"
bash -n "$WORKSPACE_DIR/scripts/patches/apply-apex-patch.sh"

# Test 2: Test save_blueprint_benchmark & get_blueprint_stats in temp directory
mock_metrics_dir=$(mktemp -d)
trap 'rm -rf "$mock_metrics_dir"' EXIT

(
  export WORKSPACE_DIR="$mock_metrics_dir"
  mkdir -p "$mock_metrics_dir/metrics"

  # Save first run: 200s
  save_blueprint_benchmark 3 200

  # Save second run: 300s
  save_blueprint_benchmark 3 300

  stats=$(get_blueprint_stats 3)
  if [[ "$stats" != *"keskmine: 4m 10s"* ]] && [[ "$stats" != *"keskmine: 250s"* ]]; then
    echo "FAIL: Expected average 250s (4m 10s), got: '$stats'"
    exit 1
  fi

  if [[ "$stats" != *"min: 3m 20s"* ]] || [[ "$stats" != *"max: 5m 0s"* ]] || [[ "$stats" != *"mõõtmisi: 2"* ]]; then
    echo "FAIL: Expected min 3m 20s, max 5m 0s, count 2 in stats: '$stats'"
    exit 1
  fi
)

# Test 3: Test LIVE_TIMER_INTERVAL parameter handling
export LIVE_TIMER_INTERVAL=7
test_int=$(python3 -c "
int_val = '$LIVE_TIMER_INTERVAL'
int_val = ''.join(c for c in int_val if c.isdigit())
int_val = int(int_val) if int_val else 3
print(int_val)
")

if [ "$test_int" -ne 7 ]; then
  echo "FAIL: Expected LIVE_TIMER_INTERVAL=7, got $test_int"
  exit 1
fi

# Test 4: Test run_substep execution
substep_out=$(run_substep "1.1" "Test Substep" false "" 5 true)
if [[ "$substep_out" != *"Alamsamm 1.1"* ]] || [[ "$substep_out" != *"Valmis"* ]]; then
  echo "FAIL: run_substep failed: $substep_out"
  exit 1
fi

# Test 5: Test cursor routines
hide_cursor
restore_cursor

echo "test-compact-terminal-ux: PASS"
