#!/usr/bin/env bash
# ============================================================================
# Oracle APEX Automated Installer for APEX Proxy Database (db-apex-proxy)
# Downloads Oracle APEX, installs engine into FREEPDB1, creates workspace.
# Supports both client-side execution (SQLcl/SQL*Plus) and container fallback.
# Logs detailed output to ./install_logs/ (ignored in Git).
# Writes step benchmark metrics to ./metrics/ (tracked in Git).
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

# Parameetrite parsimine
SKIP_ORDS=false
TARGET_DB=""
TARGET_VER=""
TARGET_PORT=""
TARGET_SERVICE=""

while [[ "$#" -gt 0 ]]; do
  case $1 in
    --no-ords) SKIP_ORDS=true ;;
    --db) TARGET_DB="$2"; shift ;;
    --version) TARGET_VER="$2"; shift ;;
    --port) TARGET_PORT="$2"; shift ;;
    --service) TARGET_SERVICE="$2"; shift ;;
  esac
  shift
done

# Dünaamiline instantsi ja konteineri tuvastamine profiilide ja topoloogia põhjal
local_primary=$(get_active_db_instances 2>/dev/null | head -n 1 | cut -d'|' -f1)
PRIMARY_CONTAINER="${local_primary:-db-dev-full}"

if [ -z "$TARGET_DB" ] || [ "$TARGET_DB" = "apex-proxy" ] || [ "$TARGET_DB" = "proxy" ] || [ "$TARGET_DB" = "$PRIMARY_CONTAINER" ]; then
  CONTAINER_NAME="$PRIMARY_CONTAINER"
  if ! podman container exists "$CONTAINER_NAME" 2>/dev/null; then
    c_found=$(podman ps --format '{{.Names}}' | grep -E '^db-|^oracle-db-' | head -n 1 || echo "")
    [ -n "$c_found" ] && CONTAINER_NAME="$c_found"
  fi
  DB_SUFFIX="${CONTAINER_NAME#db-}"
  DB_PORT="${TARGET_PORT:-${APEX_DB_PORT:-${PROFILE_DB_PORT:-1532}}}"
  DB_SERVICE="${TARGET_SERVICE:-${APEX_DB_SERVICE:-${PROFILE_DEFAULT_SERVICE:-FREEPDB1}}}"
  APEX_VER="${TARGET_VER:-${APEX_DB_APEX_VERSION:-${PROFILE_APEX_VERSION:-26.1}}}"
  SYS_PWD_SECRET="apex_db_sys_password"
else
  DB_SUFFIX="$TARGET_DB"
  c_suffix_hyphen=$(echo "$DB_SUFFIX" | tr '_' '-')
  CONTAINER_NAME="$DB_SUFFIX"
  if ! podman container exists "$CONTAINER_NAME" 2>/dev/null; then
    if podman container exists "db-$c_suffix_hyphen" 2>/dev/null; then
      CONTAINER_NAME="db-$c_suffix_hyphen"
    elif podman container exists "oracle-db-$c_suffix_hyphen" 2>/dev/null; then
      CONTAINER_NAME="oracle-db-$c_suffix_hyphen"
    fi
  fi
  DB_PORT="${TARGET_PORT:-}"
  if [ -z "$DB_PORT" ]; then
    PORT_VAR="DB_${DB_SUFFIX}_PORT"
    DB_PORT="${!PORT_VAR:-${PROFILE_DB_PORT:-1532}}"
  fi
  DB_SERVICE="${TARGET_SERVICE:-}"
  if [ -z "$DB_SERVICE" ]; then
    SERVICE_VAR="DB_${DB_SUFFIX}_SERVICE"
    DB_SERVICE="${!SERVICE_VAR:-${PROFILE_DEFAULT_SERVICE:-FREEPDB1}}"
  fi
  APEX_VER="${TARGET_VER:-}"
  if [ -z "$APEX_VER" ]; then
    APEX_VER_VAR="DB_${DB_SUFFIX}_APEX_VERSION"
    APEX_VER="${!APEX_VER_VAR:-${PROFILE_APEX_VERSION:-26.1}}"
  fi
  SYS_PWD_SECRET="${DB_SUFFIX}_db_sys_password"
fi

# Kui APEX-i versioon on NONE või tühi, siis siia andmebaasi APEX-it ei paigaldata!
if [ "$APEX_VER" = "NONE" ]; then
  echo "ℹ️  APEX_VERSION on määratud NONE andmebaasile $DB_SUFFIX — Jätan APEX paigaldamise vahele."
  exit 0
fi

APEX_URL="${APEX_DOWNLOAD_URL:-${RESOLVED_APEX_URL:-${PROFILE_APEX_DOWNLOAD_URL:-https://download.oracle.com/otn_software/apex/apex_26.1_en.zip}}}"
APEX_ZIP_NAME=$(basename "$APEX_URL")
APEX_ZIP="$SCRIPT_DIR/../../binaries/$APEX_ZIP_NAME"

# 1. Lokaalsed paigalduse logid (ei lähe Git-i)
LOG_DIR="$SCRIPT_DIR/../../install_logs"
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$LOG_DIR/apex_install_${DB_SUFFIX}_${TIMESTAMP}.log"

# Suuname kogu väljundi nii ekraanile kui lokaalsesse logifaili
exec > >(tee -a "$LOG_FILE") 2>&1

# 2. Git-is jälgitav metrics kataloog
METRICS_DIR="$SCRIPT_DIR/../../metrics"
mkdir -p "$METRICS_DIR"
JSON_BENCHMARK="$METRICS_DIR/setup_benchmarks.json"
ENV_BENCHMARK="$METRICS_DIR/setup_benchmarks.env"

if [ "$MASTER_SETUP" != "true" ]; then
  echo -e "${CYAN}==================================================================${NC}"
  echo "------------------------------------------------------------------"
  echo -e "📝 Lokaalne paigalduse logi: ${CYAN}$LOG_FILE${NC}"
  echo -e "📊 Git-is jälgitavad mõõdikud: ${CYAN}$JSON_BENCHMARK${NC}"
  echo -e "${CYAN}==================================================================${NC}"
fi

# Database parameters
SYS_PASSWORD="${SYS_PASSWORD:-}"
if [ -z "$SYS_PASSWORD" ]; then
  if [ -n "$CONTAINER_NAME" ] && podman container exists "$CONTAINER_NAME" 2>/dev/null && [ "$(podman inspect --format='{{.State.Status}}' "$CONTAINER_NAME" 2>/dev/null)" = "running" ]; then
    SYS_PASSWORD=$(podman exec "$CONTAINER_NAME" cat "/run/secrets/oracle_pwd" 2>/dev/null || podman exec "$CONTAINER_NAME" cat "/run/secrets/$SYS_PWD_SECRET" 2>/dev/null || true)
  fi
  if [ -z "$SYS_PASSWORD" ]; then
    SYS_PASSWORD=$(podman secret inspect --showsecret apex_db_sys_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
  fi
  if [ -z "$SYS_PASSWORD" ] && [ -n "$SYS_PWD_SECRET" ]; then
    SYS_PASSWORD=$(podman secret inspect --showsecret "$SYS_PWD_SECRET" 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
  fi
  SYS_PASSWORD="${SYS_PASSWORD:-$APEX_DB_SYS_PASSWORD}"
fi
DB_HOST="${APEX_DB_HOST:-${PROFILE_DB_HOST:-localhost}}"
DB_PORT="${APEX_DB_PORT:-${PROFILE_DB_PORT:-1532}}"
DB_SERVICE="${APEX_DB_SERVICE:-${PROFILE_DEFAULT_SERVICE:-FREEPDB1}}"

START_TOTAL=$(date +%s)

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

copy_static_images_to_volume() {
  if [ "$EXEC_MODE" = "CONTAINER" ]; then
    echo "📦 Kopeerin APEX staatilised pildid ühisesse volume-i (/opt/oracle/apex_images/)..."
    podman exec -u root "$CONTAINER_NAME" mkdir -p /opt/oracle/apex_images /tmp/apex_install
    podman exec -u root "$CONTAINER_NAME" chown -R oracle:oinstall /opt/oracle/apex_images /tmp/apex_install || true
    
    # If /tmp/apex_install is empty or missing images, copy and unzip APEX_ZIP into /tmp/apex_install
    if ! podman exec "$CONTAINER_NAME" test -d /tmp/apex_install/apex/images 2>/dev/null && ! podman exec "$CONTAINER_NAME" test -d /tmp/apex_install/images 2>/dev/null; then
      if [ -f "$APEX_ZIP" ]; then
        podman cp "$APEX_ZIP" "$CONTAINER_NAME":/tmp/apex-latest.zip
        podman exec -u root "$CONTAINER_NAME" chmod 644 /tmp/apex-latest.zip || true
        podman exec -u root "$CONTAINER_NAME" chown -R oracle:oinstall /tmp/apex-latest.zip || true
        podman exec -u root "$CONTAINER_NAME" unzip -o -q /tmp/apex-latest.zip -d /tmp/apex_install/ || true
      fi
    fi

    podman exec -u root "$CONTAINER_NAME" rm -rf /opt/oracle/apex_images/images || true
    podman exec -u root "$CONTAINER_NAME" sh -c 'if [ -d /tmp/apex_install/apex/images ]; then cp -R /tmp/apex_install/apex/images /opt/oracle/apex_images/; elif [ -d /tmp/apex_install/images ]; then cp -R /tmp/apex_install/images /opt/oracle/apex_images/; fi'
    podman exec -u root "$CONTAINER_NAME" chown -R oracle:oinstall /opt/oracle/apex_images || true
    echo "$APEX_ZIP_NAME" | podman exec -i "$CONTAINER_NAME" tee /opt/oracle/apex_images/.unzipped_source >/dev/null
    podman exec -u root "$CONTAINER_NAME" rm -rf /tmp/apex-latest.zip /tmp/apex_install || true
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

download_file() {
  local url="$1"
  local dest="$2"
  
  mkdir -p "$(dirname "$dest")"
  
  if grep -qi microsoft /proc/version 2>/dev/null && command -v powershell.exe &>/dev/null; then
    echo "WSL2 tuvastatud. Kasutan faili allalaadimiseks Windowsi PowerShelli (korporatiivse VPN/Proxy läbimiseks)..."
    local win_dest=$(wslpath -w "$dest" 2>/dev/null || echo "$dest")
    
    if powershell.exe -NoProfile -Command "Invoke-WebRequest -Uri '$url' -OutFile '$win_dest' -UseBasicParsing" &>/dev/null; then
      echo "✅ Allalaadimine õnnestus PowerShelliga (otseühendus)."
      return 0
    fi
    
    if powershell.exe -NoProfile -Command "Invoke-WebRequest -Uri '$url' -OutFile '$win_dest' -UseBasicParsing -ProxyUseDefaultCredentials" &>/dev/null; then
      echo "✅ Allalaadimine õnnestus PowerShelliga (süsteemi proxy auth)."
      return 0
    fi
    echo "PowerShell allalaadimine ebaõnnestus, proovin kohalikku curl-i..."
  fi
  
  curl -L -o "$dest" "$url"
}

get_step_stats() {
  local step_key1="$1"
  local step_key2="$2"
  local default_est="$3"
  local values=()
  if [ -d "$METRICS_DIR" ]; then
    for f in "$METRICS_DIR"/setup_benchmarks_*.json; do
      if [ -f "$f" ]; then
        local val=$(grep -m1 -E "\"($step_key1|$step_key2)\":" "$f" | awk -F: '{print $2}' | tr -d ' ,"\r\n' || echo "")
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
  echo -e "${CYAN}├─${NC} ${YELLOW}[Alamsamm 6.${sub_num}]: ${title}${NC}"
  if [ -n "$step_key1" ]; then
    echo -e "${CYAN}│${NC}  📊 Ajalooline ooteaeg: ${YELLOW}$(get_step_stats "$step_key1" "$step_key2" "$default_est")${NC}"
  elif [ -n "$default_est" ]; then
    echo -e "${CYAN}│${NC}  📊 Ajalooline ooteaeg: ${YELLOW}ootusaeg ~${default_est}${NC}"
  fi
}

# ----------------------------------------------------------------------------
# 1. ORDS Teenuse ja seadistuse kontroll
# ----------------------------------------------------------------------------
STEP1_START=$(date +%s)
print_sub_header "1" "Checking ORDS Service & Database Readiness..." "step1_ords_setup_seconds" "step5_ords_service_seconds" "1s"

ords_c_check="${PROFILE_ORDS_CONTAINER_NAME:-oracle-ords-dev}"
if podman container exists "$ords_c_check" 2>/dev/null; then
  echo "ORDS konteiner ($ords_c_check) on aktiivne."
fi
STEP1_SECS=$(($(date +%s) - STEP1_START))
ORDS_JSON="$METRICS_DIR/ords_setup_benchmarks.json"
if [ -f "$ORDS_JSON" ]; then
  ORDS_BENCHMARK_SECS=$(grep -o '"total_duration_seconds": [0-9]*' "$ORDS_JSON" | grep -o '[0-9]*' || echo "35")
  STEP1_SECS=$ORDS_BENCHMARK_SECS
fi
STEP1_TIME=$(format_duration $STEP1_SECS)
echo -e "⏱  [Samm 1 valmis (ORDS seadistus): ${YELLOW}$STEP1_TIME${NC}]"

# ----------------------------------------------------------------------------
# 2. APEX Tarkvarapaketi kontroll ja lahtipakkimine
# ----------------------------------------------------------------------------
STEP2_START=$(date +%s)
print_sub_header "2" "Checking Oracle APEX Software Source..." "step2_download_unzip_seconds" "step3_apex_download_unzip_seconds" "1s"
# Kontrollime lokaalseid APEX zip failide versioone (apex-latest.zip -> spetsiifiline fail -> allalaadimine)
get_apex_zip_version() {
  local zfile="$1"
  if [ -f "$zfile" ]; then
    unzip -p "$zfile" apex/images/apex_version.txt 2>/dev/null | grep -o -E '[0-9]+\.[0-9]+' | head -n 1 || echo ""
  fi
}

BINARIES_DIR="$SCRIPT_DIR/../../binaries"
mkdir -p "$BINARIES_DIR"
TARGET_APEX_ZIP=""

# 1. Kui apex-latest.zip on olemas ja tema versioon vastab nõutud APEX_VER versioonile, siis kasutatakse seda
if [ -f "$BINARIES_DIR/apex-latest.zip" ]; then
  LATEST_VER=$(get_apex_zip_version "$BINARIES_DIR/apex-latest.zip")
  if [ -n "$LATEST_VER" ] && [[ "$LATEST_VER" == "$APEX_VER"* ]]; then
    TARGET_APEX_ZIP="$BINARIES_DIR/apex-latest.zip"
    echo "Leitud olemasolev apex-latest.zip versiooniga $LATEST_VER (sobib nõutud APEX $APEX_VER versiooniga)."
  fi
fi

# 2. Kui apex-latest.zip ei sobi või puudub, kontrollime profiili URL-i kohast zip-faili
if [ -z "$TARGET_APEX_ZIP" ]; then
  APEX_URL_ZIP_NAME=$(basename "$APEX_URL")
  EXPECTED_ZIP="$BINARIES_DIR/$APEX_URL_ZIP_NAME"
  if [ -f "$EXPECTED_ZIP" ]; then
    EXPECTED_VER=$(get_apex_zip_version "$EXPECTED_ZIP")
    if [ -n "$EXPECTED_VER" ] && [[ "$EXPECTED_VER" == "$APEX_VER"* ]]; then
      TARGET_APEX_ZIP="$EXPECTED_ZIP"
      echo "Leitud olemasolev $APEX_URL_ZIP_NAME versiooniga $EXPECTED_VER (sobib nõutud APEX $APEX_VER versiooniga)."
    fi
  fi
fi

# 3. Kui vajalikku versiooni lokaalselt ei ole, laadime selle alla profiili URL-ilt
if [ -z "$TARGET_APEX_ZIP" ]; then
  APEX_URL_ZIP_NAME=$(basename "$APEX_URL")
  TARGET_APEX_ZIP="$BINARIES_DIR/$APEX_URL_ZIP_NAME"
  echo "Lokaalsest kataloogist ei leitud nõutud APEX versiooni $APEX_VER. Laadin alla aadressilt: $APEX_URL..."
  download_file "$APEX_URL" "$TARGET_APEX_ZIP"
fi

APEX_ZIP="$TARGET_APEX_ZIP"
APEX_ZIP_NAME=$(basename "$APEX_ZIP")

STEP2_SECS=$(($(date +%s) - STEP2_START))
STEP2_TIME=$(format_duration $STEP2_SECS)
echo -e "⏱  [Samm 2 valmis (APEX allalaadimine): ${YELLOW}$STEP2_TIME${NC}]"

# ----------------------------------------------------------------------------
# 3. CLI Tööriista tuvastamine ja režiimi valik
# ----------------------------------------------------------------------------
STEP3_START=$(date +%s)
print_sub_header "3" "Preparing Connection and Copying Files if required..." "step3_copy_container_seconds" "step6_apex_copy_container_seconds" "5s"

# Automaatne lokaalse konteineri kontroll ja käivitamine
IS_CONTAINER_AVAIL=false
if [ "$DB_HOST" = "localhost" ] || [ "$DB_HOST" = "127.0.0.1" ] || [ "$DB_HOST" = "$CONTAINER_NAME" ]; then
  if podman container exists "$CONTAINER_NAME" 2>/dev/null; then
    IS_CONTAINER_AVAIL=true
    STATUS=$(podman container inspect --format='{{.State.Status}}' "$CONTAINER_NAME" 2>/dev/null || echo "stopped")
    if [ "$STATUS" != "running" ]; then
      echo "Lokaalne andmebaas ($CONTAINER_NAME) ei tööta. Käivitan..."
      podman compose up -d "$CONTAINER_NAME"
    fi
    echo "Ootan kuni andmebaas ($CONTAINER_NAME) on valmis (healthy)..."
    until [ "$(podman inspect --format='{{.State.Health.Status}}' "$CONTAINER_NAME" 2>/dev/null)" == "healthy" ]; do
      sleep 3
    done
  fi
fi

EXEC_MODE="CLIENT"
# Eelistame alati CONTAINER režiimi kohalikus arenduses (et vältida Defenderi skaneerimise lag-i host-masinas)
if [ "$IS_CONTAINER_AVAIL" = "true" ]; then
  echo "Tuvastati kohalik konteiner $CONTAINER_NAME."
  echo "Kasutan konteineri režiimi (unzip + paigaldus otse konteineris, et vältida Defenderi viivitusi)..."
  EXEC_MODE="CONTAINER"
  
  # 1. Kopeerime ZIP-faili konteinerisse (üks suur fail, kopeerub sekundiga)
  echo "Kopeerin APEX zip-faili konteinerisse..."
  podman exec -u root "$CONTAINER_NAME" rm -rf /tmp/apex_install /tmp/apex-latest.zip || true
  podman exec -u root "$CONTAINER_NAME" mkdir -p /tmp/apex_install
  podman cp "$APEX_ZIP" "$CONTAINER_NAME":/tmp/apex-latest.zip
  podman exec -u root "$CONTAINER_NAME" chmod 644 /tmp/apex-latest.zip || true
  podman exec -u root "$CONTAINER_NAME" chown -R oracle:oinstall /tmp/apex-latest.zip /tmp/apex_install || true
  
  # 2. Pakime lahti konteineri sees (host-süsteemi viirusetõrje seda ei kontrolli)
  echo "Pakin APEX-i lahti konteineri sees..."
  podman exec "$CONTAINER_NAME" unzip -o -q /tmp/apex-latest.zip -d /tmp/apex_install/ || true
  
  APEX_SOURCE_DIR="/tmp/apex_install/apex"
  REST_PATH="/tmp/apex_install/apex"
  DB_CLI="podman exec -i -w $APEX_SOURCE_DIR $CONTAINER_NAME sqlplus -s"
  CONN_STR="sys/${SYS_PASSWORD}@localhost:1521/$DB_SERVICE as sysdba"
else
  # Client-side execution (kui konteinerit pole või on tegu täiesti eraldiseisva/kaug-andmebaasiga)
  # Siin peame pakkima lahti hostis
  echo "Kasutan host-süsteemi režiimi (CLIENT)..."
  NEED_UNZIP=false
  TARGET_DIR="$SCRIPT_DIR/../../db-install/apex_${APEX_VER}"
  if [ ! -d "$TARGET_DIR/apex" ] || [ ! -f "$TARGET_DIR/.unzipped_source" ] || [ "$(cat "$TARGET_DIR/.unzipped_source" 2>/dev/null)" != "$APEX_ZIP_NAME" ]; then
    NEED_UNZIP=true
  fi
  if [ "$NEED_UNZIP" = "true" ]; then
    echo "Pakin APEX-i lahti host-süsteemis..."
    rm -rf "$TARGET_DIR"
    mkdir -p "$TARGET_DIR"
    unzip -o -q "$APEX_ZIP" -d "$TARGET_DIR"
    echo "$APEX_ZIP_NAME" > "$TARGET_DIR/.unzipped_source"
  fi
  
  if command -v sql &> /dev/null; then
    DB_CLI="sql -s"
    CONN_STR="sys/${SYS_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_SERVICE} as sysdba"
    APEX_SOURCE_DIR="$TARGET_DIR/apex"
    REST_PATH="."
  elif command -v sqlplus &> /dev/null; then
    DB_CLI="sqlplus -s"
    CONN_STR="sys/${SYS_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_SERVICE} as sysdba"
    APEX_SOURCE_DIR="$TARGET_DIR/apex"
    REST_PATH="."
  else
    echo "❌ Viga: Ei leidnud SQLcl ega SQL*Plus utiliite host-süsteemist!"
    exit 1
  fi
fi

STEP3_SECS=$(($(date +%s) - STEP3_START))
STEP3_TIME=$(format_duration $STEP3_SECS)
echo -e "⏱  [Samm 3 valmis (Seadistus / Failide kopeerimine): ${YELLOW}$STEP3_TIME${NC}]"

# ----------------------------------------------------------------------------
# 4. APEX mootori paigaldamine andmebaasis
# ----------------------------------------------------------------------------
# Define dedicated log file for SQL details
STEP4_START=$(date +%s)
SQL_LOG_FILE="$LOG_DIR/apex_sql_install_${TIMESTAMP}.log"

print_sub_header "4" "Running APEX Installation in $DB_SERVICE via $EXEC_MODE (Oodatav aeg ~4-7 min)..." "step4_apex_engine_install_seconds" "step7_apex_engine_install_seconds" "6m"
echo -e "${CYAN}│${NC}  📝 Detailne SQL logi: ${CYAN}[Logi](file://$SQL_LOG_FILE)${NC}"

# Kui käivitatakse kliendi-režiimis, peame minema apex kataloogi sisse
# Kontrollime kas andmebaasis on juba sama või uuem kehtiv APEX versioon
SKIP_APEX_ENGINE_INSTALL=false
echo "Kontrollin andmebaasis installeeritud APEX-i olekut..."
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

# Parse target APEX version from URL or zip name
TARGET_APEX_VER=$(echo "$APEX_URL" | grep -o -E "apex_[0-9]+\.[0-9]+" | cut -d'_' -f2 || echo "26.1")

if [ "$DB_APEX_STATUS" = "VALID" ] && [ -n "$DB_APEX_VER" ]; then
  db_val=$(version_to_int "$DB_APEX_VER")
  target_val=$(version_to_int "$TARGET_APEX_VER")
  if [ $db_val -ge $target_val ]; then
    SKIP_APEX_ENGINE_INSTALL=true
  fi
fi

if [ "$SKIP_APEX_ENGINE_INSTALL" = "true" ]; then
  echo "✅ Andmebaasis on juba paigaldatud ja kehtiv APEX versioon $DB_APEX_VER (soovitud: $TARGET_APEX_VER). Jätan mootori installeerimise vahele."
  copy_static_images_to_volume
  STEP4_SECS=0
else
  # Kui käivitatakse kliendi-režiimis, peame minema apex kataloogi sisse
  if [ "$EXEC_MODE" = "CLIENT" ]; then
    cd "$APEX_SOURCE_DIR"
  fi

  $DB_CLI "$CONN_STR" > "$SQL_LOG_FILE" 2>&1 << EOF &
-- Drop partial APEX schemas if present to allow clean fresh installation
ALTER SESSION SET "_oracle_script" = TRUE;
BEGIN
    EXECUTE IMMEDIATE 'DROP USER APEX_260100 CASCADE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP USER APEX_240100 CASCADE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP USER APEX_230200 CASCADE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- Run main APEX installation: @apexins.sql tablespace_apex tablespace_files tablespace_temp images
@apexins.sql SYSAUX SYSAUX TEMP /i/
YES

-- Set up APEX REST users (APEX_LISTENER and APEX_REST_PUBLIC_USER)
@apex_rest_config_core.sql "${REST_PATH}" "${APEX_LISTENER_PASSWORD}" "${APEX_LISTENER_PASSWORD}"

-- Set APEX Instance Admin Password
BEGIN
    APEX_UTIL.set_security_group_id( 10 );
    APEX_UTIL.create_user(
        p_user_name                    => '${APEX_ADMIN_USER:-ADMIN}',
        p_email_address                => '${APEX_ADMIN_EMAIL:-${PROFILE_APEX_ADMIN_EMAIL:-admin@company.com}}',
        p_web_password                 => '${APEX_ADMIN_PASSWORD}',
        p_developer_privs              => 'ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:VARIABLE',
        p_change_password_on_first_use => 'N'
    );
    COMMIT;
END;
/

-- Create APEX Workspace for Application
BEGIN
    APEX_INSTANCE_ADMIN.add_workspace(
        p_workspace_id   => NULL,
        p_workspace      => '${APEX_WORKSPACE:-${PROFILE_APEX_WORKSPACE:-PROXY_WORKSPACE}}',
        p_primary_schema => '${APEX_SCHEMA_USER:-${PROFILE_APEX_SCHEMA_USER:-APEX_PROXY_SCHEMA}}'
    );
    COMMIT;
END;
/

-- Create Developer user ADMIN inside Workspace
DECLARE
    v_workspace_id NUMBER;
BEGIN
    v_workspace_id := APEX_UTIL.find_security_group_id('${APEX_WORKSPACE:-${PROFILE_APEX_WORKSPACE:-PROXY_WORKSPACE}}');
    APEX_UTIL.set_security_group_id(v_workspace_id);
    APEX_UTIL.create_user(
        p_user_name                    => '${APEX_ADMIN_USER:-ADMIN}',
        p_email_address                => '${APEX_ADMIN_EMAIL:-${PROFILE_APEX_ADMIN_EMAIL:-admin@company.com}}',
        p_web_password                 => '${APEX_ADMIN_PASSWORD}',
        p_developer_privs              => 'ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:VARIABLE',
        p_change_password_on_first_use => 'N'
    );
    COMMIT;
END;
/
    COMMIT;
END;
/

EXIT;
EOF

  SQL_PID=$!

  # Kuvame sekundite tiksujat teatud intervalliga
  ELAPSED=0
  while kill -0 $SQL_PID 2>/dev/null; do
    sleep 3
    ELAPSED=$((ELAPSED + 3))
    print_progress "   Paigaldan APEX mootorit... kestus: ${ORANGE}$(format_duration $ELAPSED)${NC}\r"
  done
  wait $SQL_PID
  echo ""
  echo "✅ APEX mootori paigaldamine lõpetatud!"

  copy_static_images_to_volume

  # Tuleme tagasi projekti juurkausta kui olime kliendi-režiimis
  if [ "$EXEC_MODE" = "CLIENT" ]; then
    cd ..
  fi

  STEP4_SECS=$(($(date +%s) - STEP4_START))
fi

STEP4_TIME=$(format_duration $STEP4_SECS)
echo -e "⏱  [Samm 4 valmis (APEX mootor): ${YELLOW}$STEP4_TIME${NC}]"

# ----------------------------------------------------------------------------
# 4.1. ORDS Konfiguratsiooni uuendamine (plsql.gateway.mode = proxied)
# ----------------------------------------------------------------------------
ORDS_CONF_START=$(date +%s)

ords_found=$(podman ps --format '{{.Names}}' | grep -E '^oracle-ords-dev|^ords-|^oracle-ords-' | head -n 1 || echo "oracle-ords-dev")
ORDS_CONTAINER="${PROFILE_ORDS_CONTAINER_NAME:-$ords_found}"
ORDS_CONF_LOG="$LOG_DIR/ords_configure_${DB_SUFFIX}_${TIMESTAMP}.log"

if [ "$SKIP_ORDS" = "false" ] && podman container exists "$ORDS_CONTAINER" 2>/dev/null; then
  echo "=================================================================="
  echo "Kontrollin ORDS ($ORDS_CONTAINER) gateway režiimi (plsql.gateway.mode = proxied)..."
  echo "📝 Logifail: [Logi](file://$ORDS_CONF_LOG)"
  echo "=================================================================="
  {
    podman exec "$ORDS_CONTAINER" ords --config /etc/ords/config config --db-pool default set plsql.gateway.mode proxied 2>/dev/null || true
  } > "$ORDS_CONF_LOG" 2>&1 || true
fi

ORDS_CONF_SECS=$(( $(date +%s) - ORDS_CONF_START ))
ORDS_CONF_TIME=$(format_duration $ORDS_CONF_SECS)
echo -e "⏱  [ORDS konfigureerimine valmis: ${YELLOW}$ORDS_CONF_TIME${NC}]"

# ----------------------------------------------------------------------------
# 5. Automaatne APEX Patchi paigaldamine (kui patches/ kataloogis on .zip fail)
# ----------------------------------------------------------------------------
STEP5_START=$(date +%s)
PATCHES_DIR="$SCRIPT_DIR/../../patches"
PATCH_SCRIPT="$SCRIPT_DIR/apply-apex-patch.sh"

if [ -d "$PATCHES_DIR" ] && [ -x "$PATCH_SCRIPT" ]; then
  APEX_VER_CLEAN=$(echo "$APEX_VER" | tr -d '.')
  LATEST_PATCH=$(find "$PATCHES_DIR" -maxdepth 1 \( -name "p*_${APEX_VER_CLEAN}_*.zip" -o -name "p*_${APEX_VER}_*.zip" \) -type f | sort -V | tail -n 1)

  if [ -n "$LATEST_PATCH" ]; then
    echo ""
    print_sub_header "5" "Leitud APEX patch: $(basename "$LATEST_PATCH") - Käivitan automaatse paigalduse..." "step5_apex_patch_install_seconds" "step9_apex_patch_install_seconds" "30s"
    if [ "$SKIP_ORDS" = "true" ]; then
      "$PATCH_SCRIPT" "$LATEST_PATCH" --no-ords
    else
      "$PATCH_SCRIPT" "$LATEST_PATCH"
    fi
    STEP5_SECS=$(( $(date +%s) - STEP5_START ))
    STEP5_TIME=$(format_duration $STEP5_SECS)
    echo -e "⏱  [Samm 5 valmis (APEX Patch): ${YELLOW}$STEP5_TIME${NC}]"
  else
    STEP5_SECS=0
    STEP5_TIME="vahele jäetud"
    echo "5. Patches/ kataloogis ei leitud ühtegi .zip patchi — vahele jäetud."
  fi
else
  STEP5_SECS=0
  STEP5_TIME="vahele jäetud"
  echo "5. Patches/ kataloog puudub — vahele jäetud."
fi

TOTAL_SECS=$(( $(date +%s) - START_TOTAL ))
TOTAL_TIME=$(format_duration $TOTAL_SECS)

# ----------------------------------------------------------------------------
# 6. Salvestame mõõdikud kataloogi ./metrics/ (Git-i jaoks)
# ----------------------------------------------------------------------------
# Define timestamped JSON file name
JSON_TS_BENCHMARK="$METRICS_DIR/setup_benchmarks_${TIMESTAMP}.json"

cat << EOF > "$JSON_TS_BENCHMARK"
{
  "last_updated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "total_duration_seconds": $TOTAL_SECS,
  "total_duration_formatted": "$TOTAL_TIME",
  "parameters": {
    "exec_mode": "$EXEC_MODE",
    "db_host": "$DB_HOST",
    "db_port": "$DB_PORT",
    "db_service": "$DB_SERVICE"
  },
  "steps": {
    "step1_ords_setup_seconds": $STEP1_SECS,
    "step2_download_unzip_seconds": $STEP2_SECS,
    "step3_copy_container_seconds": $STEP3_SECS,
    "step4_apex_engine_install_seconds": $STEP4_SECS,
    "step4_1_ords_config_seconds": $ORDS_CONF_SECS,
    "step5_apex_patch_install_seconds": $STEP5_SECS
  }
}
EOF

# Copy the latest to setup_benchmarks.json
cp "$JSON_TS_BENCHMARK" "$JSON_BENCHMARK"

# Keep only the last 10 setup benchmark runs in metrics/
(cd "$METRICS_DIR" && ls -t setup_benchmarks_*.json 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null || true)

cat << EOF > "$ENV_BENCHMARK"
# APEX & ORDS Setup Benchmark Metrics (Updated: $(date))
SETUP_TOTAL_SECS=$TOTAL_SECS
SETUP_STEP1_ORDS_SECS=$STEP1_SECS
SETUP_STEP2_DOWNLOAD_SECS=$STEP2_SECS
SETUP_STEP3_COPY_SECS=$STEP3_SECS
SETUP_STEP4_ENGINE_SECS=$STEP4_SECS
SETUP_STEP4_1_ORDS_CONF_SECS=$ORDS_CONF_SECS
SETUP_STEP5_PATCH_SECS=$STEP5_SECS
EOF

echo ""
echo -e "${CYAN}==================================================================${NC}"
echo -e "${CYAN}⏱   KOKKUVÕTLIKUD MÕÕDIKUD (SETUP BENCHMARK METRICS)${NC}"
echo -e "${CYAN}==================================================================${NC}"
echo -e "  1. ORDS Teenuse seadistus:     ${YELLOW}$STEP1_TIME (${STEP1_SECS}s)${NC}"
echo -e "  2. APEX Tarkvarapakett:        ${YELLOW}$STEP2_TIME (${STEP2_SECS}s)${NC}"
echo -e "  3. Failide seadistus/kopeerimine: ${YELLOW}$STEP3_TIME (${STEP3_SECS}s)${NC}"
echo -e "  4. APEX Mootori install (DB):  ${YELLOW}$STEP4_TIME (${STEP4_SECS}s)${NC}"
echo -e "  5. ORDS konfigureerimine:      ${YELLOW}$ORDS_CONF_TIME (${ORDS_CONF_SECS}s)${NC}"
echo -e "  6. APEX Patchi install (DB):   ${YELLOW}$STEP5_TIME (${STEP5_SECS}s)${NC}"
echo "  ------------------------------------------------------------"
echo -e "  ⌛ KOGU PAIGALDUSE KESTUS:     ${GREEN}$TOTAL_TIME (${TOTAL_SECS}s)${NC}"
echo -e "${CYAN}==================================================================${NC}"
if [ "$MASTER_SETUP" != "true" ]; then
  echo "📊 Mõõdikud salvestati Git-i kausta: $JSON_BENCHMARK"
  echo "------------------------------------------------------------------"
  echo "📝 Lokaalne logi salvestati:        $LOG_FILE"
  echo "✅ Oracle APEX & ORDS paigaldusprotsess lõpetatud!"
  echo "=================================================================="
fi
