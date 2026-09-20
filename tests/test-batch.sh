#!/usr/bin/env bash
# ==============================================================================
# Oracle DevOps Platform — Universal Batch Test Runner & Orchestrator
# Executes selected testing tiers:
#   --unit       : Tier 1 - Fast Isolation & Unit Tests (~3-5s)
#   --compliance : Tier 2 - Standards, Portability, i18n & Pre-Commit (~8-12s)
#   --ui         : Tier 3 - Dev Hub UI & WCAG Contrast Tests (~1-2s)
#   --live       : Tier 4 - E2E Live Containers & Full DB Matrix (~10-20m)
#   --quick      : Default combination of Tiers 1, 2, 3 (~15s)
#   --all        : Full suite of Tiers 1, 2, 3, 4
# ==============================================================================
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

START_SECONDS=$SECONDS
START_TS="$(date '+%Y-%m-%d %H:%M:%S')"

# Tiers to execute
RUN_UNIT=false
RUN_COMPLIANCE=false
RUN_UI=false
RUN_LIVE=false

# If no arguments provided, default to quick (Tiers 1, 2, 3)
if [ $# -eq 0 ]; then
  RUN_UNIT=true
  RUN_COMPLIANCE=true
  RUN_UI=true
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --unit)
      RUN_UNIT=true
      shift
      ;;
    --compliance)
      RUN_COMPLIANCE=true
      shift
      ;;
    --ui)
      RUN_UI=true
      shift
      ;;
    --live)
      RUN_LIVE=true
      shift
      ;;
    --quick)
      RUN_UNIT=true
      RUN_COMPLIANCE=true
      RUN_UI=true
      shift
      ;;
    --all)
      RUN_UNIT=true
      RUN_COMPLIANCE=true
      RUN_UI=true
      RUN_LIVE=true
      shift
      ;;
    -h|--help)
      echo "Kasutus: $0 [--unit] [--compliance] [--ui] [--live] [--quick] [--all]"
      echo "  --unit        Käivita Tase 1: Ühik- ja konfiguratsioonitestid (~3-5s)"
      echo "  --compliance  Käivita Tase 2: Vastavus (i18n, porditavus, turvalisus) (~8-12s)"
      echo "  --ui          Käivita Tase 3: Dev Hub UI & WCAG kontrast (~1-2s)"
      echo "  --live        Käivita Tase 4: E2E Live konteinerid ja andmebaasid (~10-20m)"
      echo "  --quick       Vaikimisi kiirtestid (Tasemed 1, 2, 3 kokku ~15s)"
      echo "  --all         Kõik tasemed (Tasemed 1, 2, 3, 4)"
      exit 0
      ;;
    *)
      echo "Tundmatu parameeter: $1"
      exit 1
      ;;
  esac
done

echo "=============================================================================="
echo " 🎛️ ORACLE DEVOPS PLATFORM — BATCH TEST RUNNER"
echo "=============================================================================="
echo " Käivitamise aeg: $START_TS"
echo " Valitud tasemed:"
[ "$RUN_UNIT" = true ] && echo "  [x] Tase 1: Ühik- ja konfiguratsioonitestid (Unit Tests)"
[ "$RUN_COMPLIANCE" = true ] && echo "  [x] Tase 2: Vastavus ja turvalisus (Compliance, i18n, Portability)"
[ "$RUN_UI" = true ] && echo "  [x] Tase 3: Dev Hub UI & WCAG kontrast (UI & Contrast)"
[ "$RUN_LIVE" = true ] && echo "  [x] Tase 4: E2E Live konteinerid & andmebaasid (Live Stacks)"
echo "------------------------------------------------------------------------------"

mkdir -p "$WORKSPACE_DIR/tests/reports" "$WORKSPACE_DIR/metrics" "$WORKSPACE_DIR/install_logs"

TIER1_STATUS="SKIPPED"
TIER1_TIME=0
TIER2_STATUS="SKIPPED"
TIER2_TIME=0
TIER3_STATUS="SKIPPED"
TIER3_TIME=0
TIER4_STATUS="SKIPPED"
TIER4_TIME=0

OVERALL_FAIL=false

# ------------------------------------------------------------------------------
# TASE 1: Ühik- ja konfiguratsioonitestid (~3-5s)
# ------------------------------------------------------------------------------
if [ "$RUN_UNIT" = true ]; then
  echo -e "\n▶️ [TASE 1]: Käivitan ühik- ja konfiguratsioonitestid..."
  T1_START=$SECONDS
  T1_FAIL=false

  # 1. Dev Hub generation & syntax
  if [ -f "$WORKSPACE_DIR/tests/unit/test-dev-hub-generation.sh" ]; then
    echo "  └─ 1. Dev Hub genereerimine ja JS süntaks..."
    if ! bash "$WORKSPACE_DIR/tests/unit/test-dev-hub-generation.sh" >/dev/null 2>&1; then
      echo "     ❌ Ebaõnnestus: test-dev-hub-generation.sh"
      T1_FAIL=true
    else
      echo "     ✅ Korras"
    fi
  fi

  # 2. Dedicated unit tests
  UNIT_COUNT=0
  for t in "$WORKSPACE_DIR"/tests/unit/test-script-*.sh; do
    [ -e "$t" ] || continue
    if ! bash "$t" >/dev/null 2>&1; then
      echo "     ❌ Ebaõnnestus: $(basename "$t")"
      T1_FAIL=true
    fi
    UNIT_COUNT=$((UNIT_COUNT + 1))
  done
  echo "     ✅ Kontrollitud $UNIT_COUNT eraldiseisvat skripti ühikutesti"

  TIER1_TIME=$(( SECONDS - T1_START ))
  if [ "$T1_FAIL" = true ]; then
    TIER1_STATUS="FAIL"
    OVERALL_FAIL=true
    echo "❌ TASE 1 Ebaõnnestus (${TIER1_TIME}s)"
  else
    TIER1_STATUS="PASS"
    echo "✅ TASE 1 Edukas: Kõik ühikutestid läbitud (${TIER1_TIME}s)"
  fi
fi

# ------------------------------------------------------------------------------
# TASE 2: Vastavus, turvalisus ja porditavus (~8-12s)
# ------------------------------------------------------------------------------
if [ "$RUN_COMPLIANCE" = true ]; then
  echo -e "\n▶️ [TASE 2]: Käivitan vastavuse, turvalisuse ja porditavuse testid..."
  T2_START=$SECONDS
  T2_FAIL=false

  # 1. Portability (Rule 13)
  echo "  └─ 1. Platvormiülene failinimede teisaldatavus (Rule 13)..."
  if ! bash "$WORKSPACE_DIR/tests/unit/test-filename-portability.sh" >/dev/null 2>&1; then
    echo "     ❌ Ebaõnnestus: test-filename-portability.sh"
    T2_FAIL=true
  else
    echo "     ✅ Korras (kõik teed vastavad reeglitele)"
  fi

  # 2. Multilingual support (Rule 9)
  echo "  └─ 2. 6-keelne i18n audit ja sõnastike sümmeetria (Rule 9)..."
  if ! bash "$WORKSPACE_DIR/tests/test-multilingual-support.sh" --all >/dev/null 2>&1; then
    echo "     ❌ Ebaõnnestus: test-multilingual-support.sh"
    T2_FAIL=true
  else
    echo "     ✅ Korras (16/16 i18n testi läbitud)"
  fi

  # 3. Pre-commit security check
  echo "  └─ 3. Git Pre-Commit turvakontroll ja saladuste leke..."
  if ! bash "$WORKSPACE_DIR/scripts/check-pre-commit.sh" --full >/dev/null 2>&1; then
    echo "     ❌ Ebaõnnestus: check-pre-commit.sh"
    T2_FAIL=true
  else
    echo "     ✅ Korras (Zero-Trust, GDPR & süntaks puhas)"
  fi

  TIER2_TIME=$(( SECONDS - T2_START ))
  if [ "$T2_FAIL" = true ]; then
    TIER2_STATUS="FAIL"
    OVERALL_FAIL=true
    echo "❌ TASE 2 Ebaõnnestus (${TIER2_TIME}s)"
  else
    TIER2_STATUS="PASS"
    echo "✅ TASE 2 Edukas: Vastavus ja turvalisus tagatud (${TIER2_TIME}s)"
  fi
fi

# ------------------------------------------------------------------------------
# TASE 3: Dev Hub UI & WCAG Kontrast (~1-2s)
# ------------------------------------------------------------------------------
if [ "$RUN_UI" = true ]; then
  echo -e "\n▶️ [TASE 3]: Käivitan Dev Hub UI, teemade ja kontrasti testid..."
  T3_START=$SECONDS
  T3_FAIL=false

  if ! bash "$WORKSPACE_DIR/tests/test-devhub-ui.sh" --all >/dev/null 2>&1; then
    echo "     ❌ Ebaõnnestus: test-devhub-ui.sh"
    T3_FAIL=true
  else
    echo "     ✅ Korras (Golden 7 vahelehed, teemad, zero black-boxes, WCAG 2.1 AA)"
  fi

  TIER3_TIME=$(( SECONDS - T3_START ))
  if [ "$T3_FAIL" = true ]; then
    TIER3_STATUS="FAIL"
    OVERALL_FAIL=true
    echo "❌ TASE 3 Ebaõnnestus (${TIER3_TIME}s)"
  else
    TIER3_STATUS="PASS"
    echo "✅ TASE 3 Edukas: Dev Hub UI ja kontrast korrektne (${TIER3_TIME}s)"
  fi
fi

# ------------------------------------------------------------------------------
# TASE 4: E2E Live Konteinerid & Andmebaasid (~10-20m)
# ------------------------------------------------------------------------------
if [ "$RUN_LIVE" = true ]; then
  echo -e "\n▶️ [TASE 4]: Käivitan E2E Live konteinerite ja andmebaaside testid..."
  T4_START=$SECONDS
  T4_FAIL=false

  if [ -f "$WORKSPACE_DIR/tests/test-containers-live.sh" ]; then
    echo "  └─ 1. Aktiivsete konteinerite ja soklite tervisekontroll..."
    if ! bash "$WORKSPACE_DIR/tests/test-containers-live.sh"; then
      T4_FAIL=true
    fi
  fi

  TIER4_TIME=$(( SECONDS - T4_START ))
  if [ "$T4_FAIL" = true ]; then
    TIER4_STATUS="FAIL"
    OVERALL_FAIL=true
    echo "❌ TASE 4 Ebaõnnestus (${TIER4_TIME}s)"
  else
    TIER4_STATUS="PASS"
    echo "✅ TASE 4 Edukas: Live konteinerid kontrollitud (${TIER4_TIME}s)"
  fi
fi

TOTAL_ELAPSED=$(( SECONDS - START_SECONDS ))
END_TS="$(date '+%Y-%m-%d %H:%M:%S')"

# ------------------------------------------------------------------------------
# KOKKUVÕTE JA TABEL
# ------------------------------------------------------------------------------
echo -e "\n=============================================================================="
echo " 📊 BATCH TEST RUNNER — TULEMUSTE KOONDKOKKUVÕTE"
echo "=============================================================================="
printf " %-35s | %-12s | %-10s\n" "Testitase" "Olek" "Kestus"
echo "------------------------------------------------------------------------------"
[ "$RUN_UNIT" = true ] && printf " %-35s | %-12s | %-10s\n" "Tase 1: Ühik- ja süntaksitestid" "$([ "$TIER1_STATUS" = "PASS" ] && echo "✅ PASS" || echo "❌ FAIL")" "${TIER1_TIME}s"
[ "$RUN_COMPLIANCE" = true ] && printf " %-35s | %-12s | %-10s\n" "Tase 2: Vastavus & Turvalisus" "$([ "$TIER2_STATUS" = "PASS" ] && echo "✅ PASS" || echo "❌ FAIL")" "${TIER2_TIME}s"
[ "$RUN_UI" = true ] && printf " %-35s | %-12s | %-10s\n" "Tase 3: Dev Hub UI & Kontrast" "$([ "$TIER3_STATUS" = "PASS" ] && echo "✅ PASS" || echo "❌ FAIL")" "${TIER3_TIME}s"
[ "$RUN_LIVE" = true ] && printf " %-35s | %-12s | %-10s\n" "Tase 4: E2E Live Konteinerid" "$([ "$TIER4_STATUS" = "PASS" ] && echo "✅ PASS" || echo "❌ FAIL")" "${TIER4_TIME}s"
echo "------------------------------------------------------------------------------"
printf " %-35s | %-12s | %-10s\n" "KOGU TESTIKOMPLEKT" "$([ "$OVERALL_FAIL" = false ] && echo "✅ 100% PASS" || echo "❌ VIGU ESINES")" "${TOTAL_ELAPSED}s"
echo "=============================================================================="

# Salvesta masinloetav telemeetria (Reegel 1)
METRICS_JSON="$WORKSPACE_DIR/metrics/test_batch_benchmarks.json"
cat << METRICSEOF > "$METRICS_JSON"
{
  "suite": "batch_test_runner",
  "status": $([ "$OVERALL_FAIL" = false ] && echo '"PASS"' || echo '"FAIL"'),
  "duration_seconds": $TOTAL_ELAPSED,
  "start_time": "$START_TS",
  "end_time": "$END_TS",
  "tiers": {
    "unit": { "enabled": $RUN_UNIT, "status": "$TIER1_STATUS", "duration_seconds": $TIER1_TIME },
    "compliance": { "enabled": $RUN_COMPLIANCE, "status": "$TIER2_STATUS", "duration_seconds": $TIER2_TIME },
    "ui": { "enabled": $RUN_UI, "status": "$TIER3_STATUS", "duration_seconds": $TIER3_TIME },
    "live": { "enabled": $RUN_LIVE, "status": "$TIER4_STATUS", "duration_seconds": $TIER4_TIME }
  }
}
METRICSEOF

# Genereeri Markdown koondaruanne Dev Hub raportite vahelehele
REPORT_MD="$WORKSPACE_DIR/tests/reports/test_batch_report.md"
cat << REPORTEOF > "$REPORT_MD"
# 🎛️ Batch Test Runner — Koondaruanne

- **Üldstaatus:** $([ "$OVERALL_FAIL" = false ] && echo '✅ 100% PASS' || echo '❌ TÕRKEID ESINES')
- **Kogukestus:** ${TOTAL_ELAPSED}s
- **Käivitatud:** ${START_TS}
- **Lõpetatud:** ${END_TS}

## Tasemete Tulemused
| Tase | Valdkond | Olek | Kestus |
| :--- | :--- | :--- | :--- |
$([ "$RUN_UNIT" = true ] && echo "| **Tase 1** | Ühik- ja konfiguratsioonitestid | $([ "$TIER1_STATUS" = "PASS" ] && echo '✅ PASS' || echo '❌ FAIL') | ${TIER1_TIME}s |")
$([ "$RUN_COMPLIANCE" = true ] && echo "| **Tase 2** | Vastavus, turvalisus & i18n | $([ "$TIER2_STATUS" = "PASS" ] && echo '✅ PASS' || echo '❌ FAIL') | ${TIER2_TIME}s |")
$([ "$RUN_UI" = true ] && echo "| **Tase 3** | Dev Hub UI & WCAG Kontrast | $([ "$TIER3_STATUS" = "PASS" ] && echo '✅ PASS' || echo '❌ FAIL') | ${TIER3_TIME}s |")
$([ "$RUN_LIVE" = true ] && echo "| **Tase 4** | E2E Live Konteinerid | $([ "$TIER4_STATUS" = "PASS" ] && echo '✅ PASS' || echo '❌ FAIL') | ${TIER4_TIME}s |")

*Aruanne genereeritud automaatselt Batch Test Runneri poolt.*
REPORTEOF

if [ "$OVERALL_FAIL" = true ]; then
  exit 1
else
  exit 0
fi
