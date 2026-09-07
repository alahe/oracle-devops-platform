#!/usr/bin/env bash
# ============================================================================
# Unit Test: test-web-ide-extensions.sh
# Validates pre-configuration and installation of Oracle SQL Developer & Antigravity
# ============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "🔍 Validating Web IDE extensions configuration..."

# 1. Check Dockerfile contains extensions, tools and settings
DOCKERFILE="$WORKSPACE_DIR/docker/web-ide/Dockerfile"
if [ ! -f "$DOCKERFILE" ]; then
  echo "❌ Error: Dockerfile missing at $DOCKERFILE"
  exit 1
fi

for ext in "Oracle.sql-developer" "google." "ms-python.python" "github.vscode-github-actions"; do
  if ! grep -q "$ext" "$DOCKERFILE"; then
    echo "❌ Error: Dockerfile missing extension $ext"
    exit 1
  fi
done

for tool in "actionlint" "act" "gh" "yamllint"; do
  if ! grep -q "$tool" "$DOCKERFILE"; then
    echo "❌ Error: Dockerfile missing tool $tool"
    exit 1
  fi
done

if ! grep -q "oracle.sql.developer.tnsAdmin" "$DOCKERFILE"; then
  echo "❌ Error: Dockerfile missing oracle.sql.developer.tnsAdmin settings"
  exit 1
fi

if ! grep -q "workbench.editorAssociations" "$DOCKERFILE" || ! grep -q "files.associations" "$DOCKERFILE"; then
  echo "❌ Error: Dockerfile missing .sql editor/file associations"
  exit 1
fi
echo "  ✅ Dockerfile contains all required extensions, security linters, and pre-configured settings."

# 2. Check install-web-ide-extensions.sh contains required extensions and .sql associations
EXT_SCRIPT="$WORKSPACE_DIR/scripts/internal/install-web-ide-extensions.sh"
if [ ! -f "$EXT_SCRIPT" ]; then
  echo "❌ Error: install-web-ide-extensions.sh missing at $EXT_SCRIPT"
  exit 1
fi

for ext in "Oracle.sql-developer" "google." "ms-python.python" "github.vscode-github-actions"; do
  if ! grep -q "$ext" "$EXT_SCRIPT"; then
    echo "❌ Error: install-web-ide-extensions.sh missing extension $ext"
    exit 1
  fi
done

if ! grep -q "workbench.editorAssociations" "$EXT_SCRIPT" || ! grep -q "files.associations" "$EXT_SCRIPT"; then
  echo "❌ Error: install-web-ide-extensions.sh missing .sql editor/file associations"
  exit 1
fi
echo "  ✅ install-web-ide-extensions.sh contains all required extension targets and .sql associations."

# 3. Check web-ide profile
PROFILE_YAML="$WORKSPACE_DIR/config/profiles/web-ide/web-ide-standard.yaml"
if [ -f "$PROFILE_YAML" ]; then
  for ext in "Oracle.sql-developer" "google." "ms-python.python" "github.vscode-github-actions"; do
    if ! grep -q "$ext" "$PROFILE_YAML"; then
      echo "❌ Error: web-ide-standard.yaml missing extension $ext"
      exit 1
    fi
  done
  echo "  ✅ web-ide-standard.yaml profile defines all required extensions."
fi

echo "✅ All Web IDE extension checks passed!"
echo "test-web-ide-extensions: PASS"
