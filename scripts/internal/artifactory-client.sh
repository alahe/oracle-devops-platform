#!/usr/bin/env bash
# ============================================================================
# Oracle DevOps Platform — Enterprise Artifactory & Azure Key Vault Client
# (scripts/internal/artifactory-client.sh)
#
# Provides a unified, product-centric client library for discovering,
# downloading, validating (.meta.json), and publishing:
# 1. Product Binaries (APEX, ORDS, Forms, Publisher .zip archives)
# 2. Product Patches (catpatch.sql, OPatch .zip bundles + patch_latest.meta.json)
# 3. Golden Snapshots & OCI Images (FastStart .tar.gz / .tar + latest.meta.json)
#
# Security:
# - Zero-Trust JIT token resolution from Azure Key Vault or Oracle SEPS Wallet
# - No plaintext credentials stored on disk
# ============================================================================

# Protect against double-sourcing
if [ -n "${_ORACLE_ARTIFACTORY_CLIENT_SH_LOADED:-}" ]; then
  return 0 2>/dev/null || exit 0
fi
_ORACLE_ARTIFACTORY_CLIENT_SH_LOADED=true

_ART_CLIENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$_ART_CLIENT_DIR/../.." && pwd)"

# Source localization and common utilities
if [ -f "$_ART_CLIENT_DIR/common.sh" ]; then
  # shellcheck source=/dev/null
  source "$_ART_CLIENT_DIR/common.sh"
fi
if [ -f "$_ART_CLIENT_DIR/i18n.sh" ]; then
  # shellcheck source=/dev/null
  source "$_ART_CLIENT_DIR/i18n.sh"
fi

# Load repository environment if present
if [ -f "$WORKSPACE_DIR/config/repository.env" ]; then
  # shellcheck source=/dev/null
  source "$WORKSPACE_DIR/config/repository.env"
fi
if [ -f "$WORKSPACE_DIR/.env" ]; then
  # shellcheck source=/dev/null
  source "$WORKSPACE_DIR/.env"
fi

# Configurable Artifactory Parameters
ARTIFACTORY_URL="${ARTIFACTORY_URL:-}"
ARTIFACTORY_REPO="${ARTIFACTORY_REPO:-oracle-devops-platform}"
ARTIFACTORY_USER="${ARTIFACTORY_USER:-${USER:-developer}}"
AZURE_KEYVAULT_NAME="${AZURE_KEYVAULT_NAME:-}"
ARTIFACTORY_SECRET_NAME="${ARTIFACTORY_SECRET_NAME:-artifactory-token}"
ARTIFACTORY_AUTO_PUBLISH="${ARTIFACTORY_AUTO_PUBLISH:-false}"

# ----------------------------------------------------------------------------
# 1. Check If Artifactory Is Configured
# ----------------------------------------------------------------------------
artifactory_is_configured() {
  [ -n "${ARTIFACTORY_URL:-}" ] && [ "$ARTIFACTORY_URL" != "NONE" ]
}

# ----------------------------------------------------------------------------
# 2. Get Zero-Trust Authentication Header (Azure Key Vault / SEPS Wallet)
# ----------------------------------------------------------------------------
artifactory_get_auth_header() {
  local token=""

  # 1. Direct environment variable if explicitly supplied (e.g. CI runner or test suite)
  if [ -n "${ARTIFACTORY_TOKEN:-}" ]; then
    token="$ARTIFACTORY_TOKEN"
  fi

  # 2. Try Azure Key Vault JIT query if configured
  if [ -z "$token" ] && [ -n "$AZURE_KEYVAULT_NAME" ] && command -v az >/dev/null 2>&1; then
    token=$(az keyvault secret show --vault-name "$AZURE_KEYVAULT_NAME" --name "$ARTIFACTORY_SECRET_NAME" --query value -o tsv 2>/dev/null || echo "")
  fi

  # 3. Try Oracle SEPS Wallet if Azure Key Vault / env didn't return a token
  if [ -z "$token" ] && [ -x "$WORKSPACE_DIR/scripts/get-password.sh" ]; then
    token=$("$WORKSPACE_DIR/scripts/get-password.sh" "ARTIFACTORY_TOKEN" 2>/dev/null | tr -d '\r\n ' || echo "")
    if [ -z "$token" ] || [[ "$token" == *"❌"* ]] || [[ "$token" == *"Viga"* ]] || [[ "$token" == *"Error"* ]]; then
      local user_pwd
      user_pwd=$("$WORKSPACE_DIR/scripts/get-password.sh" "ARTIFACTORY_PASSWORD" 2>/dev/null | tr -d '\r\n ' || echo "")
      if [ -n "$user_pwd" ] && [[ "$user_pwd" != *"❌"* ]] && [[ "$user_pwd" != *"Viga"* ]] && [[ "$user_pwd" != *"Error"* ]]; then
        echo "Authorization: Basic $(echo -n "${ARTIFACTORY_USER}:${user_pwd}" | base64)"
        return 0
      fi
      token=""
    fi
  fi

  if [ -n "$token" ]; then
    # Return header formatted for Bearer or X-JFrog-Art-Api
    echo "X-JFrog-Art-Api: $token"
    return 0
  fi

  # Anonymous access fallback
  echo ""
  return 0
}

# ----------------------------------------------------------------------------
# 3. Resolve Standardized Product Catalog URL
# ----------------------------------------------------------------------------
# Format: {ARTIFACTORY_URL}/{ARTIFACTORY_REPO}/products/{product}/{category}/{filename}
artifactory_resolve_url() {
  local product="$1"    # apex, ords, database, forms, publisher, blueprints
  local category="$2"   # binaries, patches, snapshots, images, metadata
  local filename="$3"

  local base="${ARTIFACTORY_URL%/}/${ARTIFACTORY_REPO%/}/products/${product}/${category}"
  if [ -n "$filename" ]; then
    echo "${base}/${filename}"
  else
    echo "${base}"
  fi
}

# ----------------------------------------------------------------------------
# 4. Fetch Lightweight Metadata (.meta.json) from Artifactory
# ----------------------------------------------------------------------------
artifactory_fetch_meta() {
  local product="$1"
  local category="$2"
  local meta_filename="$3"

  if ! artifactory_is_configured; then
    return 1
  fi

  local target_url
  target_url="$(artifactory_resolve_url "$product" "$category" "$meta_filename")"
  local auth_header
  auth_header="$(artifactory_get_auth_header)"

  local curl_args=("-sSL" "-f" "--connect-timeout" "5" "--max-time" "10")
  if [ -n "$auth_header" ]; then
    curl_args+=("-H" "$auth_header")
  fi

  curl "${curl_args[@]}" "$target_url" 2>/dev/null || return 1
}

# ----------------------------------------------------------------------------
# 5. Fetch Binary Package from Artifactory
# ----------------------------------------------------------------------------
artifactory_fetch_binary() {
  local product="$1"
  local filename="$2"
  local local_dest="$3"

  if ! artifactory_is_configured; then
    return 1
  fi

  local target_url
  target_url="$(artifactory_resolve_url "$product" "binaries" "$filename")"
  local auth_header
  auth_header="$(artifactory_get_auth_header)"

  mkdir -p "$(dirname "$local_dest")"
  msg_print "ARTIFACTORY_DOWNLOADING_BINARY" "$product" "$filename"

  local curl_args=("-fSL" "--connect-timeout" "10" "--progress-bar")
  if [ -n "$auth_header" ]; then
    curl_args+=("-H" "$auth_header")
  fi

  if curl "${curl_args[@]}" -o "$local_dest" "$target_url"; then
    return 0
  else
    rm -f "$local_dest" 2>/dev/null || true
    return 1
  fi
}

# ----------------------------------------------------------------------------
# 6. Fetch Patch Package with Pre-Validation from Artifactory
# ----------------------------------------------------------------------------
artifactory_fetch_patch() {
  local product="$1"
  local patch_filename="$2"
  local local_dest="$3"
  local target_app_ver="${4:-}"

  if ! artifactory_is_configured; then
    return 1
  fi

  # 1. Pre-validate patch_latest.meta.json if present
  local meta_json
  meta_json="$(artifactory_fetch_meta "$product" "patches" "patch_latest.meta.json" || true)"
  if [ -n "$meta_json" ] && [ -n "$target_app_ver" ]; then
    local patch_req_ver
    patch_req_ver=$(echo "$meta_json" | grep -o '"target_version"[[:space:]]*:[[:space:]]*"[^"]*"' | cut -d'"' -f4 || echo "")
    if [ -n "$patch_req_ver" ] && [ "$patch_req_ver" != "$target_app_ver" ]; then
      msg_print "ARTIFACTORY_META_MISMATCH_WARN" "$product patch" "$target_app_ver" "$patch_req_ver"
      return 1
    fi
  fi

  local target_url
  target_url="$(artifactory_resolve_url "$product" "patches" "$patch_filename")"
  local auth_header
  auth_header="$(artifactory_get_auth_header)"

  mkdir -p "$(dirname "$local_dest")"
  msg_print "ARTIFACTORY_DOWNLOADING_PATCH" "$product" "$patch_filename"

  local curl_args=("-fSL" "--connect-timeout" "10" "--progress-bar")
  if [ -n "$auth_header" ]; then
    curl_args+=("-H" "$auth_header")
  fi

  if curl "${curl_args[@]}" -o "$local_dest" "$target_url"; then
    return 0
  else
    rm -f "$local_dest" 2>/dev/null || true
    return 1
  fi
}

# ----------------------------------------------------------------------------
# 7. Fetch Golden Snapshot with Pre-Validation from Artifactory
# ----------------------------------------------------------------------------
artifactory_fetch_snapshot() {
  local target_id="$1"          # Blueprint ID (e.g. 3) or Profile name (e.g. db-proxy-oracle)
  local is_blueprint="${2:-true}"
  local local_dest_dir="${3:-$WORKSPACE_DIR/golden-snapshots}"
  local target_apex_ver="${4:-${PROFILE_APEX_VERSION:-26.1}}"

  if ! artifactory_is_configured; then
    return 1
  fi

  local product_path meta_name tar_name
  if [ "$is_blueprint" = "true" ]; then
    product_path="blueprints/bp_${target_id}"
    meta_name="bp_${target_id}_latest.meta.json"
    tar_name="bp_${target_id}_latest.tar.gz"
  else
    local clean_prof
    clean_prof=$(echo "$target_id" | sed 's/\.yaml$//' | tr '/' '_')
    product_path="profiles/${clean_prof}"
    meta_name="profile_${clean_prof}_latest.meta.json"
    tar_name="profile_${clean_prof}_latest.tar.gz"
  fi

  msg_print "ARTIFACTORY_CHECKING_CATALOG" "$target_id" "$product_path"

  # 1. Fetch remote .meta.json into temporary file
  local temp_meta
  temp_meta="$(mktemp 2>/dev/null || mktemp -t 'art_meta')"
  local meta_url
  meta_url="${ARTIFACTORY_URL%/}/${ARTIFACTORY_REPO%/}/products/${product_path}/${meta_name}"
  local auth_header
  auth_header="$(artifactory_get_auth_header)"

  local curl_args=("-sSL" "-f" "--connect-timeout" "5" "--max-time" "10")
  if [ -n "$auth_header" ]; then
    curl_args+=("-H" "$auth_header")
  fi

  if ! curl "${curl_args[@]}" -o "$temp_meta" "$meta_url" 2>/dev/null; then
    rm -f "$temp_meta" 2>/dev/null || true
    return 1
  fi

  # 2. Validate version compatibility before downloading large archive
  if declare -f verify_snapshot_version_match >/dev/null 2>&1; then
    if ! verify_snapshot_version_match "$temp_meta" "$target_apex_ver" "$target_id"; then
      msg_print "ARTIFACTORY_META_MISMATCH_WARN" "$target_id" "$target_apex_ver" "Remote mismatch"
      rm -f "$temp_meta" 2>/dev/null || true
      return 1
    fi
  fi

  msg_print "ARTIFACTORY_META_MATCH_OK" "$target_id"
  msg_print "ARTIFACTORY_DOWNLOADING_SNAPSHOT" "$target_id"

  mkdir -p "$local_dest_dir"
  local local_tar="$local_dest_dir/$tar_name"
  local local_meta="$local_dest_dir/$meta_name"
  local tar_url="${ARTIFACTORY_URL%/}/${ARTIFACTORY_REPO%/}/products/${product_path}/${tar_name}"

  local dl_args=("-fSL" "--connect-timeout" "10" "--progress-bar")
  if [ -n "$auth_header" ]; then
    dl_args+=("-H" "$auth_header")
  fi

  if curl "${dl_args[@]}" -o "$local_tar" "$tar_url"; then
    mv "$temp_meta" "$local_meta"
    # Also link canonical latest alias if blueprint 3 or default profile
    if [ "$target_id" = "3" ] || [ "$target_id" = "db-proxy-oracle" ]; then
      cp "$local_tar" "$local_dest_dir/apex_proxy_oradata_latest.tar.gz" 2>/dev/null || true
      cp "$local_meta" "$local_dest_dir/apex_proxy_oradata_latest.meta.json" 2>/dev/null || true
    fi
    return 0
  else
    rm -f "$local_tar" "$temp_meta" 2>/dev/null || true
    return 1
  fi
}

# ----------------------------------------------------------------------------
# 8. Publish Artifact and Metadata to Artifactory Product Catalog
# ----------------------------------------------------------------------------
artifactory_publish_artifact() {
  local product="$1"      # apex, ords, database, forms, publisher, blueprints
  local category="$2"     # binaries, patches, snapshots, images, metadata
  local local_file="$3"
  local meta_file="${4:-}"
  local subpath="${5:-}"

  if ! artifactory_is_configured; then
    echo "⚠️  Artifactory is not configured (ARTIFACTORY_URL is empty). Skipping upload."
    return 1
  fi

  if [ ! -f "$local_file" ]; then
    echo "❌ Error: Local file not found: $local_file"
    return 1
  fi

  local filename
  filename="$(basename "$local_file")"
  local target_url
  if [ -n "$subpath" ]; then
    target_url="${ARTIFACTORY_URL%/}/${ARTIFACTORY_REPO%/}/products/${product}/${subpath}/${filename}"
  else
    target_url="$(artifactory_resolve_url "$product" "$category" "$filename")"
  fi

  local auth_header
  auth_header="$(artifactory_get_auth_header)"

  msg_print "ARTIFACTORY_PUBLISHING_ARTIFACT" "$filename" "$target_url"

  local curl_args=("-fSL" "-X" "PUT" "--upload-file" "$local_file" "--connect-timeout" "10")
  if [ -n "$auth_header" ]; then
    curl_args+=("-H" "$auth_header")
  fi

  if curl "${curl_args[@]}" "$target_url" >/dev/null 2>&1; then
    msg_print "ARTIFACTORY_PUBLISH_SUCCESS" "$filename" "$ARTIFACTORY_REPO"
    
    # Upload companion .meta.json if present
    if [ -n "$meta_file" ] && [ -f "$meta_file" ]; then
      local meta_target_url="${target_url%.tar.gz}.meta.json"
      local meta_args=("-sSL" "-f" "-X" "PUT" "--upload-file" "$meta_file")
      if [ -n "$auth_header" ]; then
        meta_args+=("-H" "$auth_header")
      fi
      curl "${meta_args[@]}" "$meta_target_url" >/dev/null 2>&1 || true
    fi
    return 0
  else
    echo "❌ Failed to upload $filename to $target_url"
    return 1
  fi
}
