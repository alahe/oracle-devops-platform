#!/usr/bin/env bash
# ==============================================================================
# Oracle DevOps Platform — Publish Golden Snapshot to Enterprise Artifactory
# (scripts/snapshots/publish-snapshot-to-artifactory.sh)
#
# Convenient wrapper to upload current Golden Snapshots to Artifactory catalog.
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

exec "$WORKSPACE_DIR/scripts/publish-to-artifactory.sh" --product blueprints "$@"
