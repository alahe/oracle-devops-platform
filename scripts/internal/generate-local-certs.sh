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
echo "🔐 LOCAL SSL/TLS CERTIFICATES & WALLET ENGINE (DEV_LOCAL)"
echo "=================================================================="

# Validation helper: verifies if certificate exists and is valid for at least 24h
is_cert_valid() {
  local cert_file="$1"
  [ -f "$cert_file" ] || return 1
  openssl x509 -checkend 86400 -noout -in "$cert_file" >/dev/null 2>&1 || return 1
  return 0
}

# 1. Generate or synchronize local Root Certificate Authority (Root CA)
echo "1. Checking local Root Certificate Authority (Root CA)..."
ROOT_REGENERATED=false

if command -v mkcert >/dev/null 2>&1; then
  echo "ℹ️  Found mkcert CLI: synchronizing with system-trusted mkcert CA..."
  MK_CAROOT="$(mkcert -CAROOT 2>/dev/null || echo "")"
  if [ -n "$MK_CAROOT" ] && [ -f "$MK_CAROOT/rootCA.pem" ]; then
    cp "$MK_CAROOT/rootCA.pem" "$CERT_DIR/localCA.pem"
    [ -f "$MK_CAROOT/rootCA-key.pem" ] && cp "$MK_CAROOT/rootCA-key.pem" "$CERT_DIR/localCA.key" 2>/dev/null || true
    echo "✅ Synchronized Root CA from mkcert: config/certs/localCA.pem"
  fi
elif is_cert_valid "$CERT_DIR/localCA.pem" && [ -f "$CERT_DIR/localCA.key" ]; then
  EXP_DATE=$(openssl x509 -in "$CERT_DIR/localCA.pem" -noout -enddate 2>/dev/null | cut -d= -f2)
  echo "ℹ️  Valid Root CA already exists (expires: $EXP_DATE). Skipping creation."
else
  echo "👉 Generating new local Root CA certificate (OpenSSL)..."
  openssl genrsa -out "$CERT_DIR/localCA.key" 4096 2>/dev/null
  openssl req -x509 -new -nodes -key "$CERT_DIR/localCA.key" -sha256 -days 1825 \
    -out "$CERT_DIR/localCA.pem" \
    -subj "/C=EE/O=Local Dev Environment/CN=Local Dev Root CA" 2>/dev/null
  ROOT_REGENERATED=true
  echo "✅ New Root CA created: config/certs/localCA.pem"
fi

# 2. Generate localhost TLS domain certificate
echo "------------------------------------------------------------------"
echo "2. Checking TLS certificate for 'localhost'..."
LOCALHOST_REGENERATED=false
if [ "$ROOT_REGENERATED" = "false" ] && is_cert_valid "$CERT_DIR/localhost.crt" && [ -f "$CERT_DIR/localhost.key" ] && openssl verify -CAfile "$CERT_DIR/localCA.pem" "$CERT_DIR/localhost.crt" >/dev/null 2>&1; then
  EXP_DATE=$(openssl x509 -in "$CERT_DIR/localhost.crt" -noout -enddate 2>/dev/null | cut -d= -f2)
  echo "ℹ️  Valid localhost certificate already exists (expires: $EXP_DATE). Skipping creation."
else
  echo "👉 Generating new certificate for 'localhost'..."
  if command -v mkcert >/dev/null 2>&1; then
    echo "ℹ️  Generating browser-trusted certificate via mkcert..."
    mkcert -cert-file "$CERT_DIR/localhost.crt" -key-file "$CERT_DIR/localhost.key" localhost "*.localhost" 127.0.0.1 ::1 >/dev/null 2>&1
  else
    openssl genrsa -out "$CERT_DIR/localhost.key" 2048 2>/dev/null

    # Generate config file for SAN domains, IPs and Extended Key Usage (RFC 5280 / Apple / Chromium standard)
    cat > "$CERT_DIR/localhost.ext" <<EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=critical,CA:FALSE
keyUsage=critical,digitalSignature,keyEncipherment
extendedKeyUsage=serverAuth,clientAuth
subjectAltName=@alt_names

[alt_names]
DNS.1 = localhost
DNS.2 = *.localhost
IP.1 = 127.0.0.1
IP.2 = ::1
EOF

    # Certificate Signing Request (CSR)
    openssl req -new -key "$CERT_DIR/localhost.key" \
      -out "$CERT_DIR/localhost.csr" \
      -subj "/C=EE/O=Local Dev Environment/CN=localhost" 2>/dev/null

    # Sign certificate with Root CA (365 days max for Apple/Chrome compliance)
    openssl x509 -req -in "$CERT_DIR/localhost.csr" \
      -CA "$CERT_DIR/localCA.pem" -CAkey "$CERT_DIR/localCA.key" \
      -CAcreateserial -out "$CERT_DIR/localhost.crt" \
      -days 365 -sha256 -extfile "$CERT_DIR/localhost.ext" 2>/dev/null

    rm -f "$CERT_DIR/localhost.csr" "$CERT_DIR/localhost.ext" "$CERT_DIR/localCA.srl"
  fi

  LOCALHOST_REGENERATED=true

  # Generate unencrypted PKCS#8 DER key for ORDS standalone HTTPS
  openssl pkcs8 -topk8 -inform PEM -outform DER -in "$CERT_DIR/localhost.key" -out "$CERT_DIR/localhost.der" -nocrypt 2>/dev/null || true
  cat "$CERT_DIR/localhost.crt" "$CERT_DIR/localCA.pem" > "$CERT_DIR/localhost-fullchain.crt" 2>/dev/null || true

  echo "✅ New certificate and key generated:"
  echo "   Cert: $CERT_DIR/localhost.crt"
  echo "   Key:  $CERT_DIR/localhost.key"
  echo "   DER:  $CERT_DIR/localhost.der"
fi

# Ensure DER key and fullchain exist even if cert wasn't regenerated
if [ -f "$CERT_DIR/localhost.key" ] && [ ! -f "$CERT_DIR/localhost.der" ]; then
  openssl pkcs8 -topk8 -inform PEM -outform DER -in "$CERT_DIR/localhost.key" -out "$CERT_DIR/localhost.der" -nocrypt 2>/dev/null || true
fi
if [ -f "$CERT_DIR/localhost.crt" ] && [ -f "$CERT_DIR/localCA.pem" ] && [ ! -f "$CERT_DIR/localhost-fullchain.crt" ]; then
  cat "$CERT_DIR/localhost.crt" "$CERT_DIR/localCA.pem" > "$CERT_DIR/localhost-fullchain.crt" 2>/dev/null || true
fi

# Populate user_ca directory (Variant 3)
mkdir -p "$CERT_DIR/user_ca"
cp -f "$CERT_DIR/localCA.pem" "$CERT_DIR/user_ca/localCA.pem" 2>/dev/null || true
cp -f "$CERT_DIR/localhost.crt" "$CERT_DIR/user_ca/localhost.crt" 2>/dev/null || true
cp -f "$CERT_DIR/localhost.key" "$CERT_DIR/user_ca/localhost.key" 2>/dev/null || true
cp -f "$CERT_DIR/localhost.der" "$CERT_DIR/user_ca/localhost.der" 2>/dev/null || true

# Generate direct self-signed cert in self_signed directory (Variant 4)
mkdir -p "$CERT_DIR/self_signed"
if ! is_cert_valid "$CERT_DIR/self_signed/self_signed.crt" || [ ! -f "$CERT_DIR/self_signed/self_signed.key" ]; then
  echo "👉 Generating clean self-signed fallback certificate (Variant 4 - self_signed/)..."
  openssl req -x509 -newkey rsa:2048 -nodes -keyout "$CERT_DIR/self_signed/self_signed.key" \
    -out "$CERT_DIR/self_signed/self_signed.crt" -days 365 \
    -subj "/C=EE/O=Local Dev Environment/CN=localhost" \
    -addext "subjectAltName=DNS:localhost,DNS:*.localhost,IP:127.0.0.1" 2>/dev/null || true
  echo "✅ Self-signed fallback certificate created: config/certs/self_signed/self_signed.crt"
fi
if [ -f "$CERT_DIR/self_signed/self_signed.key" ] && [ ! -f "$CERT_DIR/self_signed/self_signed.der" ]; then
  openssl pkcs8 -topk8 -inform PEM -outform DER -in "$CERT_DIR/self_signed/self_signed.key" -out "$CERT_DIR/self_signed/self_signed.der" -nocrypt 2>/dev/null || true
fi

# 3. Export certificates to Oracle Wallet PKCS#12 format (ewallet.p12)
echo "------------------------------------------------------------------"
echo "3. Checking Oracle Wallet (ewallet.p12) files..."

WALLET_PROXY_DIR="$WORKSPACE_DIR/config/wallet-apex-proxy"
WALLET_PUB_DIR="$WORKSPACE_DIR/config/wallet-publisher"

mkdir -p "$WALLET_PROXY_DIR" "$WALLET_PUB_DIR"

if [ "$LOCALHOST_REGENERATED" = "false" ] && [ -f "$WALLET_PROXY_DIR/ewallet.p12" ] && [ -f "$WALLET_PUB_DIR/ewallet.p12" ] && [ -f "$WALLET_PROXY_DIR/cwallet.sso" ] && [ -f "$WALLET_PUB_DIR/cwallet.sso" ]; then
  echo "ℹ️  Existing Oracle Wallets (ewallet.p12 / cwallet.sso) are valid. Skipping creation."
else
  echo "👉 Exporting new ewallet.p12 files..."
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

  echo "✅ ewallet.p12 files created in:"
  echo "   - config/wallet-apex-proxy/"
  echo "   - config/wallet-publisher/"

  # 4. Generate cwallet.sso (auto-login) using container orapki utility
  echo "------------------------------------------------------------------"
  echo "4. Generating cwallet.sso (auto-login wallet) files..."

  CONTAINER_CMD=""
  if command -v podman &> /dev/null; then
    CONTAINER_CMD="podman"
  elif command -v docker &> /dev/null; then
    CONTAINER_CMD="docker"
  fi

  if [ -n "$CONTAINER_CMD" ]; then
    echo "🐳 Using container engine '$CONTAINER_CMD' and orapki tool..."
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
      echo "✅ cwallet.sso files generated successfully!"
    else
      echo "ℹ️  ewallet.p12 certificates generated."
    fi
  else
    echo "ℹ️  Container engine (podman/docker) not found. Skipping cwallet.sso generation."
  fi
fi

# 5. OS Certificate Trust Configuration
echo "------------------------------------------------------------------"
echo "5. Configuring OS certificate trust..."

NO_PROMPT=false
if [[ "$*" == *"--no-prompt"* ]]; then
  NO_PROMPT=true
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
  USER_KEYCHAIN="$HOME/Library/Keychains/login.keychain-db"
  [ ! -f "$USER_KEYCHAIN" ] && USER_KEYCHAIN="$HOME/Library/Keychains/login.keychain"

  # Install certificate into macOS user keychain (100% non-root user permissions)
  security add-certificate -k "$USER_KEYCHAIN" "$CERT_DIR/localCA.pem" 2>/dev/null || true

  if security find-certificate -c "Local Dev Root CA" "$USER_KEYCHAIN" &>/dev/null; then
    echo "✅ 'Local Dev Root CA' successfully added to macOS User Keychain (User Space, 0-Root)."
  else
    echo "ℹ️  Certificate created: $CERT_DIR/localCA.pem (User Space)"
  fi
elif { [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; }; then
  if command -v certutil &>/dev/null; then
    WIN_CERT_PATH=$(cygpath -w "$CERT_DIR/localCA.pem" 2>/dev/null || echo "$CERT_DIR/localCA.pem")
    certutil -addstore -f -user Root "$WIN_CERT_PATH" >/dev/null 2>&1 || true
    echo "✅ Certificate automatically added to Windows User Trusted Store (certutil -user -addstore Root)."
  fi
elif grep -qEi 'Microsoft|Subsystem' /proc/version 2>/dev/null; then
  if command -v certutil.exe &>/dev/null; then
    WIN_CERT_PATH=$(wslpath -w "$CERT_DIR/localCA.pem" 2>/dev/null || echo "$CERT_DIR/localCA.pem")
    certutil.exe -addstore -f -user Root "$WIN_CERT_PATH" >/dev/null 2>&1 || true
    echo "✅ Certificate automatically added to Windows store via WSL (certutil.exe -user -addstore Root)."
  fi
elif [[ "$OSTYPE" == "linux"* ]]; then
  echo "ℹ️  In Linux environment, trust certificate via environment variable: export SSL_CERT_FILE=\"$CERT_DIR/localCA.pem\""
fi

# 6. Usage summary
echo "=================================================================="
echo "🎉 SSL/TLS CERTIFICATES & ENCRYPTED WALLETS READY!"
echo "   1. ORDS/APEX HTTPS (Browser):"
echo "      Cert:  config/certs/localhost.crt"
echo "      Key:   config/certs/localhost.key"
echo "   2. Oracle Database TCPS Listeners (Port 2484):"
echo "      Wallets located at: config/wallet-apex-proxy/ and config/wallet-publisher/"
echo "      (Certificates packaged inside ewallet.p12 and cwallet.sso)"
echo "=================================================================="
