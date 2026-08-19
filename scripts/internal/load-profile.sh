#!/usr/bin/env bash
# ============================================================================
# Dynamic Database Profile Parser & Precedence Engine
# Implements 3-Level Precedence Hierarchy for DB Profiles, Images, & ZIP Files
# ============================================================================

set -e

_LOCAL_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$_LOCAL_SCRIPT_DIR/../.." && pwd)"

# Function to parse a simple YAML key value from profile file
parse_yaml_key() {
  local file="$1"
  local key="$2"
  grep -E "^[[:space:]]*${key}:" "$file" 2>/dev/null | head -n 1 | sed -E "s/^[[:space:]]*${key}:[[:space:]]*\"?([^\"]+)\"?$/\1/" | tr -d '\r\n' || true
}

# Main Profile Loader Function
load_db_profile() {
  local profile_name="$1"
  if [ -z "$profile_name" ]; then
    local first_inst=$(get_active_db_instances 2>/dev/null | head -n 1 | cut -d'|' -f2)
    profile_name="${MAIN_DB_PROFILE:-${first_inst:-proxy-adb-oracle}}"
  fi

  # Strip path or extension if provided
  profile_name=$(basename "$profile_name" .yaml)

  local profile_file="$WORKSPACE_DIR/config/profiles/databases/${profile_name}.yaml"
  if [ ! -f "$profile_file" ]; then
    profile_file="$WORKSPACE_DIR/config/profiles/${profile_name}.yaml"
  fi
  if [ ! -f "$profile_file" ]; then
    echo "⚠️  Hoiatus: Profiilifaili '${profile_name}.yaml' ei leitud kaustast config/profiles/databases/. Kasutan vaike-profiili 'proxy-adb-oracle'."
    profile_name="proxy-adb-oracle"
    profile_file="$WORKSPACE_DIR/config/profiles/databases/proxy-adb-oracle.yaml"
  fi

  # 1. Profiili põhiatribuudid
  export PROFILE_YAML="$profile_file"
  export PROFILE_ID=$(parse_yaml_key "$profile_file" "id")
  export PROFILE_NAME=$(parse_yaml_key "$profile_file" "name")

  export PROFILE_DESC=$(parse_yaml_key "$profile_file" "description")
  export PROFILE_FUNC=$(parse_yaml_key "$profile_file" "functionality")
  export PROFILE_DB_TYPE=$(parse_yaml_key "$profile_file" "db_type")
  export PROFILE_VENDOR=$(parse_yaml_key "$profile_file" "image_vendor")

  # 2. Andmebaasi parameetrid & Pildi 3-tasemeline prioriteet
  local raw_container_image=$(parse_yaml_key "$profile_file" "container_image")
  export PROFILE_WORKLOAD_TYPE=$(parse_yaml_key "$profile_file" "workload_type")
  export PROFILE_ADMIN_USER=$(parse_yaml_key "$profile_file" "admin_user")
  export PROFILE_ADMIN_ROLE=$(parse_yaml_key "$profile_file" "admin_role")
  export PROFILE_DEFAULT_SERVICE=$(parse_yaml_key "$profile_file" "default_service")
  export PROFILE_DB_PORT=$(parse_yaml_key "$profile_file" "db_port")
  export PROFILE_CONTAINER_PORT=$(parse_yaml_key "$profile_file" "container_port")
  export PROFILE_CONTAINER_PORT="${PROFILE_CONTAINER_PORT:-1521}"
  export PROFILE_DB_SID=$(parse_yaml_key "$profile_file" "db_sid")
  export PROFILE_DB_SID="${PROFILE_DB_SID:-FREE}"
  export PROFILE_DB_PDB=$(parse_yaml_key "$profile_file" "db_pdb")
  export PROFILE_DB_PDB="${PROFILE_DB_PDB:-MYATP}"
  export PROFILE_DB_MEMORY=$(parse_yaml_key "$profile_file" "db_memory_limit")
  export PROFILE_DB_MEMORY="${PROFILE_DB_MEMORY:-3072M}"
  export PROFILE_ORDS_MEMORY=$(parse_yaml_key "$profile_file" "ords_memory_limit")
  export PROFILE_ORDS_MEMORY="${PROFILE_ORDS_MEMORY:-1024M}"
  export PROFILE_WALLET_REQUIRED=$(parse_yaml_key "$profile_file" "wallet_required")
  export PROFILE_CONFIGURE_TDE=$(parse_yaml_key "$profile_file" "configure_tde")
  export PROFILE_ENCRYPT_TABLESPACES=$(parse_yaml_key "$profile_file" "encrypt_tablespaces")
  export PROFILE_KAFKA_BOOTSTRAP_SERVERS=$(parse_yaml_key "$profile_file" "kafka_bootstrap_servers")

  # Expose as fallback variables if not explicitly overridden in .env
  export CONFIGURE_TDE="${CONFIGURE_TDE:-${PROFILE_CONFIGURE_TDE:-true}}"
  export ENCRYPT_TABLESPACES="${ENCRYPT_TABLESPACES:-${PROFILE_ENCRYPT_TABLESPACES:-ALL}}"
  export KAFKA_BOOTSTRAP_SERVERS="${KAFKA_BOOTSTRAP_SERVERS:-${PROFILE_KAFKA_BOOTSTRAP_SERVERS:-localhost:9092}}"

  # Dynamically parse SYS wallet_alias from YAML users section
  local sys_usr_lower=$(echo "${PROFILE_ADMIN_USER:-sys}" | tr '[:upper:]' '[:lower:]')
  local sys_alias=$(awk -v usr="$sys_usr_lower" '
    /users:/{in_users=1; next}
    in_users && /^[[:space:]]*-/{
      if (curr_usr == usr && curr_alias != "") exit;
      curr_usr=""; curr_alias=""
    }
    in_users && /username:/{
      sub(/.*username:[[:space:]]*/, ""); gsub(/["\r]/, ""); curr_usr=tolower($0)
    }
    in_users && /wallet_alias:/{
      sub(/.*wallet_alias:[[:space:]]*/, ""); gsub(/["\r]/, ""); curr_alias=$0
    }
    END {
      if (curr_usr == usr) print curr_alias
    }
  ' "$profile_file" 2>/dev/null || echo "")

  export PROFILE_SYS_WALLET_ALIAS="${sys_alias:-SYS}"

  # Tase 2: Artifactory / .env globaalne ülekirjutus
  if [ -n "$MAIN_DB_IMAGE" ]; then
    export RESOLVED_DB_IMAGE="$MAIN_DB_IMAGE"
  elif [ -n "$ARTIFACTORY_DOCKER_REGISTRY" ]; then
    # Asendame avaliku registri sise-registriga
    RESOLVED_DB_IMAGE=$(echo "$raw_container_image" | sed -E "s#^(container-registry\.oracle\.com|docker\.io)#${ARTIFACTORY_DOCKER_REGISTRY}#")
    export RESOLVED_DB_IMAGE
  else
    export RESOLVED_DB_IMAGE="$raw_container_image"
  fi

  # ADB tuvastus
  if [ "$PROFILE_DB_TYPE" = "adb" ] || [[ "$RESOLVED_DB_IMAGE" == *"adb-free"* ]]; then
    export IS_ADB="true"
  else
    export IS_ADB="false"
  fi

  # 3. Komponentide ZIP resolution & 3-tasemeline prioriteet (ORDS & APEX)
  local ords_block=$(awk '/ords:/{flag=1;next}/apex:|sqlcl:|users:/{flag=0}flag' "$profile_file" 2>/dev/null)
  local apex_block=$(awk '/apex:/{flag=1;next}/sqlcl:|users:/{flag=0}flag' "$profile_file" 2>/dev/null)

  local profile_ords_url=$(echo "$ords_block" | parse_yaml_key "/dev/stdin" "download_url" | head -n 1)
  local profile_ords_http=$(echo "$ords_block" | parse_yaml_key "/dev/stdin" "http_port" | head -n 1)
  local profile_ords_https=$(echo "$ords_block" | parse_yaml_key "/dev/stdin" "https_port" | head -n 1)
  local profile_ords_c_name=$(echo "$ords_block" | parse_yaml_key "/dev/stdin" "container_name" | head -n 1)
  local profile_ords_s_name=$(echo "$ords_block" | parse_yaml_key "/dev/stdin" "service_name" | head -n 1)
  local profile_ords_mode=$(echo "$ords_block" | parse_yaml_key "/dev/stdin" "mode" | head -n 1)
  local profile_ords_ext_url=$(echo "$ords_block" | parse_yaml_key "/dev/stdin" "external_ords_url" | head -n 1)
  local profile_ords_ext_host=$(echo "$ords_block" | parse_yaml_key "/dev/stdin" "external_ords_host" | head -n 1)
  local profile_ords_ext_port=$(echo "$ords_block" | parse_yaml_key "/dev/stdin" "external_ords_port" | head -n 1)
  local profile_ords_ext_user=$(echo "$ords_block" | parse_yaml_key "/dev/stdin" "external_ords_user" | head -n 1)
  local profile_ords_w_alias=$(echo "$ords_block" | parse_yaml_key "/dev/stdin" "wallet_alias" | head -n 1)

  local profile_apex_url=$(echo "$apex_block" | parse_yaml_key "/dev/stdin" "download_url" | head -n 1)
  local profile_apex_ver=$(echo "$apex_block" | parse_yaml_key "/dev/stdin" "version" | head -n 1)
  local profile_apex_enabled=$(echo "$apex_block" | parse_yaml_key "/dev/stdin" "enabled" | head -n 1)
  local profile_apex_ws=$(echo "$apex_block" | parse_yaml_key "/dev/stdin" "workspace" | head -n 1)

  export PROFILE_ORDS_MODE="${profile_ords_mode:-local}"
  export PROFILE_ORDS_EXTERNAL_URL="${profile_ords_ext_url:-}"
  export PROFILE_ORDS_EXTERNAL_HOST="${profile_ords_ext_host:-}"
  export PROFILE_ORDS_EXTERNAL_PORT="${profile_ords_ext_port:-}"
  export PROFILE_ORDS_EXTERNAL_USER="${profile_ords_ext_user:-}"
  export PROFILE_ORDS_WALLET_ALIAS="${profile_ords_w_alias:-}"

  export PROFILE_ORDS_DOWNLOAD_URL="${profile_ords_url:-https://download.oracle.com/otn_software/java/ords/ords-latest.zip}"
  export PROFILE_ORDS_HTTP_PORT="${profile_ords_http:-8088}"
  export PROFILE_ORDS_HTTPS_PORT="${profile_ords_https:-8443}"
  export PROFILE_ORDS_CONTAINER_NAME="${profile_ords_c_name:-oracle-ords-dev}"
  export PROFILE_ORDS_SERVICE_NAME="${profile_ords_s_name:-dev-ords}"

  export PROFILE_APEX_DOWNLOAD_URL="${profile_apex_url:-https://download.oracle.com/otn_software/apex/apex_24.1.zip}"
  export PROFILE_APEX_VERSION="${profile_apex_ver:-24.1}"
  export PROFILE_APEX_ENABLED="${profile_apex_enabled:-true}"
  export PROFILE_APEX_WORKSPACE="${profile_apex_ws:-PROXY_WORKSPACE}"
  export APEX_WORKSPACE="${APEX_WORKSPACE:-$PROFILE_APEX_WORKSPACE}"

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
  local first_inst=$(get_active_db_instances 2>/dev/null | head -n 1 | cut -d'|' -f2)
  if [ -z "$dbname" ] || [ "$dbname" = "apex_proxy" ] || [ "$dbname" = "main" ] || [ "$dbname" = "proxy" ]; then
    echo "${PROXY_DB:-${MAIN_DB_PROFILE:-${first_inst:-proxy-adb-oracle}}}"
    return
  fi
  local key_name="$(echo "$dbname" | tr '[:lower:]' '[:upper:]')_DB"
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
    local rand_str=$(LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 16 2>/dev/null || openssl rand -hex 8 | head -c 16)
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
        
        # 1. Kontrollime, et võtme nimi viitab andmebaasile (algab DB_ või lõppeb _DB / _PROFILE)
        if [[ "$key" =~ ^DB_ ]] || [[ "$key" =~ _DB$ ]] || [[ "$key" == "MAIN_DB_PROFILE" ]] || [[ "$key" == "PROXY_DB" ]] || [[ "$key" == "PUB_DB" ]]; then
          # 2. Kontrollime, et väärtusele vastav profiili YAML fail on tõesti olemas kaustas config/profiles/databases/
          local check_profile_file="$WORKSPACE_DIR/config/profiles/databases/${profile}.yaml"
          [ ! -f "$check_profile_file" ] && check_profile_file="$WORKSPACE_DIR/config/profiles/${profile}.yaml"
          if [ -f "$check_profile_file" ]; then
            local container_name=$(echo "$key" | tr '[:upper:]' '[:lower:]' | tr '_' '-')
            if [ "$container_name" = "db-proxy" ] || [ "$container_name" = "proxy-db" ]; then
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

get_required_secret_names() {
  local secrets=("apex_db_sys_password" "publisher_db_sys_password" "apex_schema_password" "test_dev_password" "ords_listener_password" "apex_admin_password")
  for inst in $(get_active_db_instances 2>/dev/null); do
    local cname=$(echo "$inst" | cut -d'|' -f1 | tr '-' '_')
    if [[ "$cname" != "db_proxy" && "$cname" != "proxy_db" ]]; then
      secrets+=("${cname}_db_sys_password")
    fi
  done
  echo "${secrets[*]}"
}

# ============================================================================
# Central Universal Container & Service Name Collision Resolver
# Ensures unique container and service names across all DBs, ORDS, Apps, etc.
# Usage: ensure_unique_name "desired_name" "entity_type"
# ============================================================================
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
  local profile_name="${1:-${WEB_IDE_PROFILE:-web-ide-standard}}"
  profile_name=$(basename "$profile_name" .yaml)

  local profile_file="$WORKSPACE_DIR/config/profiles/web-ide/${profile_name}.yaml"
  if [ ! -f "$profile_file" ]; then
    profile_file="$WORKSPACE_DIR/config/profiles/${profile_name}.yaml"
  fi
  if [ ! -f "$profile_file" ]; then
    profile_name="web-ide-standard"
    profile_file="$WORKSPACE_DIR/config/profiles/web-ide/web-ide-standard.yaml"
  fi

  export WEB_IDE_PROFILE_YAML="$profile_file"

  local raw_enabled=$(parse_yaml_key "$profile_file" "enabled")
  export WEB_IDE_ENABLED="${WEB_IDE_ENABLED:-${raw_enabled:-true}}"

  local raw_image=$(parse_yaml_key "$profile_file" "container_image")
  export WEB_IDE_CONTAINER_IMAGE="${WEB_IDE_CONTAINER_IMAGE:-${raw_image:-lscr.io/linuxserver/code-server:latest}}"

  local raw_build_local=$(parse_yaml_key "$profile_file" "build_local")
  export WEB_IDE_BUILD_LOCAL="${WEB_IDE_BUILD_LOCAL:-${raw_build_local:-true}}"

  local raw_http=$(parse_yaml_key "$profile_file" "http_port")
  export WEB_IDE_HTTP_PORT="${WEB_IDE_HTTP_PORT:-${raw_http:-8090}}"

  local raw_https=$(parse_yaml_key "$profile_file" "https_port")
  export WEB_IDE_HTTPS_PORT="${WEB_IDE_HTTPS_PORT:-${raw_https:-8449}}"

  local raw_cicd=$(parse_yaml_key "$profile_file" "cicd_ui_port")
  export CICD_WEB_UI_PORT="${CICD_WEB_UI_PORT:-${raw_cicd:-8091}}"

  # Parse Antigravity tool settings
  local ag_block=$(awk '/antigravity:/{flag=1;next}/sqlcl:|github_cli:|act_cli:|openjdk:|extensions:/{flag=0}flag' "$profile_file" 2>/dev/null)
  local ag_enabled=$(echo "$ag_block" | parse_yaml_key "/dev/stdin" "enabled" | head -n 1)
  local ag_url=$(echo "$ag_block" | parse_yaml_key "/dev/stdin" "install_url" | head -n 1)
  export WEB_IDE_ANTIGRAVITY_ENABLED="${ag_enabled:-true}"
  export WEB_IDE_ANTIGRAVITY_INSTALL_URL="${ag_url:-https://antigravity.google/install.sh}"

  # Parse SQLcl tool settings
  local sqlcl_block=$(awk '/sqlcl:/{flag=1;next}/github_cli:|act_cli:|openjdk:|extensions:/{flag=0}flag' "$profile_file" 2>/dev/null)
  local sqlcl_enabled=$(echo "$sqlcl_block" | parse_yaml_key "/dev/stdin" "enabled" | head -n 1)
  local sqlcl_url=$(echo "$sqlcl_block" | parse_yaml_key "/dev/stdin" "download_url" | head -n 1)
  export WEB_IDE_SQLCL_ENABLED="${sqlcl_enabled:-true}"
  export WEB_IDE_SQLCL_DOWNLOAD_URL="${sqlcl_url:-https://download.oracle.com/otn_sqldev/sqlcl/sqlcl-latest.zip}"
}

# If executed directly, run load_db_profile
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
  load_db_profile "$1"
  load_web_ide_profile
fi
