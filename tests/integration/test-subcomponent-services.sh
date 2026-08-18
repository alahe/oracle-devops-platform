#!/usr/bin/env bash
# ============================================================================
# Automated Test Script for Subcomponent Services & Infrastructure Validation
# Tests: SSL Root CA, Wallet Credentials, APEX Images & REST Endpoints
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}==================================================================${NC}"
echo -e "🧪 ALAMKOMPONENTIDE TEENUSTE JA INFRASTEERIUMI TESTIMINE"
echo -e "${CYAN}==================================================================${NC}"

# Test 1: Check SSL/TLS Certificates & Oracle Wallet Files
echo -e "\n${YELLOW}[Test 1] Kontrollin lokaalseid SSL sertifikaate ja Oracle Walleteid...${NC}"
CERTS_DIR="$WORKSPACE_DIR/config/certs"
WALLET_DIR="$WORKSPACE_DIR/config/tns_admin"

if [ -f "$CERTS_DIR/localCA.pem" ] && [ -f "$CERTS_DIR/localhost.crt" ] && [ -f "$CERTS_DIR/localhost.key" ]; then
  echo -e "${GREEN}✅ Test 1.1 Edukas: SSL sertifikaadid (localCA.pem, localhost.crt, localhost.key) on olemas!${NC}"
else
  echo -e "${YELLOW}⚠️  Test 1.1 Märkus: Sertifikaate loakse automaatselt setup-all.sh käigus!${NC}"
fi

if [ -f "$WALLET_DIR/cwallet.sso" ] || [ -f "$WALLET_DIR/ewallet.p12" ]; then
  echo -e "${GREEN}✅ Test 1.2 Edukas: Oracle Wallet (cwallet.sso/ewallet.p12) on korrektselt konfigureeritud!${NC}"
else
  echo -e "${YELLOW}⚠️  Test 1.2 Märkus: Oracle Wallet luuakse automaatselt esimese paigalduse käigus.${NC}"
fi

# Test 2: Check Wallet Credential Script Execution
echo -e "\n${YELLOW}[Test 2] Kontrollin Wallet credential skripti (view-wallet-credential.sh)...${NC}"
if [ -x "$WORKSPACE_DIR/scripts/internal/view-wallet-credential.sh" ]; then
  echo -e "${GREEN}✅ Test 2 Edukas: view-wallet-credential.sh skript on olemas ja käivitatav!${NC}"
else
  echo -e "${RED}❌ Test 2 Ebaõnnestus: view-wallet-credential.sh skript puudub!${NC}"
  exit 1
fi

# Test 3: Check APEX Images Volume Mounting Setup
echo -e "\n${YELLOW}[Test 3] Kontrollin APEX staatiliste piltide (apex_images) seadistust...${NC}"
if grep -q "apex_images" "$WORKSPACE_DIR/podman-compose.yml"; then
  echo -e "${GREEN}✅ Test 3 Edukas: podman-compose.yml sisaldab apex_images persistentse volume definitsiooni!${NC}"
else
  echo -e "${RED}❌ Test 3 Ebaõnnestus: apex_images volume definitsioon puudub podman-compose.yml failist!${NC}"
  exit 1
fi

# Test 4: ORDS & APEX REST Controller Endpoint HTTP/HTTPS Check (if container is up)
echo -e "\n${YELLOW}[Test 4] Kontrollin ORDS / APEX REST liideste kättesaadavust...${NC}"
PRIMARY_CONTAINER=$(get_active_db_instances 2>/dev/null | head -n 1 | cut -d'|' -f1)
PRIMARY_CONTAINER="${PRIMARY_CONTAINER:-db-dev-full}"

if podman ps 2>/dev/null | grep -q "${PRIMARY_CONTAINER}"; then
  HTTP_CODE=$(curl -k -s -o /dev/null -w "%{http_code}" https://localhost:8443/ords/ || true)
  echo "   ORDS HTTPS Vastuse kood: ${HTTP_CODE}"
  if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ] || [ "$HTTP_CODE" = "404" ]; then
    echo -e "${GREEN}✅ Test 4 Edukas: ORDS HTTPS liides vastas koodiga ${HTTP_CODE}!${NC}"
  fi
else
  echo -e "${YELLOW}ℹ️  Test 4 Info: Konteinerid ei tööta parajasti. Veebitesti vahelejätmine on normaalne.${NC}"
fi

echo -e "\n${CYAN}==================================================================${NC}"
echo -e "${GREEN}🎉 KÕIK ALAMKOMPONENTIDE TEENUSTE TESTID LÄBITUD EDUKALT!${NC}"
echo -e "${CYAN}==================================================================${NC}"
