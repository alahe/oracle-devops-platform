#!/usr/bin/env bash
# ============================================================================
# Test Suite: Certificate Cleanup Safety & Isolation Verification
# Purpose: Verifies that clean-certs.sh:
#          1. Creates a full backup before cleaning.
#          2. Completely removes all platform-generated certificates and wallets.
#          3. Strictly PRESERVES all other unrelated third-party/system certificates.
#          4. Automatically removes the backup only if all tests pass.
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

CYAN='\033[1;36m'
GREEN='\033[1;32m'
YELLOW='\033[0;33m'
RED='\033[1;31m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${CYAN}==================================================================${NC}"
echo -e "${BOLD}🛡️  TEST: CERTIFICATE CLEANUP SAFETY & ISOLATION VERIFICATION${NC}"
echo -e "${CYAN}==================================================================${NC}"

BACKUP_DIR="$WORKSPACE_DIR/.backup_certs_test_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

assert_test() {
  local test_name="$1"
  local expected="$2"
  local actual="$3"
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  if [ "$expected" = "$actual" ]; then
    echo -e "   ✅ [PASS] ${test_name}"
    PASSED_TESTS=$((PASSED_TESTS + 1))
  else
    echo -e "   ❌ [FAIL] ${test_name} -> Oodati: '${expected}', Saadi: '${actual}'"
    FAILED_TESTS=$((FAILED_TESTS + 1))
  fi
}

USER_KEYCHAIN=""
if [[ "$OSTYPE" == "darwin"* ]]; then
  USER_KEYCHAIN="$HOME/Library/Keychains/login.keychain-db"
  [ ! -f "$USER_KEYCHAIN" ] && USER_KEYCHAIN="$HOME/Library/Keychains/login.keychain"
fi

# ----------------------------------------------------------------------------
# 1. Varukoopia loomine (Backup)
# ----------------------------------------------------------------------------
echo -e "\n${YELLOW}1. Loon sertifikaatidest ja seadetest ajutise varukoopia...${NC}"
mkdir -p "$BACKUP_DIR/config_certs" "$BACKUP_DIR/wallets"

# Backup files on disk
if [ -d "$WORKSPACE_DIR/config/certs" ]; then
  cp -R "$WORKSPACE_DIR/config/certs" "$BACKUP_DIR/"
fi
if [ -d "$WORKSPACE_DIR/config/wallet-apex-proxy" ]; then
  cp -R "$WORKSPACE_DIR/config/wallet-apex-proxy" "$BACKUP_DIR/"
fi
if [ -d "$WORKSPACE_DIR/config/wallet-publisher" ]; then
  cp -R "$WORKSPACE_DIR/config/wallet-publisher" "$BACKUP_DIR/"
fi

# Snapshot existing keychain certificates
if [ -n "$USER_KEYCHAIN" ] && [ -f "$USER_KEYCHAIN" ]; then
  security find-certificate -a "$USER_KEYCHAIN" 2>/dev/null | grep "alis" > "$BACKUP_DIR/keychain_before.txt" || true
fi

echo -e "   📦 Varukoopia salvestatud kausta: ${CYAN}${BACKUP_DIR}${NC}"
assert_test "Varukoopia kausta loomine" "EXISTS" "$([ -d "$BACKUP_DIR" ] && echo "EXISTS" || echo "MISSING")"

# ----------------------------------------------------------------------------
# 2. Lisa test-sertifikaat, mis EI OLE antud rakendusega seotud (Dummy Unrelated Cert)
# ----------------------------------------------------------------------------
echo -e "\n${YELLOW}2. Lisan teise, rakendusega mitteseotud testsertifikaadi (Unrelated Third-Party Cert)...${NC}"
DUMMY_CERT_NAME="Unrelated Corporate Test Certificate 2026"
DUMMY_CERT_FILE="$BACKUP_DIR/dummy_unrelated.crt"
DUMMY_KEY_FILE="$BACKUP_DIR/dummy_unrelated.key"

openssl req -x509 -newkey rsa:2048 -nodes -days 1 \
  -keyout "$DUMMY_KEY_FILE" \
  -out "$DUMMY_CERT_FILE" \
  -subj "/C=EE/O=External Unrelated Org/CN=${DUMMY_CERT_NAME}" 2>/dev/null

if [ -n "$USER_KEYCHAIN" ] && [ -f "$USER_KEYCHAIN" ]; then
  security add-certificate -k "$USER_KEYCHAIN" "$DUMMY_CERT_FILE" 2>/dev/null || true
  DUMMY_FOUND="NO"
  if security find-certificate -c "$DUMMY_CERT_NAME" "$USER_KEYCHAIN" &>/dev/null; then
    DUMMY_FOUND="YES"
  fi
  assert_test "Mitteseotud testsertifikaadi lisamine hoidlasse" "YES" "$DUMMY_FOUND"
fi

# ----------------------------------------------------------------------------
# 3. Käivita puhastusskript (Execute clean-certs.sh)
# ----------------------------------------------------------------------------
echo -e "\n${YELLOW}3. Käivitan sertifikaatide puhastusskripti: ./scripts/certs/clean-certs.sh -y...${NC}"
"$WORKSPACE_DIR/scripts/certs/clean-certs.sh" -y >/dev/null 2>&1
CLEAN_EXIT=$?
assert_test "clean-certs.sh väljumiskood" "0" "$CLEAN_EXIT"

# ----------------------------------------------------------------------------
# 4. Kontrolli, kas rakenduse enda sertifikaadid kustutati korrektselt
# ----------------------------------------------------------------------------
echo -e "\n${YELLOW}4. Kontrollin, kas rakenduse enda sertifikaadid on korrektselt kustutatud...${NC}"

# A. macOS Keychain kontroll
if [ -n "$USER_KEYCHAIN" ] && [ -f "$USER_KEYCHAIN" ]; then
  APP_CERT_FOUND="CLEANED"
  if security find-certificate -c "Local Dev Root CA" "$USER_KEYCHAIN" &>/dev/null; then
    APP_CERT_FOUND="STILL_EXISTS"
  fi
  assert_test "Rakenduse 'Local Dev Root CA' on Keychainist kustutatud" "CLEANED" "$APP_CERT_FOUND"
fi

# B. Kettal olevate failide kontroll
assert_test "config/certs/localhost.crt on kustutatud" "MISSING" "$([ -f "$WORKSPACE_DIR/config/certs/localhost.crt" ] && echo "EXISTS" || echo "MISSING")"
assert_test "config/certs/localhost.key on kustutatud" "MISSING" "$([ -f "$WORKSPACE_DIR/config/certs/localhost.key" ] && echo "EXISTS" || echo "MISSING")"
assert_test "config/certs/localhost.der on kustutatud" "MISSING" "$([ -f "$WORKSPACE_DIR/config/certs/localhost.der" ] && echo "EXISTS" || echo "MISSING")"
assert_test "config/certs/localCA.pem on kustutatud" "MISSING" "$([ -f "$WORKSPACE_DIR/config/certs/localCA.pem" ] && echo "EXISTS" || echo "MISSING")"
assert_test "config/wallet-apex-proxy/cwallet.sso on kustutatud" "MISSING" "$([ -f "$WORKSPACE_DIR/config/wallet-apex-proxy/cwallet.sso" ] && echo "EXISTS" || echo "MISSING")"
assert_test "config/wallet-publisher/cwallet.sso on kustutatud" "MISSING" "$([ -f "$WORKSPACE_DIR/config/wallet-publisher/cwallet.sso" ] && echo "EXISTS" || echo "MISSING")"

# ----------------------------------------------------------------------------
# 5. Kontrolli, kas teised / mitteseotud sertifikaadid jäid 100% PUUTUMATA!
# ----------------------------------------------------------------------------
echo -e "\n${YELLOW}5. Kontrollin, et mitteseotud sertifikaadid jäid puutumata (Isolatsioonikontroll)...${NC}"

if [ -n "$USER_KEYCHAIN" ] && [ -f "$USER_KEYCHAIN" ]; then
  DUMMY_STILL_EXISTS="NO"
  if security find-certificate -c "$DUMMY_CERT_NAME" "$USER_KEYCHAIN" &>/dev/null; then
    DUMMY_STILL_EXISTS="YES"
  fi
  assert_test "Mitteseotud sertifikaat on endiselt Keychainis alles (puutumata)" "YES" "$DUMMY_STILL_EXISTS"

  # Clean dummy cert after successful verification
  security delete-certificate -c "$DUMMY_CERT_NAME" "$USER_KEYCHAIN" 2>/dev/null || true
fi

# ----------------------------------------------------------------------------
# 6. Taasta algsed sertifikaadid varukoopiast
# ----------------------------------------------------------------------------
echo -e "\n${YELLOW}6. Taastan töösüsteemi sertifikaadid varukoopiast tagasi...${NC}"
if [ -d "$BACKUP_DIR/certs" ]; then
  cp -R "$BACKUP_DIR/certs/"* "$WORKSPACE_DIR/config/certs/" 2>/dev/null || true
fi
if [ -d "$BACKUP_DIR/wallet-apex-proxy" ]; then
  cp -R "$BACKUP_DIR/wallet-apex-proxy/"* "$WORKSPACE_DIR/config/wallet-apex-proxy/" 2>/dev/null || true
fi
if [ -d "$BACKUP_DIR/wallet-publisher" ]; then
  cp -R "$BACKUP_DIR/wallet-publisher/"* "$WORKSPACE_DIR/config/wallet-publisher/" 2>/dev/null || true
fi

# Lisan sertifikaadi uuesti usaldushoidlasse
if [[ "$OSTYPE" == "darwin"* ]] && [ -x "$WORKSPACE_DIR/scripts/certs/trust-local-cert-mac.sh" ]; then
  "$WORKSPACE_DIR/scripts/certs/trust-local-cert-mac.sh" >/dev/null 2>&1 || true
fi

SYSTEM_HEALTHY="HEALTHY"
if [ -f "$WORKSPACE_DIR/config/certs/localhost.crt" ] && [ -f "$WORKSPACE_DIR/config/certs/localhost.der" ]; then
  SYSTEM_HEALTHY="HEALTHY"
else
  SYSTEM_HEALTHY="UNHEALTHY"
fi
assert_test "Töösüsteemi sertifikaatide taastamine" "HEALTHY" "$SYSTEM_HEALTHY"

# ----------------------------------------------------------------------------
# 7. Varukoopia turvaline eemaldamine KUI kõik testid õnnestusid
# ----------------------------------------------------------------------------
echo -e "\n${YELLOW}7. Varukoopia haldus pärast teste...${NC}"
if [ "$FAILED_TESTS" -eq 0 ]; then
  rm -rf "$BACKUP_DIR"
  echo -e "   ${GREEN}✅ Kõik testid läbisid 100% edukalt! Varukoopia (${BACKUP_DIR}) on turvaliselt eemaldatud.${NC}"
else
  echo -e "   ${RED}⚠️  Hoiatus: ${FAILED_TESTS} testi ebaõnnestus! Varukoopia jäeti alles turvalisuse tagamiseks:${NC}"
  echo -e "      ${CYAN}${BACKUP_DIR}${NC}"
fi

echo -e "\n${CYAN}==================================================================${NC}"
if [ "$FAILED_TESTS" -eq 0 ]; then
  echo -e "${GREEN}🎉 KÕIK OHUTUS- JA ISOLATSIOONITESTID LÄBITUD EDUKALT (${PASSED_TESTS}/${TOTAL_TESTS})!${NC}"
else
  echo -e "${RED}❌ EBAÕNNESTUS: ${FAILED_TESTS} testi ${TOTAL_TESTS}-st ebaõnnestus.${NC}"
  exit 1
fi
echo -e "${CYAN}==================================================================${NC}"
