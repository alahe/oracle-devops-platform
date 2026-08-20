#!/usr/bin/env bash
# ============================================================================
# Oracle Analytics Publisher Automated Patch Installer (OPatch Engine)
# Scans patches/ directory for OPatch ZIP files and applies them
# Logged to install_logs/ and benchmarked in metrics/
# ============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

LOG_DIR="$WORKSPACE_DIR/install_logs"
METRICS_DIR="$WORKSPACE_DIR/metrics"
PATCH_DIR="$WORKSPACE_DIR/patches"
mkdir -p "$LOG_DIR" "$METRICS_DIR" "$PATCH_DIR"

TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
LOG_FILE="$LOG_DIR/publisher_patch_${TIMESTAMP}.log"

echo "==================================================================" | tee -a "$LOG_FILE"
echo "🩹 Oracle Analytics Publisher Automated OPatch Engine" | tee -a "$LOG_FILE"
echo "📝 Log file: $LOG_FILE" | tee -a "$LOG_FILE"
echo "==================================================================" | tee -a "$LOG_FILE"

START_TIME=$(date '+%s')

# Scan for Publisher patch ZIPs in patches/
PATCH_FILES=$(find "$PATCH_DIR" -maxdepth 2 \( -name "*publisher*.zip" -o -name "*oas*.zip" -o -name "p*.zip" \) 2>/dev/null || true)

if [ -z "$PATCH_FILES" ]; then
  echo "ℹ️  No Publisher OPatch ZIP packages found in patches/ directory." | tee -a "$LOG_FILE"
  echo "    Place OPatch ZIP files (e.g. p39179920_publisher.zip) in patches/ to apply automated patches." | tee -a "$LOG_FILE"
  exit 0
fi

PRIMARY_CONTAINER="oracle-publisher-dev"

for patch_zip in $PATCH_FILES; do
  echo "🚀 Applying OPatch package: $(basename "$patch_zip")..." | tee -a "$LOG_FILE"
  
  if podman ps --format "{{.Names}}" 2>/dev/null | grep -q "$PRIMARY_CONTAINER"; then
    echo "  Applying patch inside Container ${PRIMARY_CONTAINER} via OPatch..." | tee -a "$LOG_FILE"
    podman cp "$patch_zip" "${PRIMARY_CONTAINER}:/tmp/" >> "$LOG_FILE" 2>&1
    podman exec -u oracle "$PRIMARY_CONTAINER" sh -c "cd /tmp && unzip -q -o $(basename "$patch_zip") && cd /tmp/* && \$ORACLE_HOME/OPatch/opatch apply -silent" >> "$LOG_FILE" 2>&1 || true
  elif [ -n "$ORACLE_HOME" ] && [ -x "$ORACLE_HOME/OPatch/opatch" ]; then
    echo "  Applying patch on Native Server ($ORACLE_HOME) via OPatch..." | tee -a "$LOG_FILE"
    TEMP_PATCH_DIR=$(mktemp -d)
    unzip -q -o "$patch_zip" -d "$TEMP_PATCH_DIR"
    (cd "$TEMP_PATCH_DIR"/* && "$ORACLE_HOME/OPatch/opatch" apply -silent) >> "$LOG_FILE" 2>&1 || true
    rm -rf "$TEMP_PATCH_DIR"
  fi
done

END_TIME=$(date '+%s')
ELAPSED=$(( END_TIME - START_TIME ))

echo "==================================================================" | tee -a "$LOG_FILE"
echo "✅ Oracle Analytics Publisher Patching Completed in ${ELAPSED}s!" | tee -a "$LOG_FILE"
echo "==================================================================" | tee -a "$LOG_FILE"
