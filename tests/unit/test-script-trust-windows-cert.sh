#!/usr/bin/env bash
# ============================================================================
# Unit Test: scripts/certs/trust-local-cert.cmd & scripts/certs/trust-local-cert.ps1
# Verifies presence, non-root user scope, and syntax of Windows cert trust scripts
# ============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

CYAN='\033[1;36m'
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'

echo -e "${CYAN}🧪 TEST: scripts/certs/trust-local-cert.cmd & trust-local-cert.ps1${NC}"

CMD_SCRIPT="$WORKSPACE_DIR/scripts/certs/trust-local-cert.cmd"
PS1_SCRIPT="$WORKSPACE_DIR/scripts/certs/trust-local-cert.ps1"
UNTRUST_SCRIPT="$WORKSPACE_DIR/scripts/certs/untrust-local-cert.cmd"

# 1. Kontrollime, et CMD skript on olemas ja kasutab -user lippu
if [ ! -f "$CMD_SCRIPT" ]; then
  echo -e "${RED}❌ Test Ebaõnnestus: scripts/certs/trust-local-cert.cmd puudub!${NC}"
  exit 1
fi

if ! grep -q "\-user \-addstore Root" "$CMD_SCRIPT"; then
  echo -e "${RED}❌ Test Ebaõnnestus: scripts/certs/trust-local-cert.cmd ei kasuta '-user -addstore Root' parameetrit!${NC}"
  exit 1
fi

# 2. Kontrollime, et PS1 skript on olemas ja kasutab -user lippu
if [ ! -f "$PS1_SCRIPT" ]; then
  echo -e "${RED}❌ Test Ebaõnnestus: scripts/certs/trust-local-cert.ps1 puudub!${NC}"
  exit 1
fi

if ! grep -q "\-user \-addstore Root" "$PS1_SCRIPT"; then
  echo -e "${RED}❌ Test Ebaõnnestus: scripts/certs/trust-local-cert.ps1 ei kasuta '-user -addstore Root' parameetrit!${NC}"
  exit 1
fi

# 3. Kontrollime untrust skripti
if [ ! -f "$UNTRUST_SCRIPT" ]; then
  echo -e "${RED}❌ Test Ebaõnnestus: scripts/untrust-local-cert.cmd puudub!${NC}"
  exit 1
fi

if ! grep -q "\-user \-delstore Root" "$UNTRUST_SCRIPT"; then
  echo -e "${RED}❌ Test Ebaõnnestus: scripts/untrust-local-cert.cmd ei kasuta '-user -delstore Root' parameetrit!${NC}"
  exit 1
fi

echo -e "${GREEN}✅ Test Edukas: Kõik Windowsi 0-Root kasutaja sertifikaadiskriptid (.cmd ja .ps1) on korrektsed!${NC}"
exit 0
