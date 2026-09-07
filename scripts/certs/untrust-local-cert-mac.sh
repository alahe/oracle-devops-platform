#!/usr/bin/env bash
# ============================================================================
# Oracle DevOps Platform - macOS User Certificate Remover
# Removes local Dev Root CA from current macOS user keychain.
# ============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

CYAN='\033[1;36m'
GREEN='\033[1;32m'
NC='\033[0m'

echo -e "${CYAN}==================================================================${NC}"
echo -e "${CYAN}🍎 ORACLE DEVOPS PLATFORM - CERTIFICATE REMOVAL (macOS)${NC}"
echo -e "${CYAN}==================================================================${NC}"

USER_KEYCHAIN="$HOME/Library/Keychains/login.keychain-db"
[ ! -f "$USER_KEYCHAIN" ] && USER_KEYCHAIN="$HOME/Library/Keychains/login.keychain"

security delete-certificate -c "Local Dev Root CA" "$USER_KEYCHAIN" 2>/dev/null || true

echo -e "${GREEN}✅ [SUCCESS] Certificate 'Local Dev Root CA' removed from user keychain.${NC}"
