#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🧪 TEST: internal/generate-local-certs.sh${NC}"
TARGET_SCRIPT="$WORKSPACE_DIR/scripts/internal/generate-local-certs.sh"

if [ -f "$TARGET_SCRIPT" ]; then
  bash -n "$TARGET_SCRIPT"
  
  # Verify that the script contains certificate validity checks (checkend) without unnecessary regenerations
  if grep -q "is_cert_valid" "$TARGET_SCRIPT" && grep -q "openssl x509 -checkend" "$TARGET_SCRIPT"; then
    echo -e "${GREEN}✅ Test Edukas: generate-local-certs.sh sisaldab intelligentset kehtivuskontrolli (is_cert_valid)!${NC}"
  else
    echo -e "${RED}❌ Test Ebaõnnestus: is_cert_valid kehtivuskontroll puudub!${NC}"
    exit 1
  fi
else
  echo -e "${RED}❌ Test Ebaõnnestus: scripts/internal/generate-local-certs.sh puudub!${NC}"
  exit 1
fi
