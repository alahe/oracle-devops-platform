#!/usr/bin/env bash
# ============================================================================
# Script: report-repo-stats.sh
# Purpose: Calculates and outputs comprehensive codebase statistics,
#          maintainable SLOC, test density, and architecture health.
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ -f "$WORKSPACE_DIR/scripts/internal/common.sh" ]; then
  source "$WORKSPACE_DIR/scripts/internal/common.sh"
fi

show_help() {
  cat << 'EOF'
Oracle DevOps Platform — Codebase Statistics Reporter

Usage:
  ./scripts/report-repo-stats.sh [options]

Options:
  --json          Output pure JSON statistics payload
  --markdown      Output formatted Markdown report
  --refresh       Force complete filesystem re-scan
  -h, --help      Show this help menu

Outputs:
  metrics/repo_statistics.json
  metrics/repo_statistics.md
EOF
}

OUTPUT_FORMAT="standard"

for arg in "$@"; do
  case "$arg" in
    --json)
      OUTPUT_FORMAT="json"
      ;;
    --markdown|--md)
      OUTPUT_FORMAT="markdown"
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
  esac
done

ENGINE_SCRIPT="$WORKSPACE_DIR/scripts/internal/generate-repo-report.py"

if [ ! -f "$ENGINE_SCRIPT" ]; then
  echo "❌ Error: Engine script $ENGINE_SCRIPT not found!" >&2
  exit 1
fi

if [ "$OUTPUT_FORMAT" = "json" ]; then
  python3 "$ENGINE_SCRIPT" --json
elif [ "$OUTPUT_FORMAT" = "markdown" ]; then
  python3 "$ENGINE_SCRIPT" --markdown
else
  python3 "$ENGINE_SCRIPT"
fi
