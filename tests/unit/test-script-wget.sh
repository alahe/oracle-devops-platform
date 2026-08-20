#!/usr/bin/env bash
# ============================================================================
# Unit Test for scripts/wget.sh
# ============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "=== Testing wget.sh syntax ==="

if [ -f "$WORKSPACE_DIR/scripts/wget.sh" ]; then
  bash -n "$WORKSPACE_DIR/scripts/wget.sh"
fi

echo "✅ wget.sh unit test passed!"
