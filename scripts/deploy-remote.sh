#!/usr/bin/env bash
# ==============================================================================
# Remote Cloud Deployment Script (OCI Always Free, Azure Free & Remote Linux)
# Automates SSH deployment of Oracle Free DB, APEX, ORDS & Analytics Publisher
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ -f "$SCRIPT_DIR/internal/common.sh" ]; then
  source "$SCRIPT_DIR/internal/common.sh"
else
  GREEN=$'\033[1;32m'
  RED=$'\033[1;31m'
  YELLOW=$'\033[0;33m'
  CYAN=$'\033[1;36m'
  NC=$'\033[0m'
fi

REMOTE_HOST="${REMOTE_HOST:-}"
REMOTE_USER="${REMOTE_USER:-opc}"
SSH_KEY_PATH="${REMOTE_SSH_KEY_PATH:-$HOME/.ssh/id_ed25519}"
PROFILE_NAME="${MAIN_DB_PROFILE:-publisher-only}"
BLUEPRINT_ID=""
WALLET_PATH=""
DRY_RUN=false

usage() {
  cat << EOF
Usage: ./scripts/deploy-remote.sh [options]

Options:
  --host <IP/FQDN>       Remote Linux server IP address or domain (required)
  --user <user>          SSH user (default: opc for OCI, ubuntu/azureuser for Azure)
  --key <key_path>       SSH private key location (default: ~/.ssh/id_ed25519)
  -b, --blueprint <id>   Deploy specific architectural blueprint (e.g. 10 for ORDS, 11 for Publisher)
  -w, --wallet <path>    Local OCI mTLS Cloud Wallet archive (e.g. config/tns_admin/Wallet_adbp.zip)
  -p, --profile <name>   Database/service profile (default: publisher-only)
  --dry-run              Validate parameters without connecting to remote server
  -h, --help             Show this help message
EOF
  exit 0
}

while [[ $# -gt 0 ]]; do
  case $1 in
    --host)
      REMOTE_HOST="$2"
      shift 2
      ;;
    --user)
      REMOTE_USER="$2"
      shift 2
      ;;
    --key)
      SSH_KEY_PATH="$2"
      shift 2
      ;;
    -b|--blueprint)
      BLUEPRINT_ID="$2"
      shift 2
      ;;
    -b=*|--blueprint=*)
      BLUEPRINT_ID="${1#*=}"
      shift
      ;;
    -w|--wallet)
      WALLET_PATH="$2"
      shift 2
      ;;
    -w=*|--wallet=*)
      WALLET_PATH="${1#*=}"
      shift
      ;;
    -p|--profile)
      PROFILE_NAME="$2"
      shift 2
      ;;
    -p=*|--profile=*)
      PROFILE_NAME="${1#*=}"
      shift
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo -e "${RED}Unknown parameter: $1${NC}"
      usage
      ;;
  esac
done

echo "======================================================================"
echo "☁️ Remote Cloud Deployment (OCI Always Free & Azure Free)"
echo "======================================================================"

if [ -z "$REMOTE_HOST" ] && [ "$DRY_RUN" = "false" ]; then
  echo -e "${YELLOW}ℹ️ Remote host IP not specified. Falling back to dry-run mode (--dry-run).${NC}"
  DRY_RUN=true
fi

echo -e "   └─ Target Host: ${CYAN}${REMOTE_HOST:-localhost (dry-run)}${NC}"
echo -e "   └─ Target User: ${CYAN}${REMOTE_USER}${NC}"
echo -e "   └─ SSH Key:     ${CYAN}${SSH_KEY_PATH}${NC}"
if [ -n "$BLUEPRINT_ID" ]; then
  echo -e "   └─ Blueprint:   ${CYAN}${BLUEPRINT_ID}${NC}"
else
  echo -e "   └─ Profile:     ${CYAN}${PROFILE_NAME}${NC}"
fi
if [ -n "$WALLET_PATH" ]; then
  echo -e "   └─ Cloud Wallet: ${CYAN}${WALLET_PATH}${NC}"
fi

if [ -n "$WALLET_PATH" ] && [ ! -f "$WALLET_PATH" ]; then
  echo -e "${RED}❌ Error: Specified wallet file not found: ${WALLET_PATH}${NC}"
  exit 1
fi

if [ "$DRY_RUN" = "true" ]; then
  echo "======================================================================"
  echo -e "${GREEN}✅ Dry-run validation passed! Script parameters are valid.${NC}"
  echo "======================================================================"
  exit 0
fi

SSH_CMD="ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} ${REMOTE_USER}@${REMOTE_HOST}"

echo -e "\n${CYAN}1. Verifying SSH connectivity to ${REMOTE_HOST}...${NC}"
if ! $SSH_CMD "echo 'SSH Connection OK'" >/dev/null 2>&1; then
  echo -e "${RED}❌ Error: Could not establish SSH connection to ${REMOTE_USER}@${REMOTE_HOST}!${NC}"
  echo "   Check SSH key path (${SSH_KEY_PATH}) and firewall rules (Port 22)."
  exit 1
fi
echo -e "${GREEN}✅ SSH connection verified!${NC}"

echo -e "\n${CYAN}2. Configuring remote server environment and dependencies...${NC}"
$SSH_CMD bash -s << 'REMOTE_INIT_EOF'
set -e
echo "Updating packages and installing required tools..."
if command -v dnf >/dev/null 2>&1; then
  sudo dnf -y install podman git curl unzip findutils || true
elif command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update -qq && sudo apt-get install -y -qq podman git curl unzip findutils || true
fi

# Open firewall ports if firewalld is active
if command -v firewall-cmd >/dev/null 2>&1 && systemctl is-active --quiet firewalld; then
  echo "Opening firewall ports 9502, 9503, 9500, 8088 and 8448..."
  sudo firewall-cmd --add-port=9502/tcp --permanent 2>/dev/null || true
  sudo firewall-cmd --add-port=9503/tcp --permanent 2>/dev/null || true
  sudo firewall-cmd --add-port=9500/tcp --permanent 2>/dev/null || true
  sudo firewall-cmd --add-port=8088/tcp --permanent 2>/dev/null || true
  sudo firewall-cmd --add-port=8448/tcp --permanent 2>/dev/null || true
  sudo firewall-cmd --reload 2>/dev/null || true
fi
REMOTE_INIT_EOF

echo -e "\n${CYAN}3. Synchronizing project code to remote host...${NC}"
REMOTE_DIR="oracle-free-db-in-prod"
rsync -avz --exclude='.git' --exclude='install_logs' --exclude='backups' -e "ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH}" "$WORKSPACE_DIR/" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/" >/dev/null

if [ -n "$WALLET_PATH" ] && [ -f "$WALLET_PATH" ]; then
  echo -e "\n${CYAN}3.1. Uploading OCI Cloud Wallet (${WALLET_PATH}) to remote host...${NC}"
  $SSH_CMD "mkdir -p ${REMOTE_DIR}/config/tns_admin"
  scp -o StrictHostKeyChecking=no -i "${SSH_KEY_PATH}" "${WALLET_PATH}" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/config/tns_admin/"
  $SSH_CMD "unzip -o -q ${REMOTE_DIR}/config/tns_admin/$(basename "${WALLET_PATH}") -d ${REMOTE_DIR}/config/tns_admin/ 2>/dev/null || true"
  echo -e "${GREEN}✅ OCI Cloud Wallet uploaded and unpacked in remote config/tns_admin!${NC}"
fi

echo -e "\n${CYAN}4. Launching automated remote installation (setup-all.sh)...${NC}"
if [ -n "$BLUEPRINT_ID" ]; then
  $SSH_CMD "cd ${REMOTE_DIR} && ./scripts/setup-all.sh -b ${BLUEPRINT_ID} -y"
else
  $SSH_CMD "cd ${REMOTE_DIR} && MAIN_DB_PROFILE=${PROFILE_NAME} ./scripts/setup-all.sh -y"
fi

echo "======================================================================"
echo -e "${GREEN}🎉 Remote deployment to ${REMOTE_HOST} completed successfully!${NC}"
echo -e "   🔗 Developer Hub:          ${CYAN}https://${REMOTE_HOST}:8448/dev-hub.html${NC}"
echo -e "   🔗 ORDS Root Endpoint:      ${CYAN}https://${REMOTE_HOST}:8448/ords/${NC}"
echo -e "   🔗 Analytics Publisher UI: ${CYAN}http://${REMOTE_HOST}:9502/xmlpserver${NC}"
echo -e "   🔗 WebLogic Remote REST:   ${CYAN}http://${REMOTE_HOST}:9500/console/welcome${NC}"
echo "======================================================================"
