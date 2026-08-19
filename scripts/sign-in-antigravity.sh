#!/usr/bin/env bash
# ============================================================================
# Google Antigravity & Google Account Sign-In Helper
# Authenticates your Google Account (Free or PRO plan) for Antigravity AI
# Usage: ./scripts/sign-in-antigravity.sh
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
WEB_IDE_CONTAINER="${WEB_IDE_CONTAINER_NAME:-web-ide-dev}"

echo "=================================================================="
echo "🔑 GOOGLE ANTIGRAVITY & GOOGLE KONTO SISSELOGIMINE (Free / PRO)"
echo "=================================================================="
echo ""
echo "Google Antigravity tehisintellekt kasutab sinu Google kontot (Free või PRO plaan)."
echo ""
echo "👉 Viis 1: Sisselogimine brauseri Web IDE liideses (http://localhost:8090):"
echo "   1. Ava Web IDE brauseris: http://localhost:8090"
echo "   2. Vajuta klahve Cmd+Shift+P (või Ctrl+Shift+P)."
echo "   3. Trüki otsingusse: \"Google: Sign In\" või \"Cloud Code: Sign In\""
echo "   4. Logi sisse oma Google kontoga, millel on aktiivne Free või PRO plaan."
echo ""
echo "------------------------------------------------------------------"
echo "👉 Viis 2: Käsurea autentimine konteineris:"
echo "   Käivitan Google autentimise konteineri sees..."
echo "------------------------------------------------------------------"

if podman container exists "$WEB_IDE_CONTAINER" 2>/dev/null; then
  podman exec -it "$WEB_IDE_CONTAINER" bash -c "gcloud auth login --no-launch-browser || echo 'Sisselogimise lingi saamiseks kasuta Web IDE brauseripaneeli.'" 2>/dev/null || true
fi

echo ""
echo "=================================================================="
echo "✅ Kui sisselogimine on sooritatud, on sinu Google Antigravity Free/PRO plaan aktiivne!"
echo "=================================================================="
