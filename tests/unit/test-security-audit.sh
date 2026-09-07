#!/usr/bin/env bash
# ==============================================================================
# Unit Test: Enterprise Security Audit Automation
# Verifies test-security-audit.sh execution, benchmark logging, and zero critical fails
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "=================================================================="
echo "🧪 Running Unit Test: test-security-audit.sh Verification"
echo "=================================================================="

AUDIT_SCRIPT="$WORKSPACE_DIR/scripts/test-security-audit.sh"
test -f "$AUDIT_SCRIPT"
test -x "$AUDIT_SCRIPT"

# 1. Execute audit script
echo "🔍 [1/3] Executing security audit script..."
"$AUDIT_SCRIPT"

# 2. Verify benchmarks generation (Rule 1)
echo "🔍 [2/3] Verifying benchmark outputs..."
BENCHMARK_JSON="$WORKSPACE_DIR/metrics/security_audit_report.json"
BENCHMARK_ENV="$WORKSPACE_DIR/metrics/security_audit_benchmarks.env"

test -f "$BENCHMARK_JSON"
test -f "$BENCHMARK_ENV"

# Verify JSON parsing and non-zero checks
python3 -c "
import json
with open('$BENCHMARK_JSON') as f:
    d = json.load(f)
assert d['total_checks'] > 10, 'Expected > 10 total checks'
assert d['failed'] == 0, f'Expected 0 failed checks, got {d[\"failed\"]}'
assert d['security_score_percent'] >= 90, f'Expected score >= 90%, got {d[\"security_score_percent\"]}%'
print(f'   ✅ Benchmark verification passed: {d[\"passed\"]}/{d[\"total_checks\"]} checks passed ({d[\"security_score_percent\"]}%)')
"

# 3. Check logs presence (Rule 1)
echo "🔍 [3/3] Verifying log file creation..."
LATEST_LOG=$(ls -t "$WORKSPACE_DIR"/install_logs/security_audit_*.log 2>/dev/null | head -n 1)
test -n "$LATEST_LOG"
test -f "$LATEST_LOG"
echo "   ✅ Audit log verified: $LATEST_LOG"

echo "=================================================================="
echo "✅ ALL SECURITY AUDIT UNIT TESTS PASSED!"
echo "=================================================================="
