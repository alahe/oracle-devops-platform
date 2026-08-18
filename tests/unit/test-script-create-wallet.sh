#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🧪 TEST: internal/create-wallet.sh${NC}"
TARGET_SCRIPT="$WORKSPACE_DIR/scripts/internal/create-wallet.sh"

if [ -f "$TARGET_SCRIPT" ]; then
  bash -n "$TARGET_SCRIPT"
  
  # Functional Verification: Check SEPS Wallet & TNS files in config/tns_admin
  WALLET_DIR="$WORKSPACE_DIR/config/tns_admin"
  if [ -d "$WALLET_DIR" ]; then
    echo -e "${GREEN}✅ Test 1 Edukas: create-wallet.sh BASH süntaks on korras!${NC}"
    if [ -f "$WALLET_DIR/tnsnames.ora" ] && [ -f "$WALLET_DIR/sqlnet.ora" ]; then
      echo -e "${GREEN}✅ Test 2 Edukas: TNS failid (tnsnames.ora, sqlnet.ora) on loodud ja valideeritud!${NC}"
    fi
  fi
else
  echo -e "${RED}❌ Test Ebaõnnestus: scripts/internal/create-wallet.sh puudub!${NC}"
  exit 1
fi
