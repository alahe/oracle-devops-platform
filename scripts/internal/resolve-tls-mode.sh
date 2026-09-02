#!/usr/bin/env bash
# ============================================================================
# Engine Script: Adaptive TLS/HTTPS Resolution & Policy Enforcement
# Purpose: Resolves the active TLS certificate source hierarchically:
#          0. Custom pre-placed certs (config/certs/custom/)
#          1. Public Domain & CA (Let's Encrypt / Public CA)
#          2. Corporate PKI / Enterprise CA
#          3. User-Space Local Dev CA (0 root/admin rights)
# Enforces Blueprint policy levels (strict_public | corporate_pki | permissive)
# ============================================================================

set -e

_LOCAL_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$_LOCAL_SCRIPT_DIR/../.." && pwd)"

# Color definitions
CYAN=$'\033[1;36m'
GREEN=$'\033[1;32m'
RED=$'\033[1;31m'
YELLOW=$'\033[0;33m'
BOLD=$'\033[1m'
NC=$'\033[0m'

# Source common helpers if present
if [ -f "$_LOCAL_SCRIPT_DIR/common.sh" ]; then
  source "$_LOCAL_SCRIPT_DIR/common.sh"
fi

resolve_tls_mode() {
  local target_policy="${TLS_ALLOWED_LEVEL:-permissive}"
  local custom_dir="$WORKSPACE_DIR/config/certs/custom"
  local certs_dir="$WORKSPACE_DIR/config/certs"
  
  # Defaults
  RESOLVED_TLS_MODE="UNKNOWN"
  RESOLVED_SSL_CERT=""
  RESOLVED_SSL_KEY=""
  RESOLVED_SSL_CA=""
  RESOLVED_TLS_REASON=""
  RESOLVED_TLS_DOMAIN="${APP_DOMAIN:-localhost}"

  # --------------------------------------------------------------------------
  # STEP 0: Check for Custom Pre-Placed Certificates (config/certs/custom/)
  # --------------------------------------------------------------------------
  local custom_crt=""
  local custom_key=""
  
  if [ -d "$custom_dir" ]; then
    for f in "$custom_dir"/*.crt "$custom_dir"/*.pem; do
      if [ -f "$f" ] && [[ "$f" != *"key"* ]] && [[ "$f" != *"priv"* ]]; then
        custom_crt="$f"
        break
      fi
    done
    for f in "$custom_dir"/*.key "$custom_dir"/*-key.pem "$custom_dir"/privkey.pem; do
      if [ -f "$f" ]; then
        custom_key="$f"
        break
      fi
    done
  fi

  # Explicit environment overrides take highest precedence in Step 0
  if [ -n "${CUSTOM_SSL_CERT_PATH:-}" ] && [ -f "$WORKSPACE_DIR/$CUSTOM_SSL_CERT_PATH" ]; then
    custom_crt="$WORKSPACE_DIR/$CUSTOM_SSL_CERT_PATH"
  elif [ -n "${CUSTOM_SSL_CERT_PATH:-}" ] && [ -f "$CUSTOM_SSL_CERT_PATH" ]; then
    custom_crt="$CUSTOM_SSL_CERT_PATH"
  fi

  if [ -n "${CUSTOM_SSL_KEY_PATH:-}" ] && [ -f "$WORKSPACE_DIR/$CUSTOM_SSL_KEY_PATH" ]; then
    custom_key="$WORKSPACE_DIR/$CUSTOM_SSL_KEY_PATH"
  elif [ -n "${CUSTOM_SSL_KEY_PATH:-}" ] && [ -f "$CUSTOM_SSL_KEY_PATH" ]; then
    custom_key="$CUSTOM_SSL_KEY_PATH"
  fi

  if [ -n "$custom_crt" ] && [ -n "$custom_key" ]; then
    RESOLVED_TLS_MODE="CUSTOM_CERT"
    RESOLVED_SSL_CERT="$custom_crt"
    RESOLVED_SSL_KEY="$custom_key"
    RESOLVED_TLS_REASON="Detected custom certificate in config/certs/custom/"
    [ -f "$custom_dir/ca.crt" ] && RESOLVED_SSL_CA="$custom_dir/ca.crt"
    [ -f "$custom_dir/chain.pem" ] && RESOLVED_SSL_CA="$custom_dir/chain.pem"
  fi

  # --------------------------------------------------------------------------
  # STEP 1: Check for Public Domain & Public CA (Variant 1)
  # --------------------------------------------------------------------------
  if [ "$RESOLVED_TLS_MODE" = "UNKNOWN" ] && [ "${USE_PUBLIC_CA_CERTS:-false}" = "true" ]; then
    if [ -f "$certs_dir/public_cert.crt" ] && [ -f "$certs_dir/public_key.key" ]; then
      RESOLVED_TLS_MODE="PUBLIC_CA"
      RESOLVED_SSL_CERT="$certs_dir/public_cert.crt"
      RESOLVED_SSL_KEY="$certs_dir/public_key.key"
      RESOLVED_TLS_REASON="Detected production Public CA certificates"
      [ -f "$certs_dir/ca.crt" ] && RESOLVED_SSL_CA="$certs_dir/ca.crt"
    fi
  fi

  # --------------------------------------------------------------------------
  # STEP 2: Check for Enterprise Internal CA (Variant 2)
  # --------------------------------------------------------------------------
  if [ "$RESOLVED_TLS_MODE" = "UNKNOWN" ] && [ "${USE_CORP_INTERNAL_CA:-false}" = "true" ]; then
    if [ -f "$certs_dir/corp_internal_ca.crt" ] && [ -f "$certs_dir/corp_internal_key.key" ]; then
      RESOLVED_TLS_MODE="CORP_INTERNAL_CA"
      RESOLVED_SSL_CERT="$certs_dir/corp_internal_ca.crt"
      RESOLVED_SSL_KEY="$certs_dir/corp_internal_key.key"
      RESOLVED_TLS_REASON="Detected Enterprise Internal PKI certificates"
      [ -f "$certs_dir/corp_root_ca.crt" ] && RESOLVED_SSL_CA="$certs_dir/corp_root_ca.crt"
    fi
  fi

  # --------------------------------------------------------------------------
  # STEP 3: Check for User CA / Local Dev CA (Variant 3)
  # --------------------------------------------------------------------------
  if [ "$RESOLVED_TLS_MODE" = "UNKNOWN" ]; then
    if [ -f "$certs_dir/user_ca/localhost.crt" ] && [ -f "$certs_dir/user_ca/localhost.key" ]; then
      RESOLVED_TLS_MODE="USER_CA"
      RESOLVED_SSL_CERT="$certs_dir/user_ca/localhost.crt"
      RESOLVED_SSL_KEY="$certs_dir/user_ca/localhost.key"
      RESOLVED_TLS_REASON="Detected User / Local Dev Root CA certificates"
      [ -f "$certs_dir/user_ca/localCA.pem" ] && RESOLVED_SSL_CA="$certs_dir/user_ca/localCA.pem"
    elif [ -f "$certs_dir/localhost.crt" ] && [ -f "$certs_dir/localhost.key" ]; then
      RESOLVED_TLS_MODE="USER_CA"
      RESOLVED_SSL_CERT="$certs_dir/localhost.crt"
      RESOLVED_SSL_KEY="$certs_dir/localhost.key"
      RESOLVED_TLS_REASON="Detected local dev CA certificates"
      [ -f "$certs_dir/localCA.pem" ] && RESOLVED_SSL_CA="$certs_dir/localCA.pem"
    fi
  fi

  # --------------------------------------------------------------------------
  # STEP 4: Fallback to Self-Signed Cert (Variant 4)
  # --------------------------------------------------------------------------
  if [ "$RESOLVED_TLS_MODE" = "UNKNOWN" ]; then
    if [ -f "$certs_dir/self_signed/self_signed.crt" ] && [ -f "$certs_dir/self_signed/self_signed.key" ]; then
      RESOLVED_TLS_MODE="SELF_SIGNED"
      RESOLVED_SSL_CERT="$certs_dir/self_signed/self_signed.crt"
      RESOLVED_SSL_KEY="$certs_dir/self_signed/self_signed.key"
      RESOLVED_TLS_REASON="Detected self-signed fallback certificates"
    fi
  fi

  # --------------------------------------------------------------------------
  # STEP 5: Policy Level Verification vs Target Blueprint
  # --------------------------------------------------------------------------
  local target_policy="${TLS_POLICY_LEVEL:-standard}"
  local policy_violation=false

  case "$target_policy" in
    strict_prod)
      if [ "$RESOLVED_TLS_MODE" != "PUBLIC_CA" ] && [ "$RESOLVED_TLS_MODE" != "CUSTOM_CERT" ]; then
        policy_violation=true
      fi
      ;;
    corp_enforced)
      if [ "$RESOLVED_TLS_MODE" = "SELF_SIGNED" ] || [ "$RESOLVED_TLS_MODE" = "UNKNOWN" ]; then
        policy_violation=true
      fi
      ;;
    standard|permissive|*)
      policy_violation=false
      ;;
  esac

  if [ "$policy_violation" = "true" ]; then
    echo ""
    echo -e "${RED}╔══════════════════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║ ❌ TLS POLICY ERROR: Blueprint requires higher TLS level than current environment provides!    ║${NC}"
    echo -e "${RED}╠══════════════════════════════════════════════════════════════════════════════════════════════╣${NC}"
    printf "║ • Required level:  %-73s ║\n" "${CYAN}${target_policy}${NC}"
    printf "║ • Detected level:  %-73s ║\n" "${YELLOW}${RESOLVED_TLS_MODE} (${RESOLVED_TLS_REASON})${NC}"
    echo -e "${RED}║                                                                                              ║${NC}"
    echo -e "${RED}║ 🛠 USER RESOLUTION OPTIONS:                                                                 ║${NC}"
    echo -e "${RED}║                                                                                              ║${NC}"
    echo -e "${RED}║ 1. [FASTEST] Copy valid certificate and private key to:                                      ║${NC}"
    echo -e "${RED}║    📁 config/certs/custom/tls.crt                                                            ║${NC}"
    echo -e "${RED}║    📁 config/certs/custom/tls.key                                                            ║${NC}"
    echo -e "${RED}║                                                                                              ║${NC}"
    echo -e "${RED}║ 2. [CORP NETWORK] Connect to VPN and pull internal PKI cert:                                 ║${NC}"
    echo -e "${RED}║    👉 ./scripts/certs/sync-corp-cert.sh                                                      ║${NC}"
    echo -e "${RED}║                                                                                              ║${NC}"
    echo -e "${RED}║ 3. [LOCAL DEV] If developing on personal workstation, add to .env:                           ║${NC}"
    echo -e "${RED}║    👉 TLS_ALLOWED_LEVEL=permissive                                                           ║${NC}"
    echo -e "${RED}╚══════════════════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    return 1
  fi

  # Export resolved variables for current process and child subshells
  export RESOLVED_TLS_MODE
  export RESOLVED_SSL_CERT
  export RESOLVED_SSL_KEY
  export RESOLVED_SSL_CA
  export RESOLVED_TLS_REASON
  export RESOLVED_TLS_DOMAIN

  return 0
}

# If executed directly as CLI script, run and print summary
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  if resolve_tls_mode; then
    echo -e "${CYAN}==================================================================${NC}"
    echo -e "${GREEN}🔒 TLS RESOLUTION SUMMARY & ACTIVE MODE${NC}"
    echo -e "${CYAN}==================================================================${NC}"
    echo -e "   ├─ 🛡️ Mode:          ${GREEN}${RESOLVED_TLS_MODE}${NC}"
    echo -e "   ├─ ℹ️ Reason:        ${CYAN}${RESOLVED_TLS_REASON}${NC}"
    echo -e "   ├─ 📜 Certificate:   ${YELLOW}${RESOLVED_SSL_CERT}${NC}"
    echo -e "   ├─ 🔑 Private key:   ${YELLOW}${RESOLVED_SSL_KEY}${NC}"
    [ -n "$RESOLVED_SSL_CA" ] && echo -e "   ├─ 🏛️ CA Chain:      ${YELLOW}${RESOLVED_SSL_CA}${NC}"
    echo -e "   └─ 🌐 Domain:        ${CYAN}${RESOLVED_TLS_DOMAIN}${NC}"
    echo -e "${CYAN}==================================================================${NC}"
  else
    exit 1
  fi
fi
