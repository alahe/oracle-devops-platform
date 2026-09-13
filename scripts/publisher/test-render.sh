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
  
  # Resolve Template in container
  if [[ "$TPL" == "$WORKSPACE_DIR/templates/publisher/"* ]]; then
    CONTAINER_TPL="/u01/templates/${TPL#$WORKSPACE_DIR/templates/publisher/}"
  else
    CONTAINER_TPL="/tmp/input_template_$$.rtf"
    podman cp "$TPL" "app-publisher-designer:${CONTAINER_TPL}"
  fi

  # Resolve Data in container
  if [[ "$DATA" == "$WORKSPACE_DIR/templates/publisher/"* ]]; then
    CONTAINER_DATA="/u01/templates/${DATA#$WORKSPACE_DIR/templates/publisher/}"
  else
    CONTAINER_DATA="/tmp/input_data_$$.xml"
    podman cp "$DATA" "app-publisher-designer:${CONTAINER_DATA}"
  fi

  # Resolve Output in container
  NEED_CP_BACK=false
  if [[ "$OUT" == "$WORKSPACE_DIR/templates/publisher/"* ]]; then
    CONTAINER_OUT="/u01/templates/${OUT#$WORKSPACE_DIR/templates/publisher/}"
  else
    CONTAINER_OUT="/tmp/output_render_$$.pdf"
    NEED_CP_BACK=true
  fi

  podman exec -i app-publisher-designer /u01/oracle/bin/render-template.sh \
    "$CONTAINER_TPL" \
    "$CONTAINER_DATA" \
    "$CONTAINER_OUT" \
    --locale "$LOCALE"

  if [ "$NEED_CP_BACK" = true ]; then
    REAL_OUT="$(python3 -c 'import os, sys; print(os.path.realpath(sys.argv[1]))' "$OUT")"
    podman cp "app-publisher-designer:${CONTAINER_OUT}" "$REAL_OUT"
    podman exec -i app-publisher-designer rm -f "$CONTAINER_OUT" "${CONTAINER_TPL}" "${CONTAINER_DATA}" 2>/dev/null || true
  fi
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
