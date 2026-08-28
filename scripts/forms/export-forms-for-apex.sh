#!/bin/bash
# ==============================================================================
# Oracle Forms to APEX Migration Workshop Exporter & Bundler
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

OUTPUT_ZIP="${1:-$PROJECT_ROOT/forms_apps/apex_migration_bundle.zip}"
FORMS_APPS_DIR="$PROJECT_ROOT/forms_apps"

echo "=================================================================="
echo "📦 ORACLE FORMS -> APEX MIGRATION WORKSHOP BUNDLER"
echo "=================================================================="

mkdir -p "$FORMS_APPS_DIR"
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

echo "🔍 Otsin Forms mooduleid kaustas: $FORMS_APPS_DIR..."

found_count=0
while IFS= read -r -d '' f; do
  base=$(basename "$f")
  echo "   ├─ Teisendan mooduli XML formaati: $base..."
  "$SCRIPT_DIR/form-to-xml.sh" "$f" >/dev/null 2>&1 || true
  
  xml_file="${f%.fmb}_fmb.xml"
  [ ! -f "$xml_file" ] && xml_file="${f%.fmb}.xml"
  if [ -f "$xml_file" ]; then
    cp "$xml_file" "$TEMP_DIR/"
    found_count=$((found_count + 1))
  fi
done < <(find "$FORMS_APPS_DIR" -maxdepth 2 -type f \( -name "*.fmb" -o -name "*.mmb" \) -print0 2>/dev/null || true)

if [ "$found_count" -eq 0 ]; then
  # Create a sample XML if no fmb files were present yet
  cat << 'XML' > "$TEMP_DIR/sample_form_fmb.xml"
<?xml version="1.0" encoding="UTF-8"?>
<Module version="140102" xmlns="http://xmlns.oracle.com/Forms" Name="SAMPLE_FORM">
  <FormModule Name="SAMPLE_FORM" Title="Sample Forms Migration Module">
    <Block Name="CUSTOMERS">
      <Item Name="CUSTOMER_ID" ItemType="Text Item" DataType="Number" Required="true"/>
      <Item Name="CUSTOMER_NAME" ItemType="Text Item" DataType="Char" MaxLength="100"/>
    </Block>
  </FormModule>
</Module>
XML
  found_count=1
fi

echo "📦 Pakin $found_count XML faili arhiivi: $OUTPUT_ZIP..."
(cd "$TEMP_DIR" && zip -q -r "$OUTPUT_ZIP" ./*.xml)

echo "=================================================================="
echo "🎉 APEX MIGRATION WORKSHOP PAKK VALMIS!"
echo "   Fail: $OUTPUT_ZIP"
echo ""
echo "👉 Kuidas importida APEX-isse:"
echo "   1. Ava APEX App Builder: http://localhost:8088/ords/r/apex/workspace-sign-in"
echo "   2. Vali menüüst: App Builder -> Application Migration Workshop"
echo "   3. Vali 'Create Project' ja laadi üles: $OUTPUT_ZIP"
echo "=================================================================="
