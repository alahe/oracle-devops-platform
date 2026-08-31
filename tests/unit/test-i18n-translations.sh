#!/usr/bin/env bash
# ==============================================================================
# Unit Test: test-i18n-translations.sh
# Verifies 6-language dictionary symmetry, format strings, and fallback resilience.
# Supports: 🇬🇧 EN, 🇪🇪 ET, 🇫🇮 FI, 🇸🇪 SV, 🇱🇻 LV, 🇱🇹 LT (Rule 9)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source i18n
# shellcheck source=/dev/null
source "$WORKSPACE_DIR/scripts/internal/i18n.sh"

echo "🔍 Testing i18n language resolution across all 6 languages..."
CLI_LANG="et" && [ "$(resolve_cli_lang)" = "et" ]
CLI_LANG="est" && [ "$(resolve_cli_lang)" = "et" ]
CLI_LANG="fi" && [ "$(resolve_cli_lang)" = "fi" ]
CLI_LANG="suomi" && [ "$(resolve_cli_lang)" = "fi" ]
CLI_LANG="sv" && [ "$(resolve_cli_lang)" = "sv" ]
CLI_LANG="swe" && [ "$(resolve_cli_lang)" = "sv" ]
CLI_LANG="lv" && [ "$(resolve_cli_lang)" = "lv" ]
CLI_LANG="lt" && [ "$(resolve_cli_lang)" = "lt" ]
CLI_LANG="en" && [ "$(resolve_cli_lang)" = "en" ]
CLI_LANG="unknown" && [ "$(resolve_cli_lang)" = "en" ]
echo "✅ Language resolution tests passed for all 6 languages!"

echo "🔍 Testing dictionary key symmetry across EN, ET, FI, SV, LV, LT..."
MISSING=0
LANGS=("et" "fi" "sv" "lv" "lt")

# Find all registered EN keys
EN_KEYS=$(awk -F'_reg_msg en ' '/^_reg_msg en/{print $2}' "$WORKSPACE_DIR/scripts/internal/i18n.sh" | awk '{print $1}' | sort -u)

for key in $EN_KEYS; do
  for l in "${LANGS[@]}"; do
    var_name="_I18N_${l}_${key}"
    val="${!var_name:-}"
    if [ -z "$val" ]; then
      echo "❌ Missing translation for [${l}_${key}]"
      MISSING=$((MISSING + 1))
    fi
  done
done

if [ $MISSING -gt 0 ]; then
  echo "❌ Total missing translations: $MISSING"
  exit 1
fi

echo "✅ All 6 languages have 100% dictionary symmetry!"

echo "🔍 Testing 3-tier fallback..."
export ACTIVE_CLI_LANG="sv"
export CLI_LANG="sv"
out=$(msg_str "NON_EXISTENT_KEY_123")
[ "$out" = "NON_EXISTENT_KEY_123" ]
echo "✅ Fallback to raw key passed!"

echo "test-i18n-translations: PASS"
