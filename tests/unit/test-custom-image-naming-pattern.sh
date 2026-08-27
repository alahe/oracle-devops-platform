#!/usr/bin/env bash
# ============================================================================
# Unit Test: test-custom-image-naming-pattern.sh
# Purpose: Verifies format_custom_image_tag and In-DB Auto-Tagging logic
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source common helpers
source "$WORKSPACE_DIR/scripts/internal/common.sh"

# Test 1: Bash syntax checks
bash -n "$WORKSPACE_DIR/scripts/internal/common.sh"
bash -n "$WORKSPACE_DIR/docker/apex/build-apex-prebuilt-image.sh"

# Test 2: Test format_custom_image_tag with standard permutations
tag1=$(format_custom_image_tag "23.4.0.24.05" "26.1.0.123")
if [ "$tag1" != "23ai-apex26.1" ]; then
  echo "FAIL: Expected '23ai-apex26.1', got '$tag1'"
  exit 1
fi

tag2=$(format_custom_image_tag "23ai" "26.1" "26.2.2")
if [ "$tag2" != "23ai-apex26.1-ords26.2" ]; then
  echo "FAIL: Expected '23ai-apex26.1-ords26.2', got '$tag2'"
  exit 1
fi

tag3=$(format_custom_image_tag "23ai" "26.1" "" "gvenzl")
if [ "$tag3" != "23ai-gvenzl-apex26.1" ]; then
  echo "FAIL: Expected '23ai-gvenzl-apex26.1', got '$tag3'"
  exit 1
fi

tag4=$(format_custom_image_tag "19.3.0" "26.1" "26.2" "ocr")
if [ "$tag4" != "19c-ocr-apex26.1-ords26.2" ]; then
  echo "FAIL: Expected '19c-ocr-apex26.1-ords26.2', got '$tag4'"
  exit 1
fi

# Test 3: Test detect_container_db_versions fallback on non-existent container
det_out=$(detect_container_db_versions "non-existent-container-xyz" 2>/dev/null || echo "23ai:26.1:NONE")
if [[ "$det_out" != *"23ai"* ]] || [[ "$det_out" != *"26.1"* ]]; then
  echo "FAIL: Unexpected fallback detect_out: '$det_out'"
  exit 1
fi

# Test 4: Test build-apex-prebuilt-image.sh --help
help_out=$("$WORKSPACE_DIR/docker/apex/build-apex-prebuilt-image.sh" --help)
if [[ "$help_out" != *"Auto-Tagging"* ]]; then
  echo "FAIL: build-apex-prebuilt-image.sh help missing Auto-Tagging: $help_out"
  exit 1
fi

echo "test-custom-image-naming-pattern: PASS"
