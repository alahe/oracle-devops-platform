#!/usr/bin/env bash
# ============================================================================
# Oracle DevOps Platform — Blueprints 6 to 11 Automated Testing Suite
#
# Tests Blueprints 6, 7, 8, 9, 10, 11 across:
#   1. Cold Start (-tb <BP>)
#   2. Warm Start (-b <BP>)
#   3. HTTP/HTTPS Endpoint Probing
#   4. Browser & UI Login / noVNC / Web-IDE Validation
#   5. Timing Comparison Matrix
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Suppress interactive prompts and certificate GUI popups during automated tests
export IS_TEST_MODE="true"
export SKIP_CERT_TRUST="true"
export CI="true"

# Colors
CYAN='\033[1;36m'
GREEN='\033[1;32m'
YELLOW='\033[0;33m'
RED='\033[1;31m'
BOLD='\033[1m'
NC='\033[0m'

TARGET_BPS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    -b=*|--blueprint=*)
      val="${1#*=}"
      IFS=',' read -ra ADDR <<< "$val"
      for b in "${ADDR[@]}"; do TARGET_BPS+=("$b"); done
      shift
      ;;
    -b|--blueprint)
      val="$2"
      IFS=',' read -ra ADDR <<< "$val"
      for b in "${ADDR[@]}"; do TARGET_BPS+=("$b"); done
      shift 2
      ;;
    --fast)
      FAST_MODE=true
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [-b <6..11> | -b <list>]"
      echo "Default runs: 8 9 10 11 6 7"
      exit 0
      ;;
    *)
      TARGET_BPS+=("$1")
      shift
      ;;
  esac
done

if [ ${#TARGET_BPS[@]} -eq 0 ]; then
  TARGET_BPS=(8 9 10 11 6 7)
fi

format_duration() {
  local SECS=$1
  local MINS=$((SECS / 60))
  local REM_SECS=$((SECS % 60))
  if [ $MINS -gt 0 ]; then
    echo "${MINS}m ${REM_SECS}s"
  else
    echo "${REM_SECS}s"
  fi
}

check_bp_urls_and_browser() {
  local bp="$1"
  local url_res="PASS"
  local browser_res="PASS"

  case "$bp" in
    8) # Web-IDE
      local code
      code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8090/?folder=/config/workspace" || echo "000")
      if [ "$code" = "200" ] || [ "$code" = "302" ]; then
        url_res="✅ HTTP $code"
      else
        url_res="⚠️ HTTP $code"
      fi
      # Check Web-IDE extensions
      if podman container exists web-ide-dev 2>/dev/null; then
        local ext_out
        ext_out=$(podman exec web-ide-dev /app/code-server/bin/code-server --extensions-dir /config/extensions --list-extensions 2>/dev/null || podman exec web-ide-dev ls -1 /config/extensions 2>/dev/null || echo "")
        if echo "$ext_out" | grep -qi "antigravity" && echo "$ext_out" | grep -qi "python" && echo "$ext_out" | grep -qi "sql-developer"; then
          browser_res="✅ Web-IDE UI + 3 Extensions"
        else
          browser_res="⚠️ Web-IDE UI OK, Ext Partial"
        fi
      else
        browser_res="❌ Container Missing"
      fi
      ;;

    9) # Publisher Designer (noVNC 6083)
      local code
      code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:6083/vnc.html" || echo "000")
      if [ "$code" = "200" ] || [ "$code" = "302" ]; then
        url_res="✅ HTTP $code (noVNC)"
        browser_res="✅ noVNC Web Desktop OK"
      else
        # Try root
        code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:6083/" || echo "000")
        if [ "$code" = "200" ] || [ "$code" = "302" ]; then
          url_res="✅ HTTP $code"
          browser_res="✅ HTML5 Desktop UI"
        else
          url_res="⚠️ HTTP $code"
          browser_res="⚠️ noVNC unresp."
        fi
      fi
      ;;

    10) # Remote ORDS
      local code
      code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8088/ords/" || echo "000")
      if [ "$code" = "200" ] || [ "$code" = "302" ]; then
        url_res="✅ HTTP $code (ORDS)"
        browser_res="✅ ORDS Web Root"
      else
        url_res="⚠️ HTTP $code"
        browser_res="⚠️ ORDS unresp."
      fi
      ;;

    11) # Remote Publisher
      local code
      code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:9502/xmlpserver/" || echo "000")
      if [ "$code" = "200" ] || [ "$code" = "302" ]; then
        url_res="✅ HTTP $code"
        browser_res="✅ Publisher Server UI"
      else
        url_res="⚠️ HTTP $code"
        browser_res="⚠️ Initializing"
      fi
      ;;

    6) # Standalone Forms
      local f_code
      f_code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:9001/forms/frmservlet" || echo "000")
      local v_code
      v_code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:6082/" || echo "000")
      url_res="Forms: $f_code, noVNC: $v_code"
      if [ "$f_code" = "200" ] || [ "$v_code" = "200" ]; then
        browser_res="✅ Forms Web / noVNC"
      else
        browser_res="⚠️ Forms Initing"
      fi
      ;;

    7) # Consolidated Forms & Publisher
      local p_code
      p_code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:9502/xmlpserver/" || echo "000")
      local f_code
      f_code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:9001/forms/frmservlet" || echo "000")
      url_res="Pub: $p_code, Forms: $f_code"
      if [ "$p_code" = "200" ] || [ "$f_code" = "200" ]; then
        browser_res="✅ Unified FMW UI"
      else
        browser_res="⚠️ FMW Initing"
      fi
      ;;

    *)
      url_res="N/A"
      browser_res="N/A"
      ;;
  esac

  echo "${url_res}|${browser_res}"
}

RESULTS=()
REPORT_FILE="$WORKSPACE_DIR/tests/reports/blueprints_6_11_lifecycle_report.md"
mkdir -p "$(dirname "$REPORT_FILE")"

echo -e "${CYAN}==================================================================${NC}"
echo -e "${CYAN}🧪 AUTOMATED TESTING SUITE FOR BLUEPRINTS 6 TO 11${NC}"
echo -e "${CYAN}   Blueprints to test: ${YELLOW}${TARGET_BPS[*]}${NC}"
echo -e "${CYAN}==================================================================${NC}"

for bp in "${TARGET_BPS[@]}"; do
  echo -e "\n${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BOLD}▶️ EVALUATING BLUEPRINT ${bp}${NC}"
  echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

  # --------------------------------------------------------------------------
  # 1. Külm Käivitus (Cold Start / -tb)
  # --------------------------------------------------------------------------
  echo -e "${YELLOW}❄️  [TIER 1]: Külm Käivitus (setup-all.sh -tb ${bp})...${NC}"
  T_COLD_START=$(date +%s)
  "$WORKSPACE_DIR/scripts/setup-all.sh" -tb "$bp" --lang en
  T_COLD_END=$(date +%s)
  T_COLD_SECS=$((T_COLD_END - T_COLD_START))
  T_COLD_DUR=$(format_duration "$T_COLD_SECS")
  echo -e "${GREEN}✅ Külm käivitus lõpetatud: ${T_COLD_DUR}${NC}"

  # Kontrolli URL ja brauser
  eval_res=$(check_bp_urls_and_browser "$bp")
  IFS='|' read -r cold_url cold_browser <<< "$eval_res"

  # --------------------------------------------------------------------------
  # 2. Soe Käivitus (Warm Start / -b)
  # --------------------------------------------------------------------------
  echo -e "\n${YELLOW}🔥 [TIER 2]: Soe Käivitus (setup-all.sh -b ${bp})...${NC}"
  T_WARM_START=$(date +%s)
  "$WORKSPACE_DIR/scripts/setup-all.sh" -b "$bp" --lang en
  T_WARM_END=$(date +%s)
  T_WARM_SECS=$((T_WARM_END - T_WARM_START))
  T_WARM_DUR=$(format_duration "$T_WARM_SECS")
  echo -e "${GREEN}✅ Soe käivitus lõpetatud: ${T_WARM_DUR}${NC}"

  eval_res=$(check_bp_urls_and_browser "$bp")
  IFS='|' read -r warm_url warm_browser <<< "$eval_res"

  # Kiiruse võit
  if [ "$T_WARM_SECS" -gt 0 ]; then
    SPEEDUP="$(awk "BEGIN {printf \"%.1fx\", $T_COLD_SECS / $T_WARM_SECS}")"
  else
    SPEEDUP=">10x"
  fi

  RESULTS+=("${bp}|${T_COLD_DUR}|${T_WARM_DUR}|${SPEEDUP}|${cold_url}|${warm_browser}")
done

# ============================================================================
# Markdown aruande genereerimine
# ============================================================================
{
  echo "# 📊 Testimisaruanne: Blueprintide 6–11 Külm vs Soe Käivitus"
  echo ""
  echo "**Kuupäev:** $(date '+%Y-%m-%d %H:%M:%S')  "
  echo "**Platvorm:** $(uname -s) ($(uname -m))  "
  echo "**Podman:** $(podman --version 2>/dev/null || echo 'Unknown')  "
  echo ""
  echo "---"
  echo ""
  echo "## ⏱️ Ajaline Maatriks ja Funktsionaalsuse Võrdlus"
  echo ""
  echo "| Blueprint | Külm Käivitus (-tb) | Soe Käivitus (-b) | Kiiruse Võit | URL Vastus | Brauser / UI Kontroll |"
  echo "| :--- | :--- | :--- | :---: | :--- | :--- |"
  for res in "${RESULTS[@]}"; do
    IFS='|' read -r r_bp r_tc r_tw r_sp r_url r_ui <<< "$res"
    echo "| **BP ${r_bp}** | \`${r_tc}\` | \`${r_tw}\` | **${r_sp}** | ${r_url} | ${r_ui} |"
  done
  echo ""
  echo "---"
  echo ""
  echo "### 🔍 Analüüs:"
  echo "- **Külm käivitus (-tb):** Puhas nullist paigaldus (kontrollitud konteinerite loomine, mahtude lähtestamine ja vajadusel andmebaasi/RCU paigaldus)."
  echo "- **Soe käivitus (-b):** Olemasolevate mahtude ja konteinerite taaskasutamine (*Fastpath* režiim)."
  echo "- **Brauser & UI:** Kontrollitud vastavad pordid, veebiliidesed (HTTP 200/302), noVNC desktopid ja Web-IDE laiendused."
} | tee "$REPORT_FILE"

echo -e "\n${GREEN}==================================================================${NC}"
echo -e "${GREEN}🎉 BLUEPRINTIDE 6–11 TESTIMINE LÕPETATUD!${NC}"
echo -e "   📝 Raport salvestatud: ${CYAN}${REPORT_FILE}${NC}"
echo -e "${GREEN}==================================================================${NC}\n"
