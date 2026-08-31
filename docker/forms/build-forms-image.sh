#!/usr/bin/env bash
# ============================================================================
# Oracle Forms 14c (14.1.2) Container Image Builder
# Automatically builds localhost/oracle-forms:14.1.2 using Podman or Docker
# ============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

VERSION="${1:-14.1.2}"
CONTAINER_CLI="podman"
if ! command -v podman >/dev/null 2>&1; then
  if command -v docker >/dev/null 2>&1; then
    CONTAINER_CLI="docker"
  fi
fi

IMAGE_NAME="${FORMS_CONTAINER_IMAGE:-localhost/oracle-forms:${VERSION}}"
TARGET_DIR="$SCRIPT_DIR/dockerfiles/$VERSION"

if [ ! -d "$TARGET_DIR" ]; then
  echo "❌ Error: Version directory $TARGET_DIR does not exist!" >&2
  exit 1
fi

echo "🚀 Building Oracle Forms 14c Image (${IMAGE_NAME}) using ${CONTAINER_CLI}..."

# Link/Copy downloaded installer binaries from binaries/java/, binaries/middleware/, and binaries/forms/
for pkg_path in "$WORKSPACE_DIR/binaries/java"/*.rpm "$WORKSPACE_DIR/binaries/java"/*.zip "$WORKSPACE_DIR/binaries/middleware"/*.zip "$WORKSPACE_DIR/binaries/middleware"/*.jar "$WORKSPACE_DIR/binaries/forms"/*.zip "$WORKSPACE_DIR/binaries/forms"/*.bin; do
  [ -f "$pkg_path" ] || continue
  bname=$(basename "$pkg_path")
  echo "ℹ️  Found installer package: $bname ($(du -h "$pkg_path" | awk '{print $1}'))"
  ln -f "$pkg_path" "$TARGET_DIR/" 2>/dev/null || cp -f "$pkg_path" "$TARGET_DIR/"
done

cd "$TARGET_DIR"
BUILD_START=$(date '+%s')

echo "ℹ️  Starting container build for ${IMAGE_NAME}..."
${CONTAINER_CLI} build \
  --build-arg BUILD_DATE="$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
  --tag "${IMAGE_NAME}" \
  --file Dockerfile .

BUILD_DUR=$(( $(date '+%s') - BUILD_START ))
echo "🎉 Successfully built ${IMAGE_NAME} in ${BUILD_DUR}s!"
