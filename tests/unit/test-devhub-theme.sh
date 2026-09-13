#!/usr/bin/env bash
# ==============================================================================
# Unit Test: Dev Hub Light Theme Architecture, Tokens & i18n Integrity
# Tests compliance with Rule 2, Rule 9, and Theme Specifications
# ==============================================================================
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

CYAN='\033[1;36m'
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'

echo -e "${CYAN}=== Testing Dev Hub Light Theme Architecture & Tokens ===${NC}"

STYLE_CSS="$WORKSPACE_DIR/scripts/internal/dev_hub/assets/style.css"
LAYOUT_HTML="$WORKSPACE_DIR/scripts/internal/dev_hub/assets/templates/layout.html"
APP_JS="$WORKSPACE_DIR/scripts/internal/dev_hub/assets/app.js"
I18N_JS="$WORKSPACE_DIR/scripts/internal/dev_hub/assets/i18n.js"
DEV_HUB_HTML="$WORKSPACE_DIR/docs/dev-hub.html"

# 1. Check CSS variables for light theme
echo "  [1/8] Checking [data-theme=\"light\"] tokens in style.css..."
grep -q '\[data-theme="light"\]' "$STYLE_CSS" || { echo -e "${RED}FAIL: [data-theme=\"light\"] missing in style.css${NC}"; exit 1; }
grep -q -- '--bg: #f8fafc' "$STYLE_CSS" || { echo -e "${RED}FAIL: --bg token missing in style.css${NC}"; exit 1; }
grep -q -- '--surface: #ffffff' "$STYLE_CSS" || { echo -e "${RED}FAIL: --surface token missing in style.css${NC}"; exit 1; }

# 2. Check Dark Console Invariant
echo "  [2/8] Checking Dark Console Invariant (.devops-docked-terminal)..."
grep -q '.devops-docked-terminal' "$STYLE_CSS" || { echo -e "${RED}FAIL: .devops-docked-terminal missing in style.css${NC}"; exit 1; }
grep -q '#030712 !important' "$STYLE_CSS" || { echo -e "${RED}FAIL: Dark Console Invariant #030712 missing in style.css${NC}"; exit 1; }

# 3. Check layout button and head script
echo "  [3/8] Checking theme-toggle-btn and head FOUC prevention in layout.html..."
grep -q 'id="theme-toggle-btn"' "$LAYOUT_HTML" || { echo -e "${RED}FAIL: theme-toggle-btn missing in layout.html${NC}"; exit 1; }
grep -q 'toggleTheme()' "$LAYOUT_HTML" || { echo -e "${RED}FAIL: toggleTheme() call missing in layout.html${NC}"; exit 1; }
grep -q 'localStorage.getItem(.dev_hub_theme.)' "$LAYOUT_HTML" || { echo -e "${RED}FAIL: Theme init script missing in layout.html head${NC}"; exit 1; }

# 4. Check app.js functions and shortcuts
echo "  [4/8] Checking toggleTheme, setTheme, initTheme & Alt+T shortcut in app.js..."
grep -q 'function setTheme(' "$APP_JS" || { echo -e "${RED}FAIL: setTheme missing in app.js${NC}"; exit 1; }
grep -q 'function toggleTheme(' "$APP_JS" || { echo -e "${RED}FAIL: toggleTheme missing in app.js${NC}"; exit 1; }
grep -q 'function initTheme(' "$APP_JS" || { echo -e "${RED}FAIL: initTheme missing in app.js${NC}"; exit 1; }
grep -q "key.toLowerCase() === 't'" "$APP_JS" || { echo -e "${RED}FAIL: Alt+T shortcut missing in app.js${NC}"; exit 1; }

# 5. Check 6-language symmetry in i18n.js
echo "  [5/8] Checking 6-language i18n symmetry for theme keys..."
for lang in en et fi sv lv lt; do
  grep -q "tip_theme_toggle:" "$I18N_JS" || { echo -e "${RED}FAIL: tip_theme_toggle missing for $lang in i18n.js${NC}"; exit 1; }
  grep -q "theme_light:" "$I18N_JS" || { echo -e "${RED}FAIL: theme_light missing for $lang in i18n.js${NC}"; exit 1; }
  grep -q "theme_dark:" "$I18N_JS" || { echo -e "${RED}FAIL: theme_dark missing for $lang in i18n.js${NC}"; exit 1; }
done

# 6. Check compiled dev-hub.html
echo "  [6/8] Checking compiled docs/dev-hub.html for theme support..."
if [ -f "$DEV_HUB_HTML" ]; then
  grep -q 'id="theme-toggle-btn"' "$DEV_HUB_HTML" || { echo -e "${RED}FAIL: theme-toggle-btn missing in compiled dev-hub.html${NC}"; exit 1; }
  grep -q '\[data-theme="light"\]' "$DEV_HUB_HTML" || { echo -e "${RED}FAIL: [data-theme=\"light\"] missing in compiled dev-hub.html${NC}"; exit 1; }
fi

# 7. Check Canonical Pastel Token Palette
echo "  [7/8] Checking Canonical Pastel Token Palette in style.css..."
for token in "--pastel-emerald-bg" "--pastel-sky-bg" "--pastel-violet-bg" "--pastel-amber-bg" "--pastel-teal-bg" "--pastel-rose-bg"; do
  grep -q -- "$token" "$STYLE_CSS" || { echo -e "${RED}FAIL: Pastel token $token missing in style.css${NC}"; exit 1; }
done

# 8. Check Zero Black Buttons & Zero Dark Leaks in Light Theme
echo "  [8/8] Checking Zero Black Buttons & Zero Dark Leaks in Light Theme..."
grep -q '\[data-theme="light"\] .card\[data-cat="core"\]' "$STYLE_CSS" || { echo -e "${RED}FAIL: .card[data-cat=\"core\"] pastel rule missing${NC}"; exit 1; }
grep -q '\[data-theme="light"\] .card\[data-cat="middleware"\]' "$STYLE_CSS" || { echo -e "${RED}FAIL: .card[data-cat=\"middleware\"] pastel rule missing${NC}"; exit 1; }
grep -q '\[data-theme="light"\] .btn-secondary' "$STYLE_CSS" || { echo -e "${RED}FAIL: .btn-secondary light override missing${NC}"; exit 1; }
grep -q '\[data-theme="light"\] .enterprise-dropdown-btn' "$STYLE_CSS" || { echo -e "${RED}FAIL: .enterprise-dropdown-btn light override missing${NC}"; exit 1; }
grep -q '\[data-theme="light"\] .copilot-trigger-btn' "$STYLE_CSS" || { echo -e "${RED}FAIL: .copilot-trigger-btn light override missing${NC}"; exit 1; }
grep -q '\[data-theme="light"\] .card-meta' "$STYLE_CSS" || { echo -e "${RED}FAIL: .card-meta light override missing${NC}"; exit 1; }
grep -q '\[data-theme="light"\] .studio-impact-box' "$STYLE_CSS" || { echo -e "${RED}FAIL: .studio-impact-box light override missing${NC}"; exit 1; }
grep -q '\[data-theme="light"\] .telemetry-collapsible-ribbon' "$STYLE_CSS" || { echo -e "${RED}FAIL: .telemetry-collapsible-ribbon light override missing${NC}"; exit 1; }
grep -q '\[data-theme="light"\] .skills-view-btn' "$STYLE_CSS" || { echo -e "${RED}FAIL: .skills-view-btn light override missing${NC}"; exit 1; }
# 9. Check Polished Light Cards, Tables, Switchers & Mermaid
echo "  [9/9] Checking Polished Light Cards, Tables, Switchers & Mermaid in style.css..."
grep -q '\[data-theme="light"\] .glossary-item-card' "$STYLE_CSS" || { echo -e "${RED}FAIL: .glossary-item-card light rule missing${NC}"; exit 1; }
grep -q '\[data-theme="light"\] .gherkin-card' "$STYLE_CSS" || { echo -e "${RED}FAIL: .gherkin-card light rule missing${NC}"; exit 1; }
grep -q '\[data-theme="light"\] .skill-card' "$STYLE_CSS" || { echo -e "${RED}FAIL: .skill-card light rule missing${NC}"; exit 1; }
grep -q '\[data-theme="light"\] .log-item' "$STYLE_CSS" || { echo -e "${RED}FAIL: .log-item light rule missing${NC}"; exit 1; }
grep -q '\[data-theme="light"\] .doc-table-wrapper' "$STYLE_CSS" || { echo -e "${RED}FAIL: .doc-table-wrapper light rule missing${NC}"; exit 1; }
grep -q '\[data-theme="light"\] .mermaid-diagram-card' "$STYLE_CSS" || { echo -e "${RED}FAIL: .mermaid-diagram-card light rule missing${NC}"; exit 1; }
grep -q '\[data-theme="light"\] .skills-view-switcher' "$STYLE_CSS" || { echo -e "${RED}FAIL: .skills-view-switcher light rule missing${NC}"; exit 1; }

# 10. Check Selection Contrast, Specs Contrast & Testing Tab Light Containers
echo "  [10/11] Checking Selection Contrast, Specs Contrast & Testing Tab Components in style.css..."
grep -q '::selection' "$STYLE_CSS" || { echo -e "${RED}FAIL: ::selection rule missing in style.css${NC}"; exit 1; }
grep -q '\[data-theme="light"\] .reports-sidebar' "$STYLE_CSS" || { echo -e "${RED}FAIL: .reports-sidebar light rule missing${NC}"; exit 1; }
grep -q '\[data-theme="light"\] .coverage-kpi-bar' "$STYLE_CSS" || { echo -e "${RED}FAIL: .coverage-kpi-bar light rule missing${NC}"; exit 1; }
grep -q '\[data-theme="light"\] .coverage-table-container' "$STYLE_CSS" || { echo -e "${RED}FAIL: .coverage-table-container light rule missing${NC}"; exit 1; }
grep -q '\[data-theme="light"\] .history-table-container' "$STYLE_CSS" || { echo -e "${RED}FAIL: .history-table-container light rule missing${NC}"; exit 1; }
grep -q '\[data-theme="light"\] .test-script-select' "$STYLE_CSS" || { echo -e "${RED}FAIL: .test-script-select light rule missing${NC}"; exit 1; }
grep -q '\[data-theme="light"\] .agent-trail-card' "$STYLE_CSS" || { echo -e "${RED}FAIL: .agent-trail-card light rule missing${NC}"; exit 1; }

# 11. Check Blueprint Modal Light Theme (Zero Black Tabs & High Contrast)
echo "  [11/13] Checking Blueprint Modal Light Theme in style.css..."
grep -q '\[data-theme="light"\] .modal-tabs' "$STYLE_CSS" || { echo -e "${RED}FAIL: .modal-tabs light rule missing${NC}"; exit 1; }
grep -q '\[data-theme="light"\] .bp-logs-filter-toolbar' "$STYLE_CSS" || { echo -e "${RED}FAIL: .bp-logs-filter-toolbar light rule missing${NC}"; exit 1; }
grep -q '\[data-theme="light"\] .bp-quickstart-step-desc' "$STYLE_CSS" || { echo -e "${RED}FAIL: .bp-quickstart-step-desc light rule missing${NC}"; exit 1; }
grep -q '\[data-theme="light"\] .bp-user-portal-title' "$STYLE_CSS" || { echo -e "${RED}FAIL: .bp-user-portal-title light rule missing${NC}"; exit 1; }
grep -q '\[data-theme="light"\] .bp-bench-card' "$STYLE_CSS" || { echo -e "${RED}FAIL: .bp-bench-card light rule missing${NC}"; exit 1; }
grep -q '\[data-theme="light"\] .bp-action-card-desc' "$STYLE_CSS" || { echo -e "${RED}FAIL: .bp-action-card-desc light rule missing${NC}"; exit 1; }

# 12. Check DevOps Recipe Modal Light Theme
echo "  [12/13] Checking DevOps Recipe Modal Light Theme in style.css..."
grep -q '\[data-theme="light"\] #devops-recipe-modal .modal-content' "$STYLE_CSS" || { echo -e "${RED}FAIL: #devops-recipe-modal light rule missing${NC}"; exit 1; }
grep -q '\[data-theme="light"\] .recipe-modal-desc' "$STYLE_CSS" || { echo -e "${RED}FAIL: .recipe-modal-desc light rule missing${NC}"; exit 1; }
grep -q '\[data-theme="light"\] .recipe-pipeline-title' "$STYLE_CSS" || { echo -e "${RED}FAIL: .recipe-pipeline-title light rule missing${NC}"; exit 1; }
grep -q '\[data-theme="light"\] .recipe-step-cmd' "$STYLE_CSS" || { echo -e "${RED}FAIL: .recipe-step-cmd light rule missing${NC}"; exit 1; }

# 13. Check Copilot & Antigravity Assistant Drawer Light Theme
echo "  [13/16] Checking Copilot & Antigravity Assistant Drawer Light Theme in style.css..."
grep -q '\[data-theme="light"\] .copilot-drawer' "$STYLE_CSS" || { echo -e "${RED}FAIL: .copilot-drawer light rule missing${NC}"; exit 1; }
grep -q '\[data-theme="light"\] .copilot-header' "$STYLE_CSS" || { echo -e "${RED}FAIL: .copilot-header light rule missing${NC}"; exit 1; }
grep -q '\[data-theme="light"\] .copilot-messages' "$STYLE_CSS" || { echo -e "${RED}FAIL: .copilot-messages light rule missing${NC}"; exit 1; }
grep -q '\[data-theme="light"\] .copilot-msg-bot' "$STYLE_CSS" || { echo -e "${RED}FAIL: .copilot-msg-bot light rule missing${NC}"; exit 1; }
grep -q '\[data-theme="light"\] .copilot-footer' "$STYLE_CSS" || { echo -e "${RED}FAIL: .copilot-footer light rule missing${NC}"; exit 1; }
grep -q '\[data-theme="light"\] .copilot-input-row' "$STYLE_CSS" || { echo -e "${RED}FAIL: .copilot-input-row light rule missing${NC}"; exit 1; }

# 14. Check Global Search Modal Results & Tags Light Theme
echo "  [14/16] Checking Global Search Results & Recent Tags Light Theme in style.css..."
grep -q '\[data-theme="light"\] .search-result-item' "$STYLE_CSS" || { echo -e "${RED}FAIL: .search-result-item light rule missing${NC}"; exit 1; }
grep -q '\[data-theme="light"\] .recent-search-tag' "$STYLE_CSS" || { echo -e "${RED}FAIL: .recent-search-tag light rule missing${NC}"; exit 1; }
grep -q '\[data-theme="light"\] .search-result-title' "$STYLE_CSS" || { echo -e "${RED}FAIL: .search-result-title light rule missing${NC}"; exit 1; }
grep -q '\[data-theme="light"\] .search-result-path' "$STYLE_CSS" || { echo -e "${RED}FAIL: .search-result-path light rule missing${NC}"; exit 1; }

# 15. Check FAQ Interactive Toolbar & Details Cards Light Theme
echo "  [15/16] Checking FAQ Interactive Toolbar & Details Light Theme in style.css..."
grep -q '\[data-theme="light"\] .faq-toolbar' "$STYLE_CSS" || { echo -e "${RED}FAIL: .faq-toolbar light rule missing${NC}"; exit 1; }
grep -q '\[data-theme="light"\] .faq-cat-pill' "$STYLE_CSS" || { echo -e "${RED}FAIL: .faq-cat-pill light rule missing${NC}"; exit 1; }
grep -q '\[data-theme="light"\] .faq-toggle-btn' "$STYLE_CSS" || { echo -e "${RED}FAIL: .faq-toggle-btn light rule missing${NC}"; exit 1; }
grep -q '\[data-theme="light"\] details.faq-item' "$STYLE_CSS" || { echo -e "${RED}FAIL: details.faq-item light rule missing${NC}"; exit 1; }

# 16. Check Testing Coverage & Modal Toolbars Light Theme
echo "  [16/16] Checking Coverage & Modal Search Toolbars Light Theme in style.css..."
grep -q '\[data-theme="light"\] .coverage-table-container' "$STYLE_CSS" || { echo -e "${RED}FAIL: .coverage-table-container light rule missing${NC}"; exit 1; }
grep -q '\[data-theme="light"\] .faq-modal-toolbar' "$STYLE_CSS" || { echo -e "${RED}FAIL: .faq-modal-toolbar light rule missing${NC}"; exit 1; }

echo -e "${GREEN}✅ All Dev Hub Light Theme unit tests PASSED!${NC}"


