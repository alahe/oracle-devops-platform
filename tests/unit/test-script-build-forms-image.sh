#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

bash -n "$WORKSPACE_DIR/docker/forms/build-forms-image.sh"
echo "✅ Forms build image script syntax OK!"
