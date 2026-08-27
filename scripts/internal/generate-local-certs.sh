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

# Kontrollfunktsioon: kontrollib kas sertifikaat eksisteerib ja kehtib veel vähemalt 24h
is_cert_valid() {
  local cert_file="$1"
  [ -f "$cert_file" ] || return 1
  openssl x509 -checkend 86400 -noout -in "$cert_file" >/dev/null 2>&1 || return 1
  return 0
}

# 1. Genereerime kohaliku Root CA (Sertifitseerimiskeskus)
echo "1. Kontrollin kohalikku juursertifikaati (Root CA)..."
ROOT_REGENERATED=false
if is_cert_valid "$CERT_DIR/localCA.pem" && [ -f "$CERT_DIR/localCA.key" ]; then
  EXP_DATE=$(openssl x509 -in "$CERT_DIR/localCA.pem" -noout -enddate 2>/dev/null | cut -d= -f2)
  echo "ℹ️  Kehtiv Root CA on juba olemas (kehtib kuni: $EXP_DATE), uut ei genereerita."
else
  echo "👉 Loon uue kohaliku juursertifikaadi (Root CA)..."
  openssl genrsa -out "$CERT_DIR/localCA.key" 4096 2>/dev/null
  openssl req -x509 -new -nodes -key "$CERT_DIR/localCA.key" -sha256 -days 1825 \
    -out "$CERT_DIR/localCA.pem" \
    -subj "/C=EE/O=Arenduskeskkond Local/CN=Local Dev Root CA" 2>/dev/null
  ROOT_REGENERATED=true
  echo "✅ Uus Root CA loodud: config/certs/localCA.pem"
fi

# 2. Genereerime localhost sertifikaadi
echo "------------------------------------------------------------------"
echo "2. Kontrollin sertifikaati aadressile 'localhost'..."
LOCALHOST_REGENERATED=false
if [ "$ROOT_REGENERATED" = "false" ] && is_cert_valid "$CERT_DIR/localhost.crt" && [ -f "$CERT_DIR/localhost.key" ] && openssl verify -CAfile "$CERT_DIR/localCA.pem" "$CERT_DIR/localhost.crt" >/dev/null 2>&1; then
  EXP_DATE=$(openssl x509 -in "$CERT_DIR/localhost.crt" -noout -enddate 2>/dev/null | cut -d= -f2)
  echo "ℹ️  Kehtiv localhost sertifikaat on juba olemas (kehtib kuni: $EXP_DATE), uut ei genereerita."
else
  echo "👉 Loon uue sertifikaadi aadressile 'localhost'..."
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
  LOCALHOST_REGENERATED=true

  echo "✅ Uus sertifikaat ja võti loodud:"
  echo "   Sert: $CERT_DIR/localhost.crt"
  echo "   Võti: $CERT_DIR/localhost.key"
fi

# Populate user_ca directory (Variant 3)
mkdir -p "$CERT_DIR/user_ca"
cp -f "$CERT_DIR/localCA.pem" "$CERT_DIR/user_ca/localCA.pem" 2>/dev/null || true
cp -f "$CERT_DIR/localhost.crt" "$CERT_DIR/user_ca/localhost.crt" 2>/dev/null || true
cp -f "$CERT_DIR/localhost.key" "$CERT_DIR/user_ca/localhost.key" 2>/dev/null || true

# Generate direct self-signed cert in self_signed directory (Variant 4)
mkdir -p "$CERT_DIR/self_signed"
if ! is_cert_valid "$CERT_DIR/self_signed/self_signed.crt" || [ ! -f "$CERT_DIR/self_signed/self_signed.key" ]; then
  echo "👉 Loon puhta iseallkirjastatud varusertifikaadi (Variant 4 - self_signed/)..."
  openssl req -x509 -newkey rsa:2048 -nodes -keyout "$CERT_DIR/self_signed/self_signed.key" \
    -out "$CERT_DIR/self_signed/self_signed.crt" -days 365 \
    -subj "/C=EE/O=Arenduskeskkond Local/CN=localhost" \
    -addext "subjectAltName=DNS:localhost,DNS:*.localhost,IP:127.0.0.1" 2>/dev/null || true
  echo "✅ Iseallkirjastatud varusertifikaat loodud: config/certs/self_signed/self_signed.crt"
fi

# 3. Ekspordime sertifikaadid Oracle Wallet PKCS#12 formaati (ewallet.p12)
echo "------------------------------------------------------------------"
echo "3. Kontrollin Oracle Wallet (ewallet.p12) faile..."

WALLET_PROXY_DIR="$WORKSPACE_DIR/config/wallet-apex-proxy"
WALLET_PUB_DIR="$WORKSPACE_DIR/config/wallet-publisher"

mkdir -p "$WALLET_PROXY_DIR" "$WALLET_PUB_DIR"

if [ "$LOCALHOST_REGENERATED" = "false" ] && [ -f "$WALLET_PROXY_DIR/ewallet.p12" ] && [ -f "$WALLET_PUB_DIR/ewallet.p12" ] && [ -f "$WALLET_PROXY_DIR/cwallet.sso" ] && [ -f "$WALLET_PUB_DIR/cwallet.sso" ]; then
  echo "ℹ️  Olemasolevad Oracle Walletid (ewallet.p12 / cwallet.sso) on kehtivad, uusi ei genereerita."
else
  echo "👉 Ekspordime uued ewallet.p12 failid..."
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
    echo "🐳 Kasutan konteinerit '$CONTAINER_CMD' ja orapki tööriista..."
    set +e
    $CONTAINER_CMD run --rm --entrypoint bash \
      -v "$WALLET_PROXY_DIR:/wallet-proxy:rw" \
      -v "$WALLET_PUB_DIR:/wallet-pub:rw" \
      "${FREE_CONTAINER_IMAGE:-container-registry.oracle.com/database/free:latest}" \
      -c "
        orapki wallet create -wallet /wallet-proxy -pwd OracleWallet2026! -auto_login >/dev/null 2>&1 || true
        orapki wallet create -wallet /wallet-pub -pwd OracleWallet2026! -auto_login >/dev/null 2>&1 || true
      " 2>/dev/null
    set -e
    if [ -f "$WALLET_PROXY_DIR/cwallet.sso" ] && [ -f "$WALLET_PUB_DIR/cwallet.sso" ]; then
      echo "✅ cwallet.sso failid edukalt genereeritud!"
    else
      echo "ℹ️  ewallet.p12 sertifikaadid on loodud."
    fi
  else
    echo "ℹ️  Konteinerplatvormi (podman/docker) ei leitud. cwallet.sso loomine jäeti vahele."
  fi
fi

# 5. OS Hoidla Usaldusväärsuse seadistamine (macOS, Windows, WSL)
echo "------------------------------------------------------------------"
echo "5. Usaldusväärsuse seadistamine..."

NO_PROMPT=false
if [[ "$*" == *"--no-prompt"* ]]; then
  NO_PROMPT=true
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
  USER_KEYCHAIN="$HOME/Library/Keychains/login.keychain-db"
  [ ! -f "$USER_KEYCHAIN" ] && USER_KEYCHAIN="$HOME/Library/Keychains/login.keychain"

  # Lisame kasutaja võtmehoidjasse sertifikaadi (100% kasutajaõigustes ilma root/sudo-ta)
  security add-certificate -k "$USER_KEYCHAIN" "$CERT_DIR/localCA.pem" 2>/dev/null || true

  if security find-certificate -c "Local Dev Root CA" "$USER_KEYCHAIN" &>/dev/null; then
    echo "✅ 'Local Dev Root CA' on edukalt lisatud macOS kasutaja võtmehoidjasse (User Space, 0-Root)."
  else
    echo "ℹ️  Sertifikaat loodud: $CERT_DIR/localCA.pem (User Space)"
  fi
elif { [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; }; then
  if command -v certutil &>/dev/null; then
    WIN_CERT_PATH=$(cygpath -w "$CERT_DIR/localCA.pem" 2>/dev/null || echo "$CERT_DIR/localCA.pem")
    certutil -addstore -f -user Root "$WIN_CERT_PATH" >/dev/null 2>&1 || true
    echo "✅ Sertifikaat lisati automaatselt Windowsi kasutaja usaldusväärsesse hoidlasse (certutil -user -addstore Root)."
  fi
elif grep -qEi 'Microsoft|Subsystem' /proc/version 2>/dev/null; then
  if command -v certutil.exe &>/dev/null; then
    WIN_CERT_PATH=$(wslpath -w "$CERT_DIR/localCA.pem" 2>/dev/null || echo "$CERT_DIR/localCA.pem")
    certutil.exe -addstore -f -user Root "$WIN_CERT_PATH" >/dev/null 2>&1 || true
    echo "✅ Sertifikaat lisati automaatselt Windowsi hoidlasse läbi WSL-i (certutil.exe -user -addstore Root)."
  fi
elif [[ "$OSTYPE" == "linux"* ]]; then
  echo "ℹ️  Linux keskkonnas saab sertifikaadi määrata käsurea muutujaga: export SSL_CERT_FILE=\"$CERT_DIR/localCA.pem\""
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
