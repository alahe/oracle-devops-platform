#!/usr/bin/env bash
# ============================================================================
# Integration Test: Local GitHub Actions Offline Simulation & SQLcl Projects
# Validates workflow files, secrets export, and dry-run local execution
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "=================================================================="
echo "🧪 INTEGRATION TEST: GitHub Actions Local Offline Simulation & SQLcl Projects"
echo "=================================================================="

# 1. Kontrolli workflow failide olemasolu ja sintaksit
echo "▶️ [Test 1]: Kontrollin GitHub Actions workflow failide olemasolu..."
if [ ! -f "$WORKSPACE_DIR/.github/workflows/deploy-apex.yml" ]; then
  echo "❌ Viga: deploy-apex.yml faili ei leitud!"
  exit 1
fi
if [ ! -f "$WORKSPACE_DIR/.github/workflows/ci-test-suite.yml" ]; then
  echo "❌ Viga: ci-test-suite.yml faili ei leitud!"
  exit 1
fi
echo "  ✅ GitHub Actions workflow failid on olemas."

# 2. Kontrolli SQLcl Projects seadistust
echo "▶️ [Test 2]: Kontrollin SQLcl Projects seadistust (.dbtools)..."
if [ ! -f "$WORKSPACE_DIR/.dbtools/project.config.json" ]; then
  echo "❌ Viga: SQLcl project.config.json faili ei leitud!"
  exit 1
fi
if [ ! -f "$WORKSPACE_DIR/.dbtools/filters/project.filters" ]; then
  echo "❌ Viga: SQLcl project.filters faili ei leitud!"
  exit 1
fi
echo "  ✅ SQLcl Projects konfiguratsioonifailid on olemas."

# 3. Kontrolli SEPS Walleti Base64 eksporti
echo "▶️ [Test 3]: Testin SEPS Walleti Base64 eksportija skripti..."
B64_OUT=$("$WORKSPACE_DIR/scripts/internal/export-ci-secrets.sh")
if ! echo "$B64_OUT" | grep -q "SEPS Wallet edukalt pakitud"; then
  echo "❌ Viga: export-ci-secrets.sh ei edastanud oodatud Base64 väljundit!"
  exit 1
fi
echo "  ✅ SEPS Wallet Base64 eksportija toimib puhtalt."

# 4. Testi lokaalset CI/CD simulaatorit dry-run režiimis
echo "▶️ [Test 4]: Käivitan ./scripts/test-local-ci.sh --dry-run..."
DRY_RUN_OUT=$("$WORKSPACE_DIR/scripts/test-local-ci.sh" --dry-run)
if ! echo "$DRY_RUN_OUT" | grep -q "LOKAALNE CI/CD TEST EDUKALT LÕPETATUD"; then
  echo "❌ Viga: test-local-ci.sh --dry-run ei lõpetanud edukalt!"
  exit 1
fi
echo "  ✅ Lokaalne offline CI/CD simulaator (dry-run) läbis testi edukalt."

echo "=================================================================="
echo "🎉 KÕIK GITHUB ACTIONS LOKAALSE SIMULAATORI TESTID LÄBITUD EDUKALT!"
echo "=================================================================="
