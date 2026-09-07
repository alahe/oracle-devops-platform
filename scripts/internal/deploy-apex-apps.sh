#!/usr/bin/env bash
# ============================================================================
# APEX Application Deployment Script
# Automatically deploys SQL or APEXlang (.apex) applications from binaries/apex_apps/
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$WORKSPACE_DIR"

if [ -f "$SCRIPT_DIR/load-profile.sh" ]; then
  source "$SCRIPT_DIR/load-profile.sh"
  resolve_active_blueprint 2>/dev/null || true
  load_db_profile >/dev/null 2>&1 || true
elif [ -f ".env" ]; then
  set -a
  source ".env"
  set +a
fi

SYS_PWD="${APEX_DB_SYS_PASSWORD:-}"
if [ -z "$SYS_PWD" ]; then
  PRIMARY_CONTAINER=$(get_active_db_instances 2>/dev/null | head -n 1 | cut -d'|' -f1)
  PRIMARY_CONTAINER="${PRIMARY_CONTAINER:-db-proxy}"
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
mkdir -p "$APPS_DIR"

# 1. Otsime deklaratiivsed APEXlang rakendused (applications/*/application.apx)
APEXLANG_APPS=()
if [ -d "applications" ]; then
  for d in applications/*; do
    if [ -d "$d" ] && [ -f "$d/application.apx" ]; then
      APEXLANG_APPS+=("$d")
    fi
  done
fi

# 2. Otsime klassikalised .sql ja .apex failid kaustast binaries/apex_apps
LEGACY_FILES=()
if [ -d "$APPS_DIR" ]; then
  while IFS= read -r f; do
    [ -n "$f" ] && LEGACY_FILES+=("$f")
  done < <(find "$APPS_DIR" -type f \( -name "*.sql" -o -name "*.apex" \) 2>/dev/null | sort)
fi

if [ ${#APEXLANG_APPS[@]} -eq 0 ] && [ ${#LEGACY_FILES[@]} -eq 0 ]; then
  echo "ℹ️  No APEX applications found to deploy (checked applications/ and $APPS_DIR/)."
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
          echo "⚠️  WARNING: Local CLI ($LOCAL_BIN) could not connect using wallet."
          echo "   Switching automatically to secure ephemeral SQLcl container fallback."
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
  echo "⚠️  Executing APEX deployment via SQLcl container ($RUN_IMAGE)..."
  podman run --rm -i --network="${PROJECT_NET}" \
    -v "${SCRIPT_DIR}/../..:/workspace" \
    -v "${SCRIPT_DIR}/../../config/tns_admin_container:/tns:ro" \
    -e JAVA_TOOL_OPTIONS="-Doracle.net.tns_admin=/tns -Doracle.net.wallet_location=(SOURCE=(METHOD=FILE)(METHOD_DATA=(DIRECTORY=/tns)))" \
    -e TNS_ADMIN=/tns \
    -w /workspace "$RUN_IMAGE" "$@"
}

echo "=================================================================="
echo "🚀 Starting APEX applications deployment"
echo "   APEXlang rakendusi leitud: ${#APEXLANG_APPS[@]}"
echo "   SQL pakette leitud:        ${#LEGACY_FILES[@]}"
echo "=================================================================="

PRIMARY_UPPER=$(echo "$PRIMARY_CONTAINER" | sed 's/^db-//' | tr '-' '_' | tr '[:lower:]' '[:upper:]')
CONN_ARG="/@DB_${PRIMARY_UPPER}_SYS as sysdba"
if [ "$IS_ADB" = "true" ]; then
  CONN_ARG="/@DB_${PRIMARY_UPPER}_SYS"
fi

TARGET_WS="${PROFILE_APEX_WORKSPACE:-PROXY_WORKSPACE}"

# 1. Deklaratiivsete APEXlang rakenduste paigaldamine
for app_dir in "${APEXLANG_APPS[@]}"; do
  APP_NAME=$(basename "$app_dir")
  APP_ID=$(grep -E '^[[:space:]]*id:[[:space:]]*[0-9]+' "$app_dir/application.apx" | head -n 1 | awk '{print $2}')
  APP_ID="${APP_ID:-101}"
  echo "📦 Deploying declarative APEXlang application: $APP_NAME (ID: $APP_ID) into $TARGET_WS..."
  
  # Ensure target workspace exists
  run_sqlcl -s $CONN_ARG <<EOF >/dev/null 2>&1
ALTER SESSION SET CONTAINER = ${DB_SERVICE};
BEGIN
  APEX_INSTANCE_ADMIN.ADD_WORKSPACE(
    p_workspace => '${TARGET_WS}',
    p_primary_schema => 'DEVHUB'
  );
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
EXIT;
EOF

  # 1.1 CI/CD Quality Gate: Validate APEXlang application structure
  echo "🔍 [Quality Gate]: Validating $APP_NAME syntax and AST..."
  VAL_OUTPUT=$(run_sqlcl -s $CONN_ARG <<EOF 2>&1
ALTER SESSION SET CONTAINER = ${DB_SERVICE};
apex validate -input ./$app_dir -workspace ${TARGET_WS}
EXIT;
EOF
)

  if echo "$VAL_OUTPUT" | grep -E "Compile Errors|INVALID_PROPERTY|COMPONENT_NOT_FOUND|MISSING_REQUIRED_PROPERTY|SYNTAX" >/dev/null; then
    echo "❌ ERROR: APEXlang validation failed for application $APP_NAME!"
    echo "$VAL_OUTPUT" | grep -A 3 -E "Compile Errors|Type:|Error:" | head -n 30
    echo "   Aborting deployment of $APP_NAME to protect workspace $TARGET_WS."
    exit 1
  fi
  echo "   ✅ Validation successful for $APP_NAME."

  # 1.2 CI/CD Deploy: Import validated application
  echo "🚀 [Deploy]: Importing application $APP_NAME (ID: $APP_ID) into $TARGET_WS..."
  run_sqlcl -s $CONN_ARG <<EOF
ALTER SESSION SET CONTAINER = ${DB_SERVICE};
apex import -input ./$app_dir -id ${APP_ID} -workspace ${TARGET_WS}
EXIT;
EOF

  echo "✅ APEXlang application $APP_NAME (ID: $APP_ID) deployment completed."
  echo "------------------------------------------------------------------"
done

# 2. Klassikaliste .sql / .apex pakettide paigaldamine
for file in "${LEGACY_FILES[@]}"; do
  FILENAME=$(basename "$file")
  echo "📦 Deploying legacy application package: $FILENAME..."

  run_sqlcl -s $CONN_ARG <<EOF
ALTER SESSION SET CONTAINER = ${DB_SERVICE};

SET DEFINE OFF;
SET ECHO OFF;
SET SERVEROUTPUT ON SIZE UNLIMITED;

-- Set APEX workspace and schema context for the import
BEGIN
  wwv_flow_api.set_security_group_id(
    p_security_group_id => apex_util.find_security_group_id(p_workspace => '${TARGET_WS}')
  );
  apex_application_install.set_workspace_id(
    p_security_group_id => apex_util.find_security_group_id(p_workspace => '${TARGET_WS}')
  );
  apex_application_install.set_schema('APEX_PROXY_SCHEMA');
  apex_application_install.generate_offset;
END;
/

PROMPT >>> Importing $FILENAME...
@$file

COMMIT;
EXIT;
EOF

  echo "✅ Application $FILENAME deployment completed."
  echo "------------------------------------------------------------------"
done

echo "=================================================================="
echo "🎉 All APEX applications have been deployed successfully!"
echo "=================================================================="
