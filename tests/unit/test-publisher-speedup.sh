#!/usr/bin/env bash
# ============================================================================
# Unit Test: test-publisher-speedup.sh
# Purpose: Verifies TASK-019 Publisher speedup, prebuilt domain builder, and flags
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Test 1: Syntax checks
bash -n "$WORKSPACE_DIR/scripts/internal/install-publisher.sh"
bash -n "$WORKSPACE_DIR/docker/publisher/build-publisher-prebuilt-image.sh"
bash -n "$WORKSPACE_DIR/scripts/setup-all.sh"

# Test 2: Test build-publisher-prebuilt-image.sh --help
help_out=$("$WORKSPACE_DIR/docker/publisher/build-publisher-prebuilt-image.sh" --help)
if [[ "$help_out" != *"Publisher Domeenipildi Ehitaja"* ]]; then
  echo "FAIL: build-publisher-prebuilt-image.sh --help output unexpected: $help_out"
  exit 1
fi

# Test 3: Test setup-all.sh --dry-run with --parallel and --sequential flags
par_dry_out=$("$WORKSPACE_DIR/scripts/setup-all.sh" -b 7 --dry-run --parallel)
if [[ "$par_dry_out" != *"SIMULATSIOON LÕPETATUD"* ]] && [[ "$par_dry_out" != *"DRY-RUN"* ]]; then
  echo "FAIL: setup-all --dry-run --parallel failed: $par_dry_out"
  exit 1
fi

seq_dry_out=$("$WORKSPACE_DIR/scripts/setup-all.sh" -b 7 --dry-run --sequential)
if [[ "$seq_dry_out" != *"SIMULATSIOON LÕPETATUD"* ]] && [[ "$seq_dry_out" != *"DRY-RUN"* ]]; then
  echo "FAIL: setup-all --dry-run --sequential failed: $seq_dry_out"
  exit 1
fi

echo "test-publisher-speedup: PASS"
