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

# Vaigistame podman compose hoiatusteate välise teenusepakkuja kohta
export PODMAN_COMPOSE_WARNING_LOGS=false


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

if [ "$ANY_PUB_ENABLED" = "true" ] || [ "${PUBLISHER_ENABLED:-false}" = "true" ]; then
  SKIP_PUBLISHER=false
fi

echo "=================================================================="
echo "🚀 Käivitan Podmani compose konteinerid..."
get_active_db_instances | while IFS='|' read -r container prof env_key; do
  [ -z "$container" ] && continue
  echo "   - Konteiner: $container (Profiil: $prof)"
done
echo "=================================================================="

# Dynamic override file generation if missing or profile changed
if [ -x "$SCRIPT_DIR/internal/generate-passwords.sh" ]; then
  "$SCRIPT_DIR/internal/generate-passwords.sh" >/dev/null 2>&1 || true
fi

PRIMARY_CONTAINER=$(get_active_db_instances 2>/dev/null | head -n 1 | cut -d'|' -f1)
PRIMARY_CONTAINER="${PRIMARY_CONTAINER:-app-db}"

if [ "$SKIP_WEB_IDE" = "false" ] && [ "${WEB_IDE_ENABLED:-false}" = "true" ]; then
  COMPOSE_ARGS+=(--profile web-ide)
fi

# Käivitame meile teadaolevad compose teenused
if [ "$SKIP_PUBLISHER" = "false" ]; then
  COMPOSE_ARGS+=(--profile publisher)
fi

podman-compose "${COMPOSE_ARGS[@]}" up -d

# Ootame kuni andmebaasid on valmis (healthy)
echo ""
echo "⌛ Ootan andmebaaside käivitumist ja valmisolekut (Healthcheck)..."
MAX_WAIT=600

get_active_db_instances | while IFS='|' read -r container prof env_key; do
  [ -z "$container" ] && continue
  if podman container exists "$container" 2>/dev/null; then
    echo "Ootan konteinerit: $container..."
    WAIT_COUNT=0
    until [ "$(podman inspect --format='{{.State.Health.Status}}' "$container" 2>/dev/null)" == "healthy" ]; do
      sleep 3
      WAIT_COUNT=$((WAIT_COUNT + 3))
      if declare -f print_step_progress >/dev/null 2>&1; then
        print_step_progress "Ootan konteinerit $container" "$WAIT_COUNT" 60
      elif [ -c /dev/tty ]; then
        printf "\r\033[K   ⏳ Ootan konteinerit %s... kestus: %ds" "$container" "$WAIT_COUNT" >/dev/tty 2>/dev/null || true
      fi
      if [ $WAIT_COUNT -ge $MAX_WAIT ]; then
        echo ""
        echo "❌ Viga: $container ei saavutanud valmisolekut $MAX_WAIT sekundi jooksul!"
        exit 1
      fi
    done
    if [ -c /dev/tty ]; then
      printf "\r\033[K" >/dev/tty 2>/dev/null || true
    fi
    echo -e "✅ $container on valmis (healthy)!"
    ensure_db_instance_open "$container" || true
  fi
done

if [ "$SKIP_WEB_IDE" = "false" ] && [ "${WEB_IDE_ENABLED:-false}" = "true" ]; then
  echo "🚀 Käivitan Web IDE konteineri..."
  podman-compose "${COMPOSE_ARGS[@]}" --profile web-ide up -d >> /dev/null 2>&1 || true
  if [ -f "$SCRIPT_DIR/internal/init-web-ide.sh" ]; then
    "$SCRIPT_DIR/internal/init-web-ide.sh" >/dev/null 2>&1 || true
  fi
  echo "✅ Web IDE (VS Code) käivitatud aadressil: http://localhost:${WEB_IDE_HTTP_PORT:-8090}"
fi

# 🌐 KOHUSTUSLIK URL TESTIMINE ENNE TÖÖKORRAS SÕNUMIT
if [ -x "$SCRIPT_DIR/internal/test-urls.sh" ]; then
  "$SCRIPT_DIR/internal/test-urls.sh" 15 4
fi

echo "=================================================================="
echo "✅ Kõik valitud konteinerid ja veebiteenuste URL-id on töökorras!"
echo "   Kontrolli staatust: podman ps"
echo "=================================================================="
