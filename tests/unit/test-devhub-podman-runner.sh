#!/usr/bin/env bash
# ==============================================================================
# Unit Test: Dev Hub Podman Engine Startup & Lifecycle Automation
# Validates:
#   1. Backend bridge API whitelist & engine status query
#   2. Template structure: dynamic CTA button, dropdown, empty-state hero, DevOps card
#   3. Frontend application functions in app.js
#   4. 6-language i18n parity in i18n.js
#   5. Generated docs/dev-hub.html integrity
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "🔍 Starting Unit Test: Dev Hub Podman Engine Startup & Lifecycle Automation..."

BRIDGE_PY="$WORKSPACE_DIR/scripts/internal/dev-hub-bridge.py"
LAYOUT_HTML="$WORKSPACE_DIR/scripts/internal/dev_hub/assets/templates/layout.html"
APP_JS="$WORKSPACE_DIR/scripts/internal/dev_hub/assets/app.js"
I18N_JS="$WORKSPACE_DIR/scripts/internal/dev_hub/assets/i18n.js"
DEV_HUB_HTML="$WORKSPACE_DIR/docs/dev-hub.html"

# ------------------------------------------------------------------------------
# 1. Backend Bridge Verification
# ------------------------------------------------------------------------------
echo "  [1/5] Verifying backend dev-hub-bridge.py..."
if [ ! -f "$BRIDGE_PY" ]; then
  echo "❌ Error: $BRIDGE_PY not found!"
  exit 1
fi

python3 -m py_compile "$BRIDGE_PY"
echo "    ✅ dev-hub-bridge.py syntax OK"

# Check whitelist entries
python3 -c "
with open('$BRIDGE_PY', 'r', encoding='utf-8') as f:
    code = f.read()

assert '\"podman-machine-start\":' in code, 'Missing podman-machine-start in DEVOPS_WHITELIST'
assert '\"podman-machine-stop\":' in code, 'Missing podman-machine-stop in DEVOPS_WHITELIST'
assert 'def get_podman_engine_status():' in code, 'Missing get_podman_engine_status function'
assert 'def handle_podman_engine_start(' in code, 'Missing handle_podman_engine_start handler'
print('    ✅ Bridge whitelist, engine status query, and startup handlers present')
"

# ------------------------------------------------------------------------------
# 2. Template Structure Verification (layout.html)
# ------------------------------------------------------------------------------
echo "  [2/5] Verifying layout.html elements..."
for element_id in \
  "btn-podman-primary-action" \
  "btn-podman-dropdown-toggle" \
  "podman-startup-menu" \
  "menu-item-podman-machine-start" \
  "menu-item-podman-machine-stop" \
  "podman-empty-hero" \
  "podman-hero-title" \
  "podman-hero-desc" \
  "podman-hero-btn-primary" \
  "card-devops-podman-machine"; do
  if ! grep -q "id=\"$element_id\"" "$LAYOUT_HTML"; then
    echo "❌ Error: Missing element id '$element_id' in layout.html"
    exit 1
  fi
done
echo "    ✅ All required Podman UI template elements exist in layout.html"

# ------------------------------------------------------------------------------
# 3. Frontend App Logic Verification (app.js)
# ------------------------------------------------------------------------------
echo "  [3/5] Verifying frontend app.js logic..."
if command -v node >/dev/null 2>&1; then
  node -c "$APP_JS"
  echo "    ✅ app.js syntax OK"
fi

for js_fn in \
  "togglePodmanStartupMenu" \
  "updatePodmanStartupUI" \
  "checkPodmanEngineStatus" \
  "triggerSmartPodmanStartup" \
  "gPodmanEngineStatus"; do
  if ! grep -q "$js_fn" "$APP_JS"; then
    echo "❌ Error: Missing function/variable '$js_fn' in app.js"
    exit 1
  fi
done
echo "    ✅ Podman lifecycle and UI synchronization methods verified in app.js"

# ------------------------------------------------------------------------------
# 4. 6-Language i18n Parity (i18n.js)
# ------------------------------------------------------------------------------
echo "  [4/5] Verifying 6-language i18n parity in i18n.js..."
if command -v node >/dev/null 2>&1; then
  node -c "$I18N_JS"
  echo "    ✅ i18n.js syntax OK"

  node -e "
    const fs = require('fs');
    const content = fs.readFileSync('$I18N_JS', 'utf8');
    const I18N_DICT = new Function(content + '; return I18N_DICT;')();

    const requiredKeys = [
      'btn_podman_smart_start',
      'btn_podman_start_machine',
      'btn_podman_start_containers',
      'menu_podman_auto',
      'menu_podman_auto_desc',
      'menu_podman_machine_start',
      'menu_podman_containers_start',
      'menu_podman_machine_stop',
      'podman_hero_default_title',
      'podman_hero_default_desc',
      'podman_hero_machine_stopped_title',
      'podman_hero_machine_stopped_desc',
      'podman_hero_containers_stopped_title',
      'podman_hero_containers_stopped_desc',
      'title_devops_podman_machine',
      'desc_devops_podman_machine',
      'btn_start_machine',
      'btn_stop_machine'
    ];

    const languages = ['en', 'et', 'fi', 'sv', 'lv', 'lt'];
    for (const lang of languages) {
      if (!I18N_DICT[lang]) throw new Error('Missing language dict: ' + lang);
      for (const key of requiredKeys) {
        if (!I18N_DICT[lang][key]) {
          throw new Error('Missing key \"' + key + '\" in language ' + lang);
        }
      }
    }
    console.log('    ✅ 100% i18n symmetry: all ' + requiredKeys.length + ' keys present across all 6 languages');
  "
fi

# ------------------------------------------------------------------------------
# 5. Compiled Dev Hub HTML Verification (docs/dev-hub.html)
# ------------------------------------------------------------------------------
echo "  [5/5] Verifying compiled docs/dev-hub.html..."
if [ ! -f "$DEV_HUB_HTML" ]; then
  "$WORKSPACE_DIR/scripts/internal/generate-dev-hub.sh" "$DEV_HUB_HTML"
fi

for expected_marker in \
  "btn-podman-primary-action" \
  "podman-empty-hero" \
  "card-devops-podman-machine" \
  "triggerSmartPodmanStartup" \
  "checkPodmanEngineStatus"; do
  if ! grep -q "$expected_marker" "$DEV_HUB_HTML"; then
    echo "❌ Error: Missing compiled marker '$expected_marker' in $DEV_HUB_HTML"
    exit 1
  fi
done
echo "    ✅ Compiled docs/dev-hub.html contains all Podman startup features"

echo "================================================================================"
echo "🎉 ALL DEV HUB PODMAN RUNNER TESTS PASSED! (100% OK)"
echo "================================================================================"
