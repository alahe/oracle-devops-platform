#!/usr/bin/env bash
# ==============================================================================
# Oracle DevOps Platform — Dev Hub Playwright UI Test Orchestrator
# Tests Developer Hub (docs/dev-hub.html) in real browser (Google Chrome / Edge)
# Supports:
#   --all               : Runs full suite (core, themes, lifecycle) in mock mode (~3-5s)
#   --group <name>      : Filters by group (core, themes, podman, etc.)
#   -b, --blueprint <ID>: Tests specific blueprint modal and lifecycle
#   --live              : Connects to live dev-hub-bridge (default: mock-by-default)
#   --headed            : Launches visual browser window for interactive debugging
#   --ui                : Opens interactive Playwright UI dashboard
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
UI_TEST_DIR="$SCRIPT_DIR/ui"

START_SECONDS=$SECONDS
START_TS="$(date '+%Y-%m-%d %H:%M:%S')"

# Default options
GROUP=""
BLUEPRINT_ID=""
HEADED=false
OPEN_UI=false
LIVE_MODE=false
SPEC_FILTER=""

# Parse CLI arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --all)
      GROUP=""
      shift
      ;;
    --group)
      GROUP="${2:-}"
      shift 2
      ;;
    -b|--blueprint)
      BLUEPRINT_ID="${2:-}"
      shift 2
      ;;
    --live)
      LIVE_MODE=true
      shift
      ;;
    --headed)
      HEADED=true
      shift
      ;;
    --ui)
      OPEN_UI=true
      shift
      ;;
    -h|--help)
      echo "Kasutus: $0 [--all] [--group <name>] [-b <id>] [--live] [--headed] [--ui]"
      echo "  --all              Käivita kõik UI testid (vaikimisi mock-režiim)"
      echo "  --group <nimi>     Grupp: core, themes, contrast, podman, etc."
      echo "  -b, --blueprint ID Testi kindla Blueprinti (0-11) UI-d ja modaali"
      echo "  --live             Kasuta reaalset silda (mitte mock)"
      echo "  --headed           Ava brauseriakken visuaalseks vaatamiseks"
      echo "  --ui               Ava Playwright interaktiivne testpaneel"
      exit 0
      ;;
    *)
      echo "Tundmatu parameeter: $1"
      exit 1
      ;;
  esac
done

echo "=============================================================================="
echo " 🎭 DEV HUB PLAYWRIGHT UI & E2E TEST RUNNER"
echo "=============================================================================="
echo " Režiim   : $([ "$LIVE_MODE" = true ] && echo 'LIVE BRIDGE' || echo 'DETERMINISTIC MOCK (Fast & Safe)')"
[ -n "$GROUP" ] && echo " Grupp    : $GROUP"
[ -n "$BLUEPRINT_ID" ] && echo " Blueprint: $BLUEPRINT_ID"
[ "$HEADED" = true ] && echo " Visuaalne: JAH (Headed)"
echo "------------------------------------------------------------------------------"

# Ensure Node.js is present
if ! command -v node >/dev/null 2>&1; then
  echo "❌ VIGA: Node.js ei leitud masinast! Palun paigalda Node.js (v18+)."
  exit 1
fi

# Ensure tests/ui/node_modules exists
if [ ! -d "$UI_TEST_DIR/node_modules/@playwright/test" ]; then
  echo "📦 Paigaldan isoleeritud Playwright mooduli kausta tests/ui/..."
  (cd "$UI_TEST_DIR" && npm install --no-audit --no-fund)
fi

# Setup environment variables for Playwright
export TEST_BLUEPRINT_ID="${BLUEPRINT_ID:-0}"
export TEST_LIVE_MODE="$LIVE_MODE"

PW_ARGS=()

if [ "$OPEN_UI" = true ]; then
  PW_ARGS+=("--ui")
fi

if [ "$HEADED" = true ]; then
  PW_ARGS+=("--headed")
fi

# Resolve specific spec file if group or blueprint is selected
if [ "$GROUP" = "themes" ] || [ "$GROUP" = "contrast" ]; then
  PW_ARGS+=("specs/theme-contrast.spec.js")
elif [ "$GROUP" = "core" ] || [ "$GROUP" = "navigation" ] || [ "$GROUP" = "i18n" ]; then
  PW_ARGS+=("specs/core-navigation.spec.js")
elif [ "$GROUP" = "podman" ] || [ -n "$BLUEPRINT_ID" ]; then
  PW_ARGS+=("specs/components-lifecycle.spec.js")
fi

RUNNER_ARGS=()
[ -n "$GROUP" ] && RUNNER_ARGS+=("--group" "$GROUP")
[ -n "$BLUEPRINT_ID" ] && RUNNER_ARGS+=("-b" "$BLUEPRINT_ID")
[ "$LIVE_MODE" = true ] && RUNNER_ARGS+=("--live")
[ "$HEADED" = true ] && RUNNER_ARGS+=("--headed")

echo "🚀 Käivitan testid..."
mkdir -p "$WORKSPACE_DIR/tests/reports" "$WORKSPACE_DIR/metrics"

set +e
node "$UI_TEST_DIR/runner.js" ${RUNNER_ARGS[@]+"${RUNNER_ARGS[@]}"}
EXIT_CODE=$?
set -e

ELAPSED=$(( SECONDS - START_SECONDS ))
END_TS="$(date '+%Y-%m-%d %H:%M:%S')"

# Persist metrics (Rule 1)
METRICS_JSON="$WORKSPACE_DIR/metrics/devhub_ui_benchmarks.json"
cat << METRICSEOF > "$METRICS_JSON"
{
  "suite": "devhub_ui_playwright",
  "status": $([ $EXIT_CODE -eq 0 ] && echo '"PASS"' || echo '"FAIL"'),
  "duration_seconds": $ELAPSED,
  "start_time": "$START_TS",
  "end_time": "$END_TS",
  "group": "${GROUP:-all}",
  "blueprint": "${BLUEPRINT_ID:-none}",
  "live_mode": $LIVE_MODE
}
METRICSEOF

# Generate Markdown report for Dev Hub Reports tab
REPORT_MD="$WORKSPACE_DIR/tests/reports/devhub_ui_test_report.md"
cat << REPORTEOF > "$REPORT_MD"
# 🎭 Dev Hub Playwright UI Test Report

- **Staatus:** $([ $EXIT_CODE -eq 0 ] && echo '✅ PASS' || echo '❌ FAIL')
- **Kestus:** ${ELAPSED}s
- **Käivitatud:** ${START_TS}
- **Režiim:** $([ "$LIVE_MODE" = true ] && echo 'Live Bridge' || echo 'Mock Safe')
- **Grupp:** ${GROUP:-all}
- **Blueprint:** ${BLUEPRINT_ID:-kõik}

## Tulemuste Kokkuvõte
| Valdkond | Kontroll | Tulemus |
| :--- | :--- | :--- |
| **Navigatsioon & i18n** | Vahelehed, 6 keelt, konsoolivead puuduvad | $([ $EXIT_CODE -eq 0 ] && echo '✅ Korras' || echo '⚠️ Vaata logi') |
| **Teemad & Kontrast** | Hele/tume vahetus, musti kaste pole, WCAG 2.1 AA | $([ $EXIT_CODE -eq 0 ] && echo '✅ Korras' || echo '⚠️ Vaata logi') |
| **Komponendid** | Podman stardiliides, Blueprint detailid, Modaalid | $([ $EXIT_CODE -eq 0 ] && echo '✅ Korras' || echo '⚠️ Vaata logi') |

*Täielik HTML raport asub failis: \`tests/reports/playwright-report/index.html\`*
REPORTEOF

echo "------------------------------------------------------------------------------"
if [ $EXIT_CODE -eq 0 ]; then
  echo "✅ KÕIK DEV HUB UI TESTID LÄBITUD EDUKALT (${ELAPSED}s)"
  echo "📊 Raport salvestatud: tests/reports/devhub_ui_test_report.md"
else
  echo "❌ MÕNI TEST EBAÕNNESTUS (kood: $EXIT_CODE, kestus: ${ELAPSED}s)"
  echo "📸 Vaata vigade ekraanipilte kaustast: tests/reports/ui-failures/"
fi
echo "=============================================================================="

exit $EXIT_CODE
