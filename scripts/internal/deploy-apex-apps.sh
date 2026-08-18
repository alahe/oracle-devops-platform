#!/usr/bin/env bash
# ============================================================================
# APEX Application Deployment Script
# Automatically deploys SQL or APEXlang (.apex) applications from binaries/apex_apps/
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR/../.."


if [ -f ".env" ]; then
  set -a
  source ".env"
  set +a
fi

SYS_PWD="${APEX_DB_SYS_PASSWORD:-}"
if [ -z "$SYS_PWD" ]; then
  PRIMARY_CONTAINER=$(get_active_db_instances 2>/dev/null | head -n 1 | cut -d'|' -f1)
  PRIMARY_CONTAINER="${PRIMARY_CONTAINER:-db-dev-full}"
  if [ -n "$PRIMARY_CONTAINER" ] && podman container exists "$PRIMARY_CONTAINER" 2>/dev/null && [ "$(podman inspect --format='{{.State.Status}}' "$PRIMARY_CONTAINER" 2>/dev/null)" = "running" ]; then
    SYS_PWD=$(podman exec "$PRIMARY_CONTAINER" cat "/run/secrets/oracle_pwd" 2>/dev/null || podman exec "$PRIMARY_CONTAINER" cat "/run/secrets/apex_db_sys_password" 2>/dev/null || true)
  fi
  if [ -z "$SYS_PWD" ]; then
    SYS_PWD=$(podman secret inspect --showsecret apex_db_sys_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
  fi
  SYS_PWD="${SYS_PWD:-$APEX_DB_SYS_PASSWORD}"
fi
DB_HOST="${APEX_DB_HOST:-${PROFILE_DB_HOST:-localhost}}"
DB_PORT="${APEX_DB_PORT:-${PROFILE_DB_PORT:-1532}}"
DB_SERVICE="${APEX_DB_SERVICE:-${PROFILE_DEFAULT_SERVICE:-FREEPDB1}}"

IS_ADB=false
if [ "$APEX_DB_TYPE" = "ADB" ] || [[ "$APEX_DB_IMAGE" == *"adb-free"* ]]; then
  IS_ADB=true
fi

APPS_DIR="binaries/apex_apps"

if [ ! -d "$APPS_DIR" ]; then
  echo "📂 APEX rakenduste kaust puudub ($APPS_DIR). Midagi pole paigaldada."
  exit 0
fi

# Find all .sql and .apex files in APPS_DIR
FILES=$(find "$APPS_DIR" -type f \( -name "*.sql" -o -name "*.apex" \) | sort)

if [ -z "$FILES" ]; then
  echo "ℹ️  Kaustas $APPS_DIR ei leitud ühtegi .sql või .apex faili."
  exit 0
fi

SQLCL_CHECKED=false
SQLCL_FORCE_CONTAINER=false

run_sqlcl() {
  if [ "$SQLCL_FORCE_CONTAINER" = "false" ]; then
    local LOCAL_BIN=""
    if [ -n "$SQLCL_BIN" ]; then
      LOCAL_BIN="$SQLCL_BIN"
    elif command -v sql &> /dev/null; then
      LOCAL_BIN="sql"
    elif command -v sqlplus &> /dev/null; then
      LOCAL_BIN="sqlplus"
    fi
    
    if [ -n "$LOCAL_BIN" ]; then
      if [ "$SQLCL_CHECKED" = "false" ]; then
        SQLCL_CHECKED=true
        local TEST_CONN="/@DB_APEX_PROXY_SYS as sysdba"
        for arg in "$@"; do
          if [[ "$arg" == /@* ]]; then
            TEST_CONN="$arg"
            break
          fi
        done
        if ! "$LOCAL_BIN" -s "$TEST_CONN" <<EOF >/dev/null 2>&1
exit;
EOF
        then
          echo "=================================================================="
          echo "⚠️  HOIATUS: Kohalik CLI ($LOCAL_BIN) ei suutnud walleti abil ühenduda."
          echo "   Lülitun automaatselt ümber turvalise SQLcl konteineri fallbackile."
          echo "=================================================================="
          SQLCL_FORCE_CONTAINER=true
        fi
      fi
      
      if [ "$SQLCL_FORCE_CONTAINER" = "false" ]; then
        "$LOCAL_BIN" "$@"
        return $?
      fi
    fi
  fi

  local RUN_IMAGE="${SQLCL_CONTAINER_IMAGE:-container-registry.oracle.com/database/sqlcl:latest}"
  local PROJECT_NET="${PROJECT_NAME:-oracle-free-db-in-prod}_default"
  echo "⚠️  Käivitan APEX paigalduse läbi SQLcl konteineri ($RUN_IMAGE)..."
  podman run --rm -i --network="${PROJECT_NET}" \
    -v "${SCRIPT_DIR}/../..:/workspace" \

    -v "${SCRIPT_DIR}/../../config/tns_admin_container:/tns:ro" \
    -e JAVA_TOOL_OPTIONS="-Doracle.net.tns_admin=/tns -Doracle.net.wallet_location=(SOURCE=(METHOD=FILE)(METHOD_DATA=(DIRECTORY=/tns)))" \
    -e TNS_ADMIN=/tns \
    -w /workspace "$RUN_IMAGE" "$@"
}

echo "=================================================================="
echo "🚀 Alustan APEX rakenduste paigaldamist kaustast binaries/apex_apps/"
echo "=================================================================="

for file in $FILES; do
  FILENAME=$(basename "$file")
  echo "📦 Paigaldan rakendust: $FILENAME..."
  
  CONN_ARG="/@DB_APEX_PROXY_SYS as sysdba"
  if [ "$IS_ADB" = "true" ]; then
    CONN_ARG="/@DB_APEX_PROXY_SYS"
  fi

  run_sqlcl -s $CONN_ARG <<EOF
ALTER SESSION SET CONTAINER = FREEPDB1;

SET DEFINE OFF;
SET ECHO OFF;
SET SERVEROUTPUT ON SIZE UNLIMITED;

-- Set APEX workspace and schema context for the import
BEGIN
  wwv_flow_api.set_security_group_id(
    p_security_group_id => apex_util.find_security_group_id(p_workspace => 'PROXY_WORKSPACE')
  );
  apex_application_install.set_workspace_id(
    p_workspace_id => apex_util.find_security_group_id(p_workspace => 'PROXY_WORKSPACE')
  );
  apex_application_install.set_schema('APEX_PROXY_SCHEMA');
  apex_application_install.generate_offset;
END;
/

-- Run the installation script
@$file

COMMIT;
EXIT;
EOF

  echo "✅ Rakendus $FILENAME edukalt paigaldatud!"
  echo "------------------------------------------------------------------"
done

echo "=================================================================="
echo "🎉 Kõik APEX rakendused on edukalt paigaldatud!"
echo "=================================================================="
