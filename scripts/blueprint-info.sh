#!/usr/bin/env bash
# ============================================================================
# Oracle DevOps Platform — Blueprint Introspection & Architecture Explainer CLI
# (scripts/blueprint-info.sh)
#
# User CLI wrapper delegating to scripts/internal/blueprint-info.sh (Rule 3)
# Usage:
#   ./scripts/blueprint-info.sh [blueprint_number|all]
#   ./scripts/blueprint-info.sh --list
#   ./scripts/blueprint-info.sh --summary
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/internal/blueprint-info.sh" "$@"
