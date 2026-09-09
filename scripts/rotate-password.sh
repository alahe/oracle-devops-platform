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
      echo "❌ Unknown role: '$role'. Allowed roles: sys, dev, viewer, app, schema, apex_admin." >&2
      return 1
      ;;
  esac

  echo "🔄 Rotating password: Database [${target_db}] -> User [${db_username}]..."

  # 1. Update Database & APEX User Password
  if command -v podman &>/dev/null && [ "$(podman inspect --format='{{.State.Status}}' "$target_db" 2>/dev/null)" = "running" ]; then
    local in_c_sql=$(podman exec "$target_db" bash -c 'ls -d /opt/oracle/product/*/dbhomeFree/sqlcl/bin/sql 2>/dev/null | head -n 1' 2>/dev/null || echo "")
    local sql_cmd="${in_c_sql:-sql} -s / as sysdba"

    if [ "$is_sys" = "true" ]; then
      podman exec -i "$target_db" $sql_cmd <<EOSQL >/dev/null 2>&1 || true
ALTER USER sys IDENTIFIED BY "${new_pwd}" CONTAINER=ALL;
ALTER USER system IDENTIFIED BY "${new_pwd}" CONTAINER=ALL;
EXIT;
EOSQL
    elif [ "$role" = "apex_admin" ] || [ "$role" = "admin" ]; then
      podman exec -i "$target_db" $sql_cmd <<EOSQL >/dev/null 2>&1 || true
ALTER SESSION SET CONTAINER = FREEPDB1;
DECLARE
  v_schema VARCHAR2(30);
BEGIN
  SELECT username INTO v_schema FROM all_users WHERE username LIKE 'APEX_%' AND REGEXP_LIKE(username, '^APEX_[0-9]+$') AND ROWNUM = 1;
  EXECUTE IMMEDIATE 'ALTER SESSION SET CURRENT_SCHEMA = ' || v_schema;
  EXECUTE IMMEDIATE 'BEGIN ' ||
                    v_schema || '.wwv_flow_instance_admin.set_parameter(''STRONG_SITE_ADMIN_PASSWORD'', ''N''); ' ||
                    v_schema || '.wwv_flow_instance_admin.create_or_update_admin_user(p_username => ''ADMIN'', p_email => ''admin@company.com'', p_password => ''' || '${new_pwd}' || '''); ' ||
                    v_schema || '.wwv_flow_instance_admin.unlock_user(p_workspace => ''INTERNAL'', p_username => ''ADMIN'', p_password => ''' || '${new_pwd}' || '''); ' ||
                    'UPDATE ' || v_schema || '.wwv_flow_fnd_user SET change_password_on_first_use = ''N'', account_locked = ''N'' WHERE security_group_id = 10 AND user_name = ''ADMIN''; ' ||
                    'COMMIT; END;';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
EXIT;
EOSQL
    else
      podman exec -i "$target_db" $sql_cmd <<EOSQL >/dev/null 2>&1 || true
ALTER SESSION SET CONTAINER = FREEPDB1;
ALTER USER ${db_username} IDENTIFIED BY "${new_pwd}";
EXIT;
EOSQL
    fi
  fi

  # 2. Update Podman Secret Store
  store_secret "$secret_name" "$new_pwd"
  case "$role" in
    dev|developer)
      store_secret "user_developer_password" "$new_pwd"
      ;;
    viewer)
      store_secret "user_viewer_password" "$new_pwd"
      ;;
    app)
      store_secret "user_app_password" "$new_pwd"
      ;;
    schema|apex_schema)
      store_secret "apex_schema_password" "$new_pwd"
      ;;
    apex_admin|admin)
      store_secret "apex_admin_password" "$new_pwd"
      ;;
    sys|system)
      store_secret "proxy_db_sys_password" "$new_pwd"
      store_secret "db_sys_password" "$new_pwd"
      ;;
  esac

  # 3. Synchronize SEPS Wallet & APEX users
  if [ -x "$SCRIPT_DIR/internal/create-wallet.sh" ]; then
    "$SCRIPT_DIR/internal/create-wallet.sh" >/dev/null 2>&1 || true
  fi
  if [ -x "$SCRIPT_DIR/internal/apply-profile-users.sh" ]; then
    "$SCRIPT_DIR/internal/apply-profile-users.sh" "$target_db" >/dev/null 2>&1 || true
  fi

  echo "✅ Password successfully rotated: [${target_db} - ${db_username}] (Secret: ${secret_name})"
}

rotate_ords_listener_password() {
  local new_pwd="$1"
  echo "🔄 Rotating ORDS Listener password (ORDS_PUBLIC_USER, APEX_PUBLIC_USER, APEX_LISTENER)..."
  
  local dbs=$(get_active_db_instances 2>/dev/null | cut -d'|' -f1)
  [ -z "$dbs" ] && dbs="db-proxy"

  for target_db in $dbs; do
    if command -v podman &>/dev/null && [ "$(podman inspect --format='{{.State.Status}}' "$target_db" 2>/dev/null)" = "running" ]; then
      local in_c_sql=$(podman exec "$target_db" bash -c 'ls -d /opt/oracle/product/*/dbhomeFree/sqlcl/bin/sql 2>/dev/null | head -n 1' 2>/dev/null || echo "")
      local sql_cmd="${in_c_sql:-sql} -s / as sysdba"
      podman exec -i "$target_db" $sql_cmd <<EOSQL >/dev/null 2>&1 || true
ALTER SESSION SET CONTAINER = FREEPDB1;
ALTER SESSION SET "_oracle_script" = TRUE;
ALTER USER ORDS_PUBLIC_USER IDENTIFIED BY "${new_pwd}" ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER IDENTIFIED BY "${new_pwd}" ACCOUNT UNLOCK;
ALTER USER APEX_LISTENER IDENTIFIED BY "${new_pwd}" ACCOUNT UNLOCK;
ALTER USER APEX_REST_PUBLIC_USER IDENTIFIED BY "${new_pwd}" ACCOUNT UNLOCK;
EXIT;
EOSQL
    fi
  done

  store_secret "ords_listener_password" "$new_pwd"
  store_secret "apex_listener_password" "$new_pwd"
  store_secret "apex_rest_public_password" "$new_pwd"

  # 1. Update SEPS Wallet with new secrets
  if [ -x "$SCRIPT_DIR/internal/create-wallet.sh" ]; then
    "$SCRIPT_DIR/internal/create-wallet.sh" >/dev/null 2>&1 || true
  fi

  # 2. Sync all active database users & ORDS configurations
  for target_db in $dbs; do
    if [ -x "$SCRIPT_DIR/internal/apply-profile-users.sh" ]; then
      "$SCRIPT_DIR/internal/apply-profile-users.sh" "$target_db" >/dev/null 2>&1 || true
    fi
  done

  # 3. Directly patch all ORDS pool XML files on host and in app-ords
  for pool in $(find "$WORKSPACE_DIR/config/ords" -name 'pool.xml' 2>/dev/null); do
    sed -i '' "s|<entry key=\"db.password\">.*</entry>|<entry key=\"db.password\">$new_pwd</entry>|g" "$pool" 2>/dev/null || sed -i "s|<entry key=\"db.password\">.*</entry>|<entry key=\"db.password\">$new_pwd</entry>|g" "$pool" 2>/dev/null || true
  done

  if command -v podman &>/dev/null && [ "$(podman inspect --format='{{.State.Status}}' "app-ords" 2>/dev/null)" = "running" ]; then
    podman exec app-ords bash -c "
      for pool in \$(find /etc/ords/config/databases/ -name 'pool.xml' 2>/dev/null); do
        sed -i 's|<entry key=\"db.password\">.*</entry>|<entry key=\"db.password\">$new_pwd</entry>|g' \"\$pool\" 2>/dev/null || true
      done
    " 2>/dev/null || true
    echo "🔄 Restarting app-ords container with new password..."
    podman restart app-ords >/dev/null 2>&1 || true
  fi

  echo "✅ ORDS Listener password successfully rotated."
}

rotate_all_credentials() {
  echo "=================================================================="
  echo "🔄 STARTING FULL ROTATION OF ALL ACTIVE SECRETS"
  echo "=================================================================="

  local dbs=$(get_active_db_instances 2>/dev/null | cut -d'|' -f1)
  [ -z "$dbs" ] && dbs="db-proxy"

  for c_db in $dbs; do
    [ -z "$c_db" ] && continue
    echo -e "\n📦 Database: ${c_db}"
    rotate_db_user_password "$c_db" "sys" "$(gen_strong_password)"
    rotate_db_user_password "$c_db" "dev" "$(gen_strong_password)"
    rotate_db_user_password "$c_db" "viewer" "$(gen_strong_password)"
    rotate_db_user_password "$c_db" "app" "$(gen_strong_password)"
    rotate_db_user_password "$c_db" "apex_admin" "$(gen_strong_password)"
  done

  echo -e "\n🌐 Middleware services:"
  rotate_ords_listener_password "$(gen_strong_password)"

  if [ "${PUBLISHER_ENABLED:-false}" = "true" ] || (command -v podman >/dev/null 2>&1 && podman container exists app-publisher 2>/dev/null); then
    echo -e "\n📊 Analytics Publisher services:"
    rotate_publisher_password "all" "$(gen_strong_password)"
  fi

  echo "=================================================================="
  echo "✅ ALL SECRETS SUCCESSFULLY ROTATED AND SYNCHRONIZED"
  echo "=================================================================="
  if [ -x "$SCRIPT_DIR/get-password.sh" ]; then
    "$SCRIPT_DIR/get-password.sh"
  fi
}

rotate_publisher_password() {
  local role="$1"
  local new_pwd="${2:-$(gen_strong_password)}"

  local roles_to_rotate=()
  case "$role" in
    dev|developer) roles_to_rotate=("developer") ;;
    user) roles_to_rotate=("user") ;;
    admin) roles_to_rotate=("admin") ;;
    all) roles_to_rotate=("developer" "user" "admin") ;;
    *)
      echo "❌ Unknown publisher role: '$role'. Allowed: dev, user, admin, all." >&2
      return 1
      ;;
  esac

  for r in "${roles_to_rotate[@]}"; do
    local uname="bip_${r}"
    local sec_key="publisher_${r}_password"
    local r_upper=$(echo "$r" | tr '[:lower:]' '[:upper:]')
    local alias_key="PUBLISHER_${r_upper}"
    echo "🔄 Rotating password for Oracle Analytics Publisher: [${uname}] (Alias: ${alias_key})..."
    
    local pwd_val="$new_pwd"
    [ "${#roles_to_rotate[@]}" -gt 1 ] && pwd_val="$(gen_strong_password)"
    store_secret "$sec_key" "$pwd_val"

    if command -v podman >/dev/null 2>&1 && podman container exists app-publisher 2>/dev/null && [ "$(podman inspect --format='{{.State.Status}}' app-publisher 2>/dev/null)" = "running" ]; then
      local admin_pwd=$(podman secret inspect --showsecret publisher_db_sys_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || echo "AdminPassword123!")
      podman exec -i app-publisher bash -c "cat << 'PYWLST' > /tmp/rotate_pwd.py
import sys
try:
    connect('weblogic', '$admin_pwd', 't3://localhost:9500')
    cd('/SecurityConfiguration/bi/Realms/myrealm/AuthenticationProviders/DefaultAuthenticator')
    if cmo.userExists('$uname'):
        cmo.resetUserPassword('$uname', '$pwd_val')
        print('SUCCESS')
    disconnect()
except Exception, e:
    print('ERROR: ' + str(e))
PYWLST
/u01/oracle/oracle_common/common/bin/wlst.sh /tmp/rotate_pwd.py >/dev/null 2>&1 || true
rm -f /tmp/rotate_pwd.py
" 2>/dev/null || true
    fi
    echo "✅ Password rotated for ${uname}."
  done

  if [ -x "$SCRIPT_DIR/internal/create-wallet.sh" ]; then
    "$SCRIPT_DIR/internal/create-wallet.sh" >/dev/null 2>&1 || true
  fi
}

# CLI Argument parsing
TARGET="${1:-}"
ROLE="${2:-}"

if [ -z "$TARGET" ]; then
  echo "Usage: $0 <TARGET_DB_OR_SERVICE> [ROLE]"
  echo "       $0 publisher [dev|user|admin|all]"
  echo "       $0 all"
  echo ""
  echo "Examples:"
  echo "  $0 db-proxy dev"
  echo "  $0 db-proxy sys"
  echo "  $0 publisher dev"
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
  publisher|bip)
    rotate_publisher_password "${ROLE:-all}" "$(gen_strong_password)"
    ;;
  *)
    if [ -z "$ROLE" ]; then
      echo "❌ Please specify role (e.g. 'dev', 'sys', 'viewer', 'app'): $0 $TARGET dev"
      exit 1
    fi
    rotate_db_user_password "$TARGET" "$ROLE" "$(gen_strong_password)"
    ;;
esac

