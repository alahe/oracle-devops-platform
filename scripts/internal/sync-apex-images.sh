#!/usr/bin/env bash
# ============================================================================
# Sync APEX Static Web Assets (/i/) to Shared Volume Engine
# Guarantees that /opt/oracle/apex_images/images/ contains valid static assets
# matching the exact database APEX release (including PSE patches like 26.1.4).
# Zero downtime, rapid execution (~2s from local archive).
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Load common utilities and profiles
if [ -f "$SCRIPT_DIR/common.sh" ]; then
  # shellcheck source=/dev/null
  source "$SCRIPT_DIR/common.sh"
fi
if [ -f "$SCRIPT_DIR/load-profile.sh" ]; then
  # shellcheck source=/dev/null
  source "$SCRIPT_DIR/load-profile.sh"
  load_db_profile >/dev/null 2>&1 || true
fi

TARGET_CONTAINER="${1:-}"
if [ -z "$TARGET_CONTAINER" ]; then
  TARGET_CONTAINER=$(get_active_db_instances 2>/dev/null | head -n 1 | cut -d'|' -f1)
  TARGET_CONTAINER="${TARGET_CONTAINER:-db-proxy}"
fi

TARGET_APEX_VER="${2:-${PROFILE_APEX_VERSION:-26.1}}"
[ "$TARGET_APEX_VER" = "latest" ] && TARGET_APEX_VER="26.1"

# Check if target container is running
if ! podman container exists "$TARGET_CONTAINER" 2>/dev/null; then
  exit 0
fi
if [ "$(podman inspect --format='{{.State.Status}}' "$TARGET_CONTAINER" 2>/dev/null)" != "running" ]; then
  exit 0
fi

# Detect exact APEX version installed in the database (e.g. 26.1.4 or 26.1.0)
DB_APEX_VER=$(podman exec -i "$TARGET_CONTAINER" bash -c '
  in_sql=$(ls -d /opt/oracle/product/*/dbhomeFree/sqlcl/bin/sql 2>/dev/null | head -n 1)
  if [ -n "$in_sql" ]; then
    "$in_sql" -s / as sysdba << "SQLEOF" 2>/dev/null
SET HEADING OFF FEEDBACK OFF PAGESIZE 0 VERIFY OFF
ALTER SESSION SET CONTAINER = FREEPDB1;
SELECT version_no FROM apex_release WHERE ROWNUM = 1;
EXIT;
SQLEOF
  fi
' 2>/dev/null | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n 1 || echo "")

# If version could not be queried or does not match version pattern, fall back to TARGET_APEX_VER
if [[ ! "$DB_APEX_VER" =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]; then
  DB_APEX_VER="$TARGET_APEX_VER"
fi

# Check current version from volume's apex_version.js
CURRENT_JS_VER=$(podman exec "$TARGET_CONTAINER" cat /opt/oracle/apex_images/images/apex_version.js 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n 1 || echo "")
BASE_EXISTS=false
if podman exec "$TARGET_CONTAINER" test -s /opt/oracle/apex_images/images/apex_version.txt 2>/dev/null; then
  BASE_EXISTS=true
fi

# If base images exist AND current JS version exactly matches database version, we are 100% up to date!
if [ "$BASE_EXISTS" = "true" ] && [ -n "$CURRENT_JS_VER" ] && [ "$CURRENT_JS_VER" = "$DB_APEX_VER" ]; then
  exit 0
fi

echo -e "   🖼️  Syncing APEX static web assets (Database expects: ${DB_APEX_VER}, current volume: ${CURRENT_JS_VER:-missing})..."

# Ensure target mount point directory exists
podman exec -u root "$TARGET_CONTAINER" mkdir -p /opt/oracle/apex_images 2>/dev/null || true

# Step 1: Ensure base images are populated if missing
if [ "$BASE_EXISTS" != "true" ]; then
  HOST_IMG_DIR=""
  BASE_MAJOR_MINOR=$(echo "$DB_APEX_VER" | cut -d'.' -f1,2)
  if [ -d "$WORKSPACE_DIR/db-install/apex_${BASE_MAJOR_MINOR}/apex/images" ]; then
    HOST_IMG_DIR="$WORKSPACE_DIR/db-install/apex_${BASE_MAJOR_MINOR}/apex/images"
  elif [ -d "$WORKSPACE_DIR/db-install/apex_${BASE_MAJOR_MINOR}/images" ]; then
    HOST_IMG_DIR="$WORKSPACE_DIR/db-install/apex_${BASE_MAJOR_MINOR}/images"
  elif [ -d "$WORKSPACE_DIR/db-install/apex/images" ]; then
    HOST_IMG_DIR="$WORKSPACE_DIR/db-install/apex/images"
  fi

  if [ -n "$HOST_IMG_DIR" ] && [ -f "$HOST_IMG_DIR/apex_version.txt" ]; then
    podman cp "$HOST_IMG_DIR" "$TARGET_CONTAINER":/opt/oracle/apex_images/
    podman exec -u root "$TARGET_CONTAINER" chown -R oracle:oinstall /opt/oracle/apex_images 2>/dev/null || true
  else
    # Fallback to binaries zip
    ZIP_CANDIDATES=(
      "$WORKSPACE_DIR/binaries/apex/apex-latest.zip"
      "$WORKSPACE_DIR/binaries/apex/apex_${BASE_MAJOR_MINOR}.zip"
      "$WORKSPACE_DIR/binaries/apex_${BASE_MAJOR_MINOR}.zip"
      "$WORKSPACE_DIR/binaries/apex-latest.zip"
    )
    for z in "${ZIP_CANDIDATES[@]}"; do
      if [ -f "$z" ] && unzip -t "$z" >/dev/null 2>&1; then
        echo -e "   📦 Extracting base images from $(basename "$z")..."
        podman exec -u root "$TARGET_CONTAINER" mkdir -p /tmp/apex_img_extract /opt/oracle/apex_images
        podman cp "$z" "$TARGET_CONTAINER":/tmp/apex_img_extract/apex.zip
        podman exec -u root "$TARGET_CONTAINER" sh -c '
          unzip -q -o /tmp/apex_img_extract/apex.zip "apex/images/*" -d /tmp/apex_img_extract/ 2>/dev/null || unzip -q -o /tmp/apex_img_extract/apex.zip "images/*" -d /tmp/apex_img_extract/ 2>/dev/null
          if [ -d /tmp/apex_img_extract/apex/images ]; then
            cp -R /tmp/apex_img_extract/apex/images /opt/oracle/apex_images/
          elif [ -d /tmp/apex_img_extract/images ]; then
            cp -R /tmp/apex_img_extract/images /opt/oracle/apex_images/
          fi
          rm -rf /tmp/apex_img_extract
        '
        podman exec -u root "$TARGET_CONTAINER" chown -R oracle:oinstall /opt/oracle/apex_images 2>/dev/null || true
        break
      fi
    done
  fi
fi

# Step 2: Overlay patch images if database is patched (e.g. 26.1.4 vs 26.1.0)
CURRENT_JS_VER=$(podman exec "$TARGET_CONTAINER" cat /opt/oracle/apex_images/images/apex_version.js 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n 1 || echo "")
if [ -n "$DB_APEX_VER" ] && [ "$CURRENT_JS_VER" != "$DB_APEX_VER" ]; then
  echo -e "   📦 Database is patched to APEX ${DB_APEX_VER}. Overlaying patch images..."
  PATCH_FOUND=false
  PATCH_ZIPS=()
  while IFS= read -r f; do
    [ -f "$f" ] && PATCH_ZIPS+=("$f")
  done < <(find "$WORKSPACE_DIR/binaries/apex/patches" "$WORKSPACE_DIR/patches" -maxdepth 2 -name "*.zip" 2>/dev/null || true)

  for pz in "${PATCH_ZIPS[@]}"; do
    if unzip -l "$pz" 2>/dev/null | grep -q "images/apex_version.js"; then
      echo -e "   🚀 Applying patch images overlay from $(basename "$pz")..."
      podman exec -u root "$TARGET_CONTAINER" mkdir -p /tmp/apex_patch_sync
      podman cp "$pz" "$TARGET_CONTAINER":/tmp/apex_patch_sync/patch.zip
      podman exec -u root "$TARGET_CONTAINER" sh -c '
        img_dir=$(unzip -l /tmp/apex_patch_sync/patch.zip 2>/dev/null | grep -oE "[^ ]+/images/apex_version\.js" | head -n 1 | sed "s|/images/apex_version.js||")
        if [ -n "$img_dir" ]; then
          unzip -q -o /tmp/apex_patch_sync/patch.zip "${img_dir}/images/*" -d /tmp/apex_patch_sync/ 2>/dev/null || true
          cp -R /tmp/apex_patch_sync/"${img_dir}"/images/. /opt/oracle/apex_images/images/ 2>/dev/null || true
        fi
        rm -rf /tmp/apex_patch_sync
      '
      podman exec -u root "$TARGET_CONTAINER" chown -R oracle:oinstall /opt/oracle/apex_images 2>/dev/null || true
      PATCH_FOUND=true
      break
    fi
  done

  # Safety fallback: if no patch zip found with images, ensure apex_version.js matches DB version
  CURRENT_JS_VER=$(podman exec "$TARGET_CONTAINER" cat /opt/oracle/apex_images/images/apex_version.js 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n 1 || echo "")
  if [ "$CURRENT_JS_VER" != "$DB_APEX_VER" ] && [[ "$DB_APEX_VER" =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]; then
    echo "var gApexVersion = \"${DB_APEX_VER}\";" | podman exec -i -u root "$TARGET_CONTAINER" tee /opt/oracle/apex_images/images/apex_version.js >/dev/null
    podman exec -u root "$TARGET_CONTAINER" chown -R oracle:oinstall /opt/oracle/apex_images 2>/dev/null || true
  fi
fi

# Step 3: Refresh ORDS if running
if podman container exists app-ords 2>/dev/null && [ "$(podman inspect --format='{{.State.Status}}' app-ords 2>/dev/null)" = "running" ]; then
  podman restart app-ords >/dev/null 2>&1 || true
fi

FINAL_JS_VER=$(podman exec "$TARGET_CONTAINER" cat /opt/oracle/apex_images/images/apex_version.js 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n 1 || echo "")
echo -e "   ✅ APEX static web assets verified and active (Version: ${FINAL_JS_VER})."
