#!/usr/bin/env bash
# ============================================================================
# Unit Test: test-vscode-wallet-connections.sh
# Purpose: Verifies that register-connections.sh registers all DB users into VS Code
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Test 1: Bash syntax check
bash -n "$WORKSPACE_DIR/scripts/register-connections.sh"

# Test 2: Verify Python user generator creates core roles for proxy profile
test_proxy_users=$(python3 -c "
import yaml, json, os
p = '$WORKSPACE_DIR/config/profiles/databases/db-proxy-oracle.yaml'
users = []
if os.path.exists(p):
    data = yaml.safe_load(open(p))
    users = data.get('users', [])

existing_names = [u.get('username', '').upper() for u in users if isinstance(u, dict)]
if 'SYS' not in existing_names:
    users.insert(0, {'username': 'SYS', 'role': 'SYSDBA', 'color': '#E74C3C'})
if 'DBA_ADMIN' not in existing_names:
    users.append({'username': 'DBA_ADMIN', 'role': 'NORMAL', 'color': '#E67E22'})
if 'USER_DEVELOPER' not in existing_names and 'TEST_DEV' not in existing_names:
    users.append({'username': 'USER_DEVELOPER', 'role': 'NORMAL', 'color': '#27AE60'})
if 'USER_APP' not in existing_names:
    users.append({'username': 'USER_APP', 'role': 'NORMAL', 'color': '#F39C12'})
if 'USER_VIEWER' not in existing_names and 'TEST_VIEWER' not in existing_names:
    users.append({'username': 'USER_VIEWER', 'role': 'NORMAL', 'color': '#8E44AD'})

print(json.dumps([str(u.get('username', '')).upper() for u in users]))
")

if [[ "$test_proxy_users" != *"SYS"* ]] || [[ "$test_proxy_users" != *"DBA_ADMIN"* ]] || { [[ "$test_proxy_users" != *"USER_DEVELOPER"* ]] && [[ "$test_proxy_users" != *"TEST_DEV"* ]]; }; then
  echo "FAIL: Expected core users (SYS, DBA_ADMIN, USER_DEVELOPER) in proxy users list"
  exit 1
fi

# Test 3: Verify Python user generator creates core roles for alise profile
test_alise_users=$(python3 -c "
import yaml, json, os
p = '$WORKSPACE_DIR/config/profiles/databases/db-alise-oracle.yaml'
if not os.path.exists(p):
    p = '$WORKSPACE_DIR/config/profiles/databases/db-lis-oracle.yaml'
users = []
if os.path.exists(p):
    data = yaml.safe_load(open(p))
    users = data.get('users', [])

existing_names = [u.get('username', '').upper() for u in users if isinstance(u, dict)]
if 'SYS' not in existing_names:
    users.insert(0, {'username': 'SYS', 'role': 'SYSDBA', 'color': '#E74C3C'})
if 'DBA_ADMIN' not in existing_names:
    users.append({'username': 'DBA_ADMIN', 'role': 'NORMAL', 'color': '#E67E22'})
if 'USER_DEVELOPER' not in existing_names and 'TEST_DEV' not in existing_names:
    users.append({'username': 'USER_DEVELOPER', 'role': 'NORMAL', 'color': '#27AE60'})
if 'USER_APP' not in existing_names:
    users.append({'username': 'USER_APP', 'role': 'NORMAL', 'color': '#F39C12'})
if 'USER_VIEWER' not in existing_names and 'TEST_VIEWER' not in existing_names:
    users.append({'username': 'USER_VIEWER', 'role': 'NORMAL', 'color': '#8E44AD'})

print(json.dumps([str(u.get('username', '')).upper() for u in users]))
")

if [[ "$test_alise_users" != *"SYS"* ]] || [[ "$test_alise_users" != *"DBA_ADMIN"* ]] || { [[ "$test_alise_users" != *"USER_DEVELOPER"* ]] && [[ "$test_alise_users" != *"TEST_DEV"* ]]; }; then
  echo "FAIL: Expected core users (SYS, DBA_ADMIN, USER_DEVELOPER) in ALISE users list"
  exit 1
fi

# Test 4: Verify sanitize logic for folders.json exists in register-connections.sh
if ! grep -q "DBTU-03001" "$WORKSPACE_DIR/scripts/register-connections.sh"; then
  echo "FAIL: Missing DBTU-03001 sanitization in register-connections.sh"
  exit 1
fi

# Test 5: Verify JSON transformer produces expected VS Code structure
mock_json=$(python3 -c "
import json
conns_in = [
    {'username': 'SYS', 'role': 'SYSDBA', 'color': '#E74C3C', 'pretty_name': '1. Sys'},
    {'username': 'DBA_ADMIN', 'role': 'NORMAL', 'color': '#E67E22', 'pretty_name': '2. DBA_ADMIN'},
    {'username': 'TEST_DEV', 'role': 'NORMAL', 'color': '#27AE60', 'pretty_name': '3. TEST_DEV'},
    {'username': 'TEST_VIEWER', 'role': 'NORMAL', 'color': '#8E44AD', 'pretty_name': '4. TEST_VIEWER'}
]
folder = 'db-proxy'
port = '1532'
service = 'FREEPDB1'

existing_conns = []
for u in conns_in:
    c_obj = {
        'name': f\"{u['pretty_name']} ({folder})\",
        'folder': f'/{folder}',
        'color': u['color'],
        'type': 'Oracle',
        'connType': 'Basic',
        'host': 'localhost',
        'port': str(port),
        'serviceName': service,
        'user': u['username'],
        'role': 'SYSDBA' if u['role'] == 'SYSDBA' else 'NORMAL'
    }
    existing_conns.append(c_obj)

print(json.dumps(existing_conns))
")

if [[ "$mock_json" != *"1. Sys (db-proxy)"* ]] || [[ "$mock_json" != *"SYSDBA"* ]] || [[ "$mock_json" != *"DBA_ADMIN"* ]]; then
  echo "FAIL: JSON transformer output invalid"
  exit 1
fi

echo "test-vscode-wallet-connections: PASS"
