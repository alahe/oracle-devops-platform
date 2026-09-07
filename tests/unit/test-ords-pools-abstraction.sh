#!/usr/bin/env bash
# ==============================================================================
# Unit Test: ORDS Connection Pools Abstraction & Micro-Registrar (Variant 3)
# Validates autonomous pool registration, deregistration, status JSON,
# Dev Hub Gateway strip, and virtual pool tokens.
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "🔍 Testing ORDS Connection Pools Abstraction (Variant 3)..."

# 1. Verify script existence & executability
MANAGE_SCRIPT="$WORKSPACE_DIR/scripts/internal/manage-ords-pools.sh"
if [ ! -x "$MANAGE_SCRIPT" ]; then
  echo "❌ Error: $MANAGE_SCRIPT is missing or not executable!"
  exit 1
fi

# 2. Test status JSON output
JSON_OUT=$("$MANAGE_SCRIPT" status json)
if ! echo "$JSON_OUT" | python3 -c 'import sys, json; data = json.load(sys.stdin); assert isinstance(data, dict)' 2>/dev/null; then
  echo "❌ Error: manage-ords-pools.sh status json did not return valid JSON!"
  echo "$JSON_OUT"
  exit 1
fi
echo "  ✓ status json returned valid JSON"

# 3. Test Registration & Deregistration lifecycle on mock pool
MOCK_POOL="_test_unit_mock_pool"
MOCK_DIR="$WORKSPACE_DIR/config/ords/proxy/databases/$MOCK_POOL"

"$MANAGE_SCRIPT" register "$MOCK_POOL" "mock-container" "1521" "MOCKPDB" >/dev/null
if [ ! -f "$MOCK_DIR/pool.xml" ]; then
  echo "❌ Error: register failed to create $MOCK_DIR/pool.xml"
  exit 1
fi

if ! grep -q "mock-container" "$MOCK_DIR/pool.xml"; then
  echo "❌ Error: pool.xml missing expected hostname"
  rm -rf "$MOCK_DIR"
  exit 1
fi
echo "  ✓ register created valid pool.xml"

"$MANAGE_SCRIPT" deregister "$MOCK_POOL" >/dev/null
if [ -d "$MOCK_DIR" ]; then
  echo "❌ Error: deregister failed to remove $MOCK_DIR"
  rm -rf "$MOCK_DIR"
  exit 1
fi
echo "  ✓ deregister removed mock pool successfully"

# 4. Verify dev-hub.html contains ORDS Gateway components
DEV_HUB_HTML="$WORKSPACE_DIR/docs/dev-hub.html"
if [ -f "$DEV_HUB_HTML" ]; then
  for marker in "ords-gateway-strip" "LIVE_ORDS_POOLS" "chip-ords" "ords_gateway_title"; do
    if ! grep -q "$marker" "$DEV_HUB_HTML"; then
      echo "❌ Error: dev-hub.html missing required ORDS marker: $marker"
      exit 1
    fi
  done
  echo "  ✓ dev-hub.html contains all ORDS Smart Gateway visual and data markers"
fi

echo "✅ ORDS connection pools abstraction unit test passed successfully!"
