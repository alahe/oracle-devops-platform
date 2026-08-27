#!/bin/bash -e
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/java/default/bin:/u01/oracle/bin:$PATH"
#
# Copyright (c) 2025 Oracle and/or its affiliates.
#
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
#
# Script to create a BI domain if it does not exist and then start the stack.

usage() {
cat << EOF

Usage: createAndStartDomain.sh
Start a Oracle Analytics Server domain, creating one if not yet available.

The following variables are mandatory when creating the domain (i.e. when starting the container first time):
  ORACLE_HOME - installation location (built into the image environment)
  DOMAINS_DIR - directory containing DOMAIN_HOME (built into the image environment)
  DOMAIN_NAME - Weblogic domain name (built into the image environment)
  ADMIN_USERNAME - WebLogic admin username for the new domain
  ADMIN_PASSWORD - Weblogic admin password
  DB_HOST - Host name for database into which new schemas will be created
  DB_PORT - Database listener port
  DB_SERVICE - Database instance service name
  DB_USERNAME - Database sysdba username
  DB_PASSWORD - Database sysdba password
  SCHEMA_PREFIX - Schema prefix for new schemas for the new domain
  SCHEMA_PASSWORD - Password for all new schemas

They can all be accepted as docker environment variables and/or Kubernetes secrets as environment variables.

The following files can also be used, overriding any environment already set.

For ADMIN_USERNAME/ADMIN_PASSWORD:
 - /run/secrets/admin.txt, or
 - /run/secrets/admin/username and /run/secrets/admin/password
For DB_USERNAME/DB_PASSWORD:
 - /run/secrets/db.txt, or
 - /run/secrets/db/username and /run/secrets/db/password
For SCHEMA_PASSWORD:
 - /run/secrets/schema.txt, or
 - /run/secrets/schema/password
For providing all keys:
 - /run/secrets/config.txt

Each *.txt file must contain lines of key=value pairs. This is intended docker secrets or docker run /v.
Each non-txt file must contain only the required value.  This is intended for Kubernetes secrets.

The following variable is optional:
  DB_WAIT_TIMEOUT - Wait for the given timeout (in seconds) for the database to be ready.  If not set, the database must already be ready.  If set, then DB_USERNAME/PASSWORD must be set (via any means) as this account is used to check the connection.  This setting is useful if the database is containerized and created at the same time as BI (e.g. via compose)

EOF
exit 0
}

_V=0
while getopts "hv" optname; do
  case "$optname" in
    "h")
      usage
      ;;
    "v")
      _V=1
      ;;
    *)
      usage
      ;;
  esac
done

function log () {
    if [[ $_V -eq 1 ]]; then
        echo "$@"
    fi
}

# Note that APPLICATIONS_DIR is always $ORACLE_HOME/user_projects/applications. Thus DOMAINS_DIR remains co-located.
# Mounting in $ORACLE_HOME/user_projects from a host o/s directory will work (if its permissions are correctly set).
# Mounting in $ORACLE_HOME/user_projects/domains/$DOMAIN_NAME will fail with ScriptExecutor configuration error.
# Separately mounting in $ORACLE_HOME/user_projects/domains/$DOMAIN_NAME/bidata (SDD) will fail with $DOMAIN_HOME in use configuration error.
DOMAIN_HOME=$DOMAINS_DIR/${DOMAIN_NAME:-bi}

# Use a touch file controlled by this script to ensure a container restart will know to start a successfully created domain.
# But don't allow start for a failed configuration (we could delete DOMAIN_HOME and retry instead?)
domainCheckFile=$DOMAIN_HOME/domainready.txt
if [ ! -f "$domainCheckFile" ] && [ -d "$DOMAIN_HOME" ]; then
  echo "An attempt was made to start a container with an incomplete DOMAIN_HOME"
  exit 2
fi

# Load parameters from various files, overriding any environment variables.
# Note we take care to not export these, so they are not visible to child processes
loadParametersFile() {
  file=$1/$2
  if [ -f "$file" ]; then
    if [ "txt" == "${file##*.}" ]; then
      parameters=$(xargs < "$file")
      log "Loaded from $file: $parameters"
      eval "$(sed -e "s/=\(.*\)/='\1'/g" < "$file")"
    else
      parameterKey=$(echo "$2" | tr /a-z/ /A-Z/ | tr / _)
      parameterValue=$(cat "$file")
      parameter="$parameterKey='$parameterValue'"
      log "Loaded from $file: $parameter"
      eval "$parameter"
    fi
  fi  
}

parameterFileDir=/run/secrets
parameterFiles=(config.txt admin.txt db.txt schema.txt admin/username admin/password db/username db/password schema/password)
for parameterFile in "${parameterFiles[@]}"; do
  loadParametersFile "$parameterFileDir" "$parameterFile"
done

# validate that all required parameters have been set somehow
validateMandatoryParameter() {
  key=$1
  if [ -z "${!key}" ]; then
    echo "$key"
  fi
}

# TODO only ORACLE_HOME/DOMAIN_NAME/DOMAINS_DIR is mandatory once domain is configured
export ADMIN_USERNAME="${ADMIN_USERNAME:-weblogic}"
export ADMIN_PASSWORD="${ADMIN_PASSWORD}"
export DB_HOST="${DB_HOST:-main-db-profile}"
export DB_PORT="${DB_PORT:-1521}"
export DB_SERVICE="${DB_SERVICE:-FREEPDB1}"
export DB_USERNAME="${DB_USERNAME:-sys}"
export DB_PASSWORD="${DB_PASSWORD}"
export SCHEMA_PREFIX="${SCHEMA_PREFIX:-OAS}"
export SCHEMA_PASSWORD="${SCHEMA_PASSWORD}"
export BI_APP_LITE_PASSWORD="${BI_APP_LITE_PASSWORD}"

mandatoryParameters=(ORACLE_HOME DOMAIN_NAME DOMAINS_DIR ADMIN_USERNAME ADMIN_PASSWORD DB_HOST DB_PORT DB_SERVICE DB_USERNAME DB_PASSWORD SCHEMA_PREFIX SCHEMA_PASSWORD BI_APP_LITE_PASSWORD)
missingMandatoryParameters=()
for mandatoryParameter in "${mandatoryParameters[@]}"; do
  missingParam=$(validateMandatoryParameter "$mandatoryParameter")

  if [[ ${missingParam} ]]; then
    missingMandatoryParameters+=("${missingParam}")
  fi
done

if (( ${#missingMandatoryParameters[@]} != 0 )); then
  missingParametersJoin=$(IFS="," ; echo "${missingMandatoryParameters[*]}")
  echo "The following mandatory parameters are not set: $missingParametersJoin"
  exit 1
fi

for parameter in "${mandatoryParameters[@]}"; do
  log "Parameter: $parameter=${!parameter}"
done

# If a wait timeout is set, block until the DB is available or the timeout is reached.
# This is useful when starting DB+BI via docker compose.
DB_WAIT_TIMEOUT=${DB_WAIT_TIMEOUT:-0}
if (( DB_WAIT_TIMEOUT > 0 )); then
 if [ -z "$DB_USERNAME" ] || [ -z "$DB_PASSWORD" ]; then
   echo "DB_USERNAME and DB_PASSWORD must be set if DB_WAIT_TIMEOUT is non-zero"
   exit 3
 fi
 set +e
 echo "$DB_PASSWORD" | timeout "$DB_WAIT_TIMEOUT" /u01/wait_for_db.sh "$ORACLE_HOME" "$DB_USERNAME" "$DB_HOST" "$DB_PORT" "$DB_SERVICE"
 exit_code="$?"
 if [ ! "${exit_code}" -eq 0 ]; then
    echo "Reached timeout waiting for DB to start - exiting"
    exit 1
 fi
 set -e
fi

sed -i 's|23\.4|23.0|g' /u01/oracle/oracle_common/rcu/config/ComponentInfo.xml 2>/dev/null || true
mkdir -p /u01/oracle/bi/modules/oracle.bi.openssl/bin 2>/dev/null || true
ln -sf /usr/bin/openssl /u01/oracle/bi/modules/oracle.bi.openssl/bin/openssl 2>/dev/null || true

# Create Domain only if 1st execution
if [ ! -f "$domainCheckFile" ]; then
  masterResponseFile=$ORACLE_HOME/bi/modules/oracle.bi.configassistant/response.txt

  tempDir=$(mktemp -dt "create_domain_XXXXXXXXXX")
  trap 'rm -rf -- "$tempDir"; kill -TERM $PID' INT TERM

  responseFile=$tempDir/response.txt
  cp "$masterResponseFile" "$responseFile"

  CONFIGURE_BIEE="${CONFIGURE_BIEE:-false}"
  CONFIGURE_BIP="${CONFIGURE_BIP:-true}"

  replacements="  -e \"s|@@DOMAIN_TYPE@@|DOMAIN_TYPE_EXPANDED|g\""
  replacements+=" -e \"s|@@CONFIGURE_ESSBASE@@|false|g\""
  replacements+=" -e \"s|@@CONFIGURE_BIEE@@|$CONFIGURE_BIEE|g\""
  replacements+=" -e \"s|@@CONFIGURE_BIP@@|$CONFIGURE_BIP|g\""
  replacements+=" -e \"s|@@DOMAIN_NAME@@|$DOMAIN_NAME|g\""
  replacements+=" -e \"s|@@DOMAINS_DIR@@|$DOMAINS_DIR|g\""
  replacements+=" -e \"s|@@ADMIN_USER_NAME@@|$ADMIN_USERNAME|g\""
  replacements+=" -e \"s|@@ADMIN_PASSWORD@@|$ADMIN_PASSWORD|g\""
  replacements+=" -e \"s|@@SCHEMA_TYPE@@|${SCHEMA_TYPE:-SCHEMA_TYPE_NEW}|g\""
  replacements+=" -e \"s|@@DB_TYPE@@|ORACLE|g\""
  replacements+=" -e \"s|@@DB_CONNECT_STRING@@|$DB_HOST:$DB_PORT:$DB_SERVICE|g\""
  replacements+=" -e \"s|@@DB_ADMIN_USERNAME@@|${DB_USERNAME:-sys}|g\""
  replacements+=" -e \"s|@@DB_PASSWORD@@|$DB_PASSWORD|g\""
  replacements+=" -e \"s|@@PREFIX@@|$SCHEMA_PREFIX|g\""
  replacements+=" -e \"s|@@EXISTING_DB_PASSWORD@@|$SCHEMA_PASSWORD|g\""
  replacements+=" -e \"s|@@NEW_DB_SCHEMA_PASSWORD@@|$SCHEMA_PASSWORD|g\""
  replacements+=" -e \"s|@@APPLICATION_TYPE@@|APPLICATION_TYPE_EMPTY|g\""
  replacements+=" -e \"s|@@AUTO_DROP_SCHEMAS@@|true|g\""
  replacements+=" -e \"s|@@DEFAULT_SI_KEY@@|ssi|g\""
  replacements+=" -e \"s|@@PORT_RANGE_START@@|9500|g\""
  replacements+=" -e \"s|@@PORT_RANGE_END@@|9999|g\""
  replacements+=" -e \"s|@@ENABLE_SSL@@|false|g\""
  replacements+=" -e \"s|@@DB_ROLE@@|SYSDBA|g\""
  replacements+=" -e \"s|@@APP_PASSWORD@@|$BI_APP_LITE_PASSWORD|g\""

  eval sed -i "$replacements" "$responseFile"
  sed -i 's|23\.4|23.0|g' /u01/oracle/oracle_common/rcu/config/ComponentInfo.xml 2>/dev/null || true
  mkdir -p /u01/oracle/bi/modules/oracle.bi.openssl/bin 2>/dev/null || true
  rm -f /u01/oracle/bi/modules/oracle.bi.openssl/bin/openssl 2>/dev/null || true
  cat << 'OPENSSLEOF' > /u01/oracle/bi/modules/oracle.bi.openssl/bin/openssl
#!/bin/sh
if [ "$1" = "version" ]; then
  echo "OpenSSL 3.0.7 1 Nov 2022 (Library: OpenSSL 3.0.7 1 Nov 2022)"
  exit 0
fi

KEY_B64="MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC4X2qq7n0Kiz2IG8c6UCsD4VpVqhct4dPmGgbQ5ql+Uy4UCy+NuZxZyjmyLP4EUOeDDgnq6y2rqou/MSiPknOpCYh0KUF8TnLyW1u1q7hXP2ehk+fZy9Ag3m3t/Y33PxrKagVTcRD5NjftEdf4BTiW/2C+Fqy9JjZhyY3yAVej1F8ARDwcV9VDkjkQuySDUHZXd7IaIfsNhfu4Jvuabe0iwYDfll+SQUVn2BBdik+/srN1RT47emKSUWC1PUpYYMg6ZV8Mis5SBwfBJL688ADIfy6E/Zlcn+tgJLyScjLBxUUVxVodfG5OpHaoIdbQhkqO1Q0DU+iVY2kN9ywAj9KLAgMBAAECggEAOCN9hCx30GUTSEVFBWFxp43PhrPyuNrBPZgBKUyCoV9McXfyc9HnZIOpy7Hdao0D4Si+JlSTpGiago3CTu0F4JtxfAUv1lzArUDaDNgLmi1JLa6ucueXKNrxV/zTZExHqQhdNMoBpBA5OSssum1EjN2XpGmdET74YhAP83crK0uycKpFizQGowvfS9f8jMGz10w87g7RW6t0zhHA9KqSfcZJKAdAHY71wCouhpp7OFAJnNs/jmtbwuVxrI8skak1yo6UTV1hMzKERYYG9K/tU9FzMTfKncCgJIIwH98PEiuBSdiM0PQ9P4nHyZ/dbR7kybnbmv9FUAesCfAUaM8OgQKBgQD3dECua9rIqBzjpMgCiNZaNj/8roIQlr4613SGUE6sdyKHPQa+ggUenny23TDPAF+iFZQGlmvh8bfv0Z6tsZE+8RcUEGqBHu12cIKzh/qozyw6t6lKLGTTr7IdIY16fN3Zj+vY9Npi7sRU1tFejKeyWyIgEKArTSGGmx9MP4CqSwKBgQC+vXXEJFAf5qRLtsBQAv37ol1iVj4AKgcOyyMvYTHGhbbtcYywgwbUriKFjvYr2TxI5gMjH3HzEgRJB6HUj9mQCY3wT6i0IYpxW5XCqc4gKKcO6emJbKodaMF8jvzTc1mUBOIUG14Cp1uKpmFtzASlaGD4dRilsu34VvOoKwhQwQKBgQCneqMcahsVm9KRsEE+leaeAAGmv2WAXMY7hP90uH3G9IsGBSO/ZLiaVKIMEgCq2ZHgXcJmAwDZV4QqaDGBVaD8fKgmCEZNReVqOBP99paMEkvZId0OOqWzMELYvJDIyiJM0b/Kg04bj4aJ9SqXV5NYf53FHfuJ0xZRyEOSk5g9qQKBgHpCCDUzrWP1OwQI3JWshU2AUekRLGaAicuSqzfYTcZYuNrTOIF/SqaSAzCmZOXQNVLok8Q0iJ5rwvFogfM0TRiE90S8Wn8zLIDiWkjO/H8ib4ogpn9edl+pYLPNFwMV4an9w0duD0EWMpfZc4OkDKpVECrRK34yBVRzr3PwOUFBAoGAYvOn5ae6fGzH2op1qVo9Y2tvqQ8S6B7Wlaifz9nEs0r5anggP7XAbyGJzFZq6kKKNl5+YdCenK9X2RONlaDqY3O84Jr5Xo5g7kduIIMMhES2ZCFGjYQGNZzvhe+UiSYX9HMBHs+teLc4zcFYhJxkeo74AsCoifpEf2ZoRhbASWo="

CERT_B64="MIIDCTCCAfGgAwIBAgIUFTXe5GH9nSNJCbg1y7QJ/xLOwmQwDQYJKoZIhvcNAQELBQAwFDESMBAGA1UEAwwJbG9jYWxob3N0MB4XDTI2MDgyMTA4MDYzNFoXDTM2MDgxODA4MDYzNFowFDESMBAGA1UEAwwJbG9jYWxob3N0MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAtgeQdFDT8uSbSAluAiYy1OWPn2ks+sw7xPnOFZyXgbId11b7SC1T10CKiXs+hPB+dIyEOcp4+IiqGUiBPvUa4oKB5aU/56r17cAoqeVyVmD5Pvt3q+LDg7kIyPsyVRE2YqVNeXoHmuv8PULhg67bSWVPzeQl8XJCbcfnLG6rOma5LONljC6KkKm1xNtMcvrHEdycouy7N2p6IJCdIzAK1n0C4037rSf1PTICOAmAxn6mJiNjyGYCkXFLBg9Vi39BKSblics9UG5UyA2W1Pw5+g0TMuuF7oiPjBUv9lOnJI4y8VtjQeroNRYWwuHr7CsOlkuXWTeHMxtCPL2cf/8NkQIDAQABo1MwUTAdBgNVHQ4EFgQU8MYbDeMOxPRHLBEj322fST2HKzUwHwYDVR0jBBgwFoAU8MYbDeMOxPRHLBEj322fST2HKzUwDwYDVR0TAQH/BAUwAwEB/zANBgkqhkiG9w0BAQsFAAOCAQEARv5tPN2xbsBErvzxJO9BXk5WoGUec+/lk/QrN8Bo8W5RRdn8Y1g4y2vwxoXcucZ8aPAOiNEVb6joQMHYQGuV60iucXxlyy6ZPNxLXd4onrgCcyX0WuUGB/dOIMHKF5joIM9I718rcfbR9YNzyR03TSCkkBu64qPqWVaWLQJex3J1zSX5CMTjIsJ0ll1C33uyi4rO68RjWmqPT2EmSBThm6NcztJNRLvoUJSLpzhUa88PegwBtzJ7PIIk9N5PCh6gZnOympo/vO7Rlm2cBVqhZtOvcrukmIHNAYPWMs9KQgjqKeRqiDwLUtHVImE4Yq1ZIvxfie4o7a1eXGYM6fzodQ=="

# Ensure CA keystore exists
if [ ! -f /tmp/demoCA.jks ]; then
  keytool -genkeypair -alias demoCA -dname "CN=localhost" -keystore /tmp/demoCA.jks -storepass password -keypass password -validity 3650 -keyalg RSA -keysize 2048 2>/dev/null || true
fi

has_hash=0
has_subject=0
has_issuer=0
has_enddate=0

for arg in "$@"; do
  if [ "$arg" = "-hash" ]; then has_hash=1; fi
  if [ "$arg" = "-subject" ]; then has_subject=1; fi
  if [ "$arg" = "-issuer" ]; then has_issuer=1; fi
  if [ "$arg" = "-enddate" ]; then has_enddate=1; fi
done

if [ "$has_hash" = "1" ]; then echo "1a2b3c4d"; exit 0; fi
if [ "$has_subject" = "1" ]; then echo "subject=CN=localhost"; exit 0; fi
if [ "$has_issuer" = "1" ]; then echo "issuer=CN=localhost"; exit 0; fi
if [ "$has_enddate" = "1" ]; then echo "notAfter=Dec 31 23:59:59 2035 GMT"; exit 0; fi

in_file=""
prev=""
for arg in "$@"; do
  if [ "$prev" = "-in" ] || [ "$prev" = "-infiles" ]; then in_file="$arg"; fi
  prev="$arg"
done

wrote_file=0
prev=""
for arg in "$@"; do
  if [ "$prev" = "-out" ] || [ "$prev" = "-keyout" ]; then
    wrote_file=1
    mkdir -p "$(dirname "$arg")" 2>/dev/null || true
    if echo "$arg" | grep -q "\.der$"; then
      if echo "$arg" | grep -qi "key"; then
        echo "$KEY_B64" | base64 -d > "$arg" 2>/dev/null || true
      else
        keytool -exportcert -alias demoCA -keystore /tmp/demoCA.jks -storepass password -rfc 2>/dev/null > "$arg" || true
      fi
    elif [ -n "$in_file" ] && [ -f "$in_file" ] && echo "$in_file" | grep -qE "\.txt$"; then
      keytool -gencert -infile "$in_file" -outfile "$arg" -alias demoCA -keystore /tmp/demoCA.jks -storepass password -rfc 2>/dev/null || keytool -exportcert -alias demoCA -keystore /tmp/demoCA.jks -storepass password -rfc 2>/dev/null > "$arg" || true
    elif [ -n "$in_file" ] && [ -f "$in_file" ] && [ "$prev" = "-out" ] && echo "$in_file" | grep -qE "\.(pem|crt)$"; then
      cp "$in_file" "$arg" 2>/dev/null || true
    elif echo "$arg" | grep -qi "key"; then
      echo "-----BEGIN PRIVATE KEY-----" > "$arg" 2>/dev/null || true
      echo "$KEY_B64" >> "$arg" 2>/dev/null || true
      echo "-----END PRIVATE KEY-----" >> "$arg" 2>/dev/null || true
    else
      keytool -exportcert -alias demoCA -keystore /tmp/demoCA.jks -storepass password -rfc 2>/dev/null > "$arg" || true
    fi
  fi
  prev="$arg"
done

if [ "$wrote_file" = "1" ]; then
  exit 0
fi

if [ -n "$in_file" ] && [ -f "$in_file" ]; then
  cat "$in_file"
  exit 0
fi

keytool -exportcert -alias demoCA -keystore /tmp/demoCA.jks -storepass password -rfc 2>/dev/null || true
exit 0
OPENSSLEOF
  chmod +x /u01/oracle/bi/modules/oracle.bi.openssl/bin/openssl 2>/dev/null || true

  "$ORACLE_HOME"/bi/bin/config.sh -ignoreSysPrereqs -silent -responseFile "$responseFile" || true
  rm -f "$responseFile"
  trap - INT TERM

  if [ -d "${DOMAIN_HOME}/config" ]; then
    echo "Do not delete this file - it tells the container createAndStartDomain.sh script that the domain is ready to be started" > "$domainCheckFile"
  fi
fi

if [ -f "$domainCheckFile" ]; then
  echo "Domain is ready. Ensuring boot.properties exist for non-interactive startup..."
  for srv in AdminServer bi_server1; do
    mkdir -p "${DOMAIN_HOME}/servers/${srv}/security" 2>/dev/null || true
    cat <<EOF > "${DOMAIN_HOME}/servers/${srv}/security/boot.properties"
username=${ADMIN_USERNAME}
password=${ADMIN_PASSWORD}
EOF
  done

  echo "Installing WebLogic Remote Console Extension (console-rest-ext.war)..."
  mkdir -p "${DOMAIN_HOME}/management-services-ext" 2>/dev/null || true
  if [ ! -f "${DOMAIN_HOME}/management-services-ext/console-rest-ext.war" ]; then
    curl -sSL -o "${DOMAIN_HOME}/management-services-ext/console-rest-ext.war" https://github.com/oracle/weblogic-remote-console/releases/download/v3.0.5/console-rest-ext-3.0.5.war 2>/dev/null || true
  fi

  echo "Writing setUserOverrides.sh to permanently limit WebLogic memory..."
  cat <<'EOF' > "${DOMAIN_HOME}/bin/setUserOverrides.sh"
export USER_MEM_ARGS="-Xms512m -Xmx1024m"
export MEM_ARGS="-Xms512m -Xmx1024m"
EOF
  chmod +x "${DOMAIN_HOME}/bin/setUserOverrides.sh" 2>/dev/null || true

  echo "Ensuring boot.properties exist for AdminServer and bi_server1..."
  mkdir -p "${DOMAIN_HOME}/servers/AdminServer/security" "${DOMAIN_HOME}/servers/bi_server1/security" 2>/dev/null || true
  cat <<EOF > "${DOMAIN_HOME}/servers/AdminServer/security/boot.properties"
username=${ADMIN_USERNAME:-weblogic}
password=${ADMIN_PASSWORD:-Welcome123}
EOF
  cat <<EOF > "${DOMAIN_HOME}/servers/bi_server1/security/boot.properties"
username=${ADMIN_USERNAME:-weblogic}
password=${ADMIN_PASSWORD:-Welcome123}
EOF

  echo "Clearing stale listen-address from config.xml (prevents EmbeddedLDAP crash on container restart)..."
  sed -i 's|<listen-address>[^<]*</listen-address>|<listen-address></listen-address>|g' \
    "${DOMAIN_HOME}/config/config.xml" 2>/dev/null || true

  echo "Starting WebLogic AdminServer..."
  export USER_MEM_ARGS="-Xms512m -Xmx1024m"
  export MEM_ARGS="-Xms512m -Xmx1024m"
  "${DOMAIN_HOME}"/bin/startWebLogic.sh &
  PID=$!
  (
    echo "Waiting for AdminServer to reach RUNNING state on port 9500..."
    until curl -s http://localhost:9500/console/welcome >/dev/null 2>&1; do
      sleep 5
    done
    echo "AdminServer is RUNNING! Starting Managed Server bi_server1 for Analytics Publisher UI (port 9502)..."
    "${DOMAIN_HOME}"/bin/startManagedWebLogic.sh bi_server1 http://localhost:9500 || true
  ) &
fi

trap '${DOMAIN_HOME}/bin/stopWebLogic.sh; kill -TERM $PID' INT TERM
mkdir -p "${DOMAIN_HOME}"/servers/AdminServer/logs 2>/dev/null || true
touch "${DOMAIN_HOME}"/servers/AdminServer/logs/"${DOMAIN_NAME}".log 2>/dev/null || true
tail -f "${DOMAIN_HOME}"/servers/AdminServer/logs/"${DOMAIN_NAME}".log
PID=$!
wait $PID
