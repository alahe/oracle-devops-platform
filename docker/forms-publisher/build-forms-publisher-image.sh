#!/bin/bash
# ============================================================================
# Build Unified Oracle Forms 14c + Analytics Publisher 2025 Container Image
# ============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
IMAGE_NAME="${IMAGE_NAME:-localhost/oracle-forms-publisher:14c-2025}"

echo "=================================================================="
echo "🏗️  BUILDING UNIFIED FORMS 14c + PUBLISHER 2025 CONTAINER IMAGE"
echo "   Target Image: $IMAGE_NAME"
echo "=================================================================="

CONTAINER_TOOL=$(which podman 2>/dev/null || which docker 2>/dev/null || true)
if [ -z "$CONTAINER_TOOL" ]; then
  echo "❌ Error: Neither podman nor docker found in PATH."
  exit 1
fi

"$CONTAINER_TOOL" build -t "$IMAGE_NAME" -f "$SCRIPT_DIR/Dockerfile" "$SCRIPT_DIR"

echo "=================================================================="
echo "✅ UNIFIED IMAGE BUILT SUCCESSFULLY: $IMAGE_NAME"
echo "=================================================================="
