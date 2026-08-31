#!/usr/bin/env bash
# ============================================================================
# Web IDE Pre-built Container Image Builder
# Builds localhost/oracle-web-ide:latest with Oracle SQL Developer, Antigravity,
# GitHub Actions, and Red Hat YAML extensions pre-baked.
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

CONTAINER_CLI="podman"
if ! command -v podman >/dev/null 2>&1 && command -v docker >/dev/null 2>&1; then
  CONTAINER_CLI="docker"
fi

IMAGE_NAME="${WEB_IDE_CONTAINER_IMAGE:-localhost/oracle-web-ide:latest}"

echo "=================================================================="
echo "🚀 EHITAN WEB IDE EELKONFIGUREERITUD KONTEINERIPILDI"
echo "=================================================================="
echo "   📦 Sihtpilt: ${IMAGE_NAME}"
echo "   ⚙️  Mootor:   ${CONTAINER_CLI}"
echo "=================================================================="

cd "$SCRIPT_DIR"
$CONTAINER_CLI build -t "$IMAGE_NAME" -f Dockerfile .
$CONTAINER_CLI tag "$IMAGE_NAME" "web-ide-image:latest" 2>/dev/null || true

echo "=================================================================="
echo "✅ Web IDE pildi ehitamine õnnestus: ${IMAGE_NAME}"
echo "=================================================================="
