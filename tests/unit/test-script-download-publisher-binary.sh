#!/usr/bin/env bash
# ============================================================================
# Unit Test for scripts/internal/download-publisher-binary.sh
# ============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "=== Testing download-publisher-binary.sh syntax & fallback execution ==="

# Syntax check
bash -n "$WORKSPACE_DIR/scripts/internal/download-publisher-binary.sh"

# Execution test (dry run fallback notice)
"$WORKSPACE_DIR/scripts/internal/download-publisher-binary.sh"

echo "✅ download-publisher-binary.sh unit test passed!"
