#!/usr/bin/env bash
# ============================================================================
# Standalone ORDS Server Emulation Script
# Simulates a separate dedicated Linux ORDS Server in an isolated Podman container
# Usage: ./scripts/test-standalone-ords-emulation.sh
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

EMULATOR_CONTAINER="ords-standalone-emulator"

echo -e "${CYAN}==================================================================${NC}"
echo -e "🚀 ERALDISEISVA STANDALONE ORDS SERVERI EMULEERIMINE (PODMAN)"
echo -e "${CYAN}==================================================================${NC}"

# 1. Veendu, et andmebaasi konteiner jookseb
if ! podman container exists db-apex-proxy 2>/dev/null; then
  echo -e "${YELLOW}⚠️  Andmebaasi konteiner 'db-apex-proxy' ei jookse.${NC}"
  echo -e "🚀 Käivitan andmebaasi paigalduse ilma lokaalse ORDS-ita (--no-ords)..."
  "$SCRIPT_DIR/setup-all.sh" --no-ords
fi

# 2. Puhasta vana emulaatori konteiner kui see on olemas
echo -e "\n${YELLOW}1/4 🧹 Puhastan eelmise emulaatori konteineri...${NC}"
podman rm -f "$EMULATOR_CONTAINER" 2>/dev/null || true

# 3. Käivita puhas isoleeritud Linux serveri konteiner (Ubuntu 22.04)
echo -e "\n${YELLOW}2/4 🖥️ Käivitan eraldiseisva Linux serveri konteineri ('$EMULATOR_CONTAINER')...${NC}"
podman run -d --name "$EMULATOR_CONTAINER" \
  --pod pod_oracle-free-db-in-prod \
  -v "$WORKSPACE_DIR:/workspace:rw" \
  -p 8080:8080 \
  ubuntu:22.04 sleep infinity >/dev/null

# 4. Käivita Standalone ORDS paigaldus emulaatori konteineris
echo -e "\n${YELLOW}3/4 📦 Installeerin ja konfigureerin ORDS Standalone teenuse Linux konteineris...${NC}"
podman exec -i "$EMULATOR_CONTAINER" bash -c "
  apt-get update >/dev/null 2>&1 &&
  apt-get install -y openjdk-17-jre-headless zip unzip wget curl ca-certificates >/dev/null 2>&1 &&
  export DB_HOST=db-apex-proxy &&
  export DB_PORT=1521 &&
  export DB_SERVICE=FREEPDB1 &&
  chmod +x /workspace/scripts/internal/install-ords-standalone.sh &&
  /workspace/scripts/internal/install-ords-standalone.sh
"

# 5. Kontrolli emuleeritud ORDS teenuse kättesaadavust
echo -e "\n${YELLOW}4/4 🔍 Kontrollin emuleeritud ORDS teenust (http://localhost:8080/ords/)...${NC}"
STATUS="000"
for i in {1..15}; do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080/ords/" 2>/dev/null || echo "000")
  if [ "$STATUS" = "200" ] || [ "$STATUS" = "301" ] || [ "$STATUS" = "302" ]; then
    break
  fi
  sleep 2
done

if [ "$STATUS" = "200" ] || [ "$STATUS" = "301" ] || [ "$STATUS" = "302" ]; then
  echo -e "${GREEN}✅ ERALDISEISEV STANDALONE ORDS SERVER EMULEERITUD EDUKALT (HTTP $STATUS)!${NC}"
  echo -e "👉 Kontrolli brauseris: ${CYAN}http://localhost:8080/ords/${NC}"
  echo -e "👉 APEX Tööruum:       ${CYAN}http://localhost:8080/ords/apex${NC}"
else
  echo -e "${RED}⚠️  Hoiatus: Emuleeritud ORDS liides vastas koodiga HTTP $STATUS.${NC}"
fi

echo -e "${CYAN}==================================================================${NC}"
