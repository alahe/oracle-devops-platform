#!/bin/bash
# ==============================================================================
# Oracle Forms Modernization Portfolio & Complexity Analyzer CLI
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source i18n if available
if [ -f "$WORKSPACE_DIR/scripts/internal/i18n.sh" ]; then
  # shellcheck source=/dev/null
  source "$WORKSPACE_DIR/scripts/internal/i18n.sh"
fi

FORMS_DIR="${1:-$WORKSPACE_DIR/forms_apps}"
CONVERT_FMB=false
OUTPUT_JSON="$WORKSPACE_DIR/metrics/forms_portfolio_analysis.json"
OUTPUT_MD="$WORKSPACE_DIR/tests/reports/forms_portfolio_analysis.md"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dir=*)
      FORMS_DIR="${1#*=}"
      shift
      ;;
    --dir|-d)
      FORMS_DIR="$2"
      shift 2
      ;;
    --convert|-c)
      CONVERT_FMB=true
      shift
      ;;
    --json=*)
      OUTPUT_JSON="${1#*=}"
      shift
      ;;
    --report=*)
      OUTPUT_MD="${1#*=}"
      shift
      ;;
    -h|--help)
      cat <<'EOF'
Oracle Forms Modernization Portfolio & Complexity Analyzer

Usage:
  ./scripts/forms/analyze-forms-portfolio.sh [OPTIONS] [FORMS_DIRECTORY]

Options:
  -d, --dir <DIR>      Directory containing Forms .fmb / .xml files (default: forms_apps/)
  -c, --convert        Automatically convert any unconverted .fmb files to XML first
  --json <FILE>        Output metrics JSON path (default: metrics/forms_portfolio_analysis.json)
  --report <FILE>      Output markdown report path (default: tests/reports/forms_portfolio_analysis.md)
  -h, --help           Show this help message

Examples:
  ./scripts/forms/analyze-forms-portfolio.sh
  ./scripts/forms/analyze-forms-portfolio.sh --convert forms_apps/
  ./scripts/forms/analyze-forms-portfolio.sh --dir /path/to/legacy/forms
EOF
      exit 0
      ;;
    *)
      if [ -d "$1" ]; then
        FORMS_DIR="$1"
      fi
      shift
      ;;
  esac
done

echo "=================================================================="
echo "🏛️  ORACLE FORMS MODERNIZATION PORTFOLIO ANALYZER"
echo "=================================================================="
echo "📂 Scanning directory: $FORMS_DIR"

if [ ! -d "$FORMS_DIR" ]; then
  echo "❌ Error: Directory not found: $FORMS_DIR" >&2
  exit 1
fi

# Optional batch conversion of .fmb to XML
if [ "$CONVERT_FMB" = "true" ]; then
  echo "⚙️  Checking for binary .fmb files to convert to XML..."
  CONV_SCRIPT="$SCRIPT_DIR/form-to-xml.sh"
  if [ -x "$CONV_SCRIPT" ]; then
    while IFS= read -r -d '' fmb_file; do
      base=$(basename "$fmb_file" .fmb)
      target_xml="$FORMS_DIR/${base}_fmb.xml"
      if [ ! -f "$target_xml" ] || [ "$fmb_file" -nt "$target_xml" ]; then
        echo "   ▶️ Converting: $fmb_file -> $target_xml"
        "$CONV_SCRIPT" --to-xml -o "$target_xml" "$fmb_file" || true
      fi
    done < <(find "$FORMS_DIR" -maxdepth 2 -name "*.fmb" -print0)
  fi
fi

# Execute Python analyzer engine
ENGINE_PY="$WORKSPACE_DIR/scripts/internal/analyze_forms_portfolio.py"
if [ ! -f "$ENGINE_PY" ]; then
  echo "❌ Error: Engine script not found: $ENGINE_PY" >&2
  exit 1
fi

python3 "$ENGINE_PY" "$FORMS_DIR" "$OUTPUT_JSON" "$OUTPUT_MD"

# Print terminal summary if JSON exists
if [ -f "$OUTPUT_JSON" ]; then
  python3 - << 'EOF' "$OUTPUT_JSON"
import json, sys
with open(sys.argv[1]) as f:
    d = json.load(f)

tot = d.get("total_forms_scanned", 0)
w = d.get("wave_breakdown", {})
m = d.get("aggregate_metrics", {})

print("\n" + "="*66)
print(f"📊 PORTFOLIO SUMMARY: {tot} FORMS ANALYZED")
print("="*66)
print(f"  🌊 Wave 1 (Simple CRUD / Lookups):           {w.get('wave_1_simple', 0):>3} forms")
print(f"  🌊 Wave 2 (Master-Detail Transactions):      {w.get('wave_2_master_detail', 0):>3} forms")
print(f"  🌊 Wave 3 (Complex Financial Monoliths):     {w.get('wave_3_complex_monolith', 0):>3} forms")
print("-" * 66)
print(f"  📦 Total UI Blocks:       {m.get('total_blocks', 0):>5} (Data & Control blocks)")
print(f"  🔘 Total Items:           {m.get('total_items', 0):>5} (Inputs, buttons, lists)")
print(f"  ⚡ Total Triggers:        {m.get('total_triggers', 0):>5} ({m.get('total_trigger_code_lines', 0)} PL/SQL lines)")
print(f"  📄 Program Units:         {m.get('total_program_unit_code_lines', 0):>5} PL/SQL lines")
print("="*66)
print("📄 Detailed Markdown Report: tests/reports/forms_portfolio_analysis.md")
print("💾 Metrics JSON Datastore:  metrics/forms_portfolio_analysis.json\n")
EOF
fi
