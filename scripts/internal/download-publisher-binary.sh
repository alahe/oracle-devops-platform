#!/usr/bin/env bash
# ============================================================================
# Oracle Analytics Publisher Binary Auto-Downloader
# Automatically detects downloaded files in ~/Downloads, runs ~/Downloads/wget.sh
# or downloads V1055080-01.zip / V1045135-01.zip from corporate Artifactory / S3.
# ============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
TARGET_DIR="$WORKSPACE_DIR/binaries/publisher"
DOWNLOADS_DIR="$HOME/Downloads"

mkdir -p "$TARGET_DIR"

# 1. Check if binary already exists in target directory binaries/publisher/
EXISTING_ZIP=$(find "$TARGET_DIR" \( -name "V1055080-01.zip" -o -name "V1045135-01.zip" -o -name "Oracle_Analytics_Server*.zip" \) 2>/dev/null | head -n 1 || true)

if [ -n "$EXISTING_ZIP" ] && [ -f "$EXISTING_ZIP" ]; then
  echo "✅ Publisher installation package already exists: $EXISTING_ZIP"
  exit 0
fi

# 2. Check if binary exists in user's ~/Downloads directory and copy automatically
DOWNLOADED_ZIP=$(find "$DOWNLOADS_DIR" -maxdepth 1 \( -name "V1055080-01.zip" -o -name "V1045135-01.zip" -o -name "Oracle_Analytics_Server*.zip" \) 2>/dev/null | head -n 1 || true)

if [ -n "$DOWNLOADED_ZIP" ] && [ -f "$DOWNLOADED_ZIP" ]; then
  echo "🚀 Found downloaded package in Downloads folder: $DOWNLOADED_ZIP"
  echo "🚚 Copying to project workspace: $TARGET_DIR/"
  cp "$DOWNLOADED_ZIP" "$TARGET_DIR/"
  echo "✅ Package copied successfully!"
  exit 0
fi

# 3. Check if eDelivery wget.sh script exists in ~/Downloads/
if [ -f "$DOWNLOADS_DIR/wget.sh" ]; then
  echo "ℹ️  Found Oracle eDelivery downloader script at: $DOWNLOADS_DIR/wget.sh"
  if [ -n "${ACCESS_TOKEN:-}" ]; then
    echo "🚀 Executing wget.sh with provided ACCESS_TOKEN..."
    cd "$TARGET_DIR"
    echo "$ACCESS_TOKEN" | sh "$DOWNLOADS_DIR/wget.sh" || true
    EXISTING_ZIP=$(find "$TARGET_DIR" \( -name "V1055080-01.zip" -o -name "V1045135-01.zip" -o -name "Oracle_Analytics_Server*.zip" \) 2>/dev/null | head -n 1 || true)
    if [ -n "$EXISTING_ZIP" ] && [ -f "$EXISTING_ZIP" ]; then
      echo "✅ eDelivery Download completed: $EXISTING_ZIP"
      exit 0
    fi
  fi
fi

# 4. Check for Corporate Artifactory / Mirror URL (.env variable PUBLISHER_BINARY_URL)
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

# 5. Manual / Guided Fallback Notice
echo "=========================================================================="
echo "⚠️  AUTOMATIC DOWNLOAD NOTICE:"
echo "    Oracle eDelivery requires an active browser SSO token."
echo "    Found downloader script in ~/Downloads/wget.sh!"
echo ""
echo "    To download automatically using your eDelivery token:"
echo "    ACCESS_TOKEN=\"your_token\" ./scripts/internal/download-publisher-binary.sh"
echo ""
echo "    Or simply start download in browser — script will auto-detect when finished!"
echo "=========================================================================="
exit 0
