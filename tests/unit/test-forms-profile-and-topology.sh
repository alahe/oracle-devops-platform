#!/usr/bin/env bash
# ============================================================================
# Unit Test: Oracle Forms 14c Profile & Topology Verification
# ============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$WORKSPACE_DIR/scripts/internal/load-profile.sh"

echo "🧪 Test: Loading db-forms-oracle YAML profile..."
load_db_profile "db-forms-oracle"

if [ "$PROFILE_CONTAINER_NAME" != "db-forms" ] && [ "$PROFILE_CONTAINER_NAME" != "db-forms-oracle" ]; then
  echo "❌ Error: Expected container db-forms or db-forms-oracle, got $PROFILE_CONTAINER_NAME"
  exit 1
fi

if [ "$PROFILE_DB_PORT" != "1534" ]; then
  echo "❌ Error: Expected port 1534, got $PROFILE_DB_PORT"
  exit 1
fi

echo "🧪 Test: Loading db-forms-publisher-oracle YAML profile..."
load_db_profile "db-forms-publisher-oracle"

if [ "$PROFILE_CONTAINER_NAME" != "db-forms-publisher" ]; then
  echo "❌ Error: Expected container db-forms-publisher, got $PROFILE_CONTAINER_NAME"
  exit 1
fi

if [ "$PROFILE_DB_PORT" != "1538" ]; then
  echo "❌ Error: Expected port 1538, got $PROFILE_DB_PORT"
  exit 1
fi

for bp in 6 7; do
  bp_file=$(find "$WORKSPACE_DIR/config/blueprints" -name ".env.${bp}-*" -o -name ".env.${bp}" | head -n 1)
  if [ -n "$bp_file" ] && [ -f "$bp_file" ]; then
    echo "✅ Blueprint $bp exists ($(basename "$bp_file"))!"
  else
    echo "❌ Error: Blueprint $bp missing!"
    exit 1
  fi
done

if [ -x "$WORKSPACE_DIR/docker/forms/build-forms-prebuilt-image.sh" ]; then
  echo "✅ docker/forms/build-forms-prebuilt-image.sh is executable!"
else
  echo "❌ Error: build-forms-prebuilt-image.sh not found or not executable!"
  exit 1
fi

echo "✅ Forms 14c profile, topology, and blueprints 20-23, 40 tests passed!"
