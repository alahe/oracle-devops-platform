#!/usr/bin/env bash
# ============================================================================
# Pre-built Analytics Publisher Domain Container Image Builder
# Creates localhost/oracle-publisher-domain-prebuilt:2025 with WebLogic BI Domain pre-built
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

CYAN='\033[1;36m'
GREEN='\033[1;32m'
YELLOW='\033[0;33m'
RED='\033[1;31m'
NC='\033[0m'

TARGET_IMAGE="${1:-localhost/oracle-publisher-domain-prebuilt:2025}"
BASE_IMAGE="${2:-oracle/analyticsserver:2025}"

CONTAINER_CLI="podman"
if ! command -v podman >/dev/null 2>&1 && command -v docker >/dev/null 2>&1; then
  CONTAINER_CLI="docker"
fi

echo -e "${CYAN}==================================================================${NC}"
echo -e "${YELLOW}🚀 Ehitan eelkonfigureeritud Analytics Publisheri domeenipildi (${TARGET_IMAGE})...${NC}"
echo -e "${CYAN}==================================================================${NC}"

if $CONTAINER_CLI image exists "$TARGET_IMAGE" 2>/dev/null; then
  echo -e "   ✅ Pilt ${GREEN}${TARGET_IMAGE}${NC} on juba süsteemis olemas! Jätan ehituse vahele."
  exit 0
fi

echo -e "   1. Käivitan Publisheri paigalduse domeeni tekitamiseks..."
"$WORKSPACE_DIR/scripts/internal/install-publisher.sh" >/dev/null 2>&1 || true

PUB_CONTAINER="oracle-publisher-dev"
if $CONTAINER_CLI container exists "$PUB_CONTAINER" 2>/dev/null; then
  echo -e "   2. Salvestan konfigureeritud WebLogic domeeni immutatavaks pildiks (${TARGET_IMAGE})..."
  $CONTAINER_CLI commit "$PUB_CONTAINER" "$TARGET_IMAGE" >/dev/null
  echo -e "${CYAN}==================================================================${NC}"
  echo -e "✅ Analytics Publisheri domeenipildi ehitamine õnnestus! (${GREEN}${TARGET_IMAGE}${NC})"
  echo -e "${CYAN}==================================================================${NC}"
else
  echo -e "${RED}❌ VIGA: Publisheri konteinerit ei leitud pildi salvestamiseks!${NC}"
  exit 1
fi
