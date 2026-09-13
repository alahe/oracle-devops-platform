#!/bin/bash
# ==============================================================================
# Unit Test: Publisher Report Lab (Dev Hub, VS Code, and Designer Integration)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "🧪 Running unit tests for Publisher Report Lab & Designer Integration..."

# 1. Check template catalog discovery in dev-hub-bridge.py
echo "  [1/6] Checking template catalog discovery function..."
python3 -c "
import sys, os, importlib.util
spec = importlib.util.spec_from_file_location('dev_hub_bridge', '$WORKSPACE_DIR/scripts/internal/dev-hub-bridge.py')
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)
tpls = mod.get_publisher_templates_catalog()
assert len(tpls) >= 8, f'Expected at least 8 templates, found {len(tpls)}'
cats = set(t['category'] for t in tpls)
assert 'samples' in cats, 'Missing samples category'
assert 'accessibility' in cats, 'Missing accessibility category'
assert 'custom' in cats, 'Missing custom category'
for t in tpls:
    assert 'id' in t and 'name' in t and 'rtf_path' in t
    assert os.path.isfile(os.path.join('$WORKSPACE_DIR', t['rtf_path'])), f'File missing: {t[\"rtf_path\"]}'
"
echo "     ✅ Template catalog discovery verified across samples, accessibility, and custom reports!"

# 2. Check .vscode/tasks.json Publisher tasks
echo "  [2/6] Checking .vscode/tasks.json Publisher tasks..."
TASKS_JSON="$WORKSPACE_DIR/.vscode/tasks.json"
grep -q "Publisher: ⚡ Quick Render RTF to PDF" "$TASKS_JSON" || { echo "❌ Missing Quick Render task in tasks.json"; exit 1; }
grep -q "Publisher: 🚀 Deploy Report to Server & Test" "$TASKS_JSON" || { echo "❌ Missing Deploy task in tasks.json"; exit 1; }
grep -q "Publisher: 🔄 Start Live Auto-Watcher" "$TASKS_JSON" || { echo "❌ Missing Auto-Watcher task in tasks.json"; exit 1; }
echo "     ✅ .vscode/tasks.json contains all 3 Publisher developer tasks!"

# 3. Check i18n 6-language parity for Report Lab keys
echo "  [3/6] Checking i18n 6-language parity for Report Lab keys..."
python3 -c "
import re
with open('$WORKSPACE_DIR/scripts/internal/dev_hub/assets/i18n.js') as f:
    content = f.read()

langs = ['en', 'et', 'fi', 'sv', 'lv', 'lt']
required_keys = ['btn_report_lab', 'report_lab_title', 'report_select_template', 'btn_quick_preview', 'btn_deploy_publisher', 'btn_run_e2e_test']
for lang in langs:
    for k in required_keys:
        pattern = rf'{lang}:\s*\{{[^}}]*{k}:'
        assert re.search(pattern, content, re.DOTALL), f'Key {k} missing in language {lang}'
"
echo "     ✅ All Report Lab i18n keys verified across all 6 languages!"

# 4. Check layout.html modal markup and cockpit button
echo "  [4/6] Checking layout.html Report Lab modal & toolbar button..."
LAYOUT_HTML="$WORKSPACE_DIR/scripts/internal/dev_hub/assets/templates/layout.html"
DEV_HUB_HTML="$WORKSPACE_DIR/docs/dev-hub.html"
grep -q "report-studio-modal-backdrop" "$LAYOUT_HTML" || { echo "❌ Missing report-studio-modal-backdrop in layout.html"; exit 1; }
grep -q "btn-test-e2e" "$LAYOUT_HTML" || { echo "❌ Missing btn-test-e2e in layout.html"; exit 1; }
grep -q "openReportStudioModal()" "$DEV_HUB_HTML" || { echo "❌ Missing openReportStudioModal() in docs/dev-hub.html"; exit 1; }
echo "     ✅ layout.html and dev-hub.html contain Report Lab modal, triggers, and E2E test button!"

# 5. Check app.js Report Studio functions
echo "  [5/6] Checking app.js Report Studio functions..."
APP_JS="$WORKSPACE_DIR/scripts/internal/dev_hub/assets/app.js"
grep -q "function openReportStudioModal" "$APP_JS" || { echo "❌ Missing openReportStudioModal in app.js"; exit 1; }
grep -q "function renderReportPreview" "$APP_JS" || { echo "❌ Missing renderReportPreview in app.js"; exit 1; }
grep -q "function deployReportToServer" "$APP_JS" || { echo "❌ Missing deployReportToServer in app.js"; exit 1; }
grep -q "function auditReportAccessibility" "$APP_JS" || { echo "❌ Missing auditReportAccessibility in app.js"; exit 1; }
grep -q "function runPublisherE2ETest" "$APP_JS" || { echo "❌ Missing runPublisherE2ETest in app.js"; exit 1; }
echo "     ✅ app.js contains all Report Studio functions including E2E testing!"

# 6. Check Designer entrypoint.sh desktop entry
echo "  [6/6] Checking Designer entrypoint.sh desktop integration..."
ENTRYPOINT_SH="$WORKSPACE_DIR/docker/publisher-designer/entrypoint.sh"
grep -q "Deploy-To-Publisher.desktop" "$ENTRYPOINT_SH" || { echo "❌ Missing Deploy-To-Publisher.desktop in entrypoint.sh"; exit 1; }
grep -q "TITLE_DEPLOY=" "$ENTRYPOINT_SH" || { echo "❌ Missing TITLE_DEPLOY in entrypoint.sh"; exit 1; }
echo "     ✅ entrypoint.sh contains Deploy desktop entry and localized titles!"

echo "🎉 All Publisher Report Lab & Designer unit tests passed successfully!"
