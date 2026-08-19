#!/usr/bin/env bash
# ============================================================================
# Profile-Driven Instance Initializer (init-db-instance.sh)
# Executes profile-driven database initialization and schema setup
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$SCRIPT_DIR/load-profile.sh"

init_db_instance() {
  local target_profile="${1:-${PROXY_DB:-${MAIN_DB_PROFILE:-proxy-adb-oracle}}}"
  local container_name="${2:-db-apex-proxy}"

  load_db_profile "$target_profile"

  echo "⚙️  Käivitan andmebaasi algseadistuse profiilile '${PROFILE_NAME}' (${container_name})..."

  if [ -f "$SCRIPT_DIR/init-db-instance.sql" ]; then
    run_sqlcl -s "$CONN_STR_SYS" @"$SCRIPT_DIR/init-db-instance.sql" >/dev/null 2>&1 || true
  fi

  # Apply profile users and roles
  if [ -x "$SCRIPT_DIR/apply-profile-users.sh" ]; then
    "$SCRIPT_DIR/apply-profile-users.sh" "$target_profile"
  fi

  echo "✅ Instants '${container_name}' (${PROFILE_NAME}) algseadistatud edukalt!"
}

if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
  init_db_instance "$1" "$2"
fi
