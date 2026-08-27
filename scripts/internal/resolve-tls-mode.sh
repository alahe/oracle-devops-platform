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
    RESOLVED_TLS_REASON="Tuvastati käsitsi lisatud sertifikaat kaustas config/certs/custom/"
    [ -f "$custom_dir/ca.crt" ] && RESOLVED_SSL_CA="$custom_dir/ca.crt"
    [ -f "$custom_dir/chain.pem" ] && RESOLVED_SSL_CA="$custom_dir/chain.pem"
  fi

  # --------------------------------------------------------------------------
  # STEP 1: Check for Public Domain & Public CA (Variant 1)
  # --------------------------------------------------------------------------
  if [ "$RESOLVED_TLS_MODE" = "UNKNOWN" ] && [ "${USE_PUBLIC_CA_CERTS:-false}" = "true" ]; then
    if [ -f "$certs_dir/public_cert.crt" ] && [ -f "$certs_dir/public_key.key" ]; then
      RESOLVED_TLS_MODE="PUBLIC_DNS"
      RESOLVED_SSL_CERT="$certs_dir/public_cert.crt"
      RESOLVED_SSL_KEY="$certs_dir/public_key.key"
      RESOLVED_TLS_REASON="Avalik FQDN ja Let's Encrypt / Avaliku CA sertifikaat"
    fi
  fi

  # --------------------------------------------------------------------------
  # STEP 2: Check for Corporate PKI / Enterprise CA (Variant 2)
  # --------------------------------------------------------------------------
  if [ "$RESOLVED_TLS_MODE" = "UNKNOWN" ] && { [ "${CORP_PKI_ENABLED:-false}" = "true" ] || [ -f "$certs_dir/corp/corp_cert.crt" ]; }; then
    if [ -f "$certs_dir/corp/corp_cert.crt" ] && [ -f "$certs_dir/corp/corp_key.key" ]; then
      RESOLVED_TLS_MODE="CORP_PKI"
      RESOLVED_SSL_CERT="$certs_dir/corp/corp_cert.crt"
      RESOLVED_SSL_KEY="$certs_dir/corp/corp_key.key"
      RESOLVED_SSL_CA="$certs_dir/corp/corp_ca.crt"
      RESOLVED_TLS_REASON="Ettevõtte Sise-PKI (Corporate Root CA)"
    fi
  fi

  # --------------------------------------------------------------------------
  # STEP 3: Check for User-Space Local Dev CA (Variant 3)
  # --------------------------------------------------------------------------
  if [ "$RESOLVED_TLS_MODE" = "UNKNOWN" ]; then
    if [ -f "$certs_dir/user_ca/localhost.crt" ] && [ -f "$certs_dir/user_ca/localhost.key" ] && [ -f "$certs_dir/user_ca/localCA.pem" ]; then
      RESOLVED_TLS_MODE="USER_LOCAL_CA"
      RESOLVED_SSL_CERT="$certs_dir/user_ca/localhost.crt"
      RESOLVED_SSL_KEY="$certs_dir/user_ca/localhost.key"
      RESOLVED_SSL_CA="$certs_dir/user_ca/localCA.pem"
      RESOLVED_TLS_REASON="Kasutajataseme lokaalne usaldatud CA (0 root/admin õigust)"
    elif [ -f "$certs_dir/localhost.crt" ] && [ -f "$certs_dir/localhost.key" ] && [ -f "$certs_dir/localCA.pem" ]; then
      RESOLVED_TLS_MODE="USER_LOCAL_CA"
      RESOLVED_SSL_CERT="$certs_dir/localhost.crt"
      RESOLVED_SSL_KEY="$certs_dir/localhost.key"
      RESOLVED_SSL_CA="$certs_dir/localCA.pem"
      RESOLVED_TLS_REASON="Kasutajataseme lokaalne usaldatud CA (0 root/admin õigust)"
    fi
  fi

  # --------------------------------------------------------------------------
  # STEP 4: Fall back to Pure Self-Signed Certificate (Variant 4 - Lowest Tier)
  # --------------------------------------------------------------------------
  if [ "$RESOLVED_TLS_MODE" = "UNKNOWN" ]; then
    if [ -f "$certs_dir/self_signed/self_signed.crt" ] && [ -f "$certs_dir/self_signed/self_signed.key" ]; then
      RESOLVED_TLS_MODE="SELF_SIGNED"
      RESOLVED_SSL_CERT="$certs_dir/self_signed/self_signed.crt"
      RESOLVED_SSL_KEY="$certs_dir/self_signed/self_signed.key"
      RESOLVED_TLS_REASON="Jooksvalt genereeritud iseallkirjastatud sertifikaat (Untrusted Fallback)"
    else
      RESOLVED_TLS_MODE="SELF_SIGNED"
      RESOLVED_SSL_CERT="$certs_dir/localhost.crt"
      RESOLVED_SSL_KEY="$certs_dir/localhost.key"
      RESOLVED_TLS_REASON="Jooksvalt genereeritud iseallkirjastatud sertifikaat (Untrusted Fallback)"
    fi
  fi

  # --------------------------------------------------------------------------
  # POLICY ENFORCEMENT & GATING
  # --------------------------------------------------------------------------
  local policy_violation=false

  case "$target_policy" in
    strict_public)
      if [ "$RESOLVED_TLS_MODE" != "CUSTOM_CERT" ] && [ "$RESOLVED_TLS_MODE" != "PUBLIC_DNS" ]; then
        policy_violation=true
      fi
      ;;
    corporate_pki)
      if [ "$RESOLVED_TLS_MODE" != "CUSTOM_CERT" ] && [ "$RESOLVED_TLS_MODE" != "PUBLIC_DNS" ] && [ "$RESOLVED_TLS_MODE" != "CORP_PKI" ]; then
        policy_violation=true
      fi
      ;;
    trusted_local)
      if [ "$RESOLVED_TLS_MODE" = "SELF_SIGNED" ]; then
        policy_violation=true
      fi
      ;;
    permissive|allow_self_signed|auto|*)
      # All modes (0, 1, 2, 3, 4) allowed
      policy_violation=false
      ;;
  esac

  if [ "$policy_violation" = "true" ]; then
    echo ""
    echo -e "${RED}╔══════════════════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║ ❌ TLS NÕUETE VIGA: Blueprint nõuab rangemat TLS taset kui praegune keskkond tagab!          ║${NC}"
    echo -e "${RED}╠══════════════════════════════════════════════════════════════════════════════════════════════╣${NC}"
    printf "║ • Nõutav tase:     %-73s ║\n" "${CYAN}${target_policy}${NC}"
    printf "║ • Tuvastatud tase: %-73s ║\n" "${YELLOW}${RESOLVED_TLS_MODE} (${RESOLVED_TLS_REASON})${NC}"
    echo -e "${RED}║                                                                                              ║${NC}"
    echo -e "${RED}║ 🛠 LAHENDUSVARIANDID KASUTAJALE:                                                             ║${NC}"
    echo -e "${RED}║                                                                                              ║${NC}"
    echo -e "${RED}║ 1. [KIIREIM] Kopeeri olemasolev sertifikaat ja privaatvõti kausta:                           ║${NC}"
    echo -e "${RED}║    📁 config/certs/custom/tls.crt                                                            ║${NC}"
    echo -e "${RED}║    📁 config/certs/custom/tls.key                                                            ║${NC}"
    echo -e "${RED}║                                                                                              ║${NC}"
    echo -e "${RED}║ 2. [ETTEVÕTTE VÕRK] Ühendu ettevõtte VPN-iga ja tõmba sise-PKI sertifikaat:                  ║${NC}"
    echo -e "${RED}║    👉 ./scripts/certs/sync-corp-cert.sh                                                      ║${NC}"
    echo -e "${RED}║                                                                                              ║${NC}"
    echo -e "${RED}║ 3. [LOKAALNE ARENDUS] Kui soovid testida isiklikus arvutis, lisa oma .env faili:             ║${NC}"
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
    echo -e "${GREEN}🔒 TLS LAHENDUSE DOKUMENDID JA AKTIIVNE REŽIIM${NC}"
    echo -e "${CYAN}==================================================================${NC}"
    echo -e "   ├─ 🛡️ Režiim:        ${GREEN}${RESOLVED_TLS_MODE}${NC}"
    echo -e "   ├─ ℹ️ Kirjeldus:     ${CYAN}${RESOLVED_TLS_REASON}${NC}"
    echo -e "   ├─ 📜 Sertifikaat:   ${YELLOW}${RESOLVED_SSL_CERT}${NC}"
    echo -e "   ├─ 🔑 Privaatvõti:   ${YELLOW}${RESOLVED_SSL_KEY}${NC}"
    [ -n "$RESOLVED_SSL_CA" ] && echo -e "   ├─ 🏛️ CA Ahel:       ${YELLOW}${RESOLVED_SSL_CA}${NC}"
    echo -e "   └─ 🌐 Domeen:        ${CYAN}${RESOLVED_TLS_DOMAIN}${NC}"
    echo -e "${CYAN}==================================================================${NC}"
  else
    exit 1
  fi
fi
