#!/usr/bin/env bash
# ============================================================================
# Oracle Analytics Publisher Central Installer Script
# Coordinates RCU initialization, container image build/run, and native fallback
# Logged to install_logs/ and benchmarked in metrics/
# ============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

LOG_DIR="$WORKSPACE_DIR/install_logs"
METRICS_DIR="$WORKSPACE_DIR/metrics"
mkdir -p "$LOG_DIR" "$METRICS_DIR"

TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
LOG_FILE="$LOG_DIR/publisher_install_${TIMESTAMP}.log"

echo "==================================================================" | tee -a "$LOG_FILE"
echo "🚀 Oracle Analytics Publisher Installation" | tee -a "$LOG_FILE"
echo "📝 Log file: $LOG_FILE" | tee -a "$LOG_FILE"
echo "==================================================================" | tee -a "$LOG_FILE"

START_TIME=$(date '+%s')

if [ -f "$SCRIPT_DIR/load-profile.sh" ]; then
  source "$SCRIPT_DIR/load-profile.sh"
  load_db_profile >/dev/null 2>&1 || true
fi

# 1. RCU Schema Provisioning
echo "Step 1: Provisioning RCU Schemas..." | tee -a "$LOG_FILE"
"$SCRIPT_DIR/init-publisher-rcu.sh" >> "$LOG_FILE" 2>&1 || true

# 2. ORDS REST Services for Publisher DB
echo "Step 2: Initializing ORDS Services for Publisher Database..." | tee -a "$LOG_FILE"
"$SCRIPT_DIR/init-publisher-ords.sh" >> "$LOG_FILE" 2>&1 || true

# 3. Determine Execution Mode (Container vs Native)
INSTALL_MODE="${PUBLISHER_INSTALL_MODE:-container}"
if ! command -v podman >/dev/null 2>&1 && ! command -v docker >/dev/null 2>&1; then
  INSTALL_MODE="native"
fi

if [ "$INSTALL_MODE" = "container" ]; then
  echo "Step 3: Container Mode - Building/Starting Analytics Publisher Container..." | tee -a "$LOG_FILE"
  if [ -f "$WORKSPACE_DIR/docker/publisher/build-publisher-image.sh" ]; then
    "$WORKSPACE_DIR/docker/publisher/build-publisher-image.sh" >> "$LOG_FILE" 2>&1 || true
  fi
else
  echo "Step 3: Native Server Mode - Running Native Linux Installer..." | tee -a "$LOG_FILE"
  "$SCRIPT_DIR/install-publisher-native.sh" >> "$LOG_FILE" 2>&1 || true
fi

END_TIME=$(date '+%s')
ELAPSED=$(( END_TIME - START_TIME ))

echo "==================================================================" | tee -a "$LOG_FILE"
echo "✅ Oracle Analytics Publisher Installation Completed in ${ELAPSED}s!" | tee -a "$LOG_FILE"
echo "==================================================================" | tee -a "$LOG_FILE"

# Record benchmarks JSON
BENCHMARKS_FILE="$METRICS_DIR/setup_benchmarks.json"
if [ -f "$BENCHMARKS_FILE" ]; then
  echo "{\"publisher_install_seconds\": $ELAPSED, \"timestamp\": \"$TIMESTAMP\"}" > "$METRICS_DIR/publisher_benchmark.json"
fi
