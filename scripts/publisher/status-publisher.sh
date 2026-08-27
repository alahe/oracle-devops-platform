#!/usr/bin/env bash
# ==============================================================================
# Status Check Script for Oracle Analytics Publisher & WebLogic Domain
# ==============================================================================
set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

CONTAINER_NAME="${PUBLISHER_CONTAINER_NAME:-app-publisher}"
ADMIN_PORT="${PUBLISHER_ADMIN_PORT:-9500}"
MANAGED_PORT="${PUBLISHER_PORT:-9502}"
DB_PORT="${DB_PORT:-1533}"

echo "======================================================================"
echo "📊 Oracle Analytics Publisher & WebLogic Status Check"
echo "======================================================================"

# 1. Container Status Check
if command -v podman >/dev/null 2>&1 && podman ps --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
  echo -e "1. Container (${CONTAINER_NAME}): ${GREEN}RUNNING (Podman)${NC}"
elif command -v docker >/dev/null 2>&1 && docker ps --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
  echo -e "1. Container (${CONTAINER_NAME}): ${GREEN}RUNNING (Docker)${NC}"
else
  echo -e "1. Container (${CONTAINER_NAME}): ${RED}NOT RUNNING${NC}"
fi

# 2. Database Connection Check (Port 1533)
if (exec 3<>/dev/tcp/localhost/"${DB_PORT}") 2>/dev/null; then
  echo -e "2. Database Connection (Port ${DB_PORT}): ${GREEN}ONLINE${NC}"
else
  echo -e "2. Database Connection (Port ${DB_PORT}): ${YELLOW}OFFLINE / UNREACHABLE${NC}"
fi

# 3. WebLogic AdminServer REST Check (Port 9500)
ADMIN_HTTP=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 3 "http://localhost:${ADMIN_PORT}/console/welcome" || echo "000")
if [[ "$ADMIN_HTTP" == "200" || "$ADMIN_HTTP" == "307" || "$ADMIN_HTTP" == "302" ]]; then
  echo -e "3. WebLogic AdminServer (Port ${ADMIN_PORT}): ${GREEN}ONLINE (HTTP ${ADMIN_HTTP})${NC}"
else
  echo -e "3. WebLogic AdminServer (Port ${ADMIN_PORT}): ${YELLOW}OFFLINE / INITIALIZING (HTTP ${ADMIN_HTTP})${NC}"
fi

# 4. Analytics Publisher UI & REST Check (Port 9502)
BIP_HTTP=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 3 "http://localhost:${MANAGED_PORT}/xmlpserver" || echo "000")
if [[ "$BIP_HTTP" == "200" || "$BIP_HTTP" == "302" ]]; then
  echo -e "4. Analytics Publisher UI (Port ${MANAGED_PORT}/xmlpserver): ${GREEN}ONLINE (HTTP ${BIP_HTTP})${NC}"
else
  echo -e "4. Analytics Publisher UI (Port ${MANAGED_PORT}/xmlpserver): ${YELLOW}OFFLINE / INITIALIZING (HTTP ${BIP_HTTP})${NC}"
fi

echo "======================================================================"
