#!/usr/bin/env bash
# ==============================================================================
# Unit Test: Dev Hub WCAG 2.1 AA Contrast Compliance & Theme Safety
# Verifies zero invisible text (#f8fafc on light surfaces) and verifies
# that inline colors meet WCAG AA contrast standards (minimum 4.5:1 / 3.0:1)
# ==============================================================================
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

CYAN='\033[1;36m'
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'

echo -e "${CYAN}=== Testing Dev Hub WCAG 2.1 AA Contrast & Theme Safety ===${NC}"

AUDIT_SCRIPT="$WORKSPACE_DIR/scripts/internal/dev_hub/audit_contrast.py"

if [ ! -f "$AUDIT_SCRIPT" ]; then
    echo -e "${RED}FAIL: Contrast audit script not found at $AUDIT_SCRIPT${NC}"
    exit 1
fi

python3 "$AUDIT_SCRIPT"
AUDIT_EXIT=$?

if [ $AUDIT_EXIT -eq 0 ]; then
    echo -e "${GREEN}PASS: All Dev Hub components satisfy WCAG 2.1 AA contrast requirements!${NC}"
    exit 0
else
    echo -e "${RED}FAIL: WCAG 2.1 AA contrast audit detected critical contrast violations.${NC}"
    exit 1
fi
