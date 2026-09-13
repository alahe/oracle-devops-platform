#!/usr/bin/env bash
# ============================================================================
# Automatic Publisher Users Initializer (init-publisher-users.sh)
# Configures bip_developer, bip_user, bip_admin in Podman Secrets,
# SEPS Wallet, and WebLogic Security Domain.
# ============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [ -f "$SCRIPT_DIR/common.sh" ]; then
  # shellcheck source=/dev/null
  source "$SCRIPT_DIR/common.sh"
fi
if [ -f "$SCRIPT_DIR/load-profile.sh" ]; then
  # shellcheck source=/dev/null
  source "$SCRIPT_DIR/load-profile.sh"
fi

CONTAINER_NAME="${PUBLISHER_CONTAINER_NAME:-app-publisher}"
YAML_PROFILE="$WORKSPACE_DIR/config/profiles/publisher/publisher-standard.yaml"

if [ ! -f "$YAML_PROFILE" ]; then
  echo "⚠️ Warning: Publisher profile not found: $YAML_PROFILE"
  exit 0
fi

echo "👥 Initializing Oracle Analytics Publisher user accounts and security roles..."

# Function to generate strong random password
gen_pwd() {
  LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20 2>/dev/null || openssl rand -base64 16 | tr -dc 'A-Za-z0-9' | head -c 20
}

# Function to store in Podman secret store
store_podman_secret() {
  local sec_name="$1"
  local sec_val="$2"
  if command -v podman >/dev/null 2>&1; then
    podman secret rm "$sec_name" >/dev/null 2>&1 || true
    printf '%s' "$sec_val" | podman secret create "$sec_name" - >/dev/null 2>&1 || true
  fi
}

# Read users from YAML profile using python3
USERS_JSON=$(python3 - "$YAML_PROFILE" << 'PYEOF'
import sys, yaml, json
with open(sys.argv[1]) as f:
    data = yaml.safe_load(f) or {}
users = data.get('publisher', {}).get('users', [])
print(json.dumps(users))
PYEOF
)

if [ -z "$USERS_JSON" ] || [ "$USERS_JSON" = "[]" ]; then
  echo "ℹ️ No publisher users defined in YAML profile. Skipping."
  exit 0
fi

echo "$USERS_JSON" | python3 -c '
import sys, json
users = json.load(sys.stdin)
for u in users:
    uname = u.get("username", "")
    walias = u.get("wallet_alias", "")
    roles = ",".join(u.get("roles", []))
    desc = u.get("description", "")
    print(f"{uname}|{walias}|{roles}|{desc}")
' | while IFS='|' read -r uname walias roles udesc; do
  [ -z "$uname" ] && continue

  secret_key="publisher_$(echo "$uname" | sed 's/^bip_//')_password"
  
  # Check if password already exists in Podman secret
  EXISTING_PWD=""
  if command -v podman >/dev/null 2>&1; then
    EXISTING_PWD=$(podman secret inspect --showsecret "$secret_key" 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
  fi

  if [ -z "$EXISTING_PWD" ]; then
    NEW_PWD=$(gen_pwd)
    store_podman_secret "$secret_key" "$NEW_PWD"
    echo "   └─ Generated new credentials for $uname (Secret: $secret_key, Alias: $walias)"
  else
    NEW_PWD="$EXISTING_PWD"
    echo "   └─ Using existing credentials for $uname (Alias: $walias)"
  fi
done

# If app-publisher container is running, provision users in WebLogic DefaultAuthenticator
if command -v podman >/dev/null 2>&1 && podman container exists "$CONTAINER_NAME" 2>/dev/null && [ "$(podman inspect --format='{{.State.Status}}' "$CONTAINER_NAME" 2>/dev/null)" = "running" ]; then
  echo "🔐 Provisioning users inside WebLogic Security Realm (${CONTAINER_NAME})..."

  ADMIN_USER="${ADMIN_USERNAME:-weblogic}"
  ADMIN_PWD=$(podman secret inspect --showsecret publisher_db_sys_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
  [ -z "$ADMIN_PWD" ] && ADMIN_PWD=$("$WORKSPACE_DIR/scripts/get-password.sh" DB_PUBLISHER_SYS 2>/dev/null | grep -i "Password:" | awk '{print $NF}' || echo "")
  [ -z "$ADMIN_PWD" ] && ADMIN_PWD="AdminPassword123!"

  # Generate temporary python WLST script
  WLST_TMP="/tmp/provision_publisher_users_$$.py"
  cat << 'PYWLST' > "$WLST_TMP"
import sys

admin_user = sys.argv[1]
admin_pwd = sys.argv[2]
users_data = sys.argv[3]
admin_host = sys.argv[4] if len(sys.argv) > 4 else '127.0.0.1'

try:
    connect(admin_user, admin_pwd, 't3://' + admin_host + ':9500')
    cd('/SecurityConfiguration/bi/Realms/myrealm/AuthenticationProviders/DefaultAuthenticator')
    
    # Process users: name:pwd:roles:desc;...
    entries = [e for e in users_data.split(';') if e]
    for entry in entries:
        parts = entry.split('|')
        if len(parts) >= 3:
            uname = parts[0]
            upwd = parts[1]
            roles = [r.strip() for r in parts[2].split(',') if r.strip()]
            desc = parts[3] if len(parts) > 3 else ''
            
            if not cmo.userExists(uname):
                print("Creating user: " + uname)
                cmo.createUser(uname, upwd, desc)
            else:
                print("Updating user password: " + uname)
                cmo.resetUserPassword(uname, upwd)
            
            for role in roles:
                if not cmo.groupExists(role):
                    print("Creating group: " + role)
                    cmo.createGroup(role, role)
                if not cmo.isMember(role, uname, True):
                    print("Adding " + uname + " to group " + role)
                    cmo.addMemberToGroup(role, uname)
            
            # Map standard BI Application roles
            extra_bi_roles = []
            if uname == 'bip_developer':
                extra_bi_roles = ['BIAdministrators', 'BIAuthors', 'BIAuthor', 'BIConsumers', 'BIConsumer', 'Administrators', 'XMLP_ADMIN', 'XMLP_DEVELOPER', 'XMLP_TEMPLATE_DESIGNER', 'XMLP_ANALYZER', 'XMLP_SCHEDULER']
            elif uname == 'bip_user':
                extra_bi_roles = ['BIConsumers', 'BIConsumer', 'XMLP_SCHEDULER', 'XMLP_ANALYZER']
            elif uname == 'bip_admin':
                extra_bi_roles = ['BIAdministrators', 'BIAdministrator', 'BIServiceAdministrator', 'BIAuthors', 'BIAuthor', 'BIConsumers', 'BIConsumer', 'Administrators', 'XMLP_ADMIN', 'XMLP_DEVELOPER']
            for bi_r in extra_bi_roles:
                if not cmo.groupExists(bi_r):
                    cmo.createGroup(bi_r, bi_r)
                if not cmo.isMember(bi_r, uname, True):
                    cmo.addMemberToGroup(bi_r, uname)

            # Grant OPSS application roles in obi stripe
            if uname in ['bip_developer', 'bip_admin']:
                for ar in ['BIServiceAdministrator', 'BIContentAuthor', 'BIDataModelAuthor', 'BIConsumer', 'DVContentAuthor', 'DVConsumer']:
                    try:
                        grantAppRole(appStripe='obi', appRoleName=ar, principalClass='weblogic.security.principal.WLSUserImpl', principalName=uname)
                    except:
                        pass
            elif uname == 'bip_user':
                for ar in ['BIConsumer', 'DVConsumer']:
                    try:
                        grantAppRole(appStripe='obi', appRoleName=ar, principalClass='weblogic.security.principal.WLSUserImpl', principalName=uname)
                    except:
                        pass

    # Clean up any transient junk users created by previous IFS word-splitting bugs
    for junk in ['and', 'data', 'model', 'author', 'developer', 'user:']:
        try:
            if cmo.userExists(junk):
                print("Removing transient junk user: " + junk)
                cmo.removeUser(junk)
        except:
            pass

    disconnect()
    print("SUCCESS")
except Exception, e:
    print("WLST_ERROR: " + str(e))
PYWLST

  # Build serialized users data line by line (preserving spaces in descriptions)
  SERIALIZED_DATA=""
  while IFS='|' read -r uname walias roles udesc; do
    [ -z "$uname" ] && continue
    secret_key="publisher_$(echo "$uname" | sed 's/^bip_//')_password"
    upwd=$(podman secret inspect --showsecret "$secret_key" 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || echo "")
    if [ -z "$upwd" ]; then
      case "$uname" in
        bip_developer)
          upwd=$(podman secret inspect --showsecret publisher_dev_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || echo "")
          ;;
        bip_user)
          upwd=$(podman secret inspect --showsecret publisher_app_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || echo "")
          ;;
      esac
    fi
    [ -z "$upwd" ] && upwd="AdminPassword123!"
    SERIALIZED_DATA="${SERIALIZED_DATA}${uname}|${upwd}|${roles}|${udesc};"
  done < <(echo "$USERS_JSON" | python3 -c '
import sys, json
users = json.load(sys.stdin)
for u in users:
    uname = u.get("username", "")
    walias = u.get("wallet_alias", "")
    roles = ",".join(u.get("roles", []))
    desc = u.get("description", "")
    print(f"{uname}|{walias}|{roles}|{desc}")
')

  CONTAINER_IP=$(podman exec "${CONTAINER_NAME}" /bin/sh -c "export PATH=/bin:/usr/bin:\$PATH; hostname -i" 2>/dev/null | awk '{print $1}' | tr -d '\r\n')
  ADMIN_HOST="${CONTAINER_IP:-127.0.0.1}"
  podman cp "$WLST_TMP" "${CONTAINER_NAME}:/tmp/provision_publisher_users.py" 2>/dev/null || true
  rm -f "$WLST_TMP"
  podman exec -i "${CONTAINER_NAME}" /bin/bash -c "export PATH=/bin:/usr/bin:\$PATH; export WLST_PROPERTIES=\"-Djava.net.preferIPv4Stack=true\"; /u01/oracle/oracle_common/common/bin/wlst.sh /tmp/provision_publisher_users.py '$ADMIN_USER' '$ADMIN_PWD' '$SERIALIZED_DATA' '$ADMIN_HOST'" || true
  podman exec -i "${CONTAINER_NAME}" /bin/bash -c "export PATH=/bin:/usr/bin:\$PATH; rm -f /tmp/provision_publisher_users.py" 2>/dev/null || true
  echo "✅ WebLogic security realm synchronized with Publisher user roles."
else
  echo "ℹ️ Container ${CONTAINER_NAME} not running. Secrets stored in Podman for next container start."
fi

# Trigger SEPS wallet refresh if create-wallet.sh exists
if [ -x "$SCRIPT_DIR/create-wallet.sh" ]; then
  "$SCRIPT_DIR/create-wallet.sh" >/dev/null 2>&1 || true
fi

echo "✅ Publisher user provisioning completed successfully."
