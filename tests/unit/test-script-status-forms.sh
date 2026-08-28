#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

bash -n "$WORKSPACE_DIR/scripts/forms/status-forms.sh"
bash -n "$WORKSPACE_DIR/scripts/forms/restart-forms.sh"
bash -n "$WORKSPACE_DIR/scripts/internal/test-forms-service.sh"
bash -n "$WORKSPACE_DIR/scripts/internal/install-forms.sh"
bash -n "$WORKSPACE_DIR/scripts/internal/init-forms-rcu.sh"

echo "✅ Forms status & lifecycle scripts syntax OK!"
