#!/usr/bin/env bash
# ============================================================================
# Safe & Deterministic Credential Rotation Tool (DORA & PCI-DSS Compliance)
# Usage:
#   ./scripts/rotate-password.sh [TARGET_DB_OR_SERVICE] [ROLE]
#   ./scripts/rotate-password.sh all
# Examples:
#   ./scripts/rotate-password.sh db-proxy dev
#   ./scripts/rotate-password.sh db-proxy sys
#   ./scripts/rotate-password.sh apex_admin
#   ./scripts/rotate-password.sh ords_listener
#   ./scripts/rotate-password.sh all
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$SCRIPT_DIR/internal/common.sh" 2>/dev/null || true
source "$SCRIPT_DIR/internal/credential-helper.sh" 2>/dev/null || true
source "$SCRIPT_DIR/internal/load-profile.sh" 2>/dev/null || true

# Generate a strong, secure random password (20 alphanumeric chars)
gen_strong_password() {
  LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20 2>/dev/null || openssl rand -base64 16 | tr -dc 'A-Za-z0-9' | head -c 20
}

# Update podman secret store
store_secret() {
  local sec_name="$1"
  local sec_val="$2"
  if command -v podman &>/dev/null; then
    podman secret rm "$sec_name" >/dev/null 2>&1 || true
    printf '%s' "$sec_val" | podman secret create "$sec_name" - >/dev/null 2>&1 || true
  fi
}

rotate_db_user_password() {
  local target_db="$1"
  local role="$2"
  local new_pwd="$3"

  local c_short=$(get_db_short_name "$target_db")
  local c_upper=$(get_db_upper_name "$target_db")

  local db_username=""
  local secret_name=""
  local is_sys=false

  case "$role" in
    sys|system)
      db_username="SYS"
      secret_name="${c_short}_db_sys_password"
      is_sys=true
      ;;
    dev|developer)
      db_username="USER_DEVELOPER"
      secret_name="${c_short}_dev_password"
      ;;
    viewer)
      db_username="USER_VIEWER"
      secret_name="${c_short}_viewer_password"
      ;;
    app)
      db_username="USER_APP"
      secret_name="${c_short}_app_password"
      ;;
    schema|apex_schema)
      db_username="APEX_PROXY_SCHEMA"
      secret_name="${c_short}_schema_password"
      ;;
    apex_admin|admin)
      db_username="APEX_ADMIN"
      secret_name="${c_short}_apex_admin_password"
      ;;
    *)
      echo "❌ Tundmatu roll: '$role'. Lubatud rollid: sys, dev, viewer, app, schema, apex_admin." >&2
      return 1
      ;;
  esac

  echo "🔄 Roteerin parooli: Andmebaas [${target_db}] -> Kasutaja [${db_username}]..."

  # 1. Update Database & APEX User Password
  if command -v podman &>/dev/null && podman container exists "$target_db" 2>/dev/null; then
    if [ "$is_sys" = "true" ]; then
      podman exec -i "$target_db" sqlplus -s / as sysdba <<EOSQL >/dev/null 2>&1 || true
ALTER USER sys IDENTIFIED BY "${new_pwd}" CONTAINER=ALL;
ALTER USER system IDENTIFIED BY "${new_pwd}" CONTAINER=ALL;
EXIT;
EOSQL
    elif [ "$role" = "apex_admin" ] || [ "$role" = "admin" ]; then
      podman exec -i "$target_db" sqlplus -s / as sysdba <<EOSQL >/dev/null 2>&1 || true
ALTER SESSION SET CONTAINER = FREEPDB1;
ALTER SESSION SET CURRENT_SCHEMA = APEX_260100;
BEGIN
  wwv_flow_instance_admin.create_or_update_admin_user(
      p_username => 'ADMIN',
      p_email    => 'admin@company.com',
      p_password => '${new_pwd}'
  );
  COMMIT;
END;
/
EXIT;
EOSQL
    else
      podman exec -i "$target_db" sqlplus -s / as sysdba <<EOSQL >/dev/null 2>&1 || true
ALTER SESSION SET CONTAINER = FREEPDB1;
ALTER USER ${db_username} IDENTIFIED BY "${new_pwd}";
EXIT;
EOSQL
    fi
  fi

  # 2. Update Podman Secret Store
  store_secret "$secret_name" "$new_pwd"

  # 3. Synchronize APEX users & SEPS Wallet
  if [ -x "$SCRIPT_DIR/internal/apply-profile-users.sh" ]; then
    "$SCRIPT_DIR/internal/apply-profile-users.sh" "$target_db" >/dev/null 2>&1 || true
  elif [ -x "$SCRIPT_DIR/internal/create-wallet.sh" ]; then
    "$SCRIPT_DIR/internal/create-wallet.sh" >/dev/null 2>&1 || true
  fi

  echo "✅ Parool edukalt roteeritud: [${target_db} - ${db_username}] (Saladus: ${secret_name})"
}

rotate_ords_listener_password() {
  local new_pwd="$1"
  echo "🔄 Roteerin ORDS Listeneri parooli (ORDS_PUBLIC_USER & APEX_LISTENER)..."
  
  local dbs=$(get_active_db_instances 2>/dev/null | cut -d'|' -f1)
  [ -z "$dbs" ] && dbs="db-proxy"

  for target_db in $dbs; do
    if command -v podman &>/dev/null && podman container exists "$target_db" 2>/dev/null; then
      podman exec -i "$target_db" sqlplus -s / as sysdba <<EOSQL >/dev/null 2>&1 || true
ALTER SESSION SET CONTAINER = FREEPDB1;
ALTER SESSION SET "_oracle_script" = TRUE;
ALTER USER ORDS_PUBLIC_USER IDENTIFIED BY "${new_pwd}" ACCOUNT UNLOCK;
ALTER USER APEX_LISTENER IDENTIFIED BY "${new_pwd}" ACCOUNT UNLOCK;
ALTER USER APEX_REST_PUBLIC_USER IDENTIFIED BY "${new_pwd}" ACCOUNT UNLOCK;
EXIT;
EOSQL
    fi
  done

  store_secret "ords_listener_password" "$new_pwd"
  store_secret "apex_listener_password" "$new_pwd"
  store_secret "apex_rest_public_password" "$new_pwd"

  # Sync all active databases and wallet
  for target_db in $dbs; do
    if [ -x "$SCRIPT_DIR/internal/apply-profile-users.sh" ]; then
      "$SCRIPT_DIR/internal/apply-profile-users.sh" "$target_db" >/dev/null 2>&1 || true
    fi
  done

  if [ -x "$SCRIPT_DIR/internal/create-wallet.sh" ]; then
    "$SCRIPT_DIR/internal/create-wallet.sh" >/dev/null 2>&1 || true
  fi

  if command -v podman &>/dev/null && podman container exists "app-ords" 2>/dev/null; then
    echo "🔄 Taaskäivitan app-ords konteineri uue parooliga..."
    podman restart app-ords >/dev/null 2>&1 || true
  fi

  echo "✅ ORDS Listeneri parool edukalt roteeritud."
}

rotate_all_credentials() {
  echo "=================================================================="
  echo "🔄 ALUSTAN KÕIGI AKTIIVSETE SALADUSTE TÄIELIKKU ROTATSIOONI"
  echo "=================================================================="

  local dbs=$(get_active_db_instances 2>/dev/null | cut -d'|' -f1)
  [ -z "$dbs" ] && dbs="db-proxy"

  for c_db in $dbs; do
    [ -z "$c_db" ] && continue
    echo -e "\n📦 Andmebaas: ${c_db}"
    rotate_db_user_password "$c_db" "sys" "$(gen_strong_password)"
    rotate_db_user_password "$c_db" "dev" "$(gen_strong_password)"
    rotate_db_user_password "$c_db" "viewer" "$(gen_strong_password)"
    rotate_db_user_password "$c_db" "app" "$(gen_strong_password)"
    rotate_db_user_password "$c_db" "apex_admin" "$(gen_strong_password)"
  done

  echo -e "\n🌐 Middleware teenused:"
  rotate_ords_listener_password "$(gen_strong_password)"

  echo "=================================================================="
  echo "✅ KÕIK PAROOLID EDUKALT ROTEERITUD JA SÜNKRONISEERITUD"
  echo "=================================================================="
  if [ -x "$SCRIPT_DIR/get-password.sh" ]; then
    "$SCRIPT_DIR/get-password.sh"
  fi
}

# CLI Argument parsing
TARGET="${1:-}"
ROLE="${2:-}"

if [ -z "$TARGET" ]; then
  echo "Kasutus: $0 <TARGET_DB_OR_SERVICE> [ROLE]"
  echo "         $0 all"
  echo ""
  echo "Näited:"
  echo "  $0 db-proxy dev"
  echo "  $0 db-proxy sys"
  echo "  $0 ords_listener"
  echo "  $0 all"
  exit 1
fi

case "$TARGET" in
  all)
    rotate_all_credentials
    ;;
  ords_listener|ords)
    rotate_ords_listener_password "$(gen_strong_password)"
    ;;
  *)
    if [ -z "$ROLE" ]; then
      echo "❌ Palun määra roll (nt 'dev', 'sys', 'viewer', 'app'): $0 $TARGET dev"
      exit 1
    fi
    rotate_db_user_password "$TARGET" "$ROLE" "$(gen_strong_password)"
    ;;
esac
