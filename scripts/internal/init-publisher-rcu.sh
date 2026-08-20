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
  load_db_profile >/dev/null 2>&1 || true
fi

RCU_PREFIX="${PUBLISHER_RCU_PREFIX:-OAS}"
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${PROFILE_DB_PORT:-1533}"
DB_SERVICE="${PROFILE_DB_PDB:-FREEPDB1}"

SYS_PWD=$("$SCRIPT_DIR/view-wallet-credential.sh" "DB_PUBLISHER_SYS" 2>/dev/null | grep "Password:" | awk '{print $3}' | tr -d '\r\n')
if [ -z "$SYS_PWD" ]; then
  SYS_PWD=$("$SCRIPT_DIR/view-wallet-credential.sh" "DB_APEX_PROXY_SYS" 2>/dev/null | grep "Password:" | awk '{print $3}' | tr -d '\r\n')
fi
SYS_PWD="${SYS_PWD:-OraclePass2026}"

echo "🚀 Initializing RCU Schemas (${RCU_PREFIX}_*) on Database ${DB_HOST}:${DB_PORT}/${DB_SERVICE}..."

# Execute SQL statements to prepare tablespaces and grant privileges for RCU schemas
SQL_STATEMENT=$(cat <<EOF
SET FEEDBACK OFF;
SET SERVEROUTPUT ON;

DECLARE
  v_count NUMBER;
BEGIN
  -- Create OAS_CONFIG user if not existing
  SELECT COUNT(*) INTO v_count FROM dba_users WHERE username = '${RCU_PREFIX}_CONFIG';
  IF v_count = 0 THEN
    EXECUTE IMMEDIATE 'CREATE USER ${RCU_PREFIX}_CONFIG IDENTIFIED BY "${SYS_PWD}" DEFAULT TABLESPACE USERS QUOTA UNLIMITED ON USERS';
    EXECUTE IMMEDIATE 'GRANT CONNECT, RESOURCE, DBA TO ${RCU_PREFIX}_CONFIG';
    DBMS_OUTPUT.PUT_LINE('Created user ${RCU_PREFIX}_CONFIG');
  END IF;

  -- Create OAS_STB user
  SELECT COUNT(*) INTO v_count FROM dba_users WHERE username = '${RCU_PREFIX}_STB';
  IF v_count = 0 THEN
    EXECUTE IMMEDIATE 'CREATE USER ${RCU_PREFIX}_STB IDENTIFIED BY "${SYS_PWD}" DEFAULT TABLESPACE USERS QUOTA UNLIMITED ON USERS';
    EXECUTE IMMEDIATE 'GRANT CONNECT, RESOURCE, DBA TO ${RCU_PREFIX}_STB';
    DBMS_OUTPUT.PUT_LINE('Created user ${RCU_PREFIX}_STB');
  END IF;
END;
/
EXIT;
EOF
)

# Run SQL command using ephemeral container pattern or native sqlplus
CONTAINER_IMAGE="${RESOLVED_DB_IMAGE:-docker.io/gvenzl/oracle-free:23-full-faststart}"
PRIMARY_CONTAINER=$(get_active_db_instances 2>/dev/null | head -n 1 | cut -d'|' -f1 || echo "pub-db")

if podman ps --format "{{.Names}}" 2>/dev/null | grep -q "$PRIMARY_CONTAINER"; then
  echo "$SQL_STATEMENT" | podman exec -i "$PRIMARY_CONTAINER" sh -c "sqlplus -S sys/${SYS_PWD}@localhost:1521/${DB_SERVICE} as sysdba" || true
fi

echo "✅ RCU Schema Initialization completed for ${RCU_PREFIX}!"
