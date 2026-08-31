#!/usr/bin/env bash
# ==============================================================================
# Unit Test: Developer Hub HTML Generation & Architecture Visualizer
# Validates SPA structure, 6 tabs, i18n dictionary, and Blueprints catalog
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "🔍 Testing Developer Hub generation across Blueprints..."

# Test 1: Generate for default blueprint
TMP_OUT="$WORKSPACE_DIR/docs/dev-hub-test.html"
ACTIVE_BP_ID=41 "$WORKSPACE_DIR/scripts/internal/generate-dev-hub.sh" "$TMP_OUT"

if [ ! -f "$TMP_OUT" ]; then
  echo "❌ Error: $TMP_OUT was not created!"
  exit 1
fi

# Verify required tabs and sections
for expected in "tab-services" "tab-architecture" "tab-blueprints" "tab-docs" "tab-devops" "tab-benchmarks"; do
  if ! grep -q "$expected" "$TMP_OUT"; then
    echo "❌ Missing expected tab ID in HTML: $expected"
    rm -f "$TMP_OUT"
    exit 1
  fi
done

# Verify i18n languages
for lang in "en:" "et:" "sv:" "lv:" "lt:"; do
  if ! grep -q "$lang" "$TMP_OUT"; then
    echo "❌ Missing language dictionary block: $lang"
    rm -f "$TMP_OUT"
    exit 1
  fi
done

# Verify Mermaid diagrams
if ! grep -q "class=\"mermaid\"" "$TMP_OUT"; then
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

rm -f "$TMP_OUT"
echo "✅ Developer Hub HTML generation test passed!"
echo "test-dev-hub-generation: PASS"
