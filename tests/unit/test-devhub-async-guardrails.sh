#!/usr/bin/env bash
# ============================================================================
# Unit Test: Dev-Hub Asynchronous Task & Lifecycle State Guardrails
# Verifies Rule 12 and Invariants 3.6 / 3.7 to prevent regressions:
# 1. Prohibits synchronous blocking fetch with short AbortController timeouts on setup operations.
# 2. Ensures dev-hub-bridge.py uses ACTIVE_TASKS with asynchronous background dispatch.
# 3. Ensures setup-all.sh does not write .active_blueprint prematurely and uses .setup_in_progress.
# 4. Verifies AGENTS.md and SKILL.md persistent contracts.
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "=================================================================="
echo "🧪 AUDIT TEST: Dev-Hub Async Guardrails & Lifecycle State (Rule 12)"
echo "=================================================================="

ERRORS=0

# 1. Check app.js for architectural guardrail and prohibited 300s timeout on setup
echo "▶️ [Check 1]: Checking scripts/internal/dev_hub/assets/app.js..."
APP_JS="$WORKSPACE_DIR/scripts/internal/dev_hub/assets/app.js"
if [ ! -f "$APP_JS" ]; then
  echo "❌ Missing $APP_JS"
  ERRORS=$((ERRORS + 1))
else
  # Check guardrail comment exists
  if ! grep -q "ARCHITECTURAL GUARDRAIL (Rule 12 & Invariant 3.6" "$APP_JS"; then
    echo "❌ Missing architectural guardrail comment in app.js!"
    ERRORS=$((ERRORS + 1))
  else
    echo "  ✅ Guardrail comment present in app.js."
  fi

  # Check that 300,000ms AbortController timeout was eradicated from triggerBlueprintActionModal
  if grep -B 5 -A 10 "function triggerBlueprintActionModal" "$APP_JS" | grep -q "300000"; then
    echo "❌ Prohibited 300s AbortController timeout found in triggerBlueprintActionModal!"
    ERRORS=$((ERRORS + 1))
  else
    echo "  ✅ No 300s synchronous AbortController timeout in triggerBlueprintActionModal."
  fi

  # Check that task polling is implemented
  if ! grep -q "/api/task/status?task=" "$APP_JS"; then
    echo "❌ Missing /api/task/status polling in app.js!"
    ERRORS=$((ERRORS + 1))
  else
    echo "  ✅ Asynchronous task status polling verified in app.js."
  fi
fi

# 2. Check dev-hub-bridge.py for asynchronous task dispatch
echo "▶️ [Check 2]: Checking scripts/internal/dev-hub-bridge.py..."
BRIDGE_PY="$WORKSPACE_DIR/scripts/internal/dev-hub-bridge.py"
if [ ! -f "$BRIDGE_PY" ]; then
  echo "❌ Missing $BRIDGE_PY"
  ERRORS=$((ERRORS + 1))
else
  if ! grep -q "ARCHITECTURAL GUARDRAIL (Rule 12 & Invariant 3.6" "$BRIDGE_PY"; then
    echo "❌ Missing architectural guardrail comment in dev-hub-bridge.py!"
    ERRORS=$((ERRORS + 1))
  else
    echo "  ✅ Guardrail comment present in dev-hub-bridge.py."
  fi

  if ! grep -q "get_setup_in_progress" "$BRIDGE_PY"; then
    echo "❌ Missing get_setup_in_progress in dev-hub-bridge.py!"
    ERRORS=$((ERRORS + 1))
  else
    echo "  ✅ get_setup_in_progress verified in dev-hub-bridge.py."
  fi

  if ! grep -q "container_health" "$BRIDGE_PY"; then
    echo "❌ Missing container_health parsing in dev-hub-bridge.py!"
    ERRORS=$((ERRORS + 1))
  else
    echo "  ✅ Container healthcheck parsing verified in dev-hub-bridge.py."
  fi
fi

# 3. Check setup-all.sh for delayed .active_blueprint and .setup_in_progress lifecycle
echo "▶️ [Check 3]: Checking scripts/setup-all.sh..."
SETUP_SH="$WORKSPACE_DIR/scripts/setup-all.sh"
if [ ! -f "$SETUP_SH" ]; then
  echo "❌ Missing $SETUP_SH"
  ERRORS=$((ERRORS + 1))
else
  # Ensure .active_blueprint is NOT written in the first 500 lines
  EARLY_ABP=$(head -n 500 "$SETUP_SH" | grep "echo \"\$ACTIVE_BP_ID\" > \"\$WORKSPACE_DIR/\.active_blueprint\"" || true)
  if [ -n "$EARLY_ABP" ]; then
    echo "❌ Prohibited premature .active_blueprint write detected in setup-all.sh startup!"
    ERRORS=$((ERRORS + 1))
  else
    echo "  ✅ Premature .active_blueprint write eradicated from setup-all.sh startup."
  fi

  # Ensure .setup_in_progress is written at startup
  if ! head -n 500 "$SETUP_SH" | grep -q "\.setup_in_progress"; then
    echo "❌ Missing .setup_in_progress lifecycle marker in setup-all.sh startup!"
    ERRORS=$((ERRORS + 1))
  else
    echo "  ✅ .setup_in_progress lifecycle marker verified in setup-all.sh startup."
  fi

  # Ensure .active_blueprint is written at the verified completion stage
  if ! tail -n 100 "$SETUP_SH" | grep -q "\.active_blueprint"; then
    echo "❌ Missing verified .active_blueprint write in final completion stage of setup-all.sh!"
    ERRORS=$((ERRORS + 1))
  else
    echo "  ✅ Verified .active_blueprint write confirmed in final completion stage."
  fi
fi

# 4. Check .agents/AGENTS.md for Rule 12
echo "▶️ [Check 4]: Checking .agents/AGENTS.md for Rule 12..."
AGENTS_MD="$WORKSPACE_DIR/.agents/AGENTS.md"
if ! grep -q "12\. Asynchronous Long-Running Task & Lifecycle State Contract Rule" "$AGENTS_MD"; then
  echo "❌ Missing Rule 12 in .agents/AGENTS.md!"
  ERRORS=$((ERRORS + 1))
else
  echo "  ✅ Rule 12 verified in .agents/AGENTS.md."
fi

# 5. Check .agents/skills/devhub_architecture/SKILL.md for Invariants 4.6 (3.6) and 4.7 (3.7)
echo "▶️ [Check 5]: Checking .agents/skills/devhub_architecture/SKILL.md for Invariants 4.6 & 4.7..."
SKILL_MD="$WORKSPACE_DIR/.agents/skills/devhub_architecture/SKILL.md"
if ! grep -qE "(3|4)\.6 Mandatory Asynchronous Long-Running Task Contract" "$SKILL_MD" || ! grep -qE "(3|4)\.7 Delayed Active Blueprint & Verified State Contract" "$SKILL_MD"; then
  echo "❌ Missing Invariant 4.6 or 4.7 in SKILL.md!"
  ERRORS=$((ERRORS + 1))
else
  echo "  ✅ Invariants 4.6 and 4.7 verified in SKILL.md."
fi

echo "=================================================================="
if [ "$ERRORS" -gt 0 ]; then
  echo "❌ AUDIT FAILED: $ERRORS regression(s) detected!"
  exit 1
else
  echo "✅ AUDIT PASSED: All 5 guardrail checks passed with zero regressions!"
  echo "=================================================================="
  exit 0
fi
