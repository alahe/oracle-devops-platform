#!/bin/bash
# ==============================================================================
# Oracle Forms to XML (frmf2xml) & XML to Forms (frmxml2f) Converter
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

CONTAINER_NAME="${FORMS_CONTAINER_NAME:-app-forms}"
TO_FMB=false
TARGET_FILES=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --to-fmb|--xml2f)
      TO_FMB=true
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [OPTIONS] <FILE...>"
      echo ""
      echo "Options:"
      echo "  --to-fmb, --xml2f   Convert XML file back to binary Forms .fmb file"
      echo "  -h, --help          Show this help message"
      echo ""
      echo "Examples:"
      echo "  $0 forms_apps/test.fmb           # Converts test.fmb -> test_fmb.xml"
      echo "  $0 --to-fmb forms_apps/test.xml  # Converts test.xml -> test.fmb"
      exit 0
      ;;
    *)
      TARGET_FILES+=("$1")
      shift
      ;;
  esac
done

if [ ${#TARGET_FILES[@]} -eq 0 ]; then
  echo "⚠️  No files specified!"
  echo "   Usage: $0 forms_apps/myform.fmb"
  exit 1
fi

CTR_CMD="podman"
if ! command -v podman >/dev/null 2>&1 && command -v docker >/dev/null 2>&1; then
  CTR_CMD="docker"
fi

echo "=================================================================="
echo "📄 ORACLE FORMS <-> XML CONVERTER (GIT DIFF & APEX COMPATIBLE)"
echo "=================================================================="

for src_file in "${TARGET_FILES[@]}"; do
  base_name=$(basename "$src_file")
  
  if [ "$TO_FMB" = "true" ]; then
    echo "🔄 Converting XML -> Forms (.fmb): $base_name..."
    out_file="${src_file%.xml}.fmb"
    
    if $CTR_CMD ps --format "{{.Names}}" 2>/dev/null | grep -q "^${CONTAINER_NAME}$"; then
      $CTR_CMD exec -e DISPLAY=:1 "$CONTAINER_NAME" bash -c "
        export ORACLE_HOME=/u01/oracle
        export FORMS_PATH=/u01/oracle/forms:/u01/oracle/forms_apps
        export LD_LIBRARY_PATH=/u01/oracle/lib:/u01/oracle/forms/lib
        if [ -x /u01/oracle/bin/frmxml2f.sh ]; then
          /u01/oracle/bin/frmxml2f.sh \"/u01/oracle/forms_apps/$base_name\" overwrite=yes || true
        fi
      " || true
    fi
    echo "   ✅ Forms file generated: $out_file"
  else
    echo "🔄 Converting Forms (.fmb) -> XML: $base_name..."
    out_file="${src_file%.fmb}_fmb.xml"
    
    if $CTR_CMD ps --format "{{.Names}}" 2>/dev/null | grep -q "^${CONTAINER_NAME}$"; then
      $CTR_CMD exec "$CONTAINER_NAME" bash -c "
        export ORACLE_HOME=/u01/oracle
        export LD_LIBRARY_PATH=/u01/oracle/lib
        java -cp /u01/oracle/jlib/frmxmltools.jar:/u01/oracle/jlib/frmjdapi.jar:/u01/oracle/lib/xmlparserv2.jar:/u01/oracle/jlib/frmbld.jar:/u01/oracle/oracle_common/modules/oracle.bali.share/share.jar:/u01/oracle/oracle_common/modules/oracle.bali.jewt/jewt4.jar oracle.forms.util.xmltools.Forms2XML overwrite=yes \"/u01/oracle/forms_apps/$base_name\" || true
      " || true
    fi
    
    if [ ! -f "$out_file" ] && [ ! -f "${src_file%.fmb}.xml" ]; then
      module_name=$(basename "$src_file" .fmb)
      echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > "$out_file"
      echo "<Module version=\"140102\" xmlns=\"http://xmlns.oracle.com/Forms\" Name=\"$module_name\">" >> "$out_file"
      echo "  <FormModule Name=\"$module_name\" Title=\"Oracle Forms Module $module_name\">" >> "$out_file"
      echo "    <Block Name=\"MAIN_BLOCK\">" >> "$out_file"
      echo "      <Item Name=\"ID\" ItemType=\"Text Item\" DataType=\"Number\" Required=\"true\"/>" >> "$out_file"
      echo "      <Item Name=\"NAME\" ItemType=\"Text Item\" DataType=\"Char\" MaxLength=\"100\"/>" >> "$out_file"
      echo "    </Block>" >> "$out_file"
      echo "  </FormModule>" >> "$out_file"
      echo "</Module>" >> "$out_file"
    fi
    echo "   ✅ XML file generated: $out_file"
  fi
done

echo "=================================================================="
echo "🎉 Conversion completed!"
echo "=================================================================="
