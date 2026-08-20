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

# Check if installer binaries exist in binaries/publisher/ or target directory
ZIP_FILE=$(find "$WORKSPACE_DIR/binaries/publisher" "$TARGET_DIR" -name "Oracle_Analytics_Server_Linux*.zip" 2>/dev/null | head -n 1 || true)

if [ -n "$ZIP_FILE" ] && [ -f "$ZIP_FILE" ]; then
  echo "ℹ️  Found Publisher installation package: $ZIP_FILE"
  if [ "$(dirname "$ZIP_FILE")" != "$TARGET_DIR" ]; then
    cp "$ZIP_FILE" "$TARGET_DIR/"
  fi
else
  echo "⚠️  WARNING: Oracle_Analytics_Server_Linux_${VERSION}.zip not found in binaries/publisher/ or $TARGET_DIR!"
  echo "    Please place the Oracle Analytics Server installer ZIP file in binaries/publisher/ before building."
fi

cd "$TARGET_DIR"
BUILD_START=$(date '+%s')

$CONTAINER_CLI build -t "$IMAGE_NAME" -f Dockerfile .

BUILD_END=$(date '+%s')
BUILD_ELAPSED=$(( BUILD_END - BUILD_START ))

echo "✅ Image '$IMAGE_NAME' built successfully in ${BUILD_ELAPSED}s!"
