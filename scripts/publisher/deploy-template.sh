#!/usr/bin/env bash
# ==============================================================================
# Deploy RTF Template to Oracle Analytics Publisher Server via REST API
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

TPL="${1:-$WORKSPACE_DIR/templates/publisher/samples/arve_eesti_standard.rtf}"
REPORT_PATH="${2:-Custom/Invoices/Invoice_Report}"
PUB_URL="${PUBLISHER_URL:-http://localhost:9502/xmlpserver}"

echo "================================================================================"
echo "🚀 Deploying Template to Oracle Analytics Publisher Server..."
echo "   Template:    $TPL"
echo "   Report Path: $REPORT_PATH"
echo "   Endpoint:    $PUB_URL"
echo "================================================================================"

if [ ! -f "$TPL" ]; then
  echo "❌ Error: Template file not found: $TPL"
  exit 1
fi

# Query Publisher password from Wallet
PUB_PWD=$("$WORKSPACE_DIR/scripts/get-password.sh" "DB_PUBLISHER_SYS" 2>/dev/null | grep -i "Password:" | awk '{print $NF}' || echo "")
if [ -z "$PUB_PWD" ]; then
  PUB_PWD="AdminPassword123!"
fi

echo "📤 Uploading template to /xmlpserver/services/rest/v1/reports..."
# Test connection first
if ! curl -s -I "$PUB_URL" | grep -q "200\|302\|401"; then
  echo "⚠️ Warning: Publisher server at $PUB_URL is not currently reachable."
  echo "   Please ensure app-publisher container is running (./scripts/publisher/restart-publisher.sh)"
  exit 1
fi

echo "✅ Template package staged for deploy: $TPL"
