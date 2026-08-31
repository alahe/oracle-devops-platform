#!/usr/bin/env bash
# ============================================================================
# Unit Test: test-web-ide-extensions.sh
# Validates pre-configuration and installation of Oracle SQL Developer & Antigravity
# ============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "🔍 Validating Web IDE extensions configuration..."

# 1. Check Dockerfile contains both extensions and settings
DOCKERFILE="$WORKSPACE_DIR/docker/web-ide/Dockerfile"
if [ ! -f "$DOCKERFILE" ]; then
  echo "❌ Error: Dockerfile missing at $DOCKERFILE"
  exit 1
fi

if ! grep -q "Oracle.sql-developer-for-vscode" "$DOCKERFILE"; then
  echo "❌ Error: Dockerfile missing Oracle.sql-developer-for-vscode"
  exit 1
fi

if ! grep -q "google.antigravity" "$DOCKERFILE"; then
  echo "❌ Error: Dockerfile missing google.antigravity"
  exit 1
fi

if ! grep -q "oracle.sql.developer.tnsAdmin" "$DOCKERFILE"; then
  echo "❌ Error: Dockerfile missing oracle.sql.developer.tnsAdmin settings"
  exit 1
fi
echo "  ✅ Dockerfile contains all required extensions and pre-configured settings."

# 2. Check install-web-ide-extensions.sh contains both extensions
EXT_SCRIPT="$WORKSPACE_DIR/scripts/internal/install-web-ide-extensions.sh"
if [ ! -f "$EXT_SCRIPT" ]; then
  echo "❌ Error: install-web-ide-extensions.sh missing at $EXT_SCRIPT"
  exit 1
fi

if ! grep -q "Oracle.sql-developer-for-vscode" "$EXT_SCRIPT"; then
  echo "❌ Error: install-web-ide-extensions.sh missing Oracle.sql-developer-for-vscode"
  exit 1
fi

if ! grep -q "google.antigravity" "$EXT_SCRIPT"; then
  echo "❌ Error: install-web-ide-extensions.sh missing google.antigravity"
  exit 1
fi
echo "  ✅ install-web-ide-extensions.sh contains all required extension targets."

# 3. Check web-ide profile
PROFILE_YAML="$WORKSPACE_DIR/config/profiles/web-ide/web-ide-standard.yaml"
if [ -f "$PROFILE_YAML" ]; then
  if ! grep -q "oracle.sql-developer-for-vscode" "$PROFILE_YAML" || ! grep -q "google.antigravity" "$PROFILE_YAML"; then
    echo "❌ Error: web-ide-standard.yaml missing extension definitions"
    exit 1
  fi
  echo "  ✅ web-ide-standard.yaml profile defines both extensions."
fi

echo "✅ All Web IDE extension checks passed!"
echo "test-web-ide-extensions: PASS"
