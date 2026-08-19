#!/usr/bin/env bash
# ============================================================================
# Topology & Port Collision Resolver
# Resolves instance topologies, container names, volume mounts, and non-clashing ports
# ============================================================================

set -e

_LOCAL_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$_LOCAL_SCRIPT_DIR/../.." && pwd)"

# Source load-db-profile helper
source "$_LOCAL_SCRIPT_DIR/load-profile.sh"

TOPOLOGY_FILE="$WORKSPACE_DIR/config/topology.yaml"

# Check if a port is currently open on host
is_port_in_use() {
  local port="$1"
  if command -v lsof &>/dev/null; then
    lsof -i :"$port" &>/dev/null
  elif command -v nc &>/dev/null; then
    nc -z localhost "$port" &>/dev/null
  else
    return 1
  fi
}

resolve_instance_ports() {
  local base_db_port="$1"
  local base_https_port="$2"
  local base_http_port="$3"
  local offset="$4"

  local target_db_port=$((base_db_port + offset))
  local target_https_port=$((base_https_port + offset))
  local target_http_port=$((base_http_port + offset))

  # Resolve DB listener port collision
  while is_port_in_use "$target_db_port"; do
    echo "⚠️  Port $target_db_port on hõivatud. Otsin järgmist vaba porti..."
    target_db_port=$((target_db_port + 1))
  done

  # Resolve HTTPS port collision
  while is_port_in_use "$target_https_port"; do
    echo "⚠️  Port $target_https_port on hõivatud. Otsin järgmist vaba porti..."
    target_https_port=$((target_https_port + 1))
  done

  export RESOLVED_DB_PORT="$target_db_port"
  export RESOLVED_HTTPS_PORT="$target_https_port"
  export RESOLVED_HTTP_PORT="$target_http_port"
}

resolve_topology() {
  echo "🌐 Kontrollin ja lahendan andmebaaside topoloogiat..."
  
  if [ -f "$TOPOLOGY_FILE" ]; then
    echo "📄 Kasutan topoloogia spetsifikatsiooni: ${TOPOLOGY_FILE}"
  fi

  # Default instance setup
  load_db_profile "${MAIN_DB_PROFILE:-proxy-adb-oracle}"
  
  local base_https=8448
  if [ "$IS_ADB" = "true" ]; then
    base_https=8443
  fi

  resolve_instance_ports "${PROFILE_DB_PORT:-1532}" "$base_https" 8088 0

  export WEB_IDE_HTTP_PORT="${WEB_IDE_HTTP_PORT:-8090}"
  export WEB_IDE_HTTPS_PORT="${WEB_IDE_HTTPS_PORT:-8449}"
  export CICD_WEB_UI_PORT="${CICD_WEB_UI_PORT:-8091}"

  echo "✅ Topoloogia portide kontroll teostatud:"
  echo "   - DB Port:       ${RESOLVED_DB_PORT}"
  echo "   - HTTPS Port:    ${RESOLVED_HTTPS_PORT}"
  echo "   - HTTP Port:     ${RESOLVED_HTTP_PORT}"
  echo "   - Web IDE Port:  ${WEB_IDE_HTTP_PORT}"
  echo "   - CI/CD UI Port: ${CICD_WEB_UI_PORT}"
}


if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
  resolve_topology
fi
