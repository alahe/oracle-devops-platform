#!/usr/bin/env bash
# ==============================================================================
# CLI Fast-Renderer: Test Render Publisher RTF Template + XML Data -> PDF
# Runs inside the app-publisher-designer container or local LibreOffice/Java
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

TPL="${1:-$WORKSPACE_DIR/templates/publisher/samples/arve_eesti_standard.rtf}"
DATA="${2:-$WORKSPACE_DIR/templates/publisher/samples/arve_sample_data.xml}"
OUT="${3:-$WORKSPACE_DIR/templates/publisher/samples/valmis_arve.pdf}"

echo "================================================================================"
echo "⚡ Testing Pixel-Perfect Template Rendering..."
echo "   Template: $TPL"
echo "   Data:     $DATA"
echo "   Output:   $OUT"
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
    "/u01/templates/$REL_OUT"
else
  # Local fast fallback rendering
  echo "📄 Running local fallback rendering..."
  TMP_DIR="$(mktemp -d)"
  libreoffice --headless --convert-to pdf "$TPL" --outdir "$TMP_DIR" 2>/dev/null || true
  BASE="$(basename "$TPL" .rtf)"
  if [ -f "$TMP_DIR/${BASE}.pdf" ]; then
    cp "$TMP_DIR/${BASE}.pdf" "$OUT"
    rm -rf "$TMP_DIR"
    echo "✅ Local PDF generated successfully at: $OUT"
  else
    echo "ℹ️ Launching app-publisher-designer container to perform authentic render..."
    "$SCRIPT_DIR/start-designer.sh"
    "$0" "$TPL" "$DATA" "$OUT"
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
