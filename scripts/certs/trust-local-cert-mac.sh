#!/usr/bin/env bash
# ============================================================================
# Oracle DevOps Platform - macOS User Certificate Installer
# Lisab kohaliku Dev Root CA macOS kasutaja võtmehoidjasse (login.keychain).
# Toimib 100% tavakasutaja õigustes (0-Root / No Sudo).
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
echo -e "${CYAN}🍎 ORACLE DEVOPS PLATFORM - SERTIFIKAADI USALDAMINE (macOS)${NC}"
echo -e "${CYAN}==================================================================${NC}"

if [ ! -f "$CERT_FILE" ]; then
  echo -e "${RED}[VIGA] Sertifikaati ei leitud asukohast: $CERT_FILE${NC}"
  echo "Palun käivita esmalt keskkonna seadistus: ./scripts/setup-all.sh"
  exit 1
fi

USER_KEYCHAIN="$HOME/Library/Keychains/login.keychain-db"
[ ! -f "$USER_KEYCHAIN" ] && USER_KEYCHAIN="$HOME/Library/Keychains/login.keychain"

echo -e "${YELLOW}[INFO] Lisame sertifikaadi macOS kasutaja võtmehoidjasse: ${USER_KEYCHAIN}${NC}"
security add-certificate -k "$USER_KEYCHAIN" "$CERT_FILE" 2>/dev/null || true

if security find-certificate -c "Local Dev Root CA" "$USER_KEYCHAIN" &>/dev/null; then
  echo ""
  echo -e "${GREEN}==================================================================${NC}"
  echo -e "${GREEN}✅ [EDUKAS] 'Local Dev Root CA' on lisatud kasutaja võtmehoidjasse!${NC}"
  echo -e "${GREEN}   (User Space, 0-Root / No Sudo)${NC}"
  echo -e "${GREEN}==================================================================${NC}"
else
  echo -e "${RED}⚠️  Hoiatus: Sertifikaadi lisamist ei õnnestunud automaatselt kinnitada.${NC}"
fi
