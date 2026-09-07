#!/usr/bin/env bash
# ============================================================================
# Unit Test: scripts/certs/trust-local-cert-mac.sh & scripts/untrust-local-cert-mac.sh
# Verifies presence, non-root user scope, and syntax of macOS cert trust scripts
# ============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

CYAN='\033[1;36m'
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'

echo -e "${CYAN}🧪 TEST: scripts/certs/trust-local-cert-mac.sh & untrust-local-cert-mac.sh${NC}"

MAC_SCRIPT="$WORKSPACE_DIR/scripts/certs/trust-local-cert-mac.sh"
UNTRUST_SCRIPT="$WORKSPACE_DIR/scripts/certs/untrust-local-cert-mac.sh"

# 1. Verify that macOS trust script exists and bash syntax is valid
if [ ! -f "$MAC_SCRIPT" ]; then
  echo -e "${RED}❌ Test Ebaõnnestus: scripts/certs/trust-local-cert-mac.sh puudub!${NC}"
  exit 1
fi
bash -n "$MAC_SCRIPT"

if grep -q "sudo " "$MAC_SCRIPT"; then
  echo -e "${RED}❌ Test Ebaõnnestus: scripts/certs/trust-local-cert-mac.sh ei tohi sisaldada sudo käsku!${NC}"
  exit 1
fi

# 2. Verify macOS untrust script
if [ ! -f "$UNTRUST_SCRIPT" ]; then
  echo -e "${RED}❌ Test Ebaõnnestus: scripts/untrust-local-cert-mac.sh puudub!${NC}"
  exit 1
fi
bash -n "$UNTRUST_SCRIPT"

echo -e "${GREEN}✅ Test Edukas: Kõik macOS 0-Root kasutaja sertifikaadiskriptid (.sh) on korrektsed!${NC}"
exit 0
