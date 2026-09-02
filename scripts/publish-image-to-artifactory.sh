#!/usr/bin/env bash
# ============================================================================
# Oracle DevOps Platform — Publish Images to Enterprise Artifactory / Registry
# (scripts/publish-image-to-artifactory.sh)
#
# Tags and pushes local Oracle database / APEX / Publisher images to an
# enterprise container registry (JFrog Artifactory, Harbor, Nexus, GitLab).
# Optionally updates .env with REGISTRY_PREFIX for seamless offline mirroring.
#
# Supports --dry-run for safe testing and inspection without network access.
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source common helpers
if [ -f "$SCRIPT_DIR/internal/common.sh" ]; then
  source "$SCRIPT_DIR/internal/common.sh"
else
  CYAN='\033[1;36m'
  GREEN='\033[1;32m'
  YELLOW='\033[0;33m'
  RED='\033[1;31m'
  BOLD='\033[1m'
  NC='\033[0m'
fi

# Default parameters
REGISTRY_URL=""
LOCAL_IMAGE=""
REMOTE_TAG=""
AUTH_USER=""
AUTH_PASS=""
UPDATE_ENV=false
DRY_RUN=false

show_help() {
  cat << EOF
${CYAN}==================================================================${NC}
${BOLD}📦 Ettevõtte Artifactory / Registri Piltide Avaldaja${NC}
${CYAN}==================================================================${NC}
Kasutus:
  ./scripts/publish-image-to-artifactory.sh [VÕTMED]

Võtmed:
  -r, --registry <URL>      Ettevõtte registri URL (nt: artifactory.firma.ee/docker-local/oracle)
  -i, --image <NIMI>        Kohalik pilt, mida avaldada (nt: oracle-free-apex:26.1 või all)
  -t, --tag <TAG>           Sihtmärgis / versioonitähis (vaikimisi sama mis lähte-tag)
  -u, --user <USER>         Artifactory kasutajanimi sisselogimiseks
  -p, --password <PASS>     Artifactory API token või parool
      --update-env          Kirjutab REGISTRY_PREFIX väärtuse automaatselt faili .env
      --dry-run             Simuleerib käske ilma tegeliku võrguliikluse ja muudatusteta
  -h, --help                Kuvab selle abiteksti

Näited:
  # 1. Dry run and inspection:
  ./scripts/publish-image-to-artifactory.sh -r "artifactory.firma.ee/oracle" -i "oracle-free-apex:26.1" --dry-run

  # 2. Publish images and update .env configuration:
  ./scripts/publish-image-to-artifactory.sh \\
    --registry "artifactory.firma.ee/docker-local/oracle" \\
    --image "oracle-free-apex:26.1" \\
    --update-env
EOF
}

# Parse CLI arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -r|--registry)
      REGISTRY_URL="$2"
      shift
      ;;
    -i|--image)
      LOCAL_IMAGE="$2"
      shift
      ;;
    -t|--tag)
      REMOTE_TAG="$2"
      shift
      ;;
    -u|--user)
      AUTH_USER="$2"
      shift
      ;;
    -p|--password)
      AUTH_PASS="$2"
      shift
      ;;
    --update-env)
      UPDATE_ENV=true
      ;;
    --dry-run)
      DRY_RUN=true
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

if [ -z "$REGISTRY_URL" ]; then
  echo -e "${RED}❌ ERROR: Registry URL (--registry) is required!${NC}"
  echo -e "ℹ️  Example: ./scripts/publish-image-to-artifactory.sh --registry 'artifactory.company.local/oracle' --image 'oracle-free-apex:26.1'"
  exit 1
fi

# Clean trailing slash from registry URL
REGISTRY_URL="${REGISTRY_URL%/}"

# Container command resolver (podman or docker)
CONTAINER_CLI="podman"
if ! command -v podman >/dev/null 2>&1 && command -v docker >/dev/null 2>&1; then
  CONTAINER_CLI="docker"
fi

echo -e "\n${CYAN}==================================================================${NC}"
echo -e "${BOLD}🚀 ETTEVÕTTE ARTIFACTORY PILTIDE AVALDAMINE${NC}"
echo -e "${CYAN}==================================================================${NC}"
echo -e "   ├─ 🏢 ${BOLD}Sihtregister:${NC}       ${GREEN}${REGISTRY_URL}${NC}"
echo -e "   ├─ 📦 ${BOLD}Lähtepilt:${NC}          ${YELLOW}${LOCAL_IMAGE:-Kõik projekti pildid}${NC}"
echo -e "   ├─ ⚙️  ${BOLD}Konteineri mootor:${NC}  ${CONTAINER_CLI}"
echo -e "   ├─ 🧪 ${BOLD}Kuivkäivitus:${NC}       ${DRY_RUN}"
echo -e "   └─ 📝 ${BOLD}Uuenda .env:${NC}        ${UPDATE_ENV}"
echo -e "${CYAN}==================================================================${NC}\n"

# 1. Authentication (if user & password provided)
if [ -n "$AUTH_USER" ] && [ -n "$AUTH_PASS" ]; then
  echo -e "🔐 [1/3]: Autentin registrisse: ${REGISTRY_URL} (kasutaja: ${AUTH_USER})..."
  if [ "$DRY_RUN" = "true" ]; then
    echo -e "   ${YELLOW}[DRY-RUN]${NC} $CONTAINER_CLI login -u \"$AUTH_USER\" -p \"********\" \"$REGISTRY_URL\""
  else
    echo "$AUTH_PASS" | $CONTAINER_CLI login -u "$AUTH_USER" --password-stdin "$REGISTRY_URL"
    echo -e "   ${GREEN}✅ Sisselogimine õnnestus!${NC}"
  fi
else
  echo -e "ℹ️  [1/3]: Autentimistunnuseid ei antud, kasutan olemasolevaid sessiooni volitusi."
fi

# 2. Image list
IMAGES_TO_PUBLISH=()
if [ -z "$LOCAL_IMAGE" ] || [ "$LOCAL_IMAGE" = "all" ] || [ "$LOCAL_IMAGE" = "ALL" ]; then
  IMAGES_TO_PUBLISH=(
    "container-registry.oracle.com/database/free:latest"
    "oracle/analyticsserver:2025"
  )
  # Check if custom apex image exists locally
  if $CONTAINER_CLI image exists "oracle-free-apex:latest" 2>/dev/null; then
    IMAGES_TO_PUBLISH+=("oracle-free-apex:latest")
  fi
else
  IMAGES_TO_PUBLISH=("$LOCAL_IMAGE")
fi

echo -e "\n📦 [2/3]: Tag'in ja laen üles ${#IMAGES_TO_PUBLISH[@]} pilti..."

for src_img in "${IMAGES_TO_PUBLISH[@]}"; do
  img_base=$(basename "$src_img")
  img_name="${img_base%%:*}"
  img_tag="${img_base##*:}"
  [ "$img_tag" = "$img_base" ] && img_tag="latest"
  [ -n "$REMOTE_TAG" ] && img_tag="$REMOTE_TAG"

  target_ref="${REGISTRY_URL}/${img_name}:${img_tag}"

  echo -e "\n   👉 Töötlen pilti: ${BOLD}${src_img}${NC}"
  echo -e "      ├── Sihtmärgis: ${CYAN}${target_ref}${NC}"

  if [ "$DRY_RUN" = "true" ]; then
    echo -e "      ├── ${YELLOW}[DRY-RUN]${NC} $CONTAINER_CLI tag \"$src_img\" \"$target_ref\""
    echo -e "      └── ${YELLOW}[DRY-RUN]${NC} $CONTAINER_CLI push \"$target_ref\""
  else
    echo -n "      ├── Tag'in pildi... "
    $CONTAINER_CLI tag "$src_img" "$target_ref"
    echo -e "${GREEN}OK${NC}"

    echo -n "      └── Laen üles Artifactorysse... "
    $CONTAINER_CLI push "$target_ref"
    echo -e "${GREEN}VALMIS${NC}"
  fi
done

# 3. Update .env if --update-env is set
if [ "$UPDATE_ENV" = "true" ]; then
  echo -e "\n⚙️  [3/3]: Uuendan projekti .env faili seadistust..."
  ENV_FILE="$WORKSPACE_DIR/.env"
  REGISTRY_PREFIX_VAL="${REGISTRY_URL}/"

  if [ "$DRY_RUN" = "true" ]; then
    echo -e "   ${YELLOW}[DRY-RUN]${NC} Seadistan failis $ENV_FILE: REGISTRY_PREFIX=\"${REGISTRY_PREFIX_VAL}\""
  else
    if [ -f "$ENV_FILE" ]; then
      if grep -q "^REGISTRY_PREFIX=" "$ENV_FILE"; then
        # Replace existing
        sed -i.bak -E "s|^REGISTRY_PREFIX=.*|REGISTRY_PREFIX=\"${REGISTRY_PREFIX_VAL}\"|" "$ENV_FILE" && rm -f "${ENV_FILE}.bak"
      else
        echo "" >> "$ENV_FILE"
        echo "# Enterprise Artifactory registry prefix (automatically managed by publish-image-to-artifactory.sh)" >> "$ENV_FILE"
        echo "REGISTRY_PREFIX=\"${REGISTRY_PREFIX_VAL}\"" >> "$ENV_FILE"
      fi
      echo -e "   ${GREEN}✅ .env uuendatud: REGISTRY_PREFIX=\"${REGISTRY_PREFIX_VAL}\"${NC}"
    else
      echo "REGISTRY_PREFIX=\"${REGISTRY_PREFIX_VAL}\"" > "$ENV_FILE"
      echo -e "   ${GREEN}✅ Loodud uus .env fail: REGISTRY_PREFIX=\"${REGISTRY_PREFIX_VAL}\"${NC}"
    fi
  fi
else
  echo -e "\nℹ️  [3/3]: .env faili ei muudetud (kasuta --update-env kui soovid registri prefiksi kohest rakendamist)."
fi

echo -e "\n${GREEN}==================================================================${NC}"
echo -e "${GREEN}✅ ARTIFACTORY PILTIDE AVALDAMISE PROTSESS LÕPETATUD!${NC}"
echo -e "${GREEN}==================================================================${NC}\n"
