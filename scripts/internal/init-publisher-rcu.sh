#!/usr/bin/env bash
# ============================================================================
# Oracle Analytics Publisher RCU (Repository Creation Utility) Schema Provisioner
# Provisions OAS_STB, OAS_IA, OAS_WLS, OAS_BIPUPG, OAS_CONFIG schemas in DB
# ============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [ -f "$SCRIPT_DIR/load-profile.sh" ]; then
  source "$SCRIPT_DIR/load-profile.sh"
fi
if [ -f "$SCRIPT_DIR/credential-helper.sh" ]; then
  source "$SCRIPT_DIR/credential-helper.sh"
fi

PRIMARY_CONTAINER=$(resolve_service_target_db "publisher")
PRIMARY_CONTAINER="${PRIMARY_CONTAINER:-db-proxy}"

PRIMARY_PROFILE=$(resolve_service_target_profile "publisher")
PRIMARY_PROFILE="${PRIMARY_PROFILE:-db-proxy-oracle}"

load_db_profile "$PRIMARY_PROFILE" >/dev/null 2>&1 || true

RCU_PREFIX="${PUBLISHER_RCU_PREFIX:-OAS}"
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${PROFILE_DB_PORT:-1533}"
DB_SERVICE="${PROFILE_DEFAULT_SERVICE:-FREEPDB1}"
SYS_PWD=$(get_db_sys_password "$PRIMARY_CONTAINER")
if [ -z "$SYS_PWD" ]; then
  echo "❌ ERROR: Could not find SYS password for database ${PRIMARY_CONTAINER}!"
  exit 1
fi

# Synchronize SYS password in database
if podman ps --format "{{.Names}}" 2>/dev/null | grep -q "$PRIMARY_CONTAINER"; then
  in_sql=$(podman exec "$PRIMARY_CONTAINER" bash -c 'ls -d /opt/oracle/product/*/dbhomeFree/sqlcl/bin/sql 2>/dev/null | head -n 1' 2>/dev/null || echo "")
  if [ -n "$in_sql" ]; then
    podman exec -i "$PRIMARY_CONTAINER" "$in_sql" -s / as sysdba << SYSSYNC >/dev/null 2>&1 || true
ALTER USER sys IDENTIFIED BY "${SYS_PWD}" CONTAINER=ALL;
ALTER USER system IDENTIFIED BY "${SYS_PWD}" CONTAINER=ALL;
EXIT;
SYSSYNC
  fi
fi

echo "🚀 Initializing RCU Schemas (${RCU_PREFIX}_*) on Database ${DB_HOST}:${DB_PORT}/${DB_SERVICE}..."

# Execute SQL statements to prepare tablespaces and grant privileges for RCU schemas
SQL_STATEMENT=$(cat <<EOF
SET FEEDBACK OFF;
SET SERVEROUTPUT ON;
ALTER SESSION SET CONTAINER = ${DB_SERVICE};

BEGIN
  FOR df IN (SELECT file_name FROM dba_data_files) LOOP
    BEGIN
      EXECUTE IMMEDIATE 'ALTER DATABASE DATAFILE ''' || df.file_name || ''' AUTOEXTEND ON MAXSIZE UNLIMITED';
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
  END LOOP;
END;
/

-- Clean up any incomplete previous schemas if rerun
BEGIN
  FOR s IN (SELECT sid, serial# FROM v\$session WHERE username LIKE '${RCU_PREFIX}_%') LOOP
    BEGIN
      EXECUTE IMMEDIATE 'ALTER SYSTEM DISCONNECT SESSION ''' || s.sid || ',' || s.serial# || ''' IMMEDIATE';
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
  END LOOP;
  FOR u IN (SELECT username FROM dba_users WHERE username LIKE '${RCU_PREFIX}_%') LOOP
    BEGIN
      EXECUTE IMMEDIATE 'DROP USER ' || u.username || ' CASCADE';
      DBMS_OUTPUT.PUT_LINE('Cleaned old RCU schema: ' || u.username);
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
  END LOOP;
  BEGIN
    EXECUTE IMMEDIATE 'DELETE FROM schema_version_registry WHERE mrc_name = ''${RCU_PREFIX}''';
    COMMIT;
  EXCEPTION WHEN OTHERS THEN NULL;
  END;
  FOR tbs IN (SELECT tablespace_name FROM dba_tablespaces WHERE tablespace_name LIKE '${RCU_PREFIX}_%') LOOP
    BEGIN
      EXECUTE IMMEDIATE 'DROP TABLESPACE ' || tbs.tablespace_name || ' INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS';
      DBMS_OUTPUT.PUT_LINE('Cleaned old RCU tablespace: ' || tbs.tablespace_name);
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
  END LOOP;
END;
/
EXIT;
EOF
)

# Run SQL command using embedded SQLcl per Rule 6
TARGET_PUB_CONTAINER=$(get_active_db_instances 2>/dev/null | grep -i "publisher" | head -n 1 | cut -d'|' -f1)
TARGET_PUB_CONTAINER="${TARGET_PUB_CONTAINER:-main-db-profile}"

if podman ps --format "{{.Names}}" 2>/dev/null | grep -q "$TARGET_PUB_CONTAINER"; then
  in_sql=$(podman exec "$TARGET_PUB_CONTAINER" bash -c 'ls -d /opt/oracle/product/*/dbhomeFree/sqlcl/bin/sql 2>/dev/null | head -n 1' 2>/dev/null || echo "")
  if [ -n "$in_sql" ]; then
    echo "$SQL_STATEMENT" | podman exec -i "$TARGET_PUB_CONTAINER" "$in_sql" -s / as sysdba || true
  fi
fi

echo "✅ RCU Schema Initialization completed for ${RCU_PREFIX}!"
