#!/usr/bin/env bash
# ============================================================================
# Oracle Analytics Publisher Binary Auto-Downloader
# Downloads V1055080-01.zip / V1045135-01.zip from corporate Artifactory / S3
# or direct Oracle eDelivery URL if authentication token / URL is configured.
# ============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
TARGET_DIR="$WORKSPACE_DIR/binaries/publisher"

mkdir -p "$TARGET_DIR"

# Check if binary already exists locally
EXISTING_ZIP=$(find "$TARGET_DIR" \( -name "V1055080-01.zip" -o -name "V1045135-01.zip" -o -name "Oracle_Analytics_Server*.zip" \) 2>/dev/null | head -n 1 || true)

if [ -n "$EXISTING_ZIP" ] && [ -f "$EXISTING_ZIP" ]; then
  echo "✅ Publisher installation package already exists: $EXISTING_ZIP"
  exit 0
fi

echo "🔍 Publisher installer not found in $TARGET_DIR. Checking download sources..."

# 1. Option 1: Internal Corporate Artifactory / Mirror URL (.env variable PUBLISHER_BINARY_URL)
BINARY_URL="${PUBLISHER_BINARY_URL:-${PUBLISHER_DOWNLOAD_URL:-}}"

if [ -n "$BINARY_URL" ]; then
  echo "🚀 Downloading Publisher package automatically from: $BINARY_URL..."
  TARGET_FILE="$TARGET_DIR/V1055080-01.zip"
  
  if command -v curl >/dev/null 2>&1; then
    curl -L --fail --progress-bar "$BINARY_URL" -o "$TARGET_FILE"
  elif command -v wget >/dev/null 2>&1; then
    wget -O "$TARGET_FILE" "$BINARY_URL"
  else
    echo "❌ Error: Neither curl nor wget is installed!" >&2
    exit 1
  fi

  echo "✅ Download completed successfully: $TARGET_FILE"
  exit 0
fi

# 2. Option 2: Oracle eDelivery Authenticated Token Download (.env variable PUBLISHER_DOWNLOAD_TOKEN)
DOWNLOAD_TOKEN="${PUBLISHER_DOWNLOAD_TOKEN:-}"

if [ -n "$DOWNLOAD_TOKEN" ]; then
  EDELIVERY_URL="https://edelivery.oracle.com/osdc/softwareDownload?fileName=V1055080-01.zip&token=${DOWNLOAD_TOKEN}"
  echo "🚀 Downloading directly from Oracle eDelivery using authentication token..."
  TARGET_FILE="$TARGET_DIR/V1055080-01.zip"
  curl -L --fail --progress-bar "$EDELIVERY_URL" -o "$TARGET_FILE"
  echo "✅ Download completed successfully: $TARGET_FILE"
  exit 0
fi

# 3. Manual Fallback Notice
echo "=========================================================================="
echo "⚠️  AUTOMATIC DOWNLOAD NOTICE:"
echo "    Oracle eDelivery requires an active browser SSO login or corporate mirror."
echo "    To enable automatic binary downloading, set one of the following in .env:"
echo ""
echo "    1. Internal Enterprise Mirror URL (Artifactory / Nexus / S3):"
echo "       PUBLISHER_BINARY_URL=https://artifactory.internal.repo/oracle/V1055080-01.zip"
echo ""
echo "    2. eDelivery Token (copy token parameter from eDelivery download link):"
echo "       PUBLISHER_DOWNLOAD_TOKEN=U2NVaDRzTVJITUF5..."
echo ""
echo "    Or manually place V1055080-01.zip in: $TARGET_DIR/"
echo "=========================================================================="
exit 0
