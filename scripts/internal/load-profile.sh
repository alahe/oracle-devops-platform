#!/usr/bin/env bash
# ============================================================================
# Dynamic Database Profile Parser & Precedence Engine (High-Performance Edition)
# Implements 3-Level Precedence Hierarchy for DB Profiles, Images, & ZIP Files
# High-speed single-pass Python/Awk parser with in-memory caching
# ============================================================================

set -e

_LOCAL_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$_LOCAL_SCRIPT_DIR/../.." && pwd)"

# Source central common helper if available
if [ -f "$_LOCAL_SCRIPT_DIR/common.sh" ]; then
  source "$_LOCAL_SCRIPT_DIR/common.sh"
fi

# Function to parse a single key using python3 or awk
parse_yaml_key() {
  local file="$1"
  local key="$2"
  grep -E "^[[:space:]]*${key}:" "$file" 2>/dev/null | head -n 1 | sed -E 's/#.*//' | sed -E "s/^[[:space:]]*${key}:[[:space:]]*\"?([^\"]+)\"?$/\1/" | awk '{print $1}' | tr -d '\r\n' || true
}

# Fast Python-based single-pass profile exporter
_export_db_profile_python() {
  local profile_file="$1"
  python3 - "$profile_file" << 'PYEOF' 2>/dev/null
import sys, yaml, os

profile_file = sys.argv[1]
try:
    with open(profile_file, 'r') as f:
        data = yaml.safe_load(f) or {}
except Exception as e:
    sys.exit(1)

def q(val):
    if val is None:
        return "''"
    s = str(val).replace("'", "'\\''")
    return f"'{s}'"

prof = data.get('profile', {})
db = data.get('database', {})
comp = data.get('components', {})
ords = comp.get('ords', {})
apex = comp.get('apex', {})
pub = comp.get('publisher', {})
forms = comp.get('forms', {})
users = data.get('users', [])

db_type_val = str(prof.get('db_type', 'standard')).lower()
if db_type_val in ['adb', 'autonomous']:
    db_type_val = 'adb'

sys_alias = 'DB_MAIN_SYS'
for u in users:
    if str(u.get('role', '')).upper() == 'SYSDBA' and u.get('wallet_alias'):
        sys_alias = u.get('wallet_alias')
        break

lines = [
    f"export PROFILE_YAML={q(profile_file)}",
    f"export PROFILE_ID={q(prof.get('id', ''))}",
    f"export PROFILE_NAME={q(prof.get('name', ''))}",
    f"export PROFILE_DESC={q(prof.get('description', ''))}",
    f"export PROFILE_FUNC={q(prof.get('functionality', ''))}",
    f"export PROFILE_DB_TYPE={q(db_type_val)}",
    f"export PROFILE_VENDOR={q(prof.get('image_vendor', 'oracle'))}",
    f"export PROFILE_CONTAINER_NAME={q(db.get('container_name', prof.get('id', '')))}",
    f"export PROFILE_WORKLOAD_TYPE={q(db.get('workload_type', 'NONE'))}",
    f"export PROFILE_ADMIN_USER={q(db.get('admin_user', 'sys'))}",
    f"export PROFILE_ADMIN_ROLE={q(db.get('admin_role', 'SYSDBA'))}",
    f"export PROFILE_DEFAULT_SERVICE={q(db.get('default_service', 'FREEPDB1'))}",
    f"export PROFILE_DB_PORT={q(db.get('db_port', 1532))}",
    f"export PROFILE_CONTAINER_PORT={q(db.get('container_port', 1522 if db_type_val == 'adb' else 1521))}",
    f"export PROFILE_DB_SID={q(db.get('db_sid', 'FREE'))}",
    f"export PROFILE_DB_PDB={q(db.get('db_pdb', 'MYATP'))}",
    f"export PROFILE_DB_MEMORY={q(db.get('db_memory_limit', '3072M'))}",
    f"export PROFILE_ORDS_MEMORY={q(db.get('ords_memory_limit', '1024M'))}",
    f"export PROFILE_WALLET_REQUIRED={q(str(db.get('wallet_required', False)).lower())}",
    f"export PROFILE_CONFIGURE_TDE={q(str(db.get('configure_tde', True)).lower())}",
    f"export PROFILE_ENCRYPT_TABLESPACES={q(db.get('encrypt_tablespaces', 'ALL'))}",
    f"export PROFILE_KAFKA_BOOTSTRAP_SERVERS={q(db.get('kafka_bootstrap_servers', 'localhost:9092'))}",
    f"export PROFILE_SYS_WALLET_ALIAS={q(sys_alias)}",
    f"export RAW_CONTAINER_IMAGE={q(db.get('container_image', ''))}",
    # ORDS
    f"export PROFILE_ORDS_ENABLED={q(str(ords.get('enabled', True)).lower())}",
    f"export PROFILE_ORDS_MODE={q(ords.get('mode', 'local'))}",
    f"export PROFILE_ORDS_EXTERNAL_URL={q(ords.get('external_ords_url', ''))}",
    f"export PROFILE_ORDS_EXTERNAL_HOST={q(ords.get('external_ords_host', ''))}",
    f"export PROFILE_ORDS_EXTERNAL_PORT={q(ords.get('external_ords_port', ''))}",
    f"export PROFILE_ORDS_EXTERNAL_USER={q(ords.get('external_ords_user', ''))}",
    f"export PROFILE_ORDS_WALLET_ALIAS={q(ords.get('wallet_alias', ''))}",
    f"export PROFILE_ORDS_VERSION={q(ords.get('version', '26.2'))}",
    f"export PROFILE_ORDS_DOWNLOAD_URL={q(ords.get('download_url', 'https://download.oracle.com/otn_software/java/ords/ords-latest.zip'))}",
    f"export PROFILE_ORDS_HTTP_PORT={q(ords.get('http_port', 8088))}",
    f"export PROFILE_ORDS_HTTPS_PORT={q(ords.get('https_port', 8448))}",
    f"export PROFILE_ORDS_CONTAINER_NAME={q(ords.get('container_name', 'app-ords'))}",
    f"export PROFILE_ORDS_CONTAINER_IMAGE={q(ords.get('container_image', 'container-registry.oracle.com/database/ords:latest'))}",
    f"export PROFILE_ORDS_PREINSTALLED={q(str(ords.get('preinstalled', False)).lower())}",
    f"export PROFILE_ORDS_CONTAINER_REQUIRED={q(str(ords.get('container_required', True)).lower())}",
    # APEX
    f"export PROFILE_APEX_ENABLED={q(str(apex.get('enabled', True)).lower())}",
    f"export PROFILE_APEX_PREINSTALLED={q(str(apex.get('preinstalled', False)).lower())}",
    f"export PROFILE_APEX_INSTALL_REQUIRED={q(str(apex.get('install_required', True)).lower())}",
    f"export PROFILE_APEX_DOWNLOAD_URL={q(apex.get('download_url', 'https://download.oracle.com/otn_software/apex/apex_26.1_en.zip'))}",
    f"export PROFILE_APEX_VERSION={q(apex.get('version', '26.1'))}",
    f"export PROFILE_APEX_WORKSPACE={q(apex.get('workspace', 'PROXY_WORKSPACE'))}",
    # Publisher
    f"export PROFILE_PUBLISHER_ENABLED={q(str(pub.get('enabled', False)).lower())}",
    f"export PROFILE_PUBLISHER_CONTAINER_NAME={q(pub.get('container_name', 'app_publisher'))}",
    f"export PROFILE_PUBLISHER_HTTP_PORT={q(pub.get('http_port', 9502))}",
    f"export PROFILE_PUBLISHER_HTTPS_PORT={q(pub.get('https_port', 9503))}",
    f"export PROFILE_PUBLISHER_RCU_PREFIX={q(pub.get('rcu_prefix', 'OAS'))}",
    f"export PROFILE_PUBLISHER_DOMAIN_NAME={q(pub.get('domain_name', 'bi'))}",
    # Forms
    f"export PROFILE_FORMS_ENABLED={q(str(forms.get('enabled', False)).lower())}",
    f"export PROFILE_FORMS_CONTAINER_NAME={q(forms.get('container_name', 'app-forms'))}",
    f"export PROFILE_FORMS_HTTP_PORT={q(forms.get('http_port', 9001))}",
    f"export PROFILE_FORMS_HTTPS_PORT={q(forms.get('https_port', 9002))}",
    f"export PROFILE_FORMS_ADMIN_PORT={q(forms.get('admin_port', 7001))}",
    f"export PROFILE_FORMS_RCU_PREFIX={q(forms.get('rcu_prefix', 'FORMS'))}",
    f"export PROFILE_FORMS_VERSION={q(forms.get('version', '14.1.2'))}",
]
print('\n'.join(lines))
PYEOF
}

# Main Profile Loader Function
load_db_profile() {
  local profile_name="$1"
  if [ -z "$profile_name" ]; then
    local first_inst
    first_inst=$(get_active_db_instances 2>/dev/null | head -n 1 | cut -d'|' -f2)
    profile_name="${MAIN_DB_PROFILE:-${first_inst:-app-free}}"
  fi

  # Strip path or extension if provided
  profile_name=$(basename "$profile_name" .yaml)

  # Legacy backwards compatibility alias mapping
  case "$profile_name" in
    "bizapp-standard-oracle"|"bizapp-free"|"bizapp"|"app-free") profile_name="db-lis-oracle" ;;
    "bizapp-adb-oracle"|"bizapp-adb"|"app-adb") profile_name="db-lis-adb" ;;
    "proxy-standard-oracle"|"proxy-free") profile_name="db-proxy-oracle" ;;
    "proxy-adb-oracle"|"proxy-adb") profile_name="db-proxy-adb" ;;
    "proxy-standard-gvenzl"|"proxy-gvenzl") profile_name="db-proxy-gvenzl" ;;
    "publisher-free") profile_name="db-publisher-oracle" ;;
    "publisher-only") profile_name="db-publisher-gvenzl" ;;
    "appinfra-standard-gvenzl"|"appinfra"|"db-lis-gvenzl"|"lis-gvenzl") profile_name="db-infra-gvenzl" ;;
    "cicd-standard-oracle"|"cicd") profile_name="db-cicd" ;;
  esac

  local profile_file="$WORKSPACE_DIR/config/profiles/databases/${profile_name}.yaml"
  if [ ! -f "$profile_file" ]; then
    profile_file="$WORKSPACE_DIR/config/profiles/${profile_name}.yaml"
  fi
  if [ ! -f "$profile_file" ]; then
    echo "⚠️  Hoiatus: Profiilifaili '${profile_name}.yaml' ei leitud kaustast config/profiles/databases/. Kasutan vaike-profiili 'db-lis-oracle'."
    profile_name="db-lis-oracle"
    profile_file="$WORKSPACE_DIR/config/profiles/databases/db-lis-oracle.yaml"
  fi

  # 1. Execute single-pass exporter
  local script_exports
  script_exports=$(_export_db_profile_python "$profile_file")

  if [ -n "$script_exports" ]; then
    eval "$script_exports"
  else
    # Fallback to legacy field-by-field grep if python failed
    export PROFILE_YAML="$profile_file"
    export PROFILE_ID=$(parse_yaml_key "$profile_file" "id")
    export PROFILE_NAME=$(parse_yaml_key "$profile_file" "name")
    export PROFILE_DESC=$(parse_yaml_key "$profile_file" "description")
    export PROFILE_FUNC=$(parse_yaml_key "$profile_file" "functionality")
    export PROFILE_DB_TYPE=$(parse_yaml_key "$profile_file" "db_type")
    export PROFILE_VENDOR=$(parse_yaml_key "$profile_file" "image_vendor")
    export RAW_CONTAINER_IMAGE=$(parse_yaml_key "$profile_file" "container_image")
    export PROFILE_WORKLOAD_TYPE=$(parse_yaml_key "$profile_file" "workload_type")
    export PROFILE_ADMIN_USER=$(parse_yaml_key "$profile_file" "admin_user")
    export PROFILE_ADMIN_ROLE=$(parse_yaml_key "$profile_file" "admin_role")
    export PROFILE_DEFAULT_SERVICE=$(parse_yaml_key "$profile_file" "default_service")
    export PROFILE_DB_PORT=$(parse_yaml_key "$profile_file" "db_port")
    export PROFILE_CONTAINER_PORT=$(parse_yaml_key "$profile_file" "container_port")
    export PROFILE_DB_SID=$(parse_yaml_key "$profile_file" "db_sid")
    export PROFILE_DB_PDB=$(parse_yaml_key "$profile_file" "db_pdb")
    export PROFILE_DB_MEMORY=$(parse_yaml_key "$profile_file" "db_memory_limit")
    export PROFILE_ORDS_MEMORY=$(parse_yaml_key "$profile_file" "ords_memory_limit")
    export PROFILE_WALLET_REQUIRED=$(parse_yaml_key "$profile_file" "wallet_required")
    export PROFILE_CONFIGURE_TDE=$(parse_yaml_key "$profile_file" "configure_tde")
    export PROFILE_ENCRYPT_TABLESPACES=$(parse_yaml_key "$profile_file" "encrypt_tablespaces")
    export PROFILE_KAFKA_BOOTSTRAP_SERVERS=$(parse_yaml_key "$profile_file" "kafka_bootstrap_servers")
    export PROFILE_ORDS_ENABLED="true"
    export PROFILE_ORDS_VERSION="26.2"
    export PROFILE_ORDS_DOWNLOAD_URL="https://download.oracle.com/otn_software/java/ords/ords-latest.zip"
    export PROFILE_ORDS_HTTP_PORT="8088"
    export PROFILE_ORDS_HTTPS_PORT="8448"
    export PROFILE_ORDS_CONTAINER_NAME="app-ords"
    export PROFILE_ORDS_SERVICE_NAME="app-ords"
    export PROFILE_APEX_ENABLED="true"
    export PROFILE_APEX_VERSION="26.2"
    export PROFILE_APEX_DOWNLOAD_URL="https://download.oracle.com/otn_software/apex/apex_26.2.zip"
    export PROFILE_APEX_WORKSPACE="PROXY_WORKSPACE"
    export PROFILE_PUBLISHER_ENABLED="false"
  fi

  # Fallback defaults for missing keys
  export PROFILE_CONTAINER_PORT="${PROFILE_CONTAINER_PORT:-1521}"
  export PROFILE_DB_SID="${PROFILE_DB_SID:-FREE}"
  export PROFILE_DB_PDB="${PROFILE_DB_PDB:-MYATP}"
  export PROFILE_DB_MEMORY="${PROFILE_DB_MEMORY:-3072M}"
  export PROFILE_ORDS_MEMORY="${PROFILE_ORDS_MEMORY:-1024M}"
  export CONFIGURE_TDE="${CONFIGURE_TDE:-${PROFILE_CONFIGURE_TDE:-true}}"
  export ENCRYPT_TABLESPACES="${ENCRYPT_TABLESPACES:-${PROFILE_ENCRYPT_TABLESPACES:-ALL}}"
  export KAFKA_BOOTSTRAP_SERVERS="${KAFKA_BOOTSTRAP_SERVERS:-${PROFILE_KAFKA_BOOTSTRAP_SERVERS:-localhost:9092}}"
  export ORDS_VER="${ORDS_VER:-$PROFILE_ORDS_VERSION}"
  export APEX_WORKSPACE="${APEX_WORKSPACE:-$PROFILE_APEX_WORKSPACE}"

  export PUBLISHER_ENABLED="${PUBLISHER_ENABLED:-$PROFILE_PUBLISHER_ENABLED}"
  export PUBLISHER_CONTAINER_NAME="${PUBLISHER_CONTAINER_NAME:-$PROFILE_PUBLISHER_CONTAINER_NAME}"
  export PUBLISHER_HTTP_PORT="${PUBLISHER_HTTP_PORT:-$PROFILE_PUBLISHER_HTTP_PORT}"
  export PUBLISHER_HTTPS_PORT="${PUBLISHER_HTTPS_PORT:-$PROFILE_PUBLISHER_HTTPS_PORT}"

  # Tase 2: Artifactory / .env globaalne ülekirjutus
  if [ -n "$MAIN_DB_IMAGE" ]; then
    export RESOLVED_DB_IMAGE="$MAIN_DB_IMAGE"
  elif [ -n "$ARTIFACTORY_DOCKER_REGISTRY" ]; then
    RESOLVED_DB_IMAGE=$(echo "$RAW_CONTAINER_IMAGE" | sed -E "s#^(container-registry\.oracle\.com|docker\.io)#${ARTIFACTORY_DOCKER_REGISTRY}#")
    export RESOLVED_DB_IMAGE
  else
    export RESOLVED_DB_IMAGE="$RAW_CONTAINER_IMAGE"
  fi

  # Apple Silicon / ARM64 Fallback: Oracle publishes adb-free ONLY as linux/amd64.
  # On ARM64 hosts, adb-free causes "Exec format error", so fallback to multi-arch Oracle Free DB.
  local host_arch
  host_arch=$(uname -m 2>/dev/null || echo "x86_64")
  if [ "$host_arch" = "arm64" ] || [ "$host_arch" = "aarch64" ]; then
    if [[ "$RESOLVED_DB_IMAGE" == *"adb-free"* ]]; then
      export RESOLVED_DB_IMAGE="container-registry.oracle.com/database/free:latest"
    fi
  fi

  # ADB tuvastus
  if [ "$PROFILE_DB_TYPE" = "adb" ] || [ "$PROFILE_DB_TYPE" = "autonomous" ] || [[ "$RAW_CONTAINER_IMAGE" == *"adb-free"* ]]; then
    export IS_ADB="true"
  else
    export IS_ADB="false"
  fi

  # DB Versiooni tuletamine pildist
  local db_ver_label="Oracle Database 23ai Free (23.x)"
  if [[ "$RESOLVED_DB_IMAGE" == *"21"* ]]; then
    db_ver_label="Oracle Database 21c (21.x)"
  elif [[ "$RESOLVED_DB_IMAGE" == *"19"* ]]; then
    db_ver_label="Oracle Database 19c (19.x)"
  elif [[ "$RESOLVED_DB_IMAGE" == *"free"* ]] || [[ "$RESOLVED_DB_IMAGE" == *"23"* ]]; then
    db_ver_label="Oracle Database 23ai Free (23.x)"
  fi
  export PROFILE_DB_VERSION_LABEL="${PROFILE_DB_VERSION_LABEL:-$db_ver_label}"

  # ORDS URL resolution
  if [ -n "$ORDS_DOWNLOAD_URL" ]; then
    export RESOLVED_ORDS_URL="$ORDS_DOWNLOAD_URL"
  else
    export RESOLVED_ORDS_URL="$PROFILE_ORDS_DOWNLOAD_URL"
  fi

  # ORDS Base URL resolution (.env ORDS_URL / ORDS_HOST override or YAML profile)
  export RESOLVED_ORDS_HOST="${ORDS_HOST:-${PROFILE_ORDS_EXTERNAL_HOST:-${PROFILE_ORDS_HOST:-localhost}}}"
  local ords_port="${ORDS_HTTPS_PORT:-${ORDS_SSL_PORT:-${PROFILE_ORDS_EXTERNAL_PORT:-${PROFILE_ORDS_HTTPS_PORT:-8448}}}}"

  if [ -n "$ORDS_URL" ]; then
    export RESOLVED_ORDS_BASE_URL="$ORDS_URL"
  elif [ -n "$PROFILE_ORDS_EXTERNAL_URL" ]; then
    export RESOLVED_ORDS_BASE_URL="$PROFILE_ORDS_EXTERNAL_URL"
  else
    export RESOLVED_ORDS_BASE_URL="https://${RESOLVED_ORDS_HOST}:${ords_port}"
  fi

  # APEX URL resolution
  if [ -n "$APEX_DOWNLOAD_URL" ]; then
    export RESOLVED_APEX_URL="$APEX_DOWNLOAD_URL"
  else
    export RESOLVED_APEX_URL="$PROFILE_APEX_DOWNLOAD_URL"
  fi
}

# Abifunktsioon lisabaasi profiili pärimiseks (.env väärtusest DB_<dbname>_PROFILE või KEY_DB)
get_db_profile() {
  local dbname="$1"
  local first_inst
  first_inst=$(get_active_db_instances 2>/dev/null | head -n 1 | cut -d'|' -f2)
  if [ -z "$dbname" ] || [ "$dbname" = "apex_proxy" ] || [ "$dbname" = "main" ] || [ "$dbname" = "proxy" ]; then
    echo "${PROXY_DB:-${MAIN_DB_PROFILE:-${first_inst:-proxy-adb-oracle}}}"
    return
  fi
  local key_name
  key_name="$(echo "$dbname" | tr '[:lower:]' '[:upper:]')_DB"
  local custom_profile="${!key_name}"
  if [ -z "$custom_profile" ]; then
    local legacy_var="DB_${dbname}_PROFILE"
    custom_profile="${!legacy_var}"
  fi
  if [ -n "$custom_profile" ]; then
    echo "$custom_profile"
  else
    echo "bizapp-standard-oracle"
  fi
}

# Helper function to get/create secure wallet password stored in config/secrets/wallet_password.txt
get_wallet_password() {
  local secrets_dir="$WORKSPACE_DIR/config/secrets"
  local wallet_pass_file="$secrets_dir/wallet_password.txt"
  local pwd=""

  if [ -f "$wallet_pass_file" ]; then
    pwd=$(tr -d '\r\n' < "$wallet_pass_file")
  elif [ -n "$ORACLE_WALLET_PASSWORD" ]; then
    pwd="$ORACLE_WALLET_PASSWORD"
  fi

  if [ -z "$pwd" ] || [ ${#pwd} -lt 16 ] || [[ ! "$pwd" =~ [0-9] ]]; then
    local rand_str
    rand_str=$(LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 16 2>/dev/null || openssl rand -hex 8 | head -c 16)
    local extra_num=$((RANDOM % 10))
    pwd="W!${rand_str}${extra_num}#"
  fi

  mkdir -p "$secrets_dir" 2>/dev/null || true
  if [ ! -f "$wallet_pass_file" ] || [ "$(tr -d '\r\n' < "$wallet_pass_file" 2>/dev/null)" != "$pwd" ]; then
    echo -n "$pwd" > "$wallet_pass_file"
    chmod 600 "$wallet_pass_file" 2>/dev/null || true
  fi

  echo "$pwd"
}

# Helper function to list all active DB instances from active <NAME>_DB keys in .env
# Returns lines formatted as: <container_name>|<profile_name>|<env_var_key>
get_active_db_instances() {
  local env_file="$WORKSPACE_DIR/.env"
  local raw_instances=()
  local found_proxy=false

  if [ -f "$env_file" ]; then
    while IFS= read -r line || [ -n "$line" ]; do
      line=$(echo "$line" | sed 's/#.*//' | xargs)
      [ -z "$line" ] && continue
      
      if [[ "$line" =~ ^([A-Za-z0-9_.-]+)=([A-Za-z0-9_.-]+) ]]; then
        local key="${BASH_REMATCH[1]}"
        local profile="${BASH_REMATCH[2]}"
        
        # 1. Kontrollime, et võtme nimi viitab andmebaasile või profiilile (algab DB_/ORDS_/PROXY_ või lõppeb _DB/_PROXY/_PROFILE)
        if [[ "$key" =~ ^DB_ ]] || [[ "$key" =~ _DB$ ]] || [[ "$key" =~ ^ORDS_ ]] || [[ "$key" =~ _ORDS$ ]] || [[ "$key" =~ ^PROXY_ ]] || [[ "$key" =~ _PROXY$ ]] || [[ "$key" == "MAIN_DB_PROFILE" ]] || [[ "$key" == "PUB_DB" ]]; then
          local res_prof="$profile"
          case "$profile" in
            "bizapp-standard-oracle"|"bizapp-free"|"bizapp"|"app-free") res_prof="db-lis-oracle" ;;
            "bizapp-adb-oracle"|"bizapp-adb"|"app-adb") res_prof="db-lis-adb" ;;
            "proxy-standard-oracle"|"proxy-free") res_prof="db-proxy-oracle" ;;
            "proxy-adb-oracle"|"proxy-adb") res_prof="db-proxy-adb" ;;
            "proxy-standard-gvenzl"|"proxy-gvenzl") res_prof="db-proxy-gvenzl" ;;
            "publisher-free") res_prof="db-publisher-oracle" ;;
            "publisher-only") res_prof="db-publisher-gvenzl" ;;
            "appinfra-standard-gvenzl"|"appinfra"|"db-lis-gvenzl"|"lis-gvenzl") res_prof="db-infra-gvenzl" ;;
            "cicd-standard-oracle"|"cicd") res_prof="db-cicd" ;;
          esac

          # 2. Kontrollime, et väärtusele vastav profiili YAML fail on tõesti olemas kaustas config/profiles/databases/
          local check_profile_file="$WORKSPACE_DIR/config/profiles/databases/${res_prof}.yaml"
          [ ! -f "$check_profile_file" ] && check_profile_file="$WORKSPACE_DIR/config/profiles/databases/${profile}.yaml"
          [ ! -f "$check_profile_file" ] && check_profile_file="$WORKSPACE_DIR/config/profiles/${profile}.yaml"
          if [ -f "$check_profile_file" ]; then
            local container_name
            container_name=$(echo "$key" | tr '[:upper:]' '[:lower:]' | tr '_' '-')
            if [ "$container_name" = "db-proxy" ] || [ "$container_name" = "proxy-db" ] || [ "$container_name" = "db-apex-proxy" ]; then
              found_proxy=true
            fi
            raw_instances+=("${container_name}|${profile}|${key}")
          fi
        fi
      fi
    done < "$env_file"
  fi

  # Fallback kohaliku peabaasi jaoks (kui ühtegi baasi ei leitud .env failist)
  if [ "${#raw_instances[@]}" -eq 0 ]; then
    local main_profile="${MAIN_DB_PROFILE:-proxy-adb-oracle}"
    raw_instances+=("db-apex-proxy|${main_profile}|DB_APEX_PROXY")
  fi

  # Unikaalsuse tagamine: kui konteineri nimi kordub, lisatakse lõppu number (-2, -3 jne)
  local final_instances=()
  local used_names=()

  for item in "${raw_instances[@]}"; do
    IFS='|' read -r cname prof key <<< "$item"
    local unique_name="$cname"
    local counter=2
    while [[ " ${used_names[*]} " =~ " ${unique_name} " ]]; do
      unique_name="${cname}-${counter}"
      counter=$((counter + 1))
    done
    used_names+=("$unique_name")
    final_instances+=("${unique_name}|${prof}|${key}")
  done

  printf "%s\n" "${final_instances[@]}"
}

# Helper function to extract ALL container names declared inside profile YAML files
get_all_profile_container_names() {
  local names=()
  for p in "$WORKSPACE_DIR"/config/profiles/databases/*.yaml; do
    if [ -f "$p" ]; then
      local c1
      c1=$(parse_yaml_key "$p" "container_name")
      [ -n "$c1" ] && names+=("$c1")
    fi
  done
  printf "%s\n" "${names[@]}" | sort -u
}

get_required_secret_names() {
  local secrets=("apex_db_sys_password" "publisher_db_sys_password" "proxy_db_sys_password" "lis_db_sys_password" "apex_schema_password" "test_dev_password" "ords_listener_password" "apex_admin_password")
  for inst in $(get_active_db_instances 2>/dev/null); do
    local cname
    cname=$(echo "$inst" | cut -d'|' -f1)
    local db
    db=$(echo "$cname" | sed 's/^db-//' | tr '-' '_')
    local sec_name="${db}_db_sys_password"
    if [[ ! " ${secrets[*]} " =~ " ${sec_name} " ]]; then
      secrets+=("$sec_name")
    fi
  done
  echo "${secrets[*]}"
}

# Universal Container & Service Name Collision Resolver
_GLOBAL_USED_CONTAINER_NAMES=()

ensure_unique_name() {
  local raw_name="$1"
  local entity_type="${2:-Konteiner}"
  local resolved_name="$raw_name"
  local count=1

  while [[ " ${_GLOBAL_USED_CONTAINER_NAMES[*]} " =~ " ${resolved_name} " ]]; do
    count=$((count + 1))
    resolved_name="${raw_name}-${count}"
    echo "⚠️  HOIATUS [${entity_type}]: Nimi '${raw_name}' kordub! Kasutan unikaalset nime '${resolved_name}'." >&2
  done

  _GLOBAL_USED_CONTAINER_NAMES+=("$resolved_name")
  echo "$resolved_name"
}

# Web IDE Service Profile Loader
load_web_ide_profile() {
  local profile_name="${1:-${WEB_IDE_PROFILE:-web-ide-disabled}}"
  profile_name=$(basename "$profile_name" .yaml)

  local profile_file="$WORKSPACE_DIR/config/profiles/web-ide/${profile_name}.yaml"
  if [ ! -f "$profile_file" ]; then
    profile_file="$WORKSPACE_DIR/config/profiles/${profile_name}.yaml"
  fi
  if [ ! -f "$profile_file" ]; then
    profile_name="web-ide-disabled"
    profile_file="$WORKSPACE_DIR/config/profiles/web-ide/web-ide-disabled.yaml"
  fi

  export WEB_IDE_PROFILE_YAML="$profile_file"

  local raw_enabled
  raw_enabled=$(parse_yaml_key "$profile_file" "enabled")
  export WEB_IDE_ENABLED="${WEB_IDE_ENABLED:-${raw_enabled:-false}}"

  local raw_image
  raw_image=$(parse_yaml_key "$profile_file" "container_image")
  export WEB_IDE_CONTAINER_IMAGE="${WEB_IDE_CONTAINER_IMAGE:-${raw_image:-lscr.io/linuxserver/code-server:latest}}"

  local raw_build_local
  raw_build_local=$(parse_yaml_key "$profile_file" "build_local")
  export WEB_IDE_BUILD_LOCAL="${WEB_IDE_BUILD_LOCAL:-${raw_build_local:-true}}"

  local raw_http
  raw_http=$(parse_yaml_key "$profile_file" "http_port")
  export WEB_IDE_HTTP_PORT="${WEB_IDE_HTTP_PORT:-${raw_http:-8090}}"

  local raw_https
  raw_https=$(parse_yaml_key "$profile_file" "https_port")
  export WEB_IDE_HTTPS_PORT="${WEB_IDE_HTTPS_PORT:-${raw_https:-8449}}"

  local raw_cicd
  raw_cicd=$(parse_yaml_key "$profile_file" "cicd_ui_port")
  export CICD_WEB_UI_PORT="${CICD_WEB_UI_PORT:-${raw_cicd:-8091}}"

  local ag_block
  ag_block=$(awk '/antigravity:/{flag=1;next}/sqlcl:|github_cli:|act_cli:|openjdk:|extensions:/{flag=0}flag' "$profile_file" 2>/dev/null)
  local ag_enabled
  ag_enabled=$(echo "$ag_block" | parse_yaml_key "/dev/stdin" "enabled" | head -n 1)
  local ag_url
  ag_url=$(echo "$ag_block" | parse_yaml_key "/dev/stdin" "install_url" | head -n 1)
  export WEB_IDE_ANTIGRAVITY_ENABLED="${ag_enabled:-true}"
  export WEB_IDE_ANTIGRAVITY_INSTALL_URL="${ag_url:-https://antigravity.google/install.sh}"

  local sqlcl_block
  sqlcl_block=$(awk '/sqlcl:/{flag=1;next}/github_cli:|act_cli:|openjdk:|extensions:/{flag=0}flag' "$profile_file" 2>/dev/null)
  local sqlcl_enabled
  sqlcl_enabled=$(echo "$sqlcl_block" | parse_yaml_key "/dev/stdin" "enabled" | head -n 1)
  local sqlcl_url
  sqlcl_url=$(echo "$sqlcl_block" | parse_yaml_key "/dev/stdin" "download_url" | head -n 1)
  export WEB_IDE_SQLCL_ENABLED="${sqlcl_enabled:-true}"
  export WEB_IDE_SQLCL_DOWNLOAD_URL="${sqlcl_url:-https://download.oracle.com/otn_sqldev/sqlcl/sqlcl-latest.zip}"
}

# Helper function to ensure an Oracle DB container instance is fully OPEN and FREEPDB1 is READ WRITE
ensure_db_instance_open() {
  local container="$1"
  local max_retries="${2:-20}"
  [ -z "$container" ] && return 0

  if ! podman container exists "$container" 2>/dev/null; then
    return 1
  fi

  local count=0
  while [ $count -lt $max_retries ]; do
    local pdb_status
    pdb_status=$(echo "SET HEADING OFF FEEDBACK OFF; SELECT open_mode FROM v\$pdbs WHERE name='FREEPDB1'; EXIT;" | podman exec -i "$container" sqlplus -s / as sysdba 2>/dev/null | tr -d '\r\n' || true)
    if [[ "$pdb_status" == *"READ WRITE"* ]]; then
      return 0
    fi

    echo "STARTUP; ALTER PLUGGABLE DATABASE ALL OPEN; ALTER SYSTEM REGISTER; EXIT;" | podman exec -i "$container" sqlplus / as sysdba >/dev/null 2>&1 || true

    sleep 3
    count=$((count + 1))
  done

  local final_status
  final_status=$(echo "SET HEADING OFF FEEDBACK OFF; SELECT open_mode FROM v\$pdbs WHERE name='FREEPDB1'; EXIT;" | podman exec -i "$container" sqlplus -s / as sysdba 2>/dev/null | tr -d '\r\n' || true)
  if [[ "$final_status" == *"READ WRITE"* ]]; then
    return 0
  fi
  return 1
}

[ -n "$BASH_VERSION" ] && export -f ensure_db_instance_open >/dev/null 2>&1 || true

# If executed directly, run load_db_profile
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
  load_db_profile "$1"
  load_web_ide_profile
fi
