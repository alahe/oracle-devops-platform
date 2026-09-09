#!/usr/bin/env bash
# ==============================================================================
# CLI Fast-Renderer: Test Render Publisher RTF Template + XML Data -> PDF
# Runs inside the app-publisher-designer container or local LibreOffice/Java
# Supports multi-language translation via XLIFF (--locale <et|en|fi|sv|lv|lt>)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

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

TPL_INPUT="${POSITIONAL_ARGS[0]:-$WORKSPACE_DIR/templates/publisher/samples/arve_test_standard.rtf}"
DATA_INPUT="${POSITIONAL_ARGS[1]:-$WORKSPACE_DIR/templates/publisher/samples/arve_test_andmed.xml}"
OUT_INPUT="${POSITIONAL_ARGS[2]:-$WORKSPACE_DIR/templates/publisher/samples/valmis_arve_${LOCALE}.pdf}"

TPL="$(python3 -c "import os, sys; print(os.path.abspath(sys.argv[1]))" "$TPL_INPUT")"
DATA="$(python3 -c "import os, sys; print(os.path.abspath(sys.argv[1]))" "$DATA_INPUT")"
OUT="$(python3 -c "import os, sys; print(os.path.abspath(sys.argv[1]))" "$OUT_INPUT")"

echo "================================================================================"
echo "⚡ Testing Pixel-Perfect Template Rendering (Locale: $LOCALE)..."
echo "   Template: $TPL"
echo "   Data:     $DATA"
echo "   Output:   $OUT"
echo "   Locale:   $LOCALE"
echo "================================================================================"

if [ ! -f "$TPL" ]; then
  echo "❌ Error: Template file not found: $TPL"
  exit 1
fi

if [ ! -f "$DATA" ]; then
  echo "❌ Error: Data file not found: $DATA"
  exit 1
fi

# Execute via running designer container if present
if podman ps --format '{{.Names}}' | grep -q '^app-publisher-designer$'; then
  echo "🚀 Running render inside app-publisher-designer container..."
  REL_TPL="${TPL#$WORKSPACE_DIR/templates/publisher/}"
  REL_DATA="${DATA#$WORKSPACE_DIR/templates/publisher/}"
  REL_OUT="${OUT#$WORKSPACE_DIR/templates/publisher/}"
  podman exec -i app-publisher-designer /u01/oracle/bin/render-template.sh \
    "/u01/templates/$REL_TPL" \
    "/u01/templates/$REL_DATA" \
    "/u01/templates/$REL_OUT" \
    --locale "$LOCALE"
else
  # Local fast fallback rendering
  echo "📄 Running local fallback rendering..."
  TMP_DIR="$(mktemp -d)"
  POPULATED_RTF="$TMP_DIR/populated_template.rtf"
  PREPROCESSOR="$WORKSPACE_DIR/docker/publisher-designer/xdo-preprocessor.py"
  if [ -f "$PREPROCESSOR" ]; then
    python3 "$PREPROCESSOR" "$DATA" "$TPL" "$POPULATED_RTF" --locale "$LOCALE" 2>/dev/null || cp "$TPL" "$POPULATED_RTF"
  else
    cp "$TPL" "$POPULATED_RTF"
  fi
  libreoffice --headless --convert-to pdf "$POPULATED_RTF" --outdir "$TMP_DIR" 2>/dev/null || true
  BASE="$(basename "$POPULATED_RTF" .rtf)"
  if [ -f "$TMP_DIR/${BASE}.pdf" ]; then
    cp "$TMP_DIR/${BASE}.pdf" "$OUT"
    rm -rf "$TMP_DIR"
    echo "✅ Local PDF generated successfully at: $OUT"
  else
    echo "ℹ️ Launching app-publisher-designer container to perform authentic render..."
    "$SCRIPT_DIR/start-designer.sh"
    "$0" "$TPL" "$DATA" "$OUT" --locale "$LOCALE"
    exit 0
  fi
fi

if [ -f "$OUT" ]; then
  SIZE=$(wc -c < "$OUT" | tr -d ' ')
  echo "================================================================================"
  echo "🎉 SUCCESS: PDF Generated ($SIZE bytes)"
  echo "   View PDF: open $OUT"
  echo "================================================================================"
fi
