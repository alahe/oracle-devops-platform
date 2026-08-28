#!/usr/bin/env bash
# ============================================================================
# Oracle Forms 14c Status & Diagnostics Tool
# Displays container state, memory usage, WebLogic ports, and URL endpoints
# ============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

[ -f "$WORKSPACE_DIR/scripts/internal/common.sh" ] && source "$WORKSPACE_DIR/scripts/internal/common.sh"
[ -f "$WORKSPACE_DIR/scripts/internal/load-profile.sh" ] && source "$WORKSPACE_DIR/scripts/internal/load-profile.sh"

FORMS_CONTAINER="${FORMS_CONTAINER_NAME:-app-forms}"
DB_CONTAINER="db-forms"
FORMS_PORT="${FORMS_HTTP_PORT:-9001}"
FORMS_ADMIN="${FORMS_ADMIN_PORT:-7001}"

echo -e "\n${CYAN}==================================================================${NC}"
echo -e "${BOLD}📊 ORACLE FORMS 14c TEENUSTE OLEK (STATUS & DIAGNOSTICS)${NC}"
echo -e "${CYAN}==================================================================${NC}"

# 1. Konteinerite olek
echo -e "📦 ${BOLD}Konteinerid:${NC}"
for c in "$DB_CONTAINER" "$FORMS_CONTAINER"; do
  if podman container exists "$c" 2>/dev/null; then
    status=$(podman inspect --format='{{.State.Status}}' "$c" 2>/dev/null || echo "tundmatu")
    if [ "$status" = "running" ]; then
      echo -e "   ├─ ${GREEN}✅ $c:${NC} TÖÖTAB (running)"
    else
      echo -e "   ├─ ${YELLOW}⏸️  $c:${NC} PEATATUD ($status)"
    fi
  else
    echo -e "   ├─ ${RED}❌ $c:${NC} EI LEITUD"
  fi
done

# 2. URL-ide kontroll
echo -e "\n🌐 ${BOLD}Veebiliidesed ja Teenused:${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${FORMS_PORT}/forms/frmservlet" 2>/dev/null || echo "000")
if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ]; then
  echo -e "   ├─ Forms Runtime:     ${GREEN}✅ http://localhost:${FORMS_PORT}/forms/frmservlet${NC} (HTTP $HTTP_CODE)"
else
  echo -e "   ├─ Forms Runtime:     ${YELLOW}⏳ http://localhost:${FORMS_PORT}/forms/frmservlet${NC} (HTTP $HTTP_CODE)"
fi

HTTP_TEST=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${FORMS_PORT}/forms/frmservlet?form=test.fmx" 2>/dev/null || echo "000")
if [ "$HTTP_TEST" = "200" ] || [ "$HTTP_TEST" = "302" ]; then
  echo -e "   ├─ Testvorm (test):   ${GREEN}✅ http://localhost:${FORMS_PORT}/forms/frmservlet?form=test.fmx${NC} (HTTP $HTTP_TEST)"
else
  echo -e "   ├─ Testvorm (test):   ${YELLOW}⏳ http://localhost:${FORMS_PORT}/forms/frmservlet?form=test.fmx${NC} (HTTP $HTTP_TEST)"
fi

echo -e "   └─ WebLogic Admin:    ${CYAN}http://localhost:${FORMS_ADMIN}/console${NC}"
echo -e "${CYAN}==================================================================${NC}\n"
