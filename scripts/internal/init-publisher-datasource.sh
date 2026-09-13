#!/usr/bin/env bash
# ============================================================================
# Automatic Publisher JDBC Data Source Configurator (init-publisher-datasource.sh)
# Configures LIS_APP_DB JDBC connection in Oracle Analytics Publisher repository
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [ -f "$SCRIPT_DIR/load-profile.sh" ]; then
  source "$SCRIPT_DIR/load-profile.sh"
fi

echo "📊 Configuring Analytics Publisher JDBC Data Source connection (ALISE_APP_DB)..."

# Resolve target database parameters (local db-alise / db-proxy or remote host)
TARGET_DB_HOST="${ALISE_DB_HOST:-${LIS_DB_HOST:-${DB_HOST:-db-alise}}}"
TARGET_DB_PORT="${ALISE_DB_PORT:-${LIS_DB_PORT:-${DB_PORT:-1521}}}"
TARGET_DB_SERVICE="${ALISE_DB_SERVICE:-${LIS_DB_SERVICE:-${DB_SERVICE:-FREEPDB1}}}"
TARGET_USER="PUBLISHER_READER"

# Query password from Podman secret or Wallet
SQLCL_IMG="${SQLCL_CONTAINER_IMAGE:-container-registry.oracle.com/database/sqlcl:latest}"
TARGET_PASSWORD=$(podman run --rm --entrypoint cat --secret publisher_reader_password "$SQLCL_IMG" /run/secrets/publisher_reader_password 2>/dev/null || podman secret inspect --showsecret publisher_reader_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
if [ -z "$TARGET_PASSWORD" ]; then
  TARGET_PASSWORD=$("$SCRIPT_DIR/get-password.sh" DB_PUBLISHER_READER 2>/dev/null | grep "Password:" | cut -d':' -f2- | tr -d ' \r' || true)
fi
if [ -z "$TARGET_PASSWORD" ]; then
  TARGET_PASSWORD="OraclePass2026!"
fi

# Generate Publisher XML DataSource file
PUB_DS_DIR="$WORKSPACE_DIR/config/publisher/datasources"
mkdir -p "$PUB_DS_DIR"

DS_FILE="$PUB_DS_DIR/ALISE_APP_DB.xml"

cat <<EOF > "$DS_FILE"
<?xml version="1.0" encoding="UTF-8"?>
<jdbc-data-source xmlns="http://xmlns.oracle.com/weblogic/jdbc-data-source">
  <name>ALISE_APP_DB</name>
  <jdbc-driver-params>
    <url>jdbc:oracle:thin:@${TARGET_DB_HOST}:${TARGET_DB_PORT}/${TARGET_DB_SERVICE}</url>
    <driver-name>oracle.jdbc.OracleDriver</driver-name>
    <properties>
      <property>
        <name>user</name>
        <value>${TARGET_USER}</value>
      </property>
    </properties>
    <password-encrypted>${TARGET_PASSWORD}</password-encrypted>
  </jdbc-driver-params>
  <jdbc-connection-pool-params>
    <initial-capacity>2</initial-capacity>
    <max-capacity>20</max-capacity>
    <test-frequency-seconds>120</test-frequency-seconds>
    <test-table-name>SQL SELECT 1 FROM DUAL</test-table-name>
  </jdbc-connection-pool-params>
</jdbc-data-source>
EOF

# Ensure ALISE_APP_DB is configured in Publisher datasources.xml inside container
PUB_CONTAINER="app-publisher"
if command -v podman >/dev/null 2>&1 && podman container exists "$PUB_CONTAINER" 2>/dev/null && [ "$(podman inspect --format='{{.State.Status}}' "$PUB_CONTAINER" 2>/dev/null)" = "running" ]; then
  podman exec -i "$PUB_CONTAINER" /bin/bash -c '
    DS_XML="/u01/oracle/user_projects/domains/bi/config/fmwconfig/biconfig/bipublisher/Admin/DataSource/datasources.xml"
    if [ -f "$DS_XML" ] && ! grep -q "ALISE_APP_DB" "$DS_XML"; then
      echo "Injecting ALISE_APP_DB JNDI connection into $DS_XML..."
      sed -i "s|</dataSources>|<dataSource name=\"ALISE_APP_DB\">\n      <connection>\n         <connectionType>jndi</connectionType>\n         <proxyAuthentication>false</proxyAuthentication>\n         <jndiName>jdbc/BIPlatformDatasource</jndiName>\n      </connection>\n      <acl>\n         <policy>\n            <subject>\n               <rolename>BIConsumer</rolename>\n               <rolename>BIContentAuthor</rolename>\n               <rolename>BIDataLoadAuthor</rolename>\n               <rolename>BIDataModelAuthor</rolename>\n               <rolename>BIServiceAdministrator</rolename>\n               <rolename>DVConsumer</rolename>\n               <rolename>DVContentAuthor</rolename>\n            </subject>\n            <action name=\"read\"/>\n         </policy>\n      </acl>\n   </dataSource>\n</dataSources>|" "$DS_XML"
      echo "✅ ALISE_APP_DB registered in Publisher container."
    fi
  ' 2>/dev/null || true
fi

echo "✅ Analytics Publisher JDBC Data Source 'ALISE_APP_DB' configured!"
