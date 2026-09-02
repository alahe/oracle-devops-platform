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

if [ -f "$SCRIPT_DIR/common.sh" ]; then
  source "$SCRIPT_DIR/common.sh"
fi
if [ -f "$SCRIPT_DIR/snapshot-resolver.sh" ]; then
  source "$SCRIPT_DIR/snapshot-resolver.sh"
fi

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
RUNTIME_ONLY=false
TARGET_DB=""
TARGET_VER=""
TARGET_PORT=""
TARGET_SERVICE=""

while [[ "$#" -gt 0 ]]; do
  case $1 in
    --no-ords) SKIP_ORDS=true ;;
    --runtime-only|--apex-runtime) RUNTIME_ONLY=true ;;
    --db) TARGET_DB="$2"; shift ;;
    --version) TARGET_VER="$2"; shift ;;
    --port) TARGET_PORT="$2"; shift ;;
    --service) TARGET_SERVICE="$2"; shift ;;
  esac
  shift
done

# Dünaamiline instantsi ja konteineri tuvastamine profiilide ja topoloogia põhjal
if [ -n "$TARGET_DB" ]; then
  raw_target=$(echo "$TARGET_DB" | sed 's/^db-//' | tr '_' '-')
  if podman container exists "db-$raw_target" 2>/dev/null; then
    CONTAINER_NAME="db-$raw_target"
  elif podman container exists "$TARGET_DB" 2>/dev/null; then
    CONTAINER_NAME="$TARGET_DB"
  elif podman container exists "oracle-db-$raw_target" 2>/dev/null; then
    CONTAINER_NAME="oracle-db-$raw_target"
  else
    CONTAINER_NAME="db-$raw_target"
  fi
else
  c_found=$(get_active_db_instances 2>/dev/null | grep -v "publisher" | head -n 1 | cut -d'|' -f1 || echo "")
  CONTAINER_NAME="${c_found:-db-proxy}"
fi

DB_SUFFIX=$(echo "$CONTAINER_NAME" | sed 's/^db-//' | tr '-' '_')
DB_HOST="${DB_HOST:-localhost}"
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

if declare -f ensure_db_instance_open >/dev/null 2>&1; then
  ensure_db_instance_open "$CONTAINER_NAME" || true
fi

if [ "$APEX_VER" = "NONE" ]; then
  echo "ℹ️  APEX_VERSION on määratud NONE andmebaasile $DB_SUFFIX — Jätan APEX paigaldamise vahele."
  exit 0
fi

# In-DB APEX Idempotency & Skip Check:
if declare -f can_skip_in_db_apex >/dev/null 2>&1; then
  if can_skip_in_db_apex "$CONTAINER_NAME" "$APEX_VER"; then
    exit 0
  fi
fi

APEX_URL="${APEX_DOWNLOAD_URL:-${RESOLVED_APEX_URL:-${PROFILE_APEX_DOWNLOAD_URL:-https://download.oracle.com/otn_software/apex/apex_26.1_en.zip}}}"
APEX_ZIP_NAME=$(basename "$APEX_URL")
APEX_BIN_DIR="$SCRIPT_DIR/../../binaries/apex"
APEX_ZIP="$APEX_BIN_DIR/$APEX_ZIP_NAME"
[ ! -f "$APEX_ZIP" ] && [ -f "$SCRIPT_DIR/../../binaries/$APEX_ZIP_NAME" ] && APEX_ZIP="$SCRIPT_DIR/../../binaries/$APEX_ZIP_NAME"
[ ! -f "$APEX_ZIP" ] && [ -f "$APEX_BIN_DIR/apex-latest.zip" ] && APEX_ZIP="$APEX_BIN_DIR/apex-latest.zip"
[ ! -f "$APEX_ZIP" ] && [ -f "$SCRIPT_DIR/../../binaries/apex-latest.zip" ] && APEX_ZIP="$SCRIPT_DIR/../../binaries/apex-latest.zip"

# Artifactory LAN Fallback: Download from enterprise catalog if missing locally
if [ ! -f "$APEX_ZIP" ] && declare -f artifactory_is_configured >/dev/null 2>&1 && artifactory_is_configured; then
  mkdir -p "$APEX_BIN_DIR"
  if artifactory_fetch_binary "apex" "$APEX_ZIP_NAME" "$APEX_BIN_DIR/$APEX_ZIP_NAME"; then
    APEX_ZIP="$APEX_BIN_DIR/$APEX_ZIP_NAME"
  elif artifactory_fetch_binary "apex" "apex-latest.zip" "$APEX_BIN_DIR/apex-latest.zip"; then
    APEX_ZIP="$APEX_BIN_DIR/apex-latest.zip"
  fi
fi

# 1. Lokaalsed paigalduse logid (ei lähe Git-i)
LOG_DIR="$SCRIPT_DIR/../../install_logs"
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$LOG_DIR/apex_engine_install_${DB_SUFFIX}_${TIMESTAMP}.log"

# Suuname kogu väljundi nii ekraanile kui lokaalsesse logifaili (ainult eraldiseisval käivitamisel)
if [ "${MASTER_SETUP:-false}" != "true" ]; then
  exec > >(tee -a "$LOG_FILE") 2>&1
fi

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

APEX_LISTENER_PASSWORD="${APEX_LISTENER_PASSWORD:-}"
if [ -z "$APEX_LISTENER_PASSWORD" ]; then
  if [ -n "$CONTAINER_NAME" ] && podman container exists "$CONTAINER_NAME" 2>/dev/null; then
    APEX_LISTENER_PASSWORD=$(podman exec "$CONTAINER_NAME" cat "/run/secrets/ords_listener_password" 2>/dev/null || podman exec "$CONTAINER_NAME" cat "/run/secrets/apex_schema_password" 2>/dev/null || true)
  fi
  if [ -z "$APEX_LISTENER_PASSWORD" ]; then
    APEX_LISTENER_PASSWORD=$(podman secret inspect --showsecret ords_listener_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || podman secret inspect --showsecret apex_schema_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
  fi
  APEX_LISTENER_PASSWORD="${APEX_LISTENER_PASSWORD:-$SYS_PASSWORD}"
fi
APEX_ADMIN_PASSWORD="${APEX_ADMIN_PASSWORD:-}"
DB_SUFFIX_UPPER=$(echo "$DB_SUFFIX" | tr '[:lower:]' '[:upper:]')
if [ -z "$APEX_ADMIN_PASSWORD" ] || [ "$APEX_ADMIN_PASSWORD" = "$SYS_PASSWORD" ]; then
  wallet_admin_pwd=$("$SCRIPT_DIR/../get-password.sh" -p "DB_${DB_SUFFIX_UPPER}_APEX_ADMIN" 2>/dev/null | tr -d '\r\n')
  [ -z "$wallet_admin_pwd" ] && wallet_admin_pwd=$("$SCRIPT_DIR/../get-password.sh" -p "APEX_ADMIN" 2>/dev/null | tr -d '\r\n')
  [ -n "$wallet_admin_pwd" ] && APEX_ADMIN_PASSWORD="$wallet_admin_pwd"
fi
APEX_ADMIN_PASSWORD="${APEX_ADMIN_PASSWORD:-$SYS_PASSWORD}"

USER_DEV_PASSWORD="${USER_DEV_PASSWORD:-}"
if [ -z "$USER_DEV_PASSWORD" ]; then
  wallet_dev_pwd=$("$SCRIPT_DIR/../get-password.sh" -p "DB_${DB_SUFFIX_UPPER}_DEV" 2>/dev/null | tr -d '\r\n')
  [ -z "$wallet_dev_pwd" ] && wallet_dev_pwd=$("$SCRIPT_DIR/../get-password.sh" -p "DEV" 2>/dev/null | tr -d '\r\n')
  [ -n "$wallet_dev_pwd" ] && USER_DEV_PASSWORD="$wallet_dev_pwd"
fi
USER_DEV_PASSWORD="${USER_DEV_PASSWORD:-$APEX_ADMIN_PASSWORD}"
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
    msg_print "APEX_COPY_STATIC_IMAGES_VOLUME" "/opt/oracle/apex_images/"
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

if [ -f "$SCRIPT_DIR/sanitize-logs.sh" ]; then
  source "$SCRIPT_DIR/sanitize-logs.sh"
fi

if ! command -v print_progress &> /dev/null; then
  print_progress() {
    local msg="$1"
    local elapsed="$2"
    local interval="${3:-15}"
    if declare -f print_step_progress > /dev/null 2>&1; then
      print_step_progress "$msg" "$elapsed" "$interval"
    fi
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
    echo "PowerShell download failed, trying local curl..."
  fi
  
  if ! curl -fL -o "$dest" "$url"; then
    echo "❌ ERROR: Download failed (HTTP 404 or network error: $url)"
    rm -f "$dest"
    return 1
  fi

  if [[ "$dest" == *.zip ]] && ! unzip -t "$dest" &>/dev/null; then
    echo "❌ ERROR: Downloaded file $dest is not a valid ZIP archive (URL $url returned invalid content)."
    rm -f "$dest"
    return 1
  fi
}

trap restore_cursor EXIT INT TERM

print_sub_header() {
  local sub_num="$1"
  local title="$2"
  local step_key1="$3"
  local step_key2="$4"
  local default_est="$5"
  echo -e "${CYAN}├─${NC} ${YELLOW}$(msg_str "SUB_STEP_HEADER" "$sub_num" "$title")${NC}"
  local stats=""
  if [ -n "$step_key1" ]; then
    stats=$(get_step_stats "$step_key1" "$default_est" 2>/dev/null || echo "")
    [ -z "$stats" ] && [ -n "$step_key2" ] && stats=$(get_step_stats "$step_key2" "$default_est" 2>/dev/null || echo "")
  fi
  [ -z "$stats" ] && [ -n "$default_est" ] && stats="$(msg_str "BENCHMARK_EST" "$default_est")"
  if [ -n "$stats" ]; then
    echo -e "${CYAN}│${NC}  📊 $(msg_str "BENCHMARK_LABEL") ${YELLOW}${stats}${NC}"
  fi
}

# ----------------------------------------------------------------------------
# 1. ORDS Teenuse ja seadistuse kontroll
# ----------------------------------------------------------------------------
STEP1_START=$(date +%s)
print_sub_header "1" "Checking ORDS Service & Database Readiness..." "step1_ords_setup_seconds" "step5_ords_service_seconds" "1s"

ords_c_check="${PROFILE_ORDS_CONTAINER_NAME:-oracle-ords-dev}"
if podman container exists "$ords_c_check" 2>/dev/null; then
  msg_print "ORDS_CONTAINER_ACTIVE" "$ords_c_check"
fi
STEP1_SECS=$(($(date +%s) - STEP1_START))
ORDS_JSON="$METRICS_DIR/ords_setup_benchmarks.json"
if [ -f "$ORDS_JSON" ]; then
  ORDS_BENCHMARK_SECS=$(grep -o '"total_duration_seconds": [0-9]*' "$ORDS_JSON" | grep -o '[0-9]*' || echo "35")
  STEP1_SECS=$ORDS_BENCHMARK_SECS
fi
STEP1_TIME=$(format_duration $STEP1_SECS)
echo -e "⏱  [$(msg_str "STEP_1_ORDS_SETUP_DONE" "$STEP1_TIME")]"

# ----------------------------------------------------------------------------
# 2. APEX Tarkvarapaketi kontroll ja lahtipakkimine
# ----------------------------------------------------------------------------
STEP2_START=$(date +%s)
print_sub_header "2" "Checking Oracle APEX Software Source..." "step2_download_unzip_seconds" "step3_apex_download_unzip_seconds" "1s"
# Check local APEX zip package versions (apex-latest.zip -> specific archive -> download)
get_apex_zip_version() {
  local zfile="$1"
  if [ -f "$zfile" ]; then
    unzip -p "$zfile" apex/images/apex_version.txt 2>/dev/null | grep -o -E '[0-9]+\.[0-9]+' | head -n 1 || echo ""
  fi
}

BINARIES_DIR="$SCRIPT_DIR/../../binaries/apex"
LEGACY_BIN_DIR="$SCRIPT_DIR/../../binaries"
mkdir -p "$BINARIES_DIR"
TARGET_APEX_ZIP=""

# 1. Check whether required APEX zip or apex-latest.zip exists locally
APEX_URL_ZIP_NAME=$(basename "$APEX_URL")
EXPECTED_ZIP="$BINARIES_DIR/$APEX_URL_ZIP_NAME"

if [ -f "$EXPECTED_ZIP" ] && unzip -t "$EXPECTED_ZIP" &>/dev/null; then
  TARGET_APEX_ZIP="$EXPECTED_ZIP"
  msg_print "APEX_LOCAL_ARCHIVE_FOUND" "binaries/apex/$APEX_URL_ZIP_NAME"
elif [ -f "$BINARIES_DIR/apex-latest.zip" ] && unzip -t "$BINARIES_DIR/apex-latest.zip" &>/dev/null; then
  TARGET_APEX_ZIP="$BINARIES_DIR/apex-latest.zip"
  msg_print "APEX_LOCAL_ARCHIVE_FOUND" "binaries/apex/apex-latest.zip"
elif [ -f "$BINARIES_DIR/apex_latest.zip" ] && unzip -t "$BINARIES_DIR/apex_latest.zip" &>/dev/null; then
  TARGET_APEX_ZIP="$BINARIES_DIR/apex_latest.zip"
  msg_print "APEX_LOCAL_ARCHIVE_FOUND" "binaries/apex/apex_latest.zip"
elif [ -f "$LEGACY_BIN_DIR/$APEX_URL_ZIP_NAME" ] && unzip -t "$LEGACY_BIN_DIR/$APEX_URL_ZIP_NAME" &>/dev/null; then
  TARGET_APEX_ZIP="$LEGACY_BIN_DIR/$APEX_URL_ZIP_NAME"
  msg_print "APEX_LOCAL_ARCHIVE_FOUND" "binaries/$APEX_URL_ZIP_NAME"
elif [ -f "$LEGACY_BIN_DIR/apex-latest.zip" ] && unzip -t "$LEGACY_BIN_DIR/apex-latest.zip" &>/dev/null; then
  TARGET_APEX_ZIP="$LEGACY_BIN_DIR/apex-latest.zip"
  msg_print "APEX_LOCAL_ARCHIVE_FOUND" "binaries/apex-latest.zip"
fi

# 2. Kui lokaalselt sobivat zip faili ei ole, laadime alla profiili URL-ilt või apex-latest.zip URL-ilt
if [ -z "$TARGET_APEX_ZIP" ] || [ ! -f "$TARGET_APEX_ZIP" ]; then
  TARGET_APEX_ZIP="$EXPECTED_ZIP"
  msg_print "APEX_DOWNLOADING_VER" "$APEX_VER" "$APEX_URL_ZIP_NAME"
  if ! download_file "$APEX_URL" "$TARGET_APEX_ZIP"; then
    msg_print "APEX_DOWNLOAD_INVALID_ZIP"
    LATEST_URL="https://download.oracle.com/otn_software/apex/apex-latest.zip"
    TARGET_APEX_ZIP="$BINARIES_DIR/apex-latest.zip"
    if ! download_file "$LATEST_URL" "$TARGET_APEX_ZIP"; then
      # 3. Kui ka latest URL ei toimi, otsime kaustast binaries/apex/ või binaries/ kõrgeima versiooniga kehtivat zip-arhiivi
      HIGHEST_ZIP=$(ls "$BINARIES_DIR"/apex*.zip "$LEGACY_BIN_DIR"/apex*.zip 2>/dev/null | sort -rV | while read -r f; do unzip -t "$f" &>/dev/null && echo "$f" && break; done || true)
      if [ -n "$HIGHEST_ZIP" ] && [ -f "$HIGHEST_ZIP" ]; then
        TARGET_APEX_ZIP="$HIGHEST_ZIP"
        msg_print "APEX_LOCAL_FOUND_EXISTING" "$(basename "$HIGHEST_ZIP")"
      fi
    fi
  fi
fi

APEX_ZIP="$TARGET_APEX_ZIP"
APEX_ZIP_NAME=$(basename "$APEX_ZIP")

STEP2_SECS=$(($(date +%s) - STEP2_START))
STEP2_TIME=$(format_duration $STEP2_SECS)
echo -e "⏱  [$(msg_str "STEP_2_APEX_DL_DONE" "$STEP2_TIME")]"

# ----------------------------------------------------------------------------
# 3. CLI Tööriista tuvastamine ja režiimi valik
# ----------------------------------------------------------------------------
STEP3_START=$(date +%s)
print_sub_header "3" "Preparing Connection and Copying Files if required..." "step3_copy_container_seconds" "step6_apex_copy_container_seconds" "5s"

# Automaatne lokaalse konteineri kontroll ja käivitamine
IS_CONTAINER_AVAIL=false
if [ "$DB_HOST" = "localhost" ] || [ "$DB_HOST" = "127.0.0.1" ] || [ "$DB_HOST" = "$CONTAINER_NAME" ] || podman container exists "$CONTAINER_NAME" 2>/dev/null; then
  if podman container exists "$CONTAINER_NAME" 2>/dev/null; then
    IS_CONTAINER_AVAIL=true
    STATUS=$(podman container inspect --format='{{.State.Status}}' "$CONTAINER_NAME" 2>/dev/null || echo "stopped")
    if [ "$STATUS" != "running" ]; then
      echo "Local database container ($CONTAINER_NAME) is not running. Starting..."
      podman start "$CONTAINER_NAME" || true
    fi
    if [ -x "$SCRIPT_DIR/wait-db-healthy.sh" ]; then
      "$SCRIPT_DIR/wait-db-healthy.sh" "$CONTAINER_NAME" 60
    elif [ -x "$WORKSPACE_DIR/scripts/internal/wait-db-healthy.sh" ]; then
      "$WORKSPACE_DIR/scripts/internal/wait-db-healthy.sh" "$CONTAINER_NAME" 60
    else
      echo "Waiting until database container ($CONTAINER_NAME) is healthy..."
      until [ "$(podman inspect --format='{{.State.Health.Status}}' "$CONTAINER_NAME" 2>/dev/null)" == "healthy" ] || [ "$(podman inspect --format='{{.State.Status}}' "$CONTAINER_NAME" 2>/dev/null)" == "running" ]; do
        sleep 2
      done
    fi
  fi
fi

EXEC_MODE="CLIENT"
# Prefer container mode in local development
if [ "$IS_CONTAINER_AVAIL" = "true" ]; then
  msg_print "CONTAINER_DETECTED_LOCAL" "$CONTAINER_NAME"
  msg_print "CONTAINER_MODE_DEFENDER_OPT"
  EXEC_MODE="CONTAINER"
  
  # 1. Copy ZIP archive into container
  print_progress "$(msg_str "PROGRESS_COPY_APEX_CONTAINER" "$CONTAINER_NAME")" 0 1
  podman exec -u root "$CONTAINER_NAME" rm -rf /tmp/apex_install /tmp/apex-latest.zip >/dev/null 2>&1 || true
  podman exec -u root "$CONTAINER_NAME" mkdir -p /tmp/apex_install >/dev/null 2>&1 || true
  podman cp "$APEX_ZIP" "$CONTAINER_NAME":/tmp/apex-latest.zip
  podman exec -u root "$CONTAINER_NAME" chmod 644 /tmp/apex-latest.zip >/dev/null 2>&1 || true
  
  # 2. Unpack inside container
  print_progress "$(msg_str "PROGRESS_UNZIP_APEX_CONTAINER" "$CONTAINER_NAME")" 0 1
  podman exec -u root "$CONTAINER_NAME" unzip -o -q /tmp/apex-latest.zip -d /tmp/apex_install/ >/dev/null 2>&1 || true
  # Bypass redundant interim recompilations in Phase 1 (full recompilation runs at the end in Phase 3)
  podman exec -u root "$CONTAINER_NAME" sed -i 's/sys.utl_recomp.recomp_parallel/null; -- utl_recomp/g' /tmp/apex_install/apex/coreins.sql 2>/dev/null || true
  podman exec -u root "$CONTAINER_NAME" sed -i 's/sys.utl_recomp.recomp_serial/null; -- utl_recomp/g' /tmp/apex_install/apex/coreins.sql 2>/dev/null || true
  # Fix Oracle APEX timing stack overflow (prevents ORA-01704 string literal too long on action 120)
  podman exec -u root "$CONTAINER_NAME" sed -i "s/'\^TIMING_ALL_VALUES'||//g" /tmp/apex_install/apex/core/scripts/timing_start.sql 2>/dev/null || true
  # Fix Oracle APEX define character sensitivity by making internal script calls direct relative (@@)
  podman exec -u root "$CONTAINER_NAME" sh -c "find /tmp/apex_install/apex -type f \( -name '*.sql' -o -name '*.plb' \) -exec sed -i 's/@\^PREFIX\./@@/g' {} +" 2>/dev/null || true
  # Disable fragile SQL*Plus errorlogging table writes that trigger SP2-1519 and fatal ORA-03114 disconnects during recompilation
  podman exec -u root "$CONTAINER_NAME" sh -c "find /tmp/apex_install/apex -type f -name '*.sql' -exec sed -i 's/set errorlogging on.*/set errorlogging off/g' {} +" 2>/dev/null || true
  # Bypass 25,000-line CJK PDF extra font loader to prevent PGA memory exhaustion in Free DB containers
  podman exec -u root "$CONTAINER_NAME" sh -c "echo 'prompt ...extra PDF fonts skipped' > /tmp/apex_install/apex/core/apex_install_pdf_extra_fonts_data.sql" 2>/dev/null || true
  podman exec -u root "$CONTAINER_NAME" chown -R oracle:oinstall /tmp/apex_install >/dev/null 2>&1 || true
  
  APEX_SOURCE_DIR="/tmp/apex_install/apex"
  REST_PATH="/tmp/apex_install/apex"
  DB_CLI="podman exec -i -w $APEX_SOURCE_DIR $CONTAINER_NAME sqlplus -s"
  CONN_STR="sys/${SYS_PASSWORD}@localhost:1521/$DB_SERVICE as sysdba"
else
  # Client-side execution
  echo "Using host-system mode (CLIENT)..."
  NEED_UNZIP=false
  TARGET_DIR="$SCRIPT_DIR/../../db-install/apex_${APEX_VER}"
  if [ ! -d "$TARGET_DIR/apex" ] || [ ! -f "$TARGET_DIR/.unzipped_source" ] || [ "$(cat "$TARGET_DIR/.unzipped_source" 2>/dev/null)" != "$APEX_ZIP_NAME" ]; then
    NEED_UNZIP=true
  fi
  if [ "$NEED_UNZIP" = "true" ]; then
    echo "Extracting APEX on host system..."
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
    echo "❌ Error: Neither SQLcl nor SQL*Plus CLI utilities were found on host system!"
    exit 1
  fi
fi

STEP3_SECS=$(($(date +%s) - STEP3_START))
STEP3_TIME=$(format_duration $STEP3_SECS)
echo -e "⏱  [$(msg_str "STEP_3_SETUP_COPY_DONE" "$STEP3_TIME")]"

# ----------------------------------------------------------------------------
# 4. APEX mootori paigaldamine andmebaasis
# ----------------------------------------------------------------------------
# Define dedicated log file for SQL details
STEP4_START=$(date +%s)
SQL_LOG_FILE="$LOG_DIR/apex_engine_sql_${DB_SUFFIX}_${TIMESTAMP}.log"

print_sub_header "4" "$(msg_str "SUB_STEP_4_RUNNING_APEX" "$DB_SERVICE" "$EXEC_MODE")" "step4_apex_engine_install_seconds" "step7_apex_engine_install_seconds" "6m"
echo -e "${CYAN}│${NC}  📝 $(msg_str "DETAIL_SQL_LOG_LINK" "$SQL_LOG_FILE")"

# Kui käivitatakse kliendi-režiimis, peame minema apex kataloogi sisse
# Check whether the database already has the same or newer valid APEX version
SKIP_APEX_ENGINE_INSTALL=false
msg_print "CHECKING_DB_APEX_STATUS"
DB_APEX_INFO=""
if [ "$EXEC_MODE" = "CONTAINER" ]; then
  DB_APEX_INFO=$(podman exec -i -u oracle "$CONTAINER_NAME" sh -c "export ORACLE_PDB_SID=${DB_SERVICE:-FREEPDB1}; export ORACLE_HOME=\$(ls -d /opt/oracle/product/*/dbhomeFree 2>/dev/null | head -n 1); [ -n \"\$ORACLE_HOME\" ] && export PATH=\"\$ORACLE_HOME/bin:\$PATH\"; sqlplus -s / as sysdba" <<EOF 2>/dev/null | grep -v -E "Connected to|Oracle Database|version" || echo ""
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
  msg_print "APEX_ENGINE_ALREADY_INSTALLED" "$DB_APEX_VER" "$TARGET_APEX_VER"
  copy_static_images_to_volume
  # Sünkroniseerime APEX_PUBLIC_USER ja REST liideste paroolid
  LOCAL_POST_SQL_SCRIPT="$SCRIPT_DIR/../../install_logs/run_apex_post_install_${DB_SUFFIX}.sql"
  cat << EOF > "$LOCAL_POST_SQL_SCRIPT"
SET ECHO ON;
SET SERVEROUTPUT ON;

ALTER SESSION SET CONTAINER = ${DB_SERVICE};
ALTER SESSION SET "_oracle_script" = TRUE;

ALTER USER APEX_PUBLIC_USER IDENTIFIED BY "${APEX_LISTENER_PASSWORD}" ACCOUNT UNLOCK;
ALTER USER APEX_LISTENER IDENTIFIED BY "${APEX_LISTENER_PASSWORD}" ACCOUNT UNLOCK;
ALTER USER APEX_REST_PUBLIC_USER IDENTIFIED BY "${APEX_LISTENER_PASSWORD}" ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH APEX_LISTENER;
ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH APEX_REST_PUBLIC_USER;
BEGIN
    DECLARE
        v_cnt NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_cnt FROM dba_users WHERE username = 'ORDS_PUBLIC_USER';
        IF v_cnt = 0 THEN
            EXECUTE IMMEDIATE 'CREATE USER ORDS_PUBLIC_USER IDENTIFIED BY "' || '${APEX_LISTENER_PASSWORD}' || '" DEFAULT TABLESPACE USERS TEMPORARY TABLESPACE TEMP';
        ELSE
            EXECUTE IMMEDIATE 'ALTER USER ORDS_PUBLIC_USER IDENTIFIED BY "' || '${APEX_LISTENER_PASSWORD}' || '" ACCOUNT UNLOCK';
        END IF;
        EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO ORDS_PUBLIC_USER';
        EXECUTE IMMEDIATE 'ALTER USER ORDS_PUBLIC_USER ACCOUNT UNLOCK';
        EXECUTE IMMEDIATE 'ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER';
        EXECUTE IMMEDIATE 'ALTER USER APEX_REST_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER';
        EXECUTE IMMEDIATE 'ALTER USER APEX_LISTENER GRANT CONNECT THROUGH ORDS_PUBLIC_USER';
        EXECUTE IMMEDIATE 'ALTER USER APEX_PUBLIC_ROUTER GRANT CONNECT THROUGH ORDS_PUBLIC_USER';
    END;
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

DECLARE
    v_schema VARCHAR2(30);
BEGIN
    SELECT username INTO v_schema FROM all_users WHERE username LIKE 'APEX_%' AND REGEXP_LIKE(username, '^APEX_[0-9]+$') AND ROWNUM = 1;
    IF v_schema IS NOT NULL THEN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURRENT_SCHEMA = ' || v_schema;
        EXECUTE IMMEDIATE 'BEGIN ' ||
                          v_schema || '.wwv_flow_instance_admin.set_parameter(''STRONG_SITE_ADMIN_PASSWORD'', ''N''); ' ||
                          v_schema || '.wwv_flow_instance_admin.set_parameter(''ACCOUNT_LIFETIME_DAYS'', ''9999''); ' ||
                          v_schema || '.wwv_flow_instance_admin.set_parameter(''MAX_LOGIN_FAILURES'', ''100''); ' ||
                          v_schema || '.wwv_flow_instance_admin.create_or_update_admin_user(p_username => ''ADMIN'', p_email => ''${APEX_ADMIN_EMAIL:-${PROFILE_APEX_ADMIN_EMAIL:-admin@company.com}}'', p_password => ''' || '${APEX_ADMIN_PASSWORD}' || '''); ' ||
                          v_schema || '.wwv_flow_instance_admin.unlock_user(p_workspace => ''INTERNAL'', p_username => ''ADMIN'', p_password => ''' || '${APEX_ADMIN_PASSWORD}' || '''); ' ||
                          'UPDATE ' || v_schema || '.wwv_flow_fnd_user SET change_password_on_first_use = ''N'', account_locked = ''N'' WHERE security_group_id = 10 AND user_name = ''ADMIN''; ' ||
                          'COMMIT; END;';
    END IF;
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
COMMIT;
EXIT;
EOF
  if [ "$EXEC_MODE" = "CONTAINER" ]; then
    podman cp "$LOCAL_POST_SQL_SCRIPT" "$CONTAINER_NAME":/tmp/apex_post.sql 2>/dev/null || true
    podman exec -i "$CONTAINER_NAME" sqlplus -s "sys/${SYS_PASSWORD}@localhost:1521/${DB_SERVICE} as sysdba" @/tmp/apex_post.sql >/dev/null 2>&1 || true
  else
    $DB_CLI "$CONN_STR" @"$LOCAL_POST_SQL_SCRIPT" >/dev/null 2>&1 || true
  fi
  STEP4_SECS=0
else
  # Kui käivitatakse kliendi-režiimis, peame minema apex kataloogi sisse
  if [ "$EXEC_MODE" = "CLIENT" ]; then
    cd "$APEX_SOURCE_DIR"
  fi

  # Valmistame ette täpse SQL skriptifaili
  LOCAL_PRE_SQL_SCRIPT="$SCRIPT_DIR/../../install_logs/run_apex_pre_install_${DB_SUFFIX}.sql"
  cat << EOF > "$LOCAL_PRE_SQL_SCRIPT"
ALTER SESSION SET CONTAINER = ${DB_SERVICE};

-- Pre-allocate tablespaces to prevent continuous resize contention during installation
BEGIN
  FOR f IN (SELECT file_name, tablespace_name FROM dba_data_files) LOOP
    IF f.tablespace_name = 'SYSAUX' THEN
      BEGIN 
        EXECUTE IMMEDIATE 'ALTER DATABASE DATAFILE ''' || f.file_name || ''' RESIZE 2048M';
        EXECUTE IMMEDIATE 'ALTER DATABASE DATAFILE ''' || f.file_name || ''' AUTOEXTEND ON NEXT 128M MAXSIZE UNLIMITED';
      EXCEPTION WHEN OTHERS THEN NULL; 
      END;
    ELSIF f.tablespace_name = 'SYSTEM' THEN
      BEGIN 
        EXECUTE IMMEDIATE 'ALTER DATABASE DATAFILE ''' || f.file_name || ''' RESIZE 1024M';
        EXECUTE IMMEDIATE 'ALTER DATABASE DATAFILE ''' || f.file_name || ''' AUTOEXTEND ON NEXT 128M MAXSIZE UNLIMITED';
      EXCEPTION WHEN OTHERS THEN NULL; 
      END;
    ELSIF f.tablespace_name = 'UNDOTBS1' THEN
      BEGIN 
        EXECUTE IMMEDIATE 'ALTER DATABASE DATAFILE ''' || f.file_name || ''' RESIZE 512M';
        EXECUTE IMMEDIATE 'ALTER DATABASE DATAFILE ''' || f.file_name || ''' AUTOEXTEND ON NEXT 64M MAXSIZE UNLIMITED';
      EXCEPTION WHEN OTHERS THEN NULL; 
      END;
    END IF;
  END LOOP;
END;
/

-- TASK-018: Optimize DB Memory, Resource Manager and PL/SQL Compiler safely within Oracle Free RAM limits
BEGIN
    EXECUTE IMMEDIATE 'ALTER SYSTEM SET resource_manager_plan = '''' SCOPE = MEMORY';
    EXECUTE IMMEDIATE 'ALTER SYSTEM SET pga_aggregate_target = 512M SCOPE = MEMORY';
    EXECUTE IMMEDIATE 'ALTER SYSTEM SET sga_target = 1024M SCOPE = MEMORY';
    EXECUTE IMMEDIATE 'ALTER SYSTEM SET plsql_optimize_level = 2 SCOPE = MEMORY';
    EXECUTE IMMEDIATE 'ALTER SESSION SET "_oracle_script" = TRUE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

EXIT;
EOF

  APEX_MAJOR=$(echo "$APEX_VER" | cut -d'.' -f1 | tr -dc '0-9')
  APEX_MINOR=$(echo "$APEX_VER" | cut -d'.' -f2 | tr -dc '0-9')
  [ -z "$APEX_MAJOR" ] && APEX_MAJOR="26"
  [ -z "$APEX_MINOR" ] && APEX_MINOR="1"
  APEX_SCHEMA_NAME=$(printf "APEX_%02d%02d00" "$APEX_MAJOR" "$APEX_MINOR")

  LOCAL_POST_SQL_SCRIPT="$SCRIPT_DIR/../../install_logs/run_apex_post_install_${DB_SUFFIX}.sql"
  cat << EOF > "$LOCAL_POST_SQL_SCRIPT"
SET ECHO ON;
SET SERVEROUTPUT ON;

ALTER SESSION SET CONTAINER = ${DB_SERVICE};
ALTER SESSION SET "_oracle_script" = TRUE;
ALTER SESSION SET CURRENT_SCHEMA = ${APEX_SCHEMA_NAME};

-- Set up APEX REST users (APEX_LISTENER and APEX_REST_PUBLIC_USER)
@core/scripts/apxpreins.sql
@apex_rest_config_core.sql ./ "${APEX_LISTENER_PASSWORD}" "${APEX_LISTENER_PASSWORD}"

SET DEFINE OFF;

-- Unlock and sync passwords for ORDS and APEX public users
ALTER USER APEX_PUBLIC_USER IDENTIFIED BY "${APEX_LISTENER_PASSWORD}" ACCOUNT UNLOCK;
ALTER USER APEX_LISTENER IDENTIFIED BY "${APEX_LISTENER_PASSWORD}" ACCOUNT UNLOCK;
ALTER USER APEX_REST_PUBLIC_USER IDENTIFIED BY "${APEX_LISTENER_PASSWORD}" ACCOUNT UNLOCK;
BEGIN
    EXECUTE IMMEDIATE 'ALTER USER APEX_PUBLIC_ROUTER IDENTIFIED BY "' || '${APEX_LISTENER_PASSWORD}' || '" ACCOUNT UNLOCK';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH APEX_LISTENER;
ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH APEX_REST_PUBLIC_USER;

-- Ensure ORDS_METADATA and ORDS_PUBLIC_USER exist with required privileges
BEGIN
    DECLARE
        v_cnt NUMBER;
        v_apex_schema VARCHAR2(30);
    BEGIN
        SELECT username INTO v_apex_schema FROM dba_users WHERE username LIKE 'APEX_%' AND REGEXP_LIKE(username, '^APEX_[0-9]+$') AND ROWNUM = 1;

        BEGIN
            EXECUTE IMMEDIATE 'CREATE PROFILE UNLIMITED_PASS_PROFILE LIMIT
              FAILED_LOGIN_ATTEMPTS UNLIMITED
              PASSWORD_LIFE_TIME UNLIMITED
              PASSWORD_REUSE_TIME UNLIMITED
              PASSWORD_REUSE_MAX UNLIMITED
              PASSWORD_LOCK_TIME UNLIMITED
              PASSWORD_GRACE_TIME UNLIMITED';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;

        SELECT COUNT(*) INTO v_cnt FROM dba_users WHERE username = 'ORDS_PUBLIC_USER';
        IF v_cnt = 0 THEN
            EXECUTE IMMEDIATE 'CREATE USER ORDS_PUBLIC_USER IDENTIFIED BY "${APEX_LISTENER_PASSWORD}" DEFAULT TABLESPACE USERS TEMPORARY TABLESPACE TEMP PROFILE UNLIMITED_PASS_PROFILE';
        ELSE
            EXECUTE IMMEDIATE 'ALTER USER ORDS_PUBLIC_USER IDENTIFIED BY "${APEX_LISTENER_PASSWORD}" PROFILE UNLIMITED_PASS_PROFILE ACCOUNT UNLOCK';
        END IF;
        EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO ORDS_PUBLIC_USER';
        EXECUTE IMMEDIATE 'ALTER USER ORDS_PUBLIC_USER ACCOUNT UNLOCK';
        EXECUTE IMMEDIATE 'ALTER USER APEX_PUBLIC_USER PROFILE UNLIMITED_PASS_PROFILE ACCOUNT UNLOCK';
        EXECUTE IMMEDIATE 'ALTER USER APEX_LISTENER PROFILE UNLIMITED_PASS_PROFILE ACCOUNT UNLOCK';
        EXECUTE IMMEDIATE 'ALTER USER APEX_REST_PUBLIC_USER PROFILE UNLIMITED_PASS_PROFILE ACCOUNT UNLOCK';
        EXECUTE IMMEDIATE 'ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER';
        EXECUTE IMMEDIATE 'ALTER USER APEX_REST_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER';
        EXECUTE IMMEDIATE 'ALTER USER APEX_LISTENER GRANT CONNECT THROUGH ORDS_PUBLIC_USER';
        EXECUTE IMMEDIATE 'ALTER USER APEX_PUBLIC_ROUTER GRANT CONNECT THROUGH ORDS_PUBLIC_USER';

        -- INHERIT PRIVILEGES grants
        EXECUTE IMMEDIATE 'GRANT INHERIT PRIVILEGES ON USER APEX_PUBLIC_USER TO ' || v_apex_schema;
        EXECUTE IMMEDIATE 'GRANT INHERIT PRIVILEGES ON USER ORDS_PUBLIC_USER TO ' || v_apex_schema;
        EXECUTE IMMEDIATE 'GRANT INHERIT PRIVILEGES ON USER APEX_PUBLIC_USER TO APEX_PUBLIC_ROUTER';
        EXECUTE IMMEDIATE 'GRANT INHERIT PRIVILEGES ON USER ORDS_PUBLIC_USER TO APEX_PUBLIC_ROUTER';
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
END;
/
COMMIT;

-- Set APEX Instance Admin Password (Official Oracle API)
BEGIN
    ${APEX_SCHEMA_NAME}.wwv_flow_instance_admin.set_parameter('STRONG_SITE_ADMIN_PASSWORD', 'N');
    ${APEX_SCHEMA_NAME}.wwv_flow_instance_admin.set_parameter('ACCOUNT_LIFETIME_DAYS', '9999');
    ${APEX_SCHEMA_NAME}.wwv_flow_instance_admin.set_parameter('MAX_LOGIN_FAILURES', '100');
    COMMIT;
    ${APEX_SCHEMA_NAME}.wwv_flow_instance_admin.create_or_update_admin_user(
        p_username => 'ADMIN',
        p_email    => '${APEX_ADMIN_EMAIL:-${PROFILE_APEX_ADMIN_EMAIL:-admin@company.com}}',
        p_password => '${APEX_ADMIN_PASSWORD}'
    );
    ${APEX_SCHEMA_NAME}.wwv_flow_instance_admin.unlock_user(
        p_workspace => 'INTERNAL',
        p_username  => 'ADMIN',
        p_password  => '${APEX_ADMIN_PASSWORD}'
    );
    UPDATE ${APEX_SCHEMA_NAME}.wwv_flow_fnd_user
    SET change_password_on_first_use = 'N',
        account_locked = 'N'
    WHERE security_group_id = 10 AND user_name = 'ADMIN';
    COMMIT;
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- Ensure primary schema user exists before creating workspace (Created without _oracle_script so APEX allows provisioning)
ALTER SESSION SET "_oracle_script" = FALSE;

DECLARE
    v_user_cnt NUMBER;
    v_schema VARCHAR2(100) := '${APEX_SCHEMA_USER:-${PROFILE_APEX_SCHEMA_USER:-${DB_SUFFIX_UPPER}_SCHEMA}}';
BEGIN
    SELECT COUNT(*) INTO v_user_cnt FROM dba_users WHERE username = v_schema;
    IF v_user_cnt = 0 THEN
        EXECUTE IMMEDIATE 'CREATE USER ' || v_schema || ' IDENTIFIED BY "${USER_DEV_PASSWORD:-${APEX_ADMIN_PASSWORD}}"';
        EXECUTE IMMEDIATE 'GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE PROCEDURE, CREATE SEQUENCE, CREATE SYNONYM TO ' || v_schema;
        EXECUTE IMMEDIATE 'ALTER USER ' || v_schema || ' DEFAULT TABLESPACE USERS TEMPORARY TABLESPACE TEMP QUOTA UNLIMITED ON USERS';
    END IF;
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- Create APEX Workspace for Application and Developer Users (Atomic)
DECLARE
    v_workspace_id NUMBER;
    v_ws_name VARCHAR2(100) := '${APEX_WORKSPACE:-${PROFILE_APEX_WORKSPACE:-${DB_SUFFIX_UPPER}_WORKSPACE}}';
    v_schema VARCHAR2(100) := '${APEX_SCHEMA_USER:-${PROFILE_APEX_SCHEMA_USER:-${DB_SUFFIX_UPPER}_SCHEMA}}';
BEGIN
    v_workspace_id := ${APEX_SCHEMA_NAME}.HTMLDB_UTIL.find_security_group_id(v_ws_name);
    IF v_workspace_id IS NULL OR v_workspace_id = 0 THEN
        BEGIN
            ${APEX_SCHEMA_NAME}.WWV_FLOW_INSTANCE_ADMIN.add_workspace(
                p_workspace_id   => NULL,
                p_workspace      => v_ws_name,
                p_primary_schema => v_schema
            );
            COMMIT;
            v_workspace_id := ${APEX_SCHEMA_NAME}.HTMLDB_UTIL.find_security_group_id(v_ws_name);
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END IF;

    IF v_workspace_id IS NOT NULL AND v_workspace_id != 0 THEN
        ${APEX_SCHEMA_NAME}.HTMLDB_UTIL.set_security_group_id(v_workspace_id);
        
        -- DEV
        BEGIN
            ${APEX_SCHEMA_NAME}.HTMLDB_UTIL.remove_user(p_user_name => 'DEV');
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
        BEGIN
            ${APEX_SCHEMA_NAME}.HTMLDB_UTIL.create_user(
                p_user_name                    => 'DEV',
                p_email_address                => 'dev@company.local',
                p_web_password                 => '${USER_DEV_PASSWORD:-${APEX_ADMIN_PASSWORD}}',
                p_developer_privs              => 'ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:VARIABLE',
                p_account_expiry               => sysdate + 3650,
                p_account_locked               => 'N',
                p_change_password_on_first_use => 'N'
            );
        EXCEPTION WHEN OTHERS THEN NULL;
        END;

        -- USER_DEVELOPER
        BEGIN
            ${APEX_SCHEMA_NAME}.HTMLDB_UTIL.remove_user(p_user_name => 'USER_DEVELOPER');
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
        BEGIN
            ${APEX_SCHEMA_NAME}.HTMLDB_UTIL.create_user(
                p_user_name                    => 'USER_DEVELOPER',
                p_email_address                => 'user_developer@company.local',
                p_web_password                 => '${USER_DEV_PASSWORD:-${APEX_ADMIN_PASSWORD}}',
                p_developer_privs              => 'ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:VARIABLE',
                p_account_expiry               => sysdate + 3650,
                p_account_locked               => 'N',
                p_change_password_on_first_use => 'N'
            );
        EXCEPTION WHEN OTHERS THEN NULL;
        END;

        -- ADMIN
        BEGIN
            ${APEX_SCHEMA_NAME}.HTMLDB_UTIL.remove_user(p_user_name => 'ADMIN');
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
        BEGIN
            ${APEX_SCHEMA_NAME}.HTMLDB_UTIL.create_user(
                p_user_name                    => 'ADMIN',
                p_email_address                => 'admin@company.local',
                p_web_password                 => '${APEX_ADMIN_PASSWORD}',
                p_developer_privs              => 'ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:VARIABLE',
                p_account_expiry               => sysdate + 3650,
                p_account_locked               => 'N',
                p_change_password_on_first_use => 'N'
            );
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
        COMMIT;
    END IF;
END;
/

EXIT;
EOF

  OTHER_CONTAINERS=$(podman ps --format '{{.Names}}' 2>/dev/null | grep -E '^db-|^oracle-db-' | grep -v "^${CONTAINER_NAME}$" || echo "")
  if [ -n "$OTHER_CONTAINERS" ]; then
    msg_print "APEX_ENGINE_PAUSING_CONTAINERS" "$OTHER_CONTAINERS"
    podman stop $OTHER_CONTAINERS >/dev/null 2>&1 || true
  fi

  if [ "$EXEC_MODE" = "CONTAINER" ]; then
    podman exec "$CONTAINER_NAME" mkdir -p /tmp/apex_install/apex 2>/dev/null || true
    podman cp "$LOCAL_PRE_SQL_SCRIPT" "$CONTAINER_NAME":/tmp/apex_install/apex/run_pre_install.sql
    podman cp "$LOCAL_POST_SQL_SCRIPT" "$CONTAINER_NAME":/tmp/apex_install/apex/run_post_install.sql
    
    APEX_ENGINE_SQL="apexins.sql"
    [ "$RUNTIME_ONLY" = "true" ] && APEX_ENGINE_SQL="apxrtins.sql"

    cat << RUN_EOF > /tmp/run_apex_in_container.sh
#!/bin/bash
set -e
export ORACLE_HOME=\$(ls -d /opt/oracle/product/*/dbhomeFree 2>/dev/null | head -n 1)
[ -n "\$ORACLE_HOME" ] && export PATH="\$ORACLE_HOME/bin:\$PATH"
export ORACLE_SID="FREE"
export ORACLE_PDB_SID="${DB_SERVICE:-FREEPDB1}"
unset TWO_TASK
unset TNS_ADMIN
cd /tmp/apex_install/apex
sqlplus -s / as sysdba @run_pre_install.sql
sqlplus -s / as sysdba @${APEX_ENGINE_SQL} SYSAUX SYSAUX TEMP /i/
sqlplus -s / as sysdba @run_post_install.sql
RUN_EOF
    chmod +x /tmp/run_apex_in_container.sh
    podman cp /tmp/run_apex_in_container.sh "$CONTAINER_NAME":/tmp/apex_install/apex/run.sh
    podman exec "$CONTAINER_NAME" chmod 755 /tmp/apex_install/apex/run.sh /tmp/apex_install/apex/run_pre_install.sql /tmp/apex_install/apex/run_post_install.sql 2>/dev/null || true
    podman exec -i -w /tmp/apex_install/apex "$CONTAINER_NAME" /tmp/apex_install/apex/run.sh > "$SQL_LOG_FILE" 2>&1 &
    rm -f /tmp/run_apex_in_container.sh
  else
    $DB_CLI "$CONN_STR" @"$LOCAL_PRE_SQL_SCRIPT" >> "$SQL_LOG_FILE" 2>&1 && $DB_CLI "$CONN_STR" @"$LOCAL_POST_SQL_SCRIPT" >> "$SQL_LOG_FILE" 2>&1 &
  fi
  SQL_PID=$!

  hide_cursor
  ELAPSED=0
  POLL_INTERVAL="${LIVE_TIMER_INTERVAL:-3}"
  POLL_INTERVAL="${POLL_INTERVAL//[^0-9]/}"
  [ -z "$POLL_INTERVAL" ] || [ "$POLL_INTERVAL" -le 0 ] && POLL_INTERVAL=3
  print_progress "$(msg_str "PROGRESS_INSTALLING_APEX_ENGINE" "$CONTAINER_NAME")" 0 360
  while kill -0 $SQL_PID 2>/dev/null; do
    sleep "$POLL_INTERVAL"
    ELAPSED=$((ELAPSED + POLL_INTERVAL))
    print_progress "$(msg_str "PROGRESS_INSTALLING_APEX_ENGINE" "$CONTAINER_NAME")" "$ELAPSED" 360
  done
  wait $SQL_PID || true
  clear_progress_line
  restore_cursor

  if [ -n "$OTHER_CONTAINERS" ]; then
    msg_print "APEX_ENGINE_RESUMING_CONTAINERS" "$OTHER_CONTAINERS"
    podman start $OTHER_CONTAINERS >/dev/null 2>&1 || true
  fi

  # Verify APEX installation validity (VALID status in registry)
  local_ver_check=""
  if [ "$EXEC_MODE" = "CONTAINER" ]; then
    local_ver_check=$(podman exec -i "$CONTAINER_NAME" sh -c "export ORACLE_HOME=\$(ls -d /opt/oracle/product/*/dbhomeFree 2>/dev/null | head -n 1); [ -n \"\$ORACLE_HOME\" ] && export PATH=\"\$ORACLE_HOME/bin:\$PATH\"; export ORACLE_PDB_SID=\"${DB_SERVICE:-FREEPDB1}\"; sqlplus -s / as sysdba <<EOF
SET FEEDBACK OFF
SET HEADING OFF
SELECT status FROM dba_registry WHERE comp_id = 'APEX';
EXIT;
EOF" 2>/dev/null | grep -E 'VALID|INVALID' || echo "")
  else
    local_ver_check=$($DB_CLI "$CONN_STR" <<EOF 2>/dev/null | grep -E 'VALID|INVALID' || echo ""
SET FEEDBACK OFF
SET HEADING OFF
SELECT status FROM dba_registry WHERE comp_id = 'APEX';
EXIT;
EOF
)
  fi

  if [[ "$local_ver_check" != *"VALID"* ]]; then
    echo -e "\n${RED}$(msg_str "ERROR_APEX_ENGINE_FAILED")${NC}"
    echo -e "$(msg_str "SEE_DETAILED_LOG" "$SQL_LOG_FILE")\n"
    tail -n 25 "$SQL_LOG_FILE" 2>/dev/null || true
    exit 1
  fi

  msg_print "APEX_ENGINE_INSTALLED_VALID"

  copy_static_images_to_volume

  # Tuleme tagasi projekti juurkausta kui olime kliendi-režiimis
  if [ "$EXEC_MODE" = "CLIENT" ]; then
    cd ..
  fi

  STEP4_SECS=$(($(date +%s) - STEP4_START))
fi

STEP4_TIME=$(format_duration $STEP4_SECS)
echo -e "⏱  [$(msg_str "STEP_4_APEX_ENGINE_DONE" "$STEP4_TIME")]"

# ----------------------------------------------------------------------------
# 4.1. ORDS Konfiguratsiooni uuendamine (plsql.gateway.mode = proxied)
# ----------------------------------------------------------------------------
ORDS_CONF_START=$(date +%s)

ords_found=$(podman ps --format '{{.Names}}' | grep -E '^app-ords|^oracle-ords-dev|^ords-|^oracle-ords-' | head -n 1 || echo "app-ords")
ORDS_CONTAINER="${PROFILE_ORDS_CONTAINER_NAME:-$ords_found}"
ORDS_CONF_LOG="$LOG_DIR/ords_configure_${DB_SUFFIX}_${TIMESTAMP}.log"

if [ "$SKIP_ORDS" = "false" ] && podman container exists "$ORDS_CONTAINER" 2>/dev/null; then
  echo "=================================================================="
  msg_print "ORDS_CHECKING_SYNCING_CONFIG" "$ORDS_CONTAINER"
  echo "📝 Logifail: [Logi](file://$ORDS_CONF_LOG)"
  echo "=================================================================="
  {
    pool_suffix=$(echo "$CONTAINER_NAME" | sed 's/^db-//' | tr '-' '_')
    
    # Configure default pool
    podman exec -i "$ORDS_CONTAINER" bash -c "
      mkdir -p /etc/ords/config/databases/default
      cat << EOF_POOL > /etc/ords/config/databases/default/pool.xml
<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE properties SYSTEM \"http://java.sun.com/dtd/properties.dtd\">
<properties>
<entry key=\"db.connectionType\">basic</entry>
<entry key=\"db.hostname\">${CONTAINER_NAME}</entry>
<entry key=\"db.port\">1521</entry>
<entry key=\"db.servicename\">${DB_SERVICE_NAME:-FREEPDB1}</entry>
<entry key=\"db.username\">ORDS_PUBLIC_USER</entry>
<entry key=\"db.password\">${APEX_LISTENER_PASSWORD}</entry>
<entry key=\"feature.sdw\">true</entry>
<entry key=\"feature.apex\">true</entry>
<entry key=\"plsql.gateway.mode\">proxied</entry>
<entry key=\"restEnabledSql.active\">true</entry>
</properties>
EOF_POOL
    " || true

    # If container is specific pool (proxy, lis, etc.), configure mapped pool as well
    if [ -n "$pool_suffix" ] && [ "$pool_suffix" != "default" ]; then
      podman exec -i "$ORDS_CONTAINER" bash -c "
        mkdir -p /etc/ords/config/databases/${pool_suffix}
        cat << EOF_POOL > /etc/ords/config/databases/${pool_suffix}/pool.xml
<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE properties SYSTEM \"http://java.sun.com/dtd/properties.dtd\">
<properties>
<entry key=\"db.connectionType\">basic</entry>
<entry key=\"db.hostname\">${CONTAINER_NAME}</entry>
<entry key=\"db.port\">1521</entry>
<entry key=\"db.servicename\">${DB_SERVICE_NAME:-FREEPDB1}</entry>
<entry key=\"db.username\">ORDS_PUBLIC_USER</entry>
<entry key=\"db.password\">${APEX_LISTENER_PASSWORD}</entry>
<entry key=\"feature.sdw\">true</entry>
<entry key=\"feature.apex\">true</entry>
<entry key=\"plsql.gateway.mode\">proxied</entry>
<entry key=\"restEnabledSql.active\">true</entry>
</properties>
EOF_POOL
      " || true
    fi

    # Ensure global settings and clean any legacy url-mapping.xml
    podman exec -i "$ORDS_CONTAINER" bash -c '
      mkdir -p /etc/ords/config/global
      cat << "EOF_GLOBAL" > /etc/ords/config/global/settings.xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
<properties>
<entry key="database.api.enabled">true</entry>
<entry key="feature.sdw">true</entry>
<entry key="restEnabledSql.active">true</entry>
<entry key="standalone.doc.root">/opt/oracle/docroot</entry>
<entry key="standalone.http.port">8088</entry>
<entry key="standalone.https.port">8448</entry>
<entry key="standalone.static.context.path">/i</entry>
<entry key="standalone.static.path">/opt/oracle/apex_images/images</entry>
</properties>
EOF_GLOBAL

      rm -f /etc/ords/config/url-mapping.xml 2>/dev/null || true
    ' || true

    if [ -n "$APEX_LISTENER_PASSWORD" ]; then
      podman exec "$ORDS_CONTAINER" bash -c "for pool in \$(find /etc/ords/config/databases/ -name 'pool.xml' 2>/dev/null); do sed -i 's|<entry key=\"db.password\">.*</entry>|<entry key=\"db.password\">$APEX_LISTENER_PASSWORD</entry>|g' \"\$pool\" 2>/dev/null || true; done" || true
    fi
    podman restart "$ORDS_CONTAINER" >/dev/null 2>&1 || true
  } > "$ORDS_CONF_LOG" 2>&1 || true
fi

ORDS_CONF_SECS=$(( $(date +%s) - ORDS_CONF_START ))
ORDS_CONF_TIME=$(format_duration $ORDS_CONF_SECS)
echo -e "⏱  [$(msg_str "ORDS_CONFIGURE_COMPLETED_STEP" "$ORDS_CONF_TIME")]"

if podman container exists app-ords 2>/dev/null; then
  msg_print "ORDS_RESTARTING_SERVICE" "app-ords"
  podman restart app-ords >/dev/null 2>&1 || true
fi

# ----------------------------------------------------------------------------
# 5. Automated APEX Patch installation (if a .zip file exists in patches/ or binaries/)
# ----------------------------------------------------------------------------
STEP5_START=$(date +%s)
APEX_PATCHES_DIR="$WORKSPACE_DIR/binaries/apex/patches"
[ ! -d "$APEX_PATCHES_DIR" ] && APEX_PATCHES_DIR="$WORKSPACE_DIR/patches"
PATCH_SCRIPT="$SCRIPT_DIR/apply-apex-patch.sh"
[ ! -x "$PATCH_SCRIPT" ] && PATCH_SCRIPT="$WORKSPACE_DIR/scripts/internal/apply-apex-patch.sh"

APEX_VER_CLEAN=$(echo "$APEX_VER" | tr -d '.')
LATEST_PATCH=""
if [ -d "$WORKSPACE_DIR/binaries/apex/patches" ]; then
  LATEST_PATCH=$(find "$WORKSPACE_DIR/binaries/apex/patches" -maxdepth 1 \( -name "p*_${APEX_VER_CLEAN}_*.zip" -o -name "p*_${APEX_VER}_*.zip" \) -type f 2>/dev/null | sort -V | tail -n 1)
fi
if [ -z "$LATEST_PATCH" ] && [ -d "$WORKSPACE_DIR/patches" ]; then
  LATEST_PATCH=$(find "$WORKSPACE_DIR/patches" -maxdepth 1 \( -name "p*_${APEX_VER_CLEAN}_*.zip" -o -name "p*_${APEX_VER}_*.zip" \) -type f 2>/dev/null | sort -V | tail -n 1)
fi

if [ -x "$PATCH_SCRIPT" ] && [ -n "$LATEST_PATCH" ]; then
    echo ""
    print_sub_header "5" "$(msg_str "APEX_PATCH_FOUND_AUTO_INSTALL" "$(basename "$LATEST_PATCH")")" "step5_apex_patch_install_seconds" "step9_apex_patch_install_seconds" "30s"
    if [ "$SKIP_ORDS" = "true" ]; then
      TARGET_CONTAINER="$CONTAINER_NAME" "$PATCH_SCRIPT" "$LATEST_PATCH" --no-ords
    else
      TARGET_CONTAINER="$CONTAINER_NAME" "$PATCH_SCRIPT" "$LATEST_PATCH"
    fi
    STEP5_SECS=$(( $(date +%s) - STEP5_START ))
    STEP5_TIME=$(format_duration $STEP5_SECS)
    echo -e "⏱  [$(msg_str "STEP_5_APEX_PATCH_DONE" "$STEP5_TIME")]"
else
    STEP5_SECS=0
    STEP5_TIME="vahele jäetud"
    msg_print "APEX_PATCH_NO_ZIP_SKIPPED"
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
msg_print "SETUP_BENCHMARKS_HEADER"
echo -e "${CYAN}==================================================================${NC}"
msg_print "SETUP_BENCHMARKS_STEP1" "$STEP1_TIME" "$STEP1_SECS"
msg_print "SETUP_BENCHMARKS_STEP2" "$STEP2_TIME" "$STEP2_SECS"
msg_print "SETUP_BENCHMARKS_STEP3" "$STEP3_TIME" "$STEP3_SECS"
msg_print "SETUP_BENCHMARKS_STEP4" "$STEP4_TIME" "$STEP4_SECS"
msg_print "SETUP_BENCHMARKS_STEP5" "$ORDS_CONF_TIME" "$ORDS_CONF_SECS"
msg_print "SETUP_BENCHMARKS_STEP6" "$STEP5_TIME" "$STEP5_SECS"
echo "  ------------------------------------------------------------"
msg_print "SETUP_BENCHMARKS_TOTAL" "$TOTAL_TIME" "$TOTAL_SECS"
echo -e "${CYAN}==================================================================${NC}"
if [ "$MASTER_SETUP" != "true" ]; then
  echo "📊 Mõõdikud salvestati Git-i kausta: $JSON_BENCHMARK"
  echo "------------------------------------------------------------------"
  echo "📝 Lokaalne logi salvestati:        $LOG_FILE"
  echo "✅ Oracle APEX & ORDS paigaldusprotsess lõpetatud!"
  echo "=================================================================="
fi
