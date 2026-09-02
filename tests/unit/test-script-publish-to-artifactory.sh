#!/usr/bin/env bash
# ============================================================================
# Unit Test: publish-to-artifactory.sh
# ============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "🧪 TEST: publish-to-artifactory.sh"
if [ ! -f "$WORKSPACE_DIR/scripts/publish-to-artifactory.sh" ]; then
  echo "❌ Error: scripts/publish-to-artifactory.sh not found!"
  exit 1
fi

bash -n "$WORKSPACE_DIR/scripts/publish-to-artifactory.sh"
"$WORKSPACE_DIR/scripts/publish-to-artifactory.sh" --help >/dev/null

echo "✅ Test Edukas: publish-to-artifactory.sh on olemas ja BASH süntaks on korras!"
