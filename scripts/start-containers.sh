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

PROFILE="dev-ords"
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


echo "=================================================================="
echo "🚀 Käivitan Podmani compose konteinerid..."
if [ -n "$PROFILE" ]; then
  if [ "$SKIP_PUBLISHER" = "true" ]; then
    echo "   Kasutatav profiil: $PROFILE (APEX Proxy + ORDS, ilma Publisherita)"
  else
    echo "   Kasutatav profiil: $PROFILE (Andmebaasid + ORDS)"
  fi
else
  if [ "$SKIP_PUBLISHER" = "true" ]; then
    echo "   Vaikimisi profiil (Ainult APEX Proxy)"
  else
    echo "   Vaikimisi profiil (Mõlemad andmebaasid)"
  fi
fi
echo "=================================================================="

PRIMARY_CONTAINER=$(get_active_db_instances 2>/dev/null | head -n 1 | cut -d'|' -f1)
PRIMARY_CONTAINER="${PRIMARY_CONTAINER:-db-dev-full}"

# Käivitame compose
if [ "$SKIP_PUBLISHER" = "true" ]; then
  if [ -n "$PROFILE" ]; then
    podman-compose "${COMPOSE_ARGS[@]}" --profile "$PROFILE" up -d "$PRIMARY_CONTAINER" dev-ords
  else
    podman-compose "${COMPOSE_ARGS[@]}" up -d "$PRIMARY_CONTAINER"
  fi
else
  if [ -n "$PROFILE" ]; then
    podman-compose "${COMPOSE_ARGS[@]}" --profile "$PROFILE" up -d
  else
    podman-compose "${COMPOSE_ARGS[@]}" up -d
  fi
fi

if [ -f "$SCRIPT_DIR/internal/load-db-profile.sh" ]; then
  source "$SCRIPT_DIR/internal/load-db-profile.sh"
fi

# Ootame kuni andmebaasid on valmis (healthy)
echo ""
echo "⌛ Ootan andmebaaside käivitumist ja valmisolekut (Healthcheck)..."
MAX_WAIT=600

while IFS='|' read -r container prof env_key; do
  [ -z "$container" ] && continue
  if podman container exists "$container" 2>/dev/null; then
    echo "Ootan konteinerit: $container..."
    WAIT_COUNT=0
    until [ "$(podman inspect --format='{{.State.Health.Status}}' "$container" 2>/dev/null)" == "healthy" ]; do
      sleep 3
      WAIT_COUNT=$((WAIT_COUNT + 3))
      echo -ne "   Kestus: ${WAIT_COUNT}s...\r"
      if [ $WAIT_COUNT -ge $MAX_WAIT ]; then
        echo ""
        echo "❌ Viga: $container ei saavutanud valmisolekut $MAX_WAIT sekundi jooksul!"
        exit 1
      fi
    done
    echo -e "\n✅ $container on valmis (healthy)!"
  fi
done < <(get_active_db_instances)

# 3. Kontrollime ORDS-i käivitumist (kui profiil on aktiivne)
if [ -n "$PROFILE" ] && podman container exists "oracle-ords-dev" 2>/dev/null; then
  echo "Ootan konteinerit: oracle-ords-dev..."
  WAIT_COUNT=0
  until [ "$(podman inspect --format='{{.State.Status}}' "oracle-ords-dev" 2>/dev/null)" == "running" ]; do
    sleep 3
    WAIT_COUNT=$((WAIT_COUNT + 3))
    echo -ne "   Kestus: ${WAIT_COUNT}s...\r"
    if [ $WAIT_COUNT -ge 60 ]; then
      echo ""
      echo "❌ Viga: oracle-ords-dev ei käivitunud 60 sekundi jooksul!"
      exit 1
    fi
  done
  echo -e "\n✅ oracle-ords-dev on käivitatud ja töötab!"
fi

if [ "$SKIP_WEB_IDE" = "false" ] && [ "${WEB_IDE_ENABLED:-true}" = "true" ]; then
  echo "🚀 Käivitan Web IDE konteineri..."
  podman-compose "${COMPOSE_ARGS[@]}" --profile web-ide up -d >> /dev/null 2>&1 || true
  if [ -f "$SCRIPT_DIR/internal/init-web-ide.sh" ]; then
    "$SCRIPT_DIR/internal/init-web-ide.sh" >/dev/null 2>&1 || true
  fi
  echo "✅ Web IDE (VS Code) käivitatud aadressil: http://localhost:${WEB_IDE_HTTP_PORT:-8090}"
fi


echo "=================================================================="
echo "✅ Kõik valitud konteinerid on töökorras!"
echo "   Kontrolli staatust: podman ps"
echo "=================================================================="
