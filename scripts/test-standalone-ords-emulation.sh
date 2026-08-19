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

# 1. Tuvasta aktiivne andmebaasi konteiner (pub-db või db-apex-proxy)
ACTIVE_DB=""
if podman container exists pub-db 2>/dev/null; then
  ACTIVE_DB="pub-db"
elif podman container exists db-apex-proxy 2>/dev/null; then
  ACTIVE_DB="db-apex-proxy"
fi

if [ -z "$ACTIVE_DB" ]; then
  echo -e "${YELLOW}⚠️  Ühtegi aktiivset andmebaasi konteinerit ei leitud.${NC}"
  echo -e "🚀 Käivitan konteinerid ilma lokaalse ORDS-ita (--no-ords)..."
  "$SCRIPT_DIR/start-containers.sh" --no-ords
  if podman container exists pub-db 2>/dev/null; then
    ACTIVE_DB="pub-db"
  elif podman container exists db-apex-proxy 2>/dev/null; then
    ACTIVE_DB="db-apex-proxy"
  fi
fi

# Tuvastame sihtandmebaasi võrgu IP
DB_IP=$(podman inspect "$ACTIVE_DB" --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' 2>/dev/null || echo "")
[ -z "$DB_IP" ] && DB_IP="$ACTIVE_DB"

# Pärime turvaliselt SYS ja ORDS listener paroolid Podman secret store'ist
SYS_PWD=$(podman secret inspect --showsecret apex_db_sys_password 2>/dev/null | jq -r '.[0].SecretData' 2>/dev/null || true)
[ -z "$SYS_PWD" ] && SYS_PWD=$(podman secret inspect --showsecret publisher_db_sys_password 2>/dev/null | jq -r '.[0].SecretData' 2>/dev/null || true)
[ -z "$SYS_PWD" ] && SYS_PWD=$(podman secret inspect --showsecret pub_db_db_sys_password 2>/dev/null | jq -r '.[0].SecretData' 2>/dev/null || true)

LISTENER_PWD=$(podman secret inspect --showsecret ords_listener_password 2>/dev/null | jq -r '.[0].SecretData' 2>/dev/null || echo "OrdsListener#2026")

echo -e "🎯 Aktiivne Sihtandmebaas: ${GREEN}${ACTIVE_DB}${NC} (IP: ${CYAN}${DB_IP}${NC})"

# 2. Puhasta vana emulaatori konteiner kui see on olemas
echo -e "\n${YELLOW}1/4 🧹 Puhastan eelmise emulaatori konteineri...${NC}"
podman rm -f "$EMULATOR_CONTAINER" 2>/dev/null || true

# 3. Käivita puhas isoleeritud Linux serveri konteiner (Ubuntu 22.04)
echo -e "\n${YELLOW}2/4 🖥️ Käivitan eraldiseisva Linux serveri konteineri ('$EMULATOR_CONTAINER')...${NC}"
podman run -d --name "$EMULATOR_CONTAINER" \
  -v "$WORKSPACE_DIR:/workspace:rw" \
  -p 8080:8080 \
  ubuntu:22.04 sleep infinity >/dev/null

# 4. Käivita Standalone ORDS paigaldus emulaatori konteineris
echo -e "\n${YELLOW}3/4 📦 Installeerin ja konfigureerin ORDS Standalone teenuse Linux konteineris...${NC}"
podman exec -i "$EMULATOR_CONTAINER" bash -c "
  apt-get update >/dev/null 2>&1 &&
  apt-get install -y openjdk-17-jre-headless zip unzip wget curl ca-certificates >/dev/null 2>&1 &&
  export DB_HOST=${DB_IP} &&
  export DB_PORT=1521 &&
  export DB_SERVICE=FREEPDB1 &&
  export APEX_DB_SYS_PASSWORD='${SYS_PWD}' &&
  export APEX_LISTENER_PASSWORD='${LISTENER_PWD}' &&
  chmod +x /workspace/scripts/internal/install-ords-standalone.sh &&
  /workspace/scripts/internal/install-ords-standalone.sh
"

# 5. Käivita ORDS standalone veebiserver taustal
echo -e "\n${YELLOW}4/4 🚀 Käivitan ORDS standalone veebiserveri emulaator-konteineris...${NC}"
podman exec -d "$EMULATOR_CONTAINER" bash -c "
  /opt/ords/bin/ords --config /etc/ords/config serve
"

echo -e "\n${YELLOW}🔍 Kontrollin emuleeritud ORDS teenust (http://localhost:8080/ords/)...${NC}"
STATUS="000"
for i in {1..20}; do
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
