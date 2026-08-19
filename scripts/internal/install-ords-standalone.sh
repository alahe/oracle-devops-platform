#!/usr/bin/env bash
# ============================================================================
# Standalone Oracle REST Data Services (ORDS) Installation & Setup Script
# Works on any Linux Server (Oracle Linux / RHEL / Ubuntu) or Linux Container
# Logs detailed output to ./install_logs/ (ignored in Git).
# Writes benchmark metrics to ./metrics/ (tracked in Git).
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Load Central Repository Parameter File if present
CONFIG_FILE="$SCRIPT_DIR/../config/repository.env"
if [ -f "$CONFIG_FILE" ]; then
  echo "Loading repository configuration from $CONFIG_FILE"
  set -a
  source "$CONFIG_FILE"
  set +a
elif [ -f ".env" ]; then
  set -a
  source ".env"
  set +a
fi

# 1. Lokaalsed paigalduse logid (ei lähe Git-i)
LOG_DIR="$SCRIPT_DIR/../install_logs"
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$LOG_DIR/ords_install_${TIMESTAMP}.log"

# Suuname kogu väljundi nii ekraanile kui lokaalsesse logifaili
exec > >(tee -a "$LOG_FILE") 2>&1

# 2. Git-is jälgitav metrics kataloog
METRICS_DIR="$SCRIPT_DIR/../metrics"
mkdir -p "$METRICS_DIR"
JSON_BENCHMARK="$METRICS_DIR/ords_setup_benchmarks.json"

START_ORDS_TOTAL=$(date +%s)

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

echo "=================================================================="
echo "1. Oracle REST Data Services (ORDS) Standalone Setup"
echo "📝 Lokaalne logi: $LOG_FILE"
echo "📊 Git mõõdikud:   $JSON_BENCHMARK"
echo "=================================================================="

# Configuration Parameters from active profile & .env
DB_HOST="${DB_HOST:-${RESOLVED_ORDS_HOST:-localhost}}"
DB_PORT="${DB_PORT:-${PROFILE_CONTAINER_PORT:-1521}}"
DB_SERVICE="${DB_SERVICE:-${PROFILE_DEFAULT_SERVICE:-FREEPDB1}}"
SYS_PASSWORD="${SYS_PASSWORD:-${APEX_DB_SYS_PASSWORD:-OrdsSys#2026}}"
LISTENER_PASSWORD="${LISTENER_PASSWORD:-${APEX_LISTENER_PASSWORD:-OrdsListener#2026}}"

# Configurable Software Source URL (Default OTN or Internal Artifactory Repository)
ORDS_URL="${ORDS_URL:-https://download.oracle.com/otn_software/java/ords/ords-latest.zip}"
ARTIFACTORY_AUTH="${ARTIFACTORY_AUTH:-}" # e.g. "user:password" or Bearer token header

ORDS_CONFIG_DIR="${ORDS_CONFIG_DIR:-/etc/ords/config}"
ORDS_STATIC_IMAGES_DIR="${ORDS_STATIC_IMAGES_DIR:-/opt/ords/apex/images}"
ORDS_HTTP_PORT="${ORDS_HTTP_PORT:-8080}"

echo "Target Database: ${DB_HOST}:${DB_PORT}/${DB_SERVICE}"
echo "ORDS Source URL: ${ORDS_URL}"
echo "ORDS Config Directory: ${ORDS_CONFIG_DIR}"
echo "ORDS HTTP Port: ${ORDS_HTTP_PORT}"

# 2. Check Java Installation
OSTEP1_START=$(date +%s)
if ! command -v java &> /dev/null; then
  echo "Java runtime not found. Installing OpenJDK 17..."
  if command -v dnf &> /dev/null; then
    dnf install -y java-17-openjdk-headless zip unzip wget
  elif command -v apt-get &> /dev/null; then
    apt-get update && apt-get install -y openjdk-17-jre-headless zip unzip wget
  else
    echo "❌ Unknown package manager. Please install Java 17+ manually."
    exit 1
  fi
fi
OSTEP1_SECS=$(( $(date +%s) - OSTEP1_START ))

# 3. Check / Install ORDS Binary
OSTEP2_START=$(date +%s)
if ! command -v ords &> /dev/null; then
  echo "Installing ORDS CLI binaries from $ORDS_URL..."
  mkdir -p /opt/ords
  LOCAL_BIN_ZIP=$(ls -1 "$SCRIPT_DIR/../../binaries/ords"/*.zip 2>/dev/null | head -n 1 || echo "")
  if [ -n "$LOCAL_BIN_ZIP" ] && [ -f "$LOCAL_BIN_ZIP" ]; then
    echo "Using existing ORDS binary from binaries/ords: $LOCAL_BIN_ZIP"
    cp "$LOCAL_BIN_ZIP" /opt/ords/ords-latest.zip
  elif [ ! -f "/opt/ords/ords-latest.zip" ]; then
    if [ -n "$ARTIFACTORY_AUTH" ]; then
      curl -s -u "$ARTIFACTORY_AUTH" -L -o /opt/ords/ords-latest.zip "$ORDS_URL"
    else
      curl -s -L -o /opt/ords/ords-latest.zip "$ORDS_URL"
    fi
  fi
  unzip -q -o /opt/ords/ords-latest.zip -d /opt/ords/
  ln -sf /opt/ords/bin/ords /usr/local/bin/ords
fi
OSTEP2_SECS=$(( $(date +%s) - OSTEP2_START ))

echo "ORDS Binary Version:"
ords --version || true

# 4. Prepare Configuration Directories
mkdir -p "$ORDS_CONFIG_DIR"
mkdir -p "$ORDS_STATIC_IMAGES_DIR"

# 5. Run ORDS Non-Interactive Silent Installation
OSTEP3_START=$(date +%s)
echo "=================================================================="
echo "5. Running ORDS Installation & Schema Provisioning in Database..."
echo "=================================================================="

export SYS_PASSWORD="${SYS_PASSWORD}"
export LISTENER_PASSWORD="${LISTENER_PASSWORD}"

ords --config "$ORDS_CONFIG_DIR" install \
  --admin-user SYS \
  --db-hostname "$DB_HOST" \
  --db-port "$DB_PORT" \
  --db-servicename "$DB_SERVICE" \
  --feature-db-api true \
  --feature-rest-enabled-sql true \
  --feature-sdw true \
  --password-stdin << EOF 2>/dev/null || true
$SYS_PASSWORD
$LISTENER_PASSWORD
$LISTENER_PASSWORD
$LISTENER_PASSWORD
$LISTENER_PASSWORD
EOF

# Direct configuration fallback for ORDS Standalone pool.xml
ords --config "$ORDS_CONFIG_DIR" config set db.hostname "$DB_HOST" || true
ords --config "$ORDS_CONFIG_DIR" config set db.port "$DB_PORT" || true
ords --config "$ORDS_CONFIG_DIR" config set db.servicename "$DB_SERVICE" || true
ords --config "$ORDS_CONFIG_DIR" config set db.username "ORDS_PUBLIC_USER" || true
ords --config "$ORDS_CONFIG_DIR" config set db.password "$LISTENER_PASSWORD" || true

OSTEP3_SECS=$(( $(date +%s) - OSTEP3_START ))

# 6. Configure ORDS Standalone HTTP Settings
ords --config "$ORDS_CONFIG_DIR" config set standalone.http.port "$ORDS_HTTP_PORT"
ords --config "$ORDS_CONFIG_DIR" config set standalone.static.context.path /i
ords --config "$ORDS_CONFIG_DIR" config set standalone.static.path "$ORDS_STATIC_IMAGES_DIR"

ORDS_TOTAL_SECS=$(( $(date +%s) - START_ORDS_TOTAL ))
ORDS_TOTAL_TIME=$(format_duration $ORDS_TOTAL_SECS)

# Define timestamped JSON file name
JSON_TS_ORDS="$METRICS_DIR/ords_setup_benchmarks_${TIMESTAMP}.json"

cat << EOF > "$JSON_TS_ORDS"
{
  "last_updated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "total_duration_seconds": $ORDS_TOTAL_SECS,
  "total_duration_formatted": "$ORDS_TOTAL_TIME",
  "steps": {
    "java_check_seconds": $OSTEP1_SECS,
    "ords_binary_install_seconds": $OSTEP2_SECS,
    "ords_schema_provisioning_seconds": $OSTEP3_SECS
  }
}
EOF

# Copy the latest to ords_setup_benchmarks.json
cp "$JSON_TS_ORDS" "$JSON_BENCHMARK"

# Keep only the last 10 ORDS setup benchmark runs in metrics/
(cd "$METRICS_DIR" && ls -t ords_setup_benchmarks_*.json 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null || true)

echo "=================================================================="
echo "⏱   ORDS PAIGALDUSE KESTUS: $ORDS_TOTAL_TIME ($ORDS_TOTAL_SECSs)"
echo "📊 Mõõdikud salvestati Git-i: $JSON_BENCHMARK"
echo "📝 Logifail salvestati:       $LOG_FILE"
echo "✅ ORDS Standalone Setup Completed Successfully!"
echo "=================================================================="
