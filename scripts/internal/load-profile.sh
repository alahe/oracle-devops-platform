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

# Function to parse container_name specifically from the database section of a profile
parse_db_container_name() {
  local file="$1"
  [ ! -f "$file" ] && return 0
  python3 -c "import yaml; d = yaml.safe_load(open('$file')) or {}; print((d.get('database') or {}).get('container_name') or '')" 2>/dev/null || true
}

# Fast Python-based single-pass profile exporter
_export_db_profile_python() {
  local profile_file="$1"
  local role="${2:-}"
  python3 - "$profile_file" "$role" << 'PYEOF' 2>/dev/null
import sys, yaml, os

profile_file = sys.argv[1]
role = sys.argv[2] if len(sys.argv) > 2 else ""
if not role:
    role = os.environ.get("DB_ROLE", os.environ.get("INSTANCE_ROLE", ""))
role_clean = role.lower().replace("db-", "").replace("-db", "").replace("_db", "").replace("db_", "")

role_ports = {
    'alise': 1533,
    'proxy': 1532,
    'publisher': 1531,
    'forms': 1534,
}

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
comp = data.get('database_features', data.get('components', {}))
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

# Dynamic role-based defaults for universal profiles
db_port_val = db.get('db_port')
if not db_port_val or (prof.get('id') in ['db-oracle', 'db-gvenzl', 'db-adb'] and role_clean in role_ports):
    db_port_val = role_ports.get(role_clean, db.get('db_port', 1533))

pool_name_val = ords.get('pool_name', '')
if not pool_name_val and role_clean:
    pool_name_val = role_clean

workspace_val = apex.get('workspace', '')
if not workspace_val and role_clean:
    workspace_val = f"{role_clean.upper()}_WORKSPACE"

container_name_val = db.get('container_name', '')
if not container_name_val and role_clean:
    container_name_val = f"db-{role_clean}"
if not container_name_val:
    container_name_val = prof.get('id', 'db-oracle')

lines = [
    f"export PROFILE_YAML={q(profile_file)}",
    f"export PROFILE_ID={q(prof.get('id', ''))}",
    f"export PROFILE_NAME={q(prof.get('name', ''))}",
    f"export PROFILE_DESC={q(prof.get('description', ''))}",
    f"export PROFILE_FUNC={q(prof.get('functionality', ''))}",
    f"export PROFILE_DB_TYPE={q(db_type_val)}",
    f"export PROFILE_VENDOR={q(prof.get('image_vendor', 'oracle'))}",
    f"export PROFILE_CONTAINER_NAME={q(container_name_val)}",
    f"export PROFILE_WORKLOAD_TYPE={q(db.get('workload_type', 'NONE'))}",
    f"export PROFILE_ADMIN_USER={q(db.get('admin_user', 'sys'))}",
    f"export PROFILE_ADMIN_ROLE={q(db.get('admin_role', 'SYSDBA'))}",
    f"export PROFILE_DEFAULT_SERVICE={q(db.get('default_service', 'FREEPDB1'))}",
    f"export PROFILE_DB_PORT={q(db_port_val or 1533)}",
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
    f"export PROFILE_ORDS_INSTALL_IN_DB={q(str(ords.get('install_in_db', True)).lower())}",
    f"export PROFILE_ORDS_VERIFY_VERSION_MATCH={q(str(ords.get('verify_version_match', False)).lower())}",
    f"export PROFILE_ORDS_POOL_NAME={q(pool_name_val)}",
    f"export PROFILE_ORDS_URL_MAPPING={q(ords.get('url_mapping', f'/ords/{pool_name_val}/' if pool_name_val else ''))}",
    f"export PROFILE_ORDS_SCHEMA_ALIAS={q(ords.get('schema_alias', ''))}",
    f"export PROFILE_ORDS_MODE={q(ords.get('mode', 'local'))}",
    f"export PROFILE_ORDS_EXTERNAL_URL={q(ords.get('external_ords_url', ''))}",
    f"export PROFILE_ORDS_EXTERNAL_HOST={q(ords.get('external_ords_host', ''))}",
    f"export PROFILE_ORDS_EXTERNAL_PORT={q(ords.get('external_ords_port', ''))}",
    f"export PROFILE_ORDS_EXTERNAL_USER={q(ords.get('external_ords_user', ''))}",
    f"export PROFILE_ORDS_WALLET_ALIAS={q(ords.get('wallet_alias', ''))}",
    f"export PROFILE_ORDS_VERSION={q(ords.get('version', 'latest'))}",
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
    f"export PROFILE_APEX_DOWNLOAD_URL={q(apex.get('download_url', 'https://download.oracle.com/otn_software/apex/apex-latest.zip'))}",
    f"export PROFILE_APEX_VERSION={q(apex.get('version', 'latest'))}",
    f"export PROFILE_APEX_WORKSPACE={q(workspace_val or 'PROXY_WORKSPACE')}",
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

# Function to resolve the latest available APEX version and patch dynamically
resolve_apex_latest() {
  local apex_bin_dir="$WORKSPACE_DIR/binaries/apex"
  local latest_ver="26.1"
  local latest_zip=""

  if [ -d "$apex_bin_dir" ]; then
    local found_zips
    found_zips=$(find "$apex_bin_dir" -maxdepth 1 -name "apex*.zip" 2>/dev/null | sort -V | tail -n 1 || echo "")
    if [ -n "$found_zips" ]; then
      latest_zip="$found_zips"
      local fname
      fname=$(basename "$found_zips")
      if [[ "$fname" =~ apex_([0-9]+(\.[0-9]+)*) ]]; then
        latest_ver="${BASH_REMATCH[1]}"
      fi
    fi
  fi

  local patch_dir="$WORKSPACE_DIR/patches/apex"
  local latest_patch=""
  if [ -d "$patch_dir" ]; then
    latest_patch=$(find "$patch_dir" -maxdepth 2 -name "*.zip" 2>/dev/null | sort -V | tail -n 1 || echo "")
  fi

  export PROFILE_APEX_RESOLVED_VERSION="$latest_ver"
  export PROFILE_APEX_ZIP_PATH="$latest_zip"
  export PROFILE_APEX_LATEST_PATCH="$latest_patch"
}

# ORDS Service Profile Loader
load_ords_profile() {
  local ords_prof="${1:-${ORDS_PROFILE:-ords-image}}"
  ords_prof=$(basename "$ords_prof" .yaml)
  local ords_file="$WORKSPACE_DIR/config/profiles/ords/${ords_prof}.yaml"
  [ ! -f "$ords_file" ] && ords_file="$WORKSPACE_DIR/config/profiles/ords/ords-image.yaml"

  if [ -f "$ords_file" ]; then
    local ords_img ords_ver ords_cname ords_hport ords_sport ords_itype ords_rhost ords_ruser ords_rpath ords_idir
    ords_img=$(parse_yaml_key "$ords_file" "container_image")
    ords_ver=$(parse_yaml_key "$ords_file" "version")
    ords_cname=$(parse_yaml_key "$ords_file" "container_name")
    ords_hport=$(parse_yaml_key "$ords_file" "http_port")
    ords_sport=$(parse_yaml_key "$ords_file" "https_port")
    ords_itype=$(parse_yaml_key "$ords_file" "install_type")
    ords_rhost=$(parse_yaml_key "$ords_file" "remote_host")
    ords_ruser=$(parse_yaml_key "$ords_file" "remote_ssh_user")
    ords_rpath=$(parse_yaml_key "$ords_file" "remote_path")
    ords_idir=$(parse_yaml_key "$ords_file" "install_dir")

    export PROFILE_ORDS_CONTAINER_IMAGE="${ords_img:-container-registry.oracle.com/database/ords:latest}"
    export PROFILE_ORDS_VERSION="${ords_ver:-latest}"
    export PROFILE_ORDS_CONTAINER_NAME="${ords_cname:-app-ords}"
    export PROFILE_ORDS_SERVICE_NAME="${ords_cname:-app-ords}"
    export PROFILE_ORDS_HTTP_PORT="${ords_hport:-8088}"
    export PROFILE_ORDS_HTTPS_PORT="${ords_sport:-8448}"
    export PROFILE_ORDS_INSTALL_TYPE="${ords_itype:-image}"
    export PROFILE_ORDS_REMOTE_HOST="${ords_rhost:-}"
    export PROFILE_ORDS_REMOTE_USER="${ords_ruser:-oracle}"
    export PROFILE_ORDS_REMOTE_PATH="${ords_rpath:-/opt/oracle/ords}"
    export PROFILE_ORDS_INSTALL_DIR="${ords_idir:-/opt/oracle/ords}"
  fi
}

# Main Profile Loader Function
load_db_profile() {
  local profile_name="${1:-}"
  local instance_role="${2:-}"
  if [ -z "$profile_name" ]; then
    local first_inst
    first_inst=$((get_active_db_instances 2>/dev/null || true) | head -n 1 | cut -d'|' -f2)
    profile_name="${MAIN_DB_PROFILE:-${first_inst:-NONE}}"
  fi

  # Strip path or extension if provided
  profile_name=$(basename "$profile_name" .yaml)

  # Handle zero-database blueprints cleanly (MAIN_DB_PROFILE=NONE)
  if [ "$profile_name" = "NONE" ] || [ "$profile_name" = "none" ] || [ "$profile_name" = "disabled" ]; then
    export DB_ENABLED="false"
    export PROFILE_NAME="NONE"
    export PROFILE_CONTAINER_NAME="none"
    export PROFILE_DEFAULT_SERVICE="FREEPDB1"
    export PROFILE_DB_TYPE="none"
    export PROFILE_APEX_ENABLED="false"
    export PROFILE_ORDS_ENABLED="false"
    return 0
  fi

  local profile_file="$WORKSPACE_DIR/config/profiles/databases/${profile_name}.yaml"
  if [ ! -f "$profile_file" ]; then
    profile_file="$WORKSPACE_DIR/config/profiles/${profile_name}.yaml"
  fi

  if [ ! -f "$profile_file" ]; then
    # Universal backwards compatibility alias mapping if exact profile file not found
    case "$profile_name" in
      "bizapp-standard-oracle"|"bizapp-free"|"bizapp"|"app-free"|"db-alise-oracle"|"db-lis-oracle"|"db-oracle") profile_name="db-oracle" ;;
      "bizapp-adb-oracle"|"bizapp-adb"|"app-adb"|"db-alise-adb"|"db-lis-adb"|"db-adb") profile_name="db-adb" ;;
      "proxy-standard-oracle"|"proxy-free"|"db-proxy-oracle") profile_name="db-oracle" ;;
      "proxy-adb-oracle"|"proxy-adb"|"db-proxy-adb") profile_name="db-adb" ;;
      "proxy-standard-gvenzl"|"proxy-gvenzl"|"db-proxy-gvenzl"|"db-gvenzl") profile_name="db-gvenzl" ;;
      "publisher-free"|"db-publisher-oracle") profile_name="db-oracle" ;;
      "publisher-only"|"db-publisher-gvenzl") profile_name="db-gvenzl" ;;
      "forms-standard-oracle"|"db-forms-oracle") profile_name="db-oracle" ;;
      "forms-standard-gvenzl"|"db-forms-gvenzl") profile_name="db-gvenzl" ;;
      "appinfra-standard-gvenzl"|"appinfra"|"db-lis-gvenzl"|"lis-gvenzl"|"db-infra-gvenzl") profile_name="db-gvenzl" ;;
      "cicd-standard-oracle"|"cicd"|"db-cicd") profile_name="db-oracle" ;;
    esac

    profile_file="$WORKSPACE_DIR/config/profiles/databases/${profile_name}.yaml"
    if [ ! -f "$profile_file" ]; then
      profile_file="$WORKSPACE_DIR/config/profiles/${profile_name}.yaml"
    fi
    if [ ! -f "$profile_file" ]; then
      profile_name="db-oracle"
      profile_file="$WORKSPACE_DIR/config/profiles/databases/db-oracle.yaml"
    fi
  fi

  # 1. Execute single-pass exporter with instance role
  local script_exports
  script_exports=$(_export_db_profile_python "$profile_file" "$instance_role")

  if [ -n "$script_exports" ]; then
    eval "$script_exports"
  fi

  # 2. Resolve APEX version dynamically if 'latest'
  resolve_apex_latest
  if [ "$PROFILE_APEX_VERSION" = "latest" ] || [ -z "$PROFILE_APEX_VERSION" ]; then
    export PROFILE_APEX_VERSION="$PROFILE_APEX_RESOLVED_VERSION"
  fi

  if [ -z "$script_exports" ]; then
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

  # Tier 2: Artifactory / .env global override
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

  # Prebuilt Fast-Start Image Discovery:
  # If local prebuilt image exists in Podman/Docker, auto-switch to prebuilt image and set flags
  if [ "${PROFILE_APEX_INSTALL_REQUIRED:-true}" = "true" ] && [ "${IS_ADB:-false}" != "true" ] && [ -z "$MAIN_DB_IMAGE" ]; then
    if podman image exists "localhost/oracle-free-apex:23ai-${PROFILE_VENDOR:-gvenzl}-apex${PROFILE_APEX_VERSION:-26.1}" 2>/dev/null; then
      export RESOLVED_DB_IMAGE="localhost/oracle-free-apex:23ai-${PROFILE_VENDOR:-gvenzl}-apex${PROFILE_APEX_VERSION:-26.1}"
      export PROFILE_APEX_PREINSTALLED="true"
    elif podman image exists "localhost/oracle-free-apex:latest" 2>/dev/null; then
      export RESOLVED_DB_IMAGE="localhost/oracle-free-apex:latest"
      export PROFILE_APEX_PREINSTALLED="true"
    fi
  fi

  if [ "${PROFILE_FORMS_ENABLED:-false}" = "true" ] || [ "${FORMS_ENABLED:-false}" = "true" ]; then
    if [ -z "$FORMS_CONTAINER_IMAGE" ]; then
      if podman image exists "localhost/oracle-forms:14.1.2" 2>/dev/null; then
        export FORMS_CONTAINER_IMAGE="localhost/oracle-forms:14.1.2"
        export FORMS_PREINSTALLED="true"
      elif podman image exists "localhost/oracle-forms:latest" 2>/dev/null; then
        export FORMS_CONTAINER_IMAGE="localhost/oracle-forms:latest"
        export FORMS_PREINSTALLED="true"
      fi
    fi
  fi

  if [ "${PROFILE_PUBLISHER_ENABLED:-false}" = "true" ] || [ "${PUBLISHER_ENABLED:-false}" = "true" ]; then
    if [ -z "$PUBLISHER_CONTAINER_IMAGE" ]; then
      if podman image exists "localhost/oracle-publisher-domain:latest" 2>/dev/null; then
        export PUBLISHER_CONTAINER_IMAGE="localhost/oracle-publisher-domain:latest"
        export PUBLISHER_PREINSTALLED="true"
      elif podman image exists "localhost/oracle-publisher:latest" 2>/dev/null; then
        export PUBLISHER_CONTAINER_IMAGE="localhost/oracle-publisher:latest"
      fi
    fi
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

# Helper function to query secondary DB profile from .env (DB_<dbname>_PROFILE or KEY_DB)
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

# Helper function to resolve and source the active blueprint file
# Priority:
# 1. $SELECTED_BLUEPRINT or $ACTIVE_BLUEPRINT environment variable
# 2. .active_blueprint file in WORKSPACE_DIR
# 3. Fallback: Blueprint 0 (.env.0-default-proxy-ords)
resolve_active_blueprint() {
  local bp_id="${1:-${SELECTED_BLUEPRINT:-${ACTIVE_BLUEPRINT:-}}}"
  if [ -z "$bp_id" ] && [ -f "$WORKSPACE_DIR/.active_blueprint" ]; then
    bp_id=$(tr -d ' \r\n' < "$WORKSPACE_DIR/.active_blueprint" 2>/dev/null || echo "")
  fi
  [ -z "$bp_id" ] && bp_id="0"

  local bp_file=""
  bp_file=$(find "$WORKSPACE_DIR/config/blueprints" -maxdepth 1 -name ".env.${bp_id}-*" 2>/dev/null | head -n 1)
  if [ -z "$bp_file" ]; then
    bp_file=$(find "$WORKSPACE_DIR/config/blueprints" -maxdepth 1 -name ".env.${bp_id}" 2>/dev/null | head -n 1)
  fi
  if [ -z "$bp_file" ]; then
    bp_file=$(find "$WORKSPACE_DIR/config/blueprints" -maxdepth 1 -name ".env.0-*" 2>/dev/null | head -n 1)
  fi

  if [ -f "$bp_file" ]; then
    export ACTIVE_BP_FILE="$bp_file"
    export ACTIVE_BP_ID="$bp_id"
    set -a
    source "$bp_file"
    set +a
  fi
}

[ -n "$BASH_VERSION" ] && export -f resolve_active_blueprint >/dev/null 2>&1 || true

# Helper function to list all active DB instances from active blueprint configuration
# Returns lines formatted as: <container_name>|<profile_name>|<env_var_key>
get_active_db_instances() {
  local raw_instances=()
  local found_proxy=false
  local has_explicit_none=false

  # 1. First priority: In-memory environment variables (already sourced from blueprint)
  local mem_none_count=0
  local mem_db_count=0
  local checked_keys=()
  for k in DB_PROXY DB_PUBLISHER DB_FORMS DB_ALISE DB_PROXY_STANDALONE DB_GVENZL DB_ADB DB_INFRA DB_CICD DB_LIS; do
    checked_keys+=("$k")
  done
  for k in $(compgen -v 2>/dev/null | grep -E '^DB_[A-Z0-9_]+$' | sort -u || true); do
    [[ " ${checked_keys[*]} " =~ " ${k} " ]] || checked_keys+=("$k")
  done
  for env_k in "${checked_keys[@]}"; do
    local prof_val=""
    eval "prof_val=\"\${$env_k:-}\""
    [ -z "$prof_val" ] && continue
    if [ "$prof_val" = "NONE" ]; then
      mem_db_count=$((mem_db_count + 1))
      mem_none_count=$((mem_none_count + 1))
      continue
    fi
    local pfile="$WORKSPACE_DIR/config/profiles/databases/${prof_val}.yaml"
    [ ! -f "$pfile" ] && pfile="$WORKSPACE_DIR/config/profiles/${prof_val}.yaml"
    if [ -f "$pfile" ]; then
      mem_db_count=$((mem_db_count + 1))
      local c_name=""
      c_name=$(parse_db_container_name "$pfile")
      [ -z "$c_name" ] && c_name=$(echo "$env_k" | tr '[:upper:]' '[:lower:]' | tr '_' '-')
      raw_instances+=("${c_name}|${prof_val}|${env_k}")
    fi
  done
  if [ "$mem_db_count" -gt 0 ] && [ "$mem_none_count" -eq "$mem_db_count" ]; then
    has_explicit_none=true
  fi

  # 2. Second priority: If no in-memory DB keys, check if a standalone profile is active
  if [ "${#raw_instances[*]}" -eq 0 ] && [ "$has_explicit_none" = "false" ]; then
    if [ -n "${PUBLISHER_DESIGNER_PROFILE:-}" ] || [ -n "${WEB_IDE_PROFILE:-}" ]; then
      has_explicit_none=true
    else
      resolve_active_blueprint
    fi
    local src_file="${ACTIVE_BP_FILE:-}"
    if [ -n "$src_file" ] && [ -f "$src_file" ]; then
      local none_count=0
      local db_count=0
      local file_keys=()
      for k in $(grep -E '^DB_[A-Z0-9_]+=' "$src_file" 2>/dev/null | cut -d'=' -f1 | sort -u || true); do
        file_keys+=("$k")
      done
      [ ${#file_keys[@]} -eq 0 ] && file_keys=(DB_PROXY DB_PUBLISHER DB_FORMS DB_ALISE DB_PROXY_STANDALONE DB_GVENZL DB_ADB)
      for env_k in "${file_keys[@]}"; do
        local prof_val
        prof_val=$(grep -E "^${env_k}=" "$src_file" 2>/dev/null | cut -d'=' -f2 | tr -d ' "\r\n' || echo "")
        [ -z "$prof_val" ] && continue
        if [ "$prof_val" = "NONE" ]; then
          db_count=$((db_count + 1))
          none_count=$((none_count + 1))
        else
          local pfile="$WORKSPACE_DIR/config/profiles/databases/${prof_val}.yaml"
          [ ! -f "$pfile" ] && pfile="$WORKSPACE_DIR/config/profiles/${prof_val}.yaml"
          if [ -f "$pfile" ]; then
            db_count=$((db_count + 1))
            local c_name=""
            c_name=$(parse_db_container_name "$pfile")
            [ -z "$c_name" ] && c_name=$(echo "$env_k" | tr '[:upper:]' '[:lower:]' | tr '_' '-')
            raw_instances+=("${c_name}|${prof_val}|${env_k}")
          fi
        fi
      done
      if [ "$db_count" -gt 0 ] && [ "$none_count" -eq "$db_count" ]; then
        has_explicit_none=true
      fi
    fi
  fi

  # Fallback for local primary database ONLY if MAIN_DB_PROFILE is explicitly set and not NONE
  if [ "${#raw_instances[*]}" -eq 0 ] && [ "$has_explicit_none" = "false" ] && [ -n "${MAIN_DB_PROFILE:-}" ] && [ "$MAIN_DB_PROFILE" != "NONE" ]; then
    raw_instances+=("db-apex-proxy|${MAIN_DB_PROFILE}|DB_APEX_PROXY")
  fi

  # Ensure uniqueness: if container name repeats, append suffix (-2, -3, etc.)
  local final_instances=()
  local used_names=()

  if [ "${#raw_instances[*]}" -gt 0 ]; then
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
  fi

  if [ "${#final_instances[*]}" -gt 0 ]; then
    printf "%s\n" "${final_instances[@]}"
  fi
  return 0
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
  local secrets=("apex_db_sys_password" "publisher_db_sys_password" "proxy_db_sys_password" "alise_db_sys_password" "lis_db_sys_password" "apex_schema_password" "test_dev_password" "ords_listener_password" "apex_admin_password")
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
  local profile_name="${1:-${WEB_IDE_PROFILE:-}}"
  if [ -z "$profile_name" ] || [ "$profile_name" = "NONE" ] || [ "$profile_name" = "web-ide-disabled" ]; then
    export WEB_IDE_ENABLED="false"
    export WEB_IDE_PROFILE="web-ide-disabled"
    return 0
  fi
  profile_name=$(basename "$profile_name" .yaml)

  # Alias legacy / shorthand names to canonical profile
  if [ "$profile_name" = "web-ide-dev" ] || [ "$profile_name" = "web-ide-full" ] || [ "$profile_name" = "standard" ] || [ "$profile_name" = "dev" ]; then
    profile_name="web-ide-standard"
  fi

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

# Publisher Designer Workstation Service Profile Loader
load_publisher_designer_profile() {
  local profile_name="${1:-${PUBLISHER_DESIGNER_PROFILE:-}}"
  if [ -z "$profile_name" ] || [ "$profile_name" = "NONE" ] || [ "$profile_name" = "none" ] || [ "$profile_name" = "disabled" ] || [ "$profile_name" = "false" ]; then
    export PUBLISHER_DESIGNER_ENABLED="false"
    export PUBLISHER_DESIGNER_PROFILE="disabled"
    return 0
  fi
  profile_name=$(basename "$profile_name" .yaml)

  # Alias legacy / shorthand names to canonical profile
  if [ "$profile_name" = "publisher-designer" ] || [ "$profile_name" = "designer" ] || [ "$profile_name" = "standard" ]; then
    profile_name="publisher-designer-standard"
  fi

  local profile_file="$WORKSPACE_DIR/config/profiles/publisher/${profile_name}.yaml"
  if [ ! -f "$profile_file" ]; then
    profile_file="$WORKSPACE_DIR/config/profiles/publisher/publisher-designer.yaml"
  fi
  if [ ! -f "$profile_file" ]; then
    profile_file="$WORKSPACE_DIR/config/profiles/${profile_name}.yaml"
  fi

  if [ ! -f "$profile_file" ]; then
    export PUBLISHER_DESIGNER_ENABLED="false"
    export PUBLISHER_DESIGNER_PROFILE="disabled"
    return 0
  fi

  export PUBLISHER_DESIGNER_PROFILE_YAML="$profile_file"
  export PUBLISHER_DESIGNER_ENABLED="true"

  local raw_cname
  raw_cname=$(parse_yaml_key "$profile_file" "name")
  export PUBLISHER_DESIGNER_CONTAINER_NAME="${PUBLISHER_DESIGNER_CONTAINER_NAME:-${raw_cname:-app-publisher-designer}}"

  local raw_image
  raw_image=$(parse_yaml_key "$profile_file" "image")
  export PUBLISHER_DESIGNER_CONTAINER_IMAGE="${PUBLISHER_DESIGNER_CONTAINER_IMAGE:-${raw_image:-localhost/oracle-publisher-designer:latest}}"

  local raw_build_local
  raw_build_local=$(parse_yaml_key "$profile_file" "build_local")
  export PUBLISHER_DESIGNER_BUILD_LOCAL="${PUBLISHER_DESIGNER_BUILD_LOCAL:-${raw_build_local:-true}}"

  local raw_build_context
  raw_build_context=$(parse_yaml_key "$profile_file" "build_context")
  export PUBLISHER_DESIGNER_BUILD_CONTEXT="${PUBLISHER_DESIGNER_BUILD_CONTEXT:-${raw_build_context:-./docker/publisher-designer}}"

  local raw_http
  raw_http=$(awk '/ports:/{flag=1;next}/volumes:|environment:/{flag=0}flag' "$profile_file" 2>/dev/null | grep -E '^[[:space:]]*-?[[:space:]]*host_port:[[:space:]]*[0-9]+' | head -n 1 | sed -E 's/.*:[[:space:]]*([0-9]+).*/\1/' | tr -d '\r\n')
  export PUBLISHER_DESIGNER_HTTP_PORT="${PUBLISHER_DESIGNER_HTTP_PORT:-${raw_http:-6083}}"

  local raw_vnc
  raw_vnc=$(awk '/ports:/{flag=1;next}/volumes:|environment:/{flag=0}flag' "$profile_file" 2>/dev/null | grep -E '^[[:space:]]*-?[[:space:]]*host_port:[[:space:]]*[0-9]+' | sed -n '2p' | sed -E 's/.*:[[:space:]]*([0-9]+).*/\1/' | tr -d '\r\n')
  export PUBLISHER_DESIGNER_VNC_PORT="${PUBLISHER_DESIGNER_VNC_PORT:-${raw_vnc:-5903}}"
}

# Helper function to ensure an Oracle DB container instance is fully OPEN and FREEPDB1 is READ WRITE
ensure_db_instance_open() {
  local container="$1"
  local max_retries="${2:-20}"
  [ -z "$container" ] && return 0

  if ! podman container exists "$container" 2>/dev/null; then
    return 1
  fi

  local in_sql
  in_sql=$(podman exec "$container" bash -c 'ls -d /opt/oracle/product/*/dbhomeFree/sqlcl/bin/sql 2>/dev/null | head -n 1' 2>/dev/null || echo "")

  local count=0
  while [ $count -lt $max_retries ]; do
    local pdb_status=""
    if [ -n "$in_sql" ]; then
      pdb_status=$(printf "SET HEADING OFF\nSET FEEDBACK OFF\nSELECT open_mode FROM v\$pdbs WHERE name='FREEPDB1';\nEXIT;\n" | podman exec -i "$container" "$in_sql" -s / as sysdba 2>/dev/null | tr -d '\r\n' || true)
    fi
    if [[ "$pdb_status" == *"READ WRITE"* ]]; then
      return 0
    fi

    if [ -n "$in_sql" ]; then
      echo "STARTUP; ALTER PLUGGABLE DATABASE ALL OPEN; ALTER SYSTEM REGISTER; EXIT;" | podman exec -i "$container" "$in_sql" -s / as sysdba >/dev/null 2>&1 || true
    fi

    sleep 3
    count=$((count + 1))
  done

  return 0
}

# ----------------------------------------------------------------------------
# Declarative Service Enablement Helpers (Zero SKIP_* Dependency)
# ----------------------------------------------------------------------------

# Returns 0 (true) if ORDS service container is explicitly enabled in blueprint, 1 (false) otherwise
is_ords_enabled() {
  if [ -n "${ORDS_PROFILE:-}" ]; then
    if [ "$ORDS_PROFILE" = "NONE" ] || [ "$ORDS_PROFILE" = "none" ] || [ "$ORDS_PROFILE" = "disabled" ] || [ "$ORDS_PROFILE" = "false" ]; then
      return 1
    fi
    return 0
  fi
  return 1
}

# Returns 0 (true) if app-ords container is currently running
is_ords_running() {
  command -v podman &>/dev/null && [ "$(podman inspect --format='{{.State.Status}}' app-ords 2>/dev/null)" = "running" ]
}

# Checks if active database profile requires ORDS database objects (ORDS_METADATA)
is_db_ords_metadata_required() {
  local active_list
  active_list=$(get_active_db_instances 2>/dev/null || echo "")
  [ -z "$active_list" ] && return 1

  for inst in $active_list; do
    local prof
    prof=$(echo "$inst" | cut -d'|' -f2)
    local pfile="$WORKSPACE_DIR/config/profiles/databases/${prof}.yaml"
    [ ! -f "$pfile" ] && pfile="$WORKSPACE_DIR/config/profiles/${prof}.yaml"
    if [ -f "$pfile" ]; then
      local o_en
      o_en=$(awk '/ords:/{flag=1;next}/forms:|apex:|publisher:|users:/{flag=0}flag' "$pfile" | grep -E '^[[:space:]]*enabled:' | head -n 1 | sed -E 's/.*:[[:space:]]*"?([^" #]+)"?.*/\1/' | tr -d '\r\n')
      if [ "$o_en" = "true" ]; then
        return 0
      fi
    fi
  done
  return 1
}

# Checks if in-database installation of ORDS schema is required (true for Oracle Free, false for ADB)
is_db_ords_install_required() {
  local prof="${1:-}"
  if [ -n "$prof" ]; then
    local pfile="$WORKSPACE_DIR/config/profiles/databases/${prof}.yaml"
    [ ! -f "$pfile" ] && pfile="$WORKSPACE_DIR/config/profiles/${prof}.yaml"
    if [ -f "$pfile" ]; then
      local val
      val=$(awk '/ords:/{flag=1;next}/forms:|apex:|publisher:|users:/{flag=0}flag' "$pfile" | grep -E '^[[:space:]]*install_in_db:' | head -n 1 | sed -E 's/.*:[[:space:]]*"?([^" #]+)"?.*/\1/' | tr -d '\r\n')
      [ "$val" = "false" ] && return 1
    fi
  fi
  if [ "${PROFILE_ORDS_INSTALL_IN_DB:-true}" = "false" ]; then
    return 1
  fi
  return 0
}

# 3-tier resolution for target ORDS version:
# 1. From running env0 container (app-ords)
# 2. From database profile YAML (ords.version)
# 3. Default latest
resolve_target_ords_version() {
  if command -v podman &>/dev/null && [ "$(podman inspect --format='{{.State.Status}}' app-ords 2>/dev/null)" = "running" ]; then
    local c_ver
    c_ver=$(podman exec app-ords ords --version 2>/dev/null | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' | head -n 1 || true)
    if [ -n "$c_ver" ]; then
      echo "$c_ver"
      return 0
    fi
  fi

  if [ -n "${PROFILE_ORDS_VERSION:-}" ] && [ "$PROFILE_ORDS_VERSION" != "latest" ]; then
    echo "$PROFILE_ORDS_VERSION"
    return 0
  fi

  echo "latest"
  return 0
}

# Verifies if ADB in-database ORDS version matches running ORDS server/container
check_adb_ords_version_match() {
  local target_container="${1:-db-alise}"
  local srv_ver
  srv_ver=$(resolve_target_ords_version)

  local adb_ords_ver=""
  if command -v podman &>/dev/null && [ "$(podman inspect --format='{{.State.Status}}' "$target_container" 2>/dev/null)" = "running" ]; then
    local in_sql
    in_sql=$(podman exec "$target_container" bash -c 'ls -d /opt/oracle/product/*/dbhomeFree/sqlcl/bin/sql 2>/dev/null | head -n 1' 2>/dev/null || echo "")
    if [ -n "$in_sql" ]; then
      adb_ords_ver=$(podman exec -i "$target_container" "$in_sql" -s / as sysdba 2>/dev/null << 'EOSQL' | grep -Eo '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n 1 || true
ALTER SESSION SET CONTAINER = FREEPDB1;
SELECT version FROM ords_metadata.ords_version WHERE ROWNUM = 1;
EXIT;
EOSQL
)
    fi
  fi

  if [ -z "$adb_ords_ver" ]; then
    return 0
  fi

  local adb_maj_min
  adb_maj_min=$(echo "$adb_ords_ver" | cut -d'.' -f1,2)
  local srv_maj_min
  srv_maj_min=$(echo "$srv_ver" | cut -d'.' -f1,2)

  if [ "$srv_ver" = "latest" ] || [ "$adb_maj_min" = "$srv_maj_min" ]; then
    return 0
  fi

  return 1
}

# Returns 0 (true) if Oracle Forms service is enabled, 1 (false) otherwise
is_forms_enabled() {
  # 1. Explicit profile reference
  if [ -n "${FORMS_PROFILE:-}" ]; then
    if [ "$FORMS_PROFILE" = "NONE" ] || [ "$FORMS_PROFILE" = "disabled" ] || [ "$FORMS_PROFILE" = "false" ]; then
      return 1
    fi
    return 0
  fi

  # 2. Check DB_FORMS definition
  if [ -n "${DB_FORMS:-}" ] && [ "$DB_FORMS" != "NONE" ]; then
    return 0
  fi

  # 2.5. Check FORMS_PUBLISHER_PROFILE definition
  if [ -n "${FORMS_PUBLISHER_PROFILE:-}" ] && [ "$FORMS_PUBLISHER_PROFILE" != "NONE" ] && [ "$FORMS_PUBLISHER_PROFILE" != "disabled" ] && [ "$FORMS_PUBLISHER_PROFILE" != "false" ]; then
    return 0
  fi

  # 3. Derive from active database profiles
  local active_list
  active_list=$(get_active_db_instances 2>/dev/null || echo "")
  for inst in $active_list; do
    local prof
    prof=$(echo "$inst" | cut -d'|' -f2)
    local pfile="$WORKSPACE_DIR/config/profiles/databases/${prof}.yaml"
    [ ! -f "$pfile" ] && pfile="$WORKSPACE_DIR/config/profiles/${prof}.yaml"
    if [ -f "$pfile" ]; then
      local f_en
      f_en=$(awk '/forms:/{flag=1;next}/ords:|apex:|publisher:|users:/{flag=0}flag' "$pfile" | grep -E '^[[:space:]]*enabled:' | head -n 1 | sed -E 's/.*:[[:space:]]*"?([^"]+)"?/\1/' | tr -d '\r\n')
      if [ "$f_en" = "true" ]; then
        return 0
      fi
    fi
  done

  return 1
}

# Returns 0 (true) if Analytics Publisher service is enabled, 1 (false) otherwise
is_publisher_enabled() {
  # 1. Explicit profile reference
  if [ -n "${PUBLISHER_PROFILE:-}" ]; then
    if [ "$PUBLISHER_PROFILE" = "NONE" ] || [ "$PUBLISHER_PROFILE" = "disabled" ] || [ "$PUBLISHER_PROFILE" = "false" ]; then
      return 1
    fi
    return 0
  fi

  # 2. Check DB_PUBLISHER definition
  if [ -n "${DB_PUBLISHER:-}" ] && [ "$DB_PUBLISHER" != "NONE" ]; then
    return 0
  fi

  # 2.5. Check FORMS_PUBLISHER_PROFILE definition
  if [ -n "${FORMS_PUBLISHER_PROFILE:-}" ] && [ "$FORMS_PUBLISHER_PROFILE" != "NONE" ] && [ "$FORMS_PUBLISHER_PROFILE" != "disabled" ] && [ "$FORMS_PUBLISHER_PROFILE" != "false" ]; then
    return 0
  fi

  # 3. Derive from active database profiles
  local active_list
  active_list=$(get_active_db_instances 2>/dev/null || echo "")
  for inst in $active_list; do
    local prof
    prof=$(echo "$inst" | cut -d'|' -f2)
    local pfile="$WORKSPACE_DIR/config/profiles/databases/${prof}.yaml"
    [ ! -f "$pfile" ] && pfile="$WORKSPACE_DIR/config/profiles/${prof}.yaml"
    if [ -f "$pfile" ]; then
      local p_en
      p_en=$(awk '/publisher:/{flag=1;next}/ords:|apex:|forms:|users:/{flag=0}flag' "$pfile" | grep -E '^[[:space:]]*enabled:' | head -n 1 | sed -E 's/.*:[[:space:]]*"?([^"]+)"?/\1/' | tr -d '\r\n')
      if [ "$p_en" = "true" ]; then
        return 0
      fi
    fi
  done

  return 1
}

# Returns 0 (true) if Web IDE service is enabled, 1 (false) otherwise
is_web_ide_enabled() {
  if [ -n "${WEB_IDE_PROFILE:-}" ]; then
    if [ "$WEB_IDE_PROFILE" = "NONE" ] || [ "$WEB_IDE_PROFILE" = "web-ide-disabled" ] || [ "$WEB_IDE_PROFILE" = "disabled" ] || [ "$WEB_IDE_PROFILE" = "false" ]; then
      return 1
    fi
    return 0
  fi
  return 0
}

# Returns 0 (true) if Publisher Designer service is enabled, 1 (false) otherwise
is_publisher_designer_enabled() {
  if [ -n "${PUBLISHER_DESIGNER_PROFILE:-}" ]; then
    if [ "$PUBLISHER_DESIGNER_PROFILE" = "NONE" ] || [ "$PUBLISHER_DESIGNER_PROFILE" = "none" ] || [ "$PUBLISHER_DESIGNER_PROFILE" = "disabled" ] || [ "$PUBLISHER_DESIGNER_PROFILE" = "false" ]; then
      return 1
    fi
    return 0
  fi
  if [ "${PUBLISHER_DESIGNER_ENABLED:-false}" = "true" ]; then
    return 0
  fi
  return 1
}

[ -n "$BASH_VERSION" ] && export -f ensure_db_instance_open is_ords_enabled is_ords_running is_db_ords_metadata_required is_db_ords_install_required resolve_target_ords_version check_adb_ords_version_match is_forms_enabled is_publisher_enabled is_web_ide_enabled is_publisher_designer_enabled load_publisher_designer_profile >/dev/null 2>&1 || true

# If executed directly, run load_db_profile
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
  load_db_profile "${1:-}"
  load_web_ide_profile
  load_publisher_designer_profile
fi
