#!/usr/bin/env bash
# ==============================================================================
# Restart Script for Oracle Analytics Publisher & WebLogic Services
# ==============================================================================
set -euo pipefail

CONTAINER_NAME="${PUBLISHER_CONTAINER_NAME:-app-publisher}"
RUNTIME_ENGINE="${CONTAINER_ENGINE:-podman}"

echo "======================================================================"
echo "🔄 Restarting Oracle Analytics Publisher WebLogic Services..."
echo "======================================================================"

if ! "${RUNTIME_ENGINE}" ps --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
  echo "Error: Container ${CONTAINER_NAME} is not running."
  exit 1
fi

echo "1. Stopping WebLogic processes inside container..."
"${RUNTIME_ENGINE}" exec -i "${CONTAINER_NAME}" sh -c "pkill -f 'weblogic.Server' || true"
sleep 5

echo "2. Starting WebLogic AdminServer..."
"${RUNTIME_ENGINE}" exec -d "${CONTAINER_NAME}" sh -c "export USER_MEM_ARGS='-Xms512m -Xmx1536m -XX:MaxMetaspaceSize=512m'; nohup /u01/oracle/user_projects/domains/bi/bin/startWebLogic.sh > /u01/oracle/AdminServer.log 2>&1 &"

echo "3. Waiting for AdminServer to become ready..."
until "${RUNTIME_ENGINE}" exec -i "${CONTAINER_NAME}" curl -s http://localhost:9500/console/welcome >/dev/null 2>&1; do
  sleep 3
done

echo "4. Starting Managed Server bi_server1 (Analytics Publisher UI)..."
"${RUNTIME_ENGINE}" exec -d "${CONTAINER_NAME}" sh -c "export USER_MEM_ARGS='-Xms512m -Xmx1536m -XX:MaxMetaspaceSize=512m'; nohup /u01/oracle/user_projects/domains/bi/bin/startManagedWebLogic.sh bi_server1 http://localhost:9500 > /u01/oracle/bi_server1.log 2>&1 &"

echo "======================================================================"
echo "✅ Publisher WebLogic services restarted successfully!"
echo "======================================================================"
