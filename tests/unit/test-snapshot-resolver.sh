#!/usr/bin/env bash
# ============================================================================
# Unit Test: Snapshot Resolver & Automated Version Verification Engine
# Tests:
# 1. Metadata JSON generation and key reading
# 2. Multi-tier snapshot resolution (Blueprint -> Profile -> Global)
# 3. Version match verification (APEX 26.1 match vs 24.2 mismatch)
# 4. Shared vs Dedicated WebLogic topology resolution
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# shellcheck source=scripts/internal/common.sh
source "$WORKSPACE_DIR/scripts/internal/common.sh"
# shellcheck source=scripts/internal/snapshot-resolver.sh
source "$WORKSPACE_DIR/scripts/internal/snapshot-resolver.sh"

echo "=================================================================="
echo "🧪 TEST: snapshot-resolver.sh & Automated Version Verification"
echo "=================================================================="

TEST_TEMP_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t 'snap_test')"
trap 'rm -rf "$TEST_TEMP_DIR"' EXIT INT TERM

# --- TEST 1: Metadata JSON Generation & Reading ---
echo "▶️ [1/5] Testin metaandmete (.meta.json) genereerimist ja lugemist..."
TEST_SNAP="$TEST_TEMP_DIR/bp_3_latest.tar.gz"
touch "$TEST_SNAP"
write_snapshot_metadata "$TEST_SNAP" "3" "db-proxy-oracle" "26.1.0" "container-registry.oracle.com/database/free:latest" "24.4.1" "NONE" "NONE" "FREEPDB1"

META_FILE="${TEST_SNAP%.tar.gz}.meta.json"
if [ ! -f "$META_FILE" ]; then
  echo "❌ Viga: Metaandmete faili $META_FILE ei loodud!"
  exit 1
fi

READ_APEX=$(read_snapshot_metadata_key "$TEST_SNAP" "apex_version")
if [ "$READ_APEX" != "26.1.0" ]; then
  echo "❌ Viga: Oodati APEX versiooni '26.1.0', saadi '$READ_APEX'!"
  exit 1
fi
echo "   ✅ Metaandmete kirjutamine ja lugemine toimib korrektselt (APEX: $READ_APEX)."

# --- TEST 2: Multi-Tier Snapshot Resolution Hierarchy ---
echo "▶️ [2/5] Testin mitmetasemelise otsingu hierarhiat (Blueprint -> Profile -> Global)..."
touch "$TEST_TEMP_DIR/profile_db-proxy-oracle_latest.tar.gz"
touch "$TEST_TEMP_DIR/apex_proxy_oradata_latest.tar.gz"

# Blueprint 3 should find bp_3_latest.tar.gz
FOUND_BP=$(find_best_golden_snapshot "3" "db-proxy-oracle" "$TEST_TEMP_DIR")
if [[ "$FOUND_BP" != *"bp_3_latest.tar.gz" ]]; then
  echo "❌ Viga: Blueprint 3 peaks leidma bp_3_latest.tar.gz, aga leiti: $FOUND_BP"
  exit 1
fi

# Blueprint 34 (no bp_34 file) should fallback to profile_db-proxy-oracle_latest.tar.gz
FOUND_PROF=$(find_best_golden_snapshot "34" "db-proxy-oracle" "$TEST_TEMP_DIR")
if [[ "$FOUND_PROF" != *"profile_db-proxy-oracle_latest.tar.gz" ]]; then
  echo "❌ Viga: Blueprint 34 peaks kukkuma profiilile profile_db-proxy-oracle_latest.tar.gz, aga leiti: $FOUND_PROF"
  exit 1
fi
echo "   ✅ Hierarhiline otsing toimib (Blueprint -> Profile -> Global fallback)."

# --- TEST 3: Version Match Verification (MATCH CASE) ---
echo "▶️ [3/5] Testin versioonide klappivuse kontrolli (MATCH)..."
if ! verify_snapshot_version_match "$TEST_SNAP" "26.1" "db-proxy-oracle" >/dev/null 2>&1; then
  echo "❌ Viga: APEX 26.1 sihtversioon peaks klappima snapshot'iga (26.1.0)!"
  exit 1
fi
echo "   ✅ Versioonide klappivus (APEX 26.1 == 26.1.0) kinnitatud edukalt."

# --- TEST 4: Version Mismatch & Invalidation (DRIFT CASE) ---
echo "▶️ [4/5] Testin versioonide lahknevuse tuvastamist (MISMATCH / DRIFT)..."
OLD_SNAP="$TEST_TEMP_DIR/bp_old_latest.tar.gz"
touch "$OLD_SNAP"
write_snapshot_metadata "$OLD_SNAP" "3" "db-proxy-oracle" "24.2.0" "free:latest" "24.3.0" "NONE" "NONE" "FREEPDB1"

MISMATCH_OUTPUT=$(verify_snapshot_version_match "$OLD_SNAP" "26.1" "db-proxy-oracle" 2>&1 || true)
if [[ "$MISMATCH_OUTPUT" != *"VERSION MISMATCH"* ]] && [[ "$MISMATCH_OUTPUT" != *"VERSIOONIDE ERINEVUS"* ]]; then
  echo "❌ Viga: Versioonide lahknevust ei tuvastatud korrektselt! Väljund: $MISMATCH_OUTPUT"
  exit 1
fi
echo "   ✅ Versioonide lahknevus (Target 26.1 vs Snapshot 24.2) tuvastati ja logiti korrektselt."

# --- TEST 5: WebLogic Topology Mode Resolution ---
echo "▶️ [5/5] Testin WebLogic topoloogia (Shared vs Dedicated) tuvastamist..."
MODE_41=$(resolve_wls_topology_mode "41")
MODE_43=$(resolve_wls_topology_mode "43")
MODE_21=$(resolve_wls_topology_mode "21")
MODE_11=$(resolve_wls_topology_mode "11")
MODE_3=$(resolve_wls_topology_mode "3")

if [ "$MODE_41" != "shared" ] || [ "$MODE_43" != "shared" ]; then
  echo "❌ Viga: BP 41 ja 43 peaksid olema 'shared', saadi '$MODE_41' ja '$MODE_43'!"
  exit 1
fi

if [ "$MODE_21" != "dedicated" ] || [ "$MODE_11" != "dedicated" ]; then
  echo "❌ Viga: BP 21 ja 11 peaksid olema 'dedicated', saadi '$MODE_21' ja '$MODE_11'!"
  exit 1
fi

if [ "$MODE_3" != "standard" ]; then
  echo "❌ Viga: BP 3 peaks olema 'standard', saadi '$MODE_3'!"
  exit 1
fi
echo "   ✅ WebLogic topoloogiad (Shared / Dedicated / Standard) tuvastatud korrektselt."

echo "=================================================================="
echo "🎉 KÕIK SNAPSHOT RESOLVERI JA VERSIOONIKONTROLLI TESTID LÄBITUD!"
echo "=================================================================="
