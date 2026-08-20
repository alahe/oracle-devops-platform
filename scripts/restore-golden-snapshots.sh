#!/usr/bin/env bash
# ============================================================================
# Oracle Free DB in Prod — APEX Proxy DB Volume Restore Script
# Peatab konteinerid, puhastab volume ja taastab selle varukoopiast (.tar.gz).
# ============================================================================

set -e

# Vaigistame podman compose hoiatusteate välise teenusepakkuja kohta
export PODMAN_COMPOSE_WARNING_LOGS=false

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
COMPOSE_FILE="$SCRIPT_DIR/../podman-compose.yml"

# Värvide seadistamine (ainult siis kui terminal seda toetab)
if [ -t 0 ] || { [ -n "$TERM" ] && [ "$TERM" != "dumb" ]; }; then
  GREEN='\033[1;32m'
  YELLOW='\033[0;33m'
  ORANGE='\033[38;5;208m'
  CYAN='\033[1;36m'
  RED='\033[1;31m'
  NC='\033[0m'
else
  GREEN=''
  YELLOW=''
  ORANGE=''
  CYAN=''
  RED=''
  NC=''
fi

PROJECT_NAME="oracle-free-db-in-prod"
VOLUME_NAME="${PROJECT_NAME}_apex_proxy_oradata"
BACKUP_DIR="$SCRIPT_DIR/../golden-snapshots"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

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

# Vali hetktõmmise (Golden Snapshot) fail (vaikimisi latest või interaktiivne valik)
FORCE=false
BACKUP_FILE_NAME=""

for arg in "$@"; do
  if [ "$arg" = "--force" ] || [ "$arg" = "-y" ]; then
    FORCE=true
  else
    BACKUP_FILE_NAME="$arg"
  fi
done

if [ -z "$BACKUP_FILE_NAME" ] && [ "$FORCE" = "false" ]; then
  if [ ! -d "$BACKUP_DIR" ]; then
    echo "❌ Viga: Hetktõmmiste kataloogi $BACKUP_DIR ei ole olemas!"
    exit 1
  fi

  # Lugege failid massiivi viisil, mis ühildub ka Bash 3-ga (macOS vaikimisi bash)
  (cd "$BACKUP_DIR" && ls -t apex_proxy_oradata_*.tar.gz 2>/dev/null || true) | while IFS= read -r line; do
    if [ -n "$line" ]; then
      BACKUP_FILES+=("$line")
    fi
  done

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
fi

if [ -z "$BACKUP_FILE_NAME" ]; then
  BACKUP_FILE_NAME="apex_proxy_oradata_latest.tar.gz"
fi

BACKUP_FILE="$BACKUP_DIR/$BACKUP_FILE_NAME"

if [ ! -f "$BACKUP_FILE" ]; then
  echo "❌ Viga: Hetktõmmise faili '$BACKUP_FILE' ei leitud!"
  echo "   Saadaolevad hetktõmmised kaustas $BACKUP_DIR:"
  ls -la "$BACKUP_DIR" 2>/dev/null || echo "   (Kaust on tühi)"
  exit 1
fi

get_restore_stats() {
  local default_est="$1"
  local values=()
  local m_dir="$SCRIPT_DIR/../metrics"
  if [ -d "$m_dir" ]; then
    for f in "$m_dir"/restore_golden_snapshot_benchmarks_*.json; do
      if [ -f "$f" ]; then
        local val=$(grep -m1 '"restore_duration_seconds":' "$f" | awk -F: '{print $2}' | tr -d ' ,"\r\n' || echo "")
        if [[ "$val" =~ ^[0-9]+$ ]]; then
          values+=($val)
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
    if [ $val -lt $min ]; then
      min=$val
    fi
    if [ $val -gt $max ]; then
      max=$val
    fi
  done
  local avg=$((sum / count))
  echo "keskmine: $(format_duration $avg) (min: $(format_duration $min), max: $(format_duration $max))"
}

echo -e "${CYAN}==================================================================${NC}"
echo -e "${YELLOW}🚀 Oracle APEX Proxy DB Volume Golden Snapshot Restore${NC}"
echo -e "📂 Allikas: ${CYAN}$BACKUP_FILE${NC}"
echo -e "   📊 Ajalooline ooteaeg: ${YELLOW}$(get_restore_stats "1m")${NC}"
echo -e "${CYAN}==================================================================${NC}"

# 1. Logifaili seadistus (lokaalne, ei lähe Git-i)
LOG_DIR="$SCRIPT_DIR/../install_logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/restore_golden_snapshots_${TIMESTAMP}.log"
exec > >(tee -a "$LOG_FILE") 2>&1

START_RESTORE=$(date +%s)

if [ -f "$SCRIPT_DIR/internal/load-profile.sh" ]; then
  source "$SCRIPT_DIR/internal/load-profile.sh"
  load_db_profile >/dev/null 2>&1 || true
fi

PRIMARY_CONTAINER=$(get_active_db_instances 2>/dev/null | head -n 1 | cut -d'|' -f1)
PRIMARY_CONTAINER="${PRIMARY_CONTAINER:-db-dev-full}"

echo "Eemaldan praegused teenused ja konteinerid..."
podman-compose -f "$COMPOSE_FILE" down || true
for inst in $(get_active_db_instances 2>/dev/null); do
  c_inst=$(echo "$inst" | cut -d'|' -f1)
  podman stop "$c_inst" 2>/dev/null || true
  podman rm -f "$c_inst" 2>/dev/null || true
done
podman stop ords-dev oracle-ords-dev 2>/dev/null || true
podman rm -f ords-dev oracle-ords-dev 2>/dev/null || true

echo "Kustutan ja loon uue puhta volume: $VOLUME_NAME..."
podman volume rm -f "$VOLUME_NAME" 2>/dev/null || true
podman volume create "$VOLUME_NAME"

echo "Pakin lahti hetktõmmise volume andmetesse..."
# Käivitame Alpine konteineri taustal, et saaksime ooteaega dünaamiliselt kuvada
podman run --rm --privileged \
  -v "$VOLUME_NAME:/volume" \
  -v "$BACKUP_DIR:/backup" \
  alpine sh -c "cd /volume && tar xzf /backup/$(basename "$BACKUP_FILE")" &
RESTORE_PID=$!

ELAPSED=0
while kill -0 $RESTORE_PID 2>/dev/null; do
  sleep 3
  ELAPSED=$((ELAPSED + 3))
  echo -ne "   Taastan... kestus: ${ORANGE}$(format_duration $ELAPSED)${NC}\r"
done
wait $RESTORE_PID
echo ""

echo "Käivitan teenused taustal..."
podman-compose -f "$COMPOSE_FILE" --profile dev-ords up -d

CONTAINER_APEX_PROXY="$PRIMARY_CONTAINER"

echo "Ootan kuni andmebaas ($CONTAINER_APEX_PROXY) on valmis (healthy)..."
MAX_WAIT=300
WAIT_COUNT=0
until [ "$(podman inspect --format='{{.State.Health.Status}}' "$CONTAINER_APEX_PROXY" 2>/dev/null)" == "healthy" ]; do
  sleep 3
  WAIT_COUNT=$((WAIT_COUNT + 3))
  echo -ne "   Ooteaeg: ${ORANGE}$(format_duration $WAIT_COUNT)${NC} / max ${MAX_WAIT}s...\r"
  if [ $WAIT_COUNT -ge $MAX_WAIT ]; then
    echo ""
    echo "❌ Viga: Andmebaas ei saavutanud 'healthy' olekut $MAX_WAIT sekundi jooksul!"
    exit 1
  fi
done
echo ""

# Kontrollime kas APEX piltide volume on tühi (nt pärast reset-all käivitust)
IMAGES_VOLUME="${PROJECT_NAME}_apex_images"
IS_IMAGES_EMPTY=false
if ! podman volume exists "$IMAGES_VOLUME" 2>/dev/null; then
  IS_IMAGES_EMPTY=true
else
  # Kontrollime kas markerfail on olemas
  if ! podman exec "$CONTAINER_APEX_PROXY" [ -f "/opt/oracle/apex_images/.unzipped_source" ] 2>/dev/null; then
    IS_IMAGES_EMPTY=true
  fi
fi

if [ "$IS_IMAGES_EMPTY" = "true" ]; then
  echo "⚠️  APEX piltide volume on tühi (nt pärast reset-all käivitust)."
  APEX_ZIP="$SCRIPT_DIR/../binaries/apex-latest.zip"
  if [ -f "$APEX_ZIP" ]; then
    echo "📦 Taastan APEX staatilised pildid failist $(basename "$APEX_ZIP")..."
    podman exec "$CONTAINER_APEX_PROXY" rm -rf /tmp/apex_install /tmp/apex-latest.zip || true
    podman exec "$CONTAINER_APEX_PROXY" mkdir -p /tmp/apex_install
    podman cp "$APEX_ZIP" "$CONTAINER_APEX_PROXY:/tmp/apex-latest.zip"
    podman exec "$CONTAINER_APEX_PROXY" unzip -o -q /tmp/apex-latest.zip -d /tmp/apex_install/
    
    podman exec "$CONTAINER_APEX_PROXY" rm -rf /opt/oracle/apex_images/images || true
    podman exec "$CONTAINER_APEX_PROXY" mkdir -p /opt/oracle/apex_images
    podman exec "$CONTAINER_APEX_PROXY" cp -R /tmp/apex_install/apex/images /opt/oracle/apex_images/
    echo "apex-latest.zip" | podman exec -i "$CONTAINER_APEX_PROXY" tee /opt/oracle/apex_images/.unzipped_source >/dev/null
    
    podman exec "$CONTAINER_APEX_PROXY" rm -rf /tmp/apex-latest.zip /tmp/apex_install || true
    echo "✅ APEX pildid taastatud!"
  else
    echo "⚠️  Hoiatus: Ei leitud faili $APEX_ZIP. APEX pildid võivad puududa!"
  fi
fi

DURATION_RESTORE=$(( $(date +%s) - START_RESTORE ))

# Salvestame mõõdikud metrics/ kataloogi (viimased 10 korda)
METRICS_DIR="$SCRIPT_DIR/../metrics"
mkdir -p "$METRICS_DIR"
JSON_TS_RESTORE="$METRICS_DIR/restore_golden_snapshot_benchmarks_${TIMESTAMP}.json"

cat << EOF > "$JSON_TS_RESTORE"
{
  "last_updated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "restore_duration_seconds": $DURATION_RESTORE,
  "restore_file": "$(basename "$BACKUP_FILE")"
}
EOF

# Copy the latest to restore_golden_snapshot_benchmarks.json
cp "$JSON_TS_RESTORE" "$METRICS_DIR/restore_golden_snapshot_benchmarks.json"

# Keep only the last 10 restore benchmarks in metrics/
(cd "$METRICS_DIR" && ls -t restore_golden_snapshot_benchmarks_*.json 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null || true)

echo -e "${CYAN}==================================================================${NC}"
echo -e "${GREEN}✅ TAASTAMINE TEOSTATUD: $(format_duration $DURATION_RESTORE)${NC}"
echo "------------------------------------------------------------------"
echo -e "📝 Logifail salvestati:        ${CYAN}$LOG_FILE${NC}"
echo -e "📊 Git mõõdikud salvestati:    ${CYAN}$METRICS_DIR/restore_golden_snapshot_benchmarks.json${NC}"
echo -e "${CYAN}==================================================================${NC}"
