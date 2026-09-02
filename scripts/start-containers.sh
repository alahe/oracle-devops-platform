#!/usr/bin/env bash
# ============================================================================
# Utility Script: Start Podman Containers
# Purpose: Convenient wrapper to spin up local database and ORDS containers.
# Usage: ./scripts/start-containers.sh [--no-ords]
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
COMPOSE_FILE="$SCRIPT_DIR/../podman-compose.yml"
OVERRIDE_FILE="$SCRIPT_DIR/../podman-compose.override.yml"
COMPOSE_ARGS=(-f "$COMPOSE_FILE")
[ -f "$OVERRIDE_FILE" ] && COMPOSE_ARGS+=(-f "$OVERRIDE_FILE")

# Source common helpers and i18n engine
if [ -f "$SCRIPT_DIR/internal/common.sh" ]; then
  source "$SCRIPT_DIR/internal/common.sh"
fi

if [ -f ".env" ]; then
  set -a
  source "$SCRIPT_DIR/../.env" 2>/dev/null || source ".env"
  set +a
fi

PROFILE=""
SKIP_PUBLISHER=false

if [ -z "$DB_PUBLISHER" ] && [ -z "$PUBLISHER_DB_HOST" ]; then
  SKIP_PUBLISHER=true
fi

SKIP_WEB_IDE=false

for arg in "$@"; do
  case $arg in
    --no-ords)
      PROFILE=""
      ;;
    --no-publisher)
      SKIP_PUBLISHER=true
      ;;
    --no-web-ide)
      SKIP_WEB_IDE=true
      ;;
  esac
done


if [ -f "$SCRIPT_DIR/internal/load-profile.sh" ]; then
  source "$SCRIPT_DIR/internal/load-profile.sh"
  load_db_profile >/dev/null 2>&1 || true
  load_web_ide_profile >/dev/null 2>&1 || true
fi

# Dynamically check if any active profile enables publisher
ANY_PUB_ENABLED=false
for inst in $(get_active_db_instances 2>/dev/null); do
  pname=$(echo "$inst" | cut -d'|' -f2)
  pfile="$SCRIPT_DIR/../config/profiles/databases/${pname}.yaml"
  [ ! -f "$pfile" ] && pfile="$SCRIPT_DIR/../config/profiles/${pname}.yaml"
  if [ -f "$pfile" ]; then
    pub_en=$(awk '/publisher:/{flag=1;next}/ords:|apex:|sqlcl:|users:/{flag=0}flag' "$pfile" | grep -E '^[[:space:]]*enabled:' | head -n 1 | sed -E 's/.*:[[:space:]]*"?([^"]+)"?/\1/' | tr -d '\r\n')
    if [ "$pub_en" = "true" ]; then
      ANY_PUB_ENABLED=true
      break
    fi
  fi
done

if [ "$ANY_PUB_ENABLED" = "true" ] || [ "${PUBLISHER_ENABLED:-false}" = "true" ] || [ "${SKIP_PUBLISHER:-true}" = "false" ]; then
  SKIP_PUBLISHER=false
fi

echo "=================================================================="
echo -e "$(msg_str "STARTING_COMPOSE_CONTAINERS")"
get_active_db_instances | while IFS='|' read -r container prof env_key; do
  [ -z "$container" ] && continue
  echo "   - $(msg_str "LABEL_CONTAINER"): $container ($(msg_str "LABEL_PROFILE"): $prof)"
done
echo "=================================================================="

# Dynamic override file generation if missing or profile changed
if [ -x "$SCRIPT_DIR/internal/generate-passwords.sh" ]; then
  "$SCRIPT_DIR/internal/generate-passwords.sh" >/dev/null 2>&1 || true
fi
if [ -x "$SCRIPT_DIR/internal/generate-compose-override.sh" ]; then
  "$SCRIPT_DIR/internal/generate-compose-override.sh" >/dev/null 2>&1 || true
fi

PRIMARY_CONTAINER=$(get_active_db_instances 2>/dev/null | head -n 1 | cut -d'|' -f1)
PRIMARY_CONTAINER="${PRIMARY_CONTAINER:-app-db}"

if [ "$SKIP_WEB_IDE" = "false" ]; then
  COMPOSE_ARGS+=(--profile web-ide)
fi

# Start defined compose services
if [ "$SKIP_PUBLISHER" = "false" ]; then
  COMPOSE_ARGS+=(--profile publisher)
fi

if [ -x "$SCRIPT_DIR/internal/generate-dev-hub.sh" ]; then
  "$SCRIPT_DIR/internal/generate-dev-hub.sh" "$WORKSPACE_DIR/docs/dev-hub.html" >/dev/null 2>&1 || true
fi

podman-compose "${COMPOSE_ARGS[@]}" up -d

# Ootame kuni andmebaasid on valmis (healthy)
if [ -x "$SCRIPT_DIR/internal/wait-db-healthy.sh" ]; then
  "$SCRIPT_DIR/internal/wait-db-healthy.sh"
fi

# Synchronize users and passwords immediately upon database readiness
if [ -x "$SCRIPT_DIR/internal/apply-profile-users.sh" ]; then
  for inst in $(get_active_db_instances 2>/dev/null); do
    c_name=$(echo "$inst" | cut -d'|' -f1)
    [ -n "$c_name" ] && "$SCRIPT_DIR/internal/apply-profile-users.sh" "$c_name" >/dev/null 2>&1 || true
  done
fi

if podman container exists app-ords 2>/dev/null; then
  podman restart app-ords >/dev/null 2>&1 || true
fi

if podman container exists app-forms 2>/dev/null && [ "$(podman inspect --format='{{.State.Status}}' app-forms 2>/dev/null)" != "running" ]; then
  podman start app-forms >/dev/null 2>&1 || true
fi

if [ "$SKIP_PUBLISHER" = "false" ] && podman container exists app-publisher 2>/dev/null && [ "$(podman inspect --format='{{.State.Status}}' app-publisher 2>/dev/null)" != "running" ]; then
  podman start app-publisher >/dev/null 2>&1 || true
fi

if [ "$SKIP_WEB_IDE" = "false" ]; then
  podman-compose "${COMPOSE_ARGS[@]}" --profile web-ide up -d >> /dev/null 2>&1 || true
  if [ -f "$SCRIPT_DIR/internal/init-web-ide.sh" ]; then
    "$SCRIPT_DIR/internal/init-web-ide.sh" >/dev/null 2>&1 || true
  fi
  echo "✅ Web IDE (VS Code) ready: http://localhost:${WEB_IDE_HTTP_PORT:-8090}"
fi

# 🌐 KOHUSTUSLIK URL TESTIMINE ENNE TÖÖKORRAS SÕNUMIT
if [ -x "$SCRIPT_DIR/internal/test-urls.sh" ]; then
  "$SCRIPT_DIR/internal/test-urls.sh" 15 4
fi

echo "=================================================================="
echo -e "$(msg_str "ALL_CONTAINERS_HEALTHY")"
echo -e "$(msg_str "CHECK_STATUS_HINT")"
echo "=================================================================="
