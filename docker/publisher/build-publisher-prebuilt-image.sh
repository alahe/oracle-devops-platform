#!/usr/bin/env bash
# ============================================================================
# Pre-built Analytics Publisher Domain Container Image Builder (TASK-019)
# (docker/publisher/build-publisher-prebuilt-image.sh)
#
# Builds localhost/oracle-publisher-domain:2025-db23ai with the WebLogic BI
# domain (/u01/oracle/user_projects/domains/bi) and RCU datasources pre-baked.
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source common helpers
if [ -f "$WORKSPACE_DIR/scripts/internal/common.sh" ]; then
  source "$WORKSPACE_DIR/scripts/internal/common.sh"
else
  CYAN='\033[1;36m'
  GREEN='\033[1;32m'
  YELLOW='\033[0;33m'
  RED='\033[1;31m'
  BOLD='\033[1m'
  NC='\033[0m'
fi

BASE_IMAGE="oracle/analyticsserver:2025"
TARGET_IMAGE=""
DB_VER_ARG="23ai"
PUB_VER_ARG="2025"
FLAVOR_ARG=""

show_help() {
  cat << EOF
${CYAN}==================================================================${NC}
${BOLD}🏗️  Eelkonfigureeritud Publisher Domeenipildi Ehitaja (TASK-019)${NC}
${CYAN}==================================================================${NC}
Kasutus:
  ./docker/publisher/build-publisher-prebuilt-image.sh [VÕTMED]

Võtmed:
  -b, --base-image <IMG>    Lähtepilt (vaikimisi: oracle/analyticsserver:2025)
  -t, --target-image <IMG>  Sihtpildi täisnimi (kui soovitakse tag üle kirjutada)
      --pub-ver <VER>       Publisheri versioon (vaikimisi: 2025)
      --db-ver <VER>        Andmebaasi versioon (vaikimisi: 23ai)
      --flavor <NIMI>       Täiendav silditähis (nt: ocr, gvenzl)
  -h, --help                Kuvab selle abiteksti

Näide:
  ./docker/publisher/build-publisher-prebuilt-image.sh
EOF
}

# Parse CLI arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -b|--base-image)
      BASE_IMAGE="$2"
      shift
      ;;
    -t|--target-image)
      TARGET_IMAGE="$2"
      shift
      ;;
    --pub-ver)
      PUB_VER_ARG="$2"
      shift
      ;;
    --db-ver)
      DB_VER_ARG="$2"
      shift
      ;;
    --flavor)
      FLAVOR_ARG="$2"
      shift
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      echo -e "${RED}❌ Tundmatu parameeter: $1${NC}"
      show_help
      exit 1
      ;;
  esac
  shift
done

CONTAINER_CLI="podman"
if ! command -v podman >/dev/null 2>&1 && command -v docker >/dev/null 2>&1; then
  CONTAINER_CLI="docker"
fi

SEMANTIC_TAG="${PUB_VER_ARG}-db${DB_VER_ARG}"
[ -n "$FLAVOR_ARG" ] && SEMANTIC_TAG="${PUB_VER_ARG}-${FLAVOR_ARG}-db${DB_VER_ARG}"
CANONICAL_IMAGE="localhost/oracle-publisher-domain:${SEMANTIC_TAG}"

FINAL_TARGET="${TARGET_IMAGE:-$CANONICAL_IMAGE}"

echo -e "\n${CYAN}==================================================================${NC}"
echo -e "${BOLD}🚀 EHITAN EELKONFIGUREERITUD PUBLISHER DOMEENIPILDI (TASK-019)${NC}"
echo -e "${CYAN}==================================================================${NC}"
echo -e "   ├─ 📦 ${BOLD}Lähtepilt:${NC}          ${BASE_IMAGE}"
echo -e "   ├─ 🏷️  ${BOLD}Sihtmärgis:${NC}        ${FINAL_TARGET}"
echo -e "   └─ ⚙️  ${BOLD}Konteineri mootor:${NC}  ${CONTAINER_CLI}"
echo -e "${CYAN}==================================================================${NC}\n"

if $CONTAINER_CLI image exists "$FINAL_TARGET" 2>/dev/null; then
  echo -e "   ✅ Pilt ${GREEN}${FINAL_TARGET}${NC} on juba süsteemis olemas! Jätan ehituse vahele."
  exit 0
fi

echo -e "   1. Käivitan Publisheri paigalduse domeeni loomiseks..."
"$WORKSPACE_DIR/scripts/internal/install-publisher.sh" >/dev/null 2>&1 || true

PUB_CONTAINER=""
if $CONTAINER_CLI container exists "app-publisher" 2>/dev/null; then
  PUB_CONTAINER="app-publisher"
elif $CONTAINER_CLI container exists "oracle-publisher-dev" 2>/dev/null; then
  PUB_CONTAINER="oracle-publisher-dev"
fi

if [ -n "$PUB_CONTAINER" ]; then
  echo -e "   2. Salvestan konfigureeritud WebLogic domeeni immutatavaks pildiks (${FINAL_TARGET})..."
  $CONTAINER_CLI commit "$PUB_CONTAINER" "$FINAL_TARGET" >/dev/null
  $CONTAINER_CLI tag "$FINAL_TARGET" "localhost/oracle-publisher-domain:latest" >/dev/null 2>&1 || true
  
  echo -e "\n${GREEN}==================================================================${NC}"
  echo -e "${GREEN}✅ Analytics Publisheri Domeenipildi Ehitamine Õnnestus!${NC}"
  echo -e "   📦 Pilt:   ${BOLD}${FINAL_TARGET}${NC}"
  echo -e "   🏷️  Sildis: ${CYAN}${SEMANTIC_TAG}${NC}"
  echo -e "   🔗 Alias:  localhost/oracle-publisher-domain:latest"
  echo -e "${GREEN}==================================================================${NC}\n"
else
  echo -e "${RED}❌ VIGA: Publisheri konteinerit ei leitud pildi salvestamiseks!${NC}"
  exit 1
fi
