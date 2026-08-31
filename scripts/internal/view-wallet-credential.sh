#!/usr/bin/env bash
# Backward compatibility wrapper for get-password.sh (Rule 3.4 & Rule 5.1)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
exec "$SCRIPT_DIR/../get-password.sh" "$@"
