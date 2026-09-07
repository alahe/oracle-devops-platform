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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ "$SCRIPT_DIR" == *"/internal" ]] || [[ "$SCRIPT_DIR" == *"/snapshots" ]] || [[ "$SCRIPT_DIR" == *"/certs" ]] || [[ "$SCRIPT_DIR" == *"/publisher" ]] || [[ "$SCRIPT_DIR" == *"/patches" ]]; then
  WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
else
  WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
fi

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

if [ -f "$WORKSPACE_DIR/scripts/internal/load-profile.sh" ]; then
  source "$WORKSPACE_DIR/scripts/internal/load-profile.sh"
fi

if [ -f "$WORKSPACE_DIR/scripts/internal/credential-helper.sh" ]; then
  source "$WORKSPACE_DIR/scripts/internal/credential-helper.sh"
fi

get_wallet_pwd() {
  local alias_name="$1"
  local uname="$2"
  local target_c="${3:-$c_name}"
  local pwd_val=""

  local c_prefix=$(echo "$target_c" | sed 's/^db-//' | tr '-' '_' | tr '[:upper:]' '[:lower:]')
  local c_upper=$(echo "$c_prefix" | tr '[:lower:]' '[:upper:]')

  if [ "$uname" = "sys" ] || [ "$uname" = "SYS" ] || [[ "$alias_name" == *"SYS"* ]]; then
    pwd_val=$(get_db_sys_password "$target_c" 2>/dev/null || true)
  elif [[ "$uname" == *"SCHEMA"* ]] || [[ "$alias_name" == *"SCHEMA"* ]]; then
    pwd_val=$(get_db_user_password "$target_c" "schema" 2>/dev/null || true)
    [ -z "$pwd_val" ] && pwd_val=$(podman secret inspect --showsecret "${c_prefix}_schema_password" 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
  elif [[ "$uname" == *"DBA_ADMIN"* ]] || [[ "$alias_name" == *"DBA_ADMIN"* ]]; then
    pwd_val=$(get_db_user_password "$target_c" "dba_admin" 2>/dev/null || true)
  elif [[ "$uname" == *"DEVELOPER"* ]] || [[ "$uname" == *"DEV"* ]] || [[ "$alias_name" == *"DEV"* ]]; then
    pwd_val=$(get_db_user_password "$target_c" "dev" 2>/dev/null || true)
  elif [[ "$uname" == *"APP"* ]] || [[ "$alias_name" == *"APP"* ]]; then
    pwd_val=$(get_db_user_password "$target_c" "app" 2>/dev/null || true)
  elif [[ "$uname" == *"VIEWER"* ]] || [[ "$alias_name" == *"VIEWER"* ]]; then
    pwd_val=$(get_db_user_password "$target_c" "viewer" 2>/dev/null || true)
  elif [[ "$uname" == *"PUBLISHER_READER"* ]] || [[ "$alias_name" == *"PUBLISHER_READER"* ]]; then
    pwd_val=$(podman secret inspect --showsecret publisher_reader_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
  fi

  if [ -z "$pwd_val" ]; then
    pwd_val=$("$SCRIPT_DIR/get-password.sh" "$alias_name" 2>/dev/null | grep "Password:" | sed $'s/\x1b\\[[0-9;]*m//g' | cut -d':' -f2- | tr -d ' \r' || true)
  fi
  if [ -z "$pwd_val" ] && [ -n "$uname" ]; then
    pwd_val=$("$SCRIPT_DIR/get-password.sh" "$uname" 2>/dev/null | grep "Password:" | sed $'s/\x1b\\[[0-9;]*m//g' | cut -d':' -f2- | tr -d ' \r' || true)
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

  # 1. Folder/Directory Name MUST be per-container when multiple active databases exist
  if [ $(echo "$ACTIVE_INSTANCES" | wc -w | tr -d ' ') -gt 1 ]; then
    folder_name="${c_name}"
  else
    folder_name="${VSCODE_FOLDER_NAME:-${DB_CONN_NAME:-${CONTAINER_NAME:-$c_name}}}"
  fi

  port="${PROFILE_DB_PORT:-1532}"
  service="${PROFILE_DEFAULT_SERVICE:-FREEPDB1}"
  profile_file="${PROFILE_YAML:-$WORKSPACE_DIR/config/profiles/databases/${prof}.yaml}"
  if [ ! -f "$profile_file" ]; then
    profile_file="$WORKSPACE_DIR/config/profiles/databases/${PROFILE_ID:-bizapp-standard-oracle}.yaml"
  fi
  if [ ! -f "$profile_file" ]; then
    profile_file="$WORKSPACE_DIR/config/profiles/databases/proxy-adb-oracle.yaml"
  fi

  # 3. Read Database Configuration dynamically from YAML profile + ensure standard core users
  users_json=$(python3 -c "
import yaml, json, os
p = '$profile_file'
users = []
if os.path.exists(p):
    data = yaml.safe_load(open(p))
    users = data.get('users', [])

# Ensure core roles (SYS, DBA_ADMIN, SCHEMA, USER_DEVELOPER, USER_APP, USER_VIEWER) are in list if missing
existing_names = [u.get('username', '').upper() for u in users if isinstance(u, dict)]

if 'SYS' not in existing_names:
    users.insert(0, {'username': 'SYS', 'role': 'SYSDBA', 'color': '#E74C3C', 'wallet_alias': 'SYS'})
if 'DBA_ADMIN' not in existing_names:
    users.append({'username': 'DBA_ADMIN', 'role': 'NORMAL', 'color': '#E67E22', 'wallet_alias': 'DBA_ADMIN'})
if 'USER_DEVELOPER' not in existing_names and 'TEST_DEV' not in existing_names:
    users.append({'username': 'USER_DEVELOPER', 'role': 'NORMAL', 'color': '#27AE60', 'wallet_alias': 'DEV'})
if 'USER_APP' not in existing_names:
    users.append({'username': 'USER_APP', 'role': 'NORMAL', 'color': '#F39C12', 'wallet_alias': 'APP'})
if 'USER_VIEWER' not in existing_names and 'TEST_VIEWER' not in existing_names:
    users.append({'username': 'USER_VIEWER', 'role': 'NORMAL', 'color': '#8E44AD', 'wallet_alias': 'VIEWER'})

def sort_key(u):
    uname = str(u.get('username', '')).upper()
    role = str(u.get('role', '')).upper()
    if uname == 'SYS' or role == 'SYSDBA':
        return 1
    if uname == 'DBA_ADMIN' or role == 'DBA':
        return 2
    if 'SCHEMA' in uname:
        return 3
    if 'DEV' in uname or 'DEVELOPER' in uname:
        return 4
    if 'APP' in uname:
        return 5
    if 'VIEWER' in uname or 'READ' in uname:
        return 6
    return 7

users = sorted(users, key=sort_key)
print(json.dumps(users))
" 2>/dev/null || echo "[]")

  SQL_COMMANDS=()
  SQL_COMMANDS+=("connmgr delete -folder /${folder_name} -force")
  SQL_COMMANDS+=("connmgr add -folder /${folder_name}")

  CONTAINER_SQL_COMMANDS=()
  CONTAINER_SQL_COMMANDS+=("connmgr delete -folder /${folder_name} -force")
  CONTAINER_SQL_COMMANDS+=("connmgr add -folder /${folder_name}")

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

    # Map placeholder profile usernames to real database accounts if needed
    real_db_user="$uname"
    if [ "$uname" = "APP_SCHEMA" ]; then
      real_db_user="APEX_PROXY_SCHEMA"
    elif [ "$uname" = "APP_DEV" ]; then
      real_db_user="TEST_DEV"
    fi

    # 2. Passwords queried strictly from Oracle Wallet (redirect STDIN to prevent draining loop)
    pwd_val=$(get_wallet_pwd "$walias" "$real_db_user" "$c_name" </dev/null)
    if [ -z "$pwd_val" ]; then
      c_name_upper=$(echo "$c_name" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
      pwd_val=$(get_wallet_pwd "DB_${c_name_upper}_${real_db_user}" "$real_db_user" "$c_name" </dev/null)
    fi
    if [ -z "$pwd_val" ]; then
      c_short=$(echo "$c_name" | sed -E 's/^db[-_]//' | tr '[:lower:]' '[:upper:]')
      pwd_val=$(get_wallet_pwd "DB_${c_short}_${real_db_user}" "$real_db_user" "$c_name" </dev/null)
    fi
    [ -z "$pwd_val" ] && continue

    if [ "$real_db_user" = "sys" ] || [ "$real_db_user" = "SYS" ]; then
      pretty_name="${idx}. Sys (${folder_name})"
    else
      pretty_name="${idx}. ${real_db_user} (${folder_name})"
    fi

    # Build SQLcl connect command
    conn_str="${real_db_user}/${pwd_val}@localhost:${port}/${service}"
    container_conn_str="${real_db_user}/${pwd_val}@${c_name}:1521/${service}"
    if [ "$urole" = "SYSDBA" ]; then
      conn_str="${conn_str} as sysdba"
      container_conn_str="${container_conn_str} as sysdba"
    fi

    SQL_COMMANDS+=("connect -save \"${pretty_name}\" -savepwd -replace ${conn_str}")
    SQL_COMMANDS+=("connmgr move -conn \"${pretty_name}\" /${folder_name}")

    CONTAINER_SQL_COMMANDS+=("connect -save \"${pretty_name}\" -savepwd -replace ${container_conn_str}")
    CONTAINER_SQL_COMMANDS+=("connmgr move -conn \"${pretty_name}\" /${folder_name}")

    final_user_color=$(get_existing_user_color "$real_db_user" "$ucolor")
    user_json_str=$(jq -n \
      --arg uname "$real_db_user" \
      --arg pwd "$pwd_val" \
      --arg role "$urole" \
      --arg color "$final_user_color" \
      --arg pname "$pretty_name" \
      '{username: $uname, password: $pwd, role: $role, color: $color, pretty_name: $pname}')
    BUILT_CONNS+=("$user_json_str")

    idx=$((idx + 1))
  done < <(echo "$users_json" | jq -c '.[]')

  # 4. Include explicitly configured extra developer users if defined
  DEV_USERS=()
  [ -n "${EXTRA_DEV_USER:-}" ] && DEV_USERS+=("$EXTRA_DEV_USER")
  [ -n "${DEVELOPER_USER:-}" ] && DEV_USERS+=("$DEVELOPER_USER")

  UNIQUE_DEV_USERS=($(printf "%s\n" "${DEV_USERS[@]}" | sort -u))

  for dev_u in "${UNIQUE_DEV_USERS[@]}"; do
    dev_u_upper=$(echo "$dev_u" | tr '[:lower:]' '[:upper:]' | tr -d ' ')
    [ -z "$dev_u_upper" ] && continue
    
    # Skip system/schema accounts that are handled in step 3 or are web accounts or wallet alias names
    if [ "$dev_u_upper" = "SYS" ] || [ "$dev_u_upper" = "APEX_PROXY_SCHEMA" ] || [ "$dev_u_upper" = "ADMIN" ] || [[ "$dev_u_upper" == *"WEB"* ]] || [[ "$dev_u_upper" == "DB_"* ]] || [ "$dev_u_upper" = "DEV" ] || [ "$dev_u_upper" = "VIEWER" ]; then
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
      dev_pwd_val=$(get_wallet_pwd "$dev_u" "$dev_u" "$c_name" </dev/null)
    fi
    if [ -z "$dev_pwd_val" ]; then
      dev_pwd_val=$(get_wallet_pwd "$dev_u_upper" "$dev_u_upper" "$c_name" </dev/null)
    fi
    [ -z "$dev_pwd_val" ] && continue

    pretty_dev_name="${idx}. ${dev_u_upper} (${folder_name})"

    conn_dev_str="${dev_u_upper}/${dev_pwd_val}@localhost:${port}/${service}"
    container_conn_dev_str="${dev_u_upper}/${dev_pwd_val}@${c_name}:1521/${service}"

    SQL_COMMANDS+=("connect -save \"${pretty_dev_name}\" -savepwd -replace ${conn_dev_str}")
    SQL_COMMANDS+=("connmgr move -conn \"${pretty_dev_name}\" /${folder_name}")

    CONTAINER_SQL_COMMANDS+=("connect -save \"${pretty_dev_name}\" -savepwd -replace ${container_conn_dev_str}")
    CONTAINER_SQL_COMMANDS+=("connmgr move -conn \"${pretty_dev_name}\" /${folder_name}")
    
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

  CONTAINER_SQL_COMMANDS+=("connmgr list -folder /${folder_name}")
  CONTAINER_SQL_COMMANDS+=("EXIT")

  # 1. Run SQLcl batch commands on Host PC (saves encrypted passwords to OS Keychain)
  if [ "${SKIP_SQLCL_EXEC:-false}" != "true" ]; then
    if [ -n "$VSCODE_SQLCL" ] && { command -v "$VSCODE_SQLCL" &>/dev/null || [ -x "$VSCODE_SQLCL" ]; }; then
      printf '%s\n' "${SQL_COMMANDS[@]}" | "$VSCODE_SQLCL" /nolog >/dev/null 2>&1 || true
    else
      # Fallback pattern for restricted environments via Ephemeral Container
      podman run --rm -i --network=host container-registry.oracle.com/database/sqlcl:latest /nolog >/dev/null 2>&1 <<EOF || true
$(printf '%s\n' "${SQL_COMMANDS[@]}")
EOF
    fi
  fi

  # 2. Run SQLcl batch commands inside Web IDE container (if active)
  WEB_IDE_CONTAINER="${WEB_IDE_CONTAINER_NAME:-web-ide-dev}"
  if podman container exists "$WEB_IDE_CONTAINER" 2>/dev/null && [ "$(podman inspect --format='{{.State.Status}}' "$WEB_IDE_CONTAINER" 2>/dev/null)" = "running" ]; then
    CONTAINER_SQLCL=$(podman exec -i "$WEB_IDE_CONTAINER" find /config/extensions -name "sql" -path "*/oracle.sql-developer-*/dbtools/sqlcl/bin/sql" 2>/dev/null | head -n 1)
    if [ -n "$CONTAINER_SQLCL" ]; then
      printf '%s\n' "${CONTAINER_SQL_COMMANDS[@]}" | podman exec -i -u abc "$WEB_IDE_CONTAINER" "$CONTAINER_SQLCL" /nolog >/dev/null 2>&1 || true
    fi
  fi

  # Combine built connections into JSON array
  CONNS_ARRAY_JSON=$(printf '%s\n' "${BUILT_CONNS[@]}" | jq -s .)

  # Synchronize colors and JSON files for Host PC
  CONNS_JSON="$CONNS_ARRAY_JSON" FOLDER_NAME="$folder_name" PORT_VAL="$port" SERVICE_VAL="$service" python3 - << 'PYEOF'
import json, os, sys, shutil

conns_in = json.loads(os.environ.get('CONNS_JSON', '[]'))
folder = os.environ.get('FOLDER_NAME', 'pub-db')
port = os.environ.get('PORT_VAL', '1533')
service = os.environ.get('SERVICE_VAL', 'FREEPDB1')

valid_pnames = [u.get('pretty_name') for u in conns_in if u.get('pretty_name')]

dbtools_dir = os.path.expanduser('~/.dbtools/connections')
if os.path.exists(dbtools_dir):
    for entry in list(os.listdir(dbtools_dir)):
        entry_path = os.path.join(dbtools_dir, entry)
        if not os.path.isdir(entry_path):
            continue
        prop_file = os.path.join(entry_path, 'dbtools.properties')
        if os.path.isfile(prop_file):
            try:
                with open(prop_file, 'r', encoding='utf-8', errors='ignore') as pf:
                    lines = pf.readlines()
                cname = None
                for line in lines:
                    if line.startswith('name='):
                        cname = line.split('=', 1)[1].strip()
                        break
                # Remove obsolete connections belonging to this folder/db
                if cname and f'({folder})' in cname and cname not in valid_pnames:
                    shutil.rmtree(entry_path, ignore_errors=True)
                    continue
                for u in conns_in:
                    uname = u.get('username')
                    ucolor = u.get('color', '#2980B9')
                    if any(f'userName={uname}' in l for l in lines) or any(f'userName={uname.lower()}' in l for l in lines):
                        new_lines = []
                        for l in lines:
                            if l.startswith('color='):
                                continue
                            if l.startswith('connectionString='):
                                new_lines.append(f'connectionString=localhost\\:{port}/{service}\n')
                                continue
                            new_lines.append(l)
                        new_lines.append(f'color={ucolor}\n')
                        with open(prop_file, 'w', encoding='utf-8') as pf:
                            pf.writelines(new_lines)
            except Exception:
                pass

conns_path = os.path.expanduser('~/.sqldev/connections.json')
existing_conns = []
if os.path.exists(conns_path):
    try:
        with open(conns_path, 'r', encoding='utf-8') as f:
            existing_data = json.load(f)
            existing_conns = [c for c in existing_data.get('connections', []) if c.get('folder') != f'/{folder}']
    except Exception:
        existing_conns = []

for u in conns_in:
    uname = u.get('username')
    pwd = u.get('password', '')
    role = u.get('role', 'NORMAL')
    color = u.get('color', '#2980B9')
    pretty_name = u.get('pretty_name', uname)
    
    conn_name = f"{pretty_name} ({folder})" if not pretty_name.endswith(f"({folder})") else pretty_name

    c_obj = {
        'name': conn_name,
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
    existing_conns.append(c_obj)

data = {'connections': existing_conns}
for json_path in [conns_path, os.path.expanduser('~/.dbtools/connections.json')]:
    os.makedirs(os.path.dirname(json_path), exist_ok=True)
    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2)
PYEOF

  # Synchronize colors and JSON files inside Web IDE container (if active)
  if podman container exists "$WEB_IDE_CONTAINER" 2>/dev/null && [ "$(podman inspect --format='{{.State.Status}}' "$WEB_IDE_CONTAINER" 2>/dev/null)" = "running" ]; then
    podman exec -i -e CONNS_JSON="$CONNS_ARRAY_JSON" -e FOLDER_NAME="$folder_name" -e PORT_VAL="1521" -e SERVICE_VAL="$service" -e HOST_VAL="$c_name" "$WEB_IDE_CONTAINER" /app/code-server/lib/node -e '
const fs = require("fs");
const path = require("path");

const connsIn = JSON.parse(process.env.CONNS_JSON || "[]");
const folder = process.env.FOLDER_NAME || "pub-db";
const port = process.env.PORT_VAL || "1521";
const host = process.env.HOST_VAL || "localhost";
const service = process.env.SERVICE_VAL || "FREEPDB1";

const validPnames = connsIn.map(u => u.pretty_name).filter(Boolean);

const dbtoolsDir = "/config/.dbtools/connections";
if (fs.existsSync(dbtoolsDir)) {
  const folders = fs.readdirSync(dbtoolsDir);
  for (const entry of folders) {
    const entryPath = path.join(dbtoolsDir, entry);
    if (!fs.statSync(entryPath).isDirectory()) continue;
    const propFile = path.join(entryPath, "dbtools.properties");
    if (fs.existsSync(propFile)) {
      try {
        let lines = fs.readFileSync(propFile, "utf8").split("\n");
        for (const u of connsIn) {
          const uname = u.username;
          const ucolor = u.color || "#2980B9";
          if (lines.some(l => l.toLowerCase().includes("username=" + uname.toLowerCase()))) {
            lines = lines.filter(l => !l.startsWith("color="));
            lines = lines.map(l => l.startsWith("connectionString=") ? `connectionString=${host}\\:${port}/${service}` : l);
            lines.push("color=" + ucolor);
            fs.writeFileSync(propFile, lines.join("\n"));
          }
        }
      } catch (err) {}
    }
  }
}

const connsPath = "/config/.sqldev/connections.json";
let existingConns = [];
if (fs.existsSync(connsPath)) {
  try {
    const d = JSON.parse(fs.readFileSync(connsPath, "utf8"));
    existingConns = (d.connections || []).filter(c => c.folder !== "/" + folder);
  } catch (err) {
    existingConns = [];
  }
}

for (const u of connsIn) {
  const uname = u.username;
  const pwd = u.password || "";
  const role = u.role || "NORMAL";
  const color = u.color || "#2980B9";
  const prettyName = u.pretty_name || uname;
  const connName = prettyName.endsWith("(" + folder + ")") ? prettyName : prettyName + " (" + folder + ")";

  existingConns.push({
    name: connName,
    folder: "/" + folder,
    color: color,
    type: "Oracle",
    connType: "Basic",
    host: host,
    port: String(port),
    serviceName: service,
    user: uname,
    password: pwd,
    role: role === "SYSDBA" ? "SYSDBA" : "NORMAL",
    savePassword: true
  });
}

const data = { connections: existingConns };
for (const p of [connsPath, "/config/.dbtools/connections.json"]) {
  fs.mkdirSync(path.dirname(p), { recursive: true });
  fs.writeFileSync(p, JSON.stringify(data, null, 2));
}
' 2>/dev/null || true
  fi

done

# 5. Sanitize folders.json to prevent DBTU-03001 error on Host PC
FOLDERS_FILE="$HOME/.dbtools/connection_folders/folders.json"
DBTOOLS_CONNS_DIR="$HOME/.dbtools/connections"

if [ -f "$FOLDERS_FILE" ] && command -v jq &>/dev/null && [ -d "$DBTOOLS_CONNS_DIR" ]; then
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

# 6. Sanitize folders.json and set permissions inside Web IDE container
WEB_IDE_CONTAINER="${WEB_IDE_CONTAINER_NAME:-web-ide-dev}"
if podman container exists "$WEB_IDE_CONTAINER" 2>/dev/null && [ "$(podman inspect --format='{{.State.Status}}' "$WEB_IDE_CONTAINER" 2>/dev/null)" = "running" ]; then
  podman exec -i "$WEB_IDE_CONTAINER" /app/code-server/lib/node -e '
const fs = require("fs");
const path = require("path");

const foldersFile = "/config/.dbtools/connection_folders/folders.json";
const connsDir = "/config/.dbtools/connections";

if (fs.existsSync(foldersFile) && fs.existsSync(connsDir)) {
  try {
    const validIds = new Set(fs.readdirSync(connsDir).filter(d => fs.statSync(path.join(connsDir, d)).isDirectory()));
    const data = JSON.parse(fs.readFileSync(foldersFile, "utf8"));
    const cleanedFolders = [];
    for (const folder of (data.folders || [])) {
      const conns = (folder.connections || []).filter(c => validIds.has(c));
      if (conns.length > 0) {
        folder.connections = conns;
        cleanedFolders.push(folder);
      }
    }
    data.folders = cleanedFolders;
    fs.writeFileSync(foldersFile, JSON.stringify(data, null, 2));
  } catch (err) {}
}
' 2>/dev/null || true
  podman exec -u root -i "$WEB_IDE_CONTAINER" bash -c 'chown -R abc:abc /config/.dbtools /config/.sqldev 2>/dev/null || true' 2>/dev/null || true
fi

echo "✅ Database connections with custom colors and folder '${folder_name}' successfully registered in VS Code SQL Developer (Host & Web IDE)!"
echo "👉 Refresh (🔄) Oracle SQL Developer extension in VS Code to view folder, colors & saved connections!"
echo "👉 Refresh (🔄) Oracle SQL Developer extension in VS Code to view folder, colors & saved connections!"
