#!/usr/bin/env bash
# ============================================================================
# Oracle SEPS Wallet & CI/CD Secrets Exporter
# Generates Base64 encoded secrets string for GitHub Secrets / .env.secrets
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

TNS_DIR="$WORKSPACE_DIR/config/tns_admin_container"

if [ ! -d "$TNS_DIR" ]; then
  TNS_DIR="$WORKSPACE_DIR/config/tns_admin"
fi

if [ ! -d "$TNS_DIR" ]; then
  echo "❌ Error: TNS/Wallet directory not found ($TNS_DIR)!"
  exit 1
fi

echo "=================================================================="
echo "🔐 ORACLE SEPS WALLET CI/CD SECRETS EXPORTER"
echo "=================================================================="

# Create temporary ZIP package of wallet files
TMP_ZIP="/tmp/wallet_ci_$$.zip"
(cd "$TNS_DIR" && zip -q -r "$TMP_ZIP" .)

# Convert to Base64 string
B64_STR=$(base64 < "$TMP_ZIP" | tr -d '\r\n')
rm -f "$TMP_ZIP"

echo -e "✅ SEPS Wallet compressed and converted to Base64 successfully!"
echo "   Copy the string below to GitHub Secrets variable: DB_WALLET_BASE64"
echo "------------------------------------------------------------------"
echo "$B64_STR"
echo "------------------------------------------------------------------"
echo "💡 Usage via GitHub CLI:"
echo "   gh secret set DB_WALLET_BASE64 -b\"$B64_STR\""
echo "=================================================================="
