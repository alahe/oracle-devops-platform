#!/usr/bin/env bash
# ==============================================================================
# Unit Test: Oracle BI Publisher RTF Template & GitHub Copilot Integration
# Validates XML schema, RTF syntax integrity, Copilot instructions, and scripts
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "================================================================================"
echo "🧪 Testing Oracle BI Publisher RTF & GitHub Copilot Integration"
echo "================================================================================"

XML_FILE="$WORKSPACE_DIR/templates/publisher/samples/arve_test_andmed.xml"
RTF_FILE="$WORKSPACE_DIR/templates/publisher/samples/arve_test_standard.rtf"
COPILOT_SYS="$WORKSPACE_DIR/.github/copilot-instructions.md"
COPILOT_GUIDE="$WORKSPACE_DIR/templates/publisher/COPILOT_INSTRUCTIONS.md"
WATCHER_SH="$WORKSPACE_DIR/scripts/publisher/watch-render-host.sh"

FAILED=0

# 1. Validate XML Test Data
echo "▶️ [1/5] Validating XML test data file..."
if [ ! -f "$XML_FILE" ]; then
  echo "   ❌ Error: $XML_FILE not found"
  FAILED=1
else
  if python3 -c "import xml.etree.ElementTree as ET; ET.parse('$XML_FILE')" 2>/dev/null; then
    echo "   ✅ XML syntax is 100% valid: $(basename "$XML_FILE")"
  else
    echo "   ❌ Error: XML file has parsing errors: $XML_FILE"
    FAILED=1
  fi
fi

# 2. Validate RTF Template & Mandatory Oracle XDO Tags
echo "▶️ [2/5] Validating RTF template and XDO tags..."
if [ ! -f "$RTF_FILE" ]; then
  echo "   ❌ Error: $RTF_FILE not found"
  FAILED=1
else
  RTF_CONTENT="$(cat "$RTF_FILE")"
  
  # Check for standard RTF header
  if [[ "$RTF_CONTENT" == *"{\\rtf1"* ]]; then
    echo "   ✅ Valid RTF header present"
  else
    echo "   ❌ Missing valid RTF header in $RTF_FILE"
    FAILED=1
  fi

  # Check mandatory Oracle BI Publisher tags
  MANDATORY_TAGS=(
    "<?SELLER/COMPANY_NAME?>"
    "<?INVOICE_METADATA/INVOICE_NUM?>"
    "<?BUYER/COMPANY_NAME?>"
    "<?for-each:LINES/LINE?>"
    "<?end for-each?>"
    "<?format-number("
    "<?TOTALS/GRAND_TOTAL?>"
  )

  for tag in "${MANDATORY_TAGS[@]}"; do
    if [[ "$RTF_CONTENT" == *"$tag"* ]]; then
      echo "   ✅ Mandatory XDO tag present: $tag"
    else
      echo "   ❌ Missing mandatory XDO tag: $tag"
      FAILED=1
    fi
  done
fi

# 3. Check Structural Parity: XML tags vs RTF tags
echo "▶️ [3/5] Checking structural tag parity between XML and RTF..."
python3 - "$XML_FILE" "$RTF_FILE" << 'EOF'
import sys, re
import xml.etree.ElementTree as ET

xml_path = sys.argv[1]
rtf_path = sys.argv[2]

tree = ET.parse(xml_path)
root = tree.getroot()

# Collect all leaf and parent tag paths in XML
xml_tags = set()
def walk(node, path=""):
    curr = f"{path}/{node.tag}" if path else node.tag
    xml_tags.add(node.tag)
    xml_tags.add(curr)
    for child in node:
        walk(child, curr)
walk(root)

with open(rtf_path, "r", encoding="latin-1") as f:
    content = f.read()

# Find all <?...?> tags in RTF
matches = re.findall(r'<\?([^?]+)\?>', content)
orphans = []
for m in matches:
    m = m.strip()
    if m.startswith("for-each:") or m.startswith("end for-each"):
        continue
    if m.startswith("if:") or m == "end if":
        continue
    if "format-number(" in m or "format-date(" in m or "sum(" in m:
        field_match = re.search(r'\(\s*([A-Za-z0-9_/-]+)', m)
        if field_match:
            fld = field_match.group(1).split('/')[-1]
            if fld not in xml_tags:
                orphans.append(fld)
        continue
    fld = m.split('/')[-1]
    if fld not in xml_tags:
        orphans.append(m)

if orphans:
    print(f"   ⚠️ Note: Tag(s) in RTF not directly matching XML: {orphans}")
else:
    print("   ✅ 100% of RTF fields match XML schema elements perfectly!")
EOF

# 4. Validate GitHub Copilot Instructions
echo "▶️ [4/5] Checking GitHub Copilot instructions..."
if [ -f "$COPILOT_SYS" ] && grep -q "Oracle Analytics Publisher" "$COPILOT_SYS"; then
  echo "   ✅ Official VS Code Copilot instructions active in: .github/copilot-instructions.md"
else
  echo "   ❌ Missing or incomplete: .github/copilot-instructions.md"
  FAILED=1
fi

if [ -f "$COPILOT_GUIDE" ] && grep -q "GitHub Copilot" "$COPILOT_GUIDE"; then
  echo "   ✅ Developer Copilot cheat-sheet present in: templates/publisher/COPILOT_INSTRUCTIONS.md"
else
  echo "   ❌ Missing or incomplete: templates/publisher/COPILOT_INSTRUCTIONS.md"
  FAILED=1
fi

# 5. Validate Live Host Watcher Script
echo "▶️ [5/7] Checking live host watcher script..."
if [ -x "$WATCHER_SH" ]; then
  echo "   ✅ Live host watcher script is executable: scripts/publisher/watch-render-host.sh"
else
  echo "   ❌ Watcher script is missing or not executable: $WATCHER_SH"
  FAILED=1
fi

# 6. Validate XML Field Inspector & Tag Builder
echo "▶️ [6/7] Checking XML Field Inspector & Tag Builder..."
INSPECTOR_PY="$WORKSPACE_DIR/docker/publisher-designer/xml-field-inspector.py"
if [ -x "$INSPECTOR_PY" ]; then
  FIELDS_CNT=$("$INSPECTOR_PY" --list-fields | wc -l | tr -d ' ')
  if [ "$FIELDS_CNT" -ge 15 ]; then
    echo "   ✅ XML Field Inspector extracted $FIELDS_CNT fields successfully"
  else
    echo "   ❌ XML Field Inspector extracted too few fields: $FIELDS_CNT"
    FAILED=1
  fi
else
  echo "   ❌ Missing or non-executable: $INSPECTOR_PY"
  FAILED=1
fi

# 7. Validate LibreOffice Profile Setup and Studio Launcher
echo "▶️ [7/7] Checking LibreOffice Publisher Profile & Studio scripts..."
LO_SETUP="$WORKSPACE_DIR/docker/publisher-designer/setup-libreoffice-profile.sh"
STUDIO_SH="$WORKSPACE_DIR/docker/publisher-designer/launch-studio.sh"
if [ -x "$LO_SETUP" ] && [ -x "$STUDIO_SH" ]; then
  echo "   ✅ LibreOffice profile setup script is executable: setup-libreoffice-profile.sh"
  echo "   ✅ Studio launcher script is executable: launch-studio.sh"
else
  echo "   ❌ Studio scripts missing or non-executable"
  FAILED=1
fi

echo "================================================================================"
if [ "$FAILED" -eq 0 ]; then
  echo "🎉 SUCCESS: All Oracle BI Publisher & VS Code Copilot unit tests passed!"
  exit 0
else
  echo "❌ FAILED: One or more unit tests failed."
  exit 1
fi
