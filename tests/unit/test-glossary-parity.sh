#!/usr/bin/env bash
# ==============================================================================
# Unit Test: test-glossary-parity.sh
# Verifies 6-language Glossary parity, Markdown docs generation, and Dev Hub
# catalog integration across all registered acronyms (Rule 9 & Rule 13).
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "📖 Running Architecture Glossary & Acronyms Parity Test..."

# 1. Verify docs/glossary.md and localized variants exist
LANGS=("en" "et" "fi" "sv" "lv" "lt")
FILES=(
  "$WORKSPACE_DIR/docs/glossary.md"
  "$WORKSPACE_DIR/docs/et/glossary.md"
  "$WORKSPACE_DIR/docs/fi/glossary.md"
  "$WORKSPACE_DIR/docs/sv/glossary.md"
  "$WORKSPACE_DIR/docs/lv/glossary.md"
  "$WORKSPACE_DIR/docs/lt/glossary.md"
)

echo "🔍 Checking Markdown files existence..."
for f in "${FILES[@]}"; do
  if [ ! -f "$f" ]; then
    echo "❌ Missing glossary file: $f"
    exit 1
  fi
  if [ ! -s "$f" ]; then
    echo "❌ Glossary file is empty: $f"
    exit 1
  fi
  echo "  ✅ Found: ${f#"$WORKSPACE_DIR/"}"
done

# 2. Check acronym count symmetry across markdown files
echo "🔍 Checking acronym entry count symmetry across all 6 language docs..."
EN_HEADINGS=$(grep -c '^### `' "$WORKSPACE_DIR/docs/glossary.md" || true)
if [ "$EN_HEADINGS" -lt 50 ]; then
  echo "❌ Expected at least 50 acronyms in docs/glossary.md, found: $EN_HEADINGS"
  exit 1
fi
echo "  ℹ️ Base acronym count: $EN_HEADINGS"

for f in "${FILES[@]}"; do
  H_COUNT=$(grep -c '^### `' "$f" || true)
  if [ "$H_COUNT" -ne "$EN_HEADINGS" ]; then
    echo "❌ Mismatch in acronym count for $f: expected $EN_HEADINGS, got $H_COUNT"
    exit 1
  fi
done
echo "  ✅ All 6 language markdown files have identical acronym counts ($EN_HEADINGS)!"

# 3. Verify Python catalog integrity via Python verification runner
echo "🔍 Validating glossary.py data structures & 6-language parity..."
python3 -c "
import sys, os
ws = '$WORKSPACE_DIR'
sys.path.insert(0, os.path.join(ws, 'scripts', 'internal'))
from dev_hub.glossary import GLOSSARY_ITEMS, get_glossary_catalog

catalog = get_glossary_catalog()
assert len(catalog) >= 50, f'Catalog has {len(catalog)} items, expected >= 50'

langs = ['en', 'et', 'fi', 'sv', 'lv', 'lt']
seen_acronyms = set()

for idx, item in enumerate(catalog):
    acr = item.get('acronym')
    assert acr, f'Item #{idx} missing acronym'
    assert acr not in seen_acronyms, f'Duplicate acronym: {acr}'
    seen_acronyms.add(acr)
    
    assert item.get('expansion'), f'{acr} missing expansion'
    assert item.get('category'), f'{acr} missing category'
    
    # Check definitions across all 6 languages
    defs = item.get('def', {})
    for l in langs:
        assert l in defs and defs[l].strip(), f'{acr} missing def in [{l}]'
        
    # Check project role across all 6 languages
    roles = item.get('project_role', {})
    for l in langs:
        assert l in roles and roles[l].strip(), f'{acr} missing project_role in [{l}]'

    # Check official / external reference URL and title
    ref_url = item.get('ref_url')
    assert ref_url and ref_url.startswith(('http://', 'https://')), f'{acr} missing valid ref_url'
    assert item.get('ref_title'), f'{acr} missing ref_title'

print(f'  ✅ Validated {len(catalog)} glossary items: 100% 6-language parity across defs, roles, and official references.')
"

# 4. Verify language switcher in all Markdown files (Rule 9)
echo "🔍 Checking Rule 9 multi-language header switcher in markdown docs..."
for f in "${FILES[@]}"; do
  if ! grep -q '\[ 🇬🇧 English \]' "$f" && ! grep -q '\*\*\[ 🇬🇧 English \]\*\*' "$f"; then
    echo "❌ Missing English link in header switcher: $f"
    exit 1
  fi
  if ! grep -q 'Eesti' "$f" || ! grep -q 'Suomi' "$f" || ! grep -q 'Svenska' "$f"; then
    echo "❌ Missing Nordic/Baltic language links in header switcher: $f"
    exit 1
  fi
done
echo "  ✅ All 6 Markdown docs contain standard language switchers."

# 5. Verify Dev Hub template and compiler integration
echo "🔍 Checking Dev Hub layout template and compiler bindings..."
LAYOUT_FILE="$WORKSPACE_DIR/scripts/internal/dev_hub/assets/templates/layout.html"
COMPILER_FILE="$WORKSPACE_DIR/scripts/internal/dev_hub/compiler.py"
APP_JS="$WORKSPACE_DIR/scripts/internal/dev_hub/assets/app.js"
STYLE_CSS="$WORKSPACE_DIR/scripts/internal/dev_hub/assets/style.css"

grep -q 'glossary-modal-backdrop' "$LAYOUT_FILE" || { echo "❌ Missing glossary-modal-backdrop in layout.html"; exit 1; }
grep -q 'glossary-nav-btn' "$LAYOUT_FILE" || { echo "❌ Missing glossary-nav-btn in layout.html"; exit 1; }
grep -q 'GLOSSARY_DATA_JSON' "$COMPILER_FILE" || { echo "❌ Missing GLOSSARY_DATA_JSON replacement in compiler.py"; exit 1; }
grep -q 'openGlossaryModal' "$APP_JS" || { echo "❌ Missing openGlossaryModal in app.js"; exit 1; }
grep -q 'closeGlossaryModal' "$APP_JS" || { echo "❌ Missing closeGlossaryModal in app.js"; exit 1; }
grep -q 'glossary-card' "$STYLE_CSS" || { echo "❌ Missing glossary-card styles in style.css"; exit 1; }
echo "  ✅ Dev Hub layout, compiler, JavaScript engine, and CSS styles verified."

echo "🎉 Architecture Glossary & Acronyms Parity Test PASSED successfully!"
exit 0
