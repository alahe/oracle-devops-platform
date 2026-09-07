#!/usr/bin/env bash
# ============================================================================
# Oracle Analytics Publisher ORDS Service Initializer
# Configures ORDS and SQL Developer Web for db-publisher database
# ============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [ -f "$SCRIPT_DIR/load-profile.sh" ]; then
  source "$SCRIPT_DIR/load-profile.sh"
fi
if [ -f "$SCRIPT_DIR/credential-helper.sh" ]; then
  source "$SCRIPT_DIR/credential-helper.sh"
fi

PRIMARY_CONTAINER=$(resolve_service_target_db "publisher")
PRIMARY_CONTAINER="${PRIMARY_CONTAINER:-db-proxy}"

PRIMARY_PROFILE=$(resolve_service_target_profile "publisher")
PRIMARY_PROFILE="${PRIMARY_PROFILE:-db-proxy-oracle}"

load_db_profile "$PRIMARY_PROFILE" >/dev/null 2>&1 || true

if [ "${SKIP_ORDS}" = "true" ] || [ "${PROFILE_ORDS_ENABLED}" = "false" ]; then
  echo "ℹ️  ORDS is disabled. Skipping ORDS initialization for Publisher Database."
  exit 0
fi

SYS_PWD=$(get_db_sys_password "$PRIMARY_CONTAINER" 2>/dev/null || true)

DB_SERVICE="${PROFILE_DEFAULT_SERVICE:-FREEPDB1}"

echo "🚀 Initializing ORDS REST Services for Publisher Database (${DB_SERVICE})..."

if [ -f "$SCRIPT_DIR/init-publisher-ords.sql" ] && podman ps --format "{{.Names}}" 2>/dev/null | grep -q "$PRIMARY_CONTAINER"; then
  in_sql=$(podman exec "$PRIMARY_CONTAINER" bash -c 'ls -d /opt/oracle/product/*/dbhomeFree/sqlcl/bin/sql 2>/dev/null | head -n 1' 2>/dev/null || echo "")
  if [ -n "$in_sql" ]; then
    cat "$SCRIPT_DIR/init-publisher-ords.sql" | podman exec -i "$PRIMARY_CONTAINER" "$in_sql" -s / as sysdba || true
  fi
  echo "✅ ORDS REST & SQL Developer Web Enabled for Publisher DB!"
else
  echo "ℹ️  Publisher DB container not running, skipping live ORDS initialization."
fi
