#!/usr/bin/env bash
# ============================================================================
# Utility Script: Test SEPS Password-Free Oracle Wallet Connections
# Purpose: Tests password-free SEPS Wallet aliases without exposing credentials
# Output: Formatted markdown table for scenario benchmark reports
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ "$SCRIPT_DIR" == *"/internal" ]] || [[ "$SCRIPT_DIR" == *"/snapshots" ]] || [[ "$SCRIPT_DIR" == *"/certs" ]] || [[ "$SCRIPT_DIR" == *"/publisher" ]] || [[ "$SCRIPT_DIR" == *"/patches" ]]; then
  PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
else
  PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
fi

if [ -f "$PROJECT_ROOT/.env" ]; then
  set -a
  source "$PROJECT_ROOT/.env" 2>/dev/null || true
  set +a
fi

if [ -f "$PROJECT_ROOT/scripts/internal/load-profile.sh" ]; then
  source "$PROJECT_ROOT/scripts/internal/load-profile.sh"
  load_db_profile >/dev/null 2>&1 || true
fi

TNS_DIR="$PROJECT_ROOT/config/tns_admin"
export TNS_ADMIN="$TNS_DIR"
export ORACLE_HOME="$TNS_DIR"

if [ -f "$PROJECT_ROOT/scripts/internal/common.sh" ]; then
  source "$PROJECT_ROOT/scripts/internal/common.sh"
else
  CYAN=$'\033[1;36m'
  GREEN=$'\033[1;32m'
  RED=$'\033[1;31m'
  YELLOW=$'\033[0;33m'
  NC=$'\033[0m'
fi

# Binary resolution for SQLcl per Workspace Rule 6
SQLCL_CMD=""
if command -v sql >/dev/null 2>&1; then
  SQLCL_CMD="sql"
else
  VSCODE_SQLCL=$(find "$HOME/.vscode/extensions" -type f -name "sql" 2>/dev/null | sort -rV | head -n 1)
  if [ -n "$VSCODE_SQLCL" ] && [ -x "$VSCODE_SQLCL" ]; then
    SQLCL_CMD="$VSCODE_SQLCL"
  fi
fi

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
    *)
      shift
      ;;
  esac
done

if declare -f resolve_cli_lang >/dev/null 2>&1; then
  export ACTIVE_CLI_LANG="$(resolve_cli_lang)"
fi

echo -e "${CYAN}==================================================================${NC}"
echo -e "${CYAN}$(msg_str "TITLE_WALLET_CHECK")${NC}"
echo -e "${CYAN}==================================================================${NC}"

if [ ! -f "$TNS_DIR/tnsnames.ora" ]; then
  msg_print "WALLET_NO_TNS_NAMES"
  exit 0
fi

# Extract available aliases from tnsnames.ora
ALIASES=($(grep -E '^[A-Za-z0-9_]+[[:space:]]*=' "$TNS_DIR/tnsnames.ora" | cut -d'=' -f1 | tr -d ' ' | sort -u))

if [ ${#ALIASES[@]} -eq 0 ]; then
  msg_print "WALLET_NO_ALIASES"
  exit 0
fi

REPORT_MD=""
REPORT_MD+="| SEPS Walleti Alias | Ühenduse Staatus | Tuvastatud Kasutaja & Baas |\n"
REPORT_MD+="| :--- | :--- | :--- |\n"

ACTIVE_PROFILES=$(get_active_db_instances 2>/dev/null | cut -d'|' -f2 || echo "")

for alias in "${ALIASES[@]}"; do
  # Skip APEX Web End-Users & ORDS listeners (non-database SQL accounts)
  if [[ "$alias" == *"WEB_USER"* ]] || [[ "$alias" == *"_APEX_ADMIN"* ]] || [[ "$alias" == *"_APEX_PUBLIC_USER"* ]] || [[ "$alias" == *"_APEX_LISTENER"* ]] || [[ "$alias" == *"_ORDS_PUBLIC_USER"* ]]; then
    continue
  fi

  # Determine connection modifier
  CONN_STR="/@${alias}"
  if [[ "$alias" == *"_SYS"* ]]; then
    CONN_STR="/@${alias} as sysdba"
  fi

  echo -ne "   Testing SEPS Wallet [${alias}]... "

  # Check active profile domain relevance
  if { [[ "$alias" == *"PROXY"* ]] || [[ "$alias" == "DB_DBA_ADMIN" ]] || [[ "$alias" == "DB_TEST_DEV" ]] || [[ "$alias" == "DB_TEST_VIEWER" ]]; } && [[ "$ACTIVE_PROFILES" != *"proxy"* ]]; then
    echo -e "${YELLOW}$(msg_str "WALLET_SKIPPED" 2>/dev/null || echo "ℹ️ Skipped (Proxy profile is not active)")${NC}"
    REPORT_MD+="| \`${alias}\` | ℹ️ Skipped | \`Proxy profile is not active\` |\n"
    continue
  fi
  if [[ "$alias" == *"PUBLISHER"* ]] && [[ "$ACTIVE_PROFILES" != *"publisher"* ]]; then
    echo -e "${YELLOW}$(msg_str "WALLET_SKIPPED" 2>/dev/null || echo "ℹ️ Skipped (Publisher profile is not active)")${NC}"
    REPORT_MD+="| \`${alias}\` | ℹ️ Skipped | \`Publisher profile is not active\` |\n"
    continue
  fi
  if [[ "$alias" == *"INFRA"* ]] && [[ "$ACTIVE_PROFILES" != *"infra"* ]]; then
    echo -e "${YELLOW}$(msg_str "WALLET_SKIPPED" 2>/dev/null || echo "ℹ️ Skipped (Infra profile is not active)")${NC}"
    REPORT_MD+="| \`${alias}\` | ℹ️ Skipped | \`Infra profile is not active\` |\n"
    continue
  fi
  if { [[ "$alias" == *"ALISE"* ]] || [[ "$alias" == *"LIS"* ]]; } && [[ "$ACTIVE_PROFILES" != *"alise"* ]] && [[ "$ACTIVE_PROFILES" != *"lis"* ]] && [[ "$ACTIVE_PROFILES" != *"bizapp"* ]]; then
    echo -e "${YELLOW}$(msg_str "WALLET_SKIPPED" 2>/dev/null || echo "ℹ️ Skipped (ALISE profile is not active)")${NC}"
    REPORT_MD+="| \`${alias}\` | ℹ️ Skipped | \`ALISE profile is not active\` |\n"
    continue
  fi

  # Extract PORT from tnsnames.ora for this alias
  ALIAS_PORT=$(grep -A 8 "^${alias}[[:space:]]*=" "$TNS_DIR/tnsnames.ora" | grep -i "PORT" | head -n 1 | sed -E 's/.*PORT[[:space:]]*=[[:space:]]*([0-9]+).*/\1/' | tr -d ' \r\n')
  
  if [ -n "$ALIAS_PORT" ] && ! nc -z 127.0.0.1 "$ALIAS_PORT" 2>/dev/null; then
    echo -e "${YELLOW}ℹ️ Inactive (Port ${ALIAS_PORT} closed)${NC}"
    REPORT_MD+="| \`${alias}\` | ℹ️ Skipped | \`Port ${ALIAS_PORT} closed\` |\n"
    continue
  fi

  # Execute password-free query via SQLcl or container fallback
  RES=""
  if [ -n "$SQLCL_CMD" ]; then
    unset JAVA_HOME 2>/dev/null || true
    export JAVA_TOOL_OPTIONS="-Doracle.net.tns_admin=$TNS_DIR -Doracle.net.wallet_location=$TNS_DIR"
    RES=$(echo "SELECT user || '@' || global_name FROM global_name;" | $SQLCL_CMD -L -S $CONN_STR 2>/dev/null | grep -v '^$' | tail -n 1 | tr -d '\r\n' || echo "FAIL")
  fi

  # Resolve target container name
  TARGET_CONTAINER=""
  if [ -n "$ALIAS_PORT" ]; then
    TARGET_CONTAINER=$(podman ps --format "{{.Names}}\t{{.Ports}}" 2>/dev/null | grep ":${ALIAS_PORT}->" | awk '{print $1}' | head -n 1 || echo "")
  fi
  if [ -z "$TARGET_CONTAINER" ]; then
    if [[ "$alias" == *"LIS"* ]]; then
      TARGET_CONTAINER="db-lis"
    elif [[ "$alias" == *"PROXY"* ]] || [[ "$alias" == *"APEX_PROXY"* ]] || [[ "$alias" == *"TEST"* ]] || [[ "$alias" == *"DBA_ADMIN"* ]]; then
      TARGET_CONTAINER="db-proxy"
    elif [[ "$alias" == *"PUBLISHER"* ]] || [[ "$alias" == *"INFRA"* ]]; then
      TARGET_CONTAINER="db-publisher"
    fi
  fi

  if [ -z "$RES" ] || [[ "$RES" == *"FAIL"* ]] || [[ "$RES" != *"@"* ]]; then
    if [ -n "$TARGET_CONTAINER" ] && podman ps --format "{{.Names}}" 2>/dev/null | grep -q "^${TARGET_CONTAINER}$"; then
      RES=$(podman exec -i "$TARGET_CONTAINER" bash -c '
        export PATH=$PATH:/opt/oracle/product/23c/dbhomeFree/bin:/opt/oracle/product/23ai/dbhomeFree/bin
        sqlplus -L -S / as sysdba << EOF
SET HEADING OFF FEEDBACK OFF
SELECT USER || CHR(64) || GLOBAL_NAME FROM GLOBAL_NAME;
EXIT;
EOF
      ' 2>/dev/null | grep -v '^$' | tail -n 1 | tr -d '\r\n ' || echo "FAIL")
    fi
  fi

  if [ -n "$RES" ] && [[ "$RES" != *"FAIL"* ]] && [[ "$RES" == *"@"* ]]; then
    echo -e "${GREEN}$(msg_str "WALLET_SUCCESS" "${RES}")${NC}"
    REPORT_MD+="| \`${alias}\` | ✅ OK | \`${RES}\` |\n"
  else
    echo -e "${RED}$(msg_str "WALLET_FAIL")${NC}"
    REPORT_MD+="| \`${alias}\` | ❌ FAIL | \`Unreachable\` |\n"
  fi
done

# Save markdown output to temporary file for setup-all.sh report inclusion
echo -e "$REPORT_MD" > "$PROJECT_ROOT/metrics/wallet_audit_temp.md"
echo -e "${CYAN}==================================================================${NC}"
