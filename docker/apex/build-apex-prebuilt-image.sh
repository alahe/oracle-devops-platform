#!/usr/bin/env bash
# ============================================================================
# Pre-built APEX Container Image Builder
# Creates localhost/oracle-free-apex:26.2 with Oracle DB 23ai + APEX 26.2 pre-installed
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

CYAN='\033[1;36m'
GREEN='\033[1;32m'
YELLOW='\033[0;33m'
RED='\033[1;31m'
NC='\033[0m'

TARGET_IMAGE="${1:-localhost/oracle-free-apex:26.2}"
BASE_IMAGE="${2:-docker.io/gvenzl/oracle-free:23-full-faststart}"

CONTAINER_CLI="podman"
if ! command -v podman >/dev/null 2>&1 && command -v docker >/dev/null 2>&1; then
  CONTAINER_CLI="docker"
fi

echo -e "${CYAN}==================================================================${NC}"
echo -e "${YELLOW}🚀 Ehitan eelkonfigureeritud APEX 26.2 konteineripildi (${TARGET_IMAGE})...${NC}"
echo -e "${CYAN}==================================================================${NC}"

if $CONTAINER_CLI image exists "$TARGET_IMAGE" 2>/dev/null; then
  echo -e "   ✅ Pilt ${GREEN}${TARGET_IMAGE}${NC} on juba süsteemis olemas! Jätan ehituse vahele."
  exit 0
fi

TEMP_CONTAINER="apex-builder-temp"
$CONTAINER_CLI rm -f "$TEMP_CONTAINER" 2>/dev/null || true

echo -e "   1. Käivitan ajutise FastStart DB konteineri (${BASE_IMAGE})..."
$CONTAINER_CLI run -d --name "$TEMP_CONTAINER" \
  -e ORACLE_PASSWORD=OraclePass2026Sys! \
  -e ORACLE_FREE_FASTSTART=true \
  "$BASE_IMAGE" >/dev/null

echo -e "   2. Ootan andmebaasi valmisolekut (healthy)..."
COUNT=0
until [ "$($CONTAINER_CLI inspect --format='{{.State.Health.Status}}' "$TEMP_CONTAINER" 2>/dev/null)" == "healthy" ] || [ $COUNT -ge 120 ]; do
  sleep 2
  COUNT=$((COUNT + 2))
done

if [ "$($CONTAINER_CLI inspect --format='{{.State.Health.Status}}' "$TEMP_CONTAINER" 2>/dev/null)" != "healthy" ]; then
  echo -e "${RED}❌ VIGA: Ajutine baas ei saavutanud valmisolekut!${NC}"
  $CONTAINER_CLI rm -f "$TEMP_CONTAINER" 2>/dev/null || true
  exit 1
fi

echo -e "   3. Paigaldan APEX 26.2 mootori konteineri sisse..."
SYS_PWD="OraclePass2026Sys!" "$WORKSPACE_DIR/scripts/internal/install-apex.sh" --db "$TEMP_CONTAINER" --version "26.2" >/dev/null 2>&1 || true

echo -e "   4. Salvestan konteineri oleku immutatavaks pildiks (${TARGET_IMAGE})..."
$CONTAINER_CLI commit "$TEMP_CONTAINER" "$TARGET_IMAGE" >/dev/null

echo -e "   5. Puhastan ajutise ehituskonteineri..."
$CONTAINER_CLI rm -f "$TEMP_CONTAINER" 2>/dev/null || true

echo -e "${CYAN}==================================================================${NC}"
echo -e "✅ APEX 26.2 pildi ehitamine õnnestus! (${GREEN}${TARGET_IMAGE}${NC})"
echo -e "${CYAN}==================================================================${NC}"
