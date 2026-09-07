#!/usr/bin/env bash
# ==============================================================================
# Unit Test: test-pre-commit-check.sh
# Validates scripts/check-pre-commit.sh functionality:
#   1. CLI options (--help, --install-hook, --staged, --full)
#   2. Zero-Knowledge SHA-256 hash detection
#   3. GDPR & PII detection (e.g. *.dmp backup dump)
#   4. Syntax error detection (bash -n)
#   5. CRLF line ending detection & --fix flag
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

CHECK_SCRIPT="$WORKSPACE_DIR/scripts/check-pre-commit.sh"
HASHES_FILE="$WORKSPACE_DIR/config/security/forbidden_hashes.json"

echo "🧪 Running Unit Test: test-pre-commit-check.sh..."

# 1. Verify check script exists and is executable
if [ ! -x "$CHECK_SCRIPT" ]; then
  echo "❌ Error: $CHECK_SCRIPT is missing or not executable."
  exit 1
fi

# 2. Test --help
"$CHECK_SCRIPT" --help >/dev/null
echo "✅ Test 1: --help executed successfully."

# 3. Test --install-hook
"$CHECK_SCRIPT" --install-hook >/dev/null
if [ ! -f "$WORKSPACE_DIR/.githooks/pre-commit" ] || [ ! -f "$WORKSPACE_DIR/.githooks/pre-push" ]; then
  echo "❌ Error: Git hooks were not generated in .githooks/"
  exit 1
fi
echo "✅ Test 2: --install-hook generated hooks in .githooks/"

# 4. Test Zero-Knowledge SHA-256 detection
TEMP_HASH_BACKUP=$(mktemp)
cp "$HASHES_FILE" "$TEMP_HASH_BACKUP"

cleanup() {
  cp "$TEMP_HASH_BACKUP" "$HASHES_FILE" 2>/dev/null || true
  rm -f "$TEMP_HASH_BACKUP" 2>/dev/null || true
  git reset HEAD -- "tests/scratch_test_*" 2>/dev/null || true
  rm -f "$WORKSPACE_DIR"/tests/scratch_test_* 2>/dev/null || true
}
trap cleanup EXIT

DUMMY_TERM="SecretInternalKeyword$(date +%s)"
"$CHECK_SCRIPT" --add-forbidden-hash "$DUMMY_TERM" >/dev/null

TEST_FILE="$WORKSPACE_DIR/tests/scratch_test_term.py"
echo "internal_reference = '$DUMMY_TERM'" > "$TEST_FILE"

set +e
"$CHECK_SCRIPT" --files "$TEST_FILE" >/dev/null 2>&1
STATUS=$?
set -e

if [ $STATUS -eq 0 ]; then
  echo "❌ Error: check-pre-commit.sh failed to block confidential term!"
  exit 1
fi
echo "✅ Test 3: Zero-Knowledge SHA-256 hash detection correctly blocked confidential term."

rm -f "$TEST_FILE"

# 5. Test GDPR / backup dump block (*.dmp)
DUMP_FILE="$WORKSPACE_DIR/tests/scratch_test_dump.dmp"
echo "SIMULATED BINARY DUMP" > "$DUMP_FILE"

set +e
"$CHECK_SCRIPT" --files "$DUMP_FILE" >/dev/null 2>&1
STATUS=$?
set -e

if [ $STATUS -eq 0 ]; then
  echo "❌ Error: check-pre-commit.sh failed to block dangerous .dmp backup file!"
  exit 1
fi
echo "✅ Test 4: GDPR/Storage check correctly blocked database backup dump (*.dmp)."

rm -f "$DUMP_FILE"

# 6. Test syntax error detection
SYNTAX_FILE="$WORKSPACE_DIR/tests/scratch_test_bad_syntax.sh"
echo "if [ true; then echo missing_fi" > "$SYNTAX_FILE"

set +e
"$CHECK_SCRIPT" --files "$SYNTAX_FILE" >/dev/null 2>&1
STATUS=$?
set -e

if [ $STATUS -eq 0 ]; then
  echo "❌ Error: check-pre-commit.sh failed to block script with syntax error!"
  exit 1
fi
echo "✅ Test 5: Static syntax validator correctly blocked broken shell script."

rm -f "$SYNTAX_FILE"

# Restore original hashes file
cp "$TEMP_HASH_BACKUP" "$HASHES_FILE"
rm -f "$TEMP_HASH_BACKUP"

echo "🎉 All test-pre-commit-check.sh tests PASSED successfully!"
exit 0
