#!/usr/bin/env bash
# ==============================================================================
# Unit Test: 4-Part Iteration & Semantic Versioning Framework (Rule 16)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "🔍 Testing 4-Part Iteration & Automated Semantic Release System..."

FAILURES=0

# Test 1: bump-iteration.sh exists and is executable
echo "  [1/6] Checking bump-iteration.sh executable..."
if [[ -x "$WORKSPACE_DIR/scripts/bump-iteration.sh" ]]; then
  echo "    ✓ bump-iteration.sh is present and executable"
else
  echo "    ❌ ERROR: bump-iteration.sh not found or not executable"
  FAILURES=$((FAILURES + 1))
fi

# Test 2: bump-iteration.sh --dry-run produces valid 4th number
echo "  [2/6] Verifying bump-iteration.sh dry-run logic..."
DRY_OUT="$("$WORKSPACE_DIR/scripts/bump-iteration.sh" --dry-run 2>&1)"
if echo "$DRY_OUT" | grep -Eq "Uus iteratsioon:.*v[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+"; then
  echo "    ✓ bump-iteration.sh increments 4-part iteration correctly"
else
  echo "    ❌ ERROR: bump-iteration.sh dry-run did not output expected 4-part version: $DRY_OUT"
  FAILURES=$((FAILURES + 1))
fi

# Test 3: release.sh exists and executes --dry-run
echo "  [3/6] Verifying release.sh semantic analysis..."
if [[ -x "$WORKSPACE_DIR/scripts/release.sh" ]]; then
  REL_OUT="$("$WORKSPACE_DIR/scripts/release.sh" --dry-run 2>&1)"
  if echo "$REL_OUT" | grep -Fq "SEMANATILINE RELIISI ANALÜÜS (DRY-RUN)"; then
    echo "    ✓ release.sh executes and produces dry-run report"
  else
    echo "    ❌ ERROR: release.sh failed dry-run: $REL_OUT"
    FAILURES=$((FAILURES + 1))
  fi
else
  echo "    ❌ ERROR: release.sh not found or not executable"
  FAILURES=$((FAILURES + 1))
fi

# Test 4: Pre-push hook verification
echo "  [4/6] Verifying pre-push hook integration..."
if [[ -x "$WORKSPACE_DIR/.githooks/pre-push" ]]; then
  if grep -Fq "release.sh" "$WORKSPACE_DIR/.githooks/pre-push"; then
    echo "    ✓ .githooks/pre-push contains automated semantic release check"
  else
    echo "    ❌ ERROR: .githooks/pre-push does not invoke release.sh"
    FAILURES=$((FAILURES + 1))
  fi
else
  echo "    ❌ ERROR: .githooks/pre-push missing or not executable"
  FAILURES=$((FAILURES + 1))
fi

# Test 5: Specification Traceability ([REQ-06])
echo "  [5/6] Verifying SDD specification synchronization..."
if grep -Fq "[REQ-06]" "$WORKSPACE_DIR/docs/specs/devops-portal/requirements.md"; then
  echo "    ✓ REQ-06 is declared in requirements.md"
else
  echo "    ❌ ERROR: [REQ-06] missing from requirements.md"
  FAILURES=$((FAILURES + 1))
fi

if grep -Fq "TSK-DP-08" "$WORKSPACE_DIR/docs/specs/devops-portal/tasks.md"; then
  echo "    ✓ TSK-DP-08 is declared in tasks.md"
else
  echo "    ❌ ERROR: TSK-DP-08 missing from tasks.md"
  FAILURES=$((FAILURES + 1))
fi

# Test 6: Rule 16 & AI Skill synchronization
echo "  [6/6] Verifying Rule 16 and AI Skill governance..."
if grep -Fq "4-Part Iteration Bumping" "$WORKSPACE_DIR/.agents/AGENTS.md"; then
  echo "    ✓ Rule 16 is codified in .agents/AGENTS.md"
else
  echo "    ❌ ERROR: 4-part iteration rule missing from AGENTS.md"
  FAILURES=$((FAILURES + 1))
fi

if grep -Fq "Pillar 4: 4-Part Iteration" "$WORKSPACE_DIR/.agents/skills/sdd_assembly_line/SKILL.md"; then
  echo "    ✓ Pillar 4 is codified in sdd_assembly_line skill"
else
  echo "    ❌ ERROR: Pillar 4 missing from sdd_assembly_line skill"
  FAILURES=$((FAILURES + 1))
fi

echo "=================================================================="
if [[ $FAILURES -eq 0 ]]; then
  echo "✅ ALL SEMANTIC VERSIONING & ITERATION TESTS PASSED!"
  exit 0
else
  echo "❌ $FAILURES TEST(S) FAILED."
  exit 1
fi
