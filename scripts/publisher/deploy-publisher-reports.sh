#!/usr/bin/env bash
# ==============================================================================
# Oracle Analytics Publisher Reports Deployment & Git Synchronization Script
# Deploys user-created reports (.xdo, .xdoz) and data models (.xdm, .xdmz)
# from a decoupled Git repository (PUBLISHER_REPORTS_GIT_URL) or local folder.
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [ -f "$WORKSPACE_DIR/scripts/internal/common.sh" ]; then
  source "$WORKSPACE_DIR/scripts/internal/common.sh"
else
  GREEN=$'\033[1;32m'
  RED=$'\033[1;31m'
  YELLOW=$'\033[0;33m'
  CYAN=$'\033[1;36m'
  NC=$'\033[0m'
fi

# Load environment configuration
if [ -f "$WORKSPACE_DIR/.env" ]; then
  set -a
  source "$WORKSPACE_DIR/.env"
  set +a
fi

CONTAINER_NAME="${PUBLISHER_CONTAINER_NAME:-app-publisher}"
RUNTIME_ENGINE="${CONTAINER_ENGINE:-podman}"
DEPLOY_MODE="${PUBLISHER_REPORT_DEPLOY_MODE:-catalog}" # catalog or rest
REPORTS_ARTIFACTORY_URL="${PUBLISHER_REPORTS_ARTIFACTORY_URL:-}"
REPORTS_GIT_URL="${PUBLISHER_REPORTS_GIT_URL:-}"
REPORTS_GIT_BRANCH="${PUBLISHER_REPORTS_GIT_BRANCH:-main}"
LOCAL_CACHE_DIR="$WORKSPACE_DIR/binaries/publisher_reports"
LOCAL_DEV_DIR="$WORKSPACE_DIR/applications/publisher"

LOG_DIR="$WORKSPACE_DIR/install_logs"
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BP_TAG=""
if [ -n "${SELECTED_BLUEPRINT:-}" ]; then
  BP_TAG="bp_${SELECTED_BLUEPRINT}_"
elif [ -n "${ACTIVE_BLUEPRINT:-}" ]; then
  BP_TAG="bp_${ACTIVE_BLUEPRINT}_"
fi
LOG_FILE="$LOG_DIR/publisher_reports_deploy_${BP_TAG}${TIMESTAMP}.log"
[ -n "${BP_TAG}" ] && ln -sf "$LOG_FILE" "$LOG_DIR/publisher_reports_deploy_${BP_TAG}latest.log" 2>/dev/null || true

echo "======================================================================" | tee -a "$LOG_FILE"
echo "🚀 Oracle Analytics Publisher Report & Template Deployment" | tee -a "$LOG_FILE"
echo "======================================================================" | tee -a "$LOG_FILE"

# 1. Synchronize Source (Artifactory Binary vs Decoupled Git vs Local Folder)
TARGET_REPORTS_DIR=""

if [ -n "${REPORTS_ARTIFACTORY_URL}" ]; then
  echo -e "${CYAN}1. Fetching reports package from Artifactory:${NC} ${REPORTS_ARTIFACTORY_URL}" | tee -a "$LOG_FILE"
  mkdir -p "$LOCAL_CACHE_DIR"
  
  AUTH_HEADER=()
  if [ -n "${ARTIFACTORY_TOKEN:-}" ]; then
    AUTH_HEADER=(-H "Authorization: Bearer ${ARTIFACTORY_TOKEN}")
  elif [ -n "${ARTIFACTORY_USER:-}" ] && [ -n "${ARTIFACTORY_PASSWORD:-}" ]; then
    AUTH_HEADER=(-u "${ARTIFACTORY_USER}:${ARTIFACTORY_PASSWORD}")
  fi
  
  TMP_ARCHIVE="/tmp/publisher_reports_artifactory_${TIMESTAMP}.zip"
  curl -sSL "${AUTH_HEADER[@]}" -o "$TMP_ARCHIVE" "$REPORTS_ARTIFACTORY_URL" >> "$LOG_FILE" 2>&1 || true
  
  if [ -f "$TMP_ARCHIVE" ] && [ -s "$TMP_ARCHIVE" ]; then
    if [[ "$REPORTS_ARTIFACTORY_URL" == *.tar.gz || "$REPORTS_ARTIFACTORY_URL" == *.tgz ]]; then
      tar -xzf "$TMP_ARCHIVE" -C "$LOCAL_CACHE_DIR" >> "$LOG_FILE" 2>&1 || true
    else
      unzip -q -o "$TMP_ARCHIVE" -d "$LOCAL_CACHE_DIR" >> "$LOG_FILE" 2>&1 || true
    fi
    rm -f "$TMP_ARCHIVE"
    echo -e "${GREEN}✅ Artifactory reports package downloaded and extracted successfully!${NC}" | tee -a "$LOG_FILE"
  fi
  TARGET_REPORTS_DIR="$LOCAL_CACHE_DIR"
elif [ -n "${REPORTS_GIT_URL}" ]; then
  echo -e "${CYAN}1. Synchronizing decoupled reports Git repository:${NC} ${REPORTS_GIT_URL} (Branch: ${REPORTS_GIT_BRANCH})" | tee -a "$LOG_FILE"
  mkdir -p "$LOCAL_CACHE_DIR"
  if [ -d "$LOCAL_CACHE_DIR/.git" ]; then
    (cd "$LOCAL_CACHE_DIR" && git fetch origin && git checkout "$REPORTS_GIT_BRANCH" && git pull origin "$REPORTS_GIT_BRANCH") >> "$LOG_FILE" 2>&1 || true
  else
    git clone -b "$REPORTS_GIT_BRANCH" "$REPORTS_GIT_URL" "$LOCAL_CACHE_DIR" >> "$LOG_FILE" 2>&1 || true
  fi
  TARGET_REPORTS_DIR="$LOCAL_CACHE_DIR"
elif [ -d "$LOCAL_DEV_DIR" ]; then
  echo -e "${CYAN}1. Using local reports directory:${NC} ${LOCAL_DEV_DIR}" | tee -a "$LOG_FILE"
  TARGET_REPORTS_DIR="$LOCAL_DEV_DIR"
elif [ -d "$LOCAL_CACHE_DIR" ]; then
  echo -e "${CYAN}1. Using cached reports directory:${NC} ${LOCAL_CACHE_DIR}" | tee -a "$LOG_FILE"
  TARGET_REPORTS_DIR="$LOCAL_CACHE_DIR"
else
  echo -e "${YELLOW}ℹ️ No reports source found. Creating sample directory structure...${NC}" | tee -a "$LOG_FILE"
  mkdir -p "$LOCAL_DEV_DIR/Custom/Reports"
  TARGET_REPORTS_DIR="$LOCAL_DEV_DIR"
fi

echo -e "   └─ Reports source: ${TARGET_REPORTS_DIR}" | tee -a "$LOG_FILE"

# 2. Deploy Reports to Publisher
if ! "${RUNTIME_ENGINE}" ps --format "{{.Names}}" 2>/dev/null | grep -q "^${CONTAINER_NAME}$"; then
  echo -e "${YELLOW}⚠️ Container ${CONTAINER_NAME} is not running. Skipping physical report deployment.${NC}" | tee -a "$LOG_FILE"
  exit 0
fi

echo -e "${CYAN}2. Deploying reports and layouts (Mode: ${DEPLOY_MODE})...${NC}" | tee -a "$LOG_FILE"

if [ "$DEPLOY_MODE" = "catalog" ]; then
  # Direct Catalog Volume Sync
  echo "   └─ Copying report files to Publisher catalog (/u01/.../bipublisher/repository/)..." | tee -a "$LOG_FILE"
  "${RUNTIME_ENGINE}" cp "${TARGET_REPORTS_DIR}/." "${CONTAINER_NAME}:/u01/oracle/user_projects/domains/bi/bidata/components/bipublisher/repository/" >> "$LOG_FILE" 2>&1 || true
  "${RUNTIME_ENGINE}" exec -i "${CONTAINER_NAME}" chmod -R 775 /u01/oracle/user_projects/domains/bi/bidata/components/bipublisher/repository/ >> "$LOG_FILE" 2>&1 || true
  echo -e "${GREEN}✅ Reports copied to Publisher catalog successfully!${NC}" | tee -a "$LOG_FILE"
else
  # REST API Upload
  PUBLISHER_URL="${PUBLISHER_URL:-http://localhost:9502/xmlpserver}"
  ADMIN_USER="${ADMIN_USERNAME:-weblogic}"
  if [ -n "$ADMIN_PASSWORD" ]; then
    ADMIN_PWD="$ADMIN_PASSWORD"
  else
    ADMIN_PWD=$("$SCRIPT_DIR/get-password.sh" "DB_PUBLISHER_SYS" 2>/dev/null | grep "Password:" | awk '{print $3}' | sed 's/\x1b\[[0-9;]*m//g' | tr -d '\r\n' || echo "")
  fi

  find "${TARGET_REPORTS_DIR}" -type f \( -name "*.xdoz" -o -name "*.xdmz" \) | while read -r report_file; do
    rel_path="${report_file#"${TARGET_REPORTS_DIR}"/}"
    echo "   └─ REST upload: ${rel_path}..." | tee -a "$LOG_FILE"
    curl -s -u "${ADMIN_USER}:${ADMIN_PWD}" -F "reportPath=/Custom/${rel_path}" -F "file=@${report_file}" "${PUBLISHER_URL}/services/rest/v1/reports" >> "$LOG_FILE" 2>&1 || true
  done
  echo -e "${GREEN}✅ Reports uploaded via Publisher REST API successfully!${NC}" | tee -a "$LOG_FILE"
fi
# 3. Synchronize Centralized Corporate Assets (Logos & Shared Images)
COMMON_IMAGES="$WORKSPACE_DIR/templates/publisher/common/images"
if [ -d "$COMMON_IMAGES" ] && "${RUNTIME_ENGINE}" ps --format "{{.Names}}" 2>/dev/null | grep -q "^${CONTAINER_NAME}$"; then
  echo -e "${CYAN}3. Synchronizing centralized image assets (${COMMON_IMAGES})...${NC}" | tee -a "$LOG_FILE"
  "${RUNTIME_ENGINE}" exec -i "${CONTAINER_NAME}" mkdir -p /u01/common/images >> "$LOG_FILE" 2>&1 || true
  "${RUNTIME_ENGINE}" cp "${COMMON_IMAGES}/." "${CONTAINER_NAME}:/u01/common/images/" >> "$LOG_FILE" 2>&1 || true
  echo -e "${GREEN}✅ Centralized corporate logos and images synchronized!${NC}" | tee -a "$LOG_FILE"
fi

echo "======================================================================" | tee -a "$LOG_FILE"
echo -e "${GREEN}🎉 Analytics Publisher reports deployment completed!${NC}" | tee -a "$LOG_FILE"
echo "======================================================================" | tee -a "$LOG_FILE"
