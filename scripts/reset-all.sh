#!/usr/bin/env bash
# ============================================================================
# Oracle Free DB in Prod — Profile-Driven Selective & Full Reset Script
# Peatab ja kustutab valitud komponendid, profiilid või kogu keskkonna.
# Kasutus: ./scripts/reset-all.sh [all|<konteineri_nimi>] [--profile <profiili_nimi>] [--force] [--system]
# ============================================================================

set -e

# Vaigistame podman compose hoiatusteate välise teenusepakkuja kohta
export PODMAN_COMPOSE_WARNING_LOGS=false

# Värvide seadistamine (ainult siis kui terminal seda toetab)
if [ -t 0 ] || { [ -n "$TERM" ] && [ "$TERM" != "dumb" ]; }; then
  GREEN='\033[1;32m'
  YELLOW='\033[0;33m'
  CYAN='\033[1;36m'
  RED='\033[1;31m'
  NC='\033[0m'
else
  GREEN=''
  YELLOW=''
  CYAN=''
  RED=''
  NC=''
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_NAME="oracle-devops-platform"
COMPOSE_FILE="$SCRIPT_DIR/../podman-compose.yml"


# Laeme keskkonnamuutujad kui olemas
if [ -f "$SCRIPT_DIR/../.env" ]; then
  set -a
  source "$SCRIPT_DIR/../.env"
  set +a
fi

# Kaasame profiili laadimise funktsioonid
if [ -f "$SCRIPT_DIR/internal/load-profile.sh" ]; then
  source "$SCRIPT_DIR/internal/load-profile.sh"
fi

# Argumendid: vaikimisi kustutatakse KÕIK komponendid (COMPONENT="all")
COMPONENT="all"
TARGET_PROFILE="${PROXY_DB:-${MAIN_DB_PROFILE:-proxy-adb-oracle}}"
FORCE=false
SYSTEM_RESET=false

while [[ $# -gt 0 ]]; do
  case $1 in
    -y|--force)
      FORCE=true
      shift
      ;;
    --system)
      SYSTEM_RESET=true
      shift
      ;;
    --profile)
      TARGET_PROFILE="$2"
      shift 2
      ;;
    *)
      COMPONENT="$1"
      shift
      ;;
  esac
done

if [ "$SYSTEM_RESET" = "true" ]; then
  echo "=================================================================="
  echo "🚨 OHT: Valitud on kogu Podman süsteemi täielik nullimine (--system)!"
  echo "   See kustutab KÕIK konteinerid, pildid, andmed ja volumid sinu arvutist."
  echo "   Kasuta seda vaid siis, kui hoidla on korrumpeerunud või kettaruum kriitiliselt otsas."
  echo "=================================================================="
  if [ "$FORCE" = "false" ]; then
    read -p "❓ Kas oled TÄIESTI kindel, et soovid jätkata? (kirjuta 'JAH' suurte tähtedega): " CONFIRM
    if [ "$CONFIRM" != "JAH" ]; then
      echo "❌ Süsteemi nullimine tühistatud kasutaja poolt."
      exit 0
    fi
  fi
  
  echo "Peatan Podmani virtuaalmasina..."
  podman machine stop || true
  
  echo "Käivitan Podmani virtuaalmasina..."
  podman machine start || true
  
  echo "Teostan Podman süsteemi täieliku nullimise..."
  podman system prune -a -f --volumes
  
  echo "✅ Podman süsteem on edukalt nullitud ja valmis puhtaks käivituseks!"
  exit 0
fi

# Laeme valitud profiili spetsifikatsiooni
if declare -f load_db_profile >/dev/null 2>&1; then
  load_db_profile "$TARGET_PROFILE" >/dev/null 2>&1 || true
fi

SKIP_PUBLISHER=false
if [ -z "$PUBLISHER_DB_HOST" ]; then
  SKIP_PUBLISHER=true
fi

APEX_HOST="${APEX_DB_HOST:-localhost}"
APEX_PORT="${PROFILE_DB_PORT:-${APEX_DB_PORT:-1532}}"
APEX_SERVICE="${PROFILE_DEFAULT_SERVICE:-${APEX_DB_SERVICE:-FREEPDB1}}"

PUB_HOST="${PUBLISHER_DB_HOST:-localhost}"
PUB_PORT="${PUBLISHER_DB_PORT:-1531}"
PUB_SERVICE="${PUBLISHER_DB_SERVICE:-FREEPDB1}"
echo -e "${CYAN}==================================================================${NC}"
echo -e "${RED}⚠️  HOIATUS: See skript kustutab valitud komponendid, profiili ja andmed!${NC}"
echo -e "   Projekt:   ${CYAN}$PROJECT_NAME${NC}"
if [ "$COMPONENT" = "all" ]; then
  echo -e "   Sihtkoht:  ${YELLOW}KÕIK (Täielik puhastus / Full Reset)${NC}"
else
  echo -e "   Komponent: ${YELLOW}$COMPONENT${NC}"
fi
echo -e "   Profiil:   ${CYAN}${PROFILE_NAME:-$TARGET_PROFILE}${NC}"
echo -e "${CYAN}==================================================================${NC}"
echo -e "${YELLOW}🎯 KUSTUTAMISELE SUUNATUD SIHTSEADISTUSED:${NC}"
if [ "$COMPONENT" = "all" ]; then
  while IFS='|' read -r container prof env_key; do
    [ -z "$container" ] && continue
    (
      load_db_profile "$prof" >/dev/null 2>&1 || true
      p_port="${PROFILE_DB_PORT:-1532}"
      p_service="${PROFILE_DEFAULT_SERVICE:-FREEPDB1}"
      c_vol=$(echo "$container" | sed 's/^db-//' | tr '-' '_')
      echo -e "   - ${CYAN}${container}${NC} (Profiil: ${YELLOW}${prof}${NC})"
      echo -e "     ├─ Andmebaas: ${CYAN}localhost:${p_port}/${p_service}${NC}"
      echo -e "     └─ Volume: ${CYAN}${PROJECT_NAME}_${c_vol}_oradata${NC}"
    )
  done < <(get_active_db_instances 2>/dev/null || true)
  load_web_ide_profile >/dev/null 2>&1 || true
  if [ "${WEB_IDE_ENABLED:-true}" = "true" ]; then
    echo -e "   - ${CYAN}${WEB_IDE_CONTAINER_NAME:-web-ide-dev}${NC} (Web IDE Profiil: ${YELLOW}${WEB_IDE_PROFILE:-web-ide-standard}${NC})"
    echo -e "     └─ Volume: ${CYAN}${PROJECT_NAME}_web_ide_data${NC}"
  fi
  echo -e "   - Võrk: ${CYAN}${PROJECT_NAME}_default${NC}"
else
  c_vol=$(echo "$COMPONENT" | sed 's/^db-//' | tr '-' '_')
  echo -e "   - Konteiner: ${CYAN}${COMPONENT}${NC}"
  echo -e "   - Volume: ${CYAN}${PROJECT_NAME}_${c_vol}_oradata${NC}"
fi
echo -e "${CYAN}==================================================================${NC}"

if [ "$FORCE" = "false" ]; then
  read -p "❓ Kas oled kindel, et soovid jätkata? (y/N): " CONFIRM
  if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo -e "${RED}❌ Puhastamine tühistatud kasutaja poolt.${NC}"
    exit 0
  fi
fi

# Seadistame logimise
LOG_DIR="$SCRIPT_DIR/../install_logs"
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$LOG_DIR/reset_${COMPONENT}_${TIMESTAMP}.log"
exec > >(tee -a "$LOG_FILE") 2>&1

START_RESET=$(date +%s)

get_reset_stats() {
  local default_est="$1"
  local values=()
  local m_dir="$SCRIPT_DIR/../metrics"
  if [ -d "$m_dir" ]; then
    for f in "$m_dir"/reset_benchmarks_*.json; do
      if [ -f "$f" ]; then
        local val=$(grep -m1 '"reset_duration_seconds":' "$f" | awk -F: '{print $2}' | tr -d ' ,"\r\n' || echo "")
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
  echo "keskmine: ${avg}s (min: ${min}s, max: ${max}s)"
}

echo -e "${CYAN}==================================================================${NC}"
echo -e "📝 Puhastamise logi: ${CYAN}$LOG_FILE${NC}"
echo -e "📊 Ajalooline ooteaeg: ${YELLOW}$(get_reset_stats "15s")${NC}"
echo -e "${CYAN}==================================================================${NC}"

# Funktsioon konteineri kustutamiseks
cleanup_container() {
  local container=$1
  if podman container exists "$container" 2>/dev/null; then
    echo "   Peatame ja kustutame konteineri: $container"
    podman stop "$container" 2>/dev/null || true
    podman rm -f "$container" 2>/dev/null || true
  else
    echo "   Konteiner $container ei eksisteeri — OK"
  fi
}

# Funktsioon volume kustutamiseks
cleanup_volume() {
  local volume=$1
  if podman volume exists "$volume" 2>/dev/null; then
    echo "   Kustutame volume: $volume"
    podman volume rm "$volume" 2>/dev/null || true
  else
    echo "   Volume $volume ei eksisteeri — OK"
  fi
}

case $COMPONENT in
  all)
    echo "Teostan kogu keskkonna täieliku puhastuse (Full Profile Reset)..."
    COMPOSE_ARGS=(-f "$COMPOSE_FILE")
    OVERRIDE_FILE="$SCRIPT_DIR/../podman-compose.override.yml"
    [ -f "$OVERRIDE_FILE" ] && COMPOSE_ARGS+=(-f "$OVERRIDE_FILE")
    podman-compose "${COMPOSE_ARGS[@]}" --profile dev-ords down -v >> "$LOG_FILE" 2>&1 || true
    
    # 1. Kustutame dünaamiliselt kõik .env failis määratud aktiivsed konteinerid ja mahud
    while IFS='|' read -r container prof env_key; do
      [ -z "$container" ] && continue
      cleanup_container "$container"
      cleanup_container "oracle-$container"
      cleanup_container "oracle-ords-$container"
      c_vol=$(echo "$container" | sed 's/^db-//' | tr '-' '_')
      cleanup_volume "${PROJECT_NAME}_${c_vol}_oradata"
      cleanup_volume "${PROJECT_NAME}_${c_vol}_data"
      rm -rf "$SCRIPT_DIR/../config/ords/${container}"
    done < <(get_active_db_instances 2>/dev/null || true)

    cleanup_container "web-ide-dev"
    cleanup_container "ords-standalone-emulator"
    cleanup_container "ords-standalone-dev"
    cleanup_container "oracle-ords-standalone-test"
    cleanup_volume "${PROJECT_NAME}_web_ide_data"


    # 2. Otsime otse Podman daemonist KÕIK selle projektiga seotud jooksevad või peatunud konteinerid (üldine dynaamiline tuvastus)
    live_containers=$(podman ps -a --filter "label=com.docker.compose.project=$PROJECT_NAME" --format "{{.Names}}" 2>/dev/null || true)
    if [ -z "$live_containers" ]; then
      live_containers=$(podman ps -a --format "{{.Names}}" 2>/dev/null | grep -E "^(db-|oracle-|ords-|web-ide-)" || true)
    fi
    for c in $live_containers; do
      [ -n "$c" ] && cleanup_container "$c"
    done

    # 3. Otsime otse Podman daemonist KÕIK selle projektiga seotud mahud (volumed)
    live_vols=$(podman volume ls --filter "label=com.docker.compose.project=$PROJECT_NAME" --format "{{.Name}}" 2>/dev/null || true)
    if [ -z "$live_vols" ]; then
      live_vols=$(podman volume ls --format "{{.Name}}" 2>/dev/null | grep "^${PROJECT_NAME}_" || true)
    fi
    for v in $live_vols; do
      [ -n "$v" ] && cleanup_volume "$v"
    done
    # Kustutame Podman Podid
    echo "   Kustutame Podman Podid..."
    for pod in $(podman pod ls --format "{{.Name}}" 2>/dev/null | grep "$PROJECT_NAME" || true); do
      if [ -n "$pod" ]; then
        echo "   Peatame ja kustutame podi: $pod"
        podman pod stop "$pod" 2>/dev/null || true
        podman pod rm -f "$pod" 2>/dev/null || true
      fi
    done

    # Kustutame võrgu
    NETWORK="${PROJECT_NAME}_default"
    if podman network exists "$NETWORK" 2>/dev/null; then
      echo "   Kustutame võrgu: $NETWORK"
      podman network rm "$NETWORK" 2>/dev/null || true
    fi
    
    # Puhastame patchid
    PATCHES_DIR="$SCRIPT_DIR/../patches"
    if [ -d "$PATCHES_DIR" ]; then
      find "$PATCHES_DIR" -type d -name "unzipped_*" -exec rm -rf {} + 2>/dev/null || true
    fi

    # Kustutame Podmani saladused daemoni tasemel (turvaliselt)
    echo "   Kustutame Podmani saladused..."
    for sec in $(get_required_secret_names 2>/dev/null || echo "publisher_db_sys_password apex_db_sys_password apex_schema_password ords_listener_password apex_admin_password test_dev_password"); do
      podman secret rm "$sec" >> "$LOG_FILE" 2>&1 || true
    done
    
    # Kustutame hosti failid
    echo "   Kustutame TNS_ADMIN/Wallet kataloogi..."
    rm -rf "$SCRIPT_DIR/../config/tns_admin"
    rm -rf "$SCRIPT_DIR/../config/secrets"
    rm -f "$OVERRIDE_FILE"
    rm -rf "$SCRIPT_DIR/../db-install"

    # Kustutame VS Code registreeritud ühenduste kausta ja konfiguratsiooni
    echo "   Kustutame VS Code ühenduste kausta..."
    folder_name="${VSCODE_FOLDER_NAME:-${DB_CONN_NAME:-${CONTAINER_NAME:-db-dev-full}}}"
    VSCODE_SQLCL=$(find "$HOME/.vscode/extensions" -name "sql" -path "*/oracle.sql-developer-*/dbtools/sqlcl/bin/sql" 2>/dev/null | sort -rV | head -n 1)
    if [ -n "$VSCODE_SQLCL" ] && [ -x "$VSCODE_SQLCL" ]; then
      "$VSCODE_SQLCL" /nolog >/dev/null 2>&1 <<EOF || true
connmgr delete -folder /${folder_name} -force
EXIT
EOF
    fi

    # Puhastame ühenduste JSON failid ja orvud kaustad
    DBTOOLS_CONNS_DIR="$HOME/.dbtools/connections"
    FOLDERS_FILE="$HOME/.dbtools/connection_folders/folders.json"
    if [ -d "$DBTOOLS_CONNS_DIR" ]; then
      for prop in "$DBTOOLS_CONNS_DIR"/*/dbtools.properties; do
        [ -f "$prop" ] || continue
        if grep -iq "folderName=/${folder_name}" "$prop" 2>/dev/null || grep -iq "FREEPDB1" "$prop" 2>/dev/null; then
          conn_dir="$(dirname "$prop")"
          rm -rf "$conn_dir"
        fi
      done
    fi

    if [ -f "$FOLDERS_FILE" ] && command -v jq &>/dev/null; then
      valid_ids=($(find "$DBTOOLS_CONNS_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2>/dev/null || true))
      VALID_IDS_JSON=$(printf '%s\n' "${valid_ids[@]}" | jq -R . | jq -s .)
      jq --argjson valid "$VALID_IDS_JSON" '
        .folders = [
          .folders[]? |
          .connections = [ .connections[]? | select(. as $c | $valid | index($c)) ]
        ] |
        .folders = [ .folders[]? | select((.connections | length) > 0) ]
      ' "$FOLDERS_FILE" > "${FOLDERS_FILE}.tmp" 2>/dev/null && mv "${FOLDERS_FILE}.tmp" "$FOLDERS_FILE" 2>/dev/null || true
    fi

    for json_path in "$HOME/.sqldev/connections.json" "$HOME/.dbtools/connections.json"; do
      if [ -f "$json_path" ]; then
        rm -f "$json_path"
      fi
    done
    ;;

  *)
    echo "Puhastan komponendi: $COMPONENT"
    c_vol=$(echo "$COMPONENT" | sed 's/^db-//' | tr '-' '_')
    cleanup_container "$COMPONENT"
    cleanup_container "oracle-$COMPONENT"
    cleanup_container "oracle-ords-$COMPONENT"
    cleanup_volume "${PROJECT_NAME}_${c_vol}_oradata"
    cleanup_volume "${PROJECT_NAME}_${c_vol}_data"
    rm -rf "$SCRIPT_DIR/../config/ords/${COMPONENT}"
    ;;
esac

# Kontrollime tulemust
echo ""
echo "Kontrollin puhastamise tulemust..."
CLEAN=true

if [ "$COMPONENT" = "all" ]; then
  rem_containers=$(podman ps -a --filter "label=com.docker.compose.project=$PROJECT_NAME" --format "{{.Names}}" 2>/dev/null || true)
  if [ -n "$rem_containers" ]; then
    for c in $rem_containers; do
      echo -e "${RED}❌ Hoiatus: Konteiner ${c} on ikka alles!${NC}"
      CLEAN=false
    done
  fi

  rem_vols=$(podman volume ls --filter "label=com.docker.compose.project=$PROJECT_NAME" --format "{{.Name}}" 2>/dev/null || true)
  if [ -n "$rem_vols" ]; then
    for v in $rem_vols; do
      echo -e "${RED}❌ Hoiatus: Volume ${v} on ikka alles!${NC}"
      CLEAN=false
    done
  fi
else
  c_vol="${COMPONENT//-/_}"
  if podman container exists "$COMPONENT" 2>/dev/null; then
    echo -e "${RED}❌ Hoiatus: Konteiner ${COMPONENT} on ikka alles!${NC}"
    CLEAN=false
  fi
  if podman volume exists "${PROJECT_NAME}_${c_vol}_oradata" 2>/dev/null; then
    echo -e "${RED}❌ Hoiatus: Volume ${PROJECT_NAME}_${c_vol}_oradata on ikka alles!${NC}"
    CLEAN=false
  fi
fi

echo ""
if [ "$CLEAN" = "true" ]; then
  echo -e "${CYAN}==================================================================${NC}"
  if [ "$COMPONENT" = "all" ]; then
    echo -e "${GREEN}✅ KÕIK PUHAS! Kogu keskkonna (Full Reset) puhastus sooritatud.${NC}"
  else
    echo -e "${GREEN}✅ KÕIK PUHAS! Komponendi ($COMPONENT) puhastus sooritatud.${NC}"
  fi
  echo -e "${CYAN}==================================================================${NC}"
else
  echo -e "${CYAN}==================================================================${NC}"
  echo -e "${RED}⚠️  HOIATUS: Mõned komponendid jäid kustutamata!${NC}"
  echo -e "${CYAN}==================================================================${NC}"
fi

DURATION_RESET=$(( $(date +%s) - START_RESET ))

# Kirjutame mõõdikud metrics/ kataloogi
METRICS_DIR="$SCRIPT_DIR/../metrics"
mkdir -p "$METRICS_DIR"

# Define timestamped JSON file name
JSON_TS_RESET="$METRICS_DIR/reset_benchmarks_${TIMESTAMP}.json"

cat << EOF > "$JSON_TS_RESET"
{
  "last_updated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "component": "$COMPONENT",
  "profile": "${TARGET_PROFILE}",
  "reset_duration_seconds": $DURATION_RESET
}
EOF

# Copy the latest to reset_benchmarks.json
cp "$JSON_TS_RESET" "$METRICS_DIR/reset_benchmarks.json"

# Keep only the last 10 reset benchmark runs in metrics/
(cd "$METRICS_DIR" && ls -t reset_benchmarks_*.json 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null || true)

cat << EOF > "$METRICS_DIR/reset_benchmarks.env"
# APEX & DB Reset Benchmark Metrics (Updated: $(date))
RESET_COMPONENT=$COMPONENT
RESET_PROFILE=$TARGET_PROFILE
RESET_TOTAL_SECS=$DURATION_RESET
EOF

echo ""
echo -e "${YELLOW}⏱  Puhastamine võttis aega: ${DURATION_RESET}s${NC}"
echo "------------------------------------------------------------------"
echo -e "📝 Logifail salvestati: ${CYAN}$LOG_FILE${NC}"
echo -e "📊 Git mõõdikud salvestati: ${CYAN}$METRICS_DIR/reset_benchmarks.json${NC}"
echo -e "${CYAN}==================================================================${NC}"
echo ""
echo "👉 Uuesti käivitamiseks ja seadistamiseks:"
case "$COMPONENT" in
  ${TARGET_SERVICE:-db-apex-proxy}|db-apex-proxy)
    echo "  1. Käivita konteiner:          podman compose up -d ${TARGET_SERVICE:-db-apex-proxy}"
    echo "  2. Teosta DB algseadistus:    ./scripts/internal/init-db-instance.sh ${TARGET_PROFILE} ${TARGET_SERVICE:-db-apex-proxy}"
    echo "  3. Paigalda APEX mootor:      ./scripts/internal/install-apex.sh"
    ;;
  db-publisher)
    echo "  1. Käivita konteiner:          podman compose up -d db-publisher"
    echo "  2. Teosta DB algseadistus:    ./scripts/internal/init-db-instance.sh appinfra-standard-gvenzl db-publisher"
    ;;
  ords)
    echo "  1. Käivita ORDS teenus:       podman compose --profile dev-ords up -d dev-ords"
    ;;
  all)
    echo "  Kogu keskkonna nullist automaatseks käivitamiseks (Full Process):"
    echo "    ./scripts/setup-all.sh"
    echo ""
    echo "  Konteinerite käsitsi käivitamiseks:"
    echo "    ./scripts/start-containers.sh"
    ;;
esac
echo "=================================================================="
