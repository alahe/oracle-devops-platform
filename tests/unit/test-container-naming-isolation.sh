#!/usr/bin/env bash
# ==============================================================================
# Unit Test: Container Naming Isolation & Substring Collision Prevention
# (tests/unit/test-container-naming-isolation.sh)
#
# Verifies Rule 15:
# 1. Static AST / Regex Scanner:
#    - Scans all scripts/ and tests/ for unanchored container greps
#    - Prevents loose `podman ps --filter name=` or unanchored `grep -q`
#    - Prevents broad exclusions like `grep -v "publisher"` that inadvertently
#      strip composite container names (e.g. db-forms-publisher).
# 2. Synthetic Collision Cross-Matrix:
#    - Verifies that exact container matching never produces false positives
#      for substring overlaps (e.g. app-publisher vs app-publisher-designer,
#      db-proxy vs db-proxy-standalone, app-forms vs app-forms-publisher).
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${CYAN}==================================================================${NC}"
echo -e "${BOLD}🔍 AUDITING CONTAINER NAMING ISOLATION & SUBSTRING PREVENTION (RULE 15)${NC}"
echo -e "${CYAN}==================================================================${NC}"

# Source common.sh to test core helper functions
if [ -f "$WORKSPACE_DIR/scripts/internal/common.sh" ]; then
  source "$WORKSPACE_DIR/scripts/internal/common.sh"
fi

TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
ERRORS=()

assert_true() {
  local desc="$1"
  local cmd="$2"
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  if eval "$cmd"; then
    PASSED_TESTS=$((PASSED_TESTS + 1))
    echo -e "  [PASS] $desc"
  else
    FAILED_TESTS=$((FAILED_TESTS + 1))
    ERRORS+=("$desc")
    echo -e "  ${RED}[FAIL] $desc${NC}"
  fi
}

assert_false() {
  local desc="$1"
  local cmd="$2"
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  if eval "$cmd"; then
    FAILED_TESTS=$((FAILED_TESTS + 1))
    ERRORS+=("$desc (expected false, got true)")
    echo -e "  ${RED}[FAIL] $desc${NC}"
  else
    PASSED_TESTS=$((PASSED_TESTS + 1))
    echo -e "  [PASS] $desc"
  fi
}

# ------------------------------------------------------------------------------
# 1. Synthetic Collision Cross-Matrix Tests
# ------------------------------------------------------------------------------
echo -e "\n${BOLD}Phase 1: Synthetic Substring Collision Cross-Matrix${NC}"

COLLISION_PAIRS=(
  "app-publisher:app-publisher-designer"
  "app-publisher:app-publisher-remote"
  "app-forms:app-forms-publisher"
  "db-proxy:db-proxy-standalone"
  "db-forms:db-forms-publisher"
  "db-publisher:db-forms-publisher"
  "app-ords:app-ords-remote"
  "db-publisher:db-publisher-remote"
)

# Test exact matching helper function
for pair in "${COLLISION_PAIRS[@]}"; do
  target="${pair%%:*}"
  distractor="${pair##*:}"

  # Test A: Target present -> container_exact_grep must MATCH
  assert_true \
    "Exact Match: container_exact_grep '$target' matches when '$target' is present" \
    "echo '$target' | container_exact_grep '$target'"

  # Test B: Distractor present -> container_exact_grep must NOT match target
  assert_false \
    "Isolation: container_exact_grep '$target' rejects distractor '$distractor'" \
    "echo '$distractor' | container_exact_grep '$target'"

  # Test C: Distractor present -> grep -q -E '^target$' must NOT match
  assert_false \
    "Isolation: grep '^$target$' rejects distractor '$distractor'" \
    "echo '$distractor' | grep -q -E '^${target}\$'"
done

# Test multi-container list isolation
MOCK_CONTAINER_LIST=$(cat <<EOF
app-publisher-designer
app-forms-publisher
db-proxy-standalone
app-ords-remote
db-publisher-remote
web-ide-dev
EOF
)

assert_false \
    "List Isolation: 'app-publisher' not matched in mock list of composite containers" \
    "echo '$MOCK_CONTAINER_LIST' | container_exact_grep 'app-publisher'"

assert_false \
    "List Isolation: 'db-proxy' not matched in mock list of composite containers" \
    "echo '$MOCK_CONTAINER_LIST' | container_exact_grep 'db-proxy'"

assert_false \
    "List Isolation: 'app-forms' not matched in mock list of composite containers" \
    "echo '$MOCK_CONTAINER_LIST' | container_exact_grep 'app-forms'"

assert_false \
    "List Isolation: 'app-ords' not matched in mock list of composite containers" \
    "echo '$MOCK_CONTAINER_LIST' | container_exact_grep 'app-ords'"

assert_true \
    "List Isolation: 'app-publisher-designer' successfully matched in mock list" \
    "echo '$MOCK_CONTAINER_LIST' | container_exact_grep 'app-publisher-designer'"

assert_true \
    "List Isolation: 'db-proxy-standalone' successfully matched in mock list" \
    "echo '$MOCK_CONTAINER_LIST' | container_exact_grep 'db-proxy-standalone'"


# ------------------------------------------------------------------------------
# 2. Static Code Analysis (Anti-Pattern Scanner)
# ------------------------------------------------------------------------------
echo -e "\n${BOLD}Phase 2: Static Code Scanner across scripts/ and tests/${NC}"

export WORKSPACE_DIR
python3 - << 'PYEOF'
import os, sys, re

workspace_dir = os.environ.get("WORKSPACE_DIR", os.path.abspath("."))
scan_dirs = ["scripts", "tests"]

KNOWN_CONTAINERS = [
    "app-publisher", "app-publisher-designer", "app-publisher-remote",
    "app-forms", "app-forms-publisher", "db-proxy", "db-proxy-standalone",
    "db-forms", "db-forms-publisher", "app-ords", "app-ords-remote",
    "db-publisher", "db-publisher-remote", "web-ide-dev"
]

violations = []

WHITELIST_SUBSTRINGS = [
    "tests/unit/test-container-naming-isolation.sh",
    "test-container-naming-isolation.sh",
    "container_exact_grep",
    "is_container_running",
    "is_container_healthy",
    "is_container_present",
    "^db-publisher|",
    "^(db-.*|oracle-db-.*)$",
    "^(db-|oracle-)",
    "^[a-zA-Z0-9_-]+$",
    "^${cname}$",
    "^${target}$",
    "^${PRIMARY_CONTAINER}$",
    "^app-ords$",
    "^oracle-ords-dev$",
    "grep -q -E \"^",
    "grep -q -E '^",
    "grep -q -E \"\\^",
    "grep -q -E '\\^",
    "grep -qx",
    "grep -E '^[A-Z0-9_]+ ='",
    "podman container exists",
    "podman inspect",
]

for sdir in scan_dirs:
    target_dir = os.path.join(workspace_dir, sdir)
    for root, _, files in os.walk(target_dir):
        for f in sorted(files):
            if not f.endswith(".sh"):
                continue
            fpath = os.path.join(root, f)
            relpath = os.path.relpath(fpath, workspace_dir)
            if "test-container-naming-isolation.sh" in relpath:
                continue

            with open(fpath, "r", encoding="utf-8", errors="ignore") as fh:
                lines = fh.readlines()

            for idx, line in enumerate(lines, start=1):
                raw_line = line.strip()
                if not raw_line or raw_line.startswith("#"):
                    continue

                # Check for unanchored container grep in podman ps pipes
                if "podman ps" in raw_line and "grep" in raw_line:
                    if any(w in raw_line for w in WHITELIST_SUBSTRINGS):
                        continue
                    for cname in KNOWN_CONTAINERS:
                        pattern = r'grep\s+(?:-[a-zA-Z]*q[a-zA-Z]*\s+)?[\'"]?' + re.escape(cname) + r'[\'"]?'
                        if re.search(pattern, raw_line) and not re.search(r'\^' + re.escape(cname) + r'\$', raw_line):
                            violations.append((relpath, idx, f"Unanchored container grep for '{cname}': {raw_line}"))

                # Check for loose unanchored podman ps --filter name=
                if "--filter name=" in raw_line or "--filter \"name=" in raw_line:
                    if any(w in raw_line for w in WHITELIST_SUBSTRINGS):
                        continue
                    violations.append((relpath, idx, f"Loose 'podman ps --filter name=' found (use is_container_running instead): {raw_line}"))

                # Check for dangerous broad grep -v "publisher" or grep -v "forms"
                if re.search(r'grep\s+-v\s+[\'"]publisher[\'"]', raw_line):
                    violations.append((relpath, idx, f"Dangerous broad exclusion 'grep -v \"publisher\"' (use exact regex instead): {raw_line}"))
                if re.search(r'grep\s+-v\s+[\'"]forms[\'"]', raw_line):
                    violations.append((relpath, idx, f"Dangerous broad exclusion 'grep -v \"forms\"' (use exact regex instead): {raw_line}"))

if violations:
    print(f"\033[0;31m❌ Found {len(violations)} container naming isolation violation(s):\033[0m")
    for rpath, lnum, msg in violations:
        print(f"  - {rpath}:{lnum} -> {msg}")
    sys.exit(1)
else:
    print("\033[0;32m✅ Zero unanchored container greps or loose name filters found across all scripts and tests!\033[0m")
PYEOF

if [ $? -eq 0 ]; then
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  PASSED_TESTS=$((PASSED_TESTS + 1))
  echo -e "  [PASS] Static AST / Regex Scanner passed"
else
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  FAILED_TESTS=$((FAILED_TESTS + 1))
  ERRORS+=("Static AST / Regex Scanner failed")
  echo -e "  ${RED}[FAIL] Static AST / Regex Scanner failed${NC}"
fi

# ------------------------------------------------------------------------------
# Summary & Benchmark Recording
# ------------------------------------------------------------------------------
echo -e "\n${CYAN}==================================================================${NC}"
echo -e "${BOLD}TEST SUMMARY:${NC} Total: $TOTAL_TESTS | Passed: ${GREEN}$PASSED_TESTS${NC} | Failed: ${RED}$FAILED_TESTS${NC}"
echo -e "${CYAN}==================================================================${NC}"

if [ "$FAILED_TESTS" -gt 0 ]; then
  echo -e "${RED}❌ Container Naming Isolation Audit FAILED!${NC}"
  for err in "${ERRORS[@]}"; do
    echo -e "  ${RED}• $err${NC}"
  done
  exit 1
fi

echo -e "${GREEN}✅ ALL CONTAINER NAMING ISOLATION TESTS PASSED SUCCESSFULLY!${NC}"
exit 0
