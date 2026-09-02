#!/usr/bin/env bash
# ==============================================================================
# Oracle DevOps Platform — Universal Enterprise Artifactory Publisher
# (scripts/publish-to-artifactory.sh)
#
# Publishes binaries, patches, container images, or golden snapshots to the
# structured product catalog in JFrog Artifactory, Nexus, or Harbor.
#
# Usage:
#   ./scripts/publish-to-artifactory.sh --product apex --category binaries --file binaries/apex/apex_26.1_en.zip
#   ./scripts/publish-to-artifactory.sh --product apex --category patches --file binaries/apex/patches/p36758444.zip --meta binaries/apex/patches/patch_latest.meta.json
#   ./scripts/publish-to-artifactory.sh --product blueprints --blueprint 3
# ==============================================================================

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=scripts/internal/common.sh
source "$WORKSPACE_DIR/scripts/internal/common.sh"
# shellcheck source=scripts/internal/i18n.sh
source "$WORKSPACE_DIR/scripts/internal/i18n.sh"
# shellcheck source=scripts/internal/snapshot-resolver.sh
source "$WORKSPACE_DIR/scripts/internal/snapshot-resolver.sh"
# shellcheck source=scripts/internal/artifactory-client.sh
source "$WORKSPACE_DIR/scripts/internal/artifactory-client.sh"

PRODUCT=""
CATEGORY=""
LOCAL_FILE=""
META_FILE=""
BP_ID=""
PROFILE_NAME_VAL=""
FORCE=false

show_help() {
  echo -e "${CYAN}${BOLD}Oracle DevOps Platform — Universal Artifactory Publisher${NC}"
  echo ""
  echo "Usage: $0 [options]"
  echo ""
  echo "Options:"
  echo "  -p, --product <PRODUCT>    Product name (apex, ords, database, forms, publisher, blueprints)"
  echo "  -c, --category <CATEGORY>  Category (binaries, patches, snapshots, images, metadata)"
  echo "  -f, --file <FILE_PATH>     Path to local file to upload"
  echo "  -m, --meta <META_PATH>     Path to companion .meta.json file"
  echo "  -b, --blueprint <ID>       Blueprint ID (e.g. 3, 34, 41) for snapshot publishing"
  echo "      --profile <NAME>       Profile name (e.g. db-proxy-oracle) for snapshot publishing"
  echo "  -y, --yes, --force         Skip confirmation"
  echo "      --lang <LANG>          Language (en, et, fi, sv, lv, lt)"
  echo "  -h, --help                 Show this help"
  echo ""
  echo "Examples:"
  echo "  $0 --product blueprints --blueprint 3"
  echo "  $0 --product apex --category patches --file binaries/apex/patches/p36758444_latest.zip"
  echo ""
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -p|--product) PRODUCT="$2"; shift 2 ;;
    -c|--category) CATEGORY="$2"; shift 2 ;;
    -f|--file) LOCAL_FILE="$2"; shift 2 ;;
    -m|--meta) META_FILE="$2"; shift 2 ;;
    -b|--blueprint) BP_ID="$2"; shift 2 ;;
    --profile) PROFILE_NAME_VAL="$2"; shift 2 ;;
    -y|--yes|--force) FORCE=true; shift ;;
    --lang)
      export CLI_LANG="$2"
      export ACTIVE_CLI_LANG="$(resolve_cli_lang)"
      shift 2
      ;;
    -h|--help) show_help; exit 0 ;;
    *) shift ;;
  esac
done

if ! artifactory_is_configured; then
  echo -e "${RED}❌ Error: ARTIFACTORY_URL is not configured in .env or config/repository.env.${NC}"
  exit 1
fi

# Handle Blueprint Snapshot publishing shorthand
if [ -n "$BP_ID" ] || [ "$PRODUCT" = "blueprints" ]; then
  BP_ID="${BP_ID:-3}"
  PRODUCT="blueprints"
  CATEGORY="snapshots"
  LOCAL_FILE="${WORKSPACE_DIR}/golden-snapshots/bp_${BP_ID}_latest.tar.gz"
  META_FILE="${WORKSPACE_DIR}/golden-snapshots/bp_${BP_ID}_latest.meta.json"

  if [ ! -f "$LOCAL_FILE" ]; then
    LOCAL_FILE="${WORKSPACE_DIR}/golden-snapshots/apex_proxy_oradata_latest.tar.gz"
    META_FILE="${WORKSPACE_DIR}/golden-snapshots/apex_proxy_oradata_latest.meta.json"
  fi
fi

# Handle Profile Snapshot publishing shorthand
if [ -n "$PROFILE_NAME_VAL" ]; then
  PRODUCT="database"
  CATEGORY="snapshots"
  CLEAN_P=$(echo "$PROFILE_NAME_VAL" | sed 's/\.yaml$//' | tr '/' '_')
  LOCAL_FILE="${WORKSPACE_DIR}/golden-snapshots/profile_${CLEAN_P}_latest.tar.gz"
  META_FILE="${WORKSPACE_DIR}/golden-snapshots/profile_${CLEAN_P}_latest.meta.json"
fi

if [ -z "$PRODUCT" ] || [ -z "$LOCAL_FILE" ]; then
  echo -e "${RED}❌ Error: Missing required arguments --product and --file.${NC}"
  show_help
  exit 1
fi

if [ ! -f "$LOCAL_FILE" ]; then
  echo -e "${RED}❌ Error: Target file not found: $LOCAL_FILE${NC}"
  exit 1
fi

CATEGORY="${CATEGORY:-binaries}"

# Generate .meta.json if missing for snapshots
if [ "$CATEGORY" = "snapshots" ] && { [ -z "$META_FILE" ] || [ ! -f "$META_FILE" ]; }; then
  if declare -f write_snapshot_metadata >/dev/null 2>&1; then
    META_FILE="${LOCAL_FILE%.tar.gz}.meta.json"
    write_snapshot_metadata "$LOCAL_FILE" "${BP_ID:-3}" "${PROFILE_NAME_VAL:-db-proxy-oracle}" "${PROFILE_APEX_VERSION:-26.1}"
  fi
fi

echo -e "${CYAN}==================================================================${NC}"
echo -e "${YELLOW}⬆️  Publishing Artifact to Enterprise Artifactory${NC}"
echo -e "   📦 Product:   ${GREEN}$PRODUCT${NC}"
echo -e "   📂 Category:  ${CYAN}$CATEGORY${NC}"
echo -e "   📄 File:      ${YELLOW}$LOCAL_FILE${NC}"
[ -n "$META_FILE" ] && echo -e "   📑 Metadata:  ${YELLOW}$META_FILE${NC}"
echo -e "   🌐 Target:    ${CYAN}${ARTIFACTORY_URL}/${ARTIFACTORY_REPO}/products/${PRODUCT}/${CATEGORY}/${NC}"
echo -e "${CYAN}==================================================================${NC}"

SUBPATH=""
if [ "$PRODUCT" = "blueprints" ]; then
  SUBPATH="bp_${BP_ID}"
fi

if artifactory_publish_artifact "$PRODUCT" "$CATEGORY" "$LOCAL_FILE" "$META_FILE" "$SUBPATH"; then
  echo -e "${GREEN}✅ Published successfully to Artifactory.${NC}"
  exit 0
else
  echo -e "${RED}❌ Publishing failed.${NC}"
  exit 1
fi
