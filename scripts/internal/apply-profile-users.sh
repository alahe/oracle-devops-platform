#!/usr/bin/env bash
# ============================================================================
# Dynamic Profile Users & Roles Applicator
# Reads users configuration from active YAML profile and applies DB schemas, ORDS, & APEX
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$SCRIPT_DIR/load-profile.sh"

apply_profile_users() {
  export TNS_ADMIN="$WORKSPACE_DIR/config/tns_admin"
  local active_prof=$(get_active_db_instances 2>/dev/null | head -n 1 | cut -d'|' -f2)
  local target_profile="${1:-${MAIN_DB_PROFILE:-${active_prof:-proxy-standard-gvenzl}}}"
  load_db_profile "$target_profile"

  echo "👤 Rakendan profiili '${PROFILE_NAME}' kasutajaid, rolle ja ORDS seadeid..."

  APEX_LISTENER_PASSWORD="${APEX_LISTENER_PASSWORD:-${PROFILE_APEX_LISTENER_PASSWORD:-}}"
  SQLCL_IMG="${SQLCL_CONTAINER_IMAGE:-container-registry.oracle.com/database/sqlcl:latest}"
  if [ -z "$APEX_LISTENER_PASSWORD" ]; then
    APEX_LISTENER_PASSWORD=$(podman run --rm --entrypoint cat --secret ords_listener_password "$SQLCL_IMG" /run/secrets/ords_listener_password 2>/dev/null || podman secret inspect --showsecret ords_listener_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || podman secret inspect --showsecret apex_schema_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
  fi
  if [ -z "$APEX_LISTENER_PASSWORD" ]; then
    APEX_LISTENER_PASSWORD=$(LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20 2>/dev/null)
  fi
  DBA_ADMIN_PASSWORD=$(podman run --rm --entrypoint cat --secret dba_admin_password "$SQLCL_IMG" /run/secrets/dba_admin_password 2>/dev/null || podman secret inspect --showsecret dba_admin_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
  TEST_DEV_PASSWORD=$(podman run --rm --entrypoint cat --secret test_dev_password "$SQLCL_IMG" /run/secrets/test_dev_password 2>/dev/null || podman secret inspect --showsecret test_dev_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
  TEST_VIEWER_PASSWORD=$(podman run --rm --entrypoint cat --secret test_viewer_password "$SQLCL_IMG" /run/secrets/test_viewer_password 2>/dev/null || podman secret inspect --showsecret test_viewer_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
  TEST_WEB_PASSWORD=$(podman run --rm --entrypoint cat --secret test_web_password "$SQLCL_IMG" /run/secrets/test_web_password 2>/dev/null || podman secret inspect --showsecret test_web_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
  APEX_SCHEMA_PASSWORD=$(podman run --rm --entrypoint cat --secret apex_schema_password "$SQLCL_IMG" /run/secrets/apex_schema_password 2>/dev/null || podman secret inspect --showsecret apex_schema_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
  PUBLISHER_READER_PASSWORD=$(podman run --rm --entrypoint cat --secret publisher_reader_password "$SQLCL_IMG" /run/secrets/publisher_reader_password 2>/dev/null || podman secret inspect --showsecret publisher_reader_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)

  if [ -z "$DBA_ADMIN_PASSWORD" ]; then
    DBA_ADMIN_PASSWORD=$(LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20 2>/dev/null)
  fi
  if [ -z "$TEST_DEV_PASSWORD" ]; then
    TEST_DEV_PASSWORD=$(LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20 2>/dev/null)
  fi
  if [ -z "$TEST_VIEWER_PASSWORD" ]; then
    TEST_VIEWER_PASSWORD=$(LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20 2>/dev/null)
  fi
  if [ -z "$TEST_WEB_PASSWORD" ]; then
    TEST_WEB_PASSWORD=$(LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20 2>/dev/null)
  fi
  if [ -z "$APEX_SCHEMA_PASSWORD" ]; then
    APEX_SCHEMA_PASSWORD=$(LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20 2>/dev/null)
  fi
  if [ -z "$PUBLISHER_READER_PASSWORD" ]; then
    PUBLISHER_READER_PASSWORD=$(LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20 2>/dev/null)
  fi

  PRIMARY_CONTAINER=$(get_active_db_instances 2>/dev/null | head -n 1 | cut -d'|' -f1)
  PRIMARY_CONTAINER="${PRIMARY_CONTAINER:-db-dev-full}"
  PRIMARY_UPPER=$(echo "$PRIMARY_CONTAINER" | tr '-' '_' | tr '[:lower:]' '[:upper:]')

  # Ensure CONN_STR_SYS is set
  SYS_PWD=$(podman exec "$PRIMARY_CONTAINER" cat /run/secrets/oracle_pwd 2>/dev/null || podman secret inspect --showsecret apex_db_sys_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || echo "")
  if [ -z "$CONN_STR_SYS" ]; then
    if [ "$IS_ADB" = "true" ]; then
      if [ -f "$WORKSPACE_DIR/config/tns_admin/cwallet.sso" ]; then
        CONN_STR_SYS="/@DB_${PRIMARY_UPPER}_SYS"
      else
        CONN_STR_SYS="admin/${SYS_PWD}@localhost:${PROFILE_DB_PORT:-1532}/${PROFILE_DEFAULT_SERVICE:-MYATP_low.adb.oraclecloud.com}"
      fi
    else
      CONN_STR_SYS="sys/${SYS_PWD}@localhost:${PROFILE_DB_PORT:-1532}/${PROFILE_DEFAULT_SERVICE:-FREEPDB1} as sysdba"
    fi
  fi

  if ! declare -f run_sqlcl >/dev/null; then
    run_sqlcl() {
      local LOCAL_BIN=""
      local VSCODE_SQLCL=$(find "$HOME/.vscode/extensions" -name "sql" -path "*/oracle.sql-developer-*/dbtools/sqlcl/bin/sql" 2>/dev/null | head -n 1)
      if [ -n "$VSCODE_SQLCL" ] && [ -x "$VSCODE_SQLCL" ]; then
        LOCAL_BIN="$VSCODE_SQLCL"
      elif command -v sql &>/dev/null; then
        LOCAL_BIN="sql"
      fi
      if [ -n "$LOCAL_BIN" ]; then
        "$LOCAL_BIN" "$@" && return 0
      fi
      local RUN_IMAGE="${SQLCL_CONTAINER_IMAGE:-container-registry.oracle.com/database/sqlcl:latest}"
      local PROJECT_NET="${PROJECT_NAME:-oracle-free-db-in-prod}_default"
      podman run --rm -i --network="${PROJECT_NET}" \
        -v "$WORKSPACE_DIR:/workspace" \

        -v "$WORKSPACE_DIR/config/tns_admin_container:/tns:ro" \
        -e JAVA_TOOL_OPTIONS="-Doracle.net.tns_admin=/tns -Doracle.net.wallet_location=(SOURCE=(METHOD=FILE)(METHOD_DATA=(DIRECTORY=/tns)))" \
        -e TNS_ADMIN=/tns \
        -w /workspace "$RUN_IMAGE" "$@"
    }
  fi

  PDB_CONTAINER_SET=""
  if [ "$IS_ADB" != "true" ]; then
    PDB_CONTAINER_SET="ALTER SESSION SET CONTAINER = ${PROFILE_DEFAULT_SERVICE:-FREEPDB1};
ALTER SESSION SET \"_oracle_script\" = TRUE;"
  fi

  # Execute SQLcl user provisioning
  run_sqlcl -s $CONN_STR_SYS <<EOF
${PDB_CONTAINER_SET}
SET SERVEROUTPUT ON SIZE UNLIMITED;

-- 1. Luuakse DB kasutaja APEX_PROXY_SCHEMA
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

-- 1.5 Luuakse eraldi DBA administraatori kasutaja DBA_ADMIN (vältimaks SYS kasutamist igapäevaselt)
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
END;
/

-- 2. Luuakse DB kasutaja TEST_DEV ja määratakse profiilikohased rollid
DECLARE
  v_user_exists NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_user_exists FROM dba_users WHERE username = 'TEST_DEV';
  IF v_user_exists = 0 THEN
    EXECUTE IMMEDIATE 'CREATE USER TEST_DEV IDENTIFIED BY "${TEST_DEV_PASSWORD}"';
  ELSE
    BEGIN
      EXECUTE IMMEDIATE 'ALTER USER TEST_DEV IDENTIFIED BY "${TEST_DEV_PASSWORD}"';
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
  END IF;
  EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO TEST_DEV';
  EXECUTE IMMEDIATE 'GRANT DB_DEVELOPER_ROLE TO TEST_DEV';
  BEGIN
    EXECUTE IMMEDIATE 'GRANT CONSOLE_DEVELOPER, DWROLE, RESOURCE TO TEST_DEV';
  EXCEPTION WHEN OTHERS THEN NULL;
  END;
  EXECUTE IMMEDIATE 'ALTER USER TEST_DEV DEFAULT TABLESPACE USERS TEMPORARY TABLESPACE TEMP QUOTA UNLIMITED ON USERS';

  -- Lubatakse ORDS REST / SQL Developer Web liides (kui ORDS on paigaldatud)
  BEGIN
    EXECUTE IMMEDIATE 'BEGIN
      ORDS.ENABLE_SCHEMA(
          p_enabled             => TRUE,
          p_schema              => ''TEST_DEV'',
          p_url_mapping_type    => ''BASE_PATH'',
          p_url_mapping_pattern => ''test_dev'',
          p_auto_rest_auth      => FALSE
      );
    END;';
  EXCEPTION WHEN OTHERS THEN NULL;
  END;
END;
/

-- 3. Luuakse piiratud tava/test vaataja kasutaja TEST_VIEWER (kõikide skeemide lugemisõigus)
DECLARE
  v_user_exists NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_user_exists FROM dba_users WHERE username = 'TEST_VIEWER';
  IF v_user_exists = 0 THEN
    EXECUTE IMMEDIATE 'CREATE USER TEST_VIEWER IDENTIFIED BY "${TEST_VIEWER_PASSWORD}"';
  ELSE
    BEGIN
      EXECUTE IMMEDIATE 'ALTER USER TEST_VIEWER IDENTIFIED BY "${TEST_VIEWER_PASSWORD}"';
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
  END IF;
  EXECUTE IMMEDIATE 'GRANT CREATE SESSION, SELECT ANY TABLE, SELECT ANY DICTIONARY TO TEST_VIEWER';
  BEGIN
    EXECUTE IMMEDIATE 'GRANT READ ANY TABLE TO TEST_VIEWER';
  EXCEPTION WHEN OTHERS THEN NULL;
  END;
  EXECUTE IMMEDIATE 'ALTER USER TEST_VIEWER DEFAULT TABLESPACE USERS TEMPORARY TABLESPACE TEMP';
END;
/

-- 4. Luuakse piiratud õigustega süsteemne aruandluse kasutaja PUBLISHER_READER (Analytics Publisher)
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

  -- Unlock APEX_PUBLIC_USER and APEX REST accounts for ORDS proxying
  BEGIN
    FOR u IN (SELECT username FROM dba_users WHERE username IN ('APEX_PUBLIC_USER', 'APEX_PUBLIC_ROUTER', 'APEX_LISTENER', 'APEX_REST_PUBLIC_USER')) LOOP
      BEGIN
        EXECUTE IMMEDIATE 'ALTER USER ' || u.username || ' IDENTIFIED BY "' || '${APEX_LISTENER_PASSWORD}' || '" ACCOUNT UNLOCK';
      EXCEPTION WHEN OTHERS THEN NULL;
      END;
    END LOOP;
    
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
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
  END;
  /

-- 2. Luuakse APEX kasutajad (ainult siis, kui APEX mootor on paigaldatud)
DECLARE
  v_apex_installed NUMBER := 0;
BEGIN
  SELECT COUNT(*) INTO v_apex_installed FROM dba_users WHERE username LIKE 'APEX_%';
  IF v_apex_installed > 0 THEN
    BEGIN
      EXECUTE IMMEDIATE '
      DECLARE
        v_workspace_id NUMBER;
        v_target_ws VARCHAR2(100) := ''${PROFILE_APEX_WORKSPACE:-PROXY_WORKSPACE}'';
      BEGIN
        v_workspace_id := APEX_UTIL.find_security_group_id(v_target_ws);
        IF v_workspace_id IS NULL OR v_workspace_id = 0 THEN
          v_workspace_id := APEX_UTIL.find_security_group_id(''PROXY_WORKSPACE'');
        END IF;
        IF v_workspace_id IS NULL OR v_workspace_id = 0 THEN
          v_workspace_id := APEX_UTIL.find_security_group_id(''BIZAPP_WORKSPACE'');
        END IF;
        IF v_workspace_id IS NOT NULL AND v_workspace_id != 0 THEN
          APEX_UTIL.set_security_group_id(v_workspace_id);
          
          BEGIN
            APEX_UTIL.remove_user(p_user_name => ''TEST_DEV'');
          EXCEPTION WHEN OTHERS THEN NULL;
          END;
          APEX_UTIL.create_user(
              p_user_name                    => ''TEST_DEV'',
              p_email_address                => ''test_dev@company.local'',
              p_web_password                 => ''${TEST_DEV_PASSWORD}'',
              p_developer_privs              => ''CREATE:DATA_LOADER:EDIT:HELP:MONITOR:VARIABLE'',
              p_change_password_on_first_use => ''N''
          );

          BEGIN
            APEX_UTIL.remove_user(p_user_name => ''TEST_VIEWER'');
          EXCEPTION WHEN OTHERS THEN NULL;
          END;
          APEX_UTIL.create_user(
              p_user_name                    => ''TEST_VIEWER'',
              p_email_address                => ''test_viewer@company.local'',
              p_web_password                 => ''${TEST_VIEWER_PASSWORD}'',
              p_developer_privs              => '''',
              p_change_password_on_first_use => ''N''
          );
        END IF;
      END;';
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
  END IF;
END;
/
EXIT;
EOF

  if podman container exists app-ords 2>/dev/null; then
    podman exec app-ords bash -c "for pool in \$(find /etc/ords/config/databases/ -name 'pool.xml' 2>/dev/null); do sed -i 's|<entry key=\"db.password\">.*</entry>|<entry key=\"db.password\">$APEX_LISTENER_PASSWORD</entry>|g' \"\$pool\" 2>/dev/null || true; done" 2>/dev/null || true
    podman restart app-ords >/dev/null 2>&1 || true
  fi

  echo "✅ Profiili kasutajad ja rollid on konfigureeritud."
}

if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
  apply_profile_users "$1"
fi
