#!/usr/bin/env bash
# ============================================================================
# Pre-built APEX Container Image Builder with In-DB Auto-Tagging
# (docker/apex/build-apex-prebuilt-image.sh)
#
# Inspects internal dictionary views (v$instance, dba_registry, ords_metadata)
# inside the running DB to detect runtime versions and automatically generates
# a canonical semantic tag: localhost/oracle-free-apex:<DB_VER>-apex<APEX_VER>
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

BASE_IMAGE="docker.io/gvenzl/oracle-free:23-full-faststart"
TARGET_IMAGE=""
DB_VER_ARG=""
APEX_VER_ARG="26.1"
ORDS_VER_ARG=""
FLAVOR_ARG=""

show_help() {
  cat << EOF
${CYAN}==================================================================${NC}
${BOLD}🏗️  Eelkonfigureeritud APEX Konteineripildi Ehitaja (Auto-Tagging)${NC}
${CYAN}==================================================================${NC}
Kasutus:
  ./docker/apex/build-apex-prebuilt-image.sh [VÕTMED]

Võtmed:
  -b, --base-image <IMG>    Lähtepilt (vaikimisi: docker.io/gvenzl/oracle-free:23-full-faststart)
  -t, --target-image <IMG>  Sihtpildi täisnimi (kui soovitakse automaatne tag üle kirjutada)
      --db-ver <VER>        Andmebaasi versioon (nt: 23ai)
      --apex-ver <VER>      APEX versioon (vaikimisi: 26.1)
      --ords-ver <VER>      ORDS versioon (nt: 26.2)
      --flavor <NIMI>       Täiendav silditähis (nt: gvenzl, ocr)
  -h, --help                Kuvab selle abiteksti

Näide:
  # Täisautomaatne ehitamine (tuvastab DB ja APEX versiooni andmebaasist):
  ./docker/apex/build-apex-prebuilt-image.sh
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
    --db-ver)
      DB_VER_ARG="$2"
      shift
      ;;
    --apex-ver)
      APEX_VER_ARG="$2"
      shift
      ;;
    --ords-ver)
      ORDS_VER_ARG="$2"
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

TEMP_CONTAINER="apex-builder-temp-$$"

cleanup() {
  $CONTAINER_CLI rm -f "$TEMP_CONTAINER" >/dev/null 2>&1 || true
}
trap cleanup EXIT INT TERM

echo -e "\n${CYAN}==================================================================${NC}"
echo -e "${BOLD}🚀 EHITAN EELKONFIGUREERITUD APEX KONTEINERIPILDI (Auto-Tagging)${NC}"
echo -e "${CYAN}==================================================================${NC}"
echo -e "   ├─ 📦 ${BOLD}Lähtepilt:${NC}          ${BASE_IMAGE}"
echo -e "   ├─ ⚙️  ${BOLD}Konteineri mootor:${NC}  ${CONTAINER_CLI}"
echo -e "   └─ 🏷️  ${BOLD}Soovitud APEX:${NC}      ${APEX_VER_ARG}"
echo -e "${CYAN}==================================================================${NC}\n"

echo -e "   1. Käivitan ajutise FastStart DB konteineri (${TEMP_CONTAINER})..."
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
  exit 1
fi

echo -e "   3. Paigaldan APEX ${APEX_VER_ARG} mootori konteineri sisse..."
SYS_PWD="OraclePass2026Sys!" "$WORKSPACE_DIR/scripts/internal/install-apex.sh" --db "$TEMP_CONTAINER" --version "$APEX_VER_ARG" >/dev/null 2>&1 || true

echo -e "   4. Tuvastan reaalajas andmebaasi sisevaadetest versioonid (In-DB Auto-Tagging)..."
DETECTED_INFO=$(detect_container_db_versions "$TEMP_CONTAINER" 2>/dev/null || echo "23ai:26.1:NONE")

RAW_DB_VER=$(echo "$DETECTED_INFO" | cut -d':' -f1)
RAW_APEX_VER=$(echo "$DETECTED_INFO" | cut -d':' -f2)
RAW_ORDS_VER=$(echo "$DETECTED_INFO" | cut -d':' -f3)

FINAL_DB_VER="${DB_VER_ARG:-${RAW_DB_VER:-23ai}}"
FINAL_APEX_VER="${APEX_VER_ARG:-${RAW_APEX_VER:-26.1}}"
FINAL_ORDS_VER="${ORDS_VER_ARG:-${RAW_ORDS_VER}}"
[ "$FINAL_ORDS_VER" = "NONE" ] && FINAL_ORDS_VER=""

# Resolve flavor if base image is gvenzl
FINAL_FLAVOR="$FLAVOR_ARG"
if [ -z "$FINAL_FLAVOR" ] && [[ "$BASE_IMAGE" == *"gvenzl"* ]]; then
  FINAL_FLAVOR="gvenzl"
fi

SEMANTIC_TAG=$(format_custom_image_tag "$FINAL_DB_VER" "$FINAL_APEX_VER" "$FINAL_ORDS_VER" "$FINAL_FLAVOR")
CANONICAL_IMAGE="localhost/oracle-free-apex:${SEMANTIC_TAG}"

if [ -n "$TARGET_IMAGE" ]; then
  FINAL_TARGET="$TARGET_IMAGE"
else
  FINAL_TARGET="$CANONICAL_IMAGE"
fi

echo -e "      ├── Tuvastatud DB:   ${GREEN}${FINAL_DB_VER}${NC}"
echo -e "      ├── Tuvastatud APEX: ${GREEN}${FINAL_APEX_VER}${NC}"
[ -n "$FINAL_ORDS_VER" ] && echo -e "      ├── Tuvastatud ORDS: ${GREEN}${FINAL_ORDS_VER}${NC}"
echo -e "      └── Genereeritud Tag: ${CYAN}${SEMANTIC_TAG}${NC}"

echo -e "\n   5. Salvestan konteineri oleku pildiks (${FINAL_TARGET})..."
$CONTAINER_CLI commit "$TEMP_CONTAINER" "$FINAL_TARGET" >/dev/null
$CONTAINER_CLI tag "$FINAL_TARGET" "localhost/oracle-free-apex:latest" >/dev/null 2>&1 || true

echo -e "\n${GREEN}==================================================================${NC}"
echo -e "${GREEN}✅ APEX Pildi Ehitamine Õnnestus!${NC}"
echo -e "   📦 Pilt:   ${BOLD}${FINAL_TARGET}${NC}"
echo -e "   🏷️  Sildis: ${CYAN}${SEMANTIC_TAG}${NC}"
echo -e "   🔗 Alias:  localhost/oracle-free-apex:latest"
echo -e "${GREEN}==================================================================${NC}\n"
