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
DRY_RUN=false

usage() {
  cat << EOF
Kasutus: ./scripts/deploy-remote.sh [valikud]

Valikud:
  --host <IP/FQDN>     Kaug-Linux serveri IP-aadress või domeeninimi (kohustuslik)
  --user <kasutaja>    SSH kasutaja (vaikimisi: opc OCI puhul, ubuntu/azureuser Azure puhul)
  --key <tee_võtmeni>  SSH privaatvõtme asukoht (vaikimisi: ~/.ssh/id_ed25519)
  --profile <profiil>  Andmebaasi/teenuse profiil (vaikimisi: publisher-only)
  --dry-run            Kontrollib parameetreid ilma kaug-serverisse ühendamata
  -h, --help           Kuva see abiteave
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
    --profile)
      PROFILE_NAME="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo -e "${RED}Tundmatu parameeter: $1${NC}"
      usage
      ;;
  esac
done

echo "======================================================================"
echo "☁️ Remote Cloud Deployment (OCI Always Free & Azure Free)"
echo "======================================================================"

if [ -z "$REMOTE_HOST" ] && [ "$DRY_RUN" = "false" ]; then
  echo -e "${YELLOW}ℹ️ Kaug-hosti IP-d ei täpsustatud käsureal. Kasutan simuleeritud režiimi (--dry-run).${NC}"
  DRY_RUN=true
fi

echo -e "   └─ Target Host: ${CYAN}${REMOTE_HOST:-localhost (dry-run)}${NC}"
echo -e "   └─ Target User: ${CYAN}${REMOTE_USER}${NC}"
echo -e "   └─ SSH Key:     ${CYAN}${SSH_KEY_PATH}${NC}"
echo -e "   └─ Profile:     ${CYAN}${PROFILE_NAME}${NC}"

if [ "$DRY_RUN" = "true" ]; then
  echo "======================================================================"
  echo -e "${GREEN}✅ Dry-run kontroll edukalt läbitud! Skripti parameetrid on korras.${NC}"
  echo "======================================================================"
  exit 0
fi

SSH_CMD="ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} ${REMOTE_USER}@${REMOTE_HOST}"

echo -e "\n${CYAN}1. Kontrollin SSH ühendust serveriga ${REMOTE_HOST}...${NC}"
if ! $SSH_CMD "echo 'SSH Connection OK'" >/dev/null 2>&1; then
  echo -e "${RED}❌ Viga: Ei suutnud luua SSH ühendust serveriga ${REMOTE_USER}@${REMOTE_HOST}!${NC}"
  echo "   Kontrolli SSH võtme teed (${SSH_KEY_PATH}) ja pilve tulemüüri reegleid (Port 22)."
  exit 1
fi
echo -e "${GREEN}✅ SSH ühendus toimib!${NC}"

echo -e "\n${CYAN}2. Seadistan kaug-serveri keskkonna ja paigaldan vajadusel Podmani/Dockerit...${NC}"
$SSH_CMD bash -s << 'REMOTE_INIT_EOF'
set -e
echo "Pakettide uuendamine ja vajalike tööriistade paigaldus..."
if command -v dnf >/dev/null 2>&1; then
  sudo dnf -y install podman git curl unzip findutils || true
elif command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update -qq && sudo apt-get install -y -qq podman git curl unzip findutils || true
fi

# Tulemüüri portide avamine kui firewalld on aktiivne
if command -v firewall-cmd >/dev/null 2>&1 && systemctl is-active --quiet firewalld; then
  echo "Avame Linux tulemüüris pordid 9502, 9500 ja 8088..."
  sudo firewall-cmd --add-port=9502/tcp --permanent 2>/dev/null || true
  sudo firewall-cmd --add-port=9500/tcp --permanent 2>/dev/null || true
  sudo firewall-cmd --add-port=8088/tcp --permanent 2>/dev/null || true
  sudo firewall-cmd --reload 2>/dev/null || true
fi
REMOTE_INIT_EOF

echo -e "\n${CYAN}3. Sünkroniseerin projekti koodi kaug-serverisse...${NC}"
REMOTE_DIR="oracle-free-db-in-prod"
rsync -avz --exclude='.git' --exclude='install_logs' --exclude='backups' -e "ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH}" "$WORKSPACE_DIR/" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/" >/dev/null

echo -e "\n${CYAN}4. Käivitan kaug-serveris automaatse paigalduse (setup-all.sh)...${NC}"
$SSH_CMD "cd ${REMOTE_DIR} && MAIN_DB_PROFILE=${PROFILE_NAME} ./scripts/setup-all.sh -y"

echo "======================================================================"
echo -e "${GREEN}🎉 Kaugpaigaldus serverisse ${REMOTE_HOST} lõpetatud edukalt!${NC}"
echo -e "   🔗 Analytics Publisher UI: ${CYAN}http://${REMOTE_HOST}:9502/xmlpserver${NC}"
echo -e "   🔗 WebLogic Remote REST:   ${CYAN}http://${REMOTE_HOST}:9500/console/welcome${NC}"
echo "======================================================================"
