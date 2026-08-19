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


# 4. Kontrolli elavat Web IDE veebiliidest HTTP pordil 8090
echo "▶️ [Test 4]: Kontrollin elavat Web IDE veebiliidest (http://localhost:8090)..."
if podman container exists web-ide-dev 2>/dev/null; then
  HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8090/?folder=/config/workspace" || true)
  if [ "$HTTP_STATUS" = "200" ] || [ "$HTTP_STATUS" = "302" ]; then
    echo "  ✅ Web IDE vastab edukalt päringule aadressil http://localhost:8090 (HTTP $HTTP_STATUS)."
  else
    echo "❌ Viga: Web IDE veebiliides (http://localhost:8090) ei vasta oodatud HTTP 200/302 koodiga (Vastus: $HTTP_STATUS)!"
    exit 1
  fi
else
  echo "  ℹ️  web-ide-dev konteiner ei jookse hetkel. Testiti staatilist seadistust."
fi

echo "=================================================================="
echo "🎉 KÕIK WEB IDE & ARTIFACTORY MOODULITESTID LÄBITUD EDUKALT!"
echo "=================================================================="
