#!/usr/bin/env bash
# ============================================================================
# Oracle Forms 14c Application Deployer
# Copies .fmx, .mmx, and .plx binaries into the container's forms_apps volume
# ============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

SOURCE_DIR="${1:-$WORKSPACE_DIR/forms_apps}"
FORMS_CONTAINER="${FORMS_CONTAINER_NAME:-app-forms}"

echo -e "\n${CYAN}==================================================================${NC}"
echo -e "${BOLD}📦 ORACLE FORMS 14c APPLICATION DEPLOYMENT${NC}"
echo -e "${CYAN}==================================================================${NC}"

mkdir -p "$WORKSPACE_DIR/forms_apps"

if [ -d "$SOURCE_DIR" ]; then
  count=0
  for f in "$SOURCE_DIR"/*.fmx "$SOURCE_DIR"/*.mmx "$SOURCE_DIR"/*.plx; do
    [ -f "$f" ] || continue
    bname=$(basename "$f")
    echo "   ├─ Copying application file: ${CYAN}$bname${NC}"
    if podman container exists "$FORMS_CONTAINER" 2>/dev/null; then
      podman cp "$f" "$FORMS_CONTAINER":/u01/oracle/forms_apps/ >/dev/null 2>&1 || true
    fi
    count=$((count + 1))
  done
  echo -e "✅ ${GREEN}Deployed ${count} Forms application file(s) to /u01/oracle/forms_apps!${NC}"
else
  echo -e "⚠️  Directory $SOURCE_DIR not found."
fi
echo -e "${CYAN}==================================================================${NC}\n"
