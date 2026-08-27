#!/usr/bin/env bash
# ============================================================================
# Unit Test: test-multi-db-seps-wallet.sh
# Purpose: Verifies Multi-DB SEPS Wallet, TNS aliasing, and get-password scripts
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Test 1: Bash syntax checks
bash -n "$WORKSPACE_DIR/scripts/internal/create-wallet.sh"
bash -n "$WORKSPACE_DIR/scripts/sqlcl.sh"
bash -n "$WORKSPACE_DIR/scripts/get-password.sh"
bash -n "$WORKSPACE_DIR/scripts/check-wallet.sh"

# Test 2: Verify sqlcl.sh contains wallet_location in JAVA_TOOL_OPTIONS
if ! grep -q "oracle.net.wallet_location" "$WORKSPACE_DIR/scripts/sqlcl.sh"; then
  echo "FAIL: sqlcl.sh missing -Doracle.net.wallet_location"
  exit 1
fi

# Test 3: Verify check-wallet.sh contains wallet_location in JAVA_TOOL_OPTIONS
if ! grep -q "oracle.net.wallet_location" "$WORKSPACE_DIR/scripts/check-wallet.sh"; then
  echo "FAIL: check-wallet.sh missing -Doracle.net.wallet_location"
  exit 1
fi

# Test 4: Verify create-wallet.sh generates canonical container aliases (DB_${pfx}_SYS)
if ! grep -q 'pfx="$UPPER_NAME"' "$WORKSPACE_DIR/scripts/internal/create-wallet.sh"; then
  echo "FAIL: create-wallet.sh missing canonical container alias resolution"
  exit 1
fi

# Test 5: Verify get-password.sh handles container prefix parsing
if ! grep -q 'PRIMARY_SHORT=' "$WORKSPACE_DIR/scripts/get-password.sh"; then
  echo "FAIL: get-password.sh missing PRIMARY_SHORT resolution"
  exit 1
fi

echo "test-multi-db-seps-wallet: PASS"
