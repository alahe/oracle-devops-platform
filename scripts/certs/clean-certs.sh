#!/usr/bin/env bash
# ============================================================================
# Oracle DevOps Platform - Certificate & Trust Store Cleaner
# Purpose: Purges generated dev certificates from OS Keychain and disk storage.
# Usage: ./scripts/certs/clean-certs.sh [--all|--keychain-only|--files-only] [--regenerate] [-y|--force]
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source shared helpers and i18n if available
if [ -f "$WORKSPACE_DIR/scripts/internal/common.sh" ]; then
  source "$WORKSPACE_DIR/scripts/internal/common.sh"
else
  CYAN='\033[1;36m'
  GREEN='\033[1;32m'
  YELLOW='\033[0;33m'
  RED='\033[1;31m'
  NC='\033[0m'
fi

MODE="all"
REGENERATE=false
FORCE=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --all)
      MODE="all"
      shift
      ;;
    --keychain-only|--trust-only)
      MODE="keychain"
      shift
      ;;
    --files-only|--disk-only)
      MODE="files"
      shift
      ;;
    --regenerate|-r)
      REGENERATE=true
      shift
      ;;
    -y|--force|--non-interactive)
      FORCE=true
      shift
      ;;
    -l=*|--lang=*|-language=*|--language=*)
      export CLI_LANG="${1#*=}"
      shift
      ;;
    -l|--lang|-language|--language)
      export CLI_LANG="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 [--all|--keychain-only|--files-only] [--regenerate] [-y|--force]"
      echo "  --all            Purge both keychain and disk certificate files (default)"
      echo "  --keychain-only  Remove certificates only from OS Keychain / Trust Store"
      echo "  --files-only     Delete certificates and wallets only from disk (config/certs/, config/wallet-*/)"
      echo "  --regenerate, -r Immediately regenerate fresh certificates and add to trust store"
      echo "  -y, --force      Confirm operation automatically (non-interactive mode)"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [--all|--keychain-only|--files-only] [--regenerate] [-y|--force]"
      exit 1
      ;;
  esac
done

echo -e "${CYAN}==================================================================${NC}"
echo -e "${CYAN}🧹 ORACLE DEVOPS PLATFORM - CERTIFICATE CLEANUP UTILITY${NC}"
echo -e "${CYAN}==================================================================${NC}"
echo -e "   Cleanup Mode: ${YELLOW}${MODE}${NC}"
[ "$REGENERATE" = "true" ] && echo -e "   Regenerate: ${GREEN}YES${NC}"
echo -e "${CYAN}==================================================================${NC}"

if [ "$FORCE" = "false" ] && [ -t 0 ]; then
  echo -ne "${YELLOW}⚠️  Are you sure you want to remove local development certificates? (y/N): ${NC}"
  read -r reply
  if [[ ! "$reply" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}ℹ️  Cleanup cancelled by user.${NC}"
    exit 0
  fi
fi

# ----------------------------------------------------------------------------
# 1. OS Keychain & Trust Store Cleanup
# ----------------------------------------------------------------------------
if [ "$MODE" = "all" ] || [ "$MODE" = "keychain" ]; then
  echo -e "\n${CYAN}1. Removing certificates from OS Trust Store...${NC}"

  if [[ "$OSTYPE" == "darwin"* ]]; then
    USER_KEYCHAIN="$HOME/Library/Keychains/login.keychain-db"
    [ ! -f "$USER_KEYCHAIN" ] && USER_KEYCHAIN="$HOME/Library/Keychains/login.keychain"

    # User Keychain removal
    REMOVED_USER=false
    if security find-certificate -c "Local Dev Root CA" "$USER_KEYCHAIN" &>/dev/null; then
      security delete-certificate -c "Local Dev Root CA" "$USER_KEYCHAIN" 2>/dev/null || true
      REMOVED_USER=true
    fi
    if security find-certificate -c "localhost" "$USER_KEYCHAIN" &>/dev/null; then
      security delete-certificate -c "localhost" "$USER_KEYCHAIN" 2>/dev/null || true
      REMOVED_USER=true
    fi

    if [ "$REMOVED_USER" = "true" ]; then
      echo -e "   ${GREEN}✅ 'Local Dev Root CA' removed from macOS user keychain (${USER_KEYCHAIN}).${NC}"
    else
      echo -e "   ${YELLOW}ℹ️  'Local Dev Root CA' was not found in macOS user keychain.${NC}"
    fi

    # System Keychain removal check
    if security find-certificate -c "Local Dev Root CA" /Library/Keychains/System.keychain &>/dev/null; then
      if sudo -n true 2>/dev/null; then
        sudo security delete-certificate -c "Local Dev Root CA" /Library/Keychains/System.keychain 2>/dev/null || true
        echo -e "   ${GREEN}✅ 'Local Dev Root CA' removed from macOS System.keychain store.${NC}"
      else
        echo -e "   ${YELLOW}ℹ️  'Local Dev Root CA' is also present in /Library/Keychains/System.keychain.${NC}"
        echo -e "      To remove it, run if needed: ${CYAN}sudo security delete-certificate -c \"Local Dev Root CA\" /Library/Keychains/System.keychain${NC}"
      fi
    fi

  elif [[ "$OSTYPE" == "msys"* ]] || [[ "$OSTYPE" == "cygwin"* ]] || [[ "${OS:-}" == "Windows_NT" ]]; then
    if command -v certutil.exe &>/dev/null; then
      certutil.exe -delstore -user Root "Local Dev Root CA" >/dev/null 2>&1 || true
      echo -e "   ${GREEN}✅ 'Local Dev Root CA' removed from Windows User Root store.${NC}"
    elif command -v certutil &>/dev/null; then
      certutil -delstore -user Root "Local Dev Root CA" >/dev/null 2>&1 || true
      echo -e "   ${GREEN}✅ 'Local Dev Root CA' removed from Windows User Root store.${NC}"
    fi
  elif grep -qEi 'Microsoft|Subsystem' /proc/version 2>/dev/null; then
    if command -v certutil.exe &>/dev/null; then
      certutil.exe -delstore -user Root "Local Dev Root CA" >/dev/null 2>&1 || true
      echo -e "   ${GREEN}✅ 'Local Dev Root CA' removed from Windows store via WSL.${NC}"
    fi
  else
    echo -e "   ${YELLOW}ℹ️  On Linux, verify SSL_CERT_FILE environment variable.${NC}"
  fi
fi

# ----------------------------------------------------------------------------
# 2. Disk Files Cleanup
# ----------------------------------------------------------------------------
if [ "$MODE" = "all" ] || [ "$MODE" = "files" ]; then
  echo -e "\n${CYAN}2. Deleting generated certificate files from disk...${NC}"

  # config/certs/ root files
  rm -f "$WORKSPACE_DIR/config/certs/localCA.key" \
        "$WORKSPACE_DIR/config/certs/localCA.pem" \
        "$WORKSPACE_DIR/config/certs/localCA.srl" \
        "$WORKSPACE_DIR/config/certs/localhost.crt" \
        "$WORKSPACE_DIR/config/certs/localhost.key" \
        "$WORKSPACE_DIR/config/certs/localhost.der" \
        "$WORKSPACE_DIR/config/certs/localhost.csr" \
        "$WORKSPACE_DIR/config/certs/localhost.ext" \
        "$WORKSPACE_DIR/config/certs/localhost-fullchain.crt"

  # user_ca/
  find "$WORKSPACE_DIR/config/certs/user_ca" -type f ! -name ".gitkeep" ! -name "README.md" -delete 2>/dev/null || true

  # self_signed/
  find "$WORKSPACE_DIR/config/certs/self_signed" -type f ! -name ".gitkeep" ! -name "README.md" -delete 2>/dev/null || true

  # Oracle DB Wallets
  rm -f "$WORKSPACE_DIR/config/wallet-apex-proxy/ewallet.p12" \
        "$WORKSPACE_DIR/config/wallet-apex-proxy/cwallet.sso" \
        "$WORKSPACE_DIR/config/wallet-publisher/ewallet.p12" \
        "$WORKSPACE_DIR/config/wallet-publisher/cwallet.sso"

  # ORDS SSL caches
  find "$WORKSPACE_DIR/config/ords" -path "*/ssl/*" -type f ! -name ".gitkeep" -delete 2>/dev/null || true

  echo -e "   ${GREEN}✅ Generated certificates and wallets removed from disk successfully.${NC}"
fi

# ----------------------------------------------------------------------------
# 3. Optional Immediate Regeneration
# ----------------------------------------------------------------------------
if [ "$REGENERATE" = "true" ]; then
  echo -e "\n${CYAN}3. Generating fresh certificates and adding to trust store...${NC}"
  if [ -x "$WORKSPACE_DIR/scripts/internal/generate-local-certs.sh" ]; then
    "$WORKSPACE_DIR/scripts/internal/generate-local-certs.sh" --no-prompt
  fi
  if [[ "$OSTYPE" == "darwin"* ]] && [ -x "$WORKSPACE_DIR/scripts/certs/trust-local-cert-mac.sh" ]; then
    "$WORKSPACE_DIR/scripts/certs/trust-local-cert-mac.sh"
  elif [[ "$OSTYPE" == "msys"* ]] || [[ "$OSTYPE" == "cygwin"* ]] || [[ "${OS:-}" == "Windows_NT" ]]; then
    if [ -f "$WORKSPACE_DIR/scripts/certs/trust-local-cert.cmd" ]; then
      cmd.exe /c "$WORKSPACE_DIR/scripts/certs/trust-local-cert.cmd"
    fi
  fi
  echo -e "   ${GREEN}✅ Fresh certificates generated and trusted!${NC}"
fi

echo -e "\n${GREEN}==================================================================${NC}"
echo -e "${GREEN}🎉 CERTIFICATE CLEANUP COMPLETED SUCCESSFULLY!${NC}"
echo -e "${GREEN}==================================================================${NC}"
