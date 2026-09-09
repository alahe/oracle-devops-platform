#!/usr/bin/env bash
# ==============================================================================
# Unit Test: Developer Hub Automated Testing Tab (tab-testing) Verification
# Validates presence of testing tab, sub-tabs, CI scorecard, bridge endpoints,
# documentation parity across 6 languages, and pre-packaged compilation.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "🧪 Running unit tests for Dev Hub testing tab (tab-testing)..."

ERRORS=0

assert_contains() {
  local file="$1"
  local pattern="$2"
  local label="$3"
  if grep -Fq "$pattern" "$file"; then
    echo "  ✅ $label"
  else
    echo "  ❌ FAIL: Missing '$pattern' in $file ($label)"
    ERRORS=$((ERRORS + 1))
  fi
}

# 1. Check layout.html and dev-hub.html
DEV_HUB_HTML="$WORKSPACE_DIR/docs/dev-hub.html"
LAYOUT_HTML="$WORKSPACE_DIR/scripts/internal/dev_hub/assets/templates/layout.html"

echo "Checking HTML structure in layout template & compiled dev-hub.html..."
assert_contains "$LAYOUT_HTML" 'id="tab-testing"' "Testing tab container exists in layout"
assert_contains "$LAYOUT_HTML" 'id="testing-ci-scorecard"' "CI Readiness Scorecard strip exists in layout"
assert_contains "$LAYOUT_HTML" 'id="testing-subtab-runner"' "Sub-tab runner exists in layout"
assert_contains "$LAYOUT_HTML" 'id="testing-subtab-reports"' "Sub-tab reports exists in layout"
assert_contains "$LAYOUT_HTML" 'id="testing-subtab-coverage"' "Sub-tab coverage exists in layout"
assert_contains "$LAYOUT_HTML" 'id="testing-subtab-history"' "Sub-tab history exists in layout"
assert_contains "$LAYOUT_HTML" 'id="testing-terminal-output"' "Embedded terminal console exists in layout"
assert_contains "$LAYOUT_HTML" 'id="test-terminal-lang-badge"' "Language indicator badge exists in layout"
assert_contains "$LAYOUT_HTML" 'id="modal-suite-tests"' "Suite tests inspection modal exists in layout"
assert_contains "$LAYOUT_HTML" 'id="suite-script-viewer-view"' "Script viewer container exists in layout"

assert_contains "$DEV_HUB_HTML" 'id="tab-testing"' "Testing tab container exists in dev-hub.html"
assert_contains "$DEV_HUB_HTML" 'id="test-terminal-lang-badge"' "Language indicator badge exists in dev-hub.html"
assert_contains "$DEV_HUB_HTML" 'id="modal-suite-tests"' "Suite tests inspection modal exists in dev-hub.html"
assert_contains "$DEV_HUB_HTML" 'id="suite-script-viewer-view"' "Script viewer container exists in dev-hub.html"
assert_contains "$DEV_HUB_HTML" 'const TEST_SUITES_DATA = {' "TEST_SUITES_DATA embedded in dev-hub.html"
assert_contains "$DEV_HUB_HTML" 'const TEST_REPORTS_DATA = [' "TEST_REPORTS_DATA embedded in dev-hub.html"
assert_contains "$DEV_HUB_HTML" 'const TEST_COVERAGE_DATA = {' "TEST_COVERAGE_DATA embedded in dev-hub.html"

# 2. Check dev-hub-bridge.py endpoints
BRIDGE_PY="$WORKSPACE_DIR/scripts/internal/dev-hub-bridge.py"
echo "Checking Bridge API endpoints..."
assert_contains "$BRIDGE_PY" '/api/tests/suites' "Bridge endpoint: /api/tests/suites"
assert_contains "$BRIDGE_PY" '/api/tests/reports' "Bridge endpoint: /api/tests/reports"
assert_contains "$BRIDGE_PY" '/api/tests/report-content' "Bridge endpoint: /api/tests/report-content"
assert_contains "$BRIDGE_PY" '/api/tests/script-content' "Bridge endpoint: /api/tests/script-content"
assert_contains "$BRIDGE_PY" '/api/tests/coverage' "Bridge endpoint: /api/tests/coverage"
assert_contains "$BRIDGE_PY" '/api/tests/history' "Bridge endpoint: /api/tests/history"
assert_contains "$BRIDGE_PY" '/api/tests/run' "Bridge endpoint: /api/tests/run"
assert_contains "$BRIDGE_PY" '/api/tests/stop' "Bridge endpoint: /api/tests/stop"

# 3. Check i18n keys
I18N_JS="$WORKSPACE_DIR/scripts/internal/dev_hub/assets/i18n.js"
echo "Checking 6-language i18n keys..."
assert_contains "$I18N_JS" 'tab_testing: "Testing"' "EN translation: tab_testing"
assert_contains "$I18N_JS" 'tab_testing: "Testimine"' "ET translation: tab_testing"
assert_contains "$I18N_JS" 'btn_view_script_source: "View Code"' "EN translation: btn_view_script_source"
assert_contains "$I18N_JS" 'btn_view_script_source: "Vaata koodi"' "ET translation: btn_view_script_source"
assert_contains "$I18N_JS" 'tab_testing: "Testaus"' "FI translation: tab_testing"
assert_contains "$I18N_JS" 'tab_testing: "Testning"' "SV translation: tab_testing"
assert_contains "$I18N_JS" 'tab_testing: "Testēšana"' "LV translation: tab_testing"
assert_contains "$I18N_JS" 'tab_testing: "Testavimas"' "LT translation: tab_testing"

# 4. Check documentation files across all 6 languages
echo "Checking documentation files..."
for lang_path in \
  "docs/testing-framework-and-devhub.md" \
  "docs/et/testing-framework-and-devhub.md" \
  "docs/fi/testing-framework-and-devhub.md" \
  "docs/sv/testing-framework-and-devhub.md" \
  "docs/lv/testing-framework-and-devhub.md" \
  "docs/lt/testing-framework-and-devhub.md"
do
  full_path="$WORKSPACE_DIR/$lang_path"
  if [ -f "$full_path" ]; then
    echo "  ✅ Doc file exists: $lang_path"
    if grep -Fq "flowchart TD" "$full_path"; then
      echo "    ✅ Mermaid diagram embedded in $lang_path"
    else
      echo "    ❌ Missing Mermaid diagram in $lang_path"
      ERRORS=$((ERRORS + 1))
    fi
  else
    echo "  ❌ FAIL: Missing doc file: $lang_path"
    ERRORS=$((ERRORS + 1))
  fi
done

# 5. Check catalog.py registration
CATALOG_PY="$WORKSPACE_DIR/scripts/internal/dev_hub/catalog.py"
echo "Checking catalog registration..."
assert_contains "$CATALOG_PY" '"id": "testing-framework"' "Registered in DOC_SPECS"

# 6. Check Blueprint modal Testing & Diagnostics tab includes Dry-Run card
APP_JS="$WORKSPACE_DIR/scripts/internal/dev_hub/assets/app.js"
echo "Checking Blueprint modal Testing & Diagnostics tab (Dry-Run card placement)..."
assert_contains "$APP_JS" "key: 'dry-run'" "Dry-Run card registered in renderBlueprintDiagTab (app.js)"
assert_contains "$DEV_HUB_HTML" "key: 'dry-run'" "Dry-Run card compiled into renderBlueprintDiagTab (dev-hub.html)"

# 7. Check Blueprint modal Execution Logs tab (tab-btn-bp-logs / bp-modal-tab-logs)
echo "Checking Blueprint modal Execution Logs tab..."
assert_contains "$LAYOUT_HTML" 'id="tab-btn-bp-logs"' "Blueprint modal tab button exists in layout.html"
assert_contains "$DEV_HUB_HTML" 'id="tab-btn-bp-logs"' "Blueprint modal tab button exists in dev-hub.html"
assert_contains "$LAYOUT_HTML" 'id="bp-modal-tab-logs"' "Blueprint modal logs container exists in layout.html"
assert_contains "$DEV_HUB_HTML" 'id="bp-modal-tab-logs"' "Blueprint modal logs container exists in dev-hub.html"
assert_contains "$LAYOUT_HTML" 'class="bp-logs-split-container"' "Master-Detail split container exists in layout.html"
assert_contains "$LAYOUT_HTML" 'id="bp-modal-logs-list-pane"' "Left list pane exists in layout.html"
assert_contains "$LAYOUT_HTML" 'id="bp-modal-logs-viewer-pane"' "Right viewer pane exists in layout.html"
assert_contains "$LAYOUT_HTML" 'id="bp-log-search-input"' "Search input exists in layout.html"
assert_contains "$APP_JS" "renderBlueprintLogsTab" "renderBlueprintLogsTab function exists in app.js"
assert_contains "$APP_JS" "filterBpLogsCategory" "filterBpLogsCategory function exists in app.js"
assert_contains "$APP_JS" "selectBpLogFile" "selectBpLogFile function exists in app.js"
assert_contains "$DEV_HUB_HTML" "renderBlueprintLogsTab" "renderBlueprintLogsTab function compiled into dev-hub.html"
assert_contains "$DEV_HUB_HTML" "filterBpLogsCategory" "filterBpLogsCategory compiled into dev-hub.html"
assert_contains "$DEV_HUB_HTML" "selectBpLogFile" "selectBpLogFile compiled into dev-hub.html"
assert_contains "$BRIDGE_PY" '/api/logs/blueprint' "Bridge endpoint: /api/logs/blueprint"
assert_contains "$I18N_JS" 'modal_tab_logs: "📄 Execution Logs"' "EN translation: modal_tab_logs"
assert_contains "$I18N_JS" 'modal_tab_logs: "📄 Teostuse logid"' "ET translation: modal_tab_logs"
assert_contains "$I18N_JS" 'logs_cat_setup: "Setup"' "EN translation: logs_cat_setup"
assert_contains "$I18N_JS" 'logs_cat_setup: "Paigaldus"' "ET translation: logs_cat_setup"

if [ "$ERRORS" -gt 0 ]; then
  echo "❌ $ERRORS assertions failed."
  exit 1
fi

echo "🎉 All Dev Hub testing tab unit tests passed successfully!"
exit 0

