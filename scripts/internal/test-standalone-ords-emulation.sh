#!/usr/bin/env bash
# ============================================================================
# Standalone ORDS Server Emulation Script
# Simulates a separate dedicated Linux ORDS Server in an isolated Podman container
# Usage: ./scripts/test-standalone-ords-emulation.sh
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ -f "$SCRIPT_DIR/internal/common.sh" ]; then
  source "$SCRIPT_DIR/internal/common.sh"
elif [ -f "$SCRIPT_DIR/common.sh" ]; then
  source "$SCRIPT_DIR/common.sh"
else
  GREEN=$'\033[1;32m'
  RED=$'\033[1;31m'
  YELLOW=$'\033[0;33m'
  CYAN=$'\033[1;36m'
  NC=$'\033[0m'
fi

EMULATOR_CONTAINER="ords-standalone-emulator"

echo -e "${CYAN}==================================================================${NC}"
echo -e "🚀 ERALDISEISVA STANDALONE ORDS SERVERI EMULEERIMINE (PODMAN)"
echo -e "${CYAN}==================================================================${NC}"

# 1. Detect active database container (pub-db or db-apex-proxy)
ACTIVE_DB=""
if podman container exists pub-db 2>/dev/null; then
  ACTIVE_DB="pub-db"
elif podman container exists db-apex-proxy 2>/dev/null; then
  ACTIVE_DB="db-apex-proxy"
fi

if [ -z "$ACTIVE_DB" ]; then
  echo -e "${YELLOW}⚠️  No active database container found.${NC}"
  echo -e "🚀 Starting containers without local ORDS (--no-ords)..."
  "$SCRIPT_DIR/start-containers.sh" --no-ords
  if podman container exists pub-db 2>/dev/null; then
    ACTIVE_DB="pub-db"
  elif podman container exists db-apex-proxy 2>/dev/null; then
    ACTIVE_DB="db-apex-proxy"
  fi
fi

# Resolve target database container network IP address
DB_IP=$(podman inspect "$ACTIVE_DB" --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' 2>/dev/null || echo "")
[ -z "$DB_IP" ] && DB_IP="$ACTIVE_DB"

# Query SYS and ORDS listener passwords securely from Podman secret store
SYS_PWD=$(podman secret inspect --showsecret apex_db_sys_password 2>/dev/null | jq -r '.[0].SecretData' 2>/dev/null || true)
[ -z "$SYS_PWD" ] && SYS_PWD=$(podman secret inspect --showsecret publisher_db_sys_password 2>/dev/null | jq -r '.[0].SecretData' 2>/dev/null || true)
[ -z "$SYS_PWD" ] && SYS_PWD=$(podman secret inspect --showsecret pub_db_db_sys_password 2>/dev/null | jq -r '.[0].SecretData' 2>/dev/null || true)

LISTENER_PWD=$(podman secret inspect --showsecret ords_listener_password 2>/dev/null | jq -r '.[0].SecretData' 2>/dev/null || echo "OrdsListener#2026")

echo -e "🎯 Active Target Database: ${GREEN}${ACTIVE_DB}${NC} (IP: ${CYAN}${DB_IP}${NC})"

# 2. Clean up previous emulator container if existing
echo -e "\n${YELLOW}1/4 🧹 Cleaning up previous emulator container...${NC}"
podman rm -f "$EMULATOR_CONTAINER" 2>/dev/null || true

# 3. Launch fresh isolated Linux server container (Ubuntu 22.04)
echo -e "\n${YELLOW}2/4 🖥️ Starting standalone Linux server container ('$EMULATOR_CONTAINER')...${NC}"
podman run -d --name "$EMULATOR_CONTAINER" \
  -v "$WORKSPACE_DIR:/workspace:rw" \
  -p 8080:8080 \
  ubuntu:22.04 sleep infinity >/dev/null

# 4. Run Standalone ORDS installation in emulator container
echo -e "\n${YELLOW}3/4 📦 Installing and configuring Standalone ORDS in Linux container...${NC}"
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

# 5. Launch ORDS standalone web server in background
echo -e "\n${YELLOW}4/4 🚀 Starting ORDS standalone web server in emulator container...${NC}"
podman exec -d "$EMULATOR_CONTAINER" bash -c "
  /opt/ords/bin/ords --config /etc/ords/config serve
"

echo -e "\n${YELLOW}🔍 Verifying emulated ORDS service (http://localhost:8080/ords/)...${NC}"
STATUS="000"
for i in {1..20}; do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080/ords/" 2>/dev/null || echo "000")
  if [ "$STATUS" = "200" ] || [ "$STATUS" = "301" ] || [ "$STATUS" = "302" ]; then
    break
  fi
  sleep 2
done

if [ "$STATUS" = "200" ] || [ "$STATUS" = "301" ] || [ "$STATUS" = "302" ]; then
  echo -e "${GREEN}✅ STANDALONE ORDS SERVER EMULATED SUCCESSFULLY (HTTP $STATUS)!${NC}"
  echo -e "👉 Kontrolli brauseris: ${CYAN}http://localhost:8080/ords/${NC}"
  echo -e "👉 APEX Tööruum:       ${CYAN}http://localhost:8080/ords/apex${NC}"
else
  echo -e "${RED}⚠️  Hoiatus: Emuleeritud ORDS liides vastas koodiga HTTP $STATUS.${NC}"
fi

echo -e "${CYAN}==================================================================${NC}"
