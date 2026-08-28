#!/usr/bin/env bash
# ============================================================================
# Pre-built Forms Container Image Builder & Packager
# (docker/forms/build-forms-prebuilt-image.sh)
#
# Commits or packages the running Forms 14c container (app-forms) into a
# ready-to-run OCI image with canonical tag: localhost/oracle-forms:14.1.2
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source common helpers if available
if [ -f "$WORKSPACE_DIR/scripts/internal/common.sh" ]; then
  # shellcheck source=/dev/null
  source "$WORKSPACE_DIR/scripts/internal/common.sh"
fi

CONTAINER_CLI="podman"
if ! command -v podman >/dev/null 2>&1 && command -v docker >/dev/null 2>&1; then
  CONTAINER_CLI="docker"
fi

CONTAINER_NAME="${FORMS_CONTAINER_NAME:-app-forms}"
VERSION="14.1.2"
TARGET_IMAGE="localhost/oracle-forms:${VERSION}"
EXPORT_FILE=""
DO_PUSH=false

show_help() {
  cat << EOH
==================================================================
🏗️  Oracle Forms 14c Prebuilt Pildiehitaja & Pakendaja
==================================================================
Kasutus:
  ./docker/forms/build-forms-prebuilt-image.sh [VÕTMED]

Võtmed:
  -c, --container <NIMI>    Lähtekonteineri nimi (vaikimisi: app-forms)
  -t, --target-image <IMG>  Sihtpildi nimi (vaikimisi: localhost/oracle-forms:14.1.2)
  -e, --export <FAIL>       Salvesta OCI pilt arhiivina (nt: binaries/forms/oracle-forms-14.1.2.tar)
  -p, --push                Laadi pilt sihtregistrisse (podman/docker push)
  -h, --help                Kuvab selle abiinfo

Näited:
  # Loo standardne kohalik pilt töötavast Forms konteinerist:
  ./docker/forms/build-forms-prebuilt-image.sh

  # Salvesta pilt teistele jagamiseks faili:
  ./docker/forms/build-forms-prebuilt-image.sh --export binaries/forms/oracle-forms-14.1.2.tar

  # Laadi ettevõtte sise-Artifactorysse:
  ./docker/forms/build-forms-prebuilt-image.sh -t artifactory.corp.bank/oracle-forms:14.1.2 --push
EOH
}

while [[ "$#" -gt 0 ]]; do
  case $1 in
    -c|--container)
      CONTAINER_NAME="$2"
      shift 2
      ;;
    -t|--target-image)
      TARGET_IMAGE="$2"
      shift 2
      ;;
    -e|--export)
      EXPORT_FILE="$2"
      shift 2
      ;;
    -p|--push)
      DO_PUSH=true
      shift
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      echo "Tundmatu parameeter: $1" >&2
      show_help
      exit 1
      ;;
  esac
done

echo "=================================================================="
echo "🏗️  ORACLE FORMS 14c PILDIEHITAJA (${TARGET_IMAGE})"
echo "=================================================================="

# Check if container is running
if ! $CONTAINER_CLI ps --format "{{.Names}}" 2>/dev/null | grep -q "^${CONTAINER_NAME}$"; then
  echo "⚠️  Forms konteiner ($CONTAINER_NAME) ei tööta!"
  echo "   Käivitan ehituse lähtefailidest (build-forms-image.sh)..."
  "$SCRIPT_DIR/build-forms-image.sh" "$VERSION"
else
  echo "📦 Loome uue pildi töötavast konteinerist ($CONTAINER_NAME)..."
  $CONTAINER_CLI commit "$CONTAINER_NAME" "$TARGET_IMAGE"
  echo "✅ Pilt $TARGET_IMAGE on edukalt salvestatud kohalikku hoidlasse!"
fi

if [ -n "$EXPORT_FILE" ]; then
  mkdir -p "$(dirname "$EXPORT_FILE")"
  echo "💾 Ekspordin pildi arhiivi: $EXPORT_FILE..."
  $CONTAINER_CLI save -o "$EXPORT_FILE" "$TARGET_IMAGE"
  echo "✅ Pildi arhiiv valmis ($(du -h "$EXPORT_FILE" | awk '{print $1}'))!"
fi

if [ "$DO_PUSH" = "true" ]; then
  echo "🚀 Laadin pildi sihtregistrisse ($TARGET_IMAGE)..."
  $CONTAINER_CLI push "$TARGET_IMAGE"
  echo "🎉 Pilt edukalt registrisse laaditud!"
fi

echo "=================================================================="
echo "🎉 Forms 14c pilt (${TARGET_IMAGE}) on kasutusvalmis!"
echo "=================================================================="
