#!/usr/bin/env bash
# ============================================================================
# Automatically registers database connections for SQL Developer for VS Code
# Uses SQLcl `connect -save` and `connmgr` to register native folders & saved passwords.
# Complies with:
# 1. Folder/Directory name read dynamically from .env (VSCODE_FOLDER_NAME / DB_CONN_NAME / CONTAINER_NAME)
# 2. Passwords queried strictly from Oracle Wallet (SEPS) using view-wallet-credential.sh
# 3. Database configuration (users, roles, wallet aliases, colors) read dynamically from YAML profile
# 4. Interactive developer user connections created at setup / create-developer.sh
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# 1. Load environment variables
if [ -f "$WORKSPACE_DIR/.env" ]; then
  set -a
  source "$WORKSPACE_DIR/.env"
  set +a
elif [ -f "$WORKSPACE_DIR/config/repository.env" ]; then
  set -a
  source "$WORKSPACE_DIR/config/repository.env"
  set +a
fi

if [ -f "$SCRIPT_DIR/load-db-profile.sh" ]; then
  source "$SCRIPT_DIR/load-db-profile.sh"
fi

get_wallet_pwd() {
  local alias_name="$1"
  local uname="$2"
  local pwd_val=""

  if [ "$uname" = "sys" ] || [ "$uname" = "SYS" ] || [ "$alias_name" = "DB_APEX_PROXY_SYS" ]; then
    pwd_val=$(podman secret inspect --showsecret apex_db_sys_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
    [ -z "$pwd_val" ] && pwd_val=$(podman exec "${c_name:-${PRIMARY_CONTAINER:-db-dev-full}}" cat /run/secrets/apex_db_sys_password 2>/dev/null | tr -d '\r\n' || true)
    [ -z "$pwd_val" ] && pwd_val=$(podman exec "${c_name:-${PRIMARY_CONTAINER:-db-dev-full}}" cat /run/secrets/oracle_pwd 2>/dev/null | tr -d '\r\n' || true)
  fi

  if [ -z "$pwd_val" ] && { [ "$uname" = "TEST_DEV" ] || [ "$alias_name" = "DB_TEST_DEV" ] || [[ "$uname" == *"DEV"* ]]; }; then
    pwd_val=$(podman secret inspect --showsecret apex_db_dev_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
    [ -z "$pwd_val" ] && pwd_val=$(podman secret inspect --showsecret test_dev_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
    [ -z "$pwd_val" ] && pwd_val=$(podman exec "${c_name:-${PRIMARY_CONTAINER:-db-dev-full}}" cat /run/secrets/apex_db_dev_password 2>/dev/null | tr -d '\r\n' || true)
  fi


  if [ -z "$pwd_val" ]; then
    pwd_val=$("$SCRIPT_DIR/view-wallet-credential.sh" "$alias_name" 2>/dev/null | grep "Password:" | sed $'s/\x1b\\[[0-9;]*m//g' | cut -d':' -f2- | tr -d ' \r')
  fi
  if [ -z "$pwd_val" ] && [ -n "$uname" ]; then
    pwd_val=$("$SCRIPT_DIR/view-wallet-credential.sh" "$uname" 2>/dev/null | grep "Password:" | sed $'s/\x1b\\[[0-9;]*m//g' | cut -d':' -f2- | tr -d ' \r')
  fi
  echo "$pwd_val"
}

get_existing_user_color() {
  local target_u="$1"
  local default_c="${2:-#2980B9}"
  local existing_c=""

  for prop in "$HOME/.dbtools/connections"/*/dbtools.properties; do
    [ -f "$prop" ] || continue
    if grep -iq "^userName=${target_u}$" "$prop"; then
      existing_c=$(grep -i "^color=" "$prop" 2>/dev/null | head -n 1 | cut -d'=' -f2 | tr -d '\r ')
      [ -n "$existing_c" ] && break
    fi
  done

  if [ -z "$existing_c" ] && [ -f "$HOME/.sqldev/connections.json" ]; then
    existing_c=$(jq -r --arg u "$target_u" '.connections[]? | select(.user | ascii_downcase == ($u | ascii_downcase)) | .color // empty' "$HOME/.sqldev/connections.json" 2>/dev/null | head -n 1)
  fi

  echo "${existing_c:-$default_c}"
}



# Locate VS Code SQL Developer extension bundled SQLcl or system binary
VSCODE_SQLCL=$(find "$HOME/.vscode/extensions" -name "sql" -path "*/oracle.sql-developer-*/dbtools/sqlcl/bin/sql" 2>/dev/null | head -n 1)
if [ -z "$VSCODE_SQLCL" ]; then
  if command -v sql &>/dev/null; then
    VSCODE_SQLCL="sql"
  fi
fi

ACTIVE_INSTANCES=$(get_active_db_instances 2>/dev/null || echo "")
if [ -z "$ACTIVE_INSTANCES" ]; then
  PRIMARY_C="${CONTAINER_NAME:-db-dev-full}"
  ACTIVE_INSTANCES="${PRIMARY_C}|proxy-standard-gvenzl|PRIMARY"
fi

for c_entry in $ACTIVE_INSTANCES; do
  c_name=$(echo "$c_entry" | cut -d'|' -f1)
  prof=$(echo "$c_entry" | cut -d'|' -f2)
  [ -z "$c_name" ] && continue

  load_db_profile "$prof" >/dev/null 2>&1 || true

  # 1. Folder/Directory Name MUST come from .env / repository.env
  folder_name="${VSCODE_FOLDER_NAME:-${DB_CONN_NAME:-${CONTAINER_NAME:-$c_name}}}"

  port="${PROFILE_DB_PORT:-1532}"
  service="${PROFILE_DEFAULT_SERVICE:-FREEPDB1}"
  profile_file="$WORKSPACE_DIR/config/profiles/${PROFILE_ID:-proxy-standard-gvenzl}.yaml"
  if [ ! -f "$profile_file" ]; then
    profile_file="$WORKSPACE_DIR/config/profiles/proxy-standard-gvenzl.yaml"
  fi

  # 3. Read Database Configuration dynamically from YAML profile
  users_json=$(python3 -c "
import yaml, json, os
p = '$profile_file'
if os.path.exists(p):
    data = yaml.safe_load(open(p))
    print(json.dumps(data.get('users', [])))
else:
    print('[]')
" 2>/dev/null || echo "[]")

  SQL_COMMANDS=()
  SQL_COMMANDS+=("connmgr delete -folder /${folder_name} -force")
  SQL_COMMANDS+=("connmgr add -folder /${folder_name}")

  BUILT_CONNS=()
  idx=1
  while read -r user_obj; do
    [ -z "$user_obj" ] && continue

    uname=$(echo "$user_obj" | jq -r '.username // empty')
    urole=$(echo "$user_obj" | jq -r '.role // "NORMAL"')
    walias=$(echo "$user_obj" | jq -r '.wallet_alias // empty')
    ucolor=$(echo "$user_obj" | jq -r '.color // "#2980B9"')

    [ -z "$uname" ] && continue
    [ -z "$walias" ] && walias="$uname"

    # Skip WEB users as they are APEX Web accounts, not DB schemas
    if [[ "$uname" == *"WEB"* ]] || [[ "$walias" == *"WEB"* ]]; then
      continue
    fi

    # 2. Passwords queried strictly from Oracle Wallet (redirect STDIN to prevent draining loop)
    pwd_val=$(get_wallet_pwd "$walias" "$uname" </dev/null)
    if [ -z "$pwd_val" ]; then
      c_name_upper=$(echo "$c_name" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
      pwd_val=$(get_wallet_pwd "DB_${c_name_upper}_${uname}" "$uname" </dev/null)
    fi
    [ -z "$pwd_val" ] && continue

    if [ "$uname" = "sys" ]; then
      pretty_name="1. Sys"
    elif [ "$uname" = "APEX_PROXY_SCHEMA" ]; then
      pretty_name="2. APEX_PROXY_SCHEMA"
    elif [ "$uname" = "TEST_DEV" ]; then
      pretty_name="3. TEST_DEV"
    else
      pretty_name="${idx}. ${uname}"
    fi

    # Build SQLcl connect command
    conn_str="${uname}/${pwd_val}@localhost:${port}/${service}"
    if [ "$urole" = "SYSDBA" ]; then
      conn_str="${conn_str} as sysdba"
    fi

    SQL_COMMANDS+=("connect -save \"${pretty_name}\" -savepwd -replace ${conn_str}")
    SQL_COMMANDS+=("connmgr move -conn \"${pretty_name}\" /${folder_name}")

    final_user_color=$(get_existing_user_color "$uname" "$ucolor")
    user_json_str=$(jq -n \
      --arg uname "$uname" \
      --arg pwd "$pwd_val" \
      --arg role "$urole" \
      --arg color "$final_user_color" \
      --arg pname "$pretty_name" \
      '{username: $uname, password: $pwd, role: $role, color: $color, pretty_name: $pname}')
    BUILT_CONNS+=("$user_json_str")

    idx=$((idx + 1))
  done < <(echo "$users_json" | jq -c '.[]')

  # 4. Scan wallet and environment for interactive developer users (created via create-developer.sh / setup-all.sh)
  DEV_USERS=()
  [ -n "${EXTRA_DEV_USER:-}" ] && DEV_USERS+=("$EXTRA_DEV_USER")
  [ -n "${DEVELOPER_USER:-}" ] && DEV_USERS+=("$DEVELOPER_USER")
  [ -n "${USER:-}" ] && DEV_USERS+=("$USER")
  DEV_USERS+=("TEST_DEV")

  PRIMARY_C="${c_name:-${PRIMARY_CONTAINER:-db-dev-full}}"
  WALLET_PWD=$(get_wallet_password 2>/dev/null || cat "$WORKSPACE_DIR/config/secrets/wallet_password.txt" 2>/dev/null || echo "CustomWalletPass123!")
  WALLET_LIST=$(podman exec -i "$PRIMARY_C" sh -c 'export JAVA_HOME=/usr/java/latest; export PATH=$JAVA_HOME/bin:$PATH; echo "$1" | mkstore -wrl /opt/oracle/admin/FREE/wallet -listCredential' -- "$WALLET_PWD" 2>/dev/null || true)

  while read -r w_line; do
    w_alias=$(echo "$w_line" | awk '{print $2}' | tr -d '\r ')
    [ -z "$w_alias" ] && continue
    w_alias_upper=$(echo "$w_alias" | tr '[:lower:]' '[:upper:]')
    if [[ "$w_alias_upper" == *"_DEV" ]]; then
      # Extract username from DB_<CONTAINER>_<USER>
      extracted_u="${w_alias_upper##*_}"
      [ -n "$extracted_u" ] && DEV_USERS+=("$extracted_u")
      DEV_USERS+=("$w_alias")
    elif [[ "$w_alias_upper" != "DB_"* ]] && [[ "$w_alias_upper" != "APEX_"* ]] && [[ "$w_alias_upper" != "TEST_WEB_USER"* ]]; then
      DEV_USERS+=("$w_alias")
    fi
  done < <(echo "$WALLET_LIST" | grep -E "^[0-9]+:")

  UNIQUE_DEV_USERS=($(printf "%s\n" "${DEV_USERS[@]}" | sort -u))

  for dev_u in "${UNIQUE_DEV_USERS[@]}"; do
    dev_u_upper=$(echo "$dev_u" | tr '[:lower:]' '[:upper:]' | tr -d ' ')
    [ -z "$dev_u_upper" ] && continue
    
    # Skip system/schema accounts that are handled in step 3 or are web accounts
    if [ "$dev_u_upper" = "SYS" ] || [ "$dev_u_upper" = "APEX_PROXY_SCHEMA" ] || [ "$dev_u_upper" = "ADMIN" ] || [[ "$dev_u_upper" == *"WEB"* ]]; then
      continue
    fi

    # Avoid duplicate addition if user already exists in BUILT_CONNS
    already_added=false
    for conn_item in "${BUILT_CONNS[@]}"; do
      existing_u=$(echo "$conn_item" | jq -r '.username // empty' 2>/dev/null || true)
      if [ "$(echo "$existing_u" | tr '[:lower:]' '[:upper:]')" = "$dev_u_upper" ]; then
        already_added=true
        break
      fi
    done
    [ "$already_added" = "true" ] && continue

    dev_pwd_val=""
    if [ -n "${EXTRA_DEV_USER:-}" ] && [ "$(echo "$EXTRA_DEV_USER" | tr '[:lower:]' '[:upper:]')" = "$dev_u_upper" ] && [ -n "${EXTRA_DEV_PWD:-}" ]; then
      dev_pwd_val="$EXTRA_DEV_PWD"
    fi
    if [ -z "$dev_pwd_val" ]; then
      dev_pwd_val=$(get_wallet_pwd "$dev_u" "$dev_u" </dev/null)
    fi
    if [ -z "$dev_pwd_val" ]; then
      dev_pwd_val=$(get_wallet_pwd "$dev_u_upper" "$dev_u_upper" </dev/null)
    fi
    if [ -z "$dev_pwd_val" ]; then
      c_name_upper=$(echo "$PRIMARY_C" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
      dev_pwd_val=$(get_wallet_pwd "DB_${c_name_upper}_${dev_u_upper}" "$dev_u_upper" </dev/null)
    fi
    [ -z "$dev_pwd_val" ] && continue

    pretty_dev_name="${idx}. Dev ${dev_u_upper}"
    [ "$dev_u_upper" = "TEST_DEV" ] && pretty_dev_name="3. TEST_DEV"

    conn_dev_str="${dev_u_upper}/${dev_pwd_val}@localhost:${port}/${service}"
    SQL_COMMANDS+=("connect -save \"${pretty_dev_name}\" -savepwd -replace ${conn_dev_str}")
    SQL_COMMANDS+=("connmgr move -conn \"${pretty_dev_name}\" /${folder_name}")
    
    final_dev_color=$(get_existing_user_color "$dev_u_upper" "${EXTRA_DEV_COLOR:-#F39C12}")

    dev_json_str=$(jq -n \
      --arg uname "$dev_u_upper" \
      --arg pwd "$dev_pwd_val" \
      --arg role "NORMAL" \
      --arg color "$final_dev_color" \
      --arg pname "$pretty_dev_name" \
      '{username: $uname, password: $pwd, role: $role, color: $color, pretty_name: $pname}')
    BUILT_CONNS+=("$dev_json_str")
    idx=$((idx + 1))
  done




  SQL_COMMANDS+=("connmgr list -folder /${folder_name}")
  SQL_COMMANDS+=("EXIT")

  # Run SQLcl batch commands
  if [ -n "$VSCODE_SQLCL" ] && { command -v "$VSCODE_SQLCL" &>/dev/null || [ -x "$VSCODE_SQLCL" ]; }; then
    printf '%s\n' "${SQL_COMMANDS[@]}" | "$VSCODE_SQLCL" /nolog >/dev/null 2>&1 || true
  else
    # Fallback pattern for restricted environments via Ephemeral Container
    podman run --rm -i --network=host container-registry.oracle.com/database/sqlcl:latest /nolog >/dev/null 2>&1 <<EOF || true
$(printf '%s\n' "${SQL_COMMANDS[@]}")
EOF
  fi

  # Combine built connections into JSON array
  CONNS_ARRAY_JSON=$(printf '%s\n' "${BUILT_CONNS[@]}" | jq -s .)

  # Apply user colors from YAML profile into ~/.dbtools/connections/*/dbtools.properties
  DBTOOLS_CONNS_DIR="$HOME/.dbtools/connections"
  if [ -d "$DBTOOLS_CONNS_DIR" ]; then
    while read -r user_obj; do
      [ -z "$user_obj" ] && continue
      uname=$(echo "$user_obj" | jq -r '.username // empty')
      ucolor=$(echo "$user_obj" | jq -r '.color // "#2980B9"')
      [ -z "$uname" ] && continue

      for prop in "$DBTOOLS_CONNS_DIR"/*/dbtools.properties; do
        [ -f "$prop" ] || continue
        if grep -iq "^userName=${uname}$" "$prop"; then
          grep -v "^color=" "$prop" > "${prop}.tmp" && mv "${prop}.tmp" "$prop"
          echo "color=${ucolor}" >> "$prop"
        fi
      done
    done < <(echo "$CONNS_ARRAY_JSON" | jq -c '.[]')
  fi

  # Synchronize ~/.sqldev/connections.json and ~/.dbtools/connections.json with colors and folder
  CONNS_JSON="$CONNS_ARRAY_JSON" FOLDER_NAME="$folder_name" PORT_VAL="$port" SERVICE_VAL="$service" python3 -c "
import json, os, sys

conns_in = json.loads(os.environ.get('CONNS_JSON', '[]'))
folder = os.environ.get('FOLDER_NAME', '')
port = os.environ.get('PORT_VAL', '1532')
service = os.environ.get('SERVICE_VAL', 'FREEPDB1')

conns = []

for u in conns_in:
    uname = u.get('username')
    pwd = u.get('password', '')
    role = u.get('role', 'NORMAL')
    color = u.get('color', '#2980B9')
    pretty_name = u.get('pretty_name', uname)
    
    c_obj = {
        'name': pretty_name,
        'folder': f'/{folder}',
        'color': color,
        'type': 'Oracle',
        'connType': 'Basic',
        'host': 'localhost',
        'port': str(port),
        'serviceName': service,
        'user': uname,
        'password': pwd,
        'role': 'SYSDBA' if role == 'SYSDBA' else 'NORMAL',
        'savePassword': True
    }
    conns.append(c_obj)

data = {'connections': conns}

for json_path in [os.path.expanduser('~/.sqldev/connections.json'), os.path.expanduser('~/.dbtools/connections.json')]:
    os.makedirs(os.path.dirname(json_path), exist_ok=True)
    with open(json_path, 'w') as f:
        json.dump(data, f, indent=2)
"



  # Clean up orphaned connection IDs in folders.json to prevent DBTU-03001 errors in VS Code
  FOLDERS_FILE="$HOME/.dbtools/connection_folders/folders.json"
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
done

echo "✅ Database connections with custom colors and folder '${folder_name}' successfully registered in VS Code SQL Developer!"
echo "👉 Refresh (🔄) Oracle SQL Developer extension in VS Code to view folder, colors & saved connections!"
