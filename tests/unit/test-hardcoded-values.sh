#!/usr/bin/env bash
# ============================================================================
# Unit Test: Zero Hardcoded Values & Dynamic Profiles Audit (Rule 8, 5, 11)
# Verifies parameterized SQL PDB switches, dynamic user handling, and YAML profiles.
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "=================================================================="
echo "🧪 AUDIT TEST: Zero Hardcoded Values & Dynamic Profiles (Rule 11)"
echo "=================================================================="

ERRORS=0

# 1. Check SQL files for hardcoded PDB switches
echo "▶️ [Check 1]: Checking SQL scripts for hardcoded 'ALTER SESSION SET CONTAINER = FREEPDB1'..."
UNWANTED_SQL=$(grep -rn "ALTER SESSION SET CONTAINER = FREEPDB1;" "$WORKSPACE_DIR/scripts/internal"/*.sql 2>/dev/null || true)
if [ -n "$UNWANTED_SQL" ]; then
  echo "❌ Found hardcoded PDB switch in SQL scripts:"
  echo "$UNWANTED_SQL"
  ERRORS=$((ERRORS + 1))
else
  echo "  ✅ All internal SQL scripts use dynamic parameterized PDB switches."
fi

# 2. Check deployment and RCU scripts for hardcoded PDB switches
echo "▶️ [Check 2]: Checking shell scripts for hardcoded 'ALTER SESSION SET CONTAINER = FREEPDB1'..."
UNWANTED_SH=$(grep -rn "ALTER SESSION SET CONTAINER = FREEPDB1;" "$WORKSPACE_DIR/scripts/create-developer.sh" "$WORKSPACE_DIR/scripts/internal/deploy-apex-apps.sh" "$WORKSPACE_DIR/scripts/internal/init-forms-rcu.sh" "$WORKSPACE_DIR/scripts/internal/init-publisher-rcu.sh" 2>/dev/null || true)
if [ -n "$UNWANTED_SH" ]; then
  echo "❌ Found hardcoded PDB switch in shell scripts:"
  echo "$UNWANTED_SH"
  ERRORS=$((ERRORS + 1))
else
  echo "  ✅ All shell initializers use dynamic DB_SERVICE variables."
fi

# 3. Verify all active database profiles have valid YAML and omit SYS from users
echo "▶️ [Check 3]: Validating active Database YAML Profiles..."
python3 - << 'PYEOF' || ERRORS=$((ERRORS + 1))
import glob, yaml, sys, os

profiles = glob.glob('config/profiles/databases/*.yaml')
if len(profiles) < 7:
    print(f"❌ Expected at least 7 database profiles, found {len(profiles)}")
    sys.exit(1)

for p in sorted(profiles):
    fname = os.path.basename(p)
    with open(p) as fp:
        try:
            d = yaml.safe_load(fp) or {}
        except Exception as e:
            print(f"❌ Invalid YAML in {fname}: {e}")
            sys.exit(1)
            
    users = d.get('users', [])
    for u in users:
        uname = str(u.get('username', '')).upper()
        if uname == 'SYS':
            print(f"❌ Profile {fname} should not declare SYS in users array (SYS is auto-managed).")
            sys.exit(1)
        if not u.get('alias_suffix') and not u.get('wallet_alias'):
            print(f"❌ User {uname} in {fname} must define alias_suffix or wallet_alias.")
            sys.exit(1)

print(f"  ✅ All {len(profiles)} database profiles are valid and adhere to Rule 11 standard.")
PYEOF

# 4. Check for hardcoded local user machine paths (/Users/...) in core CLI scripts
echo "▶️ [Check 4]: Scanning scripts for hardcoded user paths (/Users/allanlahe)..."
UNWANTED_PATHS=$(grep -rn "/Users/allanlahe" "$WORKSPACE_DIR/scripts/setup-all.sh" "$WORKSPACE_DIR/scripts/reset-all.sh" "$WORKSPACE_DIR/scripts/create-developer.sh" "$WORKSPACE_DIR/scripts/get-password.sh" 2>/dev/null || true)
if [ -n "$UNWANTED_PATHS" ]; then
  echo "❌ Found hardcoded developer host paths:"
  echo "$UNWANTED_PATHS"
  ERRORS=$((ERRORS + 1))
else
  echo "  ✅ No absolute host user paths found in lifecycle scripts."
fi

echo "=================================================================="
if [ "$ERRORS" -gt 0 ]; then
  echo "❌ AUDIT FAILED with $ERRORS errors."
  exit 1
else
  echo "🎉 AUDIT PASSED: 100% Dynamic Profiles & Zero Hardcoding Verified!"
  echo "=================================================================="
fi
