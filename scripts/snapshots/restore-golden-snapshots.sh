#!/usr/bin/env bash
# ============================================================================
# Oracle Free DB in Prod — APEX Proxy DB Volume Restore Script (High-Speed)
# Stops containers, resets volumes, and restores from compressed backup (.tar.gz).
# Verifies .meta.json compatibility and invalidates mismatched versions.
# ============================================================================

set -e

# Silence podman compose warning logs about external providers
export PODMAN_COMPOSE_WARNING_LOGS=false

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
COMPOSE_FILE="$WORKSPACE_DIR/podman-compose.yml"

# Kaasame ühise abiteegi ja snapshot resolveri
if [ -f "$WORKSPACE_DIR/scripts/internal/common.sh" ]; then
  # shellcheck source=/dev/null
  source "$WORKSPACE_DIR/scripts/internal/common.sh"
fi
if [ -f "$WORKSPACE_DIR/scripts/internal/snapshot-resolver.sh" ]; then
  # shellcheck source=/dev/null
  source "$WORKSPACE_DIR/scripts/internal/snapshot-resolver.sh"
fi

PROJECT_NAME="oracle-free-db-in-prod"
PRIMARY_CONTAINER=$(get_active_db_instances 2>/dev/null | head -n 1 | cut -d'|' -f1)
PRIMARY_CONTAINER="${PRIMARY_CONTAINER:-db-proxy}"
PRIMARY_SHORT=$(echo "$PRIMARY_CONTAINER" | sed 's/^db-//' | tr '-' '_')
VOLUME_NAME="${PROJECT_NAME}_${PRIMARY_SHORT}_oradata"
if ! podman volume exists "$VOLUME_NAME" 2>/dev/null && podman volume exists "${PROJECT_NAME}_apex_proxy_oradata" 2>/dev/null; then
  VOLUME_NAME="${PROJECT_NAME}_apex_proxy_oradata"
fi
BACKUP_DIR="$WORKSPACE_DIR/golden-snapshots"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Parse CLI arguments
FORCE=false
NO_ROTATE=false
AUTO_MODE=false
TARGET_BP_ID="${BLUEPRINT_ID:-3}"
TARGET_PROFILE="${PROFILE_NAME:-db-proxy-oracle}"
BACKUP_FILE_NAME=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force|-y|--yes)
      FORCE=true
      shift
      ;;
    --auto)
      AUTO_MODE=true
      shift
      ;;
    --no-rotate)
      NO_ROTATE=true
      shift
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
    -*)
      shift
      ;;
    *)
      if [ -z "$BACKUP_FILE_NAME" ]; then
        BACKUP_FILE_NAME="$1"
      fi
      shift
      ;;
  esac
done

# If target blueprint is specified, synchronize .env and active profiles
if [ -n "$TARGET_BP_ID" ]; then
  bp_env_file=$(find "$WORKSPACE_DIR/config/blueprints" -name ".env.${TARGET_BP_ID}-*" 2>/dev/null | head -n 1)
  if [ -n "$bp_env_file" ] && [ -f "$bp_env_file" ]; then
    cp "$bp_env_file" "$WORKSPACE_DIR/.env"
    set -a
    source "$WORKSPACE_DIR/.env" 2>/dev/null || true
    set +a
  fi
fi

if [ -f "$WORKSPACE_DIR/scripts/internal/load-profile.sh" ]; then
  source "$WORKSPACE_DIR/scripts/internal/load-profile.sh"
  load_db_profile >/dev/null 2>&1 || true
fi

PRIMARY_CONTAINER=$(get_active_db_instances 2>/dev/null | head -n 1 | cut -d'|' -f1)
PRIMARY_CONTAINER="${PRIMARY_CONTAINER:-db-proxy}"
PRIMARY_SHORT=$(echo "$PRIMARY_CONTAINER" | sed 's/^db-//' | tr '-' '_')
VOLUME_NAME="${PROJECT_NAME}_${PRIMARY_SHORT}_oradata"
if ! podman volume exists "$VOLUME_NAME" 2>/dev/null && podman volume exists "${PROJECT_NAME}_apex_proxy_oradata" 2>/dev/null; then
  VOLUME_NAME="${PROJECT_NAME}_apex_proxy_oradata"
fi

# If in auto mode or no file specified, use snapshot-resolver
if [ -z "$BACKUP_FILE_NAME" ] && { [ "$AUTO_MODE" = "true" ] || [ "$FORCE" = "true" ]; }; then
  if declare -f find_best_golden_snapshot >/dev/null 2>&1; then
    RESOLVED_SNAP=$(find_best_golden_snapshot "$TARGET_BP_ID" "$TARGET_PROFILE" "$BACKUP_DIR" 2>/dev/null || true)
    if [ -n "$RESOLVED_SNAP" ] && [ -f "$RESOLVED_SNAP" ]; then
      BACKUP_FILE="$RESOLVED_SNAP"
      BACKUP_FILE_NAME="$(basename "$BACKUP_FILE")"
    fi
  fi
fi

if [ -z "$BACKUP_FILE_NAME" ] && [ "$FORCE" = "false" ]; then
  if [ ! -d "$BACKUP_DIR" ]; then
    echo "❌ Error: Snapshots directory $BACKUP_DIR does not exist!"
    exit 1
  fi

  BACKUP_FILES=()
  while IFS= read -r line; do
    if [ -n "$line" ]; then
      BACKUP_FILES+=("$line")
    fi
  done < <(cd "$BACKUP_DIR" && ls -t apex_proxy_oradata_*.tar.gz bp_*_*.tar.gz profile_*_*.tar.gz 2>/dev/null | sort -u || true)

  NUM_FILES=${#BACKUP_FILES[@]}

  if [ $NUM_FILES -eq 0 ]; then
    if [ -f "$BACKUP_DIR/apex_proxy_oradata_latest.tar.gz" ]; then
      BACKUP_FILE_NAME="apex_proxy_oradata_latest.tar.gz"
    else
      echo "❌ Error: No Golden Snapshots (.tar.gz) found in $BACKUP_DIR!"
      exit 1
    fi
  else
    echo -e "${CYAN}==================================================================${NC}"
    echo -e "📊 AVAILABLE GOLDEN SNAPSHOTS in golden-snapshots/ (newest first):"
    for i in "${!BACKUP_FILES[@]}"; do
      f="${BACKUP_FILES[$i]}"
      sz=$(du -sh "$BACKUP_DIR/$f" 2>/dev/null | awk '{print $1}')
      dt=$(date -r "$BACKUP_DIR/$f" +"%Y-%m-%d %H:%M:%S" 2>/dev/null || stat -c "%y" "$BACKUP_DIR/$f" 2>/dev/null | cut -d'.' -f1 || echo "")
      echo -e "   [${CYAN}$((i+1))${NC}] ${CYAN}$f${NC} (Size: ${YELLOW}$sz${NC}, created: ${YELLOW}$dt${NC})"
    done

    DEFAULT_FILE="${BACKUP_FILES[0]}"
    echo -e "${CYAN}==================================================================${NC}"
    echo -e "${GREEN}👉 Default choice [1]: $DEFAULT_FILE (press Enter)${NC}"
    read -p "$(echo -e "${YELLOW}❓ Select number or enter filename: ${NC}")" USER_CHOICE

    if [ -z "$USER_CHOICE" ]; then
      BACKUP_FILE_NAME="$DEFAULT_FILE"
    elif [[ "$USER_CHOICE" =~ ^[0-9]+$ ]] && [ "$USER_CHOICE" -le "$NUM_FILES" ] && [ "$USER_CHOICE" -gt 0 ]; then
      BACKUP_FILE_NAME="${BACKUP_FILES[$((USER_CHOICE-1))]}"
    else
      BACKUP_FILE_NAME="$USER_CHOICE"
    fi
  fi
elif [ -z "$BACKUP_FILE_NAME" ]; then
  BACKUP_FILE_NAME="apex_proxy_oradata_latest.tar.gz"
fi

# If path is relative, resolve from BACKUP_DIR
if [ -z "${BACKUP_FILE:-}" ]; then
  if [[ "$BACKUP_FILE_NAME" != /* ]]; then
    BACKUP_FILE="$BACKUP_DIR/$BACKUP_FILE_NAME"
  else
    BACKUP_FILE="$BACKUP_FILE_NAME"
  fi
fi

if [ ! -f "$BACKUP_FILE" ]; then
  echo "❌ Error: Snapshot file not found: $BACKUP_FILE"
  exit 1
fi

# AUTOMATED VERSION COMPATIBILITY VERIFICATION
if declare -f verify_snapshot_version_match >/dev/null 2>&1; then
  if ! verify_snapshot_version_match "$BACKUP_FILE" "${PROFILE_APEX_VERSION:-26.1}" "$TARGET_PROFILE"; then
    echo "❌ Snapshot version mismatch with target profile. Restore aborted."
    exit 2
  fi
fi

get_restore_stats() {
  local default_est="$1"
  local values=()
  local m_dir="$WORKSPACE_DIR/metrics"
  if [ -d "$m_dir" ]; then
    for f in "$m_dir"/restore_golden_snapshot_benchmarks_*.json; do
      if [ -f "$f" ]; then
        local val
        val=$(grep -m1 '"restore_duration_seconds":' "$f" | awk -F: '{print $2}' | tr -d ' ,"\r\n' || echo "")
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
  msg_str "BENCHMARK_AVG" "$(format_duration $avg)" "$(format_duration $min)" "$(format_duration $max)"
}

echo -e "${CYAN}==================================================================${NC}"
echo -e "${YELLOW}🚀 Oracle DB Volume Golden Snapshot Restore${NC}"
echo -e "📂 Source snapshot: ${CYAN}$BACKUP_FILE${NC}"
echo -e "   📊 $(msg_str "BENCHMARK_LABEL") ${YELLOW}$(get_restore_stats "15s")${NC}"
echo -e "${CYAN}==================================================================${NC}"

LOG_DIR="$WORKSPACE_DIR/install_logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/snapshot_restore_${TIMESTAMP}.log"
exec > >(tee -a "$LOG_FILE") 2>&1

START_RESTORE=$(date +%s)

COMPOSE_ARGS=(-f "$COMPOSE_FILE")
[ -f "$WORKSPACE_DIR/podman-compose.override.yml" ] && COMPOSE_ARGS+=(-f "$WORKSPACE_DIR/podman-compose.override.yml")

echo "Stopping and removing services..."
podman-compose "${COMPOSE_ARGS[@]}" down >> "$LOG_FILE" 2>&1 || true

echo "Purging old volume $VOLUME_NAME..."
podman volume rm -f "$VOLUME_NAME" >> "$LOG_FILE" 2>&1 || true
podman volume create "$VOLUME_NAME" >> "$LOG_FILE" 2>&1

echo "Restoring data from compressed golden snapshot into volume $VOLUME_NAME..."

podman run --rm --privileged --security-opt=no-new-privileges \
  -v "$VOLUME_NAME:/volume" \
  -v "$(dirname "$BACKUP_FILE"):/backup" \
  alpine sh -c "
    if apk add --no-cache pigz >/dev/null 2>&1; then
      pigz -dc /backup/$(basename "$BACKUP_FILE") | tar -xf - -C /volume
    else
      tar -xzf /backup/$(basename "$BACKUP_FILE") -C /volume
    fi
  " >> "$LOG_FILE" 2>&1 &
RESTORE_PID=$!

ELAPSED=0
while kill -0 $RESTORE_PID 2>/dev/null; do
  sleep 2
  ELAPSED=$((ELAPSED + 2))
  print_progress "Restoring data from snapshot" "$ELAPSED" 20
done
wait $RESTORE_PID || true
clear_progress_line
echo ""

echo "Starting services with restored data..."
if [ -x "$WORKSPACE_DIR/scripts/start-containers.sh" ]; then
  "$WORKSPACE_DIR/scripts/start-containers.sh" >> "$LOG_FILE" 2>&1 || true
else
  podman-compose "${COMPOSE_ARGS[@]}" up -d >> "$LOG_FILE" 2>&1
fi

if [ "$NO_ROTATE" != "true" ] && [ -x "$WORKSPACE_DIR/scripts/rotate-password.sh" ]; then
  echo -e "${CYAN}🔄 Rotating restored database passwords and updating SEPS Wallet...${NC}"
  if [ -x "$WORKSPACE_DIR/scripts/internal/wait-db-healthy.sh" ]; then
    "$WORKSPACE_DIR/scripts/internal/wait-db-healthy.sh" 120 >> "$LOG_FILE" 2>&1 || true
  fi
  "$WORKSPACE_DIR/scripts/rotate-password.sh" all >> "$LOG_FILE" 2>&1 || true
  echo -e "${GREEN}✅ Passwords successfully rotated and synchronized.${NC}"
fi

DURATION_RESTORE=$(( $(date +%s) - START_RESTORE ))

METRICS_DIR="$WORKSPACE_DIR/metrics"
mkdir -p "$METRICS_DIR"
JSON_TS_RESTORE="$METRICS_DIR/restore_golden_snapshot_benchmarks_${TIMESTAMP}.json"

cat << MEOF > "$JSON_TS_RESTORE"
{
  "last_updated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "restore_duration_seconds": $DURATION_RESTORE,
  "snapshot_file": "$(basename "$BACKUP_FILE")",
  "blueprint_id": "$TARGET_BP_ID",
  "profile_name": "$TARGET_PROFILE"
}
MEOF

cp "$JSON_TS_RESTORE" "$METRICS_DIR/restore_golden_snapshot_benchmarks.json"
(cd "$METRICS_DIR" && ls -t restore_golden_snapshot_benchmarks_*.json 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null || true)

echo -e "${CYAN}==================================================================${NC}"
echo -e "${GREEN}✅ GOLDEN SNAPSHOT RESTORED: $(format_duration $DURATION_RESTORE)${NC}"
echo "------------------------------------------------------------------"
echo -e "📝 Log file saved:            ${CYAN}$LOG_FILE${NC}"
echo -e "📊 Git benchmarks saved:      ${CYAN}$METRICS_DIR/restore_golden_snapshot_benchmarks.json${NC}"
echo -e "${CYAN}==================================================================${NC}"
