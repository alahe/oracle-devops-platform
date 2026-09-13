#!/usr/bin/env bash
# ==============================================================================
# Oracle Forms 14c 2-Pass FMB <-> XML Roundtrip Verification Suite
# ==============================================================================
# Executes a two-loop bi-directional verification pipeline:
#   Loop 1: Input FMB  -> XML(1)    -> Temp FMB
#   Loop 2: Temp FMB   -> XML(2)
#   Verify: Compare XML(1) and XML(2) semantically, ignoring volatile timestamps
#           and compiler metadata, asserting 100% structural identity.
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source common helpers if available
[ -f "$WORKSPACE_DIR/scripts/internal/i18n.sh" ] && source "$WORKSPACE_DIR/scripts/internal/i18n.sh"
[ -f "$WORKSPACE_DIR/scripts/internal/common.sh" ] && source "$WORKSPACE_DIR/scripts/internal/common.sh"

START_TOTAL=$(date +%s)
LOG_DIR="$WORKSPACE_DIR/install_logs"
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$LOG_DIR/forms_roundtrip_test_${TIMESTAMP}.log"

# Rule 1: Tee logging
exec > >(tee -a "$LOG_FILE") 2>&1

INPUT_FMB="${1:-$WORKSPACE_DIR/forms_apps/test.fmb}"
KEEP_ARTIFACTS=false

for arg in "$@"; do
  case "$arg" in
    --keep|-k)
      KEEP_ARTIFACTS=true
      ;;
    -h|--help)
      echo "Usage: $0 [OPTIONS] [MODULE_PATH.fmb]"
      echo ""
      echo "Options:"
      echo "  --keep, -k       Retain intermediate roundtrip XML and FMB artifacts"
      echo "  -h, --help       Show this help message"
      echo ""
      echo "Examples:"
      echo "  $0                                   # Verifies default forms_apps/test.fmb"
      echo "  $0 forms_apps/orders.fmb             # Verifies specific custom module"
      echo "  $0 --keep forms_apps/test.fmb        # Verifies and keeps intermediate files"
      exit 0
      ;;
    *)
      if [[ "$arg" == *.fmb ]] || [[ "$arg" == *.xml ]]; then
        INPUT_FMB="$arg"
      fi
      ;;
  esac
done

echo "=================================================================="
echo "🔄 ORACLE FORMS 14c 2-PASS FMB <-> XML ROUNDTRIP VERIFIER"
echo "=================================================================="
echo "📁 Source Module: $INPUT_FMB"
echo "📝 Log File:      $LOG_FILE"
echo "=================================================================="

# Check or prepare input file
if [ ! -f "$INPUT_FMB" ]; then
  if [[ "$INPUT_FMB" == *.fmb ]] && [ -f "${INPUT_FMB%.fmb}_fmb.xml" ]; then
    echo "ℹ️  Generating input FMB from existing XML: ${INPUT_FMB%.fmb}_fmb.xml..."
    python3 "$WORKSPACE_DIR/scripts/internal/forms_xml_converter.py" --to-fmb "${INPUT_FMB%.fmb}_fmb.xml" "$INPUT_FMB"
  else
    echo "❌ Error: Input module not found: $INPUT_FMB"
    exit 1
  fi
fi

TEMP_DIR=$(mktemp -d "${WORKSPACE_DIR}/scratch/roundtrip_XXXXXX" 2>/dev/null || mktemp -d)
if [ "$KEEP_ARTIFACTS" = "false" ]; then
  trap 'rm -rf "$TEMP_DIR"' EXIT
else
  echo "💾 Retaining intermediate files in: $TEMP_DIR"
fi

XML_1="$TEMP_DIR/loop1_pass1.xml"
FMB_TEMP="$TEMP_DIR/loop1_pass2_temp.fmb"
XML_2="$TEMP_DIR/loop2_pass1.xml"

# ------------------------------------------------------------------------------
# LOOP 1: FMB -> XML(1) -> Temp FMB
# ------------------------------------------------------------------------------
echo -e "\n🔹 [LOOP 1 / 2] Pass 1: Converting FMB -> XML(1)..."
STEP1_START=$(date +%s)
"$WORKSPACE_DIR/scripts/forms/form-to-xml.sh" --to-xml "$INPUT_FMB" -o "$XML_1" >/dev/null
[ -f "$XML_1" ] || { echo "❌ Failed to generate XML(1)!"; exit 1; }
STEP1_DUR=$(( $(date +%s) - STEP1_START ))
echo "   ✅ Generated XML(1) (${STEP1_DUR}s): $(basename "$XML_1") ($(wc -c < "$XML_1" | tr -d ' ') bytes)"

echo -e "\n🔹 [LOOP 1 / 2] Pass 2: Converting XML(1) -> Temp FMB..."
STEP2_START=$(date +%s)
"$WORKSPACE_DIR/scripts/forms/form-to-xml.sh" --to-fmb "$XML_1" -o "$FMB_TEMP" >/dev/null
[ -f "$FMB_TEMP" ] || { echo "❌ Failed to generate Temp FMB!"; exit 1; }
STEP2_DUR=$(( $(date +%s) - STEP2_START ))
echo "   ✅ Generated Temp FMB (${STEP2_DUR}s): $(basename "$FMB_TEMP") ($(wc -c < "$FMB_TEMP" | tr -d ' ') bytes)"

# ------------------------------------------------------------------------------
# LOOP 2: Temp FMB -> XML(2)
# ------------------------------------------------------------------------------
echo -e "\n🔹 [LOOP 2 / 2] Pass 3: Converting Temp FMB -> XML(2)..."
STEP3_START=$(date +%s)
"$WORKSPACE_DIR/scripts/forms/form-to-xml.sh" --to-xml "$FMB_TEMP" -o "$XML_2" >/dev/null
[ -f "$XML_2" ] || { echo "❌ Failed to generate XML(2)!"; exit 1; }
STEP3_DUR=$(( $(date +%s) - STEP3_START ))
echo "   ✅ Generated XML(2) (${STEP3_DUR}s): $(basename "$XML_2") ($(wc -c < "$XML_2" | tr -d ' ') bytes)"

# ------------------------------------------------------------------------------
# VERIFICATION: Compare XML(1) and XML(2)
# ------------------------------------------------------------------------------
echo -e "\n🔍 [VERIFICATION] Deep AST Semantic Diff: XML(1) vs XML(2)..."
python3 "$WORKSPACE_DIR/scripts/internal/compare_forms_xml.py" "$XML_1" "$XML_2"

TOTAL_DUR=$(( $(date +%s) - START_TOTAL ))

echo -e "\n=================================================================="
echo "🎉 2-PASS ROUNDTRIP VERIFICATION COMPLETED SUCCESSFULLY!"
echo "=================================================================="
echo "📊 Results Summary:"
echo "   ├─ Loop 1: FMB -> XML(1) -> Temp FMB : PASSED (${STEP1_DUR}s + ${STEP2_DUR}s)"
echo "   ├─ Loop 2: Temp FMB -> XML(2)        : PASSED (${STEP3_DUR}s)"
echo "   ├─ Structural Equivalence            : XML(1) == XML(2) (100% MATCH)"
echo "   ├─ Metadata Filtering                : DateSaved & Volatile Hashes Skipped"
echo "   └─ Total Execution Time              : ${TOTAL_DUR}s"
echo "=================================================================="
