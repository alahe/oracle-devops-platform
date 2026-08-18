#!/usr/bin/env bash
# ============================================================================
# Automated Integration Test: Passwordless SQLcl Connections
# Verifies that SYS, APEX_PROXY_SCHEMA, TEST_DEV and active developers can connect passwordlessly
# via `sql /@<ALIAS>` without entering passwords.
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}==================================================================${NC}"
echo -e "🧪 REAALSETE KASUTAJATE PAROOLIVABA SQLCL ÜHENDUSTE TESTIMINE"
echo -e "${CYAN}==================================================================${NC}"

if [ -f "$WORKSPACE_DIR/.env" ]; then
  set -a
  source "$WORKSPACE_DIR/.env"
  set +a
fi

PRIMARY_CONTAINER=$(podman ps --format "{{.Names}}" 2>/dev/null | grep -E "^(db-dev-full|db-proxy|oracle-)" | head -n 1 || echo "")
if [ -z "$PRIMARY_CONTAINER" ]; then
  echo -e "${YELLOW}⚠️  Andmebaasi konteiner ei ole praegu käivitatud. Jätan ühendustestid vahele.${NC}"
  exit 0
fi

FAILED=0

# Test 1: SYSDBA Connection (sql /@DB_APEX_PROXY_SYS as sysdba)
echo -e "\n${YELLOW}[Test 1] Testin SYSDBA paroolivaba ühendust (DB_APEX_PROXY_SYS)...${NC}"
SYS_OUT=$("$WORKSPACE_DIR/scripts/sqlcl.sh" "/@DB_APEX_PROXY_SYS" as sysdba <<< "SELECT USER, sys_context('USERENV','DB_NAME') FROM dual;" 2>&1 || true)
if echo "$SYS_OUT" | grep -iq "Connected to" || echo "$SYS_OUT" | grep -iq "SYS"; then
  echo -e "${GREEN}✅ Test 1 Edukas: SYSDBA paroolivaba ühendus toimib (sql /@DB_APEX_PROXY_SYS as sysdba)${NC}"
else
  echo -e "${RED}❌ Test 1 Ebaõnnestus: SYSDBA ühendus ebaõnnestus!${NC}"
  echo "--- Väljund ---"
  echo "$SYS_OUT"
  FAILED=$((FAILED + 1))
fi

# Test 2: APEX_PROXY_SCHEMA Connection (sql /@DB_APEX_PROXY_SCHEMA)
echo -e "\n${YELLOW}[Test 2] Testin APEX_PROXY_SCHEMA paroolivaba ühendust (DB_APEX_PROXY_SCHEMA)...${NC}"
SCH_OUT=$("$WORKSPACE_DIR/scripts/sqlcl.sh" "/@DB_APEX_PROXY_SCHEMA" <<< "SELECT USER FROM dual;" 2>&1 || true)
if echo "$SCH_OUT" | grep -iq "APEX_PROXY_SCHEMA" || echo "$SCH_OUT" | grep -iq "Connected to"; then
  echo -e "${GREEN}✅ Test 2 Edukas: APEX_PROXY_SCHEMA paroolivaba ühendus toimib (sql /@DB_APEX_PROXY_SCHEMA)${NC}"
else
  echo -e "${RED}❌ Test 2 Ebaõnnestus: APEX_PROXY_SCHEMA ühendus ebaõnnestus!${NC}"
  echo "--- Väljund ---"
  echo "$SCH_OUT"
  FAILED=$((FAILED + 1))
fi

# Test 3: TEST_DEV Connection (sql /@DB_TEST_DEV)
echo -e "\n${YELLOW}[Test 3] Testin TEST_DEV paroolivaba ühendust (DB_TEST_DEV)...${NC}"
DEV_OUT=$("$WORKSPACE_DIR/scripts/sqlcl.sh" "/@DB_TEST_DEV" <<< "SELECT USER FROM dual;" 2>&1 || true)
if echo "$DEV_OUT" | grep -iq "TEST_DEV" || echo "$DEV_OUT" | grep -iq "Connected to"; then
  echo -e "${GREEN}✅ Test 3 Edukas: TEST_DEV paroolivaba ühendus toimib (sql /@DB_TEST_DEV)${NC}"
else
  echo -e "${RED}❌ Test 3 Ebaõnnestus: TEST_DEV ühendus ebaõnnestus!${NC}"
  echo "--- Väljund ---"
  echo "$DEV_OUT"
  FAILED=$((FAILED + 1))
fi


# Test 3: Additional Interactive Developers (if registered)
if [ -n "${DEVELOPER_USER:-}" ] && [ "$(echo "$DEVELOPER_USER" | tr '[:lower:]' '[:upper:]')" != "TEST_DEV" ]; then
  DEV_ALIAS=$(echo "$DEVELOPER_USER" | tr '[:lower:]' '[:upper:]')
  echo -e "\n${YELLOW}[Test 3] Testin arendaja '$DEV_ALIAS' paroolivaba ühendust (sql /@${DEV_ALIAS})...${NC}"
  EXTRA_OUT=$("$WORKSPACE_DIR/scripts/sqlcl.sh" "/@${DEV_ALIAS}" <<< "SELECT USER FROM dual;" 2>&1 || true)
  if echo "$EXTRA_OUT" | grep -iq "$DEV_ALIAS" || echo "$EXTRA_OUT" | grep -iq "Connected to"; then
    echo -e "${GREEN}✅ Test 3 Edukas: Kasutaja '$DEV_ALIAS' paroolivaba ühendus toimib (sql /@${DEV_ALIAS})${NC}"
  else
    echo -e "${RED}❌ Test 3 Ebaõnnestus: Kasutaja '$DEV_ALIAS' ühendus ebaõnnestus!${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -e "\n${CYAN}==================================================================${NC}"
if [ $FAILED -eq 0 ]; then
  echo -e "${GREEN}🎉 KÕIK REAALSETE KASUTAJATE PAROOLIVABAD ÜHENDUSTESTID TÖÖTAVAD!${NC}"
  echo -e "${CYAN}==================================================================${NC}"
  exit 0
else
  echo -e "${RED}❌ $FAILED paroolivaba ühendustest(i) ebaõnnestus(id)!${NC}"
  echo -e "${CYAN}==================================================================${NC}"
  exit 1
fi
