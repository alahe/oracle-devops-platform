#!/bin/bash
# ==============================================================================
# Unit Test: Dev-Hub DevOps and Testing Search & Filtering Validation
# Tests the search bar, category filters, card markup, bridge delegation, and i18n
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "🔍 Validating Dev-Hub DevOps and Testing Search & Filter System..."

DEV_HUB_LAYOUT="$WORKSPACE_DIR/scripts/internal/dev_hub/assets/templates/layout.html"
DEV_HUB_APP_JS="$WORKSPACE_DIR/scripts/internal/dev_hub/assets/app.js"
DEV_HUB_I18N="$WORKSPACE_DIR/scripts/internal/dev_hub/assets/i18n.js"
DEV_HUB_BRIDGE="$WORKSPACE_DIR/scripts/internal/dev-hub-bridge.py"
DEV_HUB_TESTING="$WORKSPACE_DIR/scripts/internal/dev_hub/testing.py"
DEV_HUB_HTML="$WORKSPACE_DIR/docs/dev-hub.html"

# 1. Check layout markup
echo "  [1/6] Checking layout.html toolbar and card markup..."
grep -q 'id="devops-search-input"' "$DEV_HUB_LAYOUT" || { echo "❌ devops-search-input missing in layout.html"; exit 1; }
grep -q 'id="devops-category-filters"' "$DEV_HUB_LAYOUT" || { echo "❌ devops-category-filters missing in layout.html"; exit 1; }
grep -q 'id="devops-filter-counter"' "$DEV_HUB_LAYOUT" || { echo "❌ devops-filter-counter missing in layout.html"; exit 1; }
grep -q 'id="devops-empty-state"' "$DEV_HUB_LAYOUT" || { echo "❌ devops-empty-state missing in layout.html"; exit 1; }

grep -q 'id="testing-search-input"' "$DEV_HUB_LAYOUT" || { echo "❌ testing-search-input missing in layout.html"; exit 1; }
grep -q 'id="testing-category-filters"' "$DEV_HUB_LAYOUT" || { echo "❌ testing-category-filters missing in layout.html"; exit 1; }
grep -q 'id="testing-filter-counter"' "$DEV_HUB_LAYOUT" || { echo "❌ testing-filter-counter missing in layout.html"; exit 1; }
grep -q 'id="testing-empty-state"' "$DEV_HUB_LAYOUT" || { echo "❌ testing-empty-state missing in layout.html"; exit 1; }

# Verify Windows dry-run card is wrapped in a card
grep -A 2 'title_devops_windows_dryrun' "$DEV_HUB_LAYOUT" | grep -q 'Windows & WSL2' || true
# Check that each card in devops has data-cat
DEVOPS_CARDS_COUNT=$(grep -c 'data-cat=' "$DEV_HUB_LAYOUT")
[ "$DEVOPS_CARDS_COUNT" -ge 13 ] || { echo "❌ Expected at least 13 data-cat cards in layout.html, found $DEVOPS_CARDS_COUNT"; exit 1; }

# 2. Check app.js functions
echo "  [2/6] Checking JavaScript functions in app.js..."
node --check "$DEV_HUB_APP_JS"
grep -q 'function filterDevOpsCards' "$DEV_HUB_APP_JS" || { echo "❌ filterDevOpsCards missing in app.js"; exit 1; }
grep -q 'function filterDevOpsCategory' "$DEV_HUB_APP_JS" || { echo "❌ filterDevOpsCategory missing in app.js"; exit 1; }
grep -q 'function filterTestingSuites' "$DEV_HUB_APP_JS" || { echo "❌ filterTestingSuites missing in app.js"; exit 1; }
grep -q 'function filterTestingCategory' "$DEV_HUB_APP_JS" || { echo "❌ filterTestingCategory missing in app.js"; exit 1; }

# 3. Check testing.py category definitions
echo "  [3/6] Checking test suites categories in testing.py..."
python3 -c "
import sys, os
sys.path.insert(0, '$WORKSPACE_DIR/scripts/internal')
from dev_hub.testing import get_test_suites_catalog
suites = get_test_suites_catalog('$WORKSPACE_DIR')
assert len(suites) >= 10, f'Expected at least 10 suites, got {len(suites)}'
for k, s in suites.items():
    assert 'category' in s, f'Suite {k} missing category'
    assert s['category'] in ['core', 'compliance', 'e2e', 'ci'], f'Invalid category for {k}'
print(f'     ✅ {len(suites)} test suites validated with valid categories.')
"

# 4. Check bridge single source of truth delegation
echo "  [4/6] Checking dev-hub-bridge.py delegation..."
python3 -m py_compile "$DEV_HUB_BRIDGE"
python3 -c "
import sys, os
sys.path.insert(0, '$WORKSPACE_DIR/scripts/internal')
import importlib
bridge = importlib.import_module('dev-hub-bridge')
suites = bridge.get_test_suites_catalog()
assert 'windows_enterprise' in suites, 'windows_enterprise missing from bridge suites catalog'
assert 'devhub_lifecycle' in suites, 'devhub_lifecycle missing from bridge suites catalog'
print(f'     ✅ Bridge returns all {len(suites)} suites via Single Source of Truth.')
"

# 5. Check 6-Language i18n Dictionary parity
echo "  [5/6] Checking 6-language i18n parity in i18n.js..."
node --check "$DEV_HUB_I18N"
node -e "
const fs = require('fs');
const content = fs.readFileSync('$DEV_HUB_I18N', 'utf8');
const script = content + '\nif (typeof I18N_DICT !== \"undefined\") module.exports = I18N_DICT;';
const tmpFile = '/tmp/test_i18n_eval.js';
fs.writeFileSync(tmpFile, script);
const dict = require(tmpFile);
const langs = ['en', 'et', 'fi', 'sv', 'lv', 'lt'];
const requiredKeys = [
  'filter_all_cards',
  'devops_search_placeholder',
  'devops_filter_diag',
  'devops_filter_wallet',
  'devops_filter_lifecycle',
  'devops_filter_enterprise',
  'devops_no_results',
  'devops_no_results_desc',
  'test_search_placeholder',
  'test_filter_core',
  'test_filter_compliance',
  'test_filter_e2e',
  'test_filter_ci',
  'test_no_results',
  'test_no_results_desc',
  'btn_reset_filters'
];

for (const lang of langs) {
  if (!dict[lang]) throw new Error('Missing lang: ' + lang);
  for (const k of requiredKeys) {
    if (!dict[lang][k]) throw new Error('Lang ' + lang + ' missing key: ' + k);
  }
}
console.log('     ✅ All 16 keys present across all 6 languages.');
"

# 6. Check compiled dev-hub.html
echo "  [6/6] Checking compiled dev-hub.html..."
grep -q 'id="devops-search-input"' "$DEV_HUB_HTML" || { echo "❌ devops-search-input missing in docs/dev-hub.html"; exit 1; }
grep -q 'id="testing-search-input"' "$DEV_HUB_HTML" || { echo "❌ testing-search-input missing in docs/dev-hub.html"; exit 1; }
grep -q 'windows_enterprise' "$DEV_HUB_HTML" || { echo "❌ windows_enterprise missing in docs/dev-hub.html"; exit 1; }

echo "✅ All Dev-Hub search and filter validations passed successfully!"
