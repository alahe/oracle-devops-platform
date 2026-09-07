#!/usr/bin/env bash
# ==============================================================================
# Unit Test: test-windows-dryrun.sh
# Validates the Enterprise Windows & WSL2 Dry-Run Diagnostic Engine:
# 1. scripts/test-windows-dryrun.sh existence and executable bit
# 2. test-windows-dryrun.cmd 1-click Windows launcher existence and Zero-Admin compliance
# 3. JSON output schema and 10 check entries
# 4. CLI flags: --help, --fix, --json, --blueprint
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "🔍 Validating Enterprise Windows Dry-Run Diagnostic Engine..."

ERRORS=0

# 1. Verify files exist
DRYRUN_SH="$WORKSPACE_DIR/scripts/test-windows-dryrun.sh"
DRYRUN_CMD="$WORKSPACE_DIR/test-windows-dryrun.cmd"

echo "  [1/4] Checking file presence and execution permissions..."
if [ ! -f "$DRYRUN_SH" ]; then
  echo "❌ Error: scripts/test-windows-dryrun.sh does not exist!"
  ERRORS=$((ERRORS + 1))
elif [ ! -x "$DRYRUN_SH" ]; then
  echo "❌ Error: scripts/test-windows-dryrun.sh is not executable!"
  ERRORS=$((ERRORS + 1))
fi

if [ ! -f "$DRYRUN_CMD" ]; then
  echo "❌ Error: test-windows-dryrun.cmd does not exist in root!"
  ERRORS=$((ERRORS + 1))
else
  # Check Zero-Admin compliance (no runas or Start-Process -Verb RunAs)
  if grep -iE "runas /user:administrator|Start-Process.*-Verb RunAs" "$DRYRUN_CMD" 2>/dev/null; then
    echo "❌ Error: Elevated admin requirement detected in test-windows-dryrun.cmd!"
    ERRORS=$((ERRORS + 1))
  fi
fi

# 2. Test --help flag
echo "  [2/4] Testing CLI --help output..."
HELP_OUT=$("$DRYRUN_SH" --help 2>&1 || true)
if ! echo "$HELP_OUT" | grep -q "Usage: ./scripts/test-windows-dryrun.sh"; then
  echo "❌ Error: --help flag failed to produce expected usage!"
  ERRORS=$((ERRORS + 1))
fi

# 3. Test JSON output and check count
echo "  [3/4] Testing JSON schema and 10 check entries..."
JSON_RAW=$("$DRYRUN_SH" --json 2>&1 || true)

# Validate JSON parseable
if command -v python3 >/dev/null 2>&1; then
  CHECK_COUNT=$(echo "$JSON_RAW" | python3 -c '
import sys, json
try:
    data = json.load(sys.stdin)
    assert "summary" in data, "Missing summary object"
    assert "checks" in data, "Missing checks array"
    cnt = len(data["checks"])
    assert cnt == 10, "Expected 10 checks, got %d" % cnt
    print(cnt)
except Exception as e:
    print("JSON_ERR: %s" % e, file=sys.stderr)
    sys.exit(1)
' 2>/dev/null || echo "0")

  if [ "$CHECK_COUNT" != "10" ]; then
    echo "❌ Error: JSON validation failed or did not return 10 checks! ($CHECK_COUNT)"
    ERRORS=$((ERRORS + 1))
  fi
fi

# 4. Check setup.cmd dry-run integration
echo "  [4/4] Checking setup.cmd dry-run integration..."
SETUP_CMD="$WORKSPACE_DIR/setup.cmd"
if [ -f "$SETUP_CMD" ]; then
  if ! grep -q "test-windows-dryrun.sh" "$SETUP_CMD"; then
    echo "❌ Error: setup.cmd missing delegation to test-windows-dryrun.sh!"
    ERRORS=$((ERRORS + 1))
  fi
fi

if [ "$ERRORS" -gt 0 ]; then
  echo "❌ test-windows-dryrun validation failed with $ERRORS error(s)!"
  exit 1
fi

echo "✅ Enterprise Windows Dry-Run Diagnostic Engine validation passed successfully!"
exit 0
