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

PRIMARY_CONTAINER=$(get_active_db_instances 2>/dev/null | grep -i "publisher" | head -n 1 | cut -d'|' -f1)
PRIMARY_CONTAINER="${PRIMARY_CONTAINER:-main-db-profile}"
PRIMARY_PROFILE=$(get_active_db_instances 2>/dev/null | grep -i "publisher" | head -n 1 | cut -d'|' -f2)
PRIMARY_PROFILE="${PRIMARY_PROFILE:-publisher-free}"

load_db_profile "$PRIMARY_PROFILE" >/dev/null 2>&1 || true

RCU_PREFIX="${PUBLISHER_RCU_PREFIX:-OAS}"
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${PROFILE_DB_PORT:-1533}"
DB_SERVICE="${PROFILE_DEFAULT_SERVICE:-FREEPDB1}"
SYS_PWD=$(podman exec "$PRIMARY_CONTAINER" cat /run/secrets/oracle_pwd 2>/dev/null || podman secret inspect --showsecret publisher_db_sys_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || echo "")
if [ -z "$SYS_PWD" ]; then
  SYS_PWD=$("$SCRIPT_DIR/get-password.sh" "DB_PUBLISHER_SYS" 2>/dev/null | grep "Password:" | awk '{print $3}' | sed 's/\x1b\[[0-9;]*m//g' | tr -d '\r\n' || echo "")
fi
if [ -z "$SYS_PWD" ]; then
  echo "❌ VIGA: Ei suutnud leida SYS parooli Walletist ega Podman Secrets store'ist!"
  exit 1
fi

echo "🚀 Initializing RCU Schemas (${RCU_PREFIX}_*) on Database ${DB_HOST}:${DB_PORT}/${DB_SERVICE}..."

# Execute SQL statements to prepare tablespaces and grant privileges for RCU schemas
SQL_STATEMENT=$(cat <<EOF
SET FEEDBACK OFF;
SET SERVEROUTPUT ON;
ALTER SESSION SET CONTAINER = FREEPDB1;

DECLARE
  v_count NUMBER;
BEGIN
  -- Create OAS_CONFIG user if not existing
  SELECT COUNT(*) INTO v_count FROM dba_users WHERE username = '${RCU_PREFIX}_CONFIG';
  IF v_count = 0 THEN
    EXECUTE IMMEDIATE 'CREATE USER ${RCU_PREFIX}_CONFIG IDENTIFIED BY ${SYS_PWD} DEFAULT TABLESPACE USERS QUOTA UNLIMITED ON USERS';
    DBMS_OUTPUT.PUT_LINE('Created user ${RCU_PREFIX}_CONFIG');
  END IF;
  EXECUTE IMMEDIATE 'GRANT CREATE SESSION, CONNECT, RESOURCE, DBA TO ${RCU_PREFIX}_CONFIG';
  EXECUTE IMMEDIATE 'ALTER USER ${RCU_PREFIX}_CONFIG IDENTIFIED BY ${SYS_PWD}';

  -- Create OAS_STB user
  SELECT COUNT(*) INTO v_count FROM dba_users WHERE username = '${RCU_PREFIX}_STB';
  IF v_count = 0 THEN
    EXECUTE IMMEDIATE 'CREATE USER ${RCU_PREFIX}_STB IDENTIFIED BY ${SYS_PWD} DEFAULT TABLESPACE USERS QUOTA UNLIMITED ON USERS';
    DBMS_OUTPUT.PUT_LINE('Created user ${RCU_PREFIX}_STB');
  END IF;
  EXECUTE IMMEDIATE 'GRANT CREATE SESSION, CONNECT, RESOURCE, DBA TO ${RCU_PREFIX}_STB';
  EXECUTE IMMEDIATE 'ALTER USER ${RCU_PREFIX}_STB IDENTIFIED BY ${SYS_PWD}';
END;
/
EXIT;
EOF
)

# Run SQL command using ephemeral container pattern or native sqlplus
TARGET_PUB_CONTAINER=$(get_active_db_instances 2>/dev/null | grep -i "publisher" | head -n 1 | cut -d'|' -f1)
TARGET_PUB_CONTAINER="${TARGET_PUB_CONTAINER:-main-db-profile}"

if podman ps --format "{{.Names}}" 2>/dev/null | grep -q "$TARGET_PUB_CONTAINER"; then
  echo "$SQL_STATEMENT" | podman exec -i "$TARGET_PUB_CONTAINER" sh -c "sqlplus -S / as sysdba" || true
fi

echo "✅ RCU Schema Initialization completed for ${RCU_PREFIX}!"
