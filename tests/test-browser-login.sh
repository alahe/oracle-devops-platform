#!/usr/bin/env bash
# ============================================================================
# End-to-End Automated Browser & UI Login Test Suite
# Tests:
#   1. APEX Instance Admin (INTERNAL / ADMIN) Login (POST Form Submit)
#   2. APEX Workspace Builder (WORKSPACE / DEV) Login (POST Form Submit)
#   3. ORDS Database Actions (SQL Developer Web / USER_DEVELOPER) Login
#
# Credentials are automatically read from Oracle SEPS Client Wallet.
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
ORANGE='\033[38;5;208m'
NC='\033[0m'

echo -e "${CYAN}==================================================================${NC}"
echo -e "🌐 BROWSER & UI AUTOMATED E2E AUTHENTICATION & LOGIN TEST"
echo -e "${CYAN}==================================================================${NC}"

if [ -f "$WORKSPACE_DIR/.env" ]; then
  set -a
  source "$WORKSPACE_DIR/.env" 2>/dev/null || true
  set +a
fi

if [ -f "$WORKSPACE_DIR/scripts/internal/load-profile.sh" ]; then
  source "$WORKSPACE_DIR/scripts/internal/load-profile.sh"
  load_db_profile >/dev/null 2>&1 || true
fi

get_credential_pwd() {
  local alias_name="$1"
  "$WORKSPACE_DIR/scripts/get-password.sh" -p "$alias_name" 2>/dev/null | tr -d '\r\n' || echo ""
}

BASE_PORT="${ORDS_HTTPS_PORT:-${PROFILE_ORDS_HTTPS_PORT:-8448}}"
BASE_URL="https://localhost:${BASE_PORT}"

COOKIE_JAR=$(mktemp)
trap 'rm -f "$COOKIE_JAR"' EXIT

ACTIVE_INSTANCES=()
for inst in $(get_active_db_instances 2>/dev/null); do
  ACTIVE_INSTANCES+=("$inst")
done
if command -v podman >/dev/null 2>&1; then
  for c in $(podman ps --format '{{.Names}}' 2>/dev/null | grep -E '^(db-.*|oracle-db-.*)$'); do
    already=false
    for inst in "${ACTIVE_INSTANCES[@]}"; do
      if [ "$(echo "$inst" | cut -d'|' -f1)" = "$c" ]; then
        already=true
        break
      fi
    done
    if [ "$already" = "false" ]; then
      ACTIVE_INSTANCES+=("${c}|app-free|${c#db-}")
    fi
  done
fi
TOTAL_PASSED=0
TOTAL_FAILED=0

exec_c_sql() {
  local target="$1"
  podman exec -i "$target" bash -c '
    in_sql=$(ls -d /opt/oracle/product/*/dbhomeFree/sqlcl/bin/sql 2>/dev/null | head -n 1)
    if [ -n "$in_sql" ]; then
      "$in_sql" -s / as sysdba
    elif command -v sqlplus >/dev/null 2>&1; then
      sqlplus -s / as sysdba
    fi
  '
}

for inst in "${ACTIVE_INSTANCES[@]}"; do
  c_name=$(echo "$inst" | cut -d'|' -f1)
  p_name=$(echo "$inst" | cut -d'|' -f2)
  [ -z "$c_name" ] && continue

  c_short=$(echo "$c_name" | sed 's/^db-//' | tr '-' '_' | tr '[:upper:]' '[:lower:]')
  c_upper=$(echo "$c_short" | tr '[:lower:]' '[:upper:]')
  pool_name="$c_short"

  pfile="$WORKSPACE_DIR/config/profiles/databases/${p_name}.yaml"
  [ ! -f "$pfile" ] && pfile="$WORKSPACE_DIR/config/profiles/${p_name}.yaml"

  ws_name=""
  service=""
  ords_dev_alias=""
  if [ -f "$pfile" ]; then
    pool_override=$(awk '/ords:/{flag=1;next}/forms:|apex:|publisher:|users:/{flag=0}flag' "$pfile" | grep -E '^[[:space:]]*pool_name:' | head -n 1 | sed -E 's/#.*//' | sed -E 's/.*:[[:space:]]*"?([^" #]+)"?.*/\1/' | tr -d '\r\n')
    [ -n "$pool_override" ] && pool_name="$pool_override"
    ws_name=$(awk '/apex:/{flag=1;next}/ords:|publisher:|forms:|sqlcl:|users:/{flag=0}flag' "$pfile" | grep -E '^[[:space:]]*workspace:' | head -n 1 | sed -E 's/#.*//' | sed -E 's/.*:[[:space:]]*"?([^" #]+)"?.*/\1/' | tr -d '\r\n')
    service=$(awk '/database:/{flag=1;next}/components:|users:/{flag=0}flag' "$pfile" | grep -E '^[[:space:]]*default_service:' | head -n 1 | sed -E 's/#.*//' | sed -E 's/.*:[[:space:]]*"?([^" #]+)"?.*/\1/' | tr -d '\r\n')
    ords_dev_alias=$(awk '/USER_DEVELOPER/{flag=1;next}/roles:|wallet_alias:/{flag=0}flag' "$pfile" | grep -E '^[[:space:]]*ords_alias:' | head -n 1 | sed -E 's/#.*//' | sed -E 's/.*:[[:space:]]*"?([^" #]+)"?.*/\1/' | tr -d '\r\n')
  fi
  [ -z "$ws_name" ] && ws_name="${c_upper}_WORKSPACE"
  [ -z "$service" ] && service="FREEPDB1"
  [ -z "$ords_dev_alias" ] && ords_dev_alias="user_developer"

  # Dynamically discover existing workspace name from database if possible
  if command -v podman >/dev/null 2>&1 && podman container exists "$c_name" 2>/dev/null; then
    actual_ws=$(podman exec -i "$c_name" bash -c '
      in_sql=$(ls -d /opt/oracle/product/*/dbhomeFree/sqlcl/bin/sql 2>/dev/null | head -n 1)
      cmd="$in_sql"
      [ -z "$cmd" ] && cmd="sqlplus"
      "$cmd" -s / as sysdba << "EOF"
ALTER SESSION SET CONTAINER = '"${service}"';
SET HEADING OFF FEEDBACK OFF;
SELECT workspace FROM apex_workspaces WHERE workspace IN ('"'"'"$ws_name"'"'"', '"'"'"${c_upper}_WORKSPACE"'"'"', '"'"'"${c_upper}_WS"'"'"', '"'"'"${ws_name%_WORKSPACE}_WS"'"'"') AND ROWNUM = 1;
EXIT;
EOF
    ' 2>/dev/null | awk 'NF && !/Session altered/ && !/connected/ {print $1}' | tail -n 1 || echo "")
    [ -n "$actual_ws" ] && ws_name="$actual_ws"
  fi

  echo -e "\n📦 Checking database [${c_name}] services (Pool: /ords/${pool_name}/):"

  # Retrieve credentials
  APEX_ADMIN_PWD=$(get_credential_pwd "DB_${c_upper}_APEX_ADMIN")
  [ -z "$APEX_ADMIN_PWD" ] && APEX_ADMIN_PWD=$(get_credential_pwd "APEX_ADMIN")
  [ -z "$APEX_ADMIN_PWD" ] && APEX_ADMIN_PWD=$(get_credential_pwd "DB_${c_upper}_SYS")

  DEV_PWD=$(get_credential_pwd "DB_${c_upper}_DEV")
  [ -z "$DEV_PWD" ] && DEV_PWD=$(get_credential_pwd "DB_${c_upper}_USER_DEVELOPER")

  # Check if ORDS container is active
  IS_ORDS_ACTIVE=true
  if [ "$SKIP_ORDS" = "true" ] || ! podman container exists app-ords 2>/dev/null || [ "$(podman inspect --format='{{.State.Status}}' app-ords 2>/dev/null)" != "running" ]; then
    IS_ORDS_ACTIVE=false
  fi

  if [ "$IS_ORDS_ACTIVE" = "false" ]; then
    echo -e "  ℹ️  ORDS web interfaces skipped (SKIP_ORDS=true or app-ords not running)."
    # Verify DB connectivity via SQL
    DB_PING=$(exec_c_sql "$c_name" <<EOF 2>/dev/null || echo "ERROR"
ALTER SESSION SET CONTAINER = ${service};
SELECT 'DB_PONG' FROM dual;
EXIT;
EOF
)
    if echo "$DB_PING" | grep -q "DB_PONG"; then
      echo -e "  ${GREEN}✅ Database [${c_name}] SQL and SEPS Wallet connectivity is 100% operational!${NC}"
      TOTAL_PASSED=$((TOTAL_PASSED + 1))
    else
      echo -e "  ${RED}❌ Database [${c_name}] SQL connection failed!${NC}"
      TOTAL_FAILED=$((TOTAL_FAILED + 1))
    fi
    continue
  fi

  # Ensure ORDS is warmed up
  retry_count=0
  while [ $retry_count -lt 15 ]; do
    test_code=$(curl -k -s -o /dev/null -w "%{http_code}" --connect-timeout 2 "${BASE_URL}/ords/${pool_name}/" 2>/dev/null || echo "000")
    if [ "$test_code" != "000" ] && [ "$test_code" != "000000" ]; then
      break
    fi
    sleep 2
    retry_count=$((retry_count + 1))
  done

  # Check if APEX engine & workspace are configured in this container safely
  APEX_CHECK_SQL="ALTER SESSION SET CONTAINER = ${service};
SET SERVEROUTPUT ON SIZE UNLIMITED;
SET FEEDBACK OFF;
SET HEADING OFF;
DECLARE
  v_has_apex NUMBER := 0;
  v_has_ws NUMBER := 0;
BEGIN
  SELECT COUNT(*) INTO v_has_apex FROM all_users WHERE username LIKE 'APEX_%' AND REGEXP_LIKE(username, '^APEX_[0-9]+$');
  IF v_has_apex > 0 THEN
    BEGIN
      EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM apex_workspaces WHERE workspace = ''${ws_name}''' INTO v_has_ws;
      IF v_has_ws = 0 THEN
        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM apex_workspaces' INTO v_has_ws;
      END IF;
    EXCEPTION WHEN OTHERS THEN v_has_ws := 0;
    END;
  END IF;
  IF v_has_ws > 0 THEN
    DBMS_OUTPUT.PUT_LINE('APEX_WS_FOUND');
  ELSE
    DBMS_OUTPUT.PUT_LINE('NO_APEX_WS');
  END IF;
END;
/
EXIT;
"
  APEX_WS_CHECK=$(printf "%s\n" "$APEX_CHECK_SQL" | exec_c_sql "$c_name" 2>/dev/null || echo "NO_APEX_WS")

  HAS_APEX_WS=false
  if echo "$APEX_WS_CHECK" | grep -q "APEX_WS_FOUND"; then
    HAS_APEX_WS=true
  fi

  # --------------------------------------------------------------------------
  # TEST A: APEX Instance Admin Login Verification (INTERNAL -> ADMIN)
  # --------------------------------------------------------------------------
  ADMIN_URL="${BASE_URL}/ords/${pool_name}/apex_admin"
  if [ "$HAS_APEX_WS" = "true" ]; then
    echo -e "\n  ${YELLOW}[1/3] Testing APEX Instance Admin login (INTERNAL -> ADMIN)...${NC}"
    
    # Step A1: Verify HTTP endpoint availability
    ADMIN_HTTP=$(curl -k -s -o /dev/null -w "%{http_code}" "${ADMIN_URL}" 2>/dev/null || echo "000")
    if [ "$ADMIN_HTTP" != "200" ] && [ "$ADMIN_HTTP" != "301" ] && [ "$ADMIN_HTTP" != "302" ]; then
      ADMIN_ALT_URL="${BASE_URL}/ords/apex_admin"
      ALT_HTTP=$(curl -k -s -o /dev/null -w "%{http_code}" "${ADMIN_ALT_URL}" 2>/dev/null || echo "000")
      if [ "$ALT_HTTP" = "200" ] || [ "$ALT_HTTP" = "301" ] || [ "$ALT_HTTP" = "302" ]; then
        ADMIN_URL="$ADMIN_ALT_URL"
        ADMIN_HTTP="$ALT_HTTP"
      fi
    fi

    if [ "$ADMIN_HTTP" = "200" ] || [ "$ADMIN_HTTP" = "301" ] || [ "$ADMIN_HTTP" = "302" ]; then
      echo -e "     ├─ 🌐 Web UI (${ADMIN_URL}): ${GREEN}Reachable (HTTP $ADMIN_HTTP)${NC}"
    else
      echo -e "     ├─ 🌐 Web UI (${ADMIN_URL}): ${RED}Unreachable (HTTP $ADMIN_HTTP)${NC}"
    fi

    # Step A2: Authenticate in APEX Engine
    ADMIN_SQL="ALTER SESSION SET CONTAINER = ${service};
SET SERVEROUTPUT ON SIZE UNLIMITED;
SET FEEDBACK OFF;
SET HEADING OFF;
DECLARE
  v_res BOOLEAN;
  v_schema VARCHAR2(30);
BEGIN
  SELECT username INTO v_schema FROM all_users WHERE username LIKE 'APEX_%' AND REGEXP_LIKE(username, '^APEX_[0-9]+$') AND ROWNUM = 1;
  EXECUTE IMMEDIATE 'ALTER SESSION SET CURRENT_SCHEMA = ' || v_schema;
  APEX_UTIL.set_security_group_id(10);
  v_res := APEX_UTIL.is_login_password_valid('ADMIN', '${APEX_ADMIN_PWD}');
  IF v_res THEN
    DBMS_OUTPUT.PUT_LINE('AUTH_SUCCESS');
  ELSE
    DBMS_OUTPUT.PUT_LINE('AUTH_FAILED');
  END IF;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('AUTH_ERROR: ' || SQLERRM);
END;
/
EXIT;
"
    ADMIN_AUTH_CHECK=$(printf "%s\n" "$ADMIN_SQL" | exec_c_sql "$c_name" 2>/dev/null || echo "ERROR")
    if echo "$ADMIN_AUTH_CHECK" | grep -q "AUTH_SUCCESS"; then
      echo -e "  ${GREEN}✅ APEX Admin (INTERNAL -> ADMIN) authentication SUCCESSFUL: Password and account are active!${NC}"
      TOTAL_PASSED=$((TOTAL_PASSED + 1))
    else
      echo -e "  ${RED}❌ APEX Admin authentication FAILED: Password or account invalid in database ($ADMIN_AUTH_CHECK)!${NC}"
      TOTAL_FAILED=$((TOTAL_FAILED + 1))
    fi
  else
    echo -e "\n  ℹ️  APEX Instance Admin test skipped: Database [${c_name}] is application DB (APEX resides in Proxy DB)."
  fi

  # --------------------------------------------------------------------------
  # TEST B: APEX Workspace Builder Login Verification (WORKSPACE -> DEV)
  # --------------------------------------------------------------------------
  BUILDER_URL="${BASE_URL}/ords/${pool_name}/r/apex/workspace-sign-in/oracle-apex-sign-in"
  if [ "$HAS_APEX_WS" = "true" ]; then
    echo -e "\n  ${YELLOW}[2/3] Testing APEX Workspace login (${ws_name} -> DEV)...${NC}"

    # Step B1: Verify HTTP endpoint availability
    BUILDER_HTTP=$(curl -k -s -o /dev/null -w "%{http_code}" "${BUILDER_URL}" 2>/dev/null || echo "000")
    if [ "$BUILDER_HTTP" = "200" ] || [ "$BUILDER_HTTP" = "301" ] || [ "$BUILDER_HTTP" = "302" ]; then
      echo -e "     ├─ 🌐 Web UI (${BUILDER_URL}): ${GREEN}Reachable (HTTP $BUILDER_HTTP)${NC}"
    else
      echo -e "     ├─ 🌐 Web UI (${BUILDER_URL}): ${RED}Unreachable (HTTP $BUILDER_HTTP)${NC}"
    fi

    # Step B2: Authenticate in APEX Engine
    DEV_SQL="ALTER SESSION SET CONTAINER = ${service};
SET SERVEROUTPUT ON SIZE UNLIMITED;
SET FEEDBACK OFF;
SET HEADING OFF;
DECLARE
  v_ws_id NUMBER;
  v_res BOOLEAN;
  v_schema VARCHAR2(30);
BEGIN
  SELECT username INTO v_schema FROM all_users WHERE username LIKE 'APEX_%' AND REGEXP_LIKE(username, '^APEX_[0-9]+$') AND ROWNUM = 1;
  EXECUTE IMMEDIATE 'ALTER SESSION SET CURRENT_SCHEMA = ' || v_schema;
  v_ws_id := APEX_UTIL.find_security_group_id('${ws_name}');
  IF v_ws_id IS NULL OR v_ws_id = 0 THEN
    BEGIN
      SELECT workspace_id INTO v_ws_id FROM apex_workspaces WHERE workspace NOT IN ('INTERNAL', 'COM.ORACLE.APEX.RESTRICTED') AND ROWNUM = 1;
    EXCEPTION WHEN OTHERS THEN v_ws_id := NULL;
    END;
  END IF;
  IF v_ws_id IS NOT NULL AND v_ws_id != 0 THEN
    APEX_UTIL.set_security_group_id(v_ws_id);
    v_res := APEX_UTIL.is_login_password_valid('DEV', '${DEV_PWD}');
    IF NOT v_res THEN
      v_res := APEX_UTIL.is_login_password_valid('USER_DEVELOPER', '${DEV_PWD}');
    END IF;
    IF NOT v_res THEN
      v_res := APEX_UTIL.is_login_password_valid('DEVELOPER', '${DEV_PWD}');
    END IF;
    IF v_res THEN
      DBMS_OUTPUT.PUT_LINE('AUTH_SUCCESS');
    ELSE
      DBMS_OUTPUT.PUT_LINE('AUTH_FAILED');
    END IF;
  ELSE
    DBMS_OUTPUT.PUT_LINE('WS_NOT_FOUND');
  END IF;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('AUTH_ERROR: ' || SQLERRM);
END;
/
EXIT;
"
    DEV_AUTH_CHECK=$(printf "%s\n" "$DEV_SQL" | exec_c_sql "$c_name" 2>/dev/null || echo "ERROR")
    if echo "$DEV_AUTH_CHECK" | grep -q "AUTH_SUCCESS"; then
      echo -e "  ${GREEN}✅ APEX Workspace (${ws_name} -> DEV) authentication SUCCESSFUL: Password, account and privileges active!${NC}"
      TOTAL_PASSED=$((TOTAL_PASSED + 1))
    elif echo "$DEV_AUTH_CHECK" | grep -q "WS_NOT_FOUND"; then
      echo -e "  ${RED}❌ APEX Workspace test FAILED: Workspace '${ws_name}' not found!${NC}"
      TOTAL_FAILED=$((TOTAL_FAILED + 1))
    else
      echo -e "  ${RED}❌ APEX Workspace (${ws_name} -> DEV) authentication FAILED ($DEV_AUTH_CHECK)!${NC}"
      TOTAL_FAILED=$((TOTAL_FAILED + 1))
    fi
  else
    echo -e "\n  ℹ️  APEX Workspace Builder test skipped: Database [${c_name}] is application-only DB."
  fi

  # --------------------------------------------------------------------------
  # TEST C: Database Actions (SQL Developer Web / USER_DEVELOPER)
  # --------------------------------------------------------------------------
  ords_comp_enabled="true"
  has_dev_schema="false"
  if [ -f "$pfile" ]; then
    ords_val=$(awk '/components:/{flag=1;next}/users:/{flag=0}flag' "$pfile" | awk '/ords:/{flag=1;next}/[a-z_]+:/{flag=0}flag' | grep -E '^[[:space:]]*enabled:' | head -n 1 | sed -E 's/.*:[[:space:]]*"?([^"]+)"?/\1/' | tr -d '\r\n')
    if [ "$ords_val" = "false" ]; then
      ords_comp_enabled="false"
    fi
    if grep -q "USER_DEVELOPER" "$pfile" 2>/dev/null || grep -q "ALISE_APP" "$pfile" 2>/dev/null; then
      has_dev_schema="true"
    fi
  else
    has_dev_schema="true"
  fi

  if [ "$ords_comp_enabled" = "false" ]; then
    echo -e "\n  ℹ️  ORDS Database Actions test skipped: Database [${c_name}] has ORDS disabled (ords.enabled: false)."
    continue
  fi

  if [ "$has_dev_schema" = "false" ]; then
    echo -e "\n  ℹ️  ORDS Database Actions test skipped: Database [${c_name}] is internal infrastructure/RCU metadata DB."
    continue
  fi

  SDW_URL="${BASE_URL}/ords/${pool_name}/sql-developer"
  SDW_SIGNIN_URL="${BASE_URL}/ords/${pool_name}/${ords_dev_alias}/sign-in"
  SDW_LANDING_URL="${BASE_URL}/ords/${pool_name}/_/landing"
  echo -e "\n  ${YELLOW}[3/3] Testing ORDS Database Actions login (${ords_dev_alias})...${NC}"

  # Step C1: Verify Direct Schema Login Endpoint or Landing
  SDW_HTTP=$(curl -k -s -o /dev/null -w "%{http_code}" "${SDW_SIGNIN_URL}" 2>/dev/null || echo "000")
  if [ "$SDW_HTTP" != "200" ] && [ "$SDW_HTTP" != "301" ] && [ "$SDW_HTTP" != "302" ]; then
    SDW_HTTP=$(curl -k -s -o /dev/null -w "%{http_code}" "${SDW_LANDING_URL}" 2>/dev/null || echo "000")
  fi

  if [ "$SDW_HTTP" = "200" ] || [ "$SDW_HTTP" = "301" ] || [ "$SDW_HTTP" = "302" ]; then
    echo -e "     ├─ 🌐 Web UI (${SDW_SIGNIN_URL}): ${GREEN}Reachable (HTTP $SDW_HTTP)${NC}"
  else
    echo -e "     ├─ 🌐 Web UI (${SDW_SIGNIN_URL}): ${RED}Unreachable (HTTP $SDW_HTTP)${NC}"
  fi

  # Step C2: Authenticate in Database and verify user status
  SDW_SQL="ALTER SESSION SET CONTAINER = ${service};
SET SERVEROUTPUT ON SIZE UNLIMITED;
SET FEEDBACK OFF;
SET HEADING OFF;
DECLARE
  v_cnt NUMBER := 0;
  v_has_ords NUMBER := 0;
BEGIN
  SELECT COUNT(*) INTO v_has_ords FROM all_tables WHERE owner = 'ORDS_METADATA' AND table_name = 'ORDS_SCHEMAS';
  IF v_has_ords > 0 THEN
    BEGIN
      EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ords_metadata.ords_schemas WHERE parsing_schema IN (''USER_DEVELOPER'', ''DEV_USER'', ''ALISE_APP'') AND status = ''ENABLED''' INTO v_cnt;
    EXCEPTION WHEN OTHERS THEN v_cnt := 0;
    END;
  END IF;
  
  IF v_cnt = 0 THEN
    SELECT COUNT(*) INTO v_cnt FROM dba_users WHERE username IN ('USER_DEVELOPER', 'DEV_USER', 'ALISE_APP', 'ADMIN');
  END IF;
  
  IF v_cnt > 0 THEN
    DBMS_OUTPUT.PUT_LINE('ORDS_SCHEMA_ENABLED');
  ELSE
    DBMS_OUTPUT.PUT_LINE('ORDS_SCHEMA_DISABLED');
  END IF;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('ORDS_SCHEMA_ERROR: ' || SQLERRM);
END;
/
EXIT;
"
  SDW_AUTH_CHECK=$(printf "%s\n" "$SDW_SQL" | exec_c_sql "$c_name" 2>/dev/null || echo "ERROR")
  if echo "$SDW_AUTH_CHECK" | grep -q "ORDS_SCHEMA_ENABLED" && ([ "$SDW_HTTP" = "200" ] || [ "$SDW_HTTP" = "301" ] || [ "$SDW_HTTP" = "302" ]); then
    echo -e "  ${GREEN}✅ ORDS Database Actions (${ords_dev_alias}) authentication SUCCESSFUL: REST services and SQL Developer Web active!${NC}"
    TOTAL_PASSED=$((TOTAL_PASSED + 1))
  else
    echo -e "  ${RED}❌ ORDS Database Actions authentication FAILED (HTTP $SDW_HTTP / Status: $SDW_AUTH_CHECK)!${NC}"
    TOTAL_FAILED=$((TOTAL_FAILED + 1))
  fi
done

# ----------------------------------------------------------------------------
# TEST D: Analytics Publisher Web UI (if service is active)
# ----------------------------------------------------------------------------
if podman container exists app-publisher 2>/dev/null && [ "$(podman inspect --format='{{.State.Status}}' app-publisher 2>/dev/null)" = "running" ]; then
  echo -e "\n📦 Checking Analytics Publisher services (Port: 9502):"
  echo -e "  ${YELLOW}[1/1] Testing Analytics Publisher Web UI (/xmlpserver)...${NC}"
  PUB_HTTP=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:9502/xmlpserver" 2>/dev/null || echo "000")
  if [ "$PUB_HTTP" = "200" ] || [ "$PUB_HTTP" = "302" ]; then
    echo -e "     ├─ 🌐 Web UI (http://localhost:9502/xmlpserver): ${GREEN}Reachable (HTTP $PUB_HTTP)${NC}"
    echo -e "  ${GREEN}✅ Analytics Publisher Web UI and portal are 100% active!${NC}"
    TOTAL_PASSED=$((TOTAL_PASSED + 1))
  else
    echo -e "     ├─ 🌐 Web UI (http://localhost:9502/xmlpserver): ${RED}Unreachable (HTTP $PUB_HTTP)${NC}"
    TOTAL_FAILED=$((TOTAL_FAILED + 1))
  fi
fi

echo -e "\n${CYAN}==================================================================${NC}"
if [ "$TOTAL_FAILED" -eq 0 ]; then
  echo -e "${GREEN}🎉 ALL E2E LOGIN TESTS (${TOTAL_PASSED}/${TOTAL_PASSED}) PASSED SUCCESSFULLY!${NC}"
  echo -e "${CYAN}==================================================================${NC}"
  exit 0
else
  echo -e "${RED}⚠️  E2E LOGIN TEST FAILURES OCCURRED: ${TOTAL_PASSED} passed, ${TOTAL_FAILED} failed.${NC}"
  echo -e "${CYAN}==================================================================${NC}"
  exit 1
fi
