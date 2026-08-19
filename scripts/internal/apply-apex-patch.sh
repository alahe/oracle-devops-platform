#!/usr/bin/env bash
# ============================================================================
# Oracle APEX Patch Automated Installer Script
# Unzips APEX patch, locates patch SQL script (catpatch.sql / apxpatch.sql),
# applies patch in database (supporting remote connections via SQLcl/SQL*Plus).
# Logs all output automatically to ./install_logs/apex_patch_YYYYMMDD_HHMMSS.log
# Includes step timing metrics for benchmarking patch duration.
# ============================================================================

set -e

# Load Central Repository Parameter File if present
CONFIG_FILE="$(dirname "$0")/../../config/repository.env"
if [ -f "$CONFIG_FILE" ]; then
  set -a
  source "$CONFIG_FILE"
  set +a
elif [ -f ".env" ]; then
  set -a
  source ".env"
  set +a
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

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
LOG_DIR="$SCRIPT_DIR/../../install_logs"
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$LOG_DIR/apex_patch_${TIMESTAMP}.log"

# Suuname kogu väljundi nii ekraanile kui logifaili
exec > >(tee -a "$LOG_FILE") 2>&1

if [ "$MASTER_SETUP" != "true" ]; then
  echo -e "${CYAN}==================================================================${NC}"
  echo "------------------------------------------------------------------"
  echo -e "📝 APEX Patchi paigalduse logi salvestatakse faili:"
  echo -e "   ${CYAN}$LOG_FILE${NC}"
  echo -e "${CYAN}==================================================================${NC}"
fi

if [ -f "$SCRIPT_DIR/load-profile.sh" ]; then
  source "$SCRIPT_DIR/load-profile.sh"
  load_db_profile >/dev/null 2>&1 || true
fi

CONTAINER_NAME=$(get_active_db_instances 2>/dev/null | head -n 1 | cut -d'|' -f1)
CONTAINER_NAME="${CONTAINER_NAME:-db-dev-full}"
PRIMARY_UPPER=$(echo "$CONTAINER_NAME" | tr '-' '_' | tr '[:lower:]' '[:upper:]')

SYS_PASSWORD="${APEX_DB_SYS_PASSWORD:-}"
if [ -z "$SYS_PASSWORD" ]; then
  if podman container exists "$CONTAINER_NAME" 2>/dev/null && [ "$(podman inspect --format='{{.State.Status}}' "$CONTAINER_NAME" 2>/dev/null)" = "running" ]; then
    SYS_PASSWORD=$(podman exec "$CONTAINER_NAME" cat "/run/secrets/oracle_pwd" 2>/dev/null || podman exec "$CONTAINER_NAME" cat "/run/secrets/apex_db_sys_password" 2>/dev/null || true)
  fi
  if [ -z "$SYS_PASSWORD" ]; then
    SYS_PASSWORD=$(podman secret inspect --showsecret apex_db_sys_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
  fi
  SYS_PASSWORD="${SYS_PASSWORD:-$APEX_DB_SYS_PASSWORD}"
fi
DB_HOST="${APEX_DB_HOST:-${PROFILE_DB_HOST:-localhost}}"
DB_PORT="${APEX_DB_PORT:-${PROFILE_DB_PORT:-1532}}"
DB_SERVICE="${APEX_DB_SERVICE:-${PROFILE_DEFAULT_SERVICE:-FREEPDB1}}"

PATCH_ZIP=""
SKIP_ORDS=false

for arg in "$@"; do
  if [ "$arg" = "--no-ords" ]; then
    SKIP_ORDS=true
  else
    PATCH_ZIP="$arg"
  fi
done

if [ -z "$PATCH_ZIP" ]; then
  echo "Viga: Palun anna argumendina APEX patchi zip-faili tee!"
  echo "Kasutus: ./scripts/apply-apex-patch.sh patches/<patch_file>.zip [--no-ords]"
  exit 1
fi

if [ ! -f "$PATCH_ZIP" ]; then
  echo "Viga: Faili '$PATCH_ZIP' ei leitud!"
  exit 1
fi

START_PATCH_TOTAL=$(date +%s)

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
version_to_int() {
  local ver="$1"
  if [ -z "$ver" ]; then
    echo 0
    return
  fi
  ver=$(echo "$ver" | tr -d -c '0-9.')
  if [ $(echo "$ver" | tr -cd '.' | wc -c) -eq 1 ]; then
    ver="${ver}.0"
  fi
  local major=$(echo "$ver" | cut -d'.' -f1)
  local minor=$(echo "$ver" | cut -d'.' -f2)
  local patch=$(echo "$ver" | cut -d'.' -f3)
  printf "%02d%02d%02d\n" "$major" "$minor" "${patch:-0}"
}

if ! command -v print_progress &> /dev/null; then
  print_progress() {
    echo -ne "$@"
  }
fi

get_step_stats() {
  local step_key="$1"
  local default_est="$2"
  local values=()
  if [ -d "$SCRIPT_DIR/../../metrics" ]; then
    for f in "$SCRIPT_DIR/../../metrics"/setup_benchmarks_*.json; do
      if [ -f "$f" ]; then
        local val=$(grep -m1 "\"$step_key\":" "$f" | awk -F: '{print $2}' | tr -d ' ,"\r\n' || echo "")
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

print_sub_header() {
  local sub_num="$1"
  local title="$2"
  local step_key1="$3"
  local step_key2="$4"
  local default_est="$5"
  echo -e "${CYAN}├─${NC} ${YELLOW}[Alamsamm 6.6.${sub_num}]: ${title}${NC}"
  if [ -n "$step_key1" ]; then
    echo -e "${CYAN}│${NC}  📊 Ajalooline ooteaeg: ${YELLOW}$(get_step_stats "$step_key1" "$step_key2" "$default_est")${NC}"
  elif [ -n "$default_est" ]; then
    echo -e "${CYAN}│${NC}  📊 Ajalooline ooteaeg: ${YELLOW}ootusaeg ~${default_est}${NC}"
  fi
}

copy_patch_images_to_volume() {
  if [ "$EXEC_MODE" = "CONTAINER" ]; then
    podman exec -u root "$CONTAINER_NAME" chown -R oracle:oinstall /opt/oracle/apex_images || true
    if podman exec "$CONTAINER_NAME" [ -d "$PATCH_DIR/images" ] 2>/dev/null; then
      echo "Kopeerin APEX patchi (${TARGET_PATCH_VER:-uuem}) staatilised ressursid volume-i (/opt/oracle/apex_images/images/)..."
      podman exec "$CONTAINER_NAME" cp -R "$PATCH_DIR/images/." "/opt/oracle/apex_images/images/"
      echo "Staatilised ressursid (${TARGET_PATCH_VER:-uuem}) edukalt uuendatud."
    fi
    echo "Puhastan ajutised failid konteinerist..."
    podman exec "$CONTAINER_NAME" rm -rf /tmp/apex-patch.zip /tmp/apex_patch_install || true
  else
    if [ -d "$PATCH_DIR/images" ]; then
      echo "Kopeerin uued staatilised ressursid kausta ./apex/images/..."
      cp -R "$PATCH_DIR/images/." "./apex/images/"
      echo "Staatilised ressursid edukalt uuendatud kaustas ./apex/images."
    fi
  fi
}

# Automaatne lokaalse konteineri kontroll ja režiimi valik
IS_CONTAINER_AVAIL=false
if [ "$DB_HOST" = "localhost" ] || [ "$DB_HOST" = "127.0.0.1" ] || [ "$DB_HOST" = "db-apex-proxy" ]; then
  if podman container exists "$CONTAINER_NAME" 2>/dev/null; then
    IS_CONTAINER_AVAIL=true
  fi
fi

EXEC_MODE="CLIENT"
# Eelistame alati CONTAINER režiimi kohalikus arenduses (et vältida Defenderi lag-i lahtipakkimisel)
if [ "$IS_CONTAINER_AVAIL" = "true" ]; then
  echo "Tuvastati kohalik konteiner $CONTAINER_NAME."
  echo "Kasutan konteineri režiimi (unzip + paigaldus otse konteineris)..."
  EXEC_MODE="CONTAINER"
  
  PSTEP1_START=$(date +%s)
  print_sub_header "1" "Kopeerin ja pakin APEX patchi lahti konteineris..." "step6_apex_copy_container_seconds" "step6_apex_copy_container_seconds" "5s"
  podman exec "$CONTAINER_NAME" rm -rf /tmp/apex_patch_install /tmp/apex-patch.zip || true
  podman exec "$CONTAINER_NAME" mkdir -p /tmp/apex_patch_install
  podman cp "$PATCH_ZIP" "$CONTAINER_NAME":/tmp/apex-patch.zip
  podman exec "$CONTAINER_NAME" unzip -o -q /tmp/apex-patch.zip -d /tmp/apex_patch_install/ || true
  
  # Leiame paigaldusskripti konteineri seest
  PATCH_SQL_FILE=$(podman exec "$CONTAINER_NAME" find /tmp/apex_patch_install -name "catpatch.sql" -o -name "apxpatch.sql" | head -n 1 | tr -d '\r\n')
  
  if [ -z "$PATCH_SQL_FILE" ]; then
    echo "❌ Viga: Ei leidnud paigaldusskripti (catpatch.sql või apxpatch.sql) konteinerist!"
    exit 1
  fi
  
  PATCH_DIR=$(dirname "$PATCH_SQL_FILE")
  PATCH_SCRIPT_NAME=$(basename "$PATCH_SQL_FILE")
  
  echo "Leitud patchi asukoht konteineris: $PATCH_DIR (skript: $PATCH_SCRIPT_NAME)"
  PSTEP1_TIME=$(format_duration $(($(date +%s) - PSTEP1_START)))
  echo -e "⏱  [Patchi samm 1 valmis (lahtipakkimine konteineris): ${YELLOW}$PSTEP1_TIME${NC}]"
  
  PSTEP2_START=$(date +%s)
  DB_CLI="podman exec -i -w $PATCH_DIR $CONTAINER_NAME sqlplus -s"
  CONN_STR="sys/${SYS_PASSWORD}@localhost:1521/${DB_SERVICE} as sysdba"
  PSTEP2_TIME=$(format_duration $(($(date +%s) - PSTEP2_START)))
  echo -e "⏱  [Patchi samm 2 valmis (konteineri seadistus): ${YELLOW}$PSTEP2_TIME${NC}]"
else
  # Client-side execution (kui konteinerit pole või on tegu kaug-andmebaasiga)
  # Siin peame pakkima lahti hostis
  echo "Kasutan host-süsteemi režiimi (CLIENT)..."
  
  PSTEP1_START=$(date +%s)
  PATCH_UNZIP_ROOT="$(dirname "$PATCH_ZIP")/unzipped_$(basename "$PATCH_ZIP" .zip)"
  mkdir -p "$PATCH_UNZIP_ROOT"
  
  print_sub_header "1" "Lahtipakin APEX patchi hostis: $PATCH_ZIP..." "step6_apex_copy_container_seconds" "step6_apex_copy_container_seconds" "5s"
  unzip -q -o "$PATCH_ZIP" -d "$PATCH_UNZIP_ROOT" || true
  
  PATCH_SQL_FILE=$(find "$PATCH_UNZIP_ROOT" -name "catpatch.sql" -o -name "apxpatch.sql" | head -n 1)
  if [ -z "$PATCH_SQL_FILE" ]; then
    echo "❌ Viga: Ei leidnud paigaldusskripti (catpatch.sql või apxpatch.sql) zip-failist!"
    exit 1
  fi
  
  PATCH_DIR="$(dirname "$PATCH_SQL_FILE")"
  PATCH_SCRIPT_NAME="$(basename "$PATCH_SQL_FILE")"
  
  echo "Leitud patchi asukoht hostis: $PATCH_DIR (skript: $PATCH_SCRIPT_NAME)"
  PSTEP1_TIME=$(format_duration $(($(date +%s) - PSTEP1_START)))
  echo -e "⏱  [Patchi samm 1 valmis (lahtipakkimine hostis): ${YELLOW}$PSTEP1_TIME${NC}]"
  
  if command -v sql &> /dev/null; then
    DB_CLI="sql -s"
  elif command -v sqlplus &> /dev/null; then
    DB_CLI="sqlplus -s"
  else
    echo "❌ Viga: Ei leidnud SQLcl ega SQL*Plus utiliite host-süsteemist!"
    exit 1
  fi

  if [ -f "$SCRIPT_DIR/../../config/tns_admin/cwallet.sso" ]; then
    if [ "$IS_ADB" = "true" ]; then
      CONN_STR="/@DB_${PRIMARY_UPPER}_SYS"
    else
      CONN_STR="/@DB_${PRIMARY_UPPER}_SYS as sysdba"
    fi
  else
    if [ "$IS_ADB" = "true" ]; then
      CONN_STR="${APEX_ADMIN_USER:-admin}/${SYS_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_SERVICE}"
    else
      CONN_STR="sys/${SYS_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_SERVICE} as sysdba"
    fi
  fi
  PSTEP2_TIME=$(format_duration $(($(date +%s) - PSTEP2_START)))
  echo -e "⏱  [Patchi samm 2 valmis (kliendi seadistus): ${YELLOW}$PSTEP2_TIME${NC}]"
fi

# Kontrollime kas andmebaasis on juba sama või uuem APEX patch versioon
DB_APEX_INFO=""
if [ "$EXEC_MODE" = "CONTAINER" ]; then
  DB_APEX_INFO=$(podman exec -i "$CONTAINER_NAME" sqlplus -s "$CONN_STR" <<EOF 2>/dev/null | grep -v -E "Connected to|Oracle Database|version" || echo ""
SET FEEDBACK OFF
SET HEADING OFF
SET PAGESIZE 0
SET VERIFY OFF
SELECT version || ':' || status FROM dba_registry WHERE comp_id = 'APEX';
EXIT;
EOF
)
else
  DB_APEX_INFO=$($DB_CLI "$CONN_STR" <<EOF 2>/dev/null | grep -v -E "Connected to|Oracle Database|version" || echo ""
SET FEEDBACK OFF
SET HEADING OFF
SET PAGESIZE 0
SET VERIFY OFF
SELECT version || ':' || status FROM dba_registry WHERE comp_id = 'APEX';
EXIT;
EOF
)
fi

DB_APEX_VER=$(echo "$DB_APEX_INFO" | grep -v -E "ORA-|Error" | cut -d':' -f1 | tr -d ' \r\n')
DB_APEX_STATUS=$(echo "$DB_APEX_INFO" | grep -v -E "ORA-|Error" | cut -d':' -f2 | tr -d ' \r\n')

# Parse target patch version from README inside the zip
TARGET_PATCH_VER=$(unzip -p "$PATCH_ZIP" "*/README.txt" 2>/dev/null | grep -i "Oracle APEX Product Version" | grep -o -E "[0-9]+\.[0-9]+\.[0-9]+" | head -n 1 || echo "")

if [ "$DB_APEX_STATUS" = "VALID" ] && [ -n "$DB_APEX_VER" ] && [ -n "$TARGET_PATCH_VER" ]; then
  db_val=$(version_to_int "$DB_APEX_VER")
  patch_val=$(version_to_int "$TARGET_PATCH_VER")
  if [ $db_val -ge $patch_val ]; then
    echo "=================================================================="
    echo "✅ APEX patch on juba paigaldatud (andmebaasi versioon: $DB_APEX_VER, soovitud: $TARGET_PATCH_VER)."
    echo "   Jätan SQL patchimise vahele."
    echo "=================================================================="
    copy_patch_images_to_volume
    exit 0
  fi
fi

# ----------------------------------------------------------------------------
# 3. Patchi paigaldus andmebaasis
# ----------------------------------------------------------------------------
PSTEP3_START=$(date +%s)
PATCH_SQL_LOG_FILE="$LOG_DIR/apex_patch_sql_${TIMESTAMP}.log"

print_sub_header "2" "Running APEX Patch in $DB_SERVICE via $EXEC_MODE..." "step5_apex_patch_install_seconds" "step9_apex_patch_install_seconds" "1m"
echo -e "${CYAN}│${NC}  📝 Detailne SQL logi: ${CYAN}[Logi](file://$PATCH_SQL_LOG_FILE)${NC}"

if [ "$EXEC_MODE" = "CLIENT" ]; then
  ORIG_DIR=$(pwd)
  cd "$PATCH_DIR"
fi

$DB_CLI "$CONN_STR" > "$PATCH_SQL_LOG_FILE" 2>&1 << EOF &
ALTER SESSION SET "_oracle_script" = TRUE;

-- Käivitame leitud patchi skripti
@$PATCH_SCRIPT_NAME

EXIT;
EOF

SQL_PID=$!

ELAPSED=0
while kill -0 $SQL_PID 2>/dev/null; do
  sleep 3
  ELAPSED=$((ELAPSED + 3))
  print_progress "   Paigaldan APEX patchi... kestus: ${ORANGE}$(format_duration $ELAPSED)${NC}\r"
done
wait $SQL_PID
echo ""
echo "✅ APEX patchi SQL paigaldamine lõpetatud!"

if [ "$EXEC_MODE" = "CLIENT" ]; then
  cd "$ORIG_DIR"
fi

PSTEP3_TIME=$(format_duration $(($(date +%s) - PSTEP3_START)))
echo -e "⏱  [Patchi samm 3 valmis (SQL/PLSQL execution): ${YELLOW}$PSTEP3_TIME${NC}]"

# ----------------------------------------------------------------------------
# 4. Staatiliste piltide ja ressursside uuendamine ja puhastamine
# ----------------------------------------------------------------------------
PSTEP4_START=$(date +%s)
  print_sub_header "3" "Uuendan kohalikke ja ORDS staatilisi APEX-i pilte..." "" "" "2s"
copy_patch_images_to_volume
PSTEP4_TIME=$(format_duration $(($(date +%s) - PSTEP4_START)))

# ----------------------------------------------------------------------------
# 5. ORDS taaskäivitus
# ----------------------------------------------------------------------------
PSTEP5_START=$(date +%s)
  print_sub_header "4" "Taaskäivitan ORDS teenuse uute failide rakendamiseks..." "" "" "2s"
ords_found=$(podman ps --format '{{.Names}}' | grep -E '^oracle-ords-dev|^ords-|^oracle-ords-' | head -n 1 || echo "oracle-ords-dev")
ORDS_CONTAINER="${PROFILE_ORDS_CONTAINER_NAME:-$ords_found}"
if [ "$SKIP_ORDS" = "false" ] && podman container exists "$ORDS_CONTAINER" 2>/dev/null; then
  podman restart "$ORDS_CONTAINER" || true
fi
PSTEP5_TIME=$(format_duration $(($(date +%s) - PSTEP5_START)))

PATCH_TOTAL_TIME=$(format_duration $(($(date +%s) - START_PATCH_TOTAL)))

echo ""
echo "=================================================================="
echo "⏱   APEX PATCHI AJALINE KOKKUVÕTE (PATCH TIMING METRICS)"
echo "=================================================================="
echo "  1. Patchi lahtipakkimine:       $PSTEP1_TIME"
echo "  2. Failide seadistus/kopeerimine: $PSTEP2_TIME"
echo "  3. Patchi SQL paigaldus (DB):   $PSTEP3_TIME"
echo "  4. Piltide uuendamine:          $PSTEP4_TIME"
echo "  5. ORDS taaskäivitus:           $PSTEP5_TIME"
echo "  ------------------------------------------------------------"
echo "  ⌛ PATCHI PAIGALDUSE KESTUS:     $PATCH_TOTAL_TIME"
echo "=================================================================="
if [ "$MASTER_SETUP" != "true" ]; then
  echo "------------------------------------------------------------------"
  echo "📝 Logifail salvestati: $LOG_FILE"
  echo "✅ Oracle APEX Patch (Bundle Patch) edukalt paigaldatud!"
  echo "=================================================================="
fi
