#!/bin/bash
# ==============================================================================
# Oracle Forms 14c Developer Hub & Tooling Launcher
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

while [[ $# -gt 0 ]]; do
  case "$1" in
    -p|--port)
      BUILDER_PORT="$2"
      shift 2
      ;;
    -h|--help)
      echo "Kasutus: $0 [VALIKUD] [MOODUL.FMB]"
      echo ""
      echo "Valikud:"
      echo "  -p, --port PORT  Määra Developer Hubi veebiport (Vaikimisi: 6082)"
      echo "  -h, --help       Kuva see abiinfo"
      echo ""
      echo "Näited:"
      echo "  $0                          # Avab Forms & APEX Modernization Hubi brauseris"
      echo "  $0 forms_apps/minuvorm.fmb  # Kompileerib ja valmistab ette konkreetse vormi"
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
    echo "   Käivita see käsuga: ./scripts/setup-all.sh -b 18 või ./scripts/start-containers.sh"
    exit 1
  fi
fi

echo "=================================================================="
echo "🚀 ORACLE FORMS 14c DEVOPS & MODERNIZATION HUB"
echo "=================================================================="

if [ -n "$TARGET_MODULE" ]; then
  echo "📦 Kompileerin ja valideerin moodulit: $TARGET_MODULE..."
  "$SCRIPT_DIR/compile-form.sh" "$TARGET_MODULE" || true
fi

URL="http://localhost:${BUILDER_PORT}/vnc.html"
echo "🌐 Forms & APEX Modernization Hub on avatud:"
echo "   👉 $URL"
echo "=================================================================="
echo "💡 ARHITEKTUURNE SPINNER:"
echo "   • Vormide visuaalne disain (GUI): Windows Forms Builder (frmbld.exe) -> salvesta kausta 'forms_apps/'"
echo "   • Linux/Mac Konteiner:           Headless käitusserver (port 9001), partii-kompileerimine ja APEX eksport"
echo "=================================================================="

# Try to open default browser on macOS / Linux
if command -v open >/dev/null 2>&1; then
  open "$URL" 2>/dev/null || true
elif command -v xdg-open >/dev/null 2>&1; then
  xdg-open "$URL" 2>/dev/null || true
fi
