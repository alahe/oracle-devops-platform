#!/usr/bin/env bash
# ==============================================================================
# Oracle Analytics Publisher — RTF Template Accessibility Linter CLI
# Scans .rtf templates for PDF/UA-1, Section 508, and WCAG 2.1 AA compliance.
# Runs locally or via in-container Python linter.
# Usage: ./scripts/publisher/validate-rtf-accessibility.sh <template.rtf> [--strict]
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

RTF_FILE="${1:-$WORKSPACE_DIR/templates/publisher/samples/accessible_starter_template.rtf}"
STRICT_FLAG="${2:-}"

if [ ! -f "$RTF_FILE" ]; then
  echo "❌ Error: Template file not found: $RTF_FILE"
  echo "Usage: $0 <path_to_template.rtf> [--strict]"
  exit 1
fi

LINTER="$WORKSPACE_DIR/docker/publisher-designer/rtf-a11y-linter.py"

if command -v python3 >/dev/null 2>&1; then
  python3 "$LINTER" "$RTF_FILE" $STRICT_FLAG
else
  # Fallback to execution inside container
  podman exec app-publisher-designer python3 /u01/oracle/bin/rtf-a11y-linter.py "$RTF_FILE" $STRICT_FLAG
fi
