#!/usr/bin/env bash
# ============================================================================
# Dynamic Podman Compose Override & Secrets Generator
# Generates podman-compose.override.yml based on active profiles in .env
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source central common helper and profile loader
[ -f "$SCRIPT_DIR/common.sh" ] && source "$SCRIPT_DIR/common.sh"
[ -f "$SCRIPT_DIR/load-profile.sh" ] && source "$SCRIPT_DIR/load-profile.sh"

ENV_PATH="$WORKSPACE_DIR/.env"
COMPOSE_FILE="$WORKSPACE_DIR/podman-compose.yml"
OVERRIDE_FILE="$WORKSPACE_DIR/podman-compose.override.yml"

# Kontrollime, kas vajalikud Podman saladused on registreeritud
SECRETS_EXIST=true
if [ -f "$ENV_PATH" ]; then
  for secret in $(get_required_secret_names 2>/dev/null || echo "apex_db_sys_password publisher_db_sys_password apex_schema_password test_dev_password"); do
    if ! podman secret exists "$secret" 2>/dev/null; then
      SECRETS_EXIST=false
      break
    fi
  done
else
  SECRETS_EXIST=false
fi

if [ "$SECRETS_EXIST" = "false" ]; then
  if [ -x "$SCRIPT_DIR/generate-passwords.sh" ]; then
    "$SCRIPT_DIR/generate-passwords.sh" --force
  fi
fi

# Genereerime dünaamiliselt podman-compose.override.yml profiili ja lisabaaside jaoks
rm -f "$OVERRIDE_FILE"
echo "   ℹ️  Genereerin profiilipõhise podman-compose.override.yml..."
cat <<EOF > "$OVERRIDE_FILE"
version: '3.8'

services:
EOF

active_instances=($(get_active_db_instances 2>/dev/null))
has_central_ords=false

for item in "${active_instances[@]}"; do
  IFS='|' read -r c_name prof key <<< "$item"
  db=$(echo "$c_name" | sed 's/^db-//' | tr '-' '_')
  load_db_profile "$prof" >/dev/null 2>&1 || true

    PORT_VAR="${key}_PORT"
    c_port="${!PORT_VAR:-${PROFILE_DB_PORT:-1532}}"

    SERVICE_VAR="${key}_SERVICE"
    c_service="${!SERVICE_VAR:-${PROFILE_DEFAULT_SERVICE:-FREEPDB1}}"

    IMAGE_VAR="${key}_IMAGE"
    c_image="${!IMAGE_VAR:-${RESOLVED_DB_IMAGE:-container-registry.oracle.com/database/free:latest}}"

    c_sid="${PROFILE_DB_SID:-FREE}"
    c_in_port="${PROFILE_CONTAINER_PORT:-1521}"

    ORDS_PORT="${PROFILE_ORDS_HTTP_PORT:-8088}"
    ORDS_SSL="${PROFILE_ORDS_HTTPS_PORT:-8448}"

    sys_secret_name="${db}_db_sys_password"

    cat <<EOF >> "$OVERRIDE_FILE"
  ${c_name}:
    image: ${c_image}
    container_name: ${c_name}
    hostname: ${c_name}
    shm_size: 2g
    security_opt:
      - "no-new-privileges:true"
    ports:
      - "127.0.0.1:${c_port}:${c_in_port}"
EOF

    apex_ver_slug=$(echo "${PROFILE_APEX_VERSION:-24.1}" | tr '.' '_')
    apex_img_vol="apex_images_${apex_ver_slug}"

    if [ "$IS_ADB" = "true" ] && [[ "$c_image" == *"adb-free"* ]]; then
      adb_admin_pwd=$(podman secret inspect --showsecret "$sys_secret_name" 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || echo "")
      adb_wallet_pwd=$(podman secret inspect --showsecret apex_schema_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || echo "")

      cat <<EOF >> "$OVERRIDE_FILE"
    environment:
      - WORKLOAD_TYPE=${PROFILE_WORKLOAD_TYPE:-ATP}
      - ADMIN_PASSWORD=$adb_admin_pwd
      - WALLET_PASSWORD=$adb_wallet_pwd
    healthcheck:
      test:
        - CMD-SHELL
        - tnsping localhost:${PROFILE_CONTAINER_PORT:-1522} || curl -s -k -I https://localhost:${PROFILE_ORDS_HTTPS_PORT:-8443}/ords/ || exit 1
      interval: 15s
      timeout: 10s
      retries: 20
      start_period: 45s
EOF
      if [ -f "$WORKSPACE_DIR/config/certs/localhost.crt" ] && [ -f "$WORKSPACE_DIR/config/certs/localhost.key" ]; then
        cat <<EOF >> "$OVERRIDE_FILE"
    volumes:
      - ./config/certs/localhost.crt:/u01/ords/self-signed.crt:ro
      - ./config/certs/localhost.key:/u01/ords/self-signed.key:ro
EOF
      fi
    else
      cat <<EOF >> "$OVERRIDE_FILE"
    environment:
      - ORACLE_PASSWORD_FILE=/run/secrets/oracle_pwd
      - ORACLE_SID=${c_sid}
      - ORACLE_PDB=${c_service}
      - TNS_ADMIN=/opt/oracle/admin/${c_sid}/wallet
      - CONFIGURE_TDE=${CONFIGURE_TDE:-true}
      - ENCRYPT_TABLESPACES=${ENCRYPT_TABLESPACES:-ALL}
    volumes:
      - ${db}_oradata:/opt/oracle/oradata
      - ./config/tns_admin:/opt/oracle/admin/${c_sid}/wallet:rw
      - ${apex_img_vol}:/opt/oracle/apex_images
    secrets:
      - source: ${sys_secret_name}
        target: oracle_pwd
    deploy:
      resources:
        limits:
          cpus: '2.00'
          memory: ${PROFILE_DB_MEMORY:-3072M}
    healthcheck:
      test:
        - CMD-SHELL
        - (echo "SELECT 'ALIVE' FROM DUAL;" | sqlplus -L -S / as sysdba 2>/dev/null | grep -q 'ALIVE') || (echo "SELECT 'ALIVE' FROM DUAL;" | sqlplus -L -S sys/\`cat /run/secrets/oracle_pwd 2>/dev/null\`@localhost:1521/${c_service} as sysdba 2>/dev/null | grep -q 'ALIVE') || (nc -z localhost 1521 2>/dev/null) || exit 1
      interval: 10s
      timeout: 10s
      retries: 25
      start_period: 30s
    restart: unless-stopped

EOF
    fi

    if [ "${SKIP_ORDS:-false}" != "true" ] && [ "${PROFILE_ORDS_ENABLED:-true}" = "true" ] && [ "${PROFILE_ORDS_CONTAINER_REQUIRED:-true}" != "false" ] && [ "${PROFILE_ORDS_PREINSTALLED:-false}" != "true" ] && [ "$IS_ADB" != "true" ] && [ "$has_central_ords" != "true" ]; then
      has_central_ords=true
      mkdir -p "$WORKSPACE_DIR/config/ords/$db"
      raw_svc_name="${PROFILE_ORDS_SERVICE_NAME:-app-ords}"
      raw_c_name="${PROFILE_ORDS_CONTAINER_NAME:-app-ords}"

      ords_svc_name=$(ensure_unique_name "$raw_svc_name" "ORDS teenus")
      ords_c_name=$(ensure_unique_name "$raw_c_name" "ORDS konteiner")
      ords_ssl_val="$ORDS_SSL"
      ords_http_val="$ORDS_PORT"

      cat <<EOF >> "$OVERRIDE_FILE"
  ${ords_svc_name}:
    image: ${PROFILE_ORDS_CONTAINER_IMAGE:-container-registry.oracle.com/database/ords:latest}
    container_name: ${ords_c_name}
    ports:
      - "127.0.0.1:${ords_http_val}:${ords_http_val}"
      - "127.0.0.1:${ords_ssl_val}:${ords_ssl_val}"
    entrypoint:
      - /bin/bash
      - -c
      - |
        export ORACLE_PWD=\$\$(cat /run/secrets/oracle_pwd 2>/dev/null || cat /run/secrets/${sys_secret_name})
        export APEX_LISTENER_PWD=\$\$(cat /run/secrets/ords_listener_password 2>/dev/null || cat /run/secrets/apex_schema_password 2>/dev/null || cat /run/secrets/oracle_pwd)
        export APEX_REST_PWD=\$\$(cat /run/secrets/ords_listener_password 2>/dev/null || cat /run/secrets/apex_schema_password 2>/dev/null || cat /run/secrets/oracle_pwd)
        mkdir -p /etc/ords/config/ssl /etc/ords/config/databases/default
        if [ -f /etc/ords/certs/custom/tls.crt ] && [ -f /etc/ords/certs/custom/tls.key ]; then
          cp /etc/ords/certs/custom/tls.crt /etc/ords/config/ssl/cert.crt 2>/dev/null || true
          cp /etc/ords/certs/custom/tls.key /etc/ords/config/ssl/key.key 2>/dev/null || true
        elif [ -f /etc/ords/certs/public/public_cert.crt ] && [ -f /etc/ords/certs/public/public_key.key ]; then
          cp /etc/ords/certs/public/public_cert.crt /etc/ords/config/ssl/cert.crt 2>/dev/null || true
          cp /etc/ords/certs/public/public_key.key /etc/ords/config/ssl/key.key 2>/dev/null || true
        elif [ -f /etc/ords/certs/corp/corp_cert.crt ] && [ -f /etc/ords/certs/corp/corp_key.key ]; then
          cp /etc/ords/certs/corp/corp_cert.crt /etc/ords/config/ssl/cert.crt 2>/dev/null || true
          cp /etc/ords/certs/corp/corp_key.key /etc/ords/config/ssl/key.key 2>/dev/null || true
        elif [ -f /etc/ords/certs/user_ca/localhost.crt ] && [ -f /etc/ords/certs/user_ca/localhost.key ]; then
          cp /etc/ords/certs/user_ca/localhost.crt /etc/ords/config/ssl/cert.crt 2>/dev/null || true
          cp /etc/ords/certs/user_ca/localhost.key /etc/ords/config/ssl/key.key 2>/dev/null || true
        elif [ -f /etc/ords/certs/self_signed/self_signed.crt ] && [ -f /etc/ords/certs/self_signed/self_signed.key ]; then
          cp /etc/ords/certs/self_signed/self_signed.crt /etc/ords/config/ssl/cert.crt 2>/dev/null || true
          cp /etc/ords/certs/self_signed/self_signed.key /etc/ords/config/ssl/key.key 2>/dev/null || true
        else
          [ -f /etc/ords/certs/localhost.crt ] && cp /etc/ords/certs/localhost.crt /etc/ords/config/ssl/cert.crt 2>/dev/null || true
          [ -f /etc/ords/certs/localhost.key ] && cp /etc/ords/certs/localhost.key /etc/ords/config/ssl/key.key 2>/dev/null || true
        fi
        rm -rf /etc/ords/config/databases/*/wallet /etc/ords/config/databases/*/*/wallet 2>/dev/null || true
        if [ ! -f /etc/ords/config/databases/default/pool.xml ] || ! grep -q "db.hostname" /etc/ords/config/databases/default/pool.xml 2>/dev/null; then
          printf '%s\n' '<?xml version="1.0" encoding="UTF-8"?>' '<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">' '<properties>' '<entry key="db.connectionType">basic</entry>' '<entry key="db.hostname">${c_name}</entry>' '<entry key="db.port">${c_in_port}</entry>' '<entry key="db.servicename">${c_service}</entry>' '<entry key="db.username">ORDS_PUBLIC_USER</entry>' '<entry key="db.password">\$\$APEX_LISTENER_PWD</entry>' '<entry key="feature.sdw">true</entry>' '<entry key="plsql.gateway.mode">proxied</entry>' '<entry key="restEnabledSql.active">true</entry>' '</properties>' > /etc/ords/config/databases/default/pool.xml
        fi
        if [ -n "\$\$APEX_LISTENER_PWD" ]; then
          find /etc/ords/config/databases/ -name "pool.xml" -exec sed -i "s|<entry key=\"db.password\">.*</entry>|<entry key=\"db.password\">\$\$APEX_LISTENER_PWD</entry>|g" {} + 2>/dev/null || true
        fi
        ords --config /etc/ords/config config set standalone.http.port ${ords_http_val} 2>/dev/null || true
        ords --config /etc/ords/config config set standalone.https.port ${ords_ssl_val} 2>/dev/null || true
        ords --config /etc/ords/config config set standalone.static.path /opt/oracle/apex_images/images 2>/dev/null || true
        exec ords --config /etc/ords/config serve
    environment:
      - DBHOST=${c_name}
      - DBPORT=${c_in_port}
      - DBSERVICENAME=${c_service}
    secrets:
      - source: ${sys_secret_name}
        target: oracle_pwd
      - ords_listener_password
    depends_on:
      ${c_name}:
        condition: service_healthy
    deploy:
      resources:
        limits:
          cpus: '1.00'
          memory: ${PROFILE_ORDS_MEMORY:-1024M}
    volumes:
      - ${apex_img_vol}:/opt/oracle/apex_images:ro
      - ./config/ords/$db:/etc/ords/config:rw
      - ./config/certs:/etc/ords/certs:ro
    restart: unless-stopped

EOF
    fi
done

has_override_volumes=false
for item in "${active_instances[@]}"; do
  c_name=$(echo "$item" | cut -d'|' -f1)
  prof=$(echo "$item" | cut -d'|' -f2)
  db=$(echo "$c_name" | sed 's/^db-//' | tr '-' '_')
  load_db_profile "$prof" >/dev/null 2>&1 || true
  apex_ver_slug=$(echo "${PROFILE_APEX_VERSION:-24.1}" | tr '.' '_')
  if [ "$has_override_volumes" = "false" ]; then
    echo -e "\nvolumes:" >> "$OVERRIDE_FILE"
    has_override_volumes=true
  fi
  if ! grep -q "  ${db}_oradata:" "$OVERRIDE_FILE" 2>/dev/null; then
    echo "  ${db}_oradata:" >> "$OVERRIDE_FILE"
  fi
  if ! grep -q "  apex_images_${apex_ver_slug}:" "$OVERRIDE_FILE" 2>/dev/null; then
    echo "  apex_images_${apex_ver_slug}:" >> "$OVERRIDE_FILE"
  fi
done

cat <<EOF >> "$OVERRIDE_FILE"

secrets:
EOF
for item in "${active_instances[@]}"; do
  c_name=$(echo "$item" | cut -d'|' -f1)
  db=$(echo "$c_name" | sed 's/^db-//' | tr '-' '_')
  cat <<EOF >> "$OVERRIDE_FILE"
  ${db}_db_sys_password:
    external: true
EOF
done

cat <<EOF >> "$OVERRIDE_FILE"
  apex_db_sys_password:
    external: true
  ords_listener_password:
    external: true
EOF

echo "   ✅ podman-compose.override.yml edukalt genereeritud!"
