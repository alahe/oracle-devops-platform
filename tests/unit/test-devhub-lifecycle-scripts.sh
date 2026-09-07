#!/usr/bin/env bash
# ==============================================================================
# Unit Test: Dev-Hub Lifecycle & Blueprints 0-9 Scripts Validation
# (tests/unit/test-devhub-lifecycle-scripts.sh)
# ==============================================================================

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "🔍 Validating Dev-Hub Blueprints 0-9 Lifecycle Testing Scripts..."

# 1. Check file existence and execution permissions
echo "  [1/5] Checking file existence and permissions..."
[ -x "$WORKSPACE_DIR/tests/test-devhub-browser-blueprints.sh" ] || {
  echo "❌ Error: tests/test-devhub-browser-blueprints.sh is missing or not executable" >&2
  exit 1
}

[ -x "$WORKSPACE_DIR/tests/test-devhub-lifecycle-full.sh" ] || {
  echo "❌ Error: tests/test-devhub-lifecycle-full.sh is missing or not executable" >&2
  exit 1
}

# 2. Check CLI --help
echo "  [2/5] Checking CLI --help options..."
"$WORKSPACE_DIR/tests/test-devhub-browser-blueprints.sh" --help | grep -q -- "--lifecycle" || {
  echo "❌ Error: test-devhub-browser-blueprints.sh --help does not mention --lifecycle" >&2
  exit 1
}

"$WORKSPACE_DIR/tests/test-devhub-lifecycle-full.sh" --help | grep -q -- "Fast-Start" || {
  echo "❌ Error: test-devhub-lifecycle-full.sh --help does not mention Fast-Start" >&2
  exit 1
}

# 3. Test Dry-Run simulation for Blueprint #0 and #1
echo "  [3/5] Testing dry-run lifecycle execution on Blueprint #0 and #1..."
"$WORKSPACE_DIR/tests/test-devhub-browser-blueprints.sh" -b 0 --lifecycle --dry-run >/dev/null 2>&1 || {
  echo "❌ Error: test-devhub-browser-blueprints.sh -b 0 --lifecycle --dry-run failed" >&2
  exit 1
}

"$WORKSPACE_DIR/tests/test-devhub-lifecycle-full.sh" -b 1 --dry-run >/dev/null 2>&1 || {
  echo "❌ Error: test-devhub-lifecycle-full.sh -b 1 --dry-run failed" >&2
  exit 1
}

# 4. Verify Metrics and Reports generation
echo "  [4/5] Checking metrics and report generation..."
METRICS_F="$WORKSPACE_DIR/metrics/devhub_lifecycle_full_benchmarks.json"
REPORT_F="$WORKSPACE_DIR/tests/reports/devhub_lifecycle_full_report.md"

[ -f "$METRICS_F" ] || {
  echo "❌ Error: metrics file $METRICS_F was not generated" >&2
  exit 1
}

grep -q '"core_base_protected": true' "$METRICS_F" || {
  echo "❌ Error: metrics does not confirm core_base_protected" >&2
  exit 1
}

[ -f "$REPORT_F" ] || {
  echo "❌ Error: report file $REPORT_F was not generated" >&2
  exit 1
}

# 5. Check Bridge Whitelist integration
echo "  [5/5] Checking Dev-Hub Bridge whitelist integration..."
grep -q '"test-devhub-lifecycle":' "$WORKSPACE_DIR/scripts/internal/dev-hub-bridge.py" || {
  echo "❌ Error: test-devhub-lifecycle not found in dev-hub-bridge.py whitelist" >&2
  exit 1
}

echo "✅ Dev-Hub Blueprints 0-9 Lifecycle Testing scripts validation passed successfully!"
exit 0
