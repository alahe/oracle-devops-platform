#!/usr/bin/env bash
# ============================================================================
# Wrapper script to execute internal connection registration for VS Code
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
exec "$SCRIPT_DIR/internal/register-connections.sh" "$@"
