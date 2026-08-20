#!/usr/bin/env bash
# ============================================================================
# Oracle Analytics Publisher Native Linux Installer (Non-Podman Server Mode)
# Installs WebLogic & Analytics Publisher on RHEL/Oracle Linux VMs via response files
# ============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [ -f "$SCRIPT_DIR/load-profile.sh" ]; then
  source "$SCRIPT_DIR/load-profile.sh"
  load_db_profile >/dev/null 2>&1 || true
fi

echo "🚀 Oracle Analytics Publisher Native Linux Installer Starting..."

# Check Java runtime
if ! command -v java >/dev/null 2>&1; then
  echo "❌ Error: Java runtime (JDK 17 or 21) is required for native installation!" >&2
  exit 1
fi

ORACLE_HOME="${ORACLE_HOME:-/opt/oracle/product/fmw}"
RESPONSE_FILE="$WORKSPACE_DIR/docker/publisher/dockerfiles/2025/install.file"
ORAINST_LOC="$WORKSPACE_DIR/docker/publisher/dockerfiles/2025/oraInst.loc"

ZIP_FILE=$(find "$WORKSPACE_DIR/binaries/publisher" -name "Oracle_Analytics_Server_Linux*.zip" 2>/dev/null | head -n 1 || true)
INSTALLER_JAR=$(find "$WORKSPACE_DIR/binaries/publisher" -name "Oracle_Analytics_Server*.jar" 2>/dev/null | head -n 1 || true)

if [ -z "$INSTALLER_JAR" ] && [ -n "$ZIP_FILE" ]; then
  echo "ℹ️  Unpacking Publisher installer ZIP package ($ZIP_FILE)..."
  unzip -q -o "$ZIP_FILE" -d "$WORKSPACE_DIR/binaries/publisher/"
  INSTALLER_JAR=$(find "$WORKSPACE_DIR/binaries/publisher" -name "Oracle_Analytics_Server*.jar" 2>/dev/null | head -n 1 || true)
fi

if [ -n "$INSTALLER_JAR" ] && [ -f "$INSTALLER_JAR" ]; then
  echo "ℹ️  Executing silent installation via response file..."
  java -jar "$INSTALLER_JAR" -silent -responseFile "$RESPONSE_FILE" -invPtrLoc "$ORAINST_LOC" -ignoreSysPrereqs -force -novalidation ORACLE_HOME="$ORACLE_HOME" INSTALL_TYPE="Oracle Analytics"
  echo "✅ Native Oracle Analytics Publisher Installation Completed!"
else
  echo "⚠️  Installer JAR not found in binaries/publisher/. Manual step required."
fi
