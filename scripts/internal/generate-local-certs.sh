#!/usr/bin/env bash
# ============================================================================
# Local CA & Self-Signed SSL Certificate Generator for Local Dev
# Generates certificates for ORDS/APEX HTTPS and trusts them on macOS host.
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
CERT_DIR="$WORKSPACE_DIR/config/certs"

mkdir -p "$CERT_DIR"

echo "=================================================================="
echo "🔐 KOHALIKE SSL SERTIFIKAATIDE GENEREERIMINE (DEV_LOCAL)"
echo "=================================================================="

# 1. Genereerime kohaliku Root CA (Sertifitseerimiskeskus)
echo "1. Loon kohaliku juursertifikaadi (Root CA)..."
if [ ! -f "$CERT_DIR/localCA.key" ]; then
  openssl genrsa -out "$CERT_DIR/localCA.key" 4096 2>/dev/null
  openssl req -x509 -new -nodes -key "$CERT_DIR/localCA.key" -sha256 -days 1825 \
    -out "$CERT_DIR/localCA.pem" \
    -subj "/C=EE/O=Arenduskeskkond Local/CN=Local Dev Root CA" 2>/dev/null
  echo "✅ Root CA loodud: config/certs/localCA.pem"
else
  echo "ℹ️  Root CA on juba olemas, kasutatakse olemasolevat."
fi

# 2. Genereerime localhost sertifikaadi
echo "------------------------------------------------------------------"
echo "2. Loon sertifikaadi aadressile 'localhost'..."

openssl genrsa -out "$CERT_DIR/localhost.key" 2048 2>/dev/null

# Loome config faili domeenide ja IP-de jaoks (Subject Alternative Name - SAN)
cat > "$CERT_DIR/localhost.ext" <<EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
DNS.2 = *.localhost
IP.1 = 127.0.0.1
EOF

# Luuakse sertifikaadi nõue (CSR)
openssl req -new -key "$CERT_DIR/localhost.key" \
  -out "$CERT_DIR/localhost.csr" \
  -subj "/C=EE/O=Arenduskeskkond Local/CN=localhost" 2>/dev/null

# Allkirjastame sertifikaadi meie oma kohaliku Root CA-ga
openssl x509 -req -in "$CERT_DIR/localhost.csr" \
  -CA "$CERT_DIR/localCA.pem" -CAkey "$CERT_DIR/localCA.key" \
  -CAcreateserial -out "$CERT_DIR/localhost.crt" \
  -days 825 -sha256 -extfile "$CERT_DIR/localhost.ext" 2>/dev/null

rm -f "$CERT_DIR/localhost.csr" "$CERT_DIR/localhost.ext" "$CERT_DIR/localCA.srl"

echo "✅ Sertifikaat ja võti loodud:"
echo "   Sert: $CERT_DIR/localhost.crt"
echo "   Võti: $CERT_DIR/localhost.key"

# 3. Ekspordime sertifikaadid Oracle Wallet PKCS#12 formaati (ewallet.p12)
echo "------------------------------------------------------------------"
echo "3. Ekspordime sertifikaadid Oracle Wallet (ewallet.p12) formaati..."

WALLET_PROXY_DIR="$WORKSPACE_DIR/config/wallet-apex-proxy"
WALLET_PUB_DIR="$WORKSPACE_DIR/config/wallet-publisher"

mkdir -p "$WALLET_PROXY_DIR" "$WALLET_PUB_DIR"

# Genereerime ewallet.p12 failid (Oracle loeb neid otse walletina)
openssl pkcs12 -export \
  -out "$WALLET_PROXY_DIR/ewallet.p12" \
  -inkey "$CERT_DIR/localhost.key" \
  -in "$CERT_DIR/localhost.crt" \
  -certfile "$CERT_DIR/localCA.pem" \
  -passout pass:OracleWallet2026! 2>/dev/null

openssl pkcs12 -export \
  -out "$WALLET_PUB_DIR/ewallet.p12" \
  -inkey "$CERT_DIR/localhost.key" \
  -in "$CERT_DIR/localhost.crt" \
  -certfile "$CERT_DIR/localCA.pem" \
  -passout pass:OracleWallet2026! 2>/dev/null

echo "✅ ewallet.p12 failid loodud kaustadesse:"
echo "   - config/wallet-apex-proxy/"
echo "   - config/wallet-publisher/"

# 4. Genereerime cwallet.sso (auto-login) faili kasutades konteineri orapki utiliiti
echo "------------------------------------------------------------------"
echo "4. Genereerin cwallet.sso (auto-login wallet) failid..."

CONTAINER_CMD=""
if command -v podman &> /dev/null; then
  CONTAINER_CMD="podman"
elif command -v docker &> /dev/null; then
  CONTAINER_CMD="docker"
fi

if [ -n "$CONTAINER_CMD" ]; then
  # Käivitame ajutise andmebaasi konteineri, et genereerida orapki abil cwallet.sso
  echo "🐳 Kasutan konteinerit '$CONTAINER_CMD' ja orapki tööriista..."
  set +e
  $CONTAINER_CMD run --rm \
    -v "$WALLET_PROXY_DIR:/wallet-proxy:rw" \
    -v "$WALLET_PUB_DIR:/wallet-pub:rw" \
    gvenzl/oracle-free:23-slim-faststart \
    bash -c "
      orapki wallet create -wallet /wallet-proxy -pwd OracleWallet2026! -auto_login >/dev/null 2>&1
      orapki wallet create -wallet /wallet-pub -pwd OracleWallet2026! -auto_login >/dev/null 2>&1
    " 2>/dev/null
  set -e
  if [ -f "$WALLET_PROXY_DIR/cwallet.sso" ] && [ -f "$WALLET_PUB_DIR/cwallet.sso" ]; then
    echo "✅ cwallet.sso failid edukalt genereeritud!"
  else
    echo "⚠️  Hoiatus: cwallet.sso loomine ebaõnnestus (tõenäoliselt puudub lokaalselt gvenzl/oracle-free pilt). ewallet.p12 on siiski olemas."
  fi
else
  echo "ℹ️  Konteinerplatvormi (podman/docker) ei leitud. cwallet.sso loomine jäeti vahele."
fi

# 5. OS Hoidla Usaldusväärsuse seadistamine (macOS, Windows, WSL)
echo "------------------------------------------------------------------"
echo "5. Usaldusväärsuse seadistamine..."

NO_PROMPT=false
if [[ "$*" == *"--no-prompt"* ]]; then
  NO_PROMPT=true
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
  if ! security find-certificate -c "Local Dev Root CA" /Library/Keychains/System.keychain &>/dev/null; then
    if [ "$NO_PROMPT" = "true" ]; then
      echo "ℹ️  Sertifikaadi usaldamine macOS-is vajab sudo parooli. Käivita vajadusel: sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain config/certs/localCA.pem"
    elif [ -t 0 ]; then
      read -p "❓ Kas soovid sertifikaadi macOS süsteemis usaldada? (y/N): " CONFIRM
      if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
        sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain "$CERT_DIR/localCA.pem"
        echo "✅ Sertifikaat on edukalt lisatud ja usaldatud süsteemis!"
      fi
    fi
  else
    echo "✅ 'Local Dev Root CA' on macOS süsteemis juba usaldatud."
  fi
elif { [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; }; then
  if which certutil &>/dev/null; then
    WIN_CERT_PATH=$(cygpath -w "$CERT_DIR/localCA.pem" 2>/dev/null || echo "$CERT_DIR/localCA.pem")
    certutil -addstore -f -user Root "$WIN_CERT_PATH" >/dev/null 2>&1 || true
    echo "✅ Sertifikaat lisati automaatselt Windowsi kasutaja hoidlas (certutil -user -addstore Root)."
  fi
elif grep -qEi 'Microsoft|Subsystem' /proc/version 2>/dev/null; then
  if which certutil.exe &>/dev/null; then
    WIN_CERT_PATH=$(wslpath -w "$CERT_DIR/localCA.pem" 2>/dev/null || echo "$CERT_DIR/localCA.pem")
    certutil.exe -addstore -f -user Root "$WIN_CERT_PATH" >/dev/null 2>&1 || true
    echo "✅ Sertifikaat lisati automaatselt Windowsi kasutaja hoidlas läbi WSL-i (certutil.exe -user -addstore Root)."
  fi
fi

# 6. Kuidas kasutada
echo "=================================================================="
echo "🎉 SSL SERTIFIKAADID JA WALLETID ON VALMIS!"
echo "   1. ORDS/APEX HTTPS jaoks (brauser):"
echo "      Sert:  config/certs/localhost.crt"
echo "      Võti:  config/certs/localhost.key"
echo "   2. Oracle Database kuulajate jaoks (TCPS port 2484):"
echo "      Walletid asuvad: config/wallet-apex-proxy/ ja config/wallet-publisher/"
echo "      (Sertifikaadid on pakitud ewallet.p12 ja cwallet.sso failidesse)"
echo "=================================================================="
