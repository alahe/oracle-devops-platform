#!/usr/bin/env bash
# ============================================================================
# Oracle Wallet Credential Reader
# Automates the lookup of credentials inside the client wallet (ADB & Standard)
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Laeme keskkonnamuutujad
if [ -f "$WORKSPACE_DIR/.env" ]; then
  set -a
  source "$WORKSPACE_DIR/.env"
  set +a
fi

ALIAS="$1"

if [ -z "$ALIAS" ]; then
  echo "Kasutus: $0 <alias_nimi> (nt ADMIN, APEX_ADMIN, DB_TEST_DEV, TEST_WEB_USER, DB_APEX_PROXY_SYS)"
  exit 1
fi

PRIMARY_CONTAINER=$(get_active_db_instances 2>/dev/null | head -n 1 | cut -d'|' -f1)
PRIMARY_CONTAINER="${PRIMARY_CONTAINER:-db-dev-full}"
if ! podman container exists "$PRIMARY_CONTAINER" 2>/dev/null; then
  for c_entry in $(get_active_db_instances 2>/dev/null); do
    c_name=$(echo "$c_entry" | cut -d'|' -f1)
    if podman container exists "$c_name" 2>/dev/null; then
      PRIMARY_CONTAINER="$c_name"
      break
    fi
  done
fi
PROXY_CONTAINER="$PRIMARY_CONTAINER"
PRIMARY_UPPER=$(echo "$PRIMARY_CONTAINER" | tr '-' '_' | tr '[:lower:]' '[:upper:]')

source "$SCRIPT_DIR/load-profile.sh"
load_db_profile >/dev/null 2>&1 || true

# Dynamic alias resolution using active container name from .env and profile
ALIAS_UPPER=$(echo "$ALIAS" | tr '[:lower:]' '[:upper:]')

case "$ALIAS_UPPER" in
  "ADMIN") ALIAS_SEARCH="APEX_ADMIN" ;;
  "SYS"|"SYSDBA") ALIAS_SEARCH="DB_${PRIMARY_UPPER}_SYS" ;;
  "TEST_DEV"|"DB_TEST_DEV") ALIAS_SEARCH="DB_${PRIMARY_UPPER}_DEV" ;;
  *) ALIAS_SEARCH="$ALIAS" ;;
esac

if ! podman container exists "$PROXY_CONTAINER" 2>/dev/null; then
  echo "❌ Viga: $PROXY_CONTAINER konteiner ei tööta!"
  exit 1
fi

# Tuvastame, kas kasutusel on ADB või Standard wallet
IS_ADB=false
if [ "$APEX_DB_TYPE" = "ADB" ] || [[ "$APEX_DB_IMAGE" == *"adb-free"* ]] || podman exec "$PROXY_CONTAINER" test -d /u01/app/oracle/wallets/tls_wallet 2>/dev/null; then
  IS_ADB=true
fi

if [ "$IS_ADB" = "true" ]; then
  WALLET_PATH="/u01/app/oracle/wallets/tls_wallet"
  WALLET_PWD=$(podman exec "$PROXY_CONTAINER" sh -c 'echo $WALLET_PASSWORD' 2>/dev/null | tr -d '\r')
  WALLET_PWD="${WALLET_PWD:-$(get_wallet_password)}"
else
  WALLET_PATH="/opt/oracle/admin/FREE/wallet"
  WALLET_PWD="$(get_wallet_password)"
fi

if [ -z "$WALLET_PWD" ]; then
  echo "❌ Viga: Wallet parool puudub!"
  exit 1
fi

# Otsime listist vastava aliase indeksit
echo "🔍 Otsin Walletist aliasele '$ALIAS' vastavat indeksit..."
LIST_OUT=$(podman exec -i "$PROXY_CONTAINER" sh -c 'export JAVA_HOME=/usr/java/latest; export PATH=$JAVA_HOME/bin:$PATH; echo "$1" | mkstore -wrl "'"$WALLET_PATH"'" -listCredential' -- "$WALLET_PWD" 2>/dev/null || true)

# Parsime indeksi
INDEX=$(echo "$LIST_OUT" | grep -i -E "^[0-9]+: ($ALIAS_SEARCH|$ALIAS)$" | head -n 1 | cut -d':' -f1 | tr -d ' ' | tr -d '\r')
if [ -z "$INDEX" ]; then
  INDEX=$(echo "$LIST_OUT" | grep -i -E "($ALIAS_SEARCH|$ALIAS)" | head -n 1 | cut -d':' -f1 | tr -d ' ' | tr -d '\r')
fi

if [ -z "$INDEX" ]; then
  echo "❌ Viga: Walletist ei leitud aliast '$ALIAS' (ega '$ALIAS_SEARCH')!"
  exit 1
fi

# Pärime kasutaja ja parooli
USER_VAL=$(podman exec -i "$PROXY_CONTAINER" sh -c 'export JAVA_HOME=/usr/java/latest; export PATH=$JAVA_HOME/bin:$PATH; echo "$1" | mkstore -wrl "'"$WALLET_PATH"'" -viewEntry "oracle.security.client.username'"$INDEX"'"' -- "$WALLET_PWD" 2>/dev/null | grep "=" | cut -d'=' -f2 | tr -d ' ' | tr -d '\r')

PWD_VAL=$(podman exec -i "$PROXY_CONTAINER" sh -c 'export JAVA_HOME=/usr/java/latest; export PATH=$JAVA_HOME/bin:$PATH; echo "$1" | mkstore -wrl "'"$WALLET_PATH"'" -viewEntry "oracle.security.client.password'"$INDEX"'"' -- "$WALLET_PWD" 2>/dev/null | grep "=" | cut -d'=' -f2 | tr -d ' ' | tr -d '\r')

# If PWD_VAL is empty, contains question marks from binary mkstore output, or contains unprintable bytes
if [ -z "$PWD_VAL" ] || [[ "$PWD_VAL" == *"?"* ]] || echo "$PWD_VAL" | grep -q '[^[:print:]]'; then
  case "$ALIAS_UPPER" in
    "SYS"|"SYSDBA"|"DB_APEX_PROXY_SYS"|*"_SYS")
      PWD_VAL=$(podman secret inspect --showsecret apex_db_sys_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
      [ -z "$PWD_VAL" ] && PWD_VAL=$(podman exec "$PROXY_CONTAINER" cat /run/secrets/oracle_pwd 2>/dev/null | tr -d '\r\n' || true)
      [ -z "$PWD_VAL" ] && PWD_VAL=$(podman exec "$PROXY_CONTAINER" cat /run/secrets/apex_db_sys_password 2>/dev/null | tr -d '\r\n' || true)
      ;;
    "TEST_DEV"|"DB_TEST_DEV"|*"_DEV")
      PWD_VAL=$(podman secret inspect --showsecret apex_db_dev_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
      [ -z "$PWD_VAL" ] && PWD_VAL=$(podman exec "$PROXY_CONTAINER" cat /run/secrets/apex_db_dev_password 2>/dev/null | tr -d '\r\n' || true)
      ;;
    "ADMIN"|"APEX_ADMIN")
      PWD_VAL=$(podman secret inspect --showsecret apex_admin_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
      [ -z "$PWD_VAL" ] && PWD_VAL=$(podman exec "$PROXY_CONTAINER" cat /run/secrets/apex_admin_password 2>/dev/null | tr -d '\r\n' || true)
      ;;
    "TEST_WEB_USER")
      PWD_VAL=$(podman secret inspect --showsecret test_web_user_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
      [ -z "$PWD_VAL" ] && PWD_VAL=$(podman exec "$PROXY_CONTAINER" cat /run/secrets/test_web_user_password 2>/dev/null | tr -d '\r\n' || true)
      ;;
  esac
fi

echo "=================================================================="
echo -e "🔓 Wallet Credential Details for Alias: \033[1;36m$ALIAS\033[0m"
echo -e "   👤 Username: \033[1;32m$USER_VAL\033[0m"
echo -e "   🔑 Password: \033[1;33m$PWD_VAL\033[0m"
echo "=================================================================="

