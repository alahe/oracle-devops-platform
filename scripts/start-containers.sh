#!/usr/bin/env bash
# ============================================================================
# Utility Script: Start Podman Containers
# Purpose: Declarative orchestration wrapper to spin up containers for the active blueprint.
# Usage: ./scripts/start-containers.sh
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
COMPOSE_FILE="$WORKSPACE_DIR/podman-compose.yml"
OVERRIDE_FILE="$WORKSPACE_DIR/podman-compose.override.yml"
COMPOSE_ARGS=(-f "$COMPOSE_FILE")
[ -f "$OVERRIDE_FILE" ] && COMPOSE_ARGS+=(-f "$OVERRIDE_FILE")

# Source common helpers and i18n engine
if [ -f "$SCRIPT_DIR/internal/common.sh" ]; then
  source "$SCRIPT_DIR/internal/common.sh"
fi

if [ -f "$SCRIPT_DIR/internal/load-profile.sh" ]; then
  source "$SCRIPT_DIR/internal/load-profile.sh"
  resolve_active_blueprint
  load_db_profile
  load_web_ide_profile
  load_publisher_designer_profile
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

# Positively declare required service profiles for Podman Compose
if is_web_ide_enabled; then
  COMPOSE_ARGS+=(--profile web-ide)
fi

if is_publisher_enabled; then
  COMPOSE_ARGS+=(--profile publisher)
fi

if is_publisher_designer_enabled; then
  COMPOSE_ARGS+=(--profile publisher-designer)
  designer_img="${PUBLISHER_DESIGNER_CONTAINER_IMAGE:-localhost/oracle-publisher-designer:latest}"
  if ! podman image exists "$designer_img" 2>/dev/null; then
    echo "📦 Building custom oracle-publisher-designer image Just-In-Time (JIT)..."
    podman build -t "$designer_img" -f "$WORKSPACE_DIR/docker/publisher-designer/Dockerfile" "$WORKSPACE_DIR/docker/publisher-designer" || true
  fi
fi

if [ "${FAST_MODE:-false}" != "true" ] && [ "${SKIP_DEV_HUB:-false}" != "true" ] && [ -x "$SCRIPT_DIR/internal/generate-dev-hub.sh" ]; then
  "$SCRIPT_DIR/internal/generate-dev-hub.sh" "$WORKSPACE_DIR/docs/dev-hub.html" >/dev/null 2>&1 || true
fi

# Execute declarative compose startup
podman-compose "${COMPOSE_ARGS[@]}" up -d

# Wait for databases and provision profile users if active database instances are configured
if [ -n "$(get_active_db_instances 2>/dev/null)" ]; then
  if [ -x "$SCRIPT_DIR/internal/wait-db-healthy.sh" ]; then
    "$SCRIPT_DIR/internal/wait-db-healthy.sh"
  fi

  if [ -x "$SCRIPT_DIR/internal/apply-profile-users.sh" ]; then
    for inst in $(get_active_db_instances 2>/dev/null); do
      c_name=$(echo "$inst" | cut -d'|' -f1)
      [ -n "$c_name" ] && "$SCRIPT_DIR/internal/apply-profile-users.sh" "$c_name" >/dev/null 2>&1 || true
    done
  fi

  # Refresh central ORDS connection pool only if ORDS is active with this database
  if is_ords_enabled && podman container exists app-ords 2>/dev/null; then
    podman restart app-ords >/dev/null 2>&1 || true
  fi
fi

if is_web_ide_enabled; then
  if [ -f "$SCRIPT_DIR/internal/init-web-ide.sh" ]; then
    "$SCRIPT_DIR/internal/init-web-ide.sh" >/dev/null 2>&1 || true
  fi
  echo "✅ Web IDE (VS Code) ready: http://localhost:${WEB_IDE_HTTP_PORT:-8090}"
fi

if is_publisher_designer_enabled; then
  echo "🎨 Publisher Designer GUI ready: http://localhost:${PUBLISHER_DESIGNER_HTTP_PORT:-6083}/vnc.html"
fi

# URL endpoint verification
if [ -x "$SCRIPT_DIR/internal/test-urls.sh" ]; then
  "$SCRIPT_DIR/internal/test-urls.sh" 15 4
fi

# Start Dev Hub Bridge background daemon if needed
if [ -f "$SCRIPT_DIR/internal/dev-hub-bridge.py" ] && ! curl -s http://localhost:8089/api/status >/dev/null 2>&1; then
  python3 "$SCRIPT_DIR/internal/dev-hub-bridge.py" >/dev/null 2>&1 &
fi

echo "=================================================================="
echo -e "$(msg_str "ALL_CONTAINERS_HEALTHY")"
echo -e "$(msg_str "CHECK_STATUS_HINT")"
echo "=================================================================="
