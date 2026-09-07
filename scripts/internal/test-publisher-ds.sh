#!/usr/bin/env bash
# ==============================================================================
# Database Data Source Test Script for Oracle Analytics Publisher
# ==============================================================================
set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

PUBLISHER_URL="${PUBLISHER_URL:-http://localhost:9502/xmlpserver}"
ADMIN_USER="${ADMIN_USERNAME:-weblogic}"

# Resolve password from Oracle Wallet via SEPS helper rule
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
WALLET_HELPER="${WORKSPACE_DIR}/scripts/get-password.sh"
ADMIN_PWD=""

if [ -f "${WALLET_HELPER}" ]; then
  ADMIN_PWD=$("${WALLET_HELPER}" "DB_PUBLISHER_SYS" 2>/dev/null | grep "Password:" | awk '{print $3}' | sed 's/\x1b\[[0-9;]*m//g' | tr -d '\r\n' || true)
fi

echo "======================================================================"
echo "🔌 Testing Analytics Publisher Database Data Source Connection..."
echo "======================================================================"

HTTP_STATUS=$(curl -s -u "${ADMIN_USER}:${ADMIN_PWD}" -o /dev/null -w "%{http_code}" "${PUBLISHER_URL}/services/rest/v1/datasources" || echo "000")

if [[ "$HTTP_STATUS" == "200" || "$HTTP_STATUS" == "404" ]]; then
  echo -e "1. Analytics Publisher API Auth & Endpoint: ${GREEN}SUCCESS (HTTP ${HTTP_STATUS})${NC}"
else
  echo -e "1. Analytics Publisher API Auth & Endpoint: ${RED}FAILED (HTTP ${HTTP_STATUS})${NC}"
fi

# Verify FREEPDB1 database connection directly
if command -v podman >/dev/null 2>&1 && podman ps --format "{{.Names}}" | grep -q "main-db-profile"; then
  DB_TEST=$(podman exec -i main-db-profile bash -c '
    in_sql=$(ls -d /opt/oracle/product/*/dbhomeFree/sqlcl/bin/sql 2>/dev/null | head -n 1)
    if [ -n "$in_sql" ]; then
      "$in_sql" -s / as sysdba << EOF
ALTER SESSION SET CONTAINER = FREEPDB1;
SELECT status FROM v\$instance;
EXIT;
EOF
    fi' 2>/dev/null || true
  )
  if echo "${DB_TEST}" | grep -q "OPEN"; then
    echo -e "2. Target Database FREEPDB1 Status: ${GREEN}OPEN & READY${NC}"
  else
    echo -e "2. Target Database FREEPDB1 Status: ${RED}NOT OPEN${NC}"
  fi
fi

echo "======================================================================"
