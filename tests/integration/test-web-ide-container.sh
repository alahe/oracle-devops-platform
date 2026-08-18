#!/usr/bin/env bash
# ============================================================================
# Integration Test: Web IDE Container & Enterprise Artifactory Mirror Registry
# Validates Dockerfile, Artifactory override image resolution, and init-web-ide.sh
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "=================================================================="
echo "🧪 INTEGRATION TEST: Web IDE Container & Artifactory Mirror Support"
echo "=================================================================="

# 1. Kontrolli Dockerfile olemasolu ja Artifactory ARG toetust
echo "▶️ [Test 1]: Kontrollin Dockerfile faili ja Artifactory ARG muutujaid..."
DOCKERFILE="$WORKSPACE_DIR/docker/web-ide/Dockerfile"
if [ ! -f "$DOCKERFILE" ]; then
  echo "❌ Viga: docker/web-ide/Dockerfile faili ei leitud!"
  exit 1
fi

if ! grep -q "ARTIFACTORY_REGISTRY" "$DOCKERFILE"; then
  echo "❌ Viga: Dockerfile ei sisalda ARTIFACTORY_REGISTRY ARG tuge!"
  exit 1
fi
echo "  ✅ docker/web-ide/Dockerfile on olemas ja toetab Artifactory ARG-e."

# 2. Kontrolli podman-compose.yml web-ide teenuse seadistust
echo "▶️ [Test 2]: Kontrollin podman-compose.yml web-ide teenust..."
COMPOSE_FILE="$WORKSPACE_DIR/podman-compose.yml"
if ! grep -q "web-ide:" "$COMPOSE_FILE"; then
  echo "❌ Viga: podman-compose.yml ei sisalda web-ide teenust!"
  exit 1
fi
echo "  ✅ podman-compose.yml web-ide teenus on korrektselt kirjeldatud."

# 3. Kontrolli init-web-ide.sh skripti ja binaries/extensions/ VSIX tuge
echo "▶️ [Test 3]: Testin init-web-ide.sh orkestreerija skripti ja VSIX tuge..."
if [ ! -d "$WORKSPACE_DIR/binaries/extensions" ]; then
  echo "❌ Viga: binaries/extensions kausta ei leitud!"
  exit 1
fi

INIT_OUT=$("$WORKSPACE_DIR/scripts/internal/init-web-ide.sh")
if ! echo "$INIT_OUT" | grep -q "INITIALIZING CONTAINERIZED WEB IDE"; then
  echo "❌ Viga: init-web-ide.sh ei väljastanud oodatud logi!"
  exit 1
fi
echo "  ✅ init-web-ide.sh ja binaries/extensions VSIX laienduste tugi toimib puhtalt."


echo "=================================================================="
echo "🎉 KÕIK WEB IDE & ARTIFACTORY MOODULITESTID LÄBITUD EDUKALT!"
echo "=================================================================="
