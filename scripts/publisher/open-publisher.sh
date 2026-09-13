#!/usr/bin/env bash
# ============================================================================
# scripts/publisher/open-publisher.sh
# 1-Click Zero-Trust Browser Launcher for Oracle Analytics Publisher (BIP)
# Usage:
#   ./scripts/publisher/open-publisher.sh [role] [report_path]
# Examples:
#   ./scripts/publisher/open-publisher.sh
#   ./scripts/publisher/open-publisher.sh developer
#   ./scripts/publisher/open-publisher.sh user
#   ./scripts/publisher/open-publisher.sh admin
#   ./scripts/publisher/open-publisher.sh developer Custom/Invoices/Invoice_Report
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

ROLE=""
REPORT_ARG=""
DRY_RUN=false

for arg in "$@"; do
  case "$arg" in
    --dry-run|-n)
      DRY_RUN=true
      ;;
    -h|--help)
      echo "Kasutus: $0 [developer|user|admin|weblogic] [raporti_tee] [--dry-run]"
      exit 0
      ;;
    -*)
      ;;
    *)
      if [ -z "$ROLE" ]; then
        ROLE="$arg"
      elif [ -z "$REPORT_ARG" ]; then
        REPORT_ARG="$arg"
      fi
      ;;
  esac
done

[ -z "$ROLE" ] && ROLE="developer"

# Map input role to BIP username
case "$(echo "$ROLE" | tr '[:upper:]' '[:lower:]')" in
  developer|dev|bip_developer)
    BIP_USER="bip_developer"
    ROLE_TITLE="Developer (bip_developer)"
    ;;
  user|viewer|bip_user)
    BIP_USER="bip_user"
    ROLE_TITLE="User (bip_user)"
    ;;
  admin|administrator|bip_admin)
    BIP_USER="bip_admin"
    ROLE_TITLE="Admin (bip_admin)"
    ;;
  weblogic|sys|system)
    BIP_USER="weblogic"
    ROLE_TITLE="WebLogic Admin (weblogic)"
    ;;
  *)
    BIP_USER="$ROLE"
    ROLE_TITLE="$ROLE"
    ;;
esac

# Construct destination path
if [ -n "$REPORT_ARG" ]; then
  CLEAN_PATH="$(echo "$REPORT_ARG" | sed 's|^/||')"
  BASE_NAME="$(basename "$CLEAN_PATH")"
  if [[ "$CLEAN_PATH" == *.xdo ]]; then
    XDO_PATH="/${CLEAN_PATH}"
  else
    XDO_PATH="/${CLEAN_PATH}/${BASE_NAME}.xdo"
  fi
  DEST_URL="$XDO_PATH"
  TARGET_TITLE="Raport: $XDO_PATH"
else
  DEST_URL="/servlet/home"
  TARGET_TITLE="Publisheri Peaportaal (/xmlpserver/servlet/home)"
fi

BRIDGE_PORT="${DEV_HUB_BRIDGE_PORT:-8089}"
BRIDGE_BASE="http://localhost:${BRIDGE_PORT}"

# Verify if Dev Hub Bridge is active, start if not running
if ! curl -s --max-time 1 "${BRIDGE_BASE}/api/status" >/dev/null 2>&1; then
  echo "⏳ Käivitan Dev Hub Bridge taustal (port: ${BRIDGE_PORT})..."
  python3 "$WORKSPACE_DIR/scripts/internal/dev-hub-bridge.py" >/dev/null 2>&1 &
  sleep 1
fi

LAUNCH_URL="${BRIDGE_BASE}/api/publisher/open?user=${BIP_USER}&dest=$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "$DEST_URL")"

echo "=================================================================="
echo "📑 ORACLE ANALYTICS PUBLISHER 1-CLICK LAUNCHER (Rule 5 Zero-Trust)"
echo "=================================================================="
echo "   👤 Roll:     ${ROLE_TITLE}"
echo "   🎯 Sihtkoht: ${TARGET_TITLE}"
echo "   🌐 URL:      ${LAUNCH_URL}"
echo "=================================================================="


if [ "$DRY_RUN" = "true" ]; then
  echo "ℹ️  Dry-run režiim: sirvijat ei avata automaatselt."
  exit 0
fi

# Open default OS browser
if [ "$CI" != "true" ] && [ -z "$SANDBOX_PORT" ]; then
  if command -v open >/dev/null 2>&1; then
    open "$LAUNCH_URL" 2>/dev/null || echo "👉 Ava link käsitsi: $LAUNCH_URL"
  elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$LAUNCH_URL" 2>/dev/null || echo "👉 Ava link käsitsi: $LAUNCH_URL"
  elif command -v cmd.exe >/dev/null 2>&1; then
    cmd.exe /c start "$LAUNCH_URL" 2>/dev/null || echo "👉 Ava link käsitsi: $LAUNCH_URL"
  else
    echo "👉 Ava järgnev link oma veebisirvijas:"
    echo "   $LAUNCH_URL"
  fi
else
  echo "👉 Ava järgnev link oma veebisirvijas:"
  echo "   $LAUNCH_URL"
fi

exit 0
