#!/usr/bin/env bash
# ============================================================================
# Central Credential & Database Target Resolution Helper (credential-helper.sh)
# Provides deterministic, zero-cross-fallback credential access for scripts.
# ============================================================================

set -e

_CRED_HELPER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_CRED_WORKSPACE_DIR="$(cd "$_CRED_HELPER_DIR/../.." && pwd)"

# Source load-profile if available
if [ -f "$_CRED_HELPER_DIR/load-profile.sh" ]; then
  source "$_CRED_HELPER_DIR/load-profile.sh"
fi

get_db_short_name() {
  local c_name="${1:-}"
  if [ -z "$c_name" ]; then
    c_name=$(get_active_db_instances 2>/dev/null | head -n 1 | cut -d'|' -f1)
  fi
  echo "$c_name" | sed 's/^db-//' | tr '-' '_' | tr '[:upper:]' '[:lower:]'
}

get_db_upper_name() {
  local c_name="${1:-}"
  local s_name=$(get_db_short_name "$c_name")
  echo "$s_name" | tr '[:lower:]' '[:upper:]'
}

get_db_sys_password() {
  local target_container="${1:-}"
  if [ -z "$target_container" ]; then
    target_container=$(get_active_db_instances 2>/dev/null | head -n 1 | cut -d'|' -f1)
  fi
  local c_short=$(get_db_short_name "$target_container")
  local c_upper=$(get_db_upper_name "$target_container")
  local val=""

  # 1. From running container's secret mount
  if podman container exists "$target_container" 2>/dev/null; then
    val=$(podman exec "$target_container" cat /run/secrets/oracle_pwd 2>/dev/null || true)
  fi

  # 2. From Podman secret store
  if [ -z "$val" ]; then
    val=$(podman secret inspect --showsecret "${c_short}_db_sys_password" 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
  fi
  if [ -z "$val" ]; then
    val=$(podman secret inspect --showsecret "${c_short}_sys_password" 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
  fi

  # 3. From SEPS Wallet via get-password.sh
  if [ -z "$val" ] && [ -x "$_CRED_WORKSPACE_DIR/scripts/get-password.sh" ]; then
    val=$("$_CRED_WORKSPACE_DIR/scripts/get-password.sh" "DB_${c_upper}_SYS" 2>/dev/null | grep "Password:" | awk '{print $3}' | sed 's/\x1b\[[0-9;]*m//g' | tr -d '\r\n' || true)
  fi

  # Strict validation: FAIL-FAST without cross-db fallback
  if [ -z "$val" ]; then
    echo "❌ Error: Could not resolve SYS password for database '${target_container}' (checked secret '${c_short}_db_sys_password' and Wallet 'DB_${c_upper}_SYS')!" >&2
    return 1
  fi

  echo "$val"
}

get_db_user_password() {
  local target_container="$1"
  local role="$2" # dba_admin, dev, viewer, app, schema
  local c_short=$(get_db_short_name "$target_container")
  local c_upper=$(get_db_upper_name "$target_container")
  local role_upper=$(echo "$role" | tr '[:lower:]' '[:upper:]')
  local val=""

  # 1. Prefer SEPS Wallet (Rule 5)
  if [ -x "$_CRED_WORKSPACE_DIR/scripts/get-password.sh" ]; then
    val=$("$_CRED_WORKSPACE_DIR/scripts/get-password.sh" "DB_${c_upper}_${role_upper}" 2>/dev/null | grep "Password:" | awk '{print $3}' | sed 's/\x1b\[[0-9;]*m//g' | tr -d '\r\n' || true)
    [ -z "$val" ] && val=$("$_CRED_WORKSPACE_DIR/scripts/get-password.sh" "${c_upper}_${role_upper}" 2>/dev/null | grep "Password:" | awk '{print $3}' | sed 's/\x1b\[[0-9;]*m//g' | tr -d '\r\n' || true)
  fi

  # 2. Fallback to Podman secret store
  if [ -z "$val" ]; then
    val=$(podman secret inspect --showsecret "${c_short}_${role}_password" 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
  fi

  if [ -z "$val" ]; then
    echo "❌ Error: Could not resolve '${role}' password for database '${target_container}'!" >&2
    return 1
  fi

  echo "$val"
}

get_service_admin_password() {
  local service="$1" # ords_listener, apex_admin, publisher_admin, forms_admin
  local val=""

  case "$service" in
    ords_listener|ords)
      val=$(podman secret inspect --showsecret "ords_listener_password" 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
      ;;
    apex_admin|apex)
      if [ -x "$_CRED_WORKSPACE_DIR/scripts/get-password.sh" ]; then
        val=$("$_CRED_WORKSPACE_DIR/scripts/get-password.sh" "DB_ALISE_APEX_ADMIN" 2>/dev/null | grep "Password:" | awk '{print $3}' | sed 's/\x1b\[[0-9;]*m//g' | tr -d '\r\n' || true)
        [ -z "$val" ] && val=$("$_CRED_WORKSPACE_DIR/scripts/get-password.sh" "APEX_ADMIN" 2>/dev/null | grep "Password:" | awk '{print $3}' | sed 's/\x1b\[[0-9;]*m//g' | tr -d '\r\n' || true)
      fi
      [ -z "$val" ] && val=$(podman secret inspect --showsecret "proxy_db_sys_password" 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
      ;;
    publisher_admin|publisher)
      val=$(podman secret inspect --showsecret "publisher_admin_password" 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
      [ -z "$val" ] && val=$(podman secret inspect --showsecret "publisher_db_sys_password" 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
      ;;
    forms_admin|forms)
      val=$(podman secret inspect --showsecret "forms_admin_password" 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
      [ -z "$val" ] && val=$(podman secret inspect --showsecret "forms_db_sys_password" 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
      ;;
  esac

  echo "$val"
}

resolve_service_target_db() {
  local service="$1" # publisher, forms, apex, ords, web_ide
  local resolved_db=""

  case "$service" in
    publisher)
      # Check if dedicated publisher DB exists
      resolved_db=$(get_active_db_instances 2>/dev/null | grep -i "publisher" | head -n 1 | cut -d'|' -f1 || true)
      if [ -z "$resolved_db" ]; then
        # Fallback to primary DB (e.g. db-proxy)
        resolved_db=$(get_active_db_instances 2>/dev/null | head -n 1 | cut -d'|' -f1 || echo "db-proxy")
      fi
      ;;
    forms)
      # Check if dedicated forms DB exists
      resolved_db=$(get_active_db_instances 2>/dev/null | grep -i "forms" | head -n 1 | cut -d'|' -f1 || true)
      if [ -z "$resolved_db" ]; then
        # Check if shared infra publisher DB exists
        resolved_db=$(get_active_db_instances 2>/dev/null | grep -i "publisher" | head -n 1 | cut -d'|' -f1 || true)
      fi
      if [ -z "$resolved_db" ]; then
        # Fallback to primary DB (e.g. db-proxy)
        resolved_db=$(get_active_db_instances 2>/dev/null | head -n 1 | cut -d'|' -f1 || echo "db-proxy")
      fi
      ;;
    apex|ords|web_ide|*)
      resolved_db=$(get_active_db_instances 2>/dev/null | head -n 1 | cut -d'|' -f1 || echo "db-proxy")
      ;;
  esac

  echo "$resolved_db"
}

resolve_service_target_profile() {
  local service="$1"
  local target_db=$(resolve_service_target_db "$service")
  local prof=$(get_active_db_instances 2>/dev/null | grep -E "^${target_db}\|" | head -n 1 | cut -d'|' -f2 || true)
  if [ -z "$prof" ]; then
    prof=$(get_active_db_instances 2>/dev/null | head -n 1 | cut -d'|' -f2 || echo "db-proxy-oracle")
  fi
  echo "$prof"
}
