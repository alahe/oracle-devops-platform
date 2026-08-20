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
  load_db_profile >/dev/null 2>&1 || true
fi

SYS_PWD=$("$SCRIPT_DIR/view-wallet-credential.sh" "DB_PUBLISHER_SYS" 2>/dev/null | grep "Password:" | awk '{print $3}' | tr -d '\r\n')
if [ -z "$SYS_PWD" ]; then
  SYS_PWD=$("$SCRIPT_DIR/view-wallet-credential.sh" "DB_APEX_PROXY_SYS" 2>/dev/null | grep "Password:" | awk '{print $3}' | tr -d '\r\n')
fi
SYS_PWD="${SYS_PWD:-OraclePass2026}"

DB_SERVICE="${PROFILE_DB_PDB:-FREEPDB1}"
PRIMARY_CONTAINER=$(get_active_db_instances 2>/dev/null | head -n 1 | cut -d'|' -f1 || echo "pub-db")

echo "🚀 Initializing ORDS REST Services for Publisher Database (${DB_SERVICE})..."

if [ -f "$SCRIPT_DIR/init-publisher-ords.sql" ] && podman ps --format "{{.Names}}" 2>/dev/null | grep -q "$PRIMARY_CONTAINER"; then
  cat "$SCRIPT_DIR/init-publisher-ords.sql" | podman exec -i "$PRIMARY_CONTAINER" sh -c "sqlplus -S sys/${SYS_PWD}@localhost:1521/${DB_SERVICE} as sysdba" || true
  echo "✅ ORDS REST & SQL Developer Web Enabled for Publisher DB!"
else
  echo "ℹ️  Publisher DB container not running, skipping live ORDS initialization."
fi
