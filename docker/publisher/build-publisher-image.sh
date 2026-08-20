#!/usr/bin/env bash
# ============================================================================
# Oracle Analytics Publisher Container Image Builder
# Automatically builds oracle/analyticsserver:2025 using Podman or Docker
# ============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

VERSION="${1:-2025}"
CONTAINER_CLI="podman"
if ! command -v podman >/dev/null 2>&1; then
  if command -v docker >/dev/null 2>&1; then
    CONTAINER_CLI="docker"
  fi
fi

IMAGE_NAME="${PUBLISHER_CONTAINER_IMAGE:-oracle/analyticsserver:${VERSION}}"
TARGET_DIR="$SCRIPT_DIR/dockerfiles/$VERSION"

if [ ! -d "$TARGET_DIR" ]; then
  echo "❌ Error: Version directory $TARGET_DIR does not exist!" >&2
  exit 1
fi

echo "🚀 Building Oracle Analytics Publisher Image (${IMAGE_NAME}) using ${CONTAINER_CLI}..."

# Attempt automatic binary download if configured
if [ -f "$WORKSPACE_DIR/scripts/internal/download-publisher-binary.sh" ]; then
  "$WORKSPACE_DIR/scripts/internal/download-publisher-binary.sh" || true
fi

# Copy all downloaded installer binaries from binaries/publisher/ to build directory
for zip_path in "$WORKSPACE_DIR/binaries/publisher"/*.zip; do
  [ -f "$zip_path" ] || continue
  bname=$(basename "$zip_path")
  echo "ℹ️  Found installer package: $bname ($(du -h "$zip_path" | awk '{print $1}'))"
  cp -f "$zip_path" "$TARGET_DIR/"
  
  # Auto-alias V1055080-01.zip to standard filename expected by Dockerfile if needed
  if [ "$bname" = "V1055080-01.zip" ]; then
    cp -f "$zip_path" "$TARGET_DIR/Oracle_Analytics_Server_Linux_2025(8.2).zip"
  fi
done

cd "$TARGET_DIR"
BUILD_START=$(date '+%s')

$CONTAINER_CLI build -t "$IMAGE_NAME" -f Dockerfile .

BUILD_END=$(date '+%s')
BUILD_ELAPSED=$(( BUILD_END - BUILD_START ))

echo "✅ Image '$IMAGE_NAME' built successfully in ${BUILD_ELAPSED}s!"
