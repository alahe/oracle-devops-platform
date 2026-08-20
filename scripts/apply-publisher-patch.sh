#!/usr/bin/env bash
# ============================================================================
# User Entry Point: Oracle Analytics Publisher Automated Patching
# Delegates execution to scripts/internal/apply-publisher-patch.sh per workspace rules
# ============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/internal/apply-publisher-patch.sh" "$@"
