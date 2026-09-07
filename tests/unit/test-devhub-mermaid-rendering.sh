#!/usr/bin/env bash
# ==============================================================================
# Unit Test: Dev-Hub Interactive Mermaid Diagram Rendering Engine
# Validates marked-to-mermaid transformation, toolbars, zoom modal, and 6-language i18n
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "🔍 Validating Dev-Hub Mermaid Diagram Rendering Architecture..."

# 1. Check style.css definitions
echo "  [1/6] Checking style.css diagram components..."
CSS_FILE="$WORKSPACE_DIR/scripts/internal/dev_hub/assets/style.css"
for rule in ".mermaid-diagram-card" ".mermaid-toolbar" ".mermaid-render-target" ".mermaid-raw-code" "#mermaid-zoom-modal"; do
  if ! grep -q "$rule" "$CSS_FILE"; then
    echo "❌ Missing CSS rule in style.css: $rule"
    exit 1
  fi
done
echo "     ✅ All Mermaid CSS classes and modal styles present."

# 2. Check layout.html modal and blueprint toolbar
echo "  [2/6] Checking layout.html blueprint toolbar and zoom modal..."
LAYOUT_FILE="$WORKSPACE_DIR/scripts/internal/dev_hub/assets/templates/layout.html"
for elem in "id=\"bp-modal-mermaid\"" "toggleBlueprintMermaidCode" "copyBlueprintMermaidCode" "openBlueprintMermaidZoom" "id=\"mermaid-zoom-modal\""; do
  if ! grep -q "$elem" "$LAYOUT_FILE"; then
    echo "❌ Missing element in layout.html: $elem"
    exit 1
  fi
done
echo "     ✅ Blueprint topology toolbar and zoom modal markup present."

# 3. Check i18n.js 6-language parity
echo "  [3/6] Checking 6-language parity in i18n.js for Mermaid keys..."
I18N_FILE="$WORKSPACE_DIR/scripts/internal/dev_hub/assets/i18n.js"

python3 -c "
import re, sys

with open('$I18N_FILE', 'r', encoding='utf-8') as f:
    code = f.read()

languages = ['en', 'et', 'fi', 'sv', 'lv', 'lt']
keys = ['mermaid_diag_title', 'mermaid_toggle_code', 'mermaid_hide_code', 'mermaid_copy_code', 'mermaid_copied', 'mermaid_zoom', 'mermaid_zoom_title', 'mermaid_offline_msg', 'mermaid_err_msg']

for lang in languages:
    m = re.search(r'\b' + lang + r'\s*:\s*\{([^}]+)\}', code)
    if not m:
        print(f'❌ Missing language block: {lang}', file=sys.stderr)
        sys.exit(1)
    block = m.group(1)
    for k in keys:
        if k not in block:
            print(f'❌ Missing key {k} in language {lang}', file=sys.stderr)
            sys.exit(1)

print('     ✅ All 9 Mermaid keys verified across all 6 languages.')
"

# 4. Check app.js functions and wiring
echo "  [4/6] Checking JavaScript engine and wiring in app.js..."
APP_JS="$WORKSPACE_DIR/scripts/internal/dev_hub/assets/app.js"
for fn in "initMermaidGlobal" "renderMermaidInContainer" "toggleMermaidCardCode" "copyMermaidCardCode" "openMermaidZoomModal" "closeMermaidZoomModal"; do
  if ! grep -q "$fn" "$APP_JS"; then
    echo "❌ Missing function in app.js: $fn"
    exit 1
  fi
done

if ! grep -q "renderMermaidInContainer(bodyEl)" "$APP_JS"; then
  echo "❌ renderMermaidInContainer(bodyEl) not called in app.js"
  exit 1
fi
echo "     ✅ JavaScript functions and render call sites verified."

# 5. Check JS syntax validity
echo "  [5/6] Validating JS syntax with node --check..."
node --check "$APP_JS"
node --check "$I18N_FILE"
echo "     ✅ JavaScript syntax is 100% valid."

# 6. Recompile Dev-Hub HTML and check generated output
echo "  [6/6] Generating and validating standalone docs/dev-hub.html..."
"$WORKSPACE_DIR/scripts/internal/generate-dev-hub.sh" "$WORKSPACE_DIR/docs/dev-hub.html" >/dev/null

if ! grep -q "mermaid-diagram-card" "$WORKSPACE_DIR/docs/dev-hub.html"; then
  echo "❌ Compiled dev-hub.html does not contain mermaid-diagram-card styles!"
  exit 1
fi
if ! grep -q "id=\"mermaid-zoom-modal\"" "$WORKSPACE_DIR/docs/dev-hub.html"; then
  echo "❌ Compiled dev-hub.html does not contain mermaid-zoom-modal!"
  exit 1
fi

echo "✅ All Dev-Hub Mermaid diagram rendering validations passed successfully!"
