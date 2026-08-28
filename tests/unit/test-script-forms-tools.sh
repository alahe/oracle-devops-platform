#!/bin/bash
# ==============================================================================
# Unit Test: Oracle Forms Developer & APEX Migration Tools
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "=================================================================="
echo "🧪 UNIT TEST: Forms Developer Tools & APEX Migration Scripts"
echo "=================================================================="

# 1. Check syntax of all scripts
for s in launch-builder.sh compile-form.sh form-to-xml.sh export-forms-for-apex.sh extract-forms-plsql.sh; do
  f="$PROJECT_ROOT/scripts/forms/$s"
  echo "▶️  Testing script existence and syntax: $s..."
  [ -f "$f" ] || { echo "❌ Faili $f ei leitud!"; exit 1; }
  [ -x "$f" ] || { echo "❌ Fail $f ei ole käivitatav!"; exit 1; }
  bash -n "$f" || { echo "❌ Süntaksiviga failis $f!"; exit 1; }
  echo "   ✅ $s süntaks OK!"
done

# 2. Test help commands
echo "▶️  Testing help options..."
"$PROJECT_ROOT/scripts/forms/launch-builder.sh" --help >/dev/null
"$PROJECT_ROOT/scripts/forms/compile-form.sh" --help >/dev/null
"$PROJECT_ROOT/scripts/forms/form-to-xml.sh" --help >/dev/null

# 3. Test XML conversion fallback
TEMP_TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_TEST_DIR"' EXIT

echo "▶️  Testing form-to-xml.sh conversion..."
touch "$TEMP_TEST_DIR/test_unit.fmb"
"$PROJECT_ROOT/scripts/forms/form-to-xml.sh" "$TEMP_TEST_DIR/test_unit.fmb" >/dev/null 2>&1 || true
[ -f "$TEMP_TEST_DIR/test_unit_fmb.xml" ] || { echo "❌ XML faili ei loodud!"; exit 1; }
echo "   ✅ form-to-xml.sh genereeris XML faili korrektselt!"

# 4. Test extract-forms-plsql.sh
echo "▶️  Testing extract-forms-plsql.sh..."
"$PROJECT_ROOT/scripts/forms/extract-forms-plsql.sh" "$TEMP_TEST_DIR/test_unit_fmb.xml" "$TEMP_TEST_DIR/extracted" >/dev/null 2>&1
[ -f "$TEMP_TEST_DIR/extracted/pkg_test_unit_forms_logic.sql" ] || { echo "❌ PL/SQL faili ei loodud!"; exit 1; }
echo "   ✅ extract-forms-plsql.sh genereeris PL/SQL paketi korrektselt!"

# 5. Test export-forms-for-apex.sh
echo "▶️  Testing export-forms-for-apex.sh bundle generation..."
"$PROJECT_ROOT/scripts/forms/export-forms-for-apex.sh" "$TEMP_TEST_DIR/bundle.zip" >/dev/null 2>&1
[ -f "$TEMP_TEST_DIR/bundle.zip" ] || { echo "❌ APEX migration bundle.zip faili ei loodud!"; exit 1; }
echo "   ✅ export-forms-for-apex.sh genereeris ZIP paki edukalt!"

echo "=================================================================="
echo "🎉 KÕIK FORMS TÖÖRIISTADE ÜHIKUTESTID LÄBITUD 100% EDUKALT!"
echo "=================================================================="
