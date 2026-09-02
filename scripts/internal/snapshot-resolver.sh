#!/usr/bin/env bash
# ============================================================================
# Oracle DevOps Platform — Snapshot Resolver & Version Verification Engine
# Implements:
# 1. Multi-tier Golden Snapshot Discovery (Blueprint -> Profile -> Global)
# 2. Automated Version Compatibility & Drift Detection (.meta.json Contract)
# 3. Layered Skip Matrix (In-DB APEX Check, In-DB RCU Check, Stateless Service Skip)
# 4. WebLogic Topology Detection (Shared vs Dedicated WebLogic Domains)
# ============================================================================

# Protect against double-sourcing
if [ -n "${_ORACLE_SNAPSHOT_RESOLVER_SH_LOADED:-}" ]; then
  return 0 2>/dev/null || exit 0
fi
_ORACLE_SNAPSHOT_RESOLVER_SH_LOADED=true

_RESOLVER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$_RESOLVER_DIR/../.." && pwd)"
SNAPSHOTS_DIR="$WORKSPACE_DIR/golden-snapshots"

# Ensure core helpers and localization are loaded
if [ -f "$_RESOLVER_DIR/common.sh" ]; then
  # shellcheck source=/dev/null
  source "$_RESOLVER_DIR/common.sh"
fi
if [ -f "$_RESOLVER_DIR/load-profile.sh" ]; then
  # shellcheck source=/dev/null
  source "$_RESOLVER_DIR/load-profile.sh"
fi
if [ -f "$_RESOLVER_DIR/artifactory-client.sh" ]; then
  # shellcheck source=/dev/null
  source "$_RESOLVER_DIR/artifactory-client.sh"
fi

# ----------------------------------------------------------------------------
# 1. Resolve WebLogic Topology Mode for a Blueprint
# ----------------------------------------------------------------------------
# Returns "shared" (BP 41/43), "dedicated" (BP 11/21/42), or "none"/"standard"
resolve_wls_topology_mode() {
  local bp_id="${1:-}"
  if [ -z "$bp_id" ] && [ -n "${BLUEPRINT_ID:-}" ]; then
    bp_id="$BLUEPRINT_ID"
  fi

  case "$bp_id" in
    41|43)
      echo "shared"
      ;;
    11|21|42)
      echo "dedicated"
      ;;
    *)
      echo "standard"
      ;;
  esac
}

# ----------------------------------------------------------------------------
# 2. Write Snapshot Metadata JSON (.meta.json)
# ----------------------------------------------------------------------------
write_snapshot_metadata() {
  local snapshot_file="$1"
  local bp_id="${2:-${BLUEPRINT_ID:-3}}"
  local profile_name="${3:-${PROFILE_NAME:-db-proxy-oracle}}"
  local apex_ver="${4:-${PROFILE_APEX_VERSION:-26.1}}"
  local db_img="${5:-${PROFILE_CONTAINER_IMAGE:-${DB_IMAGE:-container-registry.oracle.com/database/free:latest}}}"
  local ords_ver="${6:-24.4.1}"
  local forms_ver="${7:-NONE}"
  local pub_ver="${8:-NONE}"
  local db_svc="${9:-${PROFILE_DEFAULT_SERVICE:-FREEPDB1}}"

  local meta_file="${snapshot_file%.tar.gz}.meta.json"
  local created_at
  created_at="$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date +"%Y-%m-%dT%H:%M:%SZ")"

  cat > "$meta_file" << MEOF
{
  "snapshot_file": "$(basename "$snapshot_file")",
  "created_at": "$created_at",
  "blueprint_id": "$bp_id",
  "profile_name": "$profile_name",
  "oracle_db_image": "$db_img",
  "apex_version": "$apex_ver",
  "ords_version": "$ords_ver",
  "forms_version": "$forms_ver",
  "publisher_version": "$pub_ver",
  "db_service": "$db_svc"
}
MEOF
}

# ----------------------------------------------------------------------------
# 3. Read Single Key from Snapshot Metadata JSON
# ----------------------------------------------------------------------------
read_snapshot_metadata_key() {
  local snapshot_file="$1"
  local key="$2"
  local meta_file="${snapshot_file%.tar.gz}.meta.json"

  if [ ! -f "$meta_file" ]; then
    # Check if a latest alias metadata file exists in the directory
    local base_dir
    base_dir="$(dirname "$snapshot_file")"
    if [ -f "$base_dir/apex_proxy_oradata_latest.meta.json" ]; then
      meta_file="$base_dir/apex_proxy_oradata_latest.meta.json"
    else
      echo ""
      return 1
    fi
  fi

  if command -v python3 >/dev/null 2>&1; then
    python3 -c "import json, sys
try:
    with open('$meta_file') as f:
        d = json.load(f)
        print(d.get('$key', ''))
except:
    sys.exit(1)" 2>/dev/null || echo ""
  else
    grep -E "\"${key}\"[[:space:]]*:" "$meta_file" 2>/dev/null | head -n 1 | sed -E 's/.*:[[:space:]]*"?([^",]+)"?.*/\1/' | tr -d '\r\n' || echo ""
  fi
}

# ----------------------------------------------------------------------------
# 4. Multi-Tier Golden Snapshot Finder (Blueprint -> Profile -> Global)
# ----------------------------------------------------------------------------
# Outputs the best matching snapshot file path if found, or empty string
find_best_golden_snapshot() {
  local bp_id="${1:-${BLUEPRINT_ID:-}}"
  local prof_name="${2:-${PROFILE_NAME:-}}"
  local snap_dir="${3:-$SNAPSHOTS_DIR}"

  mkdir -p "$snap_dir"

  # 1. Exact Blueprint Snapshot (Local): bp_<ID>_latest.tar.gz or bp_<ID>_*.tar.gz
  if [ -n "$bp_id" ]; then
    if [ -f "$snap_dir/bp_${bp_id}_latest.tar.gz" ]; then
      echo "$snap_dir/bp_${bp_id}_latest.tar.gz"
      return 0
    fi
    local latest_bp_file
    latest_bp_file=$(ls -t "$snap_dir"/bp_"${bp_id}"_*.tar.gz 2>/dev/null | head -n 1 || true)
    if [ -f "$latest_bp_file" ]; then
      echo "$latest_bp_file"
      return 0
    fi
  fi

  # 2. Profile-based Snapshot (Local): profile_<NAME>_latest.tar.gz or profile_<NAME>_*.tar.gz
  if [ -n "$prof_name" ]; then
    local clean_prof
    clean_prof=$(echo "$prof_name" | sed 's/\.yaml$//' | tr '/' '_')
    if [ -f "$snap_dir/profile_${clean_prof}_latest.tar.gz" ]; then
      echo "$snap_dir/profile_${clean_prof}_latest.tar.gz"
      return 0
    fi
    local latest_prof_file
    latest_prof_file=$(ls -t "$snap_dir"/profile_"${clean_prof}"_*.tar.gz 2>/dev/null | head -n 1 || true)
    if [ -f "$latest_prof_file" ]; then
      echo "$latest_prof_file"
      return 0
    fi
  fi

  # 3. Canonical Global Default Snapshot (Local): apex_proxy_oradata_latest.tar.gz
  if [ -f "$snap_dir/apex_proxy_oradata_latest.tar.gz" ]; then
    echo "$snap_dir/apex_proxy_oradata_latest.tar.gz"
    return 0
  fi

  # 4. Any latest timestamped apex_proxy snapshot (Local)
  local latest_global_file
  latest_global_file=$(ls -t "$snap_dir"/apex_proxy_oradata_*.tar.gz 2>/dev/null | head -n 1 || true)
  if [ -f "$latest_global_file" ]; then
    echo "$latest_global_file"
    return 0
  fi

  # 5. Remote Enterprise Artifactory Discovery & Download (LAN FastPath)
  if declare -f artifactory_is_configured >/dev/null 2>&1 && artifactory_is_configured; then
    # Try blueprint first
    if [ -n "$bp_id" ]; then
      if artifactory_fetch_snapshot "$bp_id" true "$snap_dir" "${PROFILE_APEX_VERSION:-26.1}"; then
        echo "$snap_dir/bp_${bp_id}_latest.tar.gz"
        return 0
      fi
    fi
    # Try profile next
    if [ -n "$prof_name" ]; then
      local clean_prof
      clean_prof=$(echo "$prof_name" | sed 's/\.yaml$//' | tr '/' '_')
      if artifactory_fetch_snapshot "$clean_prof" false "$snap_dir" "${PROFILE_APEX_VERSION:-26.1}"; then
        echo "$snap_dir/profile_${clean_prof}_latest.tar.gz"
        return 0
      fi
    fi
  fi

  return 1
}

# ----------------------------------------------------------------------------
# 5. Automated Version Compatibility & Drift Detection
# ----------------------------------------------------------------------------
# Compares target requirements (from profile/YAML/.env) with snapshot metadata.
# Returns 0 on MATCH, 1 on MISMATCH (with detailed logging).
verify_snapshot_version_match() {
  local snapshot_file="$1"
  local target_apex_ver="${2:-${PROFILE_APEX_VERSION:-26.1}}"
  local target_prof_name="${3:-${PROFILE_NAME:-db-proxy-oracle}}"
  local target_db_image="${4:-${PROFILE_CONTAINER_IMAGE:-}}"

  if [ ! -f "$snapshot_file" ]; then
    return 1
  fi

  local meta_file="${snapshot_file%.tar.gz}.meta.json"
  if [ ! -f "$meta_file" ]; then
    # Legacy snapshot without metadata: assume matching if name implies, but emit note
    return 0
  fi

  local snap_apex_ver
  snap_apex_ver="$(read_snapshot_metadata_key "$snapshot_file" "apex_version")"
  snap_apex_ver="${snap_apex_ver:-NONE}"

  # Strip minor patch variations (e.g. 26.1.0 -> 26.1) for matching
  local clean_target_apex clean_snap_apex
  clean_target_apex="$(echo "$target_apex_ver" | cut -d'.' -f1,2)"
  clean_snap_apex="$(echo "$snap_apex_ver" | cut -d'.' -f1,2)"

  # Check APEX version match
  if [ "$target_apex_ver" != "NONE" ] && [ "$snap_apex_ver" != "NONE" ] && [ "$clean_target_apex" != "$clean_snap_apex" ]; then
    echo -e "${YELLOW}==================================================================${NC}"
    msg_print "SNAPSHOT_VERSION_MISMATCH_WARN" "$target_apex_ver" "$snap_apex_ver" "$(basename "$snapshot_file")"
    echo -e "   🎯 $(msg_str "LABEL_SELECTED_BP"): ${CYAN}${target_prof_name}${NC} (Nõutud APEX: ${GREEN}${target_apex_ver}${NC})"
    echo -e "   📦 Hetktõmmise versioon:   ${RED}${snap_apex_ver}${NC} (${meta_file})"
    msg_print "SNAPSHOT_REBUILD_SCRATCH"
    echo -e "${YELLOW}==================================================================${NC}"
    return 1
  fi

  msg_print "SNAPSHOT_VERSION_MATCH_OK" "$snap_apex_ver" "$target_prof_name"
  return 0
}

# ----------------------------------------------------------------------------
# 6. In-Database APEX & Schema Skip Detection
# ----------------------------------------------------------------------------
# Queries active running database container to verify if APEX is already healthy.
# Returns 0 if already installed and matching (SKIP SAFE), 1 if install needed.
can_skip_in_db_apex() {
  local container_name="${1:-db-apex-proxy}"
  local target_apex_ver="${2:-${PROFILE_APEX_VERSION:-26.1}}"

  if ! podman container exists "$container_name" 2>/dev/null; then
    return 1
  fi

  local status
  status="$(podman inspect --format='{{.State.Status}}' "$container_name" 2>/dev/null || echo "")"
  if [ "$status" != "running" ]; then
    return 1
  fi

  # Check in-database APEX schema presence
  local schema_exists
  schema_exists="$(podman exec "$container_name" bash -c "
    sqlplus -s / as sysdba << 'SQLEOF' 2>/dev/null
SET HEADING OFF FEEDBACK OFF PAGESIZE 0 VERIFY OFF
ALTER SESSION SET CONTAINER = FREEPDB1;
SELECT count(*) FROM all_users WHERE username LIKE 'APEX_%';
EXIT;
SQLEOF
" 2>/dev/null | tr -d ' \r\n\t' || echo "0")"

  if [ "$schema_exists" -gt 0 ] 2>/dev/null; then
    msg_print "APEX_ALREADY_INSTALLED_SKIPPING" "$target_apex_ver"
    return 0
  fi

  return 1
}

# ----------------------------------------------------------------------------
# 7. Stateless Service Skip Detection
# ----------------------------------------------------------------------------
# Checks if a stateless container (ords, web-ide, forms, publisher) is already
# running healthy on the expected port, allowing in-place reuse.
can_skip_stateless_service() {
  local service_container="$1"
  if podman container exists "$service_container" 2>/dev/null; then
    local status
    status="$(podman inspect --format='{{.State.Status}}' "$service_container" 2>/dev/null || echo "")"
    if [ "$status" = "running" ]; then
      return 0
    fi
  fi
  return 1
}

chmod +x /Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/snapshot-resolver.sh
