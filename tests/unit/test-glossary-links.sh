#!/usr/bin/env bash
# ==============================================================================
# Unit Test: test-glossary-links.sh
# Safely audits all 57 external glossary links (Wikipedia, Oracle documentation)
# with zero-download in-memory HTTP HEAD requests (Rule 14 & Rule 13).
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "🌐 Running Architecture Glossary Web Links Zero-Download Audit..."

# Determine virtual null device for logging and compliance
NULL_DEVICE="/dev/null"
if [[ "${OSTYPE:-}" == "msys"* || "${OSTYPE:-}" == "cygwin"* || "${OSTYPE:-}" == "win"* || -n "${WINDIR:-}" ]]; then
  NULL_DEVICE="NUL"
fi

echo "  ℹ️ Security model: Zero-payload HTTP HEAD (in-memory only)"
echo "  ℹ️ OS target null device: $NULL_DEVICE"

PYTHON_BIN="python3"
if ! command -v python3 &>/dev/null && command -v python &>/dev/null; then
  PYTHON_BIN="python"
fi

# Execute universal Python auditor
exec "$PYTHON_BIN" "$WORKSPACE_DIR/scripts/internal/check-glossary-links.py" "$@"
