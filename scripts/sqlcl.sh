#!/usr/bin/env bash
# ============================================================================
# Dynamic Host SQLcl Wrapper Script
# Automatically resolves TNS_ADMIN and Oracle Wallet SEPS credentials
# Works with any dynamic alias defined in active profiles (NO hardcoding)
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ -f "$WORKSPACE_DIR/.env" ]; then
  set -a
  source "$WORKSPACE_DIR/.env"
  set +a
fi

TNS_DIR="$WORKSPACE_DIR/config/tns_admin"
if [ ! -d "$TNS_DIR" ]; then
  echo "❌ Viga: TNS kausta '$TNS_DIR' ei leitud!"
  exit 1
fi

export TNS_ADMIN="$TNS_DIR"
# Set only tns_admin — wallet location is read from sqlnet.ora
export JAVA_TOOL_OPTIONS="-Doracle.net.tns_admin=$TNS_DIR"

# Find VS Code SQLcl binary
VSCODE_SQLCL=$(find "$HOME/.vscode/extensions" -name "sql" -path "*/oracle.sql-developer-*/dbtools/sqlcl/bin/sql" 2>/dev/null | sort -rV | head -n 1)

# Prefer VS Code SQLcl, fallback to system
if [ -n "$VSCODE_SQLCL" ] && [ -x "$VSCODE_SQLCL" ]; then
  SQL_BIN="$VSCODE_SQLCL"
elif [ -x "/opt/homebrew/Caskroom/sqlcl/24.3.1.311.1631/sqlcl/bin/sql.orig" ]; then
  SQL_BIN="/opt/homebrew/Caskroom/sqlcl/24.3.1.311.1631/sqlcl/bin/sql.orig"
else
  SQL_BIN="$(command -v sql || true)"
fi

# Unset JAVA_HOME to avoid interfering with VS Code SQLcl's bundled JDK
unset JAVA_HOME

ARG1="${1:-}"
if [[ "$ARG1" == "/@"* ]]; then
  # Extract alias name, stripping leading /@
  RAW_ALIAS="${ARG1#/@}"
  ALIAS="${RAW_ALIAS%% *}"   # take first word only
  shift

  # Determine if sysdba is requested (from remaining args or alias name)
  IS_SYS=false
  ALIAS_LOWER=$(echo "$ALIAS" | tr '[:upper:]' '[:lower:]')
  [[ "$ALIAS_LOWER" == *"sys"* ]] && IS_SYS=true

  NEW_ARGS=()
  for a in "$@"; do
    a_lower=$(echo "$a" | tr '[:upper:]' '[:lower:]')
    if [ "$a_lower" = "sysdba" ]; then IS_SYS=true; fi
    if [ "$a_lower" != "as" ] && [ "$a_lower" != "sysdba" ]; then
      NEW_ARGS+=("$a")
    fi
  done

  # Lookup credentials from wallet or container secrets
  CRED=$("$WORKSPACE_DIR/scripts/internal/view-wallet-credential.sh" "$ALIAS" 2>/dev/null || true)
  UNAME=$(echo "$CRED" | grep "Username:" | sed $'s/\x1b\\[[0-9;]*m//g' | awk -F': ' '{print $2}' | tr -d ' \r\t\n')
  UPWD=$(echo "$CRED" | grep "Password:" | sed $'s/\x1b\\[[0-9;]*m//g' | awk -F': ' '{print $2}' | tr -d ' \r\t\n')

  # Fallback for SYS if wallet lookup was empty
  if [ -z "$UNAME" ] && [ "$IS_SYS" = "true" ]; then
    UNAME="sys"
  fi
  if [ -z "$UPWD" ] && [ "$IS_SYS" = "true" ]; then
    UPWD=$(podman secret inspect --showsecret apex_db_sys_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
    [ -z "$UPWD" ] && UPWD=$(podman exec db-dev-full cat /run/secrets/oracle_pwd 2>/dev/null | tr -d '\r\n' || true)
  fi

  if [ -n "$UNAME" ] && [ -n "$UPWD" ]; then
    CONNECT="${UNAME}/${UPWD}@${ALIAS}"
    if [ "$IS_SYS" = "true" ]; then
      set -- "$CONNECT" "as" "sysdba" "${NEW_ARGS[@]+"${NEW_ARGS[@]}"}"
    else
      set -- "$CONNECT" "${NEW_ARGS[@]+"${NEW_ARGS[@]}"}"
    fi
  else
    # Fallback to SQLcl native SEPS autologin
    if [ "$IS_SYS" = "true" ]; then
      set -- "/@${ALIAS}" "as" "sysdba" "${NEW_ARGS[@]+"${NEW_ARGS[@]}"}"
    else
      set -- "/@${ALIAS}" "${NEW_ARGS[@]+"${NEW_ARGS[@]}"}"
    fi
  fi
fi


if [ -n "$SQL_BIN" ] && [ -x "$SQL_BIN" ]; then
  exec "$SQL_BIN" "$@"
else
  # Container fallback for restricted environments
  SQLCL_IMG="${SQLCL_CONTAINER_IMAGE:-container-registry.oracle.com/database/sqlcl:latest}"
  exec podman run --rm -i --network=host \
    -v "$WORKSPACE_DIR:/workspace" \
    -v "$WORKSPACE_DIR/config/tns_admin_container:/tns:ro" \
    -e JAVA_TOOL_OPTIONS="-Doracle.net.tns_admin=/tns -Doracle.net.wallet_location=(SOURCE=(METHOD=FILE)(METHOD_DATA=(DIRECTORY=/tns)))" \
    -e TNS_ADMIN=/tns \
    -w /workspace "$SQLCL_IMG" "$@"
fi
