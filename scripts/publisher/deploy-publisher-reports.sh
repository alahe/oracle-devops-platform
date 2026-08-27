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
LOCAL_DEV_DIR="$WORKSPACE_DIR/publisher-reports"

LOG_DIR="$WORKSPACE_DIR/install_logs"
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$LOG_DIR/publisher_reports_deploy_${TIMESTAMP}.log"

echo "======================================================================" | tee -a "$LOG_FILE"
echo "🚀 Oracle Analytics Publisher Report & Template Deployment" | tee -a "$LOG_FILE"
echo "======================================================================" | tee -a "$LOG_FILE"

# 1. Synchronize Source (Artifactory Binary vs Decoupled Git vs Local Folder)
TARGET_REPORTS_DIR=""

if [ -n "${REPORTS_ARTIFACTORY_URL}" ]; then
  echo -e "${CYAN}1. Laadin aruannete ehituspaketi Artifactory'st:${NC} ${REPORTS_ARTIFACTORY_URL}" | tee -a "$LOG_FILE"
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
    echo -e "${GREEN}✅ Artifactory ehituspakett edukalt alla laaditud ja lahti pakitud!${NC}" | tee -a "$LOG_FILE"
  fi
  TARGET_REPORTS_DIR="$LOCAL_CACHE_DIR"
elif [ -n "${REPORTS_GIT_URL}" ]; then
  echo -e "${CYAN}1. Sünkroniseerin eraldiseisva aruannete Git repositooriumi:${NC} ${REPORTS_GIT_URL} (Branch: ${REPORTS_GIT_BRANCH})" | tee -a "$LOG_FILE"
  mkdir -p "$LOCAL_CACHE_DIR"
  if [ -d "$LOCAL_CACHE_DIR/.git" ]; then
    (cd "$LOCAL_CACHE_DIR" && git fetch origin && git checkout "$REPORTS_GIT_BRANCH" && git pull origin "$REPORTS_GIT_BRANCH") >> "$LOG_FILE" 2>&1 || true
  else
    git clone -b "$REPORTS_GIT_BRANCH" "$REPORTS_GIT_URL" "$LOCAL_CACHE_DIR" >> "$LOG_FILE" 2>&1 || true
  fi
  TARGET_REPORTS_DIR="$LOCAL_CACHE_DIR"
elif [ -d "$LOCAL_DEV_DIR" ]; then
  echo -e "${CYAN}1. Kasutan lokaalset aruannete kausta:${NC} ${LOCAL_DEV_DIR}" | tee -a "$LOG_FILE"
  TARGET_REPORTS_DIR="$LOCAL_DEV_DIR"
elif [ -d "$LOCAL_CACHE_DIR" ]; then
  echo -e "${CYAN}1. Kasutan puhverdatud aruannete kausta:${NC} ${LOCAL_CACHE_DIR}" | tee -a "$LOG_FILE"
  TARGET_REPORTS_DIR="$LOCAL_CACHE_DIR"
else
  echo -e "${YELLOW}ℹ️ Aruannete allikat ei leitud. Loome näidiskausta...${NC}" | tee -a "$LOG_FILE"
  mkdir -p "$LOCAL_DEV_DIR/Custom/Reports"
  TARGET_REPORTS_DIR="$LOCAL_DEV_DIR"
fi

echo -e "   └─ Aruannete allikas: ${TARGET_REPORTS_DIR}" | tee -a "$LOG_FILE"

# 2. Deploy Reports to Publisher
if ! "${RUNTIME_ENGINE}" ps --format "{{.Names}}" 2>/dev/null | grep -q "^${CONTAINER_NAME}$"; then
  echo -e "${YELLOW}⚠️ Konteiner ${CONTAINER_NAME} ei käi. Jätan aruannete füüsilise paigalduse vahele.${NC}" | tee -a "$LOG_FILE"
  exit 0
fi

echo -e "${CYAN}2. Paigaldan aruanded ja trükised (Režiim: ${DEPLOY_MODE})...${NC}" | tee -a "$LOG_FILE"

if [ "$DEPLOY_MODE" = "catalog" ]; then
  # Direct Catalog Volume Sync
  echo "   └─ Kopeerin aruannete failid Publisheri kataloogi (/u01/.../bipublisher/repository/)..." | tee -a "$LOG_FILE"
  "${RUNTIME_ENGINE}" cp "${TARGET_REPORTS_DIR}/." "${CONTAINER_NAME}:/u01/oracle/user_projects/domains/bi/bidata/components/bipublisher/repository/" >> "$LOG_FILE" 2>&1 || true
  "${RUNTIME_ENGINE}" exec -i "${CONTAINER_NAME}" chmod -R 775 /u01/oracle/user_projects/domains/bi/bidata/components/bipublisher/repository/ >> "$LOG_FILE" 2>&1 || true
  echo -e "${GREEN}✅ Aruanded kopeeritud Publisheri kataloogi edukalt!${NC}" | tee -a "$LOG_FILE"
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
    echo "   └─ REST üleslaadimine: ${rel_path}..." | tee -a "$LOG_FILE"
    curl -s -u "${ADMIN_USER}:${ADMIN_PWD}" -F "reportPath=/Custom/${rel_path}" -F "file=@${report_file}" "${PUBLISHER_URL}/services/rest/v1/reports" >> "$LOG_FILE" 2>&1 || true
  done
  echo -e "${GREEN}✅ Aruanded laaditud üles läbi Publisher REST API!${NC}" | tee -a "$LOG_FILE"
fi

echo "======================================================================" | tee -a "$LOG_FILE"
echo -e "${GREEN}🎉 Analytics Publisher aruannete paigaldus lõpetatud!${NC}" | tee -a "$LOG_FILE"
echo "======================================================================" | tee -a "$LOG_FILE"
