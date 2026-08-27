#!/usr/bin/env bash
# ============================================================================
# Unit Test: test-resolve-tls-mode.sh
# Purpose: Verifies scripts/internal/resolve-tls-mode.sh hierarchical detection
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$WORKSPACE_DIR/scripts/internal/resolve-tls-mode.sh"

# Test 1: Permissive defaults to USER_LOCAL_CA
TLS_ALLOWED_LEVEL="permissive"
USE_PUBLIC_CA_CERTS="false"
CORP_PKI_ENABLED="false"
resolve_tls_mode >/dev/null 2>&1
if [ "$RESOLVED_TLS_MODE" != "USER_LOCAL_CA" ]; then
  echo "FAIL: Expected USER_LOCAL_CA, got $RESOLVED_TLS_MODE"
  exit 1
fi

# Test 2: Custom cert drop-in
mkdir -p "$WORKSPACE_DIR/config/certs/custom"
touch "$WORKSPACE_DIR/config/certs/custom/tls.crt"
touch "$WORKSPACE_DIR/config/certs/custom/tls.key"
resolve_tls_mode >/dev/null 2>&1
res_mode="$RESOLVED_TLS_MODE"
rm -f "$WORKSPACE_DIR/config/certs/custom/tls.crt" "$WORKSPACE_DIR/config/certs/custom/tls.key"

if [ "$res_mode" != "CUSTOM_CERT" ]; then
  echo "FAIL: Expected CUSTOM_CERT, got $res_mode"
  exit 1
fi

echo "test-resolve-tls-mode: PASS"
