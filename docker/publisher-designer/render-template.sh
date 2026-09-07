#!/usr/bin/env bash
# ==============================================================================
# In-Container Oracle BI Publisher / XDO Template Fast-Renderer CLI
# Converts .rtf + .xml -> .pdf using Java XDO / FOProcessor or LibreOffice Headless
# ==============================================================================
set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <template.rtf> <data.xml> [output.pdf]"
  exit 1
fi

TPL_FILE="$1"
XML_FILE="$2"
OUT_PDF="${3:-$(dirname "$TPL_FILE")/output_$(date +%s).pdf}"

echo "================================================================================"
echo "⚡ Oracle Analytics Publisher Fast-Render Engine"
echo "   Template: $TPL_FILE"
echo "   Data:     $XML_FILE"
echo "   Output:   $OUT_PDF"
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
       -out "$OUT_PDF"
else
  # 2. Native Headless Conversion
  echo "📄 Running Headless RTF to PDF Processor..."
  TMP_OUT_DIR="$(mktemp -d)"
  libreoffice --headless --convert-to pdf "$TPL_FILE" --outdir "$TMP_OUT_DIR"
  BASE_NAME="$(basename "$TPL_FILE" .rtf)"
  if [ -f "$TMP_OUT_DIR/${BASE_NAME}.pdf" ]; then
    cp "$TMP_OUT_DIR/${BASE_NAME}.pdf" "$OUT_PDF"
    rm -rf "$TMP_OUT_DIR"
  else
    echo "❌ Failed to generate PDF output"
    rm -rf "$TMP_OUT_DIR"
    exit 1
  fi
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
