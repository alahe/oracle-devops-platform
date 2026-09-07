#!/usr/bin/env bash
# ============================================================================
# APEX Developer Account Creator for PROXY_WORKSPACE
# Creates a developer account inside PROXY_WORKSPACE for local PC user.
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ "$SCRIPT_DIR" == *"/internal" ]] || [[ "$SCRIPT_DIR" == *"/snapshots" ]] || [[ "$SCRIPT_DIR" == *"/certs" ]] || [[ "$SCRIPT_DIR" == *"/publisher" ]] || [[ "$SCRIPT_DIR" == *"/patches" ]]; then
  WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
else
  WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
fi

# Load environment variables
if [ -f "$WORKSPACE_DIR/.env" ]; then
  set -a
  source "$WORKSPACE_DIR/.env"
  set +a
elif [ -f "$WORKSPACE_DIR/config/repository.env" ]; then
  set -a
  source "$WORKSPACE_DIR/config/repository.env"
  set +a
fi

if [ -f "$WORKSPACE_DIR/scripts/internal/common.sh" ]; then
  source "$WORKSPACE_DIR/scripts/internal/common.sh"
fi

if [ -f "$WORKSPACE_DIR/scripts/internal/load-profile.sh" ]; then
  source "$WORKSPACE_DIR/scripts/internal/load-profile.sh"
  load_db_profile >/dev/null 2>&1 || true
fi

FORCE_MODE=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    -l=*|--lang=*|-language=*|--language=*)
      export CLI_LANG="${1#*=}"
      if declare -f resolve_cli_lang >/dev/null 2>&1; then
        export ACTIVE_CLI_LANG="$(resolve_cli_lang)"
      fi
      shift
      ;;
    -l|--lang|-language|--language)
      export CLI_LANG="$2"
      if declare -f resolve_cli_lang >/dev/null 2>&1; then
        export ACTIVE_CLI_LANG="$(resolve_cli_lang)"
      fi
      shift 2
      ;;
    -y|--force|--yes|-y*|--y*|-Y|--YES)
      FORCE_MODE=true
      shift
      ;;
    *)
      shift
      ;;
  esac
done

if [ "${PROFILE_APEX_ENABLED:-true}" = "false" ]; then
  msg_print "DEV_CREATOR_APEX_DISABLED" "${PROFILE_NAME:-publisher-only}"
  exit 0
fi

# Database connection parameters
DB_HOST="${APEX_DB_HOST:-${PROFILE_DB_HOST:-localhost}}"
DB_PORT="${APEX_DB_PORT:-${PROFILE_DB_PORT:-1532}}"
DB_SERVICE="${APEX_DB_SERVICE:-${PROFILE_DEFAULT_SERVICE:-FREEPDB1}}"
PRIMARY_CONTAINER=$(get_active_db_instances 2>/dev/null | head -n 1 | cut -d'|' -f1)
PRIMARY_CONTAINER="${PRIMARY_CONTAINER:-db-dev-full}"
PRIMARY_UPPER=$(echo "$PRIMARY_CONTAINER" | tr '-' '_' | tr '[:lower:]' '[:upper:]')

SYS_PASSWORD="${APEX_DB_SYS_PASSWORD:-}"
if [ -z "$SYS_PASSWORD" ]; then
  SYS_PASSWORD=$("$SCRIPT_DIR/get-password.sh" "DB_${PRIMARY_UPPER}_SYS" </dev/null 2>/dev/null | grep "Password:" | sed $'s/\x1b\\[[0-9;]*m//g' | cut -d':' -f2 | tr -d ' \r\t ')
  [ -z "$SYS_PASSWORD" ] && SYS_PASSWORD=$(podman exec "$PRIMARY_CONTAINER" cat /run/secrets/apex_db_sys_password 2>/dev/null | tr -d '\r\n' || true)
elif podman container exists db-dev-full 2>/dev/null; then
  SYS_PASSWORD=$("$SCRIPT_DIR/get-password.sh" DB_DB_DEV_FULL_SYS </dev/null 2>/dev/null | grep "Password:" | sed $'s/\x1b\\[[0-9;]*m//g' | cut -d':' -f2 | tr -d ' \r\t ')
  [ -z "$SYS_PASSWORD" ] && SYS_PASSWORD=$(podman exec db-dev-full cat /run/secrets/apex_db_sys_password 2>/dev/null | tr -d '\r\n' || true)
elif podman container exists db-apex-proxy 2>/dev/null; then
  SYS_PASSWORD=$("$SCRIPT_DIR/get-password.sh" DB_APEX_PROXY_SYS </dev/null 2>/dev/null | grep "Password:" | sed $'s/\x1b\\[[0-9;]*m//g' | cut -d':' -f2 | tr -d ' \r\t ')
  [ -z "$SYS_PASSWORD" ] && SYS_PASSWORD=$(podman exec db-apex-proxy cat /run/secrets/apex_db_sys_password 2>/dev/null | tr -d '\r\n' || true)
fi
if [ -z "$SYS_PASSWORD" ]; then
  if [ -f "/run/secrets/apex_db_sys_password" ]; then
    SYS_PASSWORD=$(cat "/run/secrets/apex_db_sys_password")
  elif podman container exists "$PRIMARY_CONTAINER" 2>/dev/null && [ "$(podman inspect --format='{{.State.Status}}' "$PRIMARY_CONTAINER" 2>/dev/null)" = "running" ]; then
    SYS_PASSWORD=$(podman exec "$PRIMARY_CONTAINER" cat "/run/secrets/apex_db_sys_password" 2>/dev/null || podman exec "$PRIMARY_CONTAINER" cat "/run/secrets/oracle_pwd" 2>/dev/null || echo "")
  fi
fi

# Detect current PC username and convert to uppercase (APEX standard)
DEFAULT_DEV_USER=$(echo "${DEVELOPER_USER:-$USER}" | tr '[:lower:]' '[:upper:]')
if [ -z "$DEFAULT_DEV_USER" ]; then
  DEFAULT_DEV_USER="DEV_USER"
fi

echo "=================================================================="
msg_print "DEV_CREATOR_TITLE"
echo "=================================================================="
if [ "$FORCE_MODE" = "true" ] || [ ! -t 0 ]; then
  DEV_USER="$DEFAULT_DEV_USER"
  msg_print "DEV_CREATOR_AUTO_USER" "$DEV_USER"
else
  read -p "$(msg_str "DEV_CREATOR_PROMPT_USER" "$DEFAULT_DEV_USER")" DEV_USER
  DEV_USER=${DEV_USER:-$DEFAULT_DEV_USER}
fi

# Strip spaces
DEV_USER=$(echo "$DEV_USER" | tr -d ' ')


# Generate random strong password automatically
RAND_PART=$(LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 12 2>/dev/null || openssl rand -hex 6)
DEV_PWD="Dev_${RAND_PART}_2026!"

# Configure log directory and filename
LOG_DIR="$WORKSPACE_DIR/install_logs"
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$LOG_DIR/db_developer_init_${TIMESTAMP}.log"

echo "------------------------------------------------------------------"
msg_print "DEV_CREATOR_CREATING" "$DEV_USER" "PROXY_WORKSPACE"
msg_print "DEV_CREATOR_LOG_FILE" "$LOG_FILE"

# Resolve SQLcl binary location (prioritizing VS Code extension binary)
SQLCL_BIN=""
VSCODE_SQLCL=$(find "$HOME/.vscode/extensions" -name "sql" -path "*/oracle.sql-developer-*/dbtools/sqlcl/bin/sql" 2>/dev/null | head -n 1)
if [ -n "$VSCODE_SQLCL" ]; then
  SQLCL_BIN="$VSCODE_SQLCL"
elif command -v sql &> /dev/null; then
  SQLCL_BIN="sql"
fi

run_sqlcl() {
  local target="$1"
  shift

  # Tier 1: In-container SQLcl (preferred for local containers)
  if [ -n "$target" ] && podman container exists "$target" 2>/dev/null && [ "$(podman inspect --format='{{.State.Status}}' "$target" 2>/dev/null)" = "running" ]; then
    local in_c_sql=$(podman exec "$target" bash -c 'ls -d /opt/oracle/product/*/dbhomeFree/sqlcl/bin/sql 2>/dev/null | head -n 1' 2>/dev/null || echo "")
    if [ -n "$in_c_sql" ]; then
      podman exec -i "$target" "$in_c_sql" "$@"
      return $?
    fi
  fi

  # Tier 2: Host SQLcl wrapper with SEPS Wallet
  if [ -x "$WORKSPACE_DIR/scripts/sqlcl.sh" ]; then
    "$WORKSPACE_DIR/scripts/sqlcl.sh" "$@"
    return $?
  fi

  # Tier 3: Local binary
  local LOCAL_BIN=""
  if [ -n "$SQLCL_BIN" ]; then
    LOCAL_BIN="$SQLCL_BIN"
  elif command -v sql &> /dev/null; then
    LOCAL_BIN="sql"
  fi

  if [ -n "$LOCAL_BIN" ]; then
    "$LOCAL_BIN" "$@"
    return $?
  fi

  # Tier 4: Ephemeral container
  local RUN_IMAGE="${SQLCL_CONTAINER_IMAGE:-container-registry.oracle.com/database/sqlcl:latest}"
  if [ -d "$WORKSPACE_DIR/config/tns_admin" ]; then
    podman run --rm -i -v "$WORKSPACE_DIR/config/tns_admin:/config/tns_admin:ro" -e TNS_ADMIN=/config/tns_admin --network=host "$RUN_IMAGE" "$@"
    return $?
  fi

  return 1
}

PRIMARY_CONTAINER=$(get_active_db_instances 2>/dev/null | head -n 1 | cut -d'|' -f1)
PRIMARY_CONTAINER="${PRIMARY_CONTAINER:-db-dev-full}"
PRIMARY_UPPER=$(echo "$PRIMARY_CONTAINER" | tr '-' '_' | tr '[:lower:]' '[:upper:]')

# Execute PL/SQL user provisioning block, redirecting output to log file
set +e
if podman container exists "$PRIMARY_CONTAINER" 2>/dev/null && [ "$(podman inspect --format='{{.State.Status}}' "$PRIMARY_CONTAINER" 2>/dev/null)" = "running" ]; then
  run_sqlcl "$PRIMARY_CONTAINER" -s / as sysdba <<EOF > "$LOG_FILE" 2>&1
ALTER SESSION SET CONTAINER = ${DB_SERVICE};
SET SERVEROUTPUT ON SIZE UNLIMITED;
WHENEVER SQLERROR CONTINUE;
-- 1. Create/update database user and grant DB_DEVELOPER_ROLE
DECLARE
  v_user_exists NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_user_exists FROM dba_users WHERE username = '${DEV_USER}';
  IF v_user_exists = 0 THEN
    EXECUTE IMMEDIATE 'CREATE USER ${DEV_USER} IDENTIFIED BY "${DEV_PWD}"';
    DBMS_OUTPUT.PUT_LINE('✅ DB kasutaja ${DEV_USER} loodud.');
  ELSE
    EXECUTE IMMEDIATE 'ALTER USER ${DEV_USER} IDENTIFIED BY "${DEV_PWD}"';
    DBMS_OUTPUT.PUT_LINE('✅ DB kasutaja ${DEV_USER} parool uuendatud.');
  END IF;
  EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO ${DEV_USER}';
  EXECUTE IMMEDIATE 'GRANT DB_DEVELOPER_ROLE TO ${DEV_USER}';
  EXECUTE IMMEDIATE 'ALTER USER ${DEV_USER} DEFAULT TABLESPACE USERS TEMPORARY TABLESPACE TEMP QUOTA UNLIMITED ON USERS';
  DBMS_OUTPUT.PUT_LINE('[OK] Role DB_DEVELOPER_ROLE granted to ${DEV_USER}.');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('[ERROR] Failed to create DB user: ' || SQLERRM);
END;
/

-- 2. Create/update APEX developer account
DECLARE
  v_workspace_id NUMBER;
  v_target_ws VARCHAR2(100) := '${PROFILE_APEX_WORKSPACE:-PROXY_WORKSPACE}';
BEGIN
  v_workspace_id := APEX_UTIL.find_security_group_id(v_target_ws);
  IF v_workspace_id IS NULL OR v_workspace_id = 0 THEN
    BEGIN
      SELECT workspace_id INTO v_workspace_id FROM apex_workspaces WHERE ROWNUM = 1;
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
  END IF;
  IF v_workspace_id IS NULL OR v_workspace_id = 0 THEN
    DBMS_OUTPUT.PUT_LINE('[ERROR] Workspace ' || v_target_ws || ' not found. Is APEX installed?');
  ELSE
    APEX_UTIL.set_security_group_id(v_workspace_id);
    
    -- Remove user if already exists (to prevent uniqueness errors)
    BEGIN
      APEX_UTIL.remove_user(p_user_name => '${DEV_USER}');
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
    
    -- Create new developer account
    APEX_UTIL.create_user(
        p_user_name                    => '${DEV_USER}',
        p_email_address                => '${DEV_USER}@company.local',
        p_web_password                 => '${DEV_PWD}',
        p_developer_privs              => 'CREATE:DATA_LOADER:EDIT:HELP:MONITOR:VARIABLE',
        p_change_password_on_first_use => 'N'
    );
    BEGIN
      DECLARE
        v_apex_schema VARCHAR2(128);
      BEGIN
        SELECT username INTO v_apex_schema FROM all_users WHERE username LIKE 'APEX_%' AND username NOT IN ('APEX_PUBLIC_USER','APEX_LISTENER','APEX_REST_PUBLIC_USER','APEX_PUBLIC_ROUTER','APEX_PROXY_SCHEMA') AND ROWNUM = 1;
        EXECUTE IMMEDIATE 'UPDATE ' || v_apex_schema || '.wwv_flow_fnd_user SET account_expiry = NULL, account_locked = ''N'', change_password_on_first_use = ''N'' WHERE user_name = :1' USING '${DEV_USER}';
      EXCEPTION WHEN OTHERS THEN NULL;
      END;
    END;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('[OK] Developer account created successfully in APEX workspace.');
  END IF;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('[ERROR] Failed to create APEX user: ' || SQLERRM);
END;
/
EXIT;
EOF
  STATUS=$?
else
  run_sqlcl "" -s "/@DB_${PRIMARY_UPPER}_SYS" as sysdba <<EOF > "$LOG_FILE" 2>&1
ALTER SESSION SET CONTAINER = ${DB_SERVICE};
SET SERVEROUTPUT ON SIZE UNLIMITED;
WHENEVER SQLERROR CONTINUE;
-- 1. Create/update database user and grant DB_DEVELOPER_ROLE
DECLARE
  v_user_exists NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_user_exists FROM dba_users WHERE username = '${DEV_USER}';
  IF v_user_exists = 0 THEN
    EXECUTE IMMEDIATE 'CREATE USER ${DEV_USER} IDENTIFIED BY "${DEV_PWD}"';
    DBMS_OUTPUT.PUT_LINE('[OK] DB user ${DEV_USER} created.');
  ELSE
    EXECUTE IMMEDIATE 'ALTER USER ${DEV_USER} IDENTIFIED BY "${DEV_PWD}"';
    DBMS_OUTPUT.PUT_LINE('[OK] DB user ${DEV_USER} password updated.');
  END IF;
  EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO ${DEV_USER}';
  EXECUTE IMMEDIATE 'GRANT DB_DEVELOPER_ROLE TO ${DEV_USER}';
  EXECUTE IMMEDIATE 'ALTER USER ${DEV_USER} DEFAULT TABLESPACE USERS TEMPORARY TABLESPACE TEMP QUOTA UNLIMITED ON USERS';
  DBMS_OUTPUT.PUT_LINE('[OK] Role DB_DEVELOPER_ROLE granted to user ${DEV_USER}.');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('[ERROR] Error creating DB user: ' || SQLERRM);
END;
/

-- 2. Create/update APEX developer account
DECLARE
  v_workspace_id NUMBER;
  v_target_ws VARCHAR2(100) := '${PROFILE_APEX_WORKSPACE:-PROXY_WORKSPACE}';
BEGIN
  v_workspace_id := APEX_UTIL.find_security_group_id(v_target_ws);
  IF v_workspace_id IS NULL OR v_workspace_id = 0 THEN
    BEGIN
      SELECT workspace_id INTO v_workspace_id FROM apex_workspaces WHERE ROWNUM = 1;
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
  END IF;
  IF v_workspace_id IS NULL OR v_workspace_id = 0 THEN
    DBMS_OUTPUT.PUT_LINE('[ERROR] Workspace ' || v_target_ws || ' not found. Is APEX installed?');
  ELSE
    APEX_UTIL.set_security_group_id(v_workspace_id);
    
    -- Remove user if already exists (to prevent uniqueness errors)
    BEGIN
      APEX_UTIL.remove_user(p_user_name => '${DEV_USER}');
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
    
    -- Create new developer account
    APEX_UTIL.create_user(
        p_user_name                    => '${DEV_USER}',
        p_email_address                => '${DEV_USER}@company.local',
        p_web_password                 => '${DEV_PWD}',
        p_developer_privs              => 'CREATE:DATA_LOADER:EDIT:HELP:MONITOR:VARIABLE',
        p_change_password_on_first_use => 'N'
    );
    BEGIN
      DECLARE
        v_apex_schema VARCHAR2(128);
      BEGIN
        SELECT username INTO v_apex_schema FROM all_users WHERE username LIKE 'APEX_%' AND username NOT IN ('APEX_PUBLIC_USER','APEX_LISTENER','APEX_REST_PUBLIC_USER','APEX_PUBLIC_ROUTER','APEX_PROXY_SCHEMA') AND ROWNUM = 1;
        EXECUTE IMMEDIATE 'UPDATE ' || v_apex_schema || '.wwv_flow_fnd_user SET account_expiry = NULL, account_locked = ''N'', change_password_on_first_use = ''N'' WHERE user_name = :1' USING '${DEV_USER}';
      EXCEPTION WHEN OTHERS THEN NULL;
      END;
    END;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('[OK] Developer account created successfully in APEX workspace.');
  END IF;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('[ERROR] Error creating APEX user: ' || SQLERRM);
END;
/
EXIT;
EOF
  STATUS=$?
fi
set -e

if [ $STATUS -eq 0 ] && grep -E -q "Developer account created successfully|Arendaja kasutajakonto edukalt loodud" "$LOG_FILE"; then
  # 1. Register new developer password in Oracle Wallet (SEPS)
  WALLET_PWD=$(cat "$WORKSPACE_DIR/config/secrets/wallet_password.txt" 2>/dev/null || echo "CustomWalletPass123!")
  if podman container exists "$PRIMARY_CONTAINER" 2>/dev/null && [ "$(podman inspect --format='{{.State.Status}}' "$PRIMARY_CONTAINER" 2>/dev/null)" = "running" ]; then
    podman exec -i "$PRIMARY_CONTAINER" sh -c "
WALLET_PATH=\"/opt/oracle/admin/FREE/wallet\"
echo \"$WALLET_PWD\" | mkstore -wrl \$WALLET_PATH -deleteCredential \"${DEV_USER}\" >/dev/null 2>&1 || true
echo \"$WALLET_PWD\" | mkstore -wrl \$WALLET_PATH -createCredential \"${DEV_USER}\" \"${DEV_USER}\" \"${DEV_PWD}\" >/dev/null 2>&1 || true
" >/dev/null 2>&1 || true
  fi

  # 2. Delegate registration to register-connections.sh script
  export EXTRA_DEV_USER="${DEV_USER}"
  export EXTRA_DEV_PWD="${DEV_PWD}"
  export EXTRA_DEV_COLOR="${DEVELOPER_COLOR:-#F39C12}"


  msg_print "DEV_CREATOR_REG_VSCODE"
  "$SCRIPT_DIR/register-connections.sh" >/dev/null 2>&1 || true

  echo "=================================================================="
  msg_print "DEV_CREATOR_ACCOUNT_CREATED"
  msg_print "DEV_CREATOR_WS_LABEL" "PROXY_WORKSPACE"
  msg_print "DEV_CREATOR_USER_LABEL" "$DEV_USER"
  msg_print "DEV_CREATOR_PWD_STORED_LABEL"
  msg_print "DEV_CREATOR_GET_PWD_HINT" "$DEV_USER"
  msg_print "DEV_CREATOR_LOGIN_URL_LABEL" "https://localhost:8448/ords/apex"
  msg_print "DEV_CREATOR_LOG_LOCATION_LABEL" "$LOG_FILE"
  echo "   --------------------------------------------------------------"
  msg_print "DEV_CREATOR_REG_SUCCESS"
  msg_print "DEV_CREATOR_REG_HINT"
  echo "=================================================================="
else
  msg_print "DEV_CREATOR_FAILED"
  msg_print "DEV_CREATOR_SEE_LOG" "$LOG_FILE"
  if [ -f "$LOG_FILE" ]; then
    echo "------------------------------------------------------------------"
    grep -E "\[ERROR\]|Error:|ORA-" "$LOG_FILE" || head -n 10 "$LOG_FILE"
    echo "------------------------------------------------------------------"
  fi
fi

