#!/bin/bash
# ==============================================================================
# Oracle Forms Builder 14c Launcher (Web noVNC / Native X11)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source helper functions if available
if [ -f "$PROJECT_ROOT/scripts/internal/common.sh" ]; then
  # shellcheck source=/dev/null
  source "$PROJECT_ROOT/scripts/internal/common.sh"
fi

CONTAINER_NAME="${FORMS_CONTAINER_NAME:-app-forms}"
BUILDER_PORT="${FORMS_BUILDER_PORT:-6082}"
TARGET_MODULE=""
USE_X11=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --x11)
      USE_X11=true
      shift
      ;;
    -p|--port)
      BUILDER_PORT="$2"
      shift 2
      ;;
    -h|--help)
      echo "Kasutus: $0 [VALIKUD] [MOODUL.FMB]"
      echo ""
      echo "Valikud:"
      echo "  --x11            Suuna kuva kohalikku X11 serverisse (XQuartz / VcXsrv)"
      echo "  -p, --port PORT  Määra noVNC veebiport (Vaikimisi: 6082)"
      echo "  -h, --help       Kuva see abiinfo"
      echo ""
      echo "Näited:"
      echo "  $0                          # Avab Forms Builderi brauseris (noVNC)"
      echo "  $0 forms_apps/minuvorm.fmb  # Avab konkreetse vormi Builderis"
      echo "  $0 --x11                    # Käivitab natiivse X11 aknana"
      exit 0
      ;;
    *)
      TARGET_MODULE="$1"
      shift
      ;;
  esac
done

# Check if Forms container is running
if ! podman ps --format "{{.Names}}" 2>/dev/null | grep -q "^${CONTAINER_NAME}$"; then
  if ! docker ps --format "{{.Names}}" 2>/dev/null | grep -q "^${CONTAINER_NAME}$"; then
    echo "⚠️  Forms konteiner ($CONTAINER_NAME) ei tööta!"
    echo "   Käivita see käsuga: ./scripts/setup-all.sh -b 14 või ./scripts/start-containers.sh"
    exit 1
  fi
fi

CTR_CMD="podman"
if ! command -v podman >/dev/null 2>&1 && command -v docker >/dev/null 2>&1; then
  CTR_CMD="docker"
fi

echo "=================================================================="
echo "🚀 ORACLE FORMS BUILDER 14c (14.1.2) KÄIVITAJA"
echo "=================================================================="

if [ "$USE_X11" = "true" ]; then
  HOST_DISPLAY="${DISPLAY:-:0}"
  echo "🖥️  Seadistan kohalikku X11 serverit (XQuartz / VcXsrv)..."
  if [ -x "/opt/X11/bin/xhost" ]; then
    DISPLAY="$HOST_DISPLAY" /opt/X11/bin/xhost + >/dev/null 2>&1 || true
  elif command -v xhost >/dev/null 2>&1; then
    DISPLAY="$HOST_DISPLAY" xhost + >/dev/null 2>&1 || true
  fi

  echo "🖥️  Käivitan Forms Builder 14c kuval host.containers.internal$HOST_DISPLAY..."
  if $CTR_CMD exec "$CONTAINER_NAME" test -f /u01/oracle/bin/frmbld.sh 2>/dev/null; then
    $CTR_CMD exec -d -e DISPLAY="host.containers.internal$HOST_DISPLAY" "$CONTAINER_NAME" /u01/oracle/bin/frmbld.sh ${TARGET_MODULE:+module=/u01/oracle/forms_apps/$(basename "$TARGET_MODULE")} || true
    echo "✅ Forms Builder käsk on edastatud töölauale!"
    echo "   Kui aken ei ilmunud kohe, veendu et XQuartz rakendus on avatud (open -a XQuartz)."
  elif $CTR_CMD exec "$CONTAINER_NAME" test -f /u01/oracle/bin/frmbld 2>/dev/null; then
    $CTR_CMD exec -d -e DISPLAY="host.containers.internal$HOST_DISPLAY" "$CONTAINER_NAME" /u01/oracle/bin/frmbld ${TARGET_MODULE:+module=/u01/oracle/forms_apps/$(basename "$TARGET_MODULE")} || true
    echo "✅ Forms Builder käsk on edastatud töölauale!"
  else
    echo "ℹ️  Konteineris on aktiivne Forms 14c Headless Deployment & Modernization Runtime mootor."
    echo ""
    echo "👉 Modernses Forms & APEX arendustöövoos kasutatakse kiirkäske:"
    echo "   • Vormi kompileerimine:    ./scripts/forms/compile-form.sh ${TARGET_MODULE:-forms_apps/minu_vorm.fmb}"
    echo "   • Git XML koodiarvustus:   ./scripts/forms/form-to-xml.sh ${TARGET_MODULE:-forms_apps/minu_vorm.fmb}"
    echo "   • APEX migratsioonipakk:   ./scripts/forms/export-forms-for-apex.sh"
    echo "   • PL/SQL loogika väljavõte: ./scripts/forms/extract-forms-plsql.sh forms_apps/<fail>_fmb.xml"
    echo "   • Veebis reaalajas test:   http://localhost:9001/forms/frmservlet?form=test.fmx"
  fi
else
  URL="http://localhost:${BUILDER_PORT}/vnc.html"
  echo "🌐 Forms Builder & Modernization Hub on avatud:"
  echo "   👉 $URL"
  echo "=================================================================="
  
  # Try to open default browser on macOS / Linux
  if command -v open >/dev/null 2>&1; then
    open "$URL" 2>/dev/null || true
  elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$URL" 2>/dev/null || true
  fi
fi
