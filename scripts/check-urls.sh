#!/usr/bin/env bash
# ============================================================================
# Utility Script: Test and Verify All Active Environment URLs
# Purpose: Performs real HTTP/HTTPS network GET calls to verify endpoint health
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ "$SCRIPT_DIR" == *"/internal" ]] || [[ "$SCRIPT_DIR" == *"/snapshots" ]] || [[ "$SCRIPT_DIR" == *"/certs" ]] || [[ "$SCRIPT_DIR" == *"/publisher" ]] || [[ "$SCRIPT_DIR" == *"/patches" ]]; then
  PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
else
  PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
fi

if [ -f "$PROJECT_ROOT/scripts/internal/load-profile.sh" ]; then
  source "$PROJECT_ROOT/scripts/internal/load-profile.sh"
  resolve_active_blueprint
  load_db_profile >/dev/null 2>&1 || true
  load_web_ide_profile >/dev/null 2>&1 || true
  load_publisher_designer_profile >/dev/null 2>&1 || true
fi

if [ -f "$PROJECT_ROOT/scripts/internal/common.sh" ]; then
  source "$PROJECT_ROOT/scripts/internal/common.sh"
else
  CYAN=$'\033[1;36m'
  GREEN=$'\033[1;32m'
  RED=$'\033[1;31m'
  YELLOW=$'\033[0;33m'
  NC=$'\033[0m'
fi

MAX_RETRIES=15
RETRY_INTERVAL=2
CURL_CONNECT_TIMEOUT=3
CURL_MAX_TIME=5

while [ $# -gt 0 ]; do
  case "$1" in
    -l=*|--lang=*|-language=*|--language=*)
      export CLI_LANG="${1#*=}"
      shift
      ;;
    -l|--lang|-language|--language)
      export CLI_LANG="$2"
      shift 2
      ;;
    -t=*|--timeout=*)
      CURL_MAX_TIME="${1#*=}"
      shift
      ;;
    -t|--timeout)
      CURL_MAX_TIME="$2"
      shift 2
      ;;
    -r=*|--retries=*)
      MAX_RETRIES="${1#*=}"
      shift
      ;;
    -r|--retries)
      MAX_RETRIES="$2"
      shift 2
      ;;
    -i=*|--interval=*)
      RETRY_INTERVAL="${1#*=}"
      shift
      ;;
    -i|--interval)
      RETRY_INTERVAL="$2"
      shift 2
      ;;
    -q|--quick|--fast)
      MAX_RETRIES=1
      RETRY_INTERVAL=0
      CURL_CONNECT_TIMEOUT=2
      CURL_MAX_TIME=2
      shift
      ;;
    *)
      if [[ "$1" =~ ^[0-9]+$ ]]; then
        if [ -z "${FIRST_POS_ARG:-}" ]; then
          MAX_RETRIES="$1"
          FIRST_POS_ARG="$1"
        else
          RETRY_INTERVAL="$1"
        fi
      fi
      shift
      ;;
  esac
done

if declare -f resolve_cli_lang >/dev/null 2>&1; then
  export ACTIVE_CLI_LANG="$(resolve_cli_lang)"
fi
CA_CERT="$PROJECT_ROOT/config/certs/localCA.pem"

echo -e "${CYAN}==================================================================${NC}"
echo -e "${CYAN}$(msg_str "TITLE_URL_CHECK")${NC}"
echo -e "${CYAN}==================================================================${NC}"

# Dynamic collection of target URLs: Label|URL|ContentCheckPattern
URLS=()

# 1. ORDS & APEX URLs
ANY_ORDS_ENABLED=false
for inst in $(get_active_db_instances 2>/dev/null); do
  pname=$(echo "$inst" | cut -d'|' -f2)
  load_db_profile "$pname" >/dev/null 2>&1 || true
  if [ "${PROFILE_ORDS_ENABLED:-true}" = "true" ]; then
    ANY_ORDS_ENABLED=true
    break
  fi
done

if is_ords_enabled || podman container exists app-ords 2>/dev/null; then
  if podman container exists app-ords 2>/dev/null || [ "${PROFILE_ORDS_CONTAINER_REQUIRED:-true}" != "false" ]; then
    ords_h_port="${ORDS_HTTP_PORT:-${PROFILE_ORDS_HTTP_PORT:-8088}}"
    ords_s_port="${ORDS_HTTPS_PORT:-${PROFILE_ORDS_HTTPS_PORT:-8448}}"
    [ "${IS_ADB:-false}" = "true" ] && ords_s_port="${ORDS_HTTPS_PORT:-${PROFILE_ORDS_HTTPS_PORT:-8443}}"

    if [ "${IS_ADB:-false}" != "true" ]; then
      URLS+=("ORDS Root HTTP|http://localhost:${ords_h_port}/ords/|")
    fi
    URLS+=("Developer Hub (HTTPS)|https://localhost:${ords_s_port}/dev-hub.html|Oracle DevOps Platform")
    URLS+=("ORDS Root HTTPS|https://localhost:${ords_s_port}/ords/|")
    URLS+=("ORDS Database Actions (Default)|https://localhost:${ords_s_port}/ords/_/landing|!DatabaseCredentialError")

    # Collect active and currently running database instances
    all_instances=($(get_active_db_instances 2>/dev/null))
    if command -v podman >/dev/null 2>&1; then
      for c in $(podman ps --format '{{.Names}}' 2>/dev/null | grep -E '^(db-.*|oracle-db-.*)$'); do
        already=false
        for inst in "${all_instances[@]}"; do
          if [ "$(echo "$inst" | cut -d'|' -f1)" = "$c" ]; then
            already=true
            break
          fi
        done
        if [ "$already" = "false" ]; then
          all_instances+=("${c}|app-free|${c#db-}")
        fi
      done
    fi

    for inst in "${all_instances[@]}"; do
      cname=$(echo "$inst" | cut -d'|' -f1)
      pname=$(echo "$inst" | cut -d'|' -f2)
      load_db_profile "$pname" >/dev/null 2>&1 || true

      pool_name=$(echo "$cname" | sed 's/^db-//' | tr '-' '_')
      apex_en="${PROFILE_APEX_ENABLED:-true}"

      if [ "$apex_en" = "true" ]; then
        upper_pool=$(echo "$pool_name" | tr '[:lower:]' '[:upper:]')
        URLS+=("APEX Static Images (/i/)|https://localhost:${ords_s_port}/i/apex_version.txt|Oracle APEX Version")
        URLS+=("APEX Builder (${upper_pool})|https://localhost:${ords_s_port}/ords/${pool_name}/r/apex/workspace-sign-in/oracle-apex-sign-in|")
        URLS+=("APEX Instance Admin (${upper_pool})|https://localhost:${ords_s_port}/ords/${pool_name}/apex_admin|")
        URLS+=("ORDS Database Actions (${upper_pool})|https://localhost:${ords_s_port}/ords/${pool_name}/sql-developer|!DatabaseCredentialError")
        URLS+=("ORDS Landing (${upper_pool})|https://localhost:${ords_s_port}/ords/${pool_name}/_/landing|!DatabaseCredentialError")
      fi
    done
  fi
else
  echo -e "   ${YELLOW}ℹ️  $(msg_str "ORDS_NOT_CONFIGURED_STATUS")${NC}"
  echo -e "   ${CYAN}💡 $(msg_str "ORDS_NOT_CONFIGURED_HINT")${NC}"
fi

# 2. Analytics Publisher URLs
if is_publisher_enabled || podman container exists app-publisher 2>/dev/null; then
  pub_h_port="${PUBLISHER_HTTP_PORT:-9502}"
  pub_s_port="${PUBLISHER_HTTPS_PORT:-9503}"
  pub_admin_port="${PUBLISHER_ADMIN_PORT:-9500}"
  URLS+=("Publisher UI (HTTP)|http://localhost:${pub_h_port}/xmlpserver|xmlpserver")
  if curl -s -m 2 -o /dev/null "http://localhost:${pub_admin_port}/console" 2>/dev/null; then
    URLS+=("Publisher WebLogic Console (HTTP)|http://localhost:${pub_admin_port}/console|")
  fi
  if curl -s -k --connect-timeout 2 --max-time 3 -o /dev/null "https://localhost:${pub_s_port}/xmlpserver" 2>/dev/null; then
    URLS+=("Publisher UI (HTTPS)|https://localhost:${pub_s_port}/xmlpserver|xmlpserver")
  fi
fi

# 3. Oracle Forms 14c URLs
if is_forms_enabled || podman container exists app-forms 2>/dev/null; then
  forms_h_port="${FORMS_HTTP_PORT:-9001}"
  forms_admin_port="${FORMS_ADMIN_PORT:-7001}"
  forms_builder_port="${FORMS_BUILDER_PORT:-6082}"
  URLS+=("Forms Runtime (HTTP)|http://localhost:${forms_h_port}/forms/frmservlet|")
  URLS+=("Forms Test Form (HTTP)|http://localhost:${forms_h_port}/forms/frmservlet?form=test.fmx|")
  URLS+=("Forms Builder GUI (noVNC)|http://localhost:${forms_builder_port}/vnc.html|")
  URLS+=("Forms WebLogic Console (HTTP)|http://localhost:${forms_admin_port}/console|")
  URLS+=("Forms Builder Web GUI (HTTP)|http://localhost:${forms_builder_port}/vnc.html|")
elif curl -s -m 2 http://localhost:6082/vnc.html >/dev/null 2>&1; then
  URLS+=("Developer Hub Web GUI (HTTP)|http://localhost:6082/vnc.html|")
fi

# 4. Web IDE URLs
if is_web_ide_enabled || [ -n "$(podman ps -q --filter name=web-ide-dev 2>/dev/null)" ]; then
  web_ide_h_port="${WEB_IDE_HTTP_PORT:-8090}"
  web_ide_s_port="${WEB_IDE_HTTPS_PORT:-8450}"
  URLS+=("Web IDE (HTTP)|http://localhost:${web_ide_h_port}|")
  if curl -s -k --connect-timeout 2 --max-time 3 -o /dev/null "https://localhost:${web_ide_s_port}" 2>/dev/null; then
    URLS+=("Web IDE (HTTPS)|https://localhost:${web_ide_s_port}|")
  fi
fi

# 5. Publisher Designer URLs
if is_publisher_designer_enabled || [ -n "$(podman ps -q --filter name=app-publisher-designer 2>/dev/null)" ]; then
  designer_h_port="${PUBLISHER_DESIGNER_HTTP_PORT:-6083}"
  URLS+=("Publisher Designer GUI (noVNC)|http://localhost:${designer_h_port}/vnc.html|")
fi

if [ ${#URLS[@]} -eq 0 ]; then
  msg_print "URL_NO_ACTIVE_URLS"
  echo "No active web service URLs" > "$PROJECT_ROOT/metrics/urls_audit_temp.md"
  exit 0
fi

FAILED_URLS=0
URL_MD_TABLE="| Veebiteenuse Nimi | Kontrollitud URL | HTTP Kood | TLS Usaldus | Staatus |\n| :--- | :--- | :--- | :--- | :--- |\n"

for item in "${URLS[@]}"; do
  label=$(echo "$item" | cut -d'|' -f1)
  url=$(echo "$item" | cut -d'|' -f2)
  pattern=$(echo "$item" | cut -d'|' -f3)

  echo -ne "$(msg_str "URL_TESTING_ENDPOINT" "$label" "$url")"

  SUCCESS=false
  HTTP_CODE=""
  TLS_STATUS="N/A"
  BODY_OUTPUT=""

  # Check TLS certificate trust if HTTPS
  if [[ "$url" =~ ^https:// ]]; then
    if [ -f "$CA_CERT" ]; then
      if curl -s --noproxy "*" --cacert "$CA_CERT" --connect-timeout "${CURL_CONNECT_TIMEOUT}" --max-time "${CURL_MAX_TIME}" -o /dev/null "$url" 2>/dev/null; then
        TLS_STATUS="✅ CA OK"
      else
        TLS_STATUS="⚠️ Self-Signed"
      fi
    fi
  fi

  for ((i=1; i<=MAX_RETRIES; i++)); do
    BODY_OUTPUT=$(curl -s -k -L --noproxy "*" --connect-timeout "${CURL_CONNECT_TIMEOUT}" --max-time "${CURL_MAX_TIME}" "$url" 2>/dev/null || true)
    HTTP_CODE=$(curl -s -k -L --noproxy "*" --connect-timeout "${CURL_CONNECT_TIMEOUT}" --max-time "${CURL_MAX_TIME}" -o /dev/null -w "%{http_code}" "$url" 2>/dev/null | grep -E '^[0-9]{3}$' || echo "000")

    # Check for valid HTTP code (1xx-4xx). HTTP 574 is a Database Credential Error and must NOT pass.
    if [[ "$HTTP_CODE" =~ ^[1-4][0-9]{2}$ ]] && [ "$HTTP_CODE" != "574" ]; then
      # If pattern check is required
      if [ -n "$pattern" ]; then
        if [[ "$pattern" == "!"* ]]; then
          neg_pat="${pattern#!}"
          if ! echo "$BODY_OUTPUT" | grep -q "$neg_pat"; then
            SUCCESS=true
            break
          fi
        else
          if echo "$BODY_OUTPUT" | grep -q -E "$pattern"; then
            SUCCESS=true
            break
          fi
        fi
      else
        SUCCESS=true
        break
      fi
    fi
    sleep "$RETRY_INTERVAL"
  done

  if [ "$SUCCESS" != "true" ] && [[ "$label" == *"APEX Static Images"* ]]; then
    if [ -x "$PROJECT_ROOT/scripts/internal/sync-apex-images.sh" ]; then
      echo -e "${YELLOW}   ⚠️  APEX static assets (/i/) missing. Attempting auto-sync...${NC}"
      "$PROJECT_ROOT/scripts/internal/sync-apex-images.sh" >/dev/null 2>&1 || true
      sleep 2
      HTTP_CODE=$(curl -s -k -L --noproxy "*" --connect-timeout "${CURL_CONNECT_TIMEOUT}" --max-time "${CURL_MAX_TIME}" -o /dev/null -w "%{http_code}" "$url" 2>/dev/null | grep -E '^[0-9]{3}$' || echo "000")
      if [ "$HTTP_CODE" = "200" ]; then
        SUCCESS=true
      fi
    fi
  fi

  if [ "$SUCCESS" = "true" ]; then
    echo -e "${GREEN}$(msg_str "URL_SUCCESS" "HTTP ${HTTP_CODE}" "${TLS_STATUS}")${NC}"
    URL_MD_TABLE+="| ${label} | \`${url}\` | \`HTTP ${HTTP_CODE}\` | ${TLS_STATUS} | ✅ OK |\n"
  else
    echo -e "${RED}$(msg_str "URL_FAIL" "HTTP ${HTTP_CODE:-000}")${NC}"
    if [ "$HTTP_CODE" = "574" ]; then
      echo -e "${YELLOW}   ⚠️  $(msg_str "ORDS_574_DIAGNOSTIC")${NC}"
    fi
    URL_MD_TABLE+="| ${label} | \`${url}\` | \`HTTP ${HTTP_CODE:-000}\` | ${TLS_STATUS} | ❌ Unreachable |\n"
    FAILED_URLS=$((FAILED_URLS + 1))
  fi
done

echo -e "$URL_MD_TABLE" > "$PROJECT_ROOT/metrics/urls_audit_temp.md"

echo -e "${CYAN}==================================================================${NC}"
if [ $FAILED_URLS -eq 0 ]; then
  echo -e "${GREEN}$(msg_str "ALL_URLS_OK")${NC}"
  echo -e "${CYAN}==================================================================${NC}"
  exit 0
else
  echo -e "${RED}$(msg_str "URL_WARN_COUNT" "$FAILED_URLS")${NC}"
  echo -e "${CYAN}==================================================================${NC}"
  exit 1
fi
