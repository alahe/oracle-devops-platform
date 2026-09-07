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
      echo "Usage: $0 [OPTIONS] [MODULE.FMB]"
      echo ""
      echo "Options:"
      echo "  -p, --port PORT  Set Developer Hub web port (Default: 6082)"
      echo "  -h, --help       Show this help message"
      echo ""
      echo "Examples:"
      echo "  $0                        # Opens Forms & APEX Modernization Hub in browser"
      echo "  $0 forms_apps/myform.fmb  # Compiles and prepares specified form"
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
    echo "⚠️  Forms container ($CONTAINER_NAME) is not running!"
    echo "   Start it with: ./scripts/setup-all.sh -b 18 or ./scripts/start-containers.sh"
    exit 1
  fi
fi

echo "=================================================================="
echo "🚀 ORACLE FORMS 14c DEVOPS & MODERNIZATION HUB"
echo "=================================================================="

if [ -n "$TARGET_MODULE" ]; then
  echo "📦 Compiling and validating module: $TARGET_MODULE..."
  "$SCRIPT_DIR/compile-form.sh" "$TARGET_MODULE" || true
fi

URL="http://localhost:${BUILDER_PORT}/vnc.html"
echo "🌐 Forms & APEX Modernization Hub is available at:"
echo "   👉 $URL"
echo "=================================================================="
echo "💡 ARCHITECTURE OVERVIEW:"
echo "   • Visual Forms Design (GUI):   Windows Forms Builder (frmbld.exe) -> save to 'forms_apps/'"
echo "   • Linux/Mac Container:         Headless runtime (port 9001), batch compilation and APEX export"
echo "=================================================================="

# Try to open default browser on macOS / Linux
if command -v open >/dev/null 2>&1; then
  open "$URL" 2>/dev/null || true
elif command -v xdg-open >/dev/null 2>&1; then
  xdg-open "$URL" 2>/dev/null || true
fi
