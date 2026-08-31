#!/usr/bin/env bash
# ============================================================================
# Oracle Forms 14c RCU (Repository Creation Utility) Schema Provisioner
# Provisions FORMS_STB, FORMS_OPSS, FORMS_IAU, FORMS_WLS, FORMS_UCS schemas in DB
# ============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [ -f "$SCRIPT_DIR/i18n.sh" ]; then
  source "$SCRIPT_DIR/i18n.sh"
fi
if [ -f "$SCRIPT_DIR/load-profile.sh" ]; then
  source "$SCRIPT_DIR/load-profile.sh"
fi
if [ -f "$SCRIPT_DIR/credential-helper.sh" ]; then
  source "$SCRIPT_DIR/credential-helper.sh"
fi

PRIMARY_CONTAINER=$(resolve_service_target_db "forms")
PRIMARY_CONTAINER="${PRIMARY_CONTAINER:-db-proxy}"
PRIMARY_PROFILE=$(resolve_service_target_profile "forms")
PRIMARY_PROFILE="${PRIMARY_PROFILE:-db-proxy-oracle}"

load_db_profile "$PRIMARY_PROFILE" >/dev/null 2>&1 || true

RCU_PREFIX="${FORMS_RCU_PREFIX:-FORMS}"
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${PROFILE_DB_PORT:-1534}"
DB_SERVICE="${PROFILE_DEFAULT_SERVICE:-FREEPDB1}"

SYS_PWD=$(get_db_sys_password "$PRIMARY_CONTAINER")
if [ -z "$SYS_PWD" ]; then
  echo "❌ VIGA: Ei suutnud leida SYS parooli andmebaasile ${PRIMARY_CONTAINER}!"
  exit 1
fi

# Tagame SYS ja SYSTEM paroolide sünkroonsuse
if podman container exists "$PRIMARY_CONTAINER" 2>/dev/null && [ "$(podman inspect --format='{{.State.Status}}' "$PRIMARY_CONTAINER" 2>/dev/null)" = "running" ]; then
  podman exec -i "$PRIMARY_CONTAINER" sh -c "sqlplus -S / as sysdba" << SYSSYNC >/dev/null 2>&1 || true
ALTER USER sys IDENTIFIED BY "${SYS_PWD}" CONTAINER=ALL;
ALTER USER system IDENTIFIED BY "${SYS_PWD}" CONTAINER=ALL;
EXIT;
SYSSYNC
fi

echo "🚀 Initializing Oracle Forms 14c RCU Schemas (${RCU_PREFIX}_*) on Database ${DB_HOST}:${DB_PORT}/${DB_SERVICE}..."

TMP_SQL="/tmp/init_forms_rcu_$$.sql"
cat << 'SQL_BLOCK' > "$TMP_SQL"
SET FEEDBACK OFF;
SET SERVEROUTPUT ON;
ALTER SESSION SET CONTAINER = FREEPDB1;

DECLARE
  v_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_count FROM dba_users WHERE username = 'FORMS_STB';
  IF v_count = 0 THEN
    EXECUTE IMMEDIATE 'CREATE USER FORMS_STB IDENTIFIED BY "Welcome1_Forms_2026" DEFAULT TABLESPACE USERS QUOTA UNLIMITED ON USERS';
  END IF;
  EXECUTE IMMEDIATE 'GRANT CREATE SESSION, CONNECT, RESOURCE, DBA TO FORMS_STB';

  SELECT COUNT(*) INTO v_count FROM dba_users WHERE username = 'FORMS_OPSS';
  IF v_count = 0 THEN
    EXECUTE IMMEDIATE 'CREATE USER FORMS_OPSS IDENTIFIED BY "Welcome1_Forms_2026" DEFAULT TABLESPACE USERS QUOTA UNLIMITED ON USERS';
  END IF;
  EXECUTE IMMEDIATE 'GRANT CREATE SESSION, CONNECT, RESOURCE, DBA TO FORMS_OPSS';

  SELECT COUNT(*) INTO v_count FROM dba_users WHERE username = 'FORMS_WLS';
  IF v_count = 0 THEN
    EXECUTE IMMEDIATE 'CREATE USER FORMS_WLS IDENTIFIED BY "Welcome1_Forms_2026" DEFAULT TABLESPACE USERS QUOTA UNLIMITED ON USERS';
  END IF;
  EXECUTE IMMEDIATE 'GRANT CREATE SESSION, CONNECT, RESOURCE, DBA TO FORMS_WLS';

  SELECT COUNT(*) INTO v_count FROM dba_users WHERE username = 'FORMS_SCHEMA';
  IF v_count = 0 THEN
    EXECUTE IMMEDIATE 'CREATE USER FORMS_SCHEMA IDENTIFIED BY "Welcome1_Forms_2026" DEFAULT TABLESPACE USERS QUOTA UNLIMITED ON USERS';
  END IF;
  EXECUTE IMMEDIATE 'GRANT CREATE SESSION, CONNECT, RESOURCE, CREATE TABLE, CREATE VIEW, CREATE PROCEDURE, CREATE SEQUENCE TO FORMS_SCHEMA';

  SELECT COUNT(*) INTO v_count FROM dba_users WHERE username = 'FORMS_DEV';
  IF v_count = 0 THEN
    EXECUTE IMMEDIATE 'CREATE USER FORMS_DEV IDENTIFIED BY "Welcome1_Forms_2026" DEFAULT TABLESPACE USERS QUOTA UNLIMITED ON USERS';
  END IF;
  EXECUTE IMMEDIATE 'GRANT CREATE SESSION, CONNECT, RESOURCE TO FORMS_DEV';
  EXECUTE IMMEDIATE 'GRANT UNLIMITED TABLESPACE TO FORMS_DEV';
END;
/
EXIT;
SQL_BLOCK

if podman container exists "$PRIMARY_CONTAINER" 2>/dev/null && [ "$(podman inspect --format='{{.State.Status}}' "$PRIMARY_CONTAINER" 2>/dev/null)" = "running" ]; then
  podman exec -i "$PRIMARY_CONTAINER" sqlplus -s "sys/${SYS_PWD}@localhost:1521/${DB_SERVICE} as sysdba" < "$TMP_SQL" >/dev/null 2>&1 || true
  echo "✅ Forms 14c RCU schemas successfully initialized inside container ${PRIMARY_CONTAINER}!"
else
  echo "⚠️  $(msg_str "FORMS_RCU_CONTAINER_OFFLINE" "$PRIMARY_CONTAINER")"
fi
rm -f "$TMP_SQL"
