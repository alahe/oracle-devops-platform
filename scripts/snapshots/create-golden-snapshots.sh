#!/usr/bin/env bash
# ============================================================================
# Oracle Free DB in Prod — APEX Proxy DB Volume Backup Script (High-Speed)
# Stops containers and creates compressed backup (.tar.gz) of database volumes.
# Generates .meta.json companion metadata for automated version verification.
# ============================================================================

set -e

# Silence podman compose warning logs about external providers
export PODMAN_COMPOSE_WARNING_LOGS=false

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
COMPOSE_FILE="$WORKSPACE_DIR/podman-compose.yml"

# Source common library and snapshot resolver
if [ -f "$WORKSPACE_DIR/scripts/internal/common.sh" ]; then
  # shellcheck source=/dev/null
  source "$WORKSPACE_DIR/scripts/internal/common.sh"
fi
if [ -f "$WORKSPACE_DIR/scripts/internal/load-profile.sh" ]; then
  # shellcheck source=/dev/null
  source "$WORKSPACE_DIR/scripts/internal/load-profile.sh"
fi
if [ -f "$WORKSPACE_DIR/scripts/internal/snapshot-resolver.sh" ]; then
  # shellcheck source=/dev/null
  source "$WORKSPACE_DIR/scripts/internal/snapshot-resolver.sh"
fi

PROJECT_NAME="oracle-free-db-in-prod"
BACKUP_DIR="$WORKSPACE_DIR/golden-snapshots"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
mkdir -p "$BACKUP_DIR"

# Parse CLI arguments
TARGET_BP_ID="${BLUEPRINT_ID:-0}"
TARGET_PROFILE="${PROFILE_NAME:-db-proxy-oracle}"
AUTO_MODE=false
CUSTOM_TAG=""
CUSTOM_DESC=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -n=*|--name=*|--tag=*|-t=*)
      CUSTOM_TAG="${1#*=}"
      shift
      ;;
    -n|--name|--tag|-t)
      CUSTOM_TAG="$2"
      shift 2
      ;;
    --desc=*|-d=*)
      CUSTOM_DESC="${1#*=}"
      shift
      ;;
    --desc|-d)
      CUSTOM_DESC="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: ./scripts/snapshots/create-golden-snapshots.sh [options]"
      echo ""
      echo "Options:"
      echo "  -n, --name, --tag <name>  Create a named custom snapshot without overwriting baseline (e.g. --name my-app)"
      echo "  -d, --desc <text>         Optional description for custom snapshot"
      echo "  -b, --blueprint <id>      Blueprint ID (default: active blueprint or 0)"
      echo "  -p, --profile <name>      Target database profile (default: active profile)"
      echo "  -f, --force               Force snapshot creation (skip 30-day age check)"
      echo "      --check-age           Create snapshot only if existing snapshot is >30 days old or missing"
      echo "  -y, --auto                Non-interactive automated mode"
      echo "  -h, --help                Show this help message"
      exit 0
      ;;
    -b=*|--blueprint=*)
      TARGET_BP_ID="${1#*=}"
      shift
      ;;
    -b|--blueprint)
      TARGET_BP_ID="$2"
      shift 2
      ;;
    -p=*|--profile=*)
      TARGET_PROFILE="${1#*=}"
      shift
      ;;
    -p|--profile)
      TARGET_PROFILE="$2"
      shift 2
      ;;
    --auto|-y|--yes)
      AUTO_MODE=true
      shift
      ;;
    --check-age|--if-expired)
      CHECK_AGE=true
      shift
      ;;
    --force|-f)
      FORCE_CREATE=true
      shift
      ;;
    --max-age=*|--max-days=*)
      MAX_AGE_DAYS="${1#*=}"
      shift
      ;;
    --max-age|--max-days)
      MAX_AGE_DAYS="$2"
      shift 2
      ;;
    -l=*|--lang=*|-language=*|--language=*)
      export CLI_LANG="${1#*=}"
      if declare -f resolve_cli_lang >/dev/null 2>&1; then
        export ACTIVE_CLI_LANG="$(resolve_cli_lang)"
      fi
      shift
      ;;
    -l|--lang|-language|--language)
      export CLI_LANG="$2"
      if declare -f resolve_cli_lang >/dev/null 2>&1; then
        export ACTIVE_CLI_LANG="$(resolve_cli_lang)"
      fi
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

BP_FILE=$(find "$WORKSPACE_DIR/config/blueprints" -maxdepth 1 -name ".env.${TARGET_BP_ID}-*" 2>/dev/null | head -n 1)
[ -z "$BP_FILE" ] && BP_FILE=$(find "$WORKSPACE_DIR/config/blueprints" -maxdepth 1 -name ".env.${TARGET_BP_ID}" 2>/dev/null | head -n 1)
if [ -f "$BP_FILE" ]; then
  set -a
  source "$BP_FILE"
  set +a
fi

# Check if snapshot is already fresh (< 30 days) when --check-age is requested without --force
if [ "${CHECK_AGE:-false}" = "true" ] && [ "${FORCE_CREATE:-false}" != "true" ]; then
  if declare -f should_create_golden_snapshot >/dev/null 2>&1; then
    if ! should_create_golden_snapshot "$TARGET_BP_ID" "$TARGET_PROFILE" "${MAX_AGE_DAYS:-30}"; then
      if [ "${EVALUATED_SNAPSHOT_ACTION:-}" = "skip_fresh" ]; then
        msg_print "SNAPSHOT_FRESH_SKIP" "$TARGET_PROFILE" "${EVALUATED_SNAPSHOT_AGE_DAYS:-0}" "${MAX_AGE_DAYS:-30}"
      else
        echo -e "   ✅ $(msg_str "SNAPSHOT_FASTPATH_DETECTED" "$TARGET_PROFILE")"
      fi
      exit 0
    fi
  fi
fi

ACTIVE_DBS=$(get_active_db_instances 2>/dev/null || true)
if [ -z "$ACTIVE_DBS" ] || [ "${DB_ENABLED:-true}" = "false" ] || [ "${TARGET_PROFILE:-}" = "NONE" ]; then
  echo -e "   ℹ️  Zero local database instances configured for Blueprint ${TARGET_BP_ID} (${TARGET_PROFILE:-NONE}). Skipping database volume snapshot."
  exit 0
fi

PRIMARY_CONTAINER=$(echo "$ACTIVE_DBS" | head -n 1 | cut -d'|' -f1)
PRIMARY_SHORT=$(echo "$PRIMARY_CONTAINER" | sed 's/^db-//' | tr '-' '_')
VOLUME_NAME="${PROJECT_NAME}_${PRIMARY_SHORT}_oradata"
if podman container exists "$PRIMARY_CONTAINER" 2>/dev/null; then
  DETECTED_VOL=$(podman inspect "$PRIMARY_CONTAINER" --format '{{range .Mounts}}{{if eq .Destination "/opt/oracle/oradata"}}{{.Name}}{{end}}{{end}}' 2>/dev/null || true)
  if [ -n "$DETECTED_VOL" ]; then
    VOLUME_NAME="$DETECTED_VOL"
  fi
fi

if [ -n "$CUSTOM_TAG" ]; then
  CLEAN_TAG=$(echo "$CUSTOM_TAG" | tr -cs 'a-zA-Z0-9_-' '_' | tr '[:upper:]' '[:lower:]' | sed 's/^_*//;s/_*$//')
  BACKUP_FILE="$BACKUP_DIR/custom_bp${TARGET_BP_ID}_${CLEAN_TAG}_${TIMESTAMP}.tar.gz"
  LATEST_BACKUP=""
else
  BACKUP_FILE="$BACKUP_DIR/bp_${TARGET_BP_ID}_${TIMESTAMP}.tar.gz"
  LATEST_BACKUP="$BACKUP_DIR/bp_${TARGET_BP_ID}_latest.tar.gz"
fi

get_backup_stats() {
  local default_est="$1"
  local values=()
  local m_dir="$WORKSPACE_DIR/metrics"
  if [ -d "$m_dir" ]; then
    for f in "$m_dir"/golden_snapshot_benchmarks_*.json; do
      if [ -f "$f" ]; then
        local val
        val=$(grep -m1 '"snapshot_duration_seconds":' "$f" | awk -F: '{print $2}' | tr -d ' ,"\r\n' || echo "")
        if [[ "$val" =~ ^[0-9]+$ ]]; then
          values+=("$val")
        fi
      fi
    done
  fi
  local count=${#values[@]}
  if [ $count -eq 0 ]; then
    echo "estimated ~${default_est}"
    return 0
  fi
  local sum=0
  local min=${values[0]}
  local max=${values[0]}
  for val in "${values[@]}"; do
    sum=$((sum + val))
    if [ $val -lt $min ]; then min=$val; fi
    if [ $val -gt $max ]; then max=$val; fi
  done
  local avg=$((sum / count))
  msg_str "BENCHMARK_AVG" "$(format_duration $avg)"
}

echo -e "${CYAN}==================================================================${NC}"
echo -e "${YELLOW}🚀 Oracle DB Volume Golden Snapshot${NC}"
echo -e "📂 Target destination: ${CYAN}$BACKUP_FILE${NC}"
echo -e "   📊 $(msg_str "BENCHMARK_LABEL") ${YELLOW}$(get_backup_stats "25s")${NC}"
echo -e "${CYAN}==================================================================${NC}"

# 1. Setup local execution log
LOG_DIR="$WORKSPACE_DIR/install_logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/snapshot_create_bp_${TARGET_BP_ID:-0}_${TIMESTAMP}.log"
ln -sf "$LOG_FILE" "$LOG_DIR/snapshot_create_bp_${TARGET_BP_ID:-0}_latest.log" 2>/dev/null || true
exec > >(tee -a "$LOG_FILE") 2>&1

START_BACKUP=$(date +%s)

COMPOSE_ARGS=(-f "$COMPOSE_FILE")
[ -f "$WORKSPACE_DIR/podman-compose.override.yml" ] && COMPOSE_ARGS+=(-f "$WORKSPACE_DIR/podman-compose.override.yml")

echo "🔄 Performing clean SGA checkpoint (ALTER SYSTEM CHECKPOINT)..."
for c in $(podman ps --format '{{.Names}}' 2>/dev/null | grep '^db-' || true); do
  podman exec "$c" bash -c '
    in_sql=$(ls -d /opt/oracle/product/*/dbhomeFree/sqlcl/bin/sql 2>/dev/null | head -n 1)
    if [ -n "$in_sql" ]; then
      "$in_sql" -s / as sysdba << "SQLEOF" 2>/dev/null
ALTER SYSTEM CHECKPOINT;
EXIT;
SQLEOF
    fi' >/dev/null 2>&1 || true
done

echo "Stopping services for golden snapshot creation..."
podman-compose "${COMPOSE_ARGS[@]}" stop >> "$LOG_FILE" 2>&1 || true

echo "Creating compressed Golden Snapshot of volume $VOLUME_NAME..."

# Launch background Alpine container with multi-threaded pigz compression
podman run --rm --privileged --security-opt=no-new-privileges \
  -v "$VOLUME_NAME:/volume:ro" \
  -v "$BACKUP_DIR:/backup" \
  alpine sh -c "
    if command -v pigz >/dev/null 2>&1; then
      tar -cf - -C /volume . | pigz > \"/backup/$(basename "$BACKUP_FILE")\"
    else
      tar -czf \"/backup/$(basename "$BACKUP_FILE")\" -C /volume .
    fi
  " >> "$LOG_FILE" 2>&1 &
BACKUP_PID=$!

ELAPSED=0
while kill -0 $BACKUP_PID 2>/dev/null; do
  sleep 2
  ELAPSED=$((ELAPSED + 2))
  print_progress "Backing up Golden Snapshot volume" "$ELAPSED" 20
done
wait $BACKUP_PID || true
clear_progress_line
echo ""

if [ -n "$CUSTOM_TAG" ]; then
  # For custom snapshots, write metadata with type=custom, tag, and desc. Do NOT overwrite latest golden links.
  if declare -f write_snapshot_metadata >/dev/null 2>&1; then
    write_snapshot_metadata "$BACKUP_FILE" "$TARGET_BP_ID" "$TARGET_PROFILE" "${PROFILE_APEX_VERSION:-26.1}" "${PROFILE_CONTAINER_IMAGE:-}" "24.4.1" "NONE" "NONE" "${PROFILE_DEFAULT_SERVICE:-FREEPDB1}" "custom" "$CUSTOM_TAG" "$CUSTOM_DESC"
  fi
else
  # Create latest alias for standard recovery
  cp "$BACKUP_FILE" "$LATEST_BACKUP"

  # Create Blueprint and Profile specific links
  CLEAN_PROF=$(echo "$TARGET_PROFILE" | sed 's/\.yaml$//' | tr '/' '_')
  BP_SNAPSHOT="$BACKUP_DIR/bp_${TARGET_BP_ID}_latest.tar.gz"
  PROF_SNAPSHOT="$BACKUP_DIR/profile_${CLEAN_PROF}_latest.tar.gz"

  cp "$BACKUP_FILE" "$BP_SNAPSHOT"
  cp "$BACKUP_FILE" "$PROF_SNAPSHOT"

  # Write machine-readable metadata (.meta.json) for version verification
  if declare -f write_snapshot_metadata >/dev/null 2>&1; then
    write_snapshot_metadata "$BACKUP_FILE" "$TARGET_BP_ID" "$TARGET_PROFILE" "${PROFILE_APEX_VERSION:-26.1}" "${PROFILE_CONTAINER_IMAGE:-}"
    write_snapshot_metadata "$LATEST_BACKUP" "$TARGET_BP_ID" "$TARGET_PROFILE" "${PROFILE_APEX_VERSION:-26.1}" "${PROFILE_CONTAINER_IMAGE:-}"
    write_snapshot_metadata "$BP_SNAPSHOT" "$TARGET_BP_ID" "$TARGET_PROFILE" "${PROFILE_APEX_VERSION:-26.1}" "${PROFILE_CONTAINER_IMAGE:-}"
    write_snapshot_metadata "$PROF_SNAPSHOT" "$TARGET_BP_ID" "$TARGET_PROFILE" "${PROFILE_APEX_VERSION:-26.1}" "${PROFILE_CONTAINER_IMAGE:-}"
  fi
fi

echo "Restarting services..."
podman-compose "${COMPOSE_ARGS[@]}" start >> "$LOG_FILE" 2>&1 || true

DURATION_BACKUP=$(( $(date +%s) - START_BACKUP ))

# Rotation: keep only the last 10 snapshots in golden-snapshots/
(cd "$BACKUP_DIR" && ls -t apex_proxy_oradata_*.tar.gz 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null || true)

# Save benchmark metrics to metrics/ directory
METRICS_DIR="$WORKSPACE_DIR/metrics"
mkdir -p "$METRICS_DIR"
JSON_TS_BACKUP="$METRICS_DIR/golden_snapshot_benchmarks_${TIMESTAMP}.json"

# File size
FILE_SIZE_BYTES=$(wc -c < "$BACKUP_FILE" 2>/dev/null || echo "0")
FILE_SIZE_MB=$(( FILE_SIZE_BYTES / 1024 / 1024 ))

cat << MEOF > "$JSON_TS_BACKUP"
{
  "last_updated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "snapshot_duration_seconds": $DURATION_BACKUP,
  "snapshot_size_mb": $FILE_SIZE_MB,
  "snapshot_file": "$(basename "$BACKUP_FILE")",
  "blueprint_id": "$TARGET_BP_ID",
  "profile_name": "$TARGET_PROFILE",
  "apex_version": "${PROFILE_APEX_VERSION:-26.1}"
}
MEOF

# Copy the latest to golden_snapshot_benchmarks.json
cp "$JSON_TS_BACKUP" "$METRICS_DIR/golden_snapshot_benchmarks.json"

# Keep only the last 10 benchmarks in metrics/
(cd "$METRICS_DIR" && ls -t golden_snapshot_benchmarks_*.json 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null || true)

echo -e "${CYAN}==================================================================${NC}"
echo -e "${GREEN}✅ GOLDEN SNAPSHOT COMPLETED: $(format_duration $DURATION_BACKUP) (file size: ${FILE_SIZE_MB}MB)${NC}"
echo "------------------------------------------------------------------"
echo -e "📝 Log file saved:            ${CYAN}$LOG_FILE${NC}"
echo -e "📄 Metadata file:             ${CYAN}${BACKUP_FILE%.tar.gz}.meta.json${NC}"
echo -e "📊 Git benchmarks saved:      ${CYAN}$JSON_TS_BACKUP${NC}"
echo -e "${CYAN}==================================================================${NC}"
