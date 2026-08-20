#!/usr/bin/env bash
# ============================================================================
# User Entry Point: Oracle Analytics Publisher Installation
# Delegates execution to scripts/internal/install-publisher.sh per workspace rules
# ============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/internal/install-publisher.sh" "$@"
