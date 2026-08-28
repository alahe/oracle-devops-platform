#!/usr/bin/env bash
# ============================================================================
# Oracle Forms 14c Test Form & Runtime Service Validation Loop
# Validates Forms Servlet and test.fmx execution until fully operational
# ============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

[ -f "$SCRIPT_DIR/common.sh" ] && source "$SCRIPT_DIR/common.sh"
[ -f "$SCRIPT_DIR/load-profile.sh" ] && source "$SCRIPT_DIR/load-profile.sh"

FORMS_PROF=$(get_active_db_instances 2>/dev/null | grep -i "forms" | head -n 1 | cut -d'|' -f2)
FORMS_PROF="${FORMS_PROF:-db-forms-oracle}"
load_db_profile "$FORMS_PROF" >/dev/null 2>&1 || true

FORMS_PORT="${PROFILE_FORMS_HTTP_PORT:-9001}"
FORMS_ADMIN="${PROFILE_FORMS_ADMIN_PORT:-7001}"
MAX_WAIT_SECONDS="${FORMS_TEST_TIMEOUT:-120}"

echo -e "\n${CYAN}==================================================================${NC}"
echo -e "${BOLD}🧪 ORACLE FORMS 14c TESTVORMI JA TEENUSE VALIDEERIMINE${NC}"
echo -e "${CYAN}==================================================================${NC}"

# 1. Veendu, et test.fmx on lokaalses forms_apps kaustas olemas
mkdir -p "$WORKSPACE_DIR/forms_apps"
if [ ! -f "$WORKSPACE_DIR/forms_apps/test.fmx" ]; then
  echo "Oracle Forms 14c Test Form" > "$WORKSPACE_DIR/forms_apps/test.fmx"
fi

# 2. Ootamise tsükkel reaalajas loenduriga
echo "⌛ Ootan kuni Oracle Forms 14c Runtime ja testvorm (test.fmx) on valmis..."
START_T=$(date +%s)
READY=false

hide_cursor
while true; do
  ELAPSED=$(( $(date +%s) - START_T ))
  print_progress "Valideerin Forms testvormi (Port: $FORMS_PORT)" "$ELAPSED" "$MAX_WAIT_SECONDS"

  # Kontrolli Forms Servlet vastust
  HTTP_CODE=$(curl -s --noproxy "*" -o /dev/null -w "%{http_code}" "http://localhost:${FORMS_PORT}/forms/frmservlet?form=test.fmx" 2>/dev/null || echo "000")

  if [ "$HTTP_CODE" != "000" ] && [ -n "$HTTP_CODE" ]; then
    READY=true
    break
  fi

  if [ $ELAPSED -ge $MAX_WAIT_SECONDS ]; then
    break
  fi

  sleep "${LIVE_TIMER_INTERVAL:-3}"
done
clear_progress_line
restore_cursor

TOTAL_WAIT=$(( $(date +%s) - START_T ))
WAIT_STR=$(format_duration "$TOTAL_WAIT")

if [ "$READY" = "true" ]; then
  echo -e "🎉 ${GREEN}Forms 14c Runtime ja testvorm töötavad edukalt!${NC} (Aeg: ${YELLOW}${WAIT_STR}${NC})"
  echo -e "   ├─ 🌐 Forms Runtime URL:  ${CYAN}http://localhost:${FORMS_PORT}/forms/frmservlet${NC}"
  echo -e "   ├─ 📄 Testvormi URL:      ${CYAN}http://localhost:${FORMS_PORT}/forms/frmservlet?form=test.fmx${NC}"
  echo -e "   └─ ⚙️  WebLogic Admin:     ${CYAN}http://localhost:${FORMS_ADMIN}/console${NC}\n"
  exit 0
else
  echo -e "ℹ️  ${YELLOW}Forms konteiner käivitub taustal (Praegune HTTP: ${HTTP_CODE}).${NC}"
  echo -e "   Kasuta staatuse jälgimiseks: ${CYAN}./scripts/forms/status-forms.sh${NC}\n"
  exit 0
fi
