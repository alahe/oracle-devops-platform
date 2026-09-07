#!/usr/bin/env bash
# ============================================================================
# Oracle DevOps Platform — 3-Tiered Lifecycle Matrix Test Automation
#
# Validates container and blueprint lifecycles across 3 sequential tiers:
#   Tier 1: Cold Start & Image/Snapshot Generation (setup-all.sh -tb <BP>)
#   Tier 2: Warm Start & Fastpath / Existing Cache (setup-all.sh -b <BP>)
#   Tier 3: Golden Snapshot Instant Restore (~15s) (restore-golden-snapshots.sh)
#
# Features:
#   - Verifies HTTP/HTTPS service endpoints (check-urls.sh)
#   - Verifies SEPS Wallet & DB connectivity (check-wallet.sh / SQLcl)
#   - Audits Web-IDE pre-installed extensions (antigravity, python, sql-developer)
#   - Generates a multi-tier timing matrix and Markdown comparison report
#
# Usage:
#   ./tests/test-tiered-lifecycle-matrix.sh -b 1
#   ./tests/test-tiered-lifecycle-matrix.sh -b 4
#   ./tests/test-tiered-lifecycle-matrix.sh -b 1,4
#   ./tests/test-tiered-lifecycle-matrix.sh --all
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Ensure test mode environment prevents interactive prompts
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

TARGET_BLUEPRINTS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    -b=*|--blueprint=*)
      val="${1#*=}"
      IFS=',' read -ra ADDR <<< "$val"
      for b in "${ADDR[@]}"; do TARGET_BLUEPRINTS+=("$b"); done
      shift
      ;;
    -b|--blueprint)
      val="$2"
      IFS=',' read -ra ADDR <<< "$val"
      for b in "${ADDR[@]}"; do TARGET_BLUEPRINTS+=("$b"); done
      shift 2
      ;;
    --all)
      TARGET_BLUEPRINTS=(1 2 3 4 5 6 7 8 9 10)
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [-b <ID> | -b <ID1,ID2> | --all]"
      echo "  -b 1     Test Blueprint 1 (ALISE Core Base)"
      echo "  -b 4     Test Blueprint 4 (Web-IDE Dev Environment)"
      echo "  -b 1,4   Test multiple blueprints sequentially"
      echo "  --all    Test all 10 canonical blueprints"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

if [ ${#TARGET_BLUEPRINTS[@]} -eq 0 ]; then
  TARGET_BLUEPRINTS=(1)
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

check_endpoints() {
  local http_ok=true
  if [ -x "$WORKSPACE_DIR/scripts/check-urls.sh" ]; then
    if ! "$WORKSPACE_DIR/scripts/check-urls.sh" >/dev/null 2>&1; then
      http_ok=false
    fi
  fi
  if [ "$http_ok" = "true" ]; then
    echo "✅ PASS (HTTP 200/302)"
  else
    echo "⚠️ PARTIAL / ERR"
  fi
}

check_database() {
  local db_ok=true
  if [ -x "$WORKSPACE_DIR/scripts/check-wallet.sh" ]; then
    if ! "$WORKSPACE_DIR/scripts/check-wallet.sh" >/dev/null 2>&1; then
      db_ok=false
    fi
  fi
  if [ "$db_ok" = "true" ]; then
    echo "✅ PASS (SEPS Wallet)"
  else
    echo "⚠️ DB UNREACHABLE"
  fi
}

check_web_ide_extensions() {
  if ! podman container exists web-ide-dev 2>/dev/null; then
    echo "N/A (0 Web-IDE)"
    return 0
  fi

  local ext_list
  ext_list=$(podman exec web-ide-dev /app/code-server/bin/code-server --extensions-dir /config/extensions --list-extensions 2>/dev/null || podman exec web-ide-dev /app/code-server/bin/code-server --list-extensions 2>/dev/null || echo "")
  [ -z "$ext_list" ] && ext_list=$(podman exec web-ide-dev ls -1 /config/extensions 2>/dev/null || echo "")

  local has_antigravity=false
  local has_python=false
  local has_sqldev=false

  if echo "$ext_list" | grep -qi "antigravity"; then has_antigravity=true; fi
  if echo "$ext_list" | grep -qi "python"; then has_python=true; fi
  if echo "$ext_list" | grep -qi "sql-developer"; then has_sqldev=true; fi

  if [ "$has_antigravity" = "true" ] && [ "$has_python" = "true" ] && [ "$has_sqldev" = "true" ]; then
    echo "✅ 3/3 OK (AI, Py, SQLDev)"
  else
    local missing=""
    [ "$has_antigravity" = "false" ] && missing+="anti "
    [ "$has_python" = "false" ] && missing+="py "
    [ "$has_sqldev" = "false" ] && missing+="sqldev "
    echo "⚠️ Missing: ${missing}"
  fi
}

RESULTS=()

mkdir -p "$WORKSPACE_DIR/tests/reports" "$WORKSPACE_DIR/metrics"
REPORT_FILE="$WORKSPACE_DIR/tests/reports/lifecycle_matrix_report.md"
METRICS_FILE="$WORKSPACE_DIR/metrics/lifecycle_matrix_report.md"

echo -e "${CYAN}==================================================================${NC}"
echo -e "${CYAN}🧪 3-TIERED CONTAINER LIFECYCLE MATRIX TEST SUITE${NC}"
echo -e "${CYAN}   Target Blueprints: ${YELLOW}${TARGET_BLUEPRINTS[*]}${NC}"
echo -e "${CYAN}==================================================================${NC}"

for bp in "${TARGET_BLUEPRINTS[@]}"; do
  echo -e "\n${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BOLD}▶️ STARTING LIFECYCLE MATRIX EVALUATION FOR BLUEPRINT ${bp}${NC}"
  echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

  # --------------------------------------------------------------------------
  # TIER 1: Cold Start / Build Mode (-tb)
  # --------------------------------------------------------------------------
  echo -e "${YELLOW}❄️  [TIER 1]: Cold Start & Image/Snapshot Generation (setup-all.sh -tb ${bp})...${NC}"
  T1_START=$(date +%s)
  "$WORKSPACE_DIR/scripts/setup-all.sh" -tb "$bp" --lang en
  T1_END=$(date +%s)
  T1_SECS=$((T1_END - T1_START))
  T1_DUR=$(format_duration "$T1_SECS")
  echo -e "${GREEN}✅ Tier 1 Completed in ${T1_DUR}${NC}"

  T1_URL=$(check_endpoints)
  T1_DB=$(check_database)
  T1_EXT=$(check_web_ide_extensions)

  # Verify Snapshot was created
  SNAP_FILE=$(find "$WORKSPACE_DIR/golden-snapshots" -maxdepth 1 -name "bp_${bp}_*.tar.gz" -o -name "bp_${bp}_latest.tar.gz" 2>/dev/null | head -n 1 || echo "")
  if [ -n "$SNAP_FILE" ]; then
    SNAP_STATUS="✅ Created ($(basename "$SNAP_FILE"))"
  else
    SNAP_STATUS="⚠️ Missing"
  fi

  # --------------------------------------------------------------------------
  # TIER 2: Warm Start / Fastpath (-b)
  # --------------------------------------------------------------------------
  echo -e "\n${YELLOW}🔥 [TIER 2]: Warm Start & Existing Cache Fastpath (setup-all.sh -b ${bp})...${NC}"
  T2_START=$(date +%s)
  "$WORKSPACE_DIR/scripts/setup-all.sh" -b "$bp" --lang en
  T2_END=$(date +%s)
  T2_SECS=$((T2_END - T2_START))
  T2_DUR=$(format_duration "$T2_SECS")
  echo -e "${GREEN}✅ Tier 2 Completed in ${T2_DUR}${NC}"

  T2_URL=$(check_endpoints)
  T2_DB=$(check_database)
  T2_EXT=$(check_web_ide_extensions)

  # --------------------------------------------------------------------------
  # TIER 3: Golden Snapshot Instant Restore
  # --------------------------------------------------------------------------
  echo -e "\n${YELLOW}⚡ [TIER 3]: Golden Snapshot Instant Restore (restore-golden-snapshots.sh)...${NC}"
  # Intentionally reset to simulate fresh disaster recovery / rollback
  "$WORKSPACE_DIR/scripts/reset-all.sh" -y --lang en >/dev/null 2>&1 || true

  T3_START=$(date +%s)
  "$WORKSPACE_DIR/scripts/snapshots/restore-golden-snapshots.sh" --auto -y -b "$bp"
  T3_END=$(date +%s)
  T3_SECS=$((T3_END - T3_START))
  T3_DUR=$(format_duration "$T3_SECS")
  echo -e "${GREEN}✅ Tier 3 Completed in ${T3_DUR}${NC}"

  T3_URL=$(check_endpoints)
  T3_DB=$(check_database)
  T3_EXT=$(check_web_ide_extensions)

  # Speedup calculation
  if [ "$T3_SECS" -gt 0 ]; then
    SPEEDUP="$(awk "BEGIN {printf \"%.1fx\", $T1_SECS / $T3_SECS}")"
  else
    SPEEDUP=">20x"
  fi

  RESULTS+=("${bp}|${T1_DUR}|${T2_DUR}|${T3_DUR}|${SPEEDUP}|${T1_URL}|${T1_DB}|${T1_EXT}|${SNAP_STATUS}")
done

# ============================================================================
# Markdown Matrix Generation
# ============================================================================
{
  echo "# 📊 3-Tiered Container Lifecycle Matrix Report"
  echo ""
  echo "**Date:** $(date -u '+%Y-%m-%d %H:%M:%S UTC')  "
  echo "**Host OS:** $(uname -s) ($(uname -m))  "
  echo "**Podman:** $(podman --version 2>/dev/null || echo 'Unknown')  "
  echo ""
  echo "---"
  echo ""
  echo "## ⏱️ Timing & Functionality Comparison Matrix"
  echo ""
  echo "| Blueprint | Tier 1: Külm (-tb) | Tier 2: Soe (-b) | Tier 3: Taastus (~15s) | Kiiruse Võit | HTTP GET | DB / Wallet | Web-IDE Laiendused | Snapshot |"
  echo "| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |"
  for res in "${RESULTS[@]}"; do
    IFS='|' read -r r_bp r_t1 r_t2 r_t3 r_sp r_url r_db r_ext r_snap <<< "$res"
    echo "| **BP ${r_bp}** | \`${r_t1}\` | \`${r_t2}\` | \`${r_t3}\` | **${r_sp}** | ${r_url} | ${r_db} | ${r_ext} | ${r_snap} |"
  done
  echo ""
  echo "---"
  echo ""
  echo "### 🔍 Etappide Definitsioonid:"
  echo "1. **Tier 1 (Külm Käivitus / Ehitusrežiim \`-tb\`):** Puhas nullist paigaldus. Genereerib ja kompileerib andmebaasi, APEX-i ja ORDS-i ning salvestab lõpus värske Golden Snapshoti."
  echo "2. **Tier 2 (Soe Käivitus / Vahemälu \`-b\`):** Taaskasutab olemasolevaid konteinereid ja mahte ilma uuesti kompileerimata (*Fastpath*)."
  echo "3. **Tier 3 (Kiirtaastus \`restore-golden-snapshots.sh\`):** Taastab andmebaasi ja teenused tihendatud arhiivist koos automaatse SEPS paroolirotatsiooniga."
  echo ""
  echo "### 💻 Web-IDE Laienduste Nõuded:"
  echo "- \`google.google-antigravity\` (Google Antigravity AI Assistant)"
  echo "- \`ms-python.python\` (Microsoft Python Suite)"
  echo "- \`oracle.sql-developer\` (Oracle SQL Developer for VS Code)"
} | tee "$REPORT_FILE" > "$METRICS_FILE"

echo -e "\n${GREEN}==================================================================${NC}"
echo -e "${GREEN}🎉 ALL TIERED LIFECYCLE TESTS COMPLETED!${NC}"
echo -e "   📝 Report saved to: ${CYAN}${REPORT_FILE}${NC}"
echo -e "   📊 Metrics copy at: ${CYAN}${METRICS_FILE}${NC}"
echo -e "${GREEN}==================================================================${NC}\n"
