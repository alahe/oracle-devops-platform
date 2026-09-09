#!/usr/bin/env bash
# ==============================================================================
# Oracle Analytics Publisher — PDF Accessibility (PDF/UA-1 & WCAG AA) Validator
# Performs structural and screen reader verification on generated PDF files.
# Usage: ./scripts/publisher/validate-pdf-accessibility.sh <output.pdf> [--strict] [--json]
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

PDF_FILE="${1:-$WORKSPACE_DIR/templates/publisher/samples/valmis_arve.pdf}"
shift || true
EXTRA_FLAGS="$*"

if [ ! -f "$PDF_FILE" ]; then
  echo "❌ Error: PDF file not found: $PDF_FILE"
  echo "Usage: $0 <path_to_file.pdf> [--strict] [--json]"
  exit 1
fi

VALIDATOR="$WORKSPACE_DIR/docker/publisher-designer/pdf-a11y-validator.py"

if command -v python3 >/dev/null 2>&1; then
  python3 "$VALIDATOR" "$PDF_FILE" $EXTRA_FLAGS
else
  podman exec app-publisher-designer python3 /u01/oracle/bin/pdf-a11y-validator.py "$PDF_FILE" $EXTRA_FLAGS
fi
