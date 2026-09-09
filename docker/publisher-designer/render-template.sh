#!/usr/bin/env bash
# ==============================================================================
# In-Container Oracle BI Publisher / XDO Template Fast-Renderer CLI
# Converts .rtf + .xml -> .pdf using Java XDO / FOProcessor or LibreOffice Headless
# Supports multi-language translation via XLIFF (--locale <et|en|fi|sv|lv|lt>)
# ==============================================================================
set -euo pipefail

LOCALE="et"
POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --locale|-l)
      LOCALE="$2"
      shift 2
      ;;
    --locale=*)
      LOCALE="${1#*=}"
      shift 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1")
      shift 1
      ;;
  esac
done

if [ "${#POSITIONAL_ARGS[@]}" -lt 2 ]; then
  echo "Usage: $0 <template.rtf> <data.xml> [output.pdf] [--locale <et|en|fi|sv|lv|lt>]"
  exit 1
fi

TPL_FILE="${POSITIONAL_ARGS[0]}"
XML_FILE="${POSITIONAL_ARGS[1]}"
OUT_PDF="${POSITIONAL_ARGS[2]:-$(dirname "$TPL_FILE")/output_${LOCALE}_$(date +%s).pdf}"

echo "================================================================================"
echo "⚡ Oracle Analytics Publisher Fast-Render Engine"
echo "   Template: $TPL_FILE"
echo "   Data:     $XML_FILE"
echo "   Output:   $OUT_PDF"
echo "   Locale:   $LOCALE"
echo "================================================================================"

if [ ! -f "$TPL_FILE" ]; then
  echo "❌ Error: Template file not found: $TPL_FILE"
  exit 1
fi

if [ ! -f "$XML_FILE" ]; then
  echo "❌ Error: XML Data file not found: $XML_FILE"
  exit 1
fi

mkdir -p "$(dirname "$OUT_PDF")"

# 1. Try Java Oracle XDO FOProcessor if jars are available
if [ -d "/u01/oracle/xdo/lib" ] && [ "$(ls -A /u01/oracle/xdo/lib/*.jar 2>/dev/null)" ]; then
  echo "🚀 Running Oracle XDO FOProcessor..."
  java -cp "/u01/oracle/xdo/lib/*" oracle.xdo.template.FOProcessor \
       -xml "$XML_FILE" \
       -rtf "$TPL_FILE" \
       -out "$OUT_PDF" \
       -locale "$LOCALE"
else
  # 2. XDO Preprocessing + Native Headless Conversion with XLIFF & Locale
  echo "📄 Running XDO Preprocessing & Headless RTF to PDF Processor (Locale: $LOCALE)..."
  TMP_OUT_DIR="$(mktemp -d)"
  POPULATED_RTF="$TMP_OUT_DIR/populated_template.rtf"
  
  PREPROCESSOR="/u01/oracle/bin/xdo-preprocessor.py"
  if [ ! -f "$PREPROCESSOR" ]; then
    PREPROCESSOR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/xdo-preprocessor.py"
  fi
  
  if [ -f "$PREPROCESSOR" ]; then
    python3 "$PREPROCESSOR" "$XML_FILE" "$TPL_FILE" "$POPULATED_RTF" --locale "$LOCALE"
    RENDER_SRC="$POPULATED_RTF"
  else
    RENDER_SRC="$TPL_FILE"
  fi

  ACCESSIBLE_EXPORTER="/u01/oracle/bin/export-accessible-pdf.py"
  if [ ! -f "$ACCESSIBLE_EXPORTER" ]; then
    ACCESSIBLE_EXPORTER="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/export-accessible-pdf.py"
  fi

  if [ -f "$ACCESSIBLE_EXPORTER" ]; then
    echo "♿ Exporting Accessible Tagged PDF (PDF/UA-1 & Section 508 / WCAG compliant)..."
    python3 "$ACCESSIBLE_EXPORTER" "$RENDER_SRC" "$OUT_PDF" --locale "$LOCALE" || {
      echo "⚠️ Falling back to standard headless export..."
      libreoffice --headless --convert-to pdf "$RENDER_SRC" --outdir "$TMP_OUT_DIR"
      BASE_NAME="$(basename "$RENDER_SRC" .rtf)"
      cp "$TMP_OUT_DIR/${BASE_NAME}.pdf" "$OUT_PDF"
    }
  else
    libreoffice --headless --convert-to pdf "$RENDER_SRC" --outdir "$TMP_OUT_DIR"
    BASE_NAME="$(basename "$RENDER_SRC" .rtf)"
    cp "$TMP_OUT_DIR/${BASE_NAME}.pdf" "$OUT_PDF"
  fi
  rm -rf "$TMP_OUT_DIR"
fi

if [ -f "$OUT_PDF" ]; then
  SIZE=$(wc -c < "$OUT_PDF" | tr -d ' ')
  echo "✅ PDF successfully generated!"
  echo "   Location: $OUT_PDF"
  echo "   Size:     $SIZE bytes"
else
  echo "❌ Error: PDF output file was not created."
  exit 1
fi
