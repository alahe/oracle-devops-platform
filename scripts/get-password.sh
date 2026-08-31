#!/usr/bin/env bash
# ============================================================================
# Oracle Wallet Credential Reader
# Automates the lookup of credentials inside the client wallet (ADB & Standard)
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ "$SCRIPT_DIR" == *"/internal" ]] || [[ "$SCRIPT_DIR" == *"/snapshots" ]] || [[ "$SCRIPT_DIR" == *"/certs" ]] || [[ "$SCRIPT_DIR" == *"/publisher" ]] || [[ "$SCRIPT_DIR" == *"/patches" ]]; then
  WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
else
  WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
fi

# Laeme keskkonnamuutujad ja profiilifunktsioonid
if [ -f "$WORKSPACE_DIR/.env" ]; then
  set -a
  source "$WORKSPACE_DIR/.env"
  set +a
fi

if [ -f "$WORKSPACE_DIR/scripts/internal/load-profile.sh" ]; then
  source "$WORKSPACE_DIR/scripts/internal/load-profile.sh"
  load_db_profile >/dev/null 2>&1 || true
fi

if [ -f "$WORKSPACE_DIR/scripts/internal/common.sh" ]; then
  source "$WORKSPACE_DIR/scripts/internal/common.sh"
fi

COPY_CLIPBOARD=false
RAW_ONLY=false
ALIAS=""

while [ $# -gt 0 ]; do
  case "$1" in
    -l=*|--lang=*|-language=*|--language=*)
      export CLI_LANG="${1#*=}"
      shift
      ;;
    -l|--lang|-language|--language)
      export CLI_LANG="$2"
      shift 2
      ;;
    -c|--copy) COPY_CLIPBOARD=true; shift ;;
    -p|--plain|--raw) RAW_ONLY=true; shift ;;
    -h|--help) ALIAS="help"; shift ;;
    *) [ -z "$ALIAS" ] && ALIAS="$1"; shift ;;
  esac
done

if declare -f resolve_cli_lang >/dev/null 2>&1; then
  export ACTIVE_CLI_LANG="$(resolve_cli_lang)"
fi

copy_to_clipboard() {
  local val="$1"
  if command -v pbcopy >/dev/null 2>&1; then
    printf "%s" "$val" | pbcopy
    return 0
  elif command -v wl-copy >/dev/null 2>&1; then
    printf "%s" "$val" | wl-copy
    return 0
  elif command -v xclip >/dev/null 2>&1; then
    printf "%s" "$val" | xclip -selection clipboard
    return 0
  elif command -v xsel >/dev/null 2>&1; then
    printf "%s" "$val" | xsel --clipboard --input
    return 0
  elif command -v clip.exe >/dev/null 2>&1; then
    printf "%s" "$val" | clip.exe
    return 0
  else
    return 1
  fi
}

if [ -z "$ALIAS" ] || [ "$ALIAS" = "--all" ] || [ "$ALIAS" = "-a" ] || [ "$ALIAS" = "help" ]; then
  echo "=================================================================="
  echo "🔐 ORACLE SEPS WALLET & SERVICE CREDENTIALS MATRIX"
  echo "=================================================================="
  printf "┌──────────────────┬─────────────────────┬──────────────────────────┬────────────────────────────────────────────────────────┐\n"
  printf "│ %-16s │ %-19s │ %-24s │ %-54s │\n" "Teenus / DB" "Kasutajanimi" "SEPS Alias" "Otspunkt / URL"
  printf "├──────────────────┼─────────────────────┼──────────────────────────┼────────────────────────────────────────────────────────┤\n"

  for inst in $(get_active_db_instances 2>/dev/null); do
    c_name=$(echo "$inst" | cut -d'|' -f1)
    c_prof=$(echo "$inst" | cut -d'|' -f2)
    c_short=$(echo "$c_name" | sed 's/^db-//' | tr '-' '_' | tr '[:upper:]' '[:lower:]')
    c_upper=$(echo "$c_short" | tr '[:lower:]' '[:upper:]')
    load_db_profile "$c_prof" >/dev/null 2>&1 || true
    c_port="${PROFILE_DB_PORT:-1532}"

    printf "│ %-16s │ %-19s │ %-24s │ %-54s │\n" "$c_name" "sys (SYSDBA)" "DB_${c_upper}_SYS" "localhost:${c_port}/FREEPDB1"
    printf "│ %-16s │ %-19s │ %-24s │ %-54s │\n" "$c_name" "DBA_ADMIN" "DB_${c_upper}_DBA_ADMIN" "localhost:${c_port}/FREEPDB1"
    printf "│ %-16s │ %-19s │ %-24s │ %-54s │\n" "$c_name" "USER_DEVELOPER" "DB_${c_upper}_DEV" "localhost:${c_port}/FREEPDB1"
    printf "│ %-16s │ %-19s │ %-24s │ %-54s │\n" "$c_name" "USER_VIEWER" "DB_${c_upper}_VIEWER" "localhost:${c_port}/FREEPDB1"
    printf "│ %-16s │ %-19s │ %-24s │ %-54s │\n" "$c_name" "USER_APP" "DB_${c_upper}_APP" "localhost:${c_port}/FREEPDB1"
  done

  if [ "${PROFILE_APEX_ENABLED:-true}" != "false" ]; then
    printf "│ %-16s │ %-19s │ %-24s │ %-54s │\n" "APEX Builder" "ADMIN (INTERNAL)" "DB_PROXY_APEX_ADMIN" "https://localhost:8448/ords/proxy/apex_admin"
    printf "│ %-16s │ %-19s │ %-24s │ %-54s │\n" "Database Actions" "USER_DEVELOPER" "DB_PROXY_DEV" "https://localhost:8448/ords/proxy/_/landing"
  fi

  if [ "${PUBLISHER_ENABLED:-false}" = "true" ] || podman container exists app-publisher 2>/dev/null; then
    printf "│ %-16s │ %-19s │ %-24s │ %-54s │\n" "Analytics Pub" "weblogic" "PUBLISHER_WEBLOGIC_ADMIN" "http://localhost:9502/xmlpserver"
  fi

  if [ "${ENABLE_FORMS:-false}" = "true" ] || podman container exists app-forms 2>/dev/null; then
    printf "│ %-16s │ %-19s │ %-24s │ %-54s │\n" "Oracle Forms" "weblogic" "FORMS_WEBLOGIC_ADMIN" "http://localhost:9001/forms/frmservlet"
  fi

  if podman container exists web-ide-dev 2>/dev/null; then
    printf "│ %-16s │ %-19s │ %-24s │ %-54s │\n" "Web IDE (VSCode)" "developer" "(Parooli pole vaja)" "http://localhost:8090/?folder=/workspace"
  fi

  printf "└──────────────────┴─────────────────────┴──────────────────────────┴────────────────────────────────────────────────────────┘\n"
  echo ""
  echo "👉 Parooli kuvamiseks: $0 <ALIAS> (nt '$0 DB_PROXY_DEV')"
  echo "👉 Parooli kopeerimiseks lõikelauale: $0 <ALIAS> -c (või --copy)"
  echo "👉 Ainult toorparooli väljastamiseks: $0 <ALIAS> -p (või --raw)"
  echo "👉 Parooli vahetamiseks: ./scripts/rotate-password.sh <TARGET> <ROLE>"
  echo "=================================================================="
  exit 0
fi

PRIMARY_CONTAINER=$(get_active_db_instances 2>/dev/null | head -n 1 | cut -d'|' -f1)
PRIMARY_CONTAINER="${PRIMARY_CONTAINER:-pub-db}"
if ! podman container exists "$PRIMARY_CONTAINER" 2>/dev/null; then
  for c_entry in $(get_active_db_instances 2>/dev/null); do
    c_name=$(echo "$c_entry" | cut -d'|' -f1)
    if podman container exists "$c_name" 2>/dev/null; then
      PRIMARY_CONTAINER="$c_name"
      break
    fi
  done
fi
if ! podman container exists "$PRIMARY_CONTAINER" 2>/dev/null; then
  if podman container exists db-apex-proxy 2>/dev/null; then
    PRIMARY_CONTAINER="db-apex-proxy"
  elif podman container exists pub-db 2>/dev/null; then
    PRIMARY_CONTAINER="pub-db"
  fi
fi
PRIMARY_SHORT=$(echo "$PRIMARY_CONTAINER" | sed -E 's/^db[-_]//' | tr '-' '_' | tr '[:lower:]' '[:upper:]')
PROXY_CONTAINER="$PRIMARY_CONTAINER"

# Dynamic alias resolution using active container name from .env and profile
ALIAS_UPPER=$(echo "$ALIAS" | tr '[:lower:]' '[:upper:]')

case "$ALIAS_UPPER" in
  "ADMIN"|"APEX_ADMIN") ALIAS_SEARCH="DB_${PRIMARY_SHORT}_APEX_ADMIN" ;;
  "SYS"|"SYSDBA") ALIAS_SEARCH="DB_${PRIMARY_SHORT}_SYS" ;;
  "DBA_ADMIN"|"DB_DBA_ADMIN") ALIAS_SEARCH="DB_${PRIMARY_SHORT}_DBA_ADMIN" ;;
  "DEV"|"DEVELOPER"|"USER_DEVELOPER"|"TEST_DEV"|"DB_TEST_DEV") ALIAS_SEARCH="DB_${PRIMARY_SHORT}_DEV" ;;
  "APP"|"USER_APP"|"FORMS_APP") ALIAS_SEARCH="DB_${PRIMARY_SHORT}_APP" ;;
  "VIEWER"|"USER_VIEWER"|"TEST_VIEWER"|"DB_TEST_VIEWER") ALIAS_SEARCH="DB_${PRIMARY_SHORT}_VIEWER" ;;
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
if [ "$RAW_ONLY" != "true" ] && [ "$COPY_CLIPBOARD" != "true" ]; then
  echo "🔍 Otsin Walletist aliasele '$ALIAS' vastavat indeksit..."
fi
LIST_OUT=$(podman exec -i "$PROXY_CONTAINER" sh -c 'export JAVA_HOME=/usr/java/latest; export PATH=$JAVA_HOME/bin:$PATH; echo "$1" | mkstore -wrl "'"$WALLET_PATH"'" -listCredential' -- "$WALLET_PWD" 2>/dev/null || true)

# Parsime indeksi
INDEX=$(echo "$LIST_OUT" | grep -i -E "^[0-9]+: ($ALIAS_SEARCH|$ALIAS)$" | head -n 1 | cut -d':' -f1 | tr -d ' ' | tr -d '\r')
if [ -z "$INDEX" ]; then
  INDEX=$(echo "$LIST_OUT" | grep -i -E "($ALIAS_SEARCH|$ALIAS)" | head -n 1 | cut -d':' -f1 | tr -d ' ' | tr -d '\r')
fi

if [ -z "$INDEX" ]; then
  case "$ALIAS_UPPER" in
    *"SYS"*) PWD_VAL=$(podman secret inspect --showsecret publisher_db_sys_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || podman secret inspect --showsecret apex_db_sys_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true); USER_VAL="sys" ;;
    *"SCHEMA"*) PWD_VAL=$(podman secret inspect --showsecret apex_schema_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true); USER_VAL="${ALIAS_UPPER#DB_}" ;;
    *"DEV"*) PWD_VAL=$(podman secret inspect --showsecret user_developer_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || podman secret inspect --showsecret test_dev_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true); USER_VAL="USER_DEVELOPER" ;;
    *"APP"*) PWD_VAL=$(podman secret inspect --showsecret user_app_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true); USER_VAL="USER_APP" ;;
    *"VIEWER"*) PWD_VAL=$(podman secret inspect --showsecret user_viewer_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || podman secret inspect --showsecret test_viewer_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true); USER_VAL="USER_VIEWER" ;;
  esac
  if [ -z "$PWD_VAL" ]; then
    echo "❌ Viga: Walletist ega secret-store'ist ei leitud aliast '$ALIAS' (ega '$ALIAS_SEARCH')!"
    exit 1
  fi
else
  # Pärime kasutaja ja parooli
  USER_VAL=$(podman exec -i "$PROXY_CONTAINER" sh -c 'export JAVA_HOME=/usr/java/latest; export PATH=$JAVA_HOME/bin:$PATH; echo "$1" | mkstore -wrl "'"$WALLET_PATH"'" -viewEntry "oracle.security.client.username'"$INDEX"'"' -- "$WALLET_PWD" 2>/dev/null | grep "=" | cut -d'=' -f2 | tr -d ' ' | tr -d '\r')

  PWD_VAL=$(podman exec -i "$PROXY_CONTAINER" sh -c 'export JAVA_HOME=/usr/java/latest; export PATH=$JAVA_HOME/bin:$PATH; echo "$1" | mkstore -wrl "'"$WALLET_PATH"'" -viewEntry "oracle.security.client.password'"$INDEX"'"' -- "$WALLET_PWD" 2>/dev/null | grep "=" | cut -d'=' -f2 | tr -d ' ' | tr -d '\r')
fi

# If PWD_VAL is empty, contains question marks from binary mkstore output, or contains unprintable bytes
if [ -z "$PWD_VAL" ] || [[ "$PWD_VAL" == *"?"* ]] || echo "$PWD_VAL" | grep -q '[^[:print:]]'; then
  case "$ALIAS_UPPER" in
    "SYS"|"SYSDBA"|"DB_APEX_PROXY_SYS"|*"_SYS")
      target_c_prefix=$(echo "$ALIAS_UPPER" | sed -E 's/^DB_//; s/_SYS$//' | sed 's/^DB_//' | tr '[:upper:]' '[:lower:]')
      [ -n "$target_c_prefix" ] && PWD_VAL=$(podman secret inspect --showsecret "${target_c_prefix}_db_sys_password" 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
      [ -z "$PWD_VAL" ] && [ -n "$target_c_prefix" ] && PWD_VAL=$(podman secret inspect --showsecret "${target_c_prefix}_sys_password" 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
      [ -z "$PWD_VAL" ] && PWD_VAL=$(podman secret inspect --showsecret apex_db_sys_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
      [ -z "$PWD_VAL" ] && PWD_VAL=$(podman exec "$PROXY_CONTAINER" cat /run/secrets/oracle_pwd 2>/dev/null | tr -d '\r\n' || true)
      [ -z "$PWD_VAL" ] && PWD_VAL=$(podman exec "$PROXY_CONTAINER" cat /run/secrets/apex_db_sys_password 2>/dev/null | tr -d '\r\n' || true)
      ;;
    "DBA_ADMIN"|"DB_DBA_ADMIN"|*"_DBA_ADMIN")
      target_c_prefix=$(echo "$ALIAS_UPPER" | sed -E 's/^DB_//; s/_DBA_ADMIN$//' | sed 's/^DB_//' | tr '[:upper:]' '[:lower:]')
      [ -n "$target_c_prefix" ] && PWD_VAL=$(podman secret inspect --showsecret "${target_c_prefix}_dba_admin_password" 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
      [ -z "$PWD_VAL" ] && [ -n "$target_c_prefix" ] && PWD_VAL=$(podman secret inspect --showsecret "${target_c_prefix}_db_sys_password" 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
      [ -z "$PWD_VAL" ] && PWD_VAL=$(podman secret inspect --showsecret dba_admin_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || podman secret inspect --showsecret apex_db_sys_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
      ;;
    "DEV"|"DEVELOPER"|"USER_DEVELOPER"|"TEST_DEV"|"DB_TEST_DEV"|*"_DEV")
      target_c_prefix=$(echo "$ALIAS_UPPER" | sed -E 's/^DB_//; s/_DEV$//' | sed 's/^DB_//' | tr '[:upper:]' '[:lower:]')
      [ -n "$target_c_prefix" ] && PWD_VAL=$(podman secret inspect --showsecret "${target_c_prefix}_user_developer_password" 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
      [ -z "$PWD_VAL" ] && [ -n "$target_c_prefix" ] && PWD_VAL=$(podman secret inspect --showsecret "${target_c_prefix}_db_dev_password" 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
      [ -z "$PWD_VAL" ] && [ -n "$target_c_prefix" ] && PWD_VAL=$(podman secret inspect --showsecret "${target_c_prefix}_dev_password" 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
      [ -z "$PWD_VAL" ] && PWD_VAL=$(podman secret inspect --showsecret user_developer_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || podman secret inspect --showsecret test_dev_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || podman secret inspect --showsecret apex_db_dev_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
      [ -z "$PWD_VAL" ] && PWD_VAL=$(podman exec "$PROXY_CONTAINER" cat /run/secrets/apex_db_dev_password 2>/dev/null | tr -d '\r\n' || true)
      ;;
    "APP"|"USER_APP"|"FORMS_APP"|*"_APP")
      target_c_prefix=$(echo "$ALIAS_UPPER" | sed -E 's/^DB_//; s/_APP$//' | sed 's/^DB_//' | tr '[:upper:]' '[:lower:]')
      [ -n "$target_c_prefix" ] && PWD_VAL=$(podman secret inspect --showsecret "${target_c_prefix}_user_app_password" 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
      [ -z "$PWD_VAL" ] && PWD_VAL=$(podman secret inspect --showsecret user_app_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
      ;;
    "VIEWER"|"USER_VIEWER"|"TEST_VIEWER"|"DB_TEST_VIEWER"|*"_VIEWER")
      target_c_prefix=$(echo "$ALIAS_UPPER" | sed -E 's/^DB_//; s/_VIEWER$//' | sed 's/^DB_//' | tr '[:upper:]' '[:lower:]')
      [ -n "$target_c_prefix" ] && PWD_VAL=$(podman secret inspect --showsecret "${target_c_prefix}_user_viewer_password" 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
      [ -z "$PWD_VAL" ] && PWD_VAL=$(podman secret inspect --showsecret user_viewer_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || podman secret inspect --showsecret test_viewer_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
      ;;
    "ADMIN"|"APEX_ADMIN"|*"_APEX_ADMIN")
      target_c_prefix=$(echo "$ALIAS_UPPER" | sed -E 's/^DB_//; s/_APEX_ADMIN$//' | sed 's/^DB_//' | tr '[:upper:]' '[:lower:]')
      [ -n "$target_c_prefix" ] && PWD_VAL=$(podman secret inspect --showsecret "${target_c_prefix}_apex_admin_password" 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
      [ -z "$PWD_VAL" ] && PWD_VAL=$(podman secret inspect --showsecret apex_admin_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
      [ -z "$PWD_VAL" ] && PWD_VAL=$(podman exec "$PROXY_CONTAINER" cat /run/secrets/apex_admin_password 2>/dev/null | tr -d '\r\n' || true)
      ;;
  esac
fi

if [ "$RAW_ONLY" = "true" ]; then
  printf "%s\n" "$PWD_VAL"
  exit 0
fi

if [ "$COPY_CLIPBOARD" = "true" ]; then
  if copy_to_clipboard "$PWD_VAL"; then
    echo -e "${GREEN}$(msg_str "PWD_COPIED" "$ALIAS")${NC}"
    echo -e "${CYAN}$(msg_str "PWD_PASTE_HINT")${NC}"
  else
    echo -e "${YELLOW}⚠️ Clipboard tool not found. Password:${NC} $PWD_VAL"
  fi
  exit 0
fi

echo "=================================================================="
echo -e "🔓 Wallet Credential Details for Alias: \033[1;36m$ALIAS\033[0m"
echo -e "   👤 Username: \033[1;32m$USER_VAL\033[0m"
echo -e "   🔑 Password: \033[1;33m$PWD_VAL\033[0m"
echo "=================================================================="
echo -e "💡 Tip: Use '\033[1;32m$0 $ALIAS -c\033[0m' to copy password directly to clipboard!"


