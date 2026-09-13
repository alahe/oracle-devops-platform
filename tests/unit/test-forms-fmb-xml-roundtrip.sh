#!/usr/bin/env bash
# ==============================================================================
# Unit Test: Oracle Forms 14c 2-Pass FMB <-> XML Roundtrip & Semantic Verifier
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "=================================================================="
echo "🧪 UNIT TEST: Forms 14c FMB <-> XML 2-Pass Roundtrip Suite"
echo "=================================================================="

# 1. Check script syntax and executability
echo "▶️  [1/4] Checking scripts existence, executability and syntax..."
for s in "scripts/forms/test-fmb-xml-roundtrip.sh" "scripts/forms/form-to-xml.sh"; do
  f="$PROJECT_ROOT/$s"
  [ -f "$f" ] || { echo "❌ Script missing: $f"; exit 1; }
  [ -x "$f" ] || { echo "❌ Script not executable: $f"; exit 1; }
  bash -n "$f" || { echo "❌ Syntax error in script: $f"; exit 1; }
  echo "   ✅ $s: syntax OK"
done

for py in "scripts/internal/forms_xml_converter.py" "scripts/internal/compare_forms_xml.py"; do
  f="$PROJECT_ROOT/$py"
  [ -f "$f" ] || { echo "❌ Python script missing: $f"; exit 1; }
  python3 -m py_compile "$f" || { echo "❌ Python syntax error in: $f"; exit 1; }
  echo "   ✅ $py: syntax OK"
done

# 2. Test positive 2-pass roundtrip on test.fmb
echo -e "\n▶️  [2/4] Testing full 2-pass roundtrip pipeline on forms_apps/test.fmb..."
ROUNDTRIP_OUT=$("$PROJECT_ROOT/scripts/forms/test-fmb-xml-roundtrip.sh" "$PROJECT_ROOT/forms_apps/test.fmb")
if echo "$ROUNDTRIP_OUT" | grep -q "100% MATCH"; then
  echo "   ✅ 2-pass roundtrip completed with 100% semantic match!"
else
  echo "❌ 2-pass roundtrip did not report 100% match!"
  echo "$ROUNDTRIP_OUT"
  exit 1
fi

# 3. Test volatile metadata filtering (DateSaved / timestamp variation tolerance)
echo -e "\n▶️  [3/4] Testing volatile metadata tolerance in compare_forms_xml.py..."
TMP_TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_TEST_DIR"' EXIT

cat << 'XML1' > "$TMP_TEST_DIR/doc1.xml"
<?xml version="1.0" encoding="UTF-8"?>
<Module version="140102" xmlns="http://xmlns.oracle.com/Forms" Name="TEST">
  <FormModule Name="TEST" DateSaved="Monday Jan 01 2024 10:00:00" SaveTimestamp="2024-01-01T10:00:00">
    <Block Name="USERS">
      <Item Name="USER_ID" ItemType="Text Item" DataType="Number"/>
    </Block>
  </FormModule>
</Module>
XML1

cat << 'XML2' > "$TMP_TEST_DIR/doc2.xml"
<?xml version="1.0" encoding="UTF-8"?>
<Module version="140102" xmlns="http://xmlns.oracle.com/Forms" Name="TEST">
  <FormModule Name="TEST" DateSaved="Sunday Sep 13 2026 18:00:00" SaveTimestamp="2026-09-13T18:00:00" CompilerVersion="14.1.2">
    <Block Name="USERS">
      <Item Name="USER_ID" ItemType="Text Item" DataType="Number"/>
    </Block>
  </FormModule>
</Module>
XML2

if python3 "$PROJECT_ROOT/scripts/internal/compare_forms_xml.py" "$TMP_TEST_DIR/doc1.xml" "$TMP_TEST_DIR/doc2.xml" >/dev/null 2>&1; then
  echo "   ✅ Metadata tolerance test passed: differing DateSaved/CompilerVersion correctly filtered!"
else
  echo "❌ compare_forms_xml.py failed on differing DateSaved metadata!"
  exit 1
fi

# 4. Test negative detection (semantic differences must fail with exit code 1)
echo -e "\n▶️  [4/4] Testing negative mismatch detection in compare_forms_xml.py..."
cat << 'XML_DIFF' > "$TMP_TEST_DIR/doc_diff.xml"
<?xml version="1.0" encoding="UTF-8"?>
<Module version="140102" xmlns="http://xmlns.oracle.com/Forms" Name="TEST">
  <FormModule Name="TEST">
    <Block Name="USERS">
      <Item Name="USER_ID" ItemType="Text Item" DataType="Char"/>
    </Block>
  </FormModule>
</Module>
XML_DIFF

if python3 "$PROJECT_ROOT/scripts/internal/compare_forms_xml.py" "$TMP_TEST_DIR/doc1.xml" "$TMP_TEST_DIR/doc_diff.xml" >/dev/null 2>&1; then
  echo "❌ Expected failure when DataType differs ('Number' vs 'Char'), but got success!"
  exit 1
else
  echo "   ✅ Negative test passed: detected mismatch in DataType ('Number' vs 'Char') as expected!"
fi

echo -e "\n=================================================================="
echo "🎉 ALL FORMS FMB <-> XML ROUNDTRIP TESTS PASSED 100%!"
echo "=================================================================="
