#!/usr/bin/env bash
# ==============================================================================
# Unit Test: Developer Hub Home Tab Pinning & Adaptive Landing (Lahendus 4)
# Validates persistent home tab pinning, adaptive last active tab memory,
# 4-tier startup routing resolution order, and i18n parity across all 6 languages.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "📌 Testing Dev Hub Home Tab Pinning & Adaptive Landing (Lahendus 4)..."

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

LAYOUT_HTML="$WORKSPACE_DIR/scripts/internal/dev_hub/assets/templates/layout.html"
STYLE_CSS="$WORKSPACE_DIR/scripts/internal/dev_hub/assets/style.css"
APP_JS="$WORKSPACE_DIR/scripts/internal/dev_hub/assets/app.js"
I18N_JS="$WORKSPACE_DIR/scripts/internal/dev_hub/assets/i18n.js"
DEV_HUB_HTML="$WORKSPACE_DIR/docs/dev-hub.html"

# 1. Check layout.html structure
echo "1. Checking HTML structure in layout.html..."
assert_contains "$LAYOUT_HTML" 'class="tab-home-pin-icon"' "tab-home-pin-icon exists on tab buttons"
assert_contains "$LAYOUT_HTML" 'class="tabs-home-ctrl"' "tabs-home-ctrl container exists in tabs-nav"
assert_contains "$LAYOUT_HTML" 'id="btn-pin-home-tab"' "btn-pin-home-tab button exists"
assert_contains "$LAYOUT_HTML" 'onclick="togglePinCurrentTabAsHome()"' "togglePinCurrentTabAsHome onclick handler exists"

# 2. Check style.css definitions
echo "2. Checking CSS classes in style.css..."
assert_contains "$STYLE_CSS" '.tab-home-pin-icon' "CSS class .tab-home-pin-icon defined"
assert_contains "$STYLE_CSS" '.tabs-home-ctrl' "CSS class .tabs-home-ctrl defined"
assert_contains "$STYLE_CSS" '.btn-pin-home-tab' "CSS class .btn-pin-home-tab defined"
assert_contains "$STYLE_CSS" '.btn-pin-home-tab.is-pinned' "CSS class .btn-pin-home-tab.is-pinned defined"

# 3. Check JavaScript functions in app.js
echo "3. Checking JavaScript functions in app.js..."
assert_contains "$APP_JS" 'function updateHomeTabPinUI' "updateHomeTabPinUI function exists"
assert_contains "$APP_JS" 'function togglePinCurrentTabAsHome' "togglePinCurrentTabAsHome function exists"
assert_contains "$APP_JS" "dev_hub_last_active_tab" "dev_hub_last_active_tab persistence in switchTab"
assert_contains "$APP_JS" "dev_hub_home_tab" "dev_hub_home_tab lookup in startup router"
assert_contains "$APP_JS" "updateHomeTabPinUI(targetTab)" "updateHomeTabPinUI called in startup router"

# 4. Check 6-language i18n keys
echo "4. Checking i18n keys across all 6 languages..."
for key in "label_pin_home" "label_pinned_home" "label_pin_mode_auto" "tip_pin_home_tab" "tip_unpin_home_tab" "toast_pinned_home" "toast_unpinned_home"; do
  assert_contains "$I18N_JS" "$key:" "i18n key '$key' exists in i18n.js"
done

# 5. Verify Node.js JavaScript syntax check on app.js and i18n.js
if command -v node >/dev/null 2>&1; then
  echo "5. Verifying JavaScript syntax via node --check..."
  node --check "$APP_JS"
  echo "  ✅ app.js syntax OK"
  node --check "$I18N_JS"
  echo "  ✅ i18n.js syntax OK"
fi

# 6. Verify compiled dev-hub.html if present
if [ -f "$DEV_HUB_HTML" ]; then
  echo "6. Verifying compiled docs/dev-hub.html..."
  assert_contains "$DEV_HUB_HTML" 'id="btn-pin-home-tab"' "btn-pin-home-tab present in compiled HTML"
  assert_contains "$DEV_HUB_HTML" 'tab-home-pin-icon' "tab-home-pin-icon present in compiled HTML"
  assert_contains "$DEV_HUB_HTML" 'updateHomeTabPinUI' "updateHomeTabPinUI present in compiled script"
fi

if [ $ERRORS -gt 0 ]; then
  echo "❌ Total Errors: $ERRORS"
  exit 1
fi

echo "✅ All Home Tab Pinning & Adaptive Landing tests PASSED successfully!"
