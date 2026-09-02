#!/usr/bin/env bash
# ============================================================================
# Dynamic Host SQLcl Wrapper Script (Secure SEPS & High-Performance Edition)
# Automatically resolves TNS_ADMIN and Oracle Wallet SEPS credentials
# Works with any dynamic alias defined in active profiles (NO hardcoding)
# Zero plaintext password leakage in ps aux / process tables
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
  echo "❌ Error: TNS directory '$TNS_DIR' not found!"
  exit 1
fi

export TNS_ADMIN="$TNS_DIR"
# High-performance JVM options for fast CLI startup + SEPS TNS admin & Wallet location
export JAVA_TOOL_OPTIONS="-Doracle.net.tns_admin=$TNS_DIR -Doracle.net.wallet_location=$TNS_DIR -XX:+TieredCompilation -XX:TieredStopAtLevel=1"

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

  # Native SEPS autologin /@ALIAS (zero plaintext password exposure in CLI)
  if [ "$IS_SYS" = "true" ]; then
    set -- "/@${ALIAS}" "as" "sysdba" "${NEW_ARGS[@]+"${NEW_ARGS[@]}"}"
  else
    set -- "/@${ALIAS}" "${NEW_ARGS[@]+"${NEW_ARGS[@]}"}"
  fi
fi

if [ -n "$SQL_BIN" ] && [ -x "$SQL_BIN" ]; then
  exec "$SQL_BIN" "$@"
else
  # Ephemeral container fallback for restricted environments
  SQLCL_IMG="${SQLCL_CONTAINER_IMAGE:-container-registry.oracle.com/database/sqlcl:latest}"
  exec podman run --rm -i --network=host \
    -v "$WORKSPACE_DIR:/workspace" \
    -v "$WORKSPACE_DIR/config/tns_admin_container:/tns:ro" \
    -e JAVA_TOOL_OPTIONS="-Doracle.net.tns_admin=/tns -XX:+TieredCompilation -XX:TieredStopAtLevel=1" \
    -e TNS_ADMIN=/tns \
    -w /workspace "$SQLCL_IMG" "$@"
fi
