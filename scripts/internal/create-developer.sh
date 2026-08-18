#!/usr/bin/env bash
# ============================================================================
# APEX Developer Account Creator for PROXY_WORKSPACE
# Creates a developer account inside PROXY_WORKSPACE for local PC user.
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Laeme keskkonnamuutujad
if [ -f "$WORKSPACE_DIR/.env" ]; then
  set -a
  source "$WORKSPACE_DIR/.env"
  set +a
elif [ -f "$WORKSPACE_DIR/config/repository.env" ]; then
  set -a
  source "$WORKSPACE_DIR/config/repository.env"
  set +a
fi

if [ -f "$SCRIPT_DIR/load-db-profile.sh" ]; then
  source "$SCRIPT_DIR/load-db-profile.sh"
  load_db_profile >/dev/null 2>&1 || true
fi

# Andmebaasi ühenduse parameetrid
DB_HOST="${APEX_DB_HOST:-${PROFILE_DB_HOST:-localhost}}"
DB_PORT="${APEX_DB_PORT:-${PROFILE_DB_PORT:-1532}}"
DB_SERVICE="${APEX_DB_SERVICE:-${PROFILE_DEFAULT_SERVICE:-FREEPDB1}}"
PRIMARY_CONTAINER=$(get_active_db_instances 2>/dev/null | head -n 1 | cut -d'|' -f1)
PRIMARY_CONTAINER="${PRIMARY_CONTAINER:-db-dev-full}"
PRIMARY_UPPER=$(echo "$PRIMARY_CONTAINER" | tr '-' '_' | tr '[:lower:]' '[:upper:]')

SYS_PASSWORD="${APEX_DB_SYS_PASSWORD:-}"
if [ -z "$SYS_PASSWORD" ]; then
  SYS_PASSWORD=$("$SCRIPT_DIR/view-wallet-credential.sh" "DB_${PRIMARY_UPPER}_SYS" </dev/null 2>/dev/null | grep "Password:" | sed $'s/\x1b\\[[0-9;]*m//g' | cut -d':' -f2 | tr -d ' \r\t ')
fi
if [ -z "$SYS_PASSWORD" ]; then
  SYS_PASSWORD=$("$SCRIPT_DIR/view-wallet-credential.sh" DB_DB_DEV_FULL_SYS </dev/null 2>/dev/null | grep "Password:" | sed $'s/\x1b\\[[0-9;]*m//g' | cut -d':' -f2 | tr -d ' \r\t ')
fi
if [ -z "$SYS_PASSWORD" ]; then
  SYS_PASSWORD=$("$SCRIPT_DIR/view-wallet-credential.sh" DB_APEX_PROXY_SYS </dev/null 2>/dev/null | grep "Password:" | sed $'s/\x1b\\[[0-9;]*m//g' | cut -d':' -f2 | tr -d ' \r\t ')
fi
if [ -z "$SYS_PASSWORD" ]; then
  if [ -f "/run/secrets/apex_db_sys_password" ]; then
    SYS_PASSWORD=$(cat "/run/secrets/apex_db_sys_password")
  elif podman container exists "$PRIMARY_CONTAINER" 2>/dev/null && [ "$(podman inspect --format='{{.State.Status}}' "$PRIMARY_CONTAINER" 2>/dev/null)" = "running" ]; then
    SYS_PASSWORD=$(podman exec "$PRIMARY_CONTAINER" cat "/run/secrets/apex_db_sys_password" 2>/dev/null || podman exec "$PRIMARY_CONTAINER" cat "/run/secrets/oracle_pwd" 2>/dev/null || echo "")
  fi
fi

FORCE_MODE=false
for arg in "$@"; do
  if [ "$arg" = "--force" ] || [ "$arg" = "-y" ]; then
    FORCE_MODE=true
  fi
done

# Tuvastame jooksva PC kasutajanime keskkonnast ja muudame suurtähtedeks (APEX standard)
DEFAULT_DEV_USER=$(echo "${DEVELOPER_USER:-$USER}" | tr '[:lower:]' '[:upper:]')
if [ -z "$DEFAULT_DEV_USER" ]; then
  DEFAULT_DEV_USER="DEV_USER"
fi

echo "=================================================================="
echo "👤 APEX ARENDAJAKONTO LOOMISE UTILIIT"
echo "=================================================================="
if [ "$FORCE_MODE" = "true" ] || [ ! -t 0 ]; then
  DEV_USER="$DEFAULT_DEV_USER"
  echo "ℹ️  Automaatne režiim (--force): Kasutan kasutajanime '$DEV_USER'"
else
  read -p "❓ Sisesta APEX arendaja kasutajanimi [Vaikimisi: $DEFAULT_DEV_USER]: " DEV_USER
  DEV_USER=${DEV_USER:-$DEFAULT_DEV_USER}
fi

# Eemaldame tühikud
DEV_USER=$(echo "$DEV_USER" | tr -d ' ')


# Genereerime juhusliku tugeva parooli automaatselt (ilma küsimata)
RAND_PART=$(LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 12 2>/dev/null || openssl rand -hex 6)
DEV_PWD="Dev_${RAND_PART}_2026!"

# Määrame logi kausta ja faili
LOG_DIR="$WORKSPACE_DIR/install_logs"
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$LOG_DIR/create_developer_${DEV_USER}_${TIMESTAMP}.log"

echo "------------------------------------------------------------------"
echo "ℹ️  Loon kasutajat '$DEV_USER' tööruumi 'PROXY_WORKSPACE'..."
echo "ℹ️  Detailne paigalduslogi suunatakse faili: $LOG_FILE"

# Tuvastame SQLcl asukoha (eelistades VS Code laienduse sisest binääri parooli salvestamiseks)
SQLCL_BIN=""
VSCODE_SQLCL=$(find "$HOME/.vscode/extensions" -name "sql" -path "*/oracle.sql-developer-*/dbtools/sqlcl/bin/sql" 2>/dev/null | head -n 1)
if [ -n "$VSCODE_SQLCL" ]; then
  SQLCL_BIN="$VSCODE_SQLCL"
elif command -v sql &> /dev/null; then
  SQLCL_BIN="sql"
fi

run_sqlcl() {
  local LOCAL_BIN=""
  if [ -n "$SQLCL_BIN" ]; then
    LOCAL_BIN="$SQLCL_BIN"
  elif command -v sql &> /dev/null; then
    LOCAL_BIN="sql"
  elif command -v sqlplus &> /dev/null; then
    LOCAL_BIN="sqlplus"
  fi

  if [ -n "$LOCAL_BIN" ]; then
    "$LOCAL_BIN" "$@"
    return $?
  fi

  local RUN_IMAGE="${SQLCL_CONTAINER_IMAGE:-container-registry.oracle.com/database/sqlcl:latest}"
  podman run --rm -i --network=host "$RUN_IMAGE" "$@"
}

PRIMARY_CONTAINER=$(get_active_db_instances 2>/dev/null | head -n 1 | cut -d'|' -f1)
PRIMARY_CONTAINER="${PRIMARY_CONTAINER:-db-dev-full}"
PRIMARY_UPPER=$(echo "$PRIMARY_CONTAINER" | tr '-' '_' | tr '[:lower:]' '[:upper:]')

# Käivitame kasutaja loomise PL/SQL ploki, suunates kogu väljundi logifaili
set +e
if podman container exists "$PRIMARY_CONTAINER" 2>/dev/null && [ "$(podman inspect --format='{{.State.Status}}' "$PRIMARY_CONTAINER" 2>/dev/null)" = "running" ]; then
  podman exec -i "$PRIMARY_CONTAINER" sqlplus -s / as sysdba <<EOF > "$LOG_FILE" 2>&1
ALTER SESSION SET CONTAINER = FREEPDB1;
SET SERVEROUTPUT ON SIZE UNLIMITED;
-- 1. Loo/uuenda andmebaasi kasutaja (DB User) ja määra DB_DEVELOPER_ROLE
DECLARE
  v_user_exists NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_user_exists FROM dba_users WHERE username = '${DEV_USER}';
  IF v_user_exists = 0 THEN
    EXECUTE IMMEDIATE 'CREATE USER ${DEV_USER} IDENTIFIED BY "${DEV_PWD}"';
    DBMS_OUTPUT.PUT_LINE('✅ DB kasutaja ${DEV_USER} loodud.');
  ELSE
    EXECUTE IMMEDIATE 'ALTER USER ${DEV_USER} IDENTIFIED BY "${DEV_PWD}"';
    DBMS_OUTPUT.PUT_LINE('✅ DB kasutaja ${DEV_USER} parool uuendatud.');
  END IF;
  EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO ${DEV_USER}';
  EXECUTE IMMEDIATE 'GRANT DB_DEVELOPER_ROLE TO ${DEV_USER}';
  EXECUTE IMMEDIATE 'ALTER USER ${DEV_USER} DEFAULT TABLESPACE USERS TEMPORARY TABLESPACE TEMP QUOTA UNLIMITED ON USERS';
  DBMS_OUTPUT.PUT_LINE('✅ Roll DB_DEVELOPER_ROLE antud kasutajale ${DEV_USER}.');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('❌ Viga DB kasutaja loomisel: ' || SQLERRM);
END;
/

-- 2. Loo/uuenda APEX arendaja
DECLARE
  v_workspace_id NUMBER;
BEGIN
  v_workspace_id := APEX_UTIL.find_security_group_id('PROXY_WORKSPACE');
  IF v_workspace_id IS NULL OR v_workspace_id = 0 THEN
    DBMS_OUTPUT.PUT_LINE('❌ Viga: Tööruumi PROXY_WORKSPACE ei leitud! Kas APEX on paigaldatud?');
  ELSE
    APEX_UTIL.set_security_group_id(v_workspace_id);
    
    -- Eemaldame kasutaja kui see juba eksisteerib (et vältida unikaalsuse vigu)
    BEGIN
      APEX_UTIL.remove_user(p_user_name => '${DEV_USER}');
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
    
    -- Loo uus arendaja konto
    APEX_UTIL.create_user(
        p_user_name                    => '${DEV_USER}',
        p_email_address                => '${DEV_USER}@company.local',
        p_web_password                 => '${DEV_PWD}',
        p_developer_privs              => 'CREATE:DATA_LOADER:EDIT:HELP:MONITOR:VARIABLE',
        p_change_password_on_first_use => 'N'
    );
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✅ Arendaja kasutajakonto edukalt loodud!');
  END IF;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('❌ Viga APEX kasutaja loomisel: ' || SQLERRM);
END;
/
EXIT;
EOF
  STATUS=$?
else
  run_sqlcl -s /@DB_${PRIMARY_UPPER}_SYS as sysdba <<EOF > "$LOG_FILE" 2>&1
ALTER SESSION SET CONTAINER = FREEPDB1;
SET SERVEROUTPUT ON SIZE UNLIMITED;
-- 1. Loo/uuenda andmebaasi kasutaja (DB User) ja määra DB_DEVELOPER_ROLE
DECLARE
  v_user_exists NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_user_exists FROM dba_users WHERE username = '${DEV_USER}';
  IF v_user_exists = 0 THEN
    EXECUTE IMMEDIATE 'CREATE USER ${DEV_USER} IDENTIFIED BY "${DEV_PWD}"';
    DBMS_OUTPUT.PUT_LINE('✅ DB kasutaja ${DEV_USER} loodud.');
  ELSE
    EXECUTE IMMEDIATE 'ALTER USER ${DEV_USER} IDENTIFIED BY "${DEV_PWD}"';
    DBMS_OUTPUT.PUT_LINE('✅ DB kasutaja ${DEV_USER} parool uuendatud.');
  END IF;
  EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO ${DEV_USER}';
  EXECUTE IMMEDIATE 'GRANT DB_DEVELOPER_ROLE TO ${DEV_USER}';
  EXECUTE IMMEDIATE 'ALTER USER ${DEV_USER} DEFAULT TABLESPACE USERS TEMPORARY TABLESPACE TEMP QUOTA UNLIMITED ON USERS';
  DBMS_OUTPUT.PUT_LINE('✅ Roll DB_DEVELOPER_ROLE antud kasutajale ${DEV_USER}.');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('❌ Viga DB kasutaja loomisel: ' || SQLERRM);
END;
/

-- 2. Loo/uuenda APEX arendaja
DECLARE
  v_workspace_id NUMBER;
BEGIN
  v_workspace_id := APEX_UTIL.find_security_group_id('PROXY_WORKSPACE');
  IF v_workspace_id IS NULL OR v_workspace_id = 0 THEN
    DBMS_OUTPUT.PUT_LINE('❌ Viga: Tööruumi PROXY_WORKSPACE ei leitud! Kas APEX on paigaldatud?');
  ELSE
    APEX_UTIL.set_security_group_id(v_workspace_id);
    
    -- Eemaldame kasutaja kui see juba eksisteerib (et vältida unikaalsuse vigu)
    BEGIN
      APEX_UTIL.remove_user(p_user_name => '${DEV_USER}');
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
    
    -- Loo uus arendaja konto
    APEX_UTIL.create_user(
        p_user_name                    => '${DEV_USER}',
        p_email_address                => '${DEV_USER}@company.local',
        p_web_password                 => '${DEV_PWD}',
        p_developer_privs              => 'CREATE:DATA_LOADER:EDIT:HELP:MONITOR:VARIABLE',
        p_change_password_on_first_use => 'N'
    );
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✅ Arendaja kasutajakonto edukalt loodud!');
  END IF;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('❌ Viga APEX kasutaja loomisel: ' || SQLERRM);
END;
/
EXIT;
EOF
  STATUS=$?
fi
set -e

if [ $STATUS -eq 0 ] && grep -q "Arendaja kasutajakonto edukalt loodud!" "$LOG_FILE"; then
  # 1. Registreerime uue arendaja parooli Oracle Walletisse (SEPS)
  WALLET_PWD=$(cat "$WORKSPACE_DIR/config/secrets/wallet_password.txt" 2>/dev/null || echo "CustomWalletPass123!")
  if podman container exists "$PRIMARY_CONTAINER" 2>/dev/null && [ "$(podman inspect --format='{{.State.Status}}' "$PRIMARY_CONTAINER" 2>/dev/null)" = "running" ]; then
    podman exec -i "$PRIMARY_CONTAINER" sh -c "
WALLET_PATH=\"/opt/oracle/admin/FREE/wallet\"
echo \"$WALLET_PWD\" | mkstore -wrl \$WALLET_PATH -deleteCredential \"${DEV_USER}\" >/dev/null 2>&1 || true
echo \"$WALLET_PWD\" | mkstore -wrl \$WALLET_PATH -createCredential \"${DEV_USER}\" \"${DEV_USER}\" \"${DEV_PWD}\" >/dev/null 2>&1 || true
" >/dev/null 2>&1 || true
  fi

  # 2. Delegeerime registreerimise register-connections.sh skriptile
  export EXTRA_DEV_USER="${DEV_USER}"
  export EXTRA_DEV_PWD="${DEV_PWD}"
  export EXTRA_DEV_COLOR="${DEVELOPER_COLOR:-#F39C12}"


  echo "Registreerin ühendused VS Code SQL Developer laiendusele..."
  "$SCRIPT_DIR/register-connections.sh" >/dev/null 2>&1 || true

  echo "=================================================================="
  echo "🎉 KASUTAJAKONTO ON LOODUD!"
  echo "   Tööruum (Workspace): PROXY_WORKSPACE"
  echo "   Kasutajanimi:        $DEV_USER"
  echo "   Parool:              Salvestatud turvaliselt Oracle Walletisse (SEPS)"
  echo "   Parooli lugemine:    ./scripts/internal/view-wallet-credential.sh $DEV_USER"
  echo "   Sisselogimise URL:   https://localhost:8448/ords/apex"
  echo "   Logi asukoht:        $LOG_FILE"
  echo "   --------------------------------------------------------------"
  echo "   ✅ Ühendus registreeritud VS Code SQL Developer all!"
  echo "   👉 Ava/värskenda Oracle SQL Developer paneel VS Code-is ühenduse nägemiseks."
  echo "=================================================================="
else
  echo "❌ Viga: Kasutaja loomine ebaõnnestus."
  echo "👉 Vaata täpsemat logi failist: $LOG_FILE"
  if [ -f "$LOG_FILE" ]; then
    echo "------------------------------------------------------------------"
    grep -E "Viga:|ORA-" "$LOG_FILE" || head -n 10 "$LOG_FILE"
    echo "------------------------------------------------------------------"
  fi
fi

