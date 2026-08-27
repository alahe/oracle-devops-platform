#!/usr/bin/env bash
# ============================================================================
# Unit Test: test-cli-blueprint-params.sh
# Purpose: Verifies blueprint CLI parameters (-lb, -sb, -search, --dry-run, -ltr)
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Test 1: --list-blueprints / -lb produces table output
out_list=$("$WORKSPACE_DIR/scripts/setup-all.sh" -lb 2>&1)
if [[ "$out_list" != *"AMETLIKUD ARHITEKTUURSED KAVANDID"* ]]; then
  echo "FAIL: Expected blueprints header in -lb output"
  exit 1
fi
if [[ "$out_list" != *".env.3-db-lis-apex-ords-with-proxy"* ]]; then
  echo "FAIL: Expected Blueprint 3 in -lb table"
  exit 1
fi

# Test 2: --show-blueprint 3 / -sb 3 displays breakdown
out_show=$("$WORKSPACE_DIR/scripts/setup-all.sh" -sb 3 2>&1)
if [[ "$out_show" != *"DETAILNE BLUEPRINTI ÜLEVAADE"* ]]; then
  echo "FAIL: Expected detailed header in -sb 3 output"
  exit 1
fi
if [[ "$out_show" != *"db-proxy"* ]] || [[ "$out_show" != *"db-lis"* ]] || [[ "$out_show" != *"app-ords"* ]]; then
  echo "FAIL: Expected containers (db-proxy, db-lis, app-ords) in -sb 3 output"
  exit 1
fi

# Test 3: --search publisher filters table
out_search=$("$WORKSPACE_DIR/scripts/setup-all.sh" --search publisher 2>&1)
if [[ "$out_search" != *".env.4-only-app-publisher"* ]]; then
  echo "FAIL: Expected Blueprint 4 in publisher search output"
  exit 1
fi

# Test 4: -b 3 --dry-run produces simulation output
out_dry=$("$WORKSPACE_DIR/scripts/setup-all.sh" -b 3 --dry-run 2>&1)
if [[ "$out_dry" != *"DRY-RUN EDUKAS"* ]]; then
  echo "FAIL: Expected DRY-RUN EDUKAS in -b 3 --dry-run"
  exit 1
fi

# Test 5: -tb 1,3 --dry-run produces test simulation
out_tb_dry=$("$WORKSPACE_DIR/scripts/setup-all.sh" -tb 1,3 --dry-run 2>&1)
if [[ "$out_tb_dry" != *"BLUEPRINT 1 SIMULATSIOON"* ]] || [[ "$out_tb_dry" != *"BLUEPRINT 3 SIMULATSIOON"* ]]; then
  echo "FAIL: Expected BP 1 and BP 3 simulations in -tb 1,3 --dry-run"
  exit 1
fi

# Test 6: -ltr displays test reports
out_ltr=$("$WORKSPACE_DIR/scripts/setup-all.sh" -ltr 2>&1)
if [[ "$out_ltr" != *"BLUEPRINTIDE TESTIARUANNETE OLEK"* ]]; then
  echo "FAIL: Expected reports table in -ltr"
  exit 1
fi

echo "test-cli-blueprint-params: PASS"
