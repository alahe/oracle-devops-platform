#!/usr/bin/env bash
# ============================================================================
# Test Suite: TLS Scenarios & Blueprint Policy Enforcement Validation
# Purpose: Simulates and tests all 4 TLS modes and Blueprint policy gating:
#          1. Custom Cert Drop-In (Step 0)
#          2. User-Space Local Trust (Step 3)
#          3. Policy Rejection Gating (strict_public / corporate_pki)
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

CYAN='\033[1;36m'
GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${CYAN}==================================================================${NC}"
echo -e "${BOLD}🔒 TLS & BLUEPRINT POLICY AUTOMATED TEST SUITE${NC}"
echo -e "${CYAN}==================================================================${NC}"

TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

assert_test() {
  local test_name="$1"
  local expected="$2"
  local actual="$3"
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  if [ "$expected" = "$actual" ]; then
    echo -e "   ✅ [PASS] ${test_name} -> ${GREEN}${actual}${NC}"
    PASSED_TESTS=$((PASSED_TESTS + 1))
  else
    echo -e "   ❌ [FAIL] ${test_name} -> Oodati: '${expected}', Saadi: '${actual}'"
    FAILED_TESTS=$((FAILED_TESTS + 1))
  fi
}

# ----------------------------------------------------------------------------
# TEST 1: Default / Permissive Policy resolves USER_LOCAL_CA (Variant 3)
# ----------------------------------------------------------------------------
echo -e "\n${YELLOW}[Test 1] Vaikimisi permissive režiimi tuvastus (USER_LOCAL_CA)...${NC}"
TLS_ALLOWED_LEVEL="permissive"
USE_PUBLIC_CA_CERTS="false"
CORP_PKI_ENABLED="false"
rm -rf "$WORKSPACE_DIR/config/certs/custom/tls.crt" "$WORKSPACE_DIR/config/certs/custom/tls.key" 2>/dev/null || true
rm -rf "$WORKSPACE_DIR/config/certs/corp/corp_cert.crt" "$WORKSPACE_DIR/config/certs/corp/corp_key.key" 2>/dev/null || true

source "$WORKSPACE_DIR/scripts/internal/resolve-tls-mode.sh"
resolve_tls_mode >/dev/null 2>&1 || true
assert_test "Permissive TLS Mode" "USER_LOCAL_CA" "$RESOLVED_TLS_MODE"

# ----------------------------------------------------------------------------
# TEST 2: Custom Certificate Drop-In (Step 0 Override)
# ----------------------------------------------------------------------------
echo -e "\n${YELLOW}[Test 2] Käsitsi lisatud sertifikaadi tuvastus (config/certs/custom/)...${NC}"
mkdir -p "$WORKSPACE_DIR/config/certs/custom"
touch "$WORKSPACE_DIR/config/certs/custom/tls.crt"
touch "$WORKSPACE_DIR/config/certs/custom/tls.key"

TLS_ALLOWED_LEVEL="strict_public"
resolve_tls_mode >/dev/null 2>&1 || true
assert_test "Custom Cert Drop-in Mode" "CUSTOM_CERT" "$RESOLVED_TLS_MODE"

rm -f "$WORKSPACE_DIR/config/certs/custom/tls.crt" "$WORKSPACE_DIR/config/certs/custom/tls.key"

# ----------------------------------------------------------------------------
# TEST 3: Blueprint Policy Rejection when strict_public has no public/custom cert
# ----------------------------------------------------------------------------
echo -e "\n${YELLOW}[Test 3] Blueprinti poliitika tagasilükkamise test (strict_public ilma sertifikaadita)...${NC}"
TLS_ALLOWED_LEVEL="strict_public"
USE_PUBLIC_CA_CERTS="false"
CORP_PKI_ENABLED="false"

set +e
output=$(resolve_tls_mode 2>&1)
exit_code=$?
set -e

assert_test "Policy Rejection Exit Code (Must be 1)" "1" "$exit_code"

if echo "$output" | grep -q "TLS NÕUETE VIGA"; then
  assert_test "Policy Rejection User Guidance Output" "FOUND" "FOUND"
else
  assert_test "Policy Rejection User Guidance Output" "FOUND" "NOT_FOUND"
fi

# ----------------------------------------------------------------------------
# TEST 4: Corporate PKI mode resolution
# ----------------------------------------------------------------------------
echo -e "\n${YELLOW}[Test 4] Ettevõtte sise-PKI tuvastuse test (CORP_PKI)...${NC}"
mkdir -p "$WORKSPACE_DIR/config/certs/corp"
touch "$WORKSPACE_DIR/config/certs/corp/corp_cert.crt"
touch "$WORKSPACE_DIR/config/certs/corp/corp_key.key"

TLS_ALLOWED_LEVEL="corporate_pki"
CORP_PKI_ENABLED="true"
resolve_tls_mode >/dev/null 2>&1 || true

assert_test "Corporate PKI Mode" "CORP_PKI" "$RESOLVED_TLS_MODE"

rm -f "$WORKSPACE_DIR/config/certs/corp/corp_cert.crt" "$WORKSPACE_DIR/config/certs/corp/corp_key.key"
CORP_PKI_ENABLED="false"

# ----------------------------------------------------------------------------
# TEST 5: User-Space Mac Trust Script (No Sudo)
# ----------------------------------------------------------------------------
if [[ "$OSTYPE" == "darwin"* ]]; then
  echo -e "\n${YELLOW}[Test 5] macOS User-Space Keychain usaldamise skript (0-Root / No Sudo)...${NC}"
  set +e
  "$WORKSPACE_DIR/scripts/certs/trust-local-cert-mac.sh" >/dev/null 2>&1
  mac_exit=$?
  set -e
  assert_test "macOS Keychain User Trust Exit Code" "0" "$mac_exit"
fi

# ----------------------------------------------------------------------------
# TEST 6: Variant 4 Self-Signed Fallback Mode (config/certs/self_signed/)
# ----------------------------------------------------------------------------
echo -e "\n${YELLOW}[Test 6] Variant 4 Iseallkirjastatud sertifikaadi tuvastuse test (SELF_SIGNED)...${NC}"
mkdir -p "$WORKSPACE_DIR/config/certs/self_signed"
touch "$WORKSPACE_DIR/config/certs/self_signed/self_signed.crt"
touch "$WORKSPACE_DIR/config/certs/self_signed/self_signed.key"

# Temporarily move user_ca so fallback triggers
mkdir -p "$WORKSPACE_DIR/config/certs/user_ca_temp"
mv "$WORKSPACE_DIR/config/certs/user_ca"/* "$WORKSPACE_DIR/config/certs/user_ca_temp/" 2>/dev/null || true
mv "$WORKSPACE_DIR/config/certs/localCA.pem" "$WORKSPACE_DIR/config/certs/localCA_temp.pem" 2>/dev/null || true

TLS_ALLOWED_LEVEL="permissive"
USE_PUBLIC_CA_CERTS="false"
CORP_PKI_ENABLED="false"
resolve_tls_mode >/dev/null 2>&1 || true

assert_test "Variant 4 Self-Signed Mode" "SELF_SIGNED" "$RESOLVED_TLS_MODE"

# ----------------------------------------------------------------------------
# TEST 7: Policy Gating 'trusted_local' blocks Variant 4 Self-Signed
# ----------------------------------------------------------------------------
echo -e "\n${YELLOW}[Test 7] 'trusted_local' poliitika test (keelab Variant 4 SELF_SIGNED)...${NC}"
TLS_ALLOWED_LEVEL="trusted_local"
set +e
output=$(resolve_tls_mode 2>&1)
exit_code=$?
set -e

assert_test "trusted_local blocks SELF_SIGNED (Exit Code 1)" "1" "$exit_code"

# Restore user_ca files
mv "$WORKSPACE_DIR/config/certs/user_ca_temp"/* "$WORKSPACE_DIR/config/certs/user_ca/" 2>/dev/null || true
mv "$WORKSPACE_DIR/config/certs/localCA_temp.pem" "$WORKSPACE_DIR/config/certs/localCA.pem" 2>/dev/null || true
rm -rf "$WORKSPACE_DIR/config/certs/user_ca_temp"

echo -e "\n${CYAN}==================================================================${NC}"
if [ "$FAILED_TESTS" -eq 0 ]; then
  echo -e "${GREEN}🎉 KÕIK TLS JA POLIITIKA TESTID LÄBITI EDUKALT ($PASSED_TESTS / $TOTAL_TESTS)!${NC}"
  echo -e "${CYAN}==================================================================${NC}"
  exit 0
else
  echo -e "${RED}❌ $FAILED_TESTS TESTI EBAÕNNESTUS ($PASSED_TESTS / $TOTAL_TESTS läbitud)!${NC}"
  echo -e "${CYAN}==================================================================${NC}"
  exit 1
fi
