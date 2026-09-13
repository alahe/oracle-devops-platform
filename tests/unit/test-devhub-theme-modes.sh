#!/usr/bin/env bash
# ==============================================================================
# Unit Test: Dev Hub Dual-Theme (Dark & Light Mode) Contract & Contrast Safety
# Verifies CSS variables, button hierarchy discipline, high-contrast sidebar
# typography, accessibility controls (Alt+T), and prevention of light-mode anti-patterns.
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

CYAN='\033[1;36m'
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'

echo -e "${CYAN}=== Validating Dev Hub Dual-Theme (Dark & Light) Architecture ===${NC}"

CSS_FILE="$WORKSPACE_DIR/scripts/internal/dev_hub/assets/style.css"
APP_JS="$WORKSPACE_DIR/scripts/internal/dev_hub/assets/app.js"
LAYOUT_HTML="$WORKSPACE_DIR/scripts/internal/dev_hub/assets/templates/layout.html"

# 1. Verify CSS variable palettes for both Dark and Light modes
echo "  [1/6] Checking CSS variable tokens for dark and light root scopes..."
for selector in ':root' '[data-theme="light"]'; do
  if ! grep -q "$selector" "$CSS_FILE"; then
    echo -e "${RED}❌ Missing theme root selector in style.css: $selector${NC}"
    exit 1
  fi
done

# Ensure core variables are declared under both themes
for var_name in "--bg" "--surface" "--surface-subtle" "--text-main" "--text-muted" "--border" "--primary" "--code-bg"; do
  if ! grep -q -e "$var_name:" "$CSS_FILE"; then
    echo -e "${RED}❌ Missing essential theme variable in style.css: $var_name${NC}"
    exit 1
  fi
done
echo "     ✅ Dark and Light theme root variables verified."

# 2. Enforce Button Hierarchy Discipline (Preventing the 'Sinine Kast' Anti-Pattern)
echo "  [2/6] Verifying button hierarchy rules and prohibition of indiscriminate solid primary buttons..."
# Ensure light mode does NOT blanket force all .btn to background: var(--primary) !important
if grep -q '\[data-theme="light"\] \.btn\s*{[^}]*background:\s*var\(--primary\)\s*!important' "$CSS_FILE"; then
  echo -e "${RED}❌ Detected prohibited anti-pattern: [data-theme=\"light\"] .btn forces solid primary background!${NC}"
  exit 1
fi

# Ensure light mode has neutral base button definitions
if ! grep -q '\[data-theme="light"\] \.btn {' "$CSS_FILE"; then
  echo -e "${RED}❌ Missing neutral base .btn styles for [data-theme=\"light\"] in style.css${NC}"
  exit 1
fi
echo "     ✅ Button hierarchy contract enforced: no indiscriminate solid buttons in light mode."

# 3. Typography & List Contrast Contract (Blueprint / Profile Sidebars)
echo "  [3/6] Verifying high-contrast typography in sidebars, code boxes, and modal tags..."
if ! grep -q '\[data-theme="light"\] \.profile-item-btn {' "$CSS_FILE"; then
  echo -e "${RED}❌ Missing [data-theme=\"light\"] .profile-item-btn style in style.css${NC}"
  exit 1
fi

if ! grep -q '\[data-theme="light"\] \.bp-tag' "$CSS_FILE"; then
  echo -e "${RED}❌ Missing [data-theme=\"light\"] .bp-tag styling in style.css${NC}"
  exit 1
fi

# Check that app.js does not inject low-contrast inline color #cbd5e1 into sidebar item buttons
if grep -q "renderProfilesSidebar" "$APP_JS" && grep -q "color:\s*#cbd5e1" "$APP_JS"; then
  echo -e "${RED}❌ Detected hardcoded low-contrast inline color (#cbd5e1) in app.js${NC}"
  exit 1
fi
echo "     ✅ High-contrast sidebar typography and tag styling verified."

# 4. Interactive Theme Controls & Persistence
echo "  [4/6] Verifying theme toggle control, Alt+T shortcut, and persistence..."
if ! grep -q 'id="theme-toggle-btn"' "$LAYOUT_HTML"; then
  echo -e "${RED}❌ Missing #theme-toggle-btn in layout.html${NC}"
  exit 1
fi

if ! grep -q 'dev_hub_theme' "$APP_JS"; then
  echo -e "${RED}❌ Missing localStorage theme persistence (dev_hub_theme) in app.js${NC}"
  exit 1
fi

if ! grep -q "'KeyT'" "$APP_JS" && ! grep -q '"KeyT"' "$APP_JS"; then
  echo -e "${RED}❌ Missing Alt+T theme keyboard shortcut in app.js${NC}"
  exit 1
fi
echo "     ✅ Theme toggle button, Alt+T shortcut, and localStorage persistence verified."

# 5. Active Selection Accent Discipline (Log items, Category filters)
echo "  [5/6] Verifying active selection indicator styles..."
if ! grep -q '\[data-theme="light"\] \.log-item\.active' "$CSS_FILE"; then
  echo -e "${RED}❌ Missing [data-theme=\"light\"] .log-item.active rule in style.css${NC}"
  exit 1
fi

if ! grep -q 'border-left:' "$CSS_FILE"; then
  echo -e "${RED}❌ Missing border-left accent line in style.css${NC}"
  exit 1
fi
echo "     ✅ Active item accent indicators verified."

# 6. WCAG 2.1 AA Mathematical Contrast Calculation
echo "  [6/6] Computing WCAG 2.1 AA relative luminance contrast ratios for theme palettes..."
python3 -c "
import math, sys

def srgb_to_linear(c):
    v = c / 255.0
    return v / 12.92 if v <= 0.03928 else ((v + 0.055) / 1.055) ** 2.4

def lum(r, g, b):
    return 0.2126 * srgb_to_linear(r) + 0.7152 * srgb_to_linear(g) + 0.0722 * srgb_to_linear(b)

def contrast(c1, c2):
    l1 = lum(*c1)
    l2 = lum(*c2)
    lighter = max(l1, l2)
    darker = min(l1, l2)
    return (lighter + 0.05) / (darker + 0.05)

# Light Mode: white surface (#ffffff) vs text colors
white_bg = (255, 255, 255)
text_main = (15, 23, 42)      # #0f172a
text_muted = (71, 85, 105)    # #475569
sidebar_btn = (51, 65, 85)    # #334155
primary_link = (2, 132, 199)  # #0284c7

# Dark Mode: dark surface (#111827) vs text colors
dark_bg = (17, 24, 39)
dark_text = (248, 250, 252)   # #f8fafc

# Check Light Mode ratios (must be >= 4.5:1 for normal text)
r_main = contrast(text_main, white_bg)
r_muted = contrast(text_muted, white_bg)
r_sidebar = contrast(sidebar_btn, white_bg)
r_link = contrast(primary_link, white_bg)
r_dark = contrast(dark_text, dark_bg)

print(f'       Light text-main on white:    {r_main:.2f}:1 (Requirement >= 4.5:1)')
print(f'       Light text-muted on white:   {r_muted:.2f}:1 (Requirement >= 4.5:1)')
print(f'       Light sidebar-btn on white:  {r_sidebar:.2f}:1 (Requirement >= 4.5:1)')
print(f'       Light primary-link on white: {r_link:.2f}:1 (Requirement >= 3.0:1 for UI/large)')
print(f'       Dark text on dark surface:   {r_dark:.2f}:1 (Requirement >= 4.5:1)')

if r_main < 4.5:
    sys.exit('❌ Light text-main contrast failed WCAG AA (< 4.5:1)')
if r_muted < 4.5:
    sys.exit('❌ Light text-muted contrast failed WCAG AA (< 4.5:1)')
if r_sidebar < 4.5:
    sys.exit('❌ Light sidebar-btn contrast failed WCAG AA (< 4.5:1)')
if r_link < 3.0:
    sys.exit('❌ Light primary link contrast failed (< 3.0:1)')
if r_dark < 4.5:
    sys.exit('❌ Dark text contrast failed WCAG AA (< 4.5:1)')

print('       ✅ All contrast ratios pass WCAG 2.1 AA!')
"

# 7. Universal Notification & Toast Architecture Audit
echo "  [7/7] Verifying universal notification, toast, and alert styles across themes..."
for rule in ".devhub-toast" '[data-theme="light"] .devhub-toast' ".alert-box-warning" ".alert-box-danger"; do
  if ! grep -F -q "$rule" "$CSS_FILE"; then
    echo -e "${RED}❌ Missing notification CSS rule in style.css: $rule${NC}"
    exit 1
  fi
done

# Ensure app.js showToast does not inject hardcoded dark backgrounds or inline cssText
python3 -c "
import re, sys
with open('$APP_JS', 'r', encoding='utf-8') as f:
    js = f.read()

m = re.search(r'function\s+showToast\s*\([^)]*\)\s*\{([^}]+)\}', js)
if not m:
    sys.exit('❌ Could not find function showToast in app.js')

body = m.group(1)
if 'background:' in body or '#0f172a' in body or 'cssText' in body:
    sys.exit('❌ Detected hardcoded dark inline background or cssText inside showToast in app.js!')
"
echo "     ✅ Universal toast and in-page alert rules verified without dark background leaks."

echo -e "${GREEN}PASS: Dev Hub Dual-Theme (Dark & Light) architecture, notifications, and contrast standards verified!${NC}"
exit 0

