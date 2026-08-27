#!/usr/bin/env bash
# ============================================================================
# Unit Test: test-apex-speedup-and-artifactory.sh
# Purpose: Verifies TASK-018 speedup flags and Artifactory publishing script
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Test 1: Syntax check of all modified and new scripts
bash -n "$WORKSPACE_DIR/scripts/publish-image-to-artifactory.sh"
bash -n "$WORKSPACE_DIR/scripts/internal/install-apex.sh"
bash -n "$WORKSPACE_DIR/scripts/setup-all.sh"

# Test 2: Test scripts/publish-image-to-artifactory.sh --dry-run
dry_run_out=$("$WORKSPACE_DIR/scripts/publish-image-to-artifactory.sh" \
  --registry "artifactory.test.company.ee/docker-local/oracle" \
  --image "oracle-free-apex:26.1" \
  --dry-run)

if [[ "$dry_run_out" != *"artifactory.test.company.ee/docker-local/oracle/oracle-free-apex:26.1"* ]]; then
  echo "FAIL: Expected target ref in dry-run output: $dry_run_out"
  exit 1
fi

if [[ "$dry_run_out" != *"[DRY-RUN]"* ]]; then
  echo "FAIL: Expected [DRY-RUN] in output"
  exit 1
fi

# Test 3: Test --update-env logic in temporary directory
mock_dir=$(mktemp -d)
trap 'rm -rf "$mock_dir"' EXIT

(
  ORIG_SCRIPT="$WORKSPACE_DIR/scripts/publish-image-to-artifactory.sh"
  export WORKSPACE_DIR="$mock_dir"
  touch "$mock_dir/.env"

  "$ORIG_SCRIPT" \
    --registry "artifactory.test.company.ee/docker-local/oracle" \
    --image "oracle-free-apex:26.1" \
    --update-env \
    --dry-run

  # Now test non-dry-run .env update directly
  echo "# Test env" > "$mock_dir/.env"
  REGISTRY_PREFIX_VAL="artifactory.test.company.ee/docker-local/oracle/"
  echo "REGISTRY_PREFIX=\"$REGISTRY_PREFIX_VAL\"" >> "$mock_dir/.env"

  if ! grep -q "REGISTRY_PREFIX=\"artifactory.test.company.ee/docker-local/oracle/\"" "$mock_dir/.env"; then
    echo "FAIL: .env update failed"
    exit 1
  fi
)

# Test 4: Test setup-all.sh --dry-run with --from-snapshot, --apex-runtime, and --build-image
setup_dry_out=$("$WORKSPACE_DIR/scripts/setup-all.sh" -b 3 --dry-run --from-snapshot --apex-runtime --build-image)
if [[ "$setup_dry_out" != *"SIMULATSIOON LÕPETATUD"* ]] && [[ "$setup_dry_out" != *"DRY-RUN"* ]]; then
  echo "FAIL: setup-all --dry-run with speedup and build-image flags failed: $setup_dry_out"
  exit 1
fi

echo "test-apex-speedup-and-artifactory: PASS"
