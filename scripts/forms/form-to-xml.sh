#!/bin/bash
# ==============================================================================
# Oracle Forms to XML (frmf2xml) & XML to Forms (frmxml2f) Converter
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

CONTAINER_NAME="${FORMS_CONTAINER_NAME:-app-forms}"
CONV_PY="$PROJECT_ROOT/scripts/internal/forms_xml_converter.py"
MODE="auto" # auto, to-xml, to-fmb
OUTPUT_FILE=""
TARGET_FILES=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --to-fmb|--xml2f|--xml-to-fmb)
      MODE="to-fmb"
      shift
      ;;
    --to-xml|--f2xml|--fmb-to-xml)
      MODE="to-xml"
      shift
      ;;
    -o|--output)
      OUTPUT_FILE="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 [OPTIONS] <FILE...>"
      echo ""
      echo "Options:"
      echo "  --to-xml, --fmb-to-xml    Convert Forms .fmb binary module to XML format (frmf2xml)"
      echo "  --to-fmb, --xml-to-fmb    Convert Forms XML file back to binary .fmb module (frmxml2f)"
      echo "  -o, --output <FILE>       Specify explicit output filename"
      echo "  -h, --help                Show this help message"
      echo ""
      echo "Examples:"
      echo "  $0 forms_apps/test.fmb                    # Converts test.fmb -> test_fmb.xml"
      echo "  $0 --to-fmb forms_apps/test_fmb.xml       # Converts test_fmb.xml -> test.fmb"
      echo "  $0 -o forms_apps/custom.xml test.fmb      # Explicit output path"
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

CONTAINER_RUNNING=false
if $CTR_CMD ps --format "{{.Names}}" 2>/dev/null | grep -q "^${CONTAINER_NAME}$"; then
  CONTAINER_RUNNING=true
fi

echo "=================================================================="
echo "📄 ORACLE FORMS <-> XML CONVERTER (GIT DIFF & APEX COMPATIBLE)"
if [ "$CONTAINER_RUNNING" = "true" ]; then
  echo "🐳 Forms Engine: Container ($CONTAINER_NAME) - Active"
else
  echo "💻 Forms Engine: Local Converter Fallback (Ephemeral Mode)"
fi
echo "=================================================================="

for src_file in "${TARGET_FILES[@]}"; do
  if [ ! -f "$src_file" ]; then
    echo "❌ Error: Source file not found: $src_file"
    exit 1
  fi

  abs_src=$(cd "$(dirname "$src_file")" && pwd)/$(basename "$src_file")
  base_name=$(basename "$src_file")
  src_dir=$(dirname "$abs_src")

  # Detect mode if auto
  current_mode="$MODE"
  if [ "$current_mode" = "auto" ]; then
    if [[ "$base_name" == *.xml ]]; then
      current_mode="to-fmb"
    else
      current_mode="to-xml"
    fi
  fi

  if [ "$current_mode" = "to-fmb" ]; then
    echo "🔄 Converting XML -> Forms (.fmb): $base_name..."
    if [ -n "$OUTPUT_FILE" ]; then
      out_file="$OUTPUT_FILE"
    else
      clean_name="${base_name%.xml}"
      clean_name="${clean_name%_fmb}"
      out_file="$src_dir/${clean_name}.fmb"
    fi

    converted=false
    if [ "$CONTAINER_RUNNING" = "true" ]; then
      # If file is inside forms_apps, execute via container
      rel_path="${abs_src#$PROJECT_ROOT/forms_apps/}"
      if [ "$rel_path" != "$abs_src" ]; then
        if $CTR_CMD exec -e DISPLAY=:1 "$CONTAINER_NAME" bash -c "
          export ORACLE_HOME=/u01/oracle
          export FORMS_PATH=/u01/oracle/forms:/u01/oracle/forms_apps
          export LD_LIBRARY_PATH=/u01/oracle/lib:/u01/oracle/forms/lib
          if [ -x /u01/oracle/bin/frmxml2f.sh ]; then
            /u01/oracle/bin/frmxml2f.sh \"/u01/oracle/forms_apps/$rel_path\" overwrite=yes
          elif [ -x /u01/oracle/bin/frmxml2f ]; then
            /u01/oracle/bin/frmxml2f \"/u01/oracle/forms_apps/$rel_path\" overwrite=yes
          fi
        " >/dev/null 2>&1; then
          converted=true
        fi
      fi
    fi

    if [ "$converted" = "false" ] || [ ! -f "$out_file" ]; then
      python3 "$CONV_PY" --to-fmb "$abs_src" "$out_file" >/dev/null
    fi
    echo "   ✅ Forms module generated: $out_file"

  else
    echo "🔄 Converting Forms (.fmb) -> XML: $base_name..."
    if [ -n "$OUTPUT_FILE" ]; then
      out_file="$OUTPUT_FILE"
    else
      clean_name="${base_name%.fmb}"
      out_file="$src_dir/${clean_name}_fmb.xml"
    fi

    converted=false
    if [ "$CONTAINER_RUNNING" = "true" ]; then
      # If file is inside forms_apps, execute via container
      rel_path="${abs_src#$PROJECT_ROOT/forms_apps/}"
      if [ "$rel_path" != "$abs_src" ]; then
        if $CTR_CMD exec "$CONTAINER_NAME" bash -c "
          export ORACLE_HOME=/u01/oracle
          export FORMS_PATH=/u01/oracle/forms:/u01/oracle/forms_apps
          export LD_LIBRARY_PATH=/u01/oracle/lib:/u01/oracle/forms/lib
          if [ -x /u01/oracle/bin/frmf2xml.sh ]; then
            /u01/oracle/bin/frmf2xml.sh \"/u01/oracle/forms_apps/$rel_path\" overwrite=yes
          elif [ -x /u01/oracle/bin/frmf2xml ]; then
            /u01/oracle/bin/frmf2xml \"/u01/oracle/forms_apps/$rel_path\" overwrite=yes
          fi
        " >/dev/null 2>&1; then
          converted=true
        fi
      fi
    fi

    if [ "$converted" = "false" ] || [ ! -f "$out_file" ]; then
      python3 "$CONV_PY" --to-xml "$abs_src" "$out_file" >/dev/null
    fi
    echo "   ✅ XML file generated: $out_file"
  fi
done

echo "=================================================================="
echo "🎉 Conversion completed successfully!"
echo "=================================================================="
