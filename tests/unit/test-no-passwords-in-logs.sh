#!/usr/bin/env bash
# ============================================================================
# Unit Test: test-no-passwords-in-logs.sh
# Validates Rule 5 (Zero-Trust): Credentials must NEVER appear in plaintext
# inside install_logs/, test scripts, or Dev Hub static artifacts.
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}==================================================================${NC}"
echo -e "🔒 ZERO-TRUST AUDIT: LOGS & SCRIPT CREDENTIAL SCANNER (Rule 5)"
echo -e "${CYAN}==================================================================${NC}"

FAILURES=0

# 1. Check test-publisher-deploy-verify-e2e.sh for password leaks in echo
E2E_SCRIPT="$WORKSPACE_DIR/tests/integration/test-publisher-deploy-verify-e2e.sh"
if [ -f "$E2E_SCRIPT" ]; then
  if grep -E 'echo.*get-password\.sh -p' "$E2E_SCRIPT" >/dev/null 2>&1; then
    echo -e "${RED}❌ VIOLATION: $E2E_SCRIPT prints plaintext password (-p) in echo output!${NC}"
    FAILURES=$((FAILURES + 1))
  else
    echo -e "${GREEN}✅ PASSED: test-publisher-deploy-verify-e2e.sh does not leak passwords via echo.${NC}"
  fi
fi

# 2. Query known SEPS Wallet aliases and verify they are not leaked in install_logs/ or docs/dev-hub.html
KNOWN_ALIASES=("PUBLISHER_DEVELOPER" "PUBLISHER_USER" "PUBLISHER_WEBLOGIC_ADMIN" "DB_PROXY_DEV" "DB_PROXY_APEX_ADMIN")
GET_PWD="$WORKSPACE_DIR/scripts/get-password.sh"

if [ -f "$GET_PWD" ]; then
  for alias in "${KNOWN_ALIASES[@]}"; do
    pwd_val=$("$GET_PWD" -p "$alias" 2>/dev/null || true)
    # Only check if password is non-empty and at least 8 characters
    if [ -n "$pwd_val" ] && [ ${#pwd_val} -ge 8 ]; then
      # Scan install_logs
      if [ -d "$WORKSPACE_DIR/install_logs" ]; then
        match_count=$(grep -rnF "$pwd_val" "$WORKSPACE_DIR/install_logs" 2>/dev/null | wc -l | tr -d ' ')
        if [ "$match_count" -gt 0 ]; then
          echo -e "${RED}❌ VIOLATION: Password for $alias found in install_logs ($match_count occurrences)!${NC}"
          FAILURES=$((FAILURES + 1))
        fi
      fi

      # Scan docs/dev-hub.html
      if [ -f "$WORKSPACE_DIR/docs/dev-hub.html" ]; then
        if grep -F "$pwd_val" "$WORKSPACE_DIR/docs/dev-hub.html" >/dev/null 2>&1; then
          echo -e "${RED}❌ VIOLATION: Password for $alias found in docs/dev-hub.html!${NC}"
          FAILURES=$((FAILURES + 1))
        fi
      fi
    fi
  done
fi

if [ "$FAILURES" -eq 0 ]; then
  echo -e "${GREEN}🎉 ZERO-TRUST AUDIT PASSED: No plaintext credentials found in logs or docs!${NC}"
  exit 0
else
  echo -e "${RED}⚠️  ZERO-TRUST AUDIT FAILED with $FAILURES violations!${NC}"
  exit 1
fi
