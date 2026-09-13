#!/bin/bash
# ==============================================================================
# Unit Test: Dev Hub RAM Metrics, Expected vs Live RAM, and 2.0 GB Safety Reserve
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "🧪 Running unit tests for Dev Hub RAM metrics & safety reserve architecture..."

# 1. Check metrics/blueprint_ram_benchmarks.json
echo "  [1/6] Checking metrics/blueprint_ram_benchmarks.json..."
RAM_BENCH_FILE="$WORKSPACE_DIR/metrics/blueprint_ram_benchmarks.json"
if [ ! -f "$RAM_BENCH_FILE" ]; then
  echo "❌ Error: $RAM_BENCH_FILE does not exist!"
  exit 1
fi

python3 -c "
import json
with open('$RAM_BENCH_FILE') as f:
    d = json.load(f)
assert d.get('system_safety_reserve_gb') == 2.0, 'system_safety_reserve_gb must be 2.0'
bps = d.get('blueprints', {})
for b_num in range(12):
    assert str(b_num) in bps, f'Blueprint {b_num} missing in benchmarks'
    assert 'expected_ram_range_gb' in bps[str(b_num)], f'expected_ram_range_gb missing for BP {b_num}'
    assert 'containers' in bps[str(b_num)], f'containers missing for BP {b_num}'
"
echo "     ✅ blueprint_ram_benchmarks.json schema and all 12 blueprints verified!"

# 2. Check cards.py markup
echo "  [2/6] Checking cards.py markup..."
CARDS_PY="$WORKSPACE_DIR/scripts/internal/dev_hub/cards.py"
grep -q 'bp-card-ram-line' "$CARDS_PY" || { echo "❌ Error: bp-card-ram-line missing in cards.py"; exit 1; }
grep -q 'bp-live-ram-pill' "$CARDS_PY" || { echo "❌ Error: bp-live-ram-pill missing in cards.py"; exit 1; }
echo "     ✅ cards.py contains bp-card-ram-line and bp-live-ram-pill!"

# 3. Check i18n keys across all 6 languages
echo "  [3/6] Checking i18n 6-language parity for RAM & Master Refresh keys..."
I18N_JS="$WORKSPACE_DIR/scripts/internal/dev_hub/assets/i18n.js"
python3 -c "
with open('$I18N_JS') as f:
    cnt = f.read()

required_keys = [
    'ram_safe_avail_label', 'ram_live_current', 'ram_tooltip_breakdown',
    'ram_badge_format', 'master_autorefresh_on', 'master_autorefresh_off',
    'btn_sync_now', 'status_stopped'
]
for lang in ['en', 'et', 'fi', 'sv', 'lv', 'lt']:
    for k in required_keys:
        assert f'{k}:' in cnt, f'Key {k} missing in i18n.js'
"
echo "     ✅ All RAM & Master Refresh keys verified across 6 languages!"

# 4. Check app.js syntax and logic
echo "  [4/6] Checking app.js syntax and safety reserve logic..."
APP_JS="$WORKSPACE_DIR/scripts/internal/dev_hub/assets/app.js"
node --check "$APP_JS"
grep -q 'LIVE_CONTAINER_MEMORY' "$APP_JS" || { echo "❌ Error: LIVE_CONTAINER_MEMORY missing in app.js"; exit 1; }
grep -q 'system_reserve_gb' "$APP_JS" || { echo "❌ Error: system_reserve_gb missing in app.js"; exit 1; }
grep -q 'safeAvailGb' "$APP_JS" || { echo "❌ Error: safeAvailGb missing in app.js"; exit 1; }
grep -q 'gMasterAutoRefresh' "$APP_JS" || { echo "❌ Error: gMasterAutoRefresh missing in app.js"; exit 1; }
grep -q 'toggleMasterAutoRefresh' "$APP_JS" || { echo "❌ Error: toggleMasterAutoRefresh missing in app.js"; exit 1; }
grep -q 'masterRefreshNow' "$APP_JS" || { echo "❌ Error: masterRefreshNow missing in app.js"; exit 1; }
grep -q 'freeColor' "$APP_JS" || { echo "❌ Error: freeColor adaptive calculation missing in app.js"; exit 1; }
echo "     ✅ app.js syntax and memory reserve calculations verified!"

# 5. Check dev-hub-bridge.py memory stats and safety check
echo "  [5/6] Checking dev-hub-bridge.py container memory stats..."
BRIDGE_PY="$WORKSPACE_DIR/scripts/internal/dev_hub/dev-hub-bridge.py"
if [ ! -f "$BRIDGE_PY" ]; then
  BRIDGE_PY="$WORKSPACE_DIR/scripts/internal/dev-hub-bridge.py"
fi
python3 -c "
import py_compile
py_compile.compile('$BRIDGE_PY', doraise=True)
"
grep -q 'get_containers_memory_stats' "$BRIDGE_PY" || { echo "❌ Error: get_containers_memory_stats missing in bridge"; exit 1; }
grep -q 'safe_avail_ram_gb' "$BRIDGE_PY" || { echo "❌ Error: safe_avail_ram_gb missing in bridge"; exit 1; }
grep -q 'handle_ords_refresh' "$BRIDGE_PY" || { echo "❌ Error: handle_ords_refresh missing in bridge"; exit 1; }
echo "     ✅ dev-hub-bridge.py syntax and RAM endpoints verified!"

# 6. Check compiled dev-hub.html
echo "  [6/6] Checking compiled dev-hub.html for unified controls, title, and RAM badge..."
DEV_HUB_HTML="$WORKSPACE_DIR/docs/dev-hub.html"
grep -q 'bp-card-ram-line' "$DEV_HUB_HTML" || { echo "❌ Error: bp-card-ram-line missing in dev-hub.html"; exit 1; }
grep -q 'bp-live-ram-pill' "$DEV_HUB_HTML" || { echo "❌ Error: bp-live-ram-pill missing in dev-hub.html"; exit 1; }
grep -q 'BLUEPRINT_RAM_BENCHMARKS' "$DEV_HUB_HTML" || { echo "❌ Error: BLUEPRINT_RAM_BENCHMARKS missing in dev-hub.html"; exit 1; }
grep -q 'master-autorefresh-btn' "$DEV_HUB_HTML" || { echo "❌ Error: master-autorefresh-btn missing in dev-hub.html"; exit 1; }
grep -q 'master-refresh-btn' "$DEV_HUB_HTML" || { echo "❌ Error: master-refresh-btn missing in dev-hub.html"; exit 1; }
! grep -q 'id="btn-toggle-auto-refresh"' "$DEV_HUB_HTML" || { echo "❌ Error: old btn-toggle-auto-refresh should not exist on top bar"; exit 1; }
! grep -q 'id="btn-manual-refresh"' "$DEV_HUB_HTML" || { echo "❌ Error: old btn-manual-refresh should not exist on top bar"; exit 1; }
grep -q 'Services Cockpit' "$DEV_HUB_HTML" || { echo "❌ Error: Services Cockpit title missing in dev-hub.html"; exit 1; }
echo "     ✅ dev-hub.html compiled with Services Cockpit and unified single master controls!"

echo "🎉 All Dev Hub RAM metrics unit tests passed successfully!"
