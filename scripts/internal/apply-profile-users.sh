#!/usr/bin/env bash
# ============================================================================
# Dynamic Profile Users & Roles Applicator
# Reads users configuration from active YAML profile and applies DB schemas, ORDS, & APEX
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$SCRIPT_DIR/load-profile.sh"
if [ -f "$SCRIPT_DIR/credential-helper.sh" ]; then
  source "$SCRIPT_DIR/credential-helper.sh"
fi

apply_profile_users() {
  export TNS_ADMIN="$WORKSPACE_DIR/config/tns_admin"
  local arg1="${1:-}"
  local target_profile=""
  local target_container=""

  if [ -n "$arg1" ]; then
    local matched_inst=$(get_active_db_instances 2>/dev/null | grep -E "^${arg1}\|" | head -n 1 || true)
    if [ -n "$matched_inst" ]; then
      target_container="$arg1"
      target_profile=$(echo "$matched_inst" | cut -d'|' -f2)
    else
      target_profile="$arg1"
      target_container="${2:-}"
    fi
  fi

  if [ -z "$target_profile" ]; then
    target_profile=$(get_active_db_instances 2>/dev/null | head -n 1 | cut -d'|' -f2)
    target_profile="${target_profile:-db-proxy-oracle}"
  fi

  load_db_profile "$target_profile"

  if [ -z "$target_container" ]; then
    target_container=$(get_active_db_instances 2>/dev/null | grep "|$target_profile|" | cut -d'|' -f1 | head -n 1 || echo "")
  fi
  [ -z "$target_container" ] && target_container=$(get_active_db_instances 2>/dev/null | head -n 1 | cut -d'|' -f1 || echo "db-proxy")

  echo "👤 Applying profile '${PROFILE_NAME}' (${target_container}) users, roles and ORDS configuration..."

  SQLCL_IMG="${SQLCL_CONTAINER_IMAGE:-container-registry.oracle.com/database/sqlcl:latest}"

  c_short=$(get_db_short_name "$target_container")
  c_upper=$(get_db_upper_name "$target_container")

  get_alias_pwd() {
    local a="$1"
    "$WORKSPACE_DIR/scripts/get-password.sh" -p "$a" 2>/dev/null | tr -d '\r\n' || echo ""
  }

  DBA_ADMIN_PASSWORD=$(get_container_secret "$target_container" "dba_admin_password" 2>/dev/null || true)
  [ -z "$DBA_ADMIN_PASSWORD" ] && DBA_ADMIN_PASSWORD=$(get_alias_pwd "DB_${c_upper}_DBA_ADMIN")
  [ -z "$DBA_ADMIN_PASSWORD" ] && DBA_ADMIN_PASSWORD=$(get_db_user_password "$target_container" "dba_admin" 2>/dev/null || true)
  [ -z "$DBA_ADMIN_PASSWORD" ] && DBA_ADMIN_PASSWORD=$(LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20 2>/dev/null)

  DEV_PASSWORD=$(get_container_secret "$target_container" "dev_password" 2>/dev/null || true)
  [ -z "$DEV_PASSWORD" ] && DEV_PASSWORD=$(get_alias_pwd "DB_${c_upper}_DEV")
  [ -z "$DEV_PASSWORD" ] && DEV_PASSWORD=$(get_alias_pwd "DB_${c_upper}_USER_DEVELOPER")
  [ -z "$DEV_PASSWORD" ] && DEV_PASSWORD=$(get_db_user_password "$target_container" "dev" 2>/dev/null || true)
  [ -z "$DEV_PASSWORD" ] && DEV_PASSWORD=$(LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20 2>/dev/null)
  USER_DEV_PASSWORD="$DEV_PASSWORD"

  VIEWER_PASSWORD=$(get_container_secret "$target_container" "viewer_password" 2>/dev/null || true)
  [ -z "$VIEWER_PASSWORD" ] && VIEWER_PASSWORD=$(get_alias_pwd "DB_${c_upper}_VIEWER")
  [ -z "$VIEWER_PASSWORD" ] && VIEWER_PASSWORD=$(get_alias_pwd "DB_${c_upper}_USER_VIEWER")
  [ -z "$VIEWER_PASSWORD" ] && VIEWER_PASSWORD=$(get_db_user_password "$target_container" "viewer" 2>/dev/null || true)
  [ -z "$VIEWER_PASSWORD" ] && VIEWER_PASSWORD=$(LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20 2>/dev/null)
  USER_VIEWER_PASSWORD="$VIEWER_PASSWORD"

  APP_USER_PASSWORD=$(get_container_secret "$target_container" "app_password" 2>/dev/null || true)
  [ -z "$APP_USER_PASSWORD" ] && APP_USER_PASSWORD=$(get_alias_pwd "DB_${c_upper}_APP")
  [ -z "$APP_USER_PASSWORD" ] && APP_USER_PASSWORD=$(get_alias_pwd "DB_${c_upper}_USER_APP")
  [ -z "$APP_USER_PASSWORD" ] && APP_USER_PASSWORD=$(get_db_user_password "$target_container" "app" 2>/dev/null || true)
  [ -z "$APP_USER_PASSWORD" ] && APP_USER_PASSWORD=$(LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20 2>/dev/null)
  USER_APP_PASSWORD="$APP_USER_PASSWORD"

  APEX_SCHEMA_PASSWORD=$(get_container_secret "$target_container" "schema_password" 2>/dev/null || true)
  [ -z "$APEX_SCHEMA_PASSWORD" ] && APEX_SCHEMA_PASSWORD=$(get_alias_pwd "DB_${c_upper}_SCHEMA")
  [ -z "$APEX_SCHEMA_PASSWORD" ] && APEX_SCHEMA_PASSWORD=$(get_db_user_password "$target_container" "schema" 2>/dev/null || true)
  [ -z "$APEX_SCHEMA_PASSWORD" ] && APEX_SCHEMA_PASSWORD=$(LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20 2>/dev/null)

  PUBLISHER_READER_PASSWORD=$(get_container_secret "$target_container" "publisher_reader_password" 2>/dev/null || true)
  [ -z "$PUBLISHER_READER_PASSWORD" ] && PUBLISHER_READER_PASSWORD=$(get_alias_pwd "DB_${c_upper}_PUBLISHER_READER")
  [ -z "$PUBLISHER_READER_PASSWORD" ] && PUBLISHER_READER_PASSWORD=$(get_alias_pwd "DB_PUBLISHER_READER")
  [ -z "$PUBLISHER_READER_PASSWORD" ] && PUBLISHER_READER_PASSWORD=$(LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20 2>/dev/null)

  APEX_LISTENER_PASSWORD=$(podman secret inspect --showsecret "ords_listener_password" 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
  [ -z "$APEX_LISTENER_PASSWORD" ] && APEX_LISTENER_PASSWORD=$(get_alias_pwd "DB_${c_upper}_ORDS_PUBLIC_USER")
  [ -z "$APEX_LISTENER_PASSWORD" ] && APEX_LISTENER_PASSWORD=$(get_alias_pwd "DB_${c_upper}_APEX_LISTENER")
  [ -z "$APEX_LISTENER_PASSWORD" ] && APEX_LISTENER_PASSWORD=$(get_alias_pwd "DB_PROXY_ORDS_PUBLIC_USER")
  [ -z "$APEX_LISTENER_PASSWORD" ] && APEX_LISTENER_PASSWORD=$(get_alias_pwd "DB_ORDS_PUBLIC_USER")
  [ -z "$APEX_LISTENER_PASSWORD" ] && APEX_LISTENER_PASSWORD=$(get_service_admin_password "ords_listener" 2>/dev/null || true)
  [ -z "$APEX_LISTENER_PASSWORD" ] && APEX_LISTENER_PASSWORD="${PROFILE_APEX_LISTENER_PASSWORD:-}"
  [ -z "$APEX_LISTENER_PASSWORD" ] && APEX_LISTENER_PASSWORD=$(LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20 2>/dev/null)

  DB_SYS_PASSWORD=$(get_container_secret "$target_container" "db_sys_password" 2>/dev/null || true)
  [ -z "$DB_SYS_PASSWORD" ] && DB_SYS_PASSWORD=$(get_alias_pwd "DB_${c_upper}_SYS")
  [ -z "$DB_SYS_PASSWORD" ] && DB_SYS_PASSWORD=$(get_db_sys_password "$target_container" 2>/dev/null || true)

  APEX_ADMIN_PWD=$(get_container_secret "$target_container" "apex_admin_password" 2>/dev/null || true)
  [ -z "$APEX_ADMIN_PWD" ] && APEX_ADMIN_PWD=$(get_alias_pwd "DB_${c_upper}_APEX_ADMIN")
  [ -z "$APEX_ADMIN_PWD" ] && APEX_ADMIN_PWD=$(get_service_admin_password "apex_admin" 2>/dev/null || true)
  [ -z "$APEX_ADMIN_PWD" ] && APEX_ADMIN_PWD="$DB_SYS_PASSWORD"

  PDB_CONTAINER_SET="ALTER SESSION SET CONTAINER = ${PROFILE_DEFAULT_SERVICE:-FREEPDB1};
ALTER SESSION SET \"_oracle_script\" = FALSE;"

  run_db_sqlcl() {
    local target="$1"
    local sql_log="$WORKSPACE_DIR/install_logs/apply_profile_users_sql_${target}.log"
    mkdir -p "$WORKSPACE_DIR/install_logs"

    # Tier 1: In-container SQLcl (preferred) or sqlplus fallback
    if podman container exists "$target" 2>/dev/null; then
      local in_c_sql=$(podman exec "$target" bash -c 'ls -d /opt/oracle/product/*/dbhomeFree/sqlcl/bin/sql 2>/dev/null | head -n 1' || echo "")
      if [ -n "$in_c_sql" ]; then
        podman exec -i "$target" "$in_c_sql" -s / as sysdba >> "$sql_log" 2>&1
        return $?
      elif podman exec "$target" bash -c 'command -v sqlplus >/dev/null 2>&1'; then
        podman exec -i "$target" bash -c 'sqlplus -s / as sysdba' >> "$sql_log" 2>&1
        return $?
      fi
    fi

    # Tier 2: Host SQLcl wrapper with SEPS Wallet
    if [ -x "$WORKSPACE_DIR/scripts/sqlcl.sh" ]; then
      "$WORKSPACE_DIR/scripts/sqlcl.sh" -s "/@DB_${c_upper}_SYS" as sysdba >> "$sql_log" 2>&1
      return $?
    fi

    # Tier 3: Ephemeral SQLcl container
    local sqlcl_img="${SQLCL_CONTAINER_IMAGE:-container-registry.oracle.com/database/sqlcl:latest}"
    if command -v podman &>/dev/null && [ -d "$WORKSPACE_DIR/config/tns_admin" ]; then
      podman run --rm -i -v "$WORKSPACE_DIR/config/tns_admin:/config/tns_admin:ro" -e TNS_ADMIN=/config/tns_admin --network host "$sqlcl_img" -s "/@DB_${c_upper}_SYS" as sysdba >> "$sql_log" 2>&1
      return $?
    fi

    return 1
  }

  run_db_sqlcl_capture() {
    local target="$1"
    if podman container exists "$target" 2>/dev/null; then
      local in_c_sql=$(podman exec "$target" bash -c 'ls -d /opt/oracle/product/*/dbhomeFree/sqlcl/bin/sql 2>/dev/null | head -n 1' || echo "")
      if [ -n "$in_c_sql" ]; then
        podman exec -i "$target" "$in_c_sql" -s / as sysdba
        return $?
      elif podman exec "$target" bash -c 'command -v sqlplus >/dev/null 2>&1'; then
        podman exec -i "$target" bash -c 'sqlplus -s / as sysdba'
        return $?
      fi
    fi
    if [ -x "$WORKSPACE_DIR/scripts/sqlcl.sh" ]; then
      "$WORKSPACE_DIR/scripts/sqlcl.sh" -s "/@DB_${c_upper}_SYS" as sysdba
      return $?
    fi
    return 1
  }

  if podman container exists "$target_container" 2>/dev/null; then
    # 0. Synchronize SYS and SYSTEM passwords across all containers (CDB + PDB)
    if [ -n "$DB_SYS_PASSWORD" ] && [ "$IS_ADB" != "true" ]; then
      run_db_sqlcl "$target_container" << EOF || true
WHENEVER SQLERROR CONTINUE;
ALTER USER sys IDENTIFIED BY "${DB_SYS_PASSWORD}" CONTAINER=ALL;
ALTER USER system IDENTIFIED BY "${DB_SYS_PASSWORD}" CONTAINER=ALL;
EXIT;
EOF
    fi

    run_db_sqlcl "$target_container" << EOF || true
WHENEVER SQLERROR CONTINUE;
${PDB_CONTAINER_SET}
SET SERVEROUTPUT ON SIZE UNLIMITED;

-- 1. Create DB user APEX_PROXY_SCHEMA
DECLARE
  v_user_exists NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_user_exists FROM dba_users WHERE username = 'APEX_PROXY_SCHEMA';
  IF v_user_exists = 0 THEN
    EXECUTE IMMEDIATE 'CREATE USER APEX_PROXY_SCHEMA IDENTIFIED BY "${APEX_SCHEMA_PASSWORD}"';
  ELSE
    BEGIN
      EXECUTE IMMEDIATE 'ALTER USER APEX_PROXY_SCHEMA IDENTIFIED BY "${APEX_SCHEMA_PASSWORD}"';
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
  END IF;
  EXECUTE IMMEDIATE 'GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE PROCEDURE, CREATE SEQUENCE, CREATE SYNONYM TO APEX_PROXY_SCHEMA';
  EXECUTE IMMEDIATE 'ALTER USER APEX_PROXY_SCHEMA DEFAULT TABLESPACE USERS TEMPORARY TABLESPACE TEMP QUOTA UNLIMITED ON USERS';
END;
/

-- 1.5 Create dedicated DBA admin user DBA_ADMIN (avoids using SYS daily)
DECLARE
  v_user_exists NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_user_exists FROM dba_users WHERE username = 'DBA_ADMIN';
  IF v_user_exists = 0 THEN
    EXECUTE IMMEDIATE 'CREATE USER DBA_ADMIN IDENTIFIED BY "${DBA_ADMIN_PASSWORD}"';
  ELSE
    BEGIN
      EXECUTE IMMEDIATE 'ALTER USER DBA_ADMIN IDENTIFIED BY "${DBA_ADMIN_PASSWORD}"';
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
  END IF;
  EXECUTE IMMEDIATE 'GRANT CREATE SESSION, DBA TO DBA_ADMIN';
  EXECUTE IMMEDIATE 'ALTER USER DBA_ADMIN DEFAULT TABLESPACE USERS TEMPORARY TABLESPACE TEMP QUOTA UNLIMITED ON USERS';

  -- Grant INHERIT PRIVILEGES to ORDS_METADATA so SYS can execute ORDS.ENABLE_SCHEMA for DBA users
  BEGIN
    EXECUTE IMMEDIATE 'GRANT INHERIT PRIVILEGES ON USER SYS TO ORDS_METADATA';
  EXCEPTION WHEN OTHERS THEN NULL;
  END;

  -- Enable ORDS REST / SQL Developer Web interface for DBA_ADMIN user
  BEGIN
    EXECUTE IMMEDIATE 'BEGIN
      ORDS.ENABLE_SCHEMA(
          p_enabled             => TRUE,
          p_schema              => ''DBA_ADMIN'',
          p_url_mapping_type    => ''BASE_PATH'',
          p_url_mapping_pattern => ''dba_admin'',
          p_auto_rest_auth      => FALSE
      );
    END;';
  EXCEPTION WHEN OTHERS THEN NULL;
  END;
END;
/

-- 2. Create DB user USER_DEVELOPER and assign profile roles
DECLARE
  v_user_exists NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_user_exists FROM dba_users WHERE username = 'USER_DEVELOPER';
  IF v_user_exists = 0 THEN
    EXECUTE IMMEDIATE 'CREATE USER USER_DEVELOPER IDENTIFIED BY "${USER_DEV_PASSWORD}"';
  ELSE
    BEGIN
      EXECUTE IMMEDIATE 'ALTER USER USER_DEVELOPER IDENTIFIED BY "${USER_DEV_PASSWORD}"';
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
  END IF;
  EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO USER_DEVELOPER';
  EXECUTE IMMEDIATE 'GRANT DB_DEVELOPER_ROLE TO USER_DEVELOPER';
  BEGIN
    EXECUTE IMMEDIATE 'GRANT CONSOLE_DEVELOPER, DWROLE, RESOURCE TO USER_DEVELOPER';
  EXCEPTION WHEN OTHERS THEN NULL;
  END;
  EXECUTE IMMEDIATE 'ALTER USER USER_DEVELOPER DEFAULT TABLESPACE USERS TEMPORARY TABLESPACE TEMP QUOTA UNLIMITED ON USERS';

  -- Lubatakse ORDS REST / SQL Developer Web liides (kui ORDS on paigaldatud)
  BEGIN
    EXECUTE IMMEDIATE 'BEGIN
      ORDS.ENABLE_SCHEMA(
          p_enabled             => TRUE,
          p_schema              => ''USER_DEVELOPER'',
          p_url_mapping_type    => ''BASE_PATH'',
          p_url_mapping_pattern => ''user_developer'',
          p_auto_rest_auth      => FALSE
      );
    END;';
  EXCEPTION WHEN OTHERS THEN NULL;
  END;
END;
/

-- 2.5 Create application runtime and schema user USER_APP (Forms and business objects)
DECLARE
  v_user_exists NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_user_exists FROM dba_users WHERE username = 'USER_APP';
  IF v_user_exists = 0 THEN
    EXECUTE IMMEDIATE 'CREATE USER USER_APP IDENTIFIED BY "${USER_APP_PASSWORD}"';
  ELSE
    BEGIN
      EXECUTE IMMEDIATE 'ALTER USER USER_APP IDENTIFIED BY "${USER_APP_PASSWORD}"';
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
  END IF;
  EXECUTE IMMEDIATE 'GRANT CREATE SESSION, RESOURCE, CREATE TABLE, CREATE VIEW, CREATE PROCEDURE, CREATE SEQUENCE, CREATE SYNONYM TO USER_APP';
  EXECUTE IMMEDIATE 'ALTER USER USER_APP DEFAULT TABLESPACE USERS TEMPORARY TABLESPACE TEMP QUOTA UNLIMITED ON USERS';
END;
/

-- 3. Create restricted viewer user USER_VIEWER (read-only for all schemas)
DECLARE
  v_user_exists NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_user_exists FROM dba_users WHERE username = 'USER_VIEWER';
  IF v_user_exists = 0 THEN
    EXECUTE IMMEDIATE 'CREATE USER USER_VIEWER IDENTIFIED BY "${USER_VIEWER_PASSWORD}"';
  ELSE
    BEGIN
      EXECUTE IMMEDIATE 'ALTER USER USER_VIEWER IDENTIFIED BY "${USER_VIEWER_PASSWORD}"';
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
  END IF;
  EXECUTE IMMEDIATE 'GRANT CREATE SESSION, SELECT ANY TABLE, SELECT ANY DICTIONARY TO USER_VIEWER';
  BEGIN
    EXECUTE IMMEDIATE 'GRANT READ ANY TABLE TO USER_VIEWER';
  EXCEPTION WHEN OTHERS THEN NULL;
  END;
  EXECUTE IMMEDIATE 'ALTER USER USER_VIEWER DEFAULT TABLESPACE USERS TEMPORARY TABLESPACE TEMP';
END;
/

-- 4. Create restricted system reporting user PUBLISHER_READER (Analytics Publisher)
DECLARE
  v_user_exists NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_user_exists FROM dba_users WHERE username = 'PUBLISHER_READER';
  IF v_user_exists = 0 THEN
    EXECUTE IMMEDIATE 'CREATE USER PUBLISHER_READER IDENTIFIED BY "${PUBLISHER_READER_PASSWORD}"';
  ELSE
    BEGIN
      EXECUTE IMMEDIATE 'ALTER USER PUBLISHER_READER IDENTIFIED BY "${PUBLISHER_READER_PASSWORD}"';
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
  END IF;
  EXECUTE IMMEDIATE 'GRANT CREATE SESSION, SELECT ANY TABLE, SELECT ANY DICTIONARY TO PUBLISHER_READER';
  BEGIN
    EXECUTE IMMEDIATE 'GRANT READ ANY TABLE TO PUBLISHER_READER';
  EXCEPTION WHEN OTHERS THEN NULL;
  END;
  EXECUTE IMMEDIATE 'ALTER USER PUBLISHER_READER DEFAULT TABLESPACE USERS TEMPORARY TABLESPACE TEMP';
END;
/

  -- Ensure DEFAULT profile has unlimited login attempts to prevent lockouts
  BEGIN
    EXECUTE IMMEDIATE 'ALTER PROFILE DEFAULT LIMIT FAILED_LOGIN_ATTEMPTS UNLIMITED PASSWORD_LIFE_TIME UNLIMITED';
  EXCEPTION WHEN OTHERS THEN NULL;
  END;
/

  -- Set passwords and unlock all ORDS & APEX service accounts
  BEGIN
    EXECUTE IMMEDIATE 'ALTER SESSION SET "_oracle_script" = TRUE';
    -- Ensure ORDS_PUBLIC_USER exists if needed
    DECLARE
      v_ords_cnt NUMBER := 0;
      v_ts VARCHAR2(30) := 'USERS';
    BEGIN
      SELECT COUNT(*) INTO v_ords_cnt FROM dba_users WHERE username = 'ORDS_PUBLIC_USER';
      IF v_ords_cnt = 0 AND '${APEX_LISTENER_PASSWORD}' IS NOT NULL AND LENGTH('${APEX_LISTENER_PASSWORD}') > 0 THEN
        BEGIN
          SELECT tablespace_name INTO v_ts FROM (
            SELECT tablespace_name FROM dba_tablespaces WHERE contents = 'PERMANENT' AND status = 'ONLINE' ORDER BY CASE WHEN tablespace_name IN ('USERS', 'DATA') THEN 1 ELSE 2 END
          ) WHERE ROWNUM = 1;
        EXCEPTION WHEN OTHERS THEN v_ts := 'SYSAUX';
        END;
        BEGIN
          EXECUTE IMMEDIATE 'CREATE USER ORDS_PUBLIC_USER IDENTIFIED BY "' || '${APEX_LISTENER_PASSWORD}' || '" DEFAULT TABLESPACE ' || v_ts || ' TEMPORARY TABLESPACE TEMP';
          EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO ORDS_PUBLIC_USER';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
      END IF;
    EXCEPTION WHEN OTHERS THEN NULL;
    END;

    IF '${APEX_LISTENER_PASSWORD}' IS NOT NULL AND LENGTH('${APEX_LISTENER_PASSWORD}') > 0 THEN
      FOR u IN (SELECT username FROM dba_users WHERE username IN ('ORDS_PUBLIC_USER', 'APEX_PUBLIC_USER', 'APEX_PUBLIC_ROUTER', 'APEX_LISTENER', 'APEX_REST_PUBLIC_USER')) LOOP
        BEGIN
          EXECUTE IMMEDIATE 'ALTER USER ' || u.username || ' IDENTIFIED BY "' || '${APEX_LISTENER_PASSWORD}' || '" ACCOUNT UNLOCK';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
      END LOOP;
    END IF;

    FOR u IN (SELECT username FROM dba_users WHERE username IN ('ORDS_METADATA', 'USER_DEVELOPER', 'DBA_ADMIN', 'USER_APP', 'USER_VIEWER', 'APEX_PROXY_SCHEMA', 'ALISE_APP')) LOOP
      BEGIN
        EXECUTE IMMEDIATE 'ALTER USER ' || u.username || ' ACCOUNT UNLOCK';
      EXCEPTION WHEN OTHERS THEN NULL;
      END;
    END LOOP;

    EXECUTE IMMEDIATE 'ALTER USER APEX_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER';
    EXECUTE IMMEDIATE 'ALTER USER APEX_REST_PUBLIC_USER GRANT CONNECT THROUGH ORDS_PUBLIC_USER';
    EXECUTE IMMEDIATE 'ALTER USER APEX_LISTENER GRANT CONNECT THROUGH ORDS_PUBLIC_USER';
    EXECUTE IMMEDIATE 'ALTER USER APEX_PUBLIC_ROUTER GRANT CONNECT THROUGH ORDS_PUBLIC_USER';
    EXECUTE IMMEDIATE 'ALTER USER USER_DEVELOPER GRANT CONNECT THROUGH ORDS_PUBLIC_USER';
    EXECUTE IMMEDIATE 'ALTER USER APEX_PROXY_SCHEMA GRANT CONNECT THROUGH ORDS_PUBLIC_USER';
    EXECUTE IMMEDIATE 'ALTER USER DBA_ADMIN GRANT CONNECT THROUGH ORDS_PUBLIC_USER';
    EXECUTE IMMEDIATE 'ALTER USER USER_APP GRANT CONNECT THROUGH ORDS_PUBLIC_USER';
    EXECUTE IMMEDIATE 'ALTER USER USER_VIEWER GRANT CONNECT THROUGH ORDS_PUBLIC_USER';

    -- Internal DB security lockdown (Lock internal APEX & ORDS web access if requested)
    IF ('${LOCK_INTERNAL_APEX:-false}' = 'true' OR '${DISABLE_INTERNAL_APEX_WEB:-false}' = 'true') AND ('${c_short}' = 'forms' OR '${c_short}' = 'publisher') THEN
      BEGIN
        EXECUTE IMMEDIATE 'ALTER USER APEX_PUBLIC_USER ACCOUNT LOCK';
        EXECUTE IMMEDIATE 'ALTER USER APEX_LISTENER ACCOUNT LOCK';
      EXCEPTION WHEN OTHERS THEN NULL;
      END;
    END IF;

    EXECUTE IMMEDIATE 'ALTER SESSION SET "_oracle_script" = FALSE';
  EXCEPTION WHEN OTHERS THEN NULL;
  END;
/

-- 5. Set active APEX schema
BEGIN
  FOR s IN (SELECT username FROM dba_users WHERE username LIKE 'APEX_%' AND REGEXP_LIKE(username, '^APEX_[0-9]+$') AND ROWNUM = 1) LOOP
    EXECUTE IMMEDIATE 'ALTER SESSION SET CURRENT_SCHEMA = ' || s.username;
  END LOOP;
END;
/

-- 6. Create APEX workspaces and users
DECLARE
  v_workspace_id NUMBER;
  v_target_ws VARCHAR2(100) := '${PROFILE_APEX_WORKSPACE:-ALISE_WORKSPACE}';
  v_primary_schema VARCHAR2(100) := '${PROFILE_DB_SCHEMA:-${PROFILE_APEX_SCHEMA_USER:-USER_DEVELOPER}}';
BEGIN
  BEGIN
    APEX_INSTANCE_ADMIN.SET_PARAMETER('STRONG_SITE_ADMIN_PASSWORD', 'N');
    APEX_INSTANCE_ADMIN.SET_PARAMETER('ACCOUNT_LIFETIME_DAYS', '9999');
    APEX_INSTANCE_ADMIN.SET_PARAMETER('MAX_LOGIN_FAILURES', '100');
    APEX_INSTANCE_ADMIN.SET_PARAMETER('ALLOW_SQL_DEVELOPER_WEB', 'Y');
    COMMIT;
  EXCEPTION WHEN OTHERS THEN NULL;
  END;

  DECLARE
    v_user_cnt NUMBER := 0;
  BEGIN
    IF v_primary_schema IS NULL OR v_primary_schema LIKE 'APEX_%' OR v_primary_schema LIKE 'apex_%' OR v_primary_schema LIKE 'USER_%' OR v_primary_schema LIKE 'user_%' OR v_primary_schema LIKE 'SYS%' OR v_primary_schema LIKE 'sys%' OR v_primary_schema LIKE 'ORDS_%' OR v_primary_schema LIKE 'ords_%' THEN
      v_primary_schema := '${c_upper}_SCHEMA';
    END IF;
    SELECT COUNT(*) INTO v_user_cnt FROM dba_users WHERE username = v_primary_schema;
    IF v_user_cnt = 0 THEN
      FOR u IN (SELECT username FROM dba_users WHERE username IN ('APP_SCHEMA', '${c_upper}_SCHEMA', 'USER_DEVELOPER') AND ROWNUM = 1) LOOP
        v_primary_schema := u.username;
        v_user_cnt := 1;
      END LOOP;
    END IF;
    IF v_user_cnt = 0 THEN
      BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET "_oracle_script" = TRUE';
        EXECUTE IMMEDIATE 'CREATE USER ' || v_primary_schema || ' IDENTIFIED BY "${USER_DEV_PASSWORD}"';
        EXECUTE IMMEDIATE 'GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE PROCEDURE, CREATE SEQUENCE, CREATE SYNONYM TO ' || v_primary_schema;
        EXECUTE IMMEDIATE 'ALTER USER ' || v_primary_schema || ' DEFAULT TABLESPACE USERS TEMPORARY TABLESPACE TEMP QUOTA UNLIMITED ON USERS';
        EXECUTE IMMEDIATE 'ALTER SESSION SET "_oracle_script" = FALSE';
      EXCEPTION WHEN OTHERS THEN NULL;
      END;
    END IF;
  EXCEPTION WHEN OTHERS THEN NULL;
  END;

  BEGIN
    FOR s IN (SELECT username FROM dba_users WHERE username LIKE 'APEX_%' AND REGEXP_LIKE(username, '^APEX_[0-9]+$') AND ROWNUM = 1) LOOP
      EXECUTE IMMEDIATE 'ALTER SESSION SET CURRENT_SCHEMA = ' || s.username;
    END LOOP;
  EXCEPTION WHEN OTHERS THEN NULL;
  END;

  DECLARE
    v_ws_id NUMBER;
  BEGIN
    FOR target_name IN (SELECT v_target_ws AS ws_name FROM dual UNION SELECT '${c_upper}_WS' AS ws_name FROM dual WHERE '${c_upper}_WS' != v_target_ws) LOOP
      BEGIN
        SELECT workspace_id INTO v_ws_id FROM apex_workspaces WHERE workspace = target_name.ws_name;
      EXCEPTION WHEN OTHERS THEN v_ws_id := NULL;
      END;

      IF v_ws_id IS NULL OR v_ws_id = 0 THEN
        BEGIN
          FOR s IN (SELECT username FROM dba_users WHERE username LIKE 'APEX_%' AND REGEXP_LIKE(username, '^APEX_[0-9]+$') AND ROWNUM = 1) LOOP
            EXECUTE IMMEDIATE 'BEGIN ' || s.username || '.WWV_FLOW_INSTANCE_ADMIN.add_workspace(p_workspace_id => NULL, p_workspace => ''' || target_name.ws_name || ''', p_primary_schema => ''' || v_primary_schema || '''); COMMIT; END;';
          END LOOP;
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
      END IF;
    END LOOP;

    -- Provision DEV and USER_DEVELOPER across all active application workspaces
    FOR w IN (SELECT workspace_id, workspace FROM apex_workspaces WHERE workspace IN (v_target_ws, '${c_upper}_WS', 'PROXY_WORKSPACE')) LOOP
      FOR s IN (SELECT username FROM dba_users WHERE username LIKE 'APEX_%' AND REGEXP_LIKE(username, '^APEX_[0-9]+$') AND ROWNUM = 1) LOOP
        BEGIN
          EXECUTE IMMEDIATE 'BEGIN ' || s.username || '.HTMLDB_UTIL.set_security_group_id(' || w.workspace_id || '); END;';
          
          -- 1. DEV user
          BEGIN
            EXECUTE IMMEDIATE 'BEGIN ' || s.username || '.HTMLDB_UTIL.remove_user(p_user_name => ''DEV''); EXCEPTION WHEN OTHERS THEN NULL; END;';
            EXECUTE IMMEDIATE 'BEGIN ' || s.username || '.HTMLDB_UTIL.create_user(p_user_name => ''DEV'', p_email_address => ''dev_' || lower(w.workspace) || '@company.local'', p_web_password => ''' || '${USER_DEV_PASSWORD}' || ''', p_developer_privs => ''ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:VARIABLE'', p_account_expiry => sysdate + 3650, p_account_locked => ''N'', p_change_password_on_first_use => ''N''); COMMIT; EXCEPTION WHEN OTHERS THEN NULL; END;';
          EXCEPTION WHEN OTHERS THEN NULL;
          END;

          -- 2. USER_DEVELOPER user
          BEGIN
            EXECUTE IMMEDIATE 'BEGIN ' || s.username || '.HTMLDB_UTIL.remove_user(p_user_name => ''USER_DEVELOPER''); EXCEPTION WHEN OTHERS THEN NULL; END;';
            EXECUTE IMMEDIATE 'BEGIN ' || s.username || '.HTMLDB_UTIL.create_user(p_user_name => ''USER_DEVELOPER'', p_email_address => ''user_dev_' || lower(w.workspace) || '@company.local'', p_web_password => ''' || '${USER_DEV_PASSWORD}' || ''', p_developer_privs => ''ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:VARIABLE'', p_account_expiry => sysdate + 3650, p_account_locked => ''N'', p_change_password_on_first_use => ''N''); COMMIT; EXCEPTION WHEN OTHERS THEN NULL; END;';
          EXCEPTION WHEN OTHERS THEN NULL;
          END;
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
      END LOOP;
    END LOOP;

    -- Unlock all developer users across all schemas
    FOR s IN (SELECT username FROM dba_users WHERE username LIKE 'APEX_%' AND REGEXP_LIKE(username, '^APEX_[0-9]+$') AND ROWNUM = 1) LOOP
      BEGIN
        EXECUTE IMMEDIATE 'UPDATE ' || s.username || '.wwv_flow_fnd_user SET account_locked = ''N'', change_password_on_first_use = ''N'', account_expiry = sysdate + 3650 WHERE user_name IN (''DEV'', ''USER_DEVELOPER'', ''ADMIN'')';
        COMMIT;
      EXCEPTION WHEN OTHERS THEN NULL;
      END;
    END LOOP;
  EXCEPTION WHEN OTHERS THEN NULL;
  END;

  -- 5. INTERNAL Workspace Admin
  BEGIN
    APEX_INSTANCE_ADMIN.SET_PARAMETER('STRONG_SITE_ADMIN_PASSWORD', 'N');
    APEX_INSTANCE_ADMIN.SET_PARAMETER('ACCOUNT_LIFETIME_DAYS', '9999');
    APEX_INSTANCE_ADMIN.SET_PARAMETER('MAX_LOGIN_FAILURES', '100');
    COMMIT;
    wwv_flow_instance_admin.create_or_update_admin_user(
        p_username => 'ADMIN',
        p_email    => 'admin@company.local',
        p_password => '${APEX_ADMIN_PWD}'
    );
    wwv_flow_instance_admin.unlock_user(
        p_workspace => 'INTERNAL',
        p_username  => 'ADMIN',
        p_password  => '${APEX_ADMIN_PWD}'
    );
    UPDATE wwv_flow_fnd_user
    SET change_password_on_first_use = 'N',
        account_locked = 'N',
        account_expiry = NULL
    WHERE security_group_id = 10 AND user_name = 'ADMIN';
    COMMIT;
  EXCEPTION WHEN OTHERS THEN NULL;
  END;

  COMMIT;
END;
/

-- 7. Lubatakse skeemid ORDS-i jaoks (SDW ja REST teenused)
BEGIN
  ORDS_METADATA.ORDS_ADMIN.ENABLE_SCHEMA(
      p_enabled             => TRUE,
      p_schema              => 'USER_DEVELOPER',
      p_url_mapping_type    => 'BASE_PATH',
      p_url_mapping_pattern => 'user_developer',
      p_auto_rest_auth      => TRUE
  );
  COMMIT;
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
EXIT;
EOF
  fi

  local should_install_ords=true
  if ! is_db_ords_install_required "$target_profile"; then
    should_install_ords=false
    echo "   ℹ️  ORDS in-database schema installation skipped (install_in_db: false for profile '$target_profile')."
  fi

  # Check if ORDS is installed in database
  local ords_installed=$(run_db_sqlcl_capture "$target_container" << EOSQL 2>/dev/null | grep "ORDS_READY" || true
ALTER SESSION SET CONTAINER = ${PROFILE_DEFAULT_SERVICE:-FREEPDB1};
SELECT 'ORDS_READY' FROM dba_objects WHERE owner = 'ORDS_METADATA' AND object_name = 'ORDS' AND object_type = 'PACKAGE BODY' AND status = 'VALID';
EXIT;
EOSQL
)

  if [ "$should_install_ords" = "true" ] && [ -z "$ords_installed" ]; then
    local target_ords_ver=$(resolve_target_ords_version)
    local ords_container_img="container-registry.oracle.com/database/ords:latest"
    if [ "$target_ords_ver" != "latest" ] && [ -n "$target_ords_ver" ]; then
      ords_container_img="container-registry.oracle.com/database/ords:${target_ords_ver}"
    fi

    run_db_sqlcl "$target_container" << EOSQL || true
WHENEVER SQLERROR CONTINUE;
ALTER SESSION SET "_oracle_script" = TRUE;
ALTER SESSION SET CONTAINER = ${PROFILE_DEFAULT_SERVICE:-FREEPDB1};
ALTER SESSION SET "_oracle_script" = TRUE;
BEGIN
  FOR u IN (SELECT username FROM dba_users WHERE username IN ('ORDS_METADATA', 'ORDS_PUBLIC_USER')) LOOP
    EXECUTE IMMEDIATE 'DROP USER ' || u.username || ' CASCADE';
  END LOOP;
  FOR r IN (SELECT role FROM dba_roles WHERE role IN ('ORDS_ADMINISTRATOR_ROLE', 'ORDS_RUNTIME_ROLE')) LOOP
    EXECUTE IMMEDIATE 'DROP ROLE ' || r.role;
  END LOOP;
END;
/
EXIT;
EOSQL

    printf "%s\n%s\n" "$DB_SYS_PASSWORD" "$APEX_LISTENER_PASSWORD" | podman run --rm -i --network oracle-free-db-in-prod_default \
      --memory 2048m \
      "$ords_container_img" \
      install \
      --admin-user SYS \
      --db-hostname "$target_container" \
      --db-port 1521 \
      --db-servicename "${PROFILE_DEFAULT_SERVICE:-FREEPDB1}" \
      --feature-db-api true \
      --feature-rest-enabled-sql true \
      --feature-sdw true \
      --gateway-mode proxied \
      --gateway-user APEX_PUBLIC_USER \
      --proxy-user \
      --schema-tablespace USERS \
      --schema-temp-tablespace TEMP \
      --password-stdin >/dev/null 2>&1 || true
  fi

  # Enable USER_DEVELOPER schema in ORDS
  run_db_sqlcl "$target_container" << 'EOSQL' || true
WHENEVER SQLERROR CONTINUE;
ALTER SESSION SET CONTAINER = FREEPDB1;
BEGIN
  ORDS_METADATA.ORDS_ADMIN.ENABLE_SCHEMA(
      p_enabled             => TRUE,
      p_schema              => 'USER_DEVELOPER',
      p_url_mapping_type    => 'BASE_PATH',
      p_url_mapping_pattern => 'user_developer',
      p_auto_rest_auth      => TRUE
  );
  COMMIT;
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
ALTER USER USER_DEVELOPER GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
ALTER USER DBA_ADMIN GRANT CONNECT THROUGH ORDS_PUBLIC_USER;
COMMIT;
EXIT;
EOSQL

  # Automatic pool registration with running central ORDS (env0)
  if is_ords_running; then
    local pool_suffix="${target_container#db-}"
    pool_suffix="${pool_suffix#oracle-db-}"
    pool_suffix=$(echo "$pool_suffix" | tr '-' '_' | tr '[:upper:]' '[:lower:]')
    local pool_name="${PROFILE_ORDS_POOL_NAME:-$pool_suffix}"
    [ -z "$pool_name" ] && pool_name="$pool_suffix"

    local can_register_pool=true
    if [ "${PROFILE_ORDS_VERIFY_VERSION_MATCH:-false}" = "true" ]; then
      if ! check_adb_ords_version_match "$target_container"; then
        echo "   ⚠️  ADB ORDS version does not match running central ORDS. Pool registration skipped."
        can_register_pool=false
      fi
    fi

    if [ "$can_register_pool" = "true" ]; then
      local central_ords_dir="$WORKSPACE_DIR/config/ords/proxy/databases/$pool_name"
      mkdir -p "$central_ords_dir"
      cat << POOLEOF > "$central_ords_dir/pool.xml"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
<properties>
<entry key="db.connectionType">basic</entry>
<entry key="db.hostname">${target_container}</entry>
<entry key="db.port">1521</entry>
<entry key="db.servicename">${PROFILE_DEFAULT_SERVICE:-FREEPDB1}</entry>
<entry key="db.username">ORDS_PUBLIC_USER</entry>
<entry key="db.password">${APEX_LISTENER_PASSWORD}</entry>
<entry key="feature.sdw">true</entry>
<entry key="feature.apex">true</entry>
<entry key="plsql.gateway.mode">proxied</entry>
<entry key="restEnabledSql.active">true</entry>
</properties>
POOLEOF
      echo "   ✅ Registered ORDS pool '$pool_name' in central ORDS (env0)."
      podman restart app-ords >/dev/null 2>&1 || true
    fi
  fi

  echo "✅ Profile users and roles configured successfully."
}

if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
  apply_profile_users "$1" "$2"
fi
