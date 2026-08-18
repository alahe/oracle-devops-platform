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
  echo "❌ Viga: TNS/Wallet kataloogi ei leitud ($TNS_DIR)!"
  exit 1
fi

echo "=================================================================="
echo "🔐 ORACLE SEPS WALLET CI/CD SECRETS EXPORTER"
echo "=================================================================="

# Loo ajutine ZIP pakk Wallet failidest
TMP_ZIP="/tmp/wallet_ci_$$.zip"
(cd "$TNS_DIR" && zip -q -r "$TMP_ZIP" .)


# Konverteeri Base64 sõneks
B64_STR=$(base64 < "$TMP_ZIP" | tr -d '\r\n')
rm -f "$TMP_ZIP"

echo -e "✅ SEPS Wallet edukalt pakitud ja konverteeritud Base64 kujule!"
echo "   Kopeeri allolev sõne GitHub Secrets muutujasse: DB_WALLET_BASE64"
echo "------------------------------------------------------------------"
echo "$B64_STR"
echo "------------------------------------------------------------------"
echo "💡 Kasutamine käsureal (GitHub CLI):"
echo "   gh secret set DB_WALLET_BASE64 -b\"$B64_STR\""
echo "=================================================================="
