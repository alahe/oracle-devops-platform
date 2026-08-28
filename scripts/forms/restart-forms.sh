#!/usr/bin/env bash
# ============================================================================
# Oracle Forms 14c Restart Utility
# Cleanly restarts the app-forms container and Forms Services
# ============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

[ -f "$WORKSPACE_DIR/scripts/internal/common.sh" ] && source "$WORKSPACE_DIR/scripts/internal/common.sh"

FORMS_CONTAINER="${FORMS_CONTAINER_NAME:-app-forms}"

echo -e "\n${CYAN}==================================================================${NC}"
echo -e "${BOLD}🔄 TAASKÄIVITAN ORACLE FORMS 14c TEENUSE (${FORMS_CONTAINER})...${NC}"
echo -e "${CYAN}==================================================================${NC}"

if podman container exists "$FORMS_CONTAINER" 2>/dev/null; then
  echo "⏹️  Peatan konteineri $FORMS_CONTAINER..."
  podman stop "$FORMS_CONTAINER" >/dev/null 2>&1 || true
  echo "▶️  Käivitan konteineri $FORMS_CONTAINER..."
  podman start "$FORMS_CONTAINER" >/dev/null 2>&1 || true
  echo -e "✅ ${GREEN}Konteiner $FORMS_CONTAINER taaskäivitatud!${NC}"
else
  echo -e "ℹ️  Konteinerit $FORMS_CONTAINER ei leitud. Käivitan paigalduse..."
  "$WORKSPACE_DIR/scripts/internal/install-forms.sh"
fi

echo -e "${CYAN}==================================================================${NC}\n"
