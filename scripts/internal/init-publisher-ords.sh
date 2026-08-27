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

PRIMARY_CONTAINER=$(get_active_db_instances 2>/dev/null | grep -i "publisher" | head -n 1 | cut -d'|' -f1)
PRIMARY_CONTAINER="${PRIMARY_CONTAINER:-main-db-profile}"
PRIMARY_PROFILE=$(get_active_db_instances 2>/dev/null | grep -i "publisher" | head -n 1 | cut -d'|' -f2)
PRIMARY_PROFILE="${PRIMARY_PROFILE:-publisher-free}"

load_db_profile "$PRIMARY_PROFILE" >/dev/null 2>&1 || true

if [ "${SKIP_ORDS}" = "true" ] || [ "${PROFILE_ORDS_ENABLED}" = "false" ]; then
  echo "ℹ️  ORDS is disabled. Skipping ORDS initialization for Publisher Database."
  exit 0
fi

SYS_PWD=$(podman exec "$PRIMARY_CONTAINER" cat /run/secrets/oracle_pwd 2>/dev/null || podman secret inspect --showsecret publisher_db_sys_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || echo "")
if [ -z "$SYS_PWD" ]; then
  SYS_PWD=$("$SCRIPT_DIR/get-password.sh" "DB_PUBLISHER_SYS" 2>/dev/null | grep "Password:" | awk '{print $3}' | sed 's/\x1b\[[0-9;]*m//g' | tr -d '\r\n' || echo "")
fi

DB_SERVICE="${PROFILE_DEFAULT_SERVICE:-FREEPDB1}"

echo "🚀 Initializing ORDS REST Services for Publisher Database (${DB_SERVICE})..."

if [ -f "$SCRIPT_DIR/init-publisher-ords.sql" ] && podman ps --format "{{.Names}}" 2>/dev/null | grep -q "$PRIMARY_CONTAINER"; then
  cat "$SCRIPT_DIR/init-publisher-ords.sql" | podman exec -i "$PRIMARY_CONTAINER" sh -c "sqlplus -S / as sysdba" || true
  echo "✅ ORDS REST & SQL Developer Web Enabled for Publisher DB!"
else
  echo "ℹ️  Publisher DB container not running, skipping live ORDS initialization."
fi
