#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

bash -n "$WORKSPACE_DIR/scripts/forms/deploy-forms-apps.sh"
echo "✅ Forms deploy apps script syntax OK!"
