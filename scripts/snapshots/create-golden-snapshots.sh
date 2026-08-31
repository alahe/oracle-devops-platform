#!/usr/bin/env bash
# ============================================================================
# Oracle Free DB in Prod — APEX Proxy DB Volume Backup Script (High-Speed)
# Peatab konteinerid ja loob andmebaasi volumist tihendatud varukoopia (.tar.gz).
# ============================================================================

set -e

# Vaigistame podman compose hoiatusteate välise teenusepakkuja kohta
export PODMAN_COMPOSE_WARNING_LOGS=false

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
COMPOSE_FILE="$WORKSPACE_DIR/podman-compose.yml"

# Kaasame ühise abiteegi
if [ -f "$WORKSPACE_DIR/scripts/internal/common.sh" ]; then
  source "$WORKSPACE_DIR/scripts/internal/common.sh"
fi

PROJECT_NAME="oracle-free-db-in-prod"
VOLUME_NAME="${PROJECT_NAME}_apex_proxy_oradata"
BACKUP_DIR="$WORKSPACE_DIR/golden-snapshots"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/apex_proxy_oradata_${TIMESTAMP}.tar.gz"
LATEST_BACKUP="$BACKUP_DIR/apex_proxy_oradata_latest.tar.gz"

mkdir -p "$BACKUP_DIR"

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
    echo "ootusaeg ~${default_est}"
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
echo -e "${YELLOW}🚀 Oracle APEX Proxy DB Volume Golden Snapshot${NC}"
echo -e "📂 Sihtkoht: ${CYAN}$BACKUP_FILE${NC}"
echo -e "   📊 $(msg_str "BENCHMARK_LABEL") ${YELLOW}$(get_backup_stats "2m")${NC}"
echo -e "${CYAN}==================================================================${NC}"

# 1. Logifaili seadistus (lokaalne, ei lähe Git-i)
LOG_DIR="$WORKSPACE_DIR/install_logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/snapshot_backup_${TIMESTAMP}.log"
exec > >(tee -a "$LOG_FILE") 2>&1

START_BACKUP=$(date +%s)

COMPOSE_ARGS=(-f "$COMPOSE_FILE")
[ -f "$WORKSPACE_DIR/podman-compose.override.yml" ] && COMPOSE_ARGS+=(-f "$WORKSPACE_DIR/podman-compose.override.yml")

echo "Peatan teenused hetktõmmise ajaks..."
podman-compose "${COMPOSE_ARGS[@]}" stop >> "$LOG_FILE" 2>&1 || true

echo "Loon tihendatud hetktõmmise (Golden Snapshot) volumist $VOLUME_NAME..."

# Käivitame Alpine konteineri taustal mitmelõimelise pigz toega
podman run --rm --privileged --security-opt=no-new-privileges \
  -v "$VOLUME_NAME:/volume:ro" \
  -v "$BACKUP_DIR:/backup" \
  alpine sh -c "
    if apk add --no-cache pigz >/dev/null 2>&1; then
      tar -cf - -C /volume . | pigz > /backup/apex_proxy_oradata_${TIMESTAMP}.tar.gz
    else
      tar -czf /backup/apex_proxy_oradata_${TIMESTAMP}.tar.gz -C /volume .
    fi
  " >> "$LOG_FILE" 2>&1 &
BACKUP_PID=$!

ELAPSED=0
while kill -0 $BACKUP_PID 2>/dev/null; do
  sleep 2
  ELAPSED=$((ELAPSED + 2))
  print_progress "Varundan Golden Snapshot hetktõmmist" "$ELAPSED" 20
done
wait $BACKUP_PID || true
clear_progress_line
echo ""

# Teeme koopia ka "latest" nimega lihtsaks taastamiseks
cp "$BACKUP_FILE" "$LATEST_BACKUP"

echo "Käivitan teenused uuesti..."
podman-compose "${COMPOSE_ARGS[@]}" start >> "$LOG_FILE" 2>&1 || true

DURATION_BACKUP=$(( $(date +%s) - START_BACKUP ))

# Rotatsioon: säilitame kaustas golden-snapshots/ vaid viimased 10 hetktõmmist
(cd "$BACKUP_DIR" && ls -t apex_proxy_oradata_*.tar.gz 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null || true)

# Salvestame mõõdikud metrics/ kataloogi
METRICS_DIR="$WORKSPACE_DIR/metrics"
mkdir -p "$METRICS_DIR"
JSON_TS_BACKUP="$METRICS_DIR/golden_snapshot_benchmarks_${TIMESTAMP}.json"

# Hetktõmmise faili suurus
FILE_SIZE_BYTES=$(wc -c < "$BACKUP_FILE" 2>/dev/null || echo "0")
FILE_SIZE_MB=$(( FILE_SIZE_BYTES / 1024 / 1024 ))

cat << EOF > "$JSON_TS_BACKUP"
{
  "last_updated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "snapshot_duration_seconds": $DURATION_BACKUP,
  "snapshot_size_mb": $FILE_SIZE_MB,
  "snapshot_file": "$(basename "$BACKUP_FILE")"
}
EOF

# Copy the latest to golden_snapshot_benchmarks.json
cp "$JSON_TS_BACKUP" "$METRICS_DIR/golden_snapshot_benchmarks.json"

# Keep only the last 10 benchmarks in metrics/
(cd "$METRICS_DIR" && ls -t golden_snapshot_benchmarks_*.json 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null || true)

echo -e "${CYAN}==================================================================${NC}"
echo -e "${GREEN}✅ HETKTÕMMIS (GOLDEN SNAPSHOT) VALMIS: $(format_duration $DURATION_BACKUP) (faili suurus: ${FILE_SIZE_MB}MB)${NC}"
echo "------------------------------------------------------------------"
echo -e "📝 Logifail salvestati:        ${CYAN}$LOG_FILE${NC}"
echo -e "📊 Git mõõdikud salvestati:    ${CYAN}$METRICS_DIR/golden_snapshot_benchmarks.json${NC}"
echo -e "${CYAN}==================================================================${NC}"
