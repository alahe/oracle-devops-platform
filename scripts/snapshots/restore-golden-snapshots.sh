#!/usr/bin/env bash
# ============================================================================
# Oracle Free DB in Prod — APEX Proxy DB Volume Restore Script (High-Speed)
# Peatab konteinerid, puhastab volume ja taastab selle varukoopiast (.tar.gz).
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

# Vali hetktõmmise (Golden Snapshot) fail (vaikimisi latest või interaktiivne valik)
FORCE=false
NO_ROTATE=false
BACKUP_FILE_NAME=""

for arg in "$@"; do
  if [ "$arg" = "--force" ] || [ "$arg" = "-y" ]; then
    FORCE=true
  elif [ "$arg" = "--no-rotate" ]; then
    NO_ROTATE=true
  else
    BACKUP_FILE_NAME="$arg"
  fi
done

if [ -z "$BACKUP_FILE_NAME" ] && [ "$FORCE" = "false" ]; then
  if [ ! -d "$BACKUP_DIR" ]; then
    echo "❌ Viga: Hetktõmmiste kataloogi $BACKUP_DIR ei ole olemas!"
    exit 1
  fi

  BACKUP_FILES=()
  while IFS= read -r line; do
    if [ -n "$line" ]; then
      BACKUP_FILES+=("$line")
    fi
  done < <(cd "$BACKUP_DIR" && ls -t apex_proxy_oradata_*.tar.gz 2>/dev/null || true)

  NUM_FILES=${#BACKUP_FILES[@]}

  if [ $NUM_FILES -eq 0 ]; then
    if [ -f "$BACKUP_DIR/apex_proxy_oradata_latest.tar.gz" ]; then
      BACKUP_FILE_NAME="apex_proxy_oradata_latest.tar.gz"
    else
      echo "❌ Viga: Ühtegi hetktõmmist (.tar.gz) ei leitud kaustast $BACKUP_DIR!"
      exit 1
    fi
  else
    echo -e "${CYAN}==================================================================${NC}"
    echo -e "📊 SAADAOLEVAD HETKTÕMMISED kaustas golden-snapshots/ (uusim eespool):"
    for i in "${!BACKUP_FILES[@]}"; do
      f="${BACKUP_FILES[$i]}"
      sz=$(du -sh "$BACKUP_DIR/$f" | awk '{print $1}')
      dt=$(date -r "$BACKUP_DIR/$f" +"%Y-%m-%d %H:%M:%S" 2>/dev/null || stat -c "%y" "$BACKUP_DIR/$f" 2>/dev/null | cut -d'.' -f1 || echo "")
      echo -e "   [${CYAN}$((i+1))${NC}] ${CYAN}$f${NC} (Suurus: ${YELLOW}$sz${NC}, loodud: ${YELLOW}$dt${NC})"
    done

    DEFAULT_FILE="${BACKUP_FILES[0]}"
    echo -e "${CYAN}==================================================================${NC}"
    echo -e "${GREEN}👉 Vaikimisi valik [1]: $DEFAULT_FILE (vajuta Enter)${NC}"
    read -p "$(echo -e "${YELLOW}❓ Vali number või sisesta faili nimi: ${NC}")" USER_CHOICE

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

# Kui faili tee ei sisalda kataloogi, eeldame, et see asub $BACKUP_DIR kaustas
if [[ "$BACKUP_FILE_NAME" != /* ]]; then
  BACKUP_FILE="$BACKUP_DIR/$BACKUP_FILE_NAME"
else
  BACKUP_FILE="$BACKUP_FILE_NAME"
fi

if [ ! -f "$BACKUP_FILE" ]; then
  echo "❌ Viga: Hetktõmmise faili ei leitud: $BACKUP_FILE"
  exit 1
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
echo -e "${YELLOW}🚀 Oracle APEX Proxy DB Volume Golden Snapshot Taastamine${NC}"
echo -e "📂 Lähtehetktõmmis: ${CYAN}$BACKUP_FILE${NC}"
echo -e "   📊 $(msg_str "BENCHMARK_LABEL") ${YELLOW}$(get_restore_stats "1m 30s")${NC}"
echo -e "${CYAN}==================================================================${NC}"

LOG_DIR="$WORKSPACE_DIR/install_logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/snapshot_restore_${TIMESTAMP}.log"
exec > >(tee -a "$LOG_FILE") 2>&1

START_RESTORE=$(date +%s)

COMPOSE_ARGS=(-f "$COMPOSE_FILE")
[ -f "$WORKSPACE_DIR/podman-compose.override.yml" ] && COMPOSE_ARGS+=(-f "$WORKSPACE_DIR/podman-compose.override.yml")

echo "Peatan ja eemaldan teenused..."
podman-compose "${COMPOSE_ARGS[@]}" down >> "$LOG_FILE" 2>&1 || true

echo "Puhastan vana volumi $VOLUME_NAME..."
podman volume rm -f "$VOLUME_NAME" >> "$LOG_FILE" 2>&1 || true
podman volume create "$VOLUME_NAME" >> "$LOG_FILE" 2>&1

echo "Taastan andmed tihendatud hetktõmmisest volumisse $VOLUME_NAME..."

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
  print_progress "Taastan andmeid hetktõmmisest" "$ELAPSED" 20
done
wait $RESTORE_PID || true
clear_progress_line
echo ""

echo "Käivitan teenused taastatud andmetega..."
podman-compose "${COMPOSE_ARGS[@]}" up -d >> "$LOG_FILE" 2>&1

if [ "$NO_ROTATE" != "true" ] && [ -x "$WORKSPACE_DIR/scripts/rotate-password.sh" ]; then
  echo -e "${CYAN}🔄 Roteerin taastatud andmebaasi paroolid ja uuendan SEPS Walletit...${NC}"
  if [ -x "$WORKSPACE_DIR/scripts/internal/wait-db-healthy.sh" ]; then
    "$WORKSPACE_DIR/scripts/internal/wait-db-healthy.sh" "db-proxy" >> "$LOG_FILE" 2>&1 || true
  fi
  "$WORKSPACE_DIR/scripts/rotate-password.sh" all >> "$LOG_FILE" 2>&1 || true
  echo -e "${GREEN}✅ Paroolid edukalt roteeritud ja sünkroniseeritud.${NC}"
fi

DURATION_RESTORE=$(( $(date +%s) - START_RESTORE ))

METRICS_DIR="$WORKSPACE_DIR/metrics"
mkdir -p "$METRICS_DIR"
JSON_TS_RESTORE="$METRICS_DIR/restore_golden_snapshot_benchmarks_${TIMESTAMP}.json"

cat << EOF > "$JSON_TS_RESTORE"
{
  "last_updated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "restore_duration_seconds": $DURATION_RESTORE,
  "snapshot_file": "$(basename "$BACKUP_FILE")"
}
EOF

cp "$JSON_TS_RESTORE" "$METRICS_DIR/restore_golden_snapshot_benchmarks.json"
(cd "$METRICS_DIR" && ls -t restore_golden_snapshot_benchmarks_*.json 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null || true)

echo -e "${CYAN}==================================================================${NC}"
echo -e "${GREEN}✅ HETKTÕMMIS TAASTATUD: $(format_duration $DURATION_RESTORE)${NC}"
echo "------------------------------------------------------------------"
echo -e "📝 Logifail salvestati:        ${CYAN}$LOG_FILE${NC}"
echo -e "📊 Git mõõdikud salvestati:    ${CYAN}$METRICS_DIR/restore_golden_snapshot_benchmarks.json${NC}"
echo -e "${CYAN}==================================================================${NC}"
