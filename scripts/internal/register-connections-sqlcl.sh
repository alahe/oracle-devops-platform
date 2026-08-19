#!/usr/bin/env bash
# ============================================================================
# Automatic Connection Registration via VS Code Extension Bundled SQLcl
# Grouped by database container name with saved credentials in container folders.
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [ -f "$WORKSPACE_DIR/.env" ]; then
  set -a
  source "$WORKSPACE_DIR/.env"
  set +a
elif [ -f "$WORKSPACE_DIR/config/repository.env" ]; then
  set -a
  source "$WORKSPACE_DIR/config/repository.env"
  set +a
fi

if [ -f "$SCRIPT_DIR/load-profile.sh" ]; then
  source "$SCRIPT_DIR/load-profile.sh"
fi

get_container_secret() {
  local container="$1"
  local name="$2"
  local val=""

  val=$(podman secret inspect --showsecret "$name" 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)

  if [ -z "$val" ] && { [ "$name" = "oracle_pwd" ] || [[ "$name" == *_sys_password ]]; }; then
    val=$(podman secret inspect --showsecret apex_db_sys_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
  fi

  if [ -z "$val" ] && podman container exists "$container" 2>/dev/null && [ "$(podman inspect --format='{{.State.Status}}' "$container" 2>/dev/null)" = "running" ]; then
    val=$(podman exec "$container" cat "/run/secrets/$name" 2>/dev/null || podman exec "$container" cat "/run/secrets/apex_db_sys_password" 2>/dev/null || true)
  fi

  echo "$val"
}

VSCODE_SQLCL=$(find "$HOME/.vscode/extensions" -name "sql" -path "*/oracle.sql-developer-*/dbtools/sqlcl/bin/sql" 2>/dev/null | head -n 1)
if [ -z "$VSCODE_SQLCL" ]; then
  VSCODE_SQLCL="sql"
fi

echo "Using SQLcl binary: $VSCODE_SQLCL"

TNS_ADMIN_PATH="$WORKSPACE_DIR/config/tns_admin"
export TNS_ADMIN="$TNS_ADMIN_PATH"

ACTIVE_INSTANCES=$(get_active_db_instances 2>/dev/null || echo "")
if [ -z "$ACTIVE_INSTANCES" ]; then
  PRIMARY_C="${CONTAINER_NAME:-db-dev-full}"
  ACTIVE_INSTANCES="${PRIMARY_C}|proxy-standard-gvenzl|PRIMARY"
fi

ENV_NAME="${ENVIRONMENT:-${PROFILE_NAME:-dev}}"
IS_PROD=false
if [[ "$(echo "$ENV_NAME" | tr '[:upper:]' '[:lower:]')" == *"prod"* ]]; then
  IS_PROD=true
fi

# Delegation to register-connections.sh which handles native connection folders and saved credentials
exec "$SCRIPT_DIR/register-connections.sh" "$@"

