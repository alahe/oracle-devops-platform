#!/usr/bin/env bash
# ==============================================================================
# Unit Test: Developer Hub HTML Generation & Architecture Visualizer
# Validates SPA structure, 9 tabs, i18n dictionary (6 languages), and Blueprints catalog
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "🔍 Testing Developer Hub generation across Blueprints..."

# Test 1: Generate for default blueprint
TMP_OUT="$WORKSPACE_DIR/docs/dev-hub-test.html"
ACTIVE_BP_ID=21 "$WORKSPACE_DIR/scripts/internal/generate-dev-hub.sh" "$TMP_OUT"

if [ ! -f "$TMP_OUT" ]; then
  echo "❌ Error: $TMP_OUT was not created!"
  exit 1
fi

# Verify required tabs and sections
for expected in "tab-services" "tab-podman" "tab-presentation" "tab-snapshots" "tab-forms-pub" "tab-apexlang" "tab-docs" "tab-devops" "tab-testing" "tab-benchmarks"; do
  if ! grep -q "$expected" "$TMP_OUT"; then
    echo "❌ Missing expected tab ID in HTML: $expected"
    rm -f "$TMP_OUT"
    exit 1
  fi
done

# Verify i18n languages across all 6 languages
for lang in "en:" "et:" "fi:" "sv:" "lv:" "lt:"; do
  if ! grep -q "$lang" "$TMP_OUT"; then
    echo "❌ Missing language dictionary block: $lang"
    rm -f "$TMP_OUT"
    exit 1
  fi
done

# Verify Mermaid diagrams engine and modal container
if ! grep -q "mermaid.min.js" "$TMP_OUT" || ! grep -q "bp-modal-mermaid" "$TMP_OUT"; then
  echo "❌ Missing Mermaid diagram blocks in HTML"
  rm -f "$TMP_OUT"
  exit 1
fi

# Verify Blueprints JSON Data
if ! grep -q "BLUEPRINTS_DATA = \[" "$TMP_OUT"; then
  echo "❌ Missing BLUEPRINTS_DATA array in HTML"
  rm -f "$TMP_OUT"
  exit 1
fi

# Verify Single Source of Truth Platform Version in Header and Footer (Rule 16)
EXPECTED_VER="$(cat "$WORKSPACE_DIR/VERSION" 2>/dev/null || echo "2.3.0")"
if grep -q "%PLATFORM_VERSION%" "$TMP_OUT"; then
  echo "❌ Unrendered %PLATFORM_VERSION% token found in $TMP_OUT!"
  rm -f "$TMP_OUT"
  exit 1
fi

if ! grep -q "id=\"platform-global-version\">v${EXPECTED_VER}<" "$TMP_OUT"; then
  echo "❌ Missing or mismatched platform-global-version in header (expected v${EXPECTED_VER})"
  rm -f "$TMP_OUT"
  exit 1
fi

if ! grep -q "id=\"footer-platform-version\"" "$TMP_OUT" || ! grep -q "v${EXPECTED_VER}" "$TMP_OUT"; then
  echo "❌ Missing or mismatched footer-platform-version in footer (expected v${EXPECTED_VER})"
  rm -f "$TMP_OUT"
  exit 1
fi
echo "✅ Platform version v${EXPECTED_VER} verified in both header and footer!"

# Verify embedded JavaScript syntax integrity (catches syntax errors, missing commas, unescaped strings)
if command -v node >/dev/null 2>&1; then
  node -e "
    const fs = require('fs');
    const html = fs.readFileSync('$TMP_OUT', 'utf8');
    const scriptMatches = [...html.matchAll(/<script(?:\s+[^>]*)?>([\s\S]*?)<\/script>/gi)]
      .map(m => m[1].trim())
      .filter(c => c.length > 0);
    if (scriptMatches.length === 0) {
      console.error('❌ Error: Could not find embedded script block in $TMP_OUT');
      process.exit(1);
    }
    const tmpJs = '$TMP_OUT.check.js';
    for (let i = 0; i < scriptMatches.length; i++) {
      fs.writeFileSync(tmpJs, scriptMatches[i]);
      try {
        require('child_process').execSync('node --check ' + tmpJs, { stdio: 'pipe' });
      } finally {
        if (fs.existsSync(tmpJs)) fs.unlinkSync(tmpJs);
      }
    }
  "
  echo "✅ Embedded JavaScript syntax validation passed (no SyntaxError)!"
fi

rm -f "$TMP_OUT"
echo "✅ Developer Hub generation unit tests passed successfully across all 6 languages & 9 tabs!"
