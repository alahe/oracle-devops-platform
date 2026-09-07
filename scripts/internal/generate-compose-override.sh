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
if [ -f "$SCRIPT_DIR/load-profile.sh" ]; then
  source "$SCRIPT_DIR/load-profile.sh"
  resolve_active_blueprint
fi

ENV_PATH="$WORKSPACE_DIR/.env"
COMPOSE_FILE="$WORKSPACE_DIR/podman-compose.yml"
OVERRIDE_FILE="$WORKSPACE_DIR/podman-compose.override.yml"

# Verify that required Podman secrets are registered
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
    "$SCRIPT_DIR/generate-passwords.sh"
  fi
fi

# Dynamically generate podman-compose.override.yml for profiles and additional databases
cat <<EOF > "$OVERRIDE_FILE"
version: '3.8'

EOF

active_instances=($(get_active_db_instances 2>/dev/null))
if command -v podman >/dev/null 2>&1; then
  for live_c in $(podman ps --format '{{.Names}}' 2>/dev/null | grep -E '^(db-.*|oracle-db-.*)$'); do
    already=false
    for inst in "${active_instances[@]}"; do
      if [ "$(echo "$inst" | cut -d'|' -f1)" = "$live_c" ]; then
        already=true
        break
      fi
    done
    if [ "$already" = "false" ]; then
      live_prof=$(find "$WORKSPACE_DIR/config/profiles/databases" -name "${live_c}.yaml" -o -name "${live_c}-oracle.yaml" 2>/dev/null | head -n 1)
      if [ -n "$live_prof" ]; then
        live_prof_id=$(basename "$live_prof" .yaml)
      else
        live_prof_id="db-oracle"
      fi
      live_key="DB_$(echo "${live_c#db-}" | tr '-' '_' | tr '[:lower:]' '[:upper:]')"
      active_instances+=("${live_c}|${live_prof_id}|${live_key}")
    fi
  done
fi
if [ "${#active_instances[@]}" -gt 0 ] || is_ords_enabled; then
  echo "services:" >> "$OVERRIDE_FILE"
else
  echo "services: {}" >> "$OVERRIDE_FILE"
fi
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
      - "${c_port}:${c_in_port}"
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
        - (in_sql=\$\$(ls -d /opt/oracle/product/*/dbhomeFree/sqlcl/bin/sql 2>/dev/null | head -n 1); [ -n "\$\$in_sql" ] && printf "SELECT 'ALIVE' FROM DUAL;\nEXIT;\n" | "\$\$in_sql" -s / as sysdba 2>/dev/null | grep -q 'ALIVE') || (command -v sqlplus >/dev/null && printf "SELECT 'ALIVE' FROM DUAL;\nEXIT;\n" | sqlplus -s / as sysdba 2>/dev/null | grep -q 'ALIVE') || (timeout 1 bash -c "exec 3<>/dev/tcp/localhost/1521" 2>/dev/null) || exit 1
      interval: 10s
      timeout: 10s
      retries: 25
      start_period: 30s
    restart: unless-stopped

EOF
    fi

    ords_needed=false
    if is_ords_enabled && [ "${PROFILE_ORDS_ENABLED:-true}" = "true" ] && [ "${PROFILE_ORDS_CONTAINER_REQUIRED:-true}" != "false" ] && [ "$has_central_ords" != "true" ]; then
      ords_needed=true
    elif is_ords_running && [ "$has_central_ords" != "true" ]; then
      ords_needed=true
    fi

    if [ "$ords_needed" = "true" ]; then
      has_central_ords=true
      ords_mount_target="proxy"
      if [ ! -d "$WORKSPACE_DIR/config/ords/proxy" ] && [ -d "$WORKSPACE_DIR/config/ords/$db" ]; then
        ords_mount_target="$db"
      elif [ ! -d "$WORKSPACE_DIR/config/ords/proxy" ]; then
        ords_mount_target="$db"
      fi
      mkdir -p "$WORKSPACE_DIR/config/ords/$ords_mount_target"
      raw_svc_name="${PROFILE_ORDS_SERVICE_NAME:-app-ords}"
      raw_c_name="${PROFILE_ORDS_CONTAINER_NAME:-app-ords}"

      ords_svc_name=$(ensure_unique_name "$raw_svc_name" "ORDS service")
      ords_c_name=$(ensure_unique_name "$raw_c_name" "ORDS container")
      ords_ssl_val="$ORDS_SSL"
      ords_http_val="$ORDS_PORT"

      # Collect pools for all active databases and generate configuration directly to host directory
      ords_conf_dir="$WORKSPACE_DIR/config/ords/$ords_mount_target"
      mkdir -p "$ords_conf_dir/databases"
      rm -f "$ords_conf_dir/url-mapping.xml" 2>/dev/null || true

      first_pool_created=false
      first_pool_dir=""
      ords_depends_yaml=""

      for sub_item in "${active_instances[@]}"; do
        IFS='|' read -r s_cname s_prof s_key <<< "$sub_item"
        s_pfile="$WORKSPACE_DIR/config/profiles/databases/${s_prof}.yaml"
        [ ! -f "$s_pfile" ] && s_pfile="$WORKSPACE_DIR/config/profiles/${s_prof}.yaml"
        
        s_ords_en="true"
        s_pool_name=$(echo "$s_cname" | sed 's/^db-//' | tr '-' '_')
        s_service="FREEPDB1"
        s_in_port="1521"
        if [ -f "$s_pfile" ]; then
          s_ords_en=$(awk '/ords:/{flag=1;next}/forms:|apex:|publisher:|users:/{flag=0}flag' "$s_pfile" | grep -E '^[[:space:]]*enabled:' | head -n 1 | sed -E 's/.*:[[:space:]]*"?([^" #]+)"?.*/\1/' | tr -d '\r\n')
          s_pool_override=$(awk '/ords:/{flag=1;next}/forms:|apex:|publisher:|users:/{flag=0}flag' "$s_pfile" | grep -E '^[[:space:]]*pool_name:' | head -n 1 | sed -E 's/.*:[[:space:]]*"?([^" #]+)"?.*/\1/' | tr -d '\r\n')
          [ -n "$s_pool_override" ] && s_pool_name="$s_pool_override"
          s_svc_override=$(grep -E '^[[:space:]]*default_service:' "$s_pfile" | head -n 1 | sed -E 's/#.*//' | awk -F: '{print $2}' | tr -d ' "\r\n')
          [ -n "$s_svc_override" ] && s_service="$s_svc_override"
        fi

        if [ "$s_ords_en" = "true" ]; then
          ords_depends_yaml="${ords_depends_yaml}      ${s_cname}:\n        condition: service_healthy\n"
          current_ords_pwd=""
          if command -v podman &>/dev/null && podman secret exists "ords_listener_password" 2>/dev/null; then
            current_ords_pwd=$(podman secret inspect --showsecret ords_listener_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
          fi
          if [ -z "$current_ords_pwd" ] && [ -x "$SCRIPT_DIR/../get-password.sh" ]; then
            current_ords_pwd=$("$SCRIPT_DIR/../get-password.sh" ords_listener_password -p 2>/dev/null || echo "")
          fi
          [ -z "$current_ords_pwd" ] && current_ords_pwd="placeholder"

          mkdir -p "$ords_conf_dir/databases/${s_pool_name}"
          cat <<EOF_POOL > "$ords_conf_dir/databases/${s_pool_name}/pool.xml"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
<properties>
<entry key="db.connectionType">basic</entry>
<entry key="db.hostname">${s_cname}</entry>
<entry key="db.port">${s_in_port}</entry>
<entry key="db.servicename">${s_service}</entry>
<entry key="db.username">ORDS_PUBLIC_USER</entry>
<entry key="db.password">${current_ords_pwd}</entry>
<entry key="feature.sdw">true</entry>
<entry key="feature.apex">true</entry>
<entry key="plsql.gateway.mode">proxied</entry>
<entry key="restEnabledSql.active">true</entry>
</properties>
EOF_POOL
          if [ "$first_pool_created" = "false" ]; then
            first_pool_created=true
            first_pool_dir="${s_pool_name}"
          fi
        fi
      done

      if [ "$first_pool_created" = "true" ]; then
        mkdir -p "$ords_conf_dir/databases/default"
        if [ -f "$ords_conf_dir/databases/proxy/pool.xml" ]; then
          cp "$ords_conf_dir/databases/proxy/pool.xml" "$ords_conf_dir/databases/default/pool.xml" 2>/dev/null || true
        else
          cp "$ords_conf_dir/databases/${first_pool_dir}/pool.xml" "$ords_conf_dir/databases/default/pool.xml" 2>/dev/null || true
        fi
      fi

      # Clean up obsolete database pool directories to prevent ORDS UnknownHostException
      valid_pools=" default proxy "
      for sub_item in "${active_instances[@]}"; do
        IFS='|' read -r s_cname s_prof s_key <<< "$sub_item"
        s_pname=$(echo "$s_cname" | sed 's/^db-//' | tr '-' '_')
        s_pfile="$WORKSPACE_DIR/config/profiles/databases/${s_prof}.yaml"
        [ ! -f "$s_pfile" ] && s_pfile="$WORKSPACE_DIR/config/profiles/${s_prof}.yaml"
        if [ -f "$s_pfile" ]; then
          s_pool_override=$(awk '/ords:/{flag=1;next}/forms:|apex:|publisher:|users:/{flag=0}flag' "$s_pfile" | grep -E '^[[:space:]]*pool_name:' | head -n 1 | sed -E 's/.*:[[:space:]]*"?([^" #]+)"?.*/\1/' | tr -d '\r\n')
          [ -n "$s_pool_override" ] && s_pname="$s_pool_override"
        fi
        valid_pools="${valid_pools}${s_pname} "
      done
      if command -v podman >/dev/null 2>&1; then
        for live_c in $(podman ps --format '{{.Names}}' 2>/dev/null | grep -E '^(db-.*|oracle-db-.*)$'); do
          valid_pools="${valid_pools}$(echo "$live_c" | sed 's/^db-//' | sed 's/^oracle-db-//' | tr '-' '_') "
        done
      fi
      for d in "$ords_conf_dir/databases"/*; do
        [ -d "$d" ] || continue
        pname=$(basename "$d")
        if [[ ! " $valid_pools " =~ " $pname " ]]; then
          rm -rf "$d"
        fi
      done

      cat <<EOF >> "$OVERRIDE_FILE"
  ${ords_svc_name}:
    image: ${PROFILE_ORDS_CONTAINER_IMAGE:-container-registry.oracle.com/database/ords:latest}
    container_name: ${ords_c_name}
    ports:
      - "${ords_http_val}:${ords_http_val}"
      - "${ords_ssl_val}:${ords_ssl_val}"
    entrypoint:
      - /bin/bash
      - -c
      - |
        export ORACLE_PWD=\$\$(cat /run/secrets/oracle_pwd 2>/dev/null || cat /run/secrets/${sys_secret_name})
        export APEX_LISTENER_PWD=\$\$(cat /run/secrets/ords_listener_password 2>/dev/null || cat /run/secrets/apex_schema_password 2>/dev/null || cat /run/secrets/oracle_pwd)
        export APEX_REST_PWD=\$\$(cat /run/secrets/ords_listener_password 2>/dev/null || cat /run/secrets/apex_schema_password 2>/dev/null || cat /run/secrets/oracle_pwd)
        mkdir -p /etc/ords/config/ssl /opt/oracle/docroot
        if [ -f /etc/ords/certs/custom/tls.crt ] && [ -f /etc/ords/certs/custom/tls.key ]; then
          cp /etc/ords/certs/custom/tls.crt /etc/ords/config/ssl/cert.crt 2>/dev/null || true
          [ -f /etc/ords/certs/custom/tls.der ] && cp /etc/ords/certs/custom/tls.der /etc/ords/config/ssl/key.der 2>/dev/null || cp /etc/ords/certs/custom/tls.key /etc/ords/config/ssl/key.key 2>/dev/null || true
        elif [ -f /etc/ords/certs/public/public_cert.crt ] && [ -f /etc/ords/certs/public/public_key.key ]; then
          cp /etc/ords/certs/public/public_cert.crt /etc/ords/config/ssl/cert.crt 2>/dev/null || true
          [ -f /etc/ords/certs/public/public_key.der ] && cp /etc/ords/certs/public/public_key.der /etc/ords/config/ssl/key.der 2>/dev/null || cp /etc/ords/certs/public/public_key.key /etc/ords/config/ssl/key.key 2>/dev/null || true
        elif [ -f /etc/ords/certs/corp/corp_cert.crt ] && [ -f /etc/ords/certs/corp/corp_key.key ]; then
          cp /etc/ords/certs/corp/corp_cert.crt /etc/ords/config/ssl/cert.crt 2>/dev/null || true
          [ -f /etc/ords/certs/corp/corp_key.der ] && cp /etc/ords/certs/corp/corp_key.der /etc/ords/config/ssl/key.der 2>/dev/null || cp /etc/ords/certs/corp/corp_key.key /etc/ords/config/ssl/key.key 2>/dev/null || true
        elif [ -f /etc/ords/certs/localhost.crt ] && [ -f /etc/ords/certs/localhost.key ]; then
          [ -f /etc/ords/certs/localhost-fullchain.crt ] && cp /etc/ords/certs/localhost-fullchain.crt /etc/ords/config/ssl/cert.crt 2>/dev/null || cp /etc/ords/certs/localhost.crt /etc/ords/config/ssl/cert.crt 2>/dev/null || true
          [ -f /etc/ords/certs/localhost.der ] && cp /etc/ords/certs/localhost.der /etc/ords/config/ssl/key.der 2>/dev/null || cp /etc/ords/certs/localhost.key /etc/ords/config/ssl/key.key 2>/dev/null || true
        elif [ -f /etc/ords/certs/user_ca/localhost.crt ] && [ -f /etc/ords/certs/user_ca/localhost.key ]; then
          cp /etc/ords/certs/user_ca/localhost.crt /etc/ords/config/ssl/cert.crt 2>/dev/null || true
          [ -f /etc/ords/certs/user_ca/localhost.der ] && cp /etc/ords/certs/user_ca/localhost.der /etc/ords/config/ssl/key.der 2>/dev/null || cp /etc/ords/certs/user_ca/localhost.key /etc/ords/config/ssl/key.key 2>/dev/null || true
        elif [ -f /etc/ords/certs/self_signed/self_signed.crt ] && [ -f /etc/ords/certs/self_signed/self_signed.key ]; then
          cp /etc/ords/certs/self_signed/self_signed.crt /etc/ords/config/ssl/cert.crt 2>/dev/null || true
          [ -f /etc/ords/certs/self_signed/self_signed.der ] && cp /etc/ords/certs/self_signed/self_signed.der /etc/ords/config/ssl/key.der 2>/dev/null || cp /etc/ords/certs/self_signed/self_signed.key /etc/ords/config/ssl/key.key 2>/dev/null || true
        fi
        rm -rf /etc/ords/config/databases/*/wallet /etc/ords/config/databases/*/*/wallet 2>/dev/null || true
        if [ -f /run/secrets/ords_listener_password ]; then
          APEX_LISTENER_PWD=\$(cat /run/secrets/ords_listener_password | tr -d '\r\n')
          if [ -n "\$APEX_LISTENER_PWD" ]; then
            find /etc/ords/config/databases/ -name "pool.xml" -exec sed -i "s|<entry key=\"db.password\">.*</entry>|<entry key=\"db.password\">\$APEX_LISTENER_PWD</entry>|g" {} + 2>/dev/null || true
          fi
        fi
        mkdir -p /etc/ords/config/global
        SSL_ENTRIES=""
        if [ -f /etc/ords/config/ssl/cert.crt ] && [ -f /etc/ords/config/ssl/key.der ]; then
          SSL_ENTRIES='<entry key="standalone.https.cert">/etc/ords/config/ssl/cert.crt</entry><entry key="standalone.https.cert.key">/etc/ords/config/ssl/key.der</entry>'
        elif [ -f /etc/ords/config/ssl/cert.crt ] && [ -f /etc/ords/config/ssl/key.key ]; then
          SSL_ENTRIES='<entry key="standalone.https.cert">/etc/ords/config/ssl/cert.crt</entry><entry key="standalone.https.cert.key">/etc/ords/config/ssl/key.key</entry>'
        fi
        printf '%s\n' '<?xml version="1.0" encoding="UTF-8"?>' '<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">' '<properties>' '<entry key="database.api.enabled">true</entry>' '<entry key="feature.sdw">true</entry>' '<entry key="restEnabledSql.active">true</entry>' '<entry key="standalone.doc.root">/opt/oracle/docroot</entry>' "<entry key=\"standalone.http.port\">${ords_http_val}</entry>" "<entry key=\"standalone.https.port\">${ords_ssl_val}</entry>" '<entry key="standalone.static.context.path">/i</entry>' '<entry key="standalone.static.path">/opt/oracle/apex_images/images</entry>' "\$\$SSL_ENTRIES" '</properties>' > /etc/ords/config/global/settings.xml
        exec ords --config /etc/ords/config serve
    environment:
      - DBHOST=${c_name}
      - DBPORT=${c_in_port}
      - DBSERVICENAME=${c_service}
      - JAVA_TOOL_OPTIONS=-Xms512m -Xmx2048m -XX:+UseG1GC
      - _JAVA_OPTIONS=-Xms512m -Xmx2048m
    secrets:
      - source: ${sys_secret_name}
        target: oracle_pwd
      - ords_listener_password
EOF
      # Note: depends_on is intentionally omitted to prevent Podman from setting --requires,
      # which blocks independent container restarts, snapshot restores, and lifecycle operations.
      # Database readiness is orchestrated sequentially via wait-db-healthy.sh.
      cat <<EOF >> "$OVERRIDE_FILE"
    deploy:
      resources:
        limits:
          cpus: '1.00'
          memory: ${PROFILE_ORDS_MEMORY:-3072M}
    healthcheck:
      test:
        - CMD-SHELL
        - (curl -k -f -s -o /dev/null http://localhost:${ords_http_val}/ords/ || curl -k -f -s -o /dev/null https://localhost:${ords_ssl_val}/ords/ || timeout 1 bash -c "exec 3<>/dev/tcp/localhost/${ords_http_val}" 2>/dev/null) || exit 1
      interval: 10s
      timeout: 5s
      retries: 20
      start_period: 25s
    volumes:
      - ${apex_img_vol}:/opt/oracle/apex_images:ro
      - ./config/ords/$ords_mount_target:/etc/ords/config:rw
      - ./config/certs:/etc/ords/certs:ro
      - ./docs/dev-hub.html:/opt/oracle/docroot/index.html:ro
      - ./docs/dev-hub.html:/opt/oracle/docroot/dev-hub.html:ro
      - ./docs/dev-hub.html:/opt/oracle/docroot/hub.html:ro
      - ./docs:/opt/oracle/docroot/docs:ro
      - ./metrics:/opt/oracle/docroot/metrics:ro
      - ./config/blueprints:/opt/oracle/docroot/blueprints:ro
    restart: unless-stopped

EOF
    fi
done

if [ "${#active_instances[@]}" -eq 0 ] && is_ords_enabled; then
  ords_http_val="${ORDS_HTTP_PORT:-8088}"
  ords_ssl_val="${ORDS_HTTPS_PORT:-8448}"
  cat <<EOF >> "$OVERRIDE_FILE"
  app-ords:
    image: ${PROFILE_ORDS_CONTAINER_IMAGE:-container-registry.oracle.com/database/ords:latest}
    container_name: app-ords
    ports:
      - "${ords_http_val}:${ords_http_val}"
      - "${ords_ssl_val}:${ords_ssl_val}"
    entrypoint:
      - /bin/bash
      - -c
      - |
        mkdir -p /etc/ords/config/ssl /opt/oracle/docroot /etc/ords/config/global
        if [ -f /etc/ords/certs/custom/tls.crt ] && [ -f /etc/ords/certs/custom/tls.key ]; then
          cp /etc/ords/certs/custom/tls.crt /etc/ords/config/ssl/cert.crt 2>/dev/null || true
          [ -f /etc/ords/certs/custom/tls.der ] && cp /etc/ords/certs/custom/tls.der /etc/ords/config/ssl/key.der 2>/dev/null || cp /etc/ords/certs/custom/tls.key /etc/ords/config/ssl/key.key 2>/dev/null || true
        elif [ -f /etc/ords/certs/public/public_cert.crt ] && [ -f /etc/ords/certs/public/public_key.key ]; then
          cp /etc/ords/certs/public/public_cert.crt /etc/ords/config/ssl/cert.crt 2>/dev/null || true
          [ -f /etc/ords/certs/public/public_key.der ] && cp /etc/ords/certs/public/public_key.der /etc/ords/config/ssl/key.der 2>/dev/null || cp /etc/ords/certs/public/public_key.key /etc/ords/config/ssl/key.key 2>/dev/null || true
        elif [ -f /etc/ords/certs/corp/corp_cert.crt ] && [ -f /etc/ords/certs/corp/corp_key.key ]; then
          cp /etc/ords/certs/corp/corp_cert.crt /etc/ords/config/ssl/cert.crt 2>/dev/null || true
          [ -f /etc/ords/certs/corp/corp_key.der ] && cp /etc/ords/certs/corp/corp_key.der /etc/ords/config/ssl/key.der 2>/dev/null || cp /etc/ords/certs/corp/corp_key.key /etc/ords/config/ssl/key.key 2>/dev/null || true
        elif [ -f /etc/ords/certs/localhost.crt ] && [ -f /etc/ords/certs/localhost.key ]; then
          [ -f /etc/ords/certs/localhost-fullchain.crt ] && cp /etc/ords/certs/localhost-fullchain.crt /etc/ords/config/ssl/cert.crt 2>/dev/null || cp /etc/ords/certs/localhost.crt /etc/ords/config/ssl/cert.crt 2>/dev/null || true
          [ -f /etc/ords/certs/localhost.der ] && cp /etc/ords/certs/localhost.der /etc/ords/config/ssl/key.der 2>/dev/null || cp /etc/ords/certs/localhost.key /etc/ords/config/ssl/key.key 2>/dev/null || true
        elif [ -f /etc/ords/certs/user_ca/localhost.crt ] && [ -f /etc/ords/certs/user_ca/localhost.key ]; then
          cp /etc/ords/certs/user_ca/localhost.crt /etc/ords/config/ssl/cert.crt 2>/dev/null || true
          [ -f /etc/ords/certs/user_ca/localhost.der ] && cp /etc/ords/certs/user_ca/localhost.der /etc/ords/config/ssl/key.der 2>/dev/null || cp /etc/ords/certs/user_ca/localhost.key /etc/ords/config/ssl/key.key 2>/dev/null || true
        elif [ -f /etc/ords/certs/self_signed/self_signed.crt ] && [ -f /etc/ords/certs/self_signed/self_signed.key ]; then
          cp /etc/ords/certs/self_signed/self_signed.crt /etc/ords/config/ssl/cert.crt 2>/dev/null || true
          [ -f /etc/ords/certs/self_signed/self_signed.der ] && cp /etc/ords/certs/self_signed/self_signed.der /etc/ords/config/ssl/key.der 2>/dev/null || cp /etc/ords/certs/self_signed/self_signed.key /etc/ords/config/ssl/key.key 2>/dev/null || true
        fi
        SSL_ENTRIES=""
        if [ -f /etc/ords/config/ssl/cert.crt ] && [ -f /etc/ords/config/ssl/key.der ]; then
          SSL_ENTRIES='<entry key="standalone.https.cert">/etc/ords/config/ssl/cert.crt</entry><entry key="standalone.https.cert.key">/etc/ords/config/ssl/key.der</entry>'
        elif [ -f /etc/ords/config/ssl/cert.crt ] && [ -f /etc/ords/config/ssl/key.key ]; then
          SSL_ENTRIES='<entry key="standalone.https.cert">/etc/ords/config/ssl/cert.crt</entry><entry key="standalone.https.cert.key">/etc/ords/config/ssl/key.key</entry>'
        fi
        printf '%s\n' '<?xml version="1.0" encoding="UTF-8"?>' '<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">' '<properties>' '<entry key="database.api.enabled">true</entry>' '<entry key="feature.sdw">true</entry>' '<entry key="restEnabledSql.active">true</entry>' '<entry key="standalone.doc.root">/opt/oracle/docroot</entry>' "<entry key=\"standalone.http.port\">${ords_http_val}</entry>" "<entry key=\"standalone.https.port\">${ords_ssl_val}</entry>" "\$\$SSL_ENTRIES" '</properties>' > /etc/ords/config/global/settings.xml
        exec ords --config /etc/ords/config serve
    deploy:
      resources:
        limits:
          cpus: '1.00'
          memory: 1024M
    healthcheck:
      test:
        - CMD-SHELL
        - (curl -k -f -s -o /dev/null http://localhost:${ords_http_val}/ords/ || curl -k -f -s -o /dev/null https://localhost:${ords_ssl_val}/ords/ || timeout 1 bash -c "exec 3<>/dev/tcp/localhost/${ords_http_val}" 2>/dev/null) || exit 1
      interval: 10s
      timeout: 5s
      retries: 20
      start_period: 25s
    volumes:
      - ./config/ords/standalone:/etc/ords/config:rw
      - ./config/certs:/etc/ords/certs:ro
      - ./docs/dev-hub.html:/opt/oracle/docroot/index.html:ro
      - ./docs/dev-hub.html:/opt/oracle/docroot/dev-hub.html:ro
      - ./docs/dev-hub.html:/opt/oracle/docroot/hub.html:ro
      - ./docs:/opt/oracle/docroot/docs:ro
      - ./metrics:/opt/oracle/docroot/metrics:ro
      - ./config/blueprints:/opt/oracle/docroot/blueprints:ro
    restart: unless-stopped

EOF
fi

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

echo "   $(msg_str "COMPOSE_GEN_SUCCESS")"
