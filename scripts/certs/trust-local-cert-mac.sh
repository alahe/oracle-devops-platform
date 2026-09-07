#!/usr/bin/env bash
# ============================================================================
# Oracle DevOps Platform - macOS User Certificate Installer
# Installs local Dev Root CA into current macOS user keychain (login.keychain).
# Runs 100% in user space without requiring root privileges.
# ============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
CERT_FILE="$WORKSPACE_DIR/config/certs/localCA.pem"

CYAN='\033[1;36m'
GREEN='\033[1;32m'
YELLOW='\033[0;33m'
RED='\033[1;31m'
NC='\033[0m'

echo -e "${CYAN}==================================================================${NC}"
echo -e "${CYAN}🍎 ORACLE DEVOPS PLATFORM - CERTIFICATE TRUST CONFIGURATION (macOS)${NC}"
echo -e "${CYAN}==================================================================${NC}"

if [ ! -f "$CERT_FILE" ]; then
  echo -e "${RED}[ERROR] Certificate not found at: $CERT_FILE${NC}"
  echo "Please run environment setup first: ./scripts/setup-all.sh"
  exit 1
fi

USER_KEYCHAIN="$HOME/Library/Keychains/login.keychain-db"
[ ! -f "$USER_KEYCHAIN" ] && USER_KEYCHAIN="$HOME/Library/Keychains/login.keychain"

if security verify-cert -c "$WORKSPACE_DIR/config/certs/localhost.crt" &>/dev/null; then
  echo -e "${GREEN}✅ 'Local Dev Root CA' and localhost certificate are already trusted in macOS system. Continuing.${NC}"
  exit 0
elif security find-certificate -c "Local Dev Root CA" "$USER_KEYCHAIN" &>/dev/null; then
  echo -e "${GREEN}✅ 'Local Dev Root CA' is already added to macOS user keychain (${USER_KEYCHAIN}). Continuing.${NC}"
  exit 0
fi

if [ "${SKIP_CERT_TRUST:-false}" = "true" ] || [ "${IS_TEST_MODE:-false}" = "true" ] || [ ! -t 0 ]; then
  echo -e "${YELLOW}ℹ️  [TEST_MODE] Automated testing or background mode: skipping interactive macOS keychain trust.${NC}"
  echo -e "${YELLOW}   (Using direct certificate file: ${CERT_FILE})${NC}"
  exit 0
fi

echo -e "${YELLOW}[INFO] Adding certificate to macOS user keychain: ${USER_KEYCHAIN}${NC}"
security add-trusted-cert -r trustRoot -p ssl -k "$USER_KEYCHAIN" "$CERT_FILE" 2>/dev/null || security add-trusted-cert -d -r trustRoot -k "$USER_KEYCHAIN" "$CERT_FILE" 2>/dev/null || security add-certificate -k "$USER_KEYCHAIN" "$CERT_FILE" 2>/dev/null || true

if security verify-cert -c "$WORKSPACE_DIR/config/certs/localhost.crt" &>/dev/null || security find-certificate -c "Local Dev Root CA" "$USER_KEYCHAIN" &>/dev/null; then
  echo ""
  echo -e "${GREEN}==================================================================${NC}"
  echo -e "${GREEN}✅ [SUCCESS] 'Local Dev Root CA' trusted in macOS keychain!${NC}"
  echo -e "${GREEN}   (User Space, 0-Root / No Sudo)${NC}"
  echo -e "${GREEN}==================================================================${NC}"
else
  echo -e "${RED}⚠️  Warning: Certificate addition could not be automatically verified.${NC}"
fi
