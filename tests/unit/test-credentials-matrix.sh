#!/usr/bin/env bash
# ============================================================================
# Unit Test: Credential Matrix & Dynamic Service Target Resolution
# Validates deterministic naming, service mapping, and zero cross-db fallback
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "🔍 Testing Credential Helper functions..."

source "$WORKSPACE_DIR/scripts/internal/credential-helper.sh"

# 1. Test short and upper name extraction
if [ "$(get_db_short_name "db-proxy")" != "proxy" ]; then
  echo "❌ Error: get_db_short_name failed for db-proxy"
  exit 1
fi
if [ "$(get_db_upper_name "db-proxy")" != "PROXY" ]; then
  echo "❌ Error: get_db_upper_name failed for db-proxy"
  exit 1
fi
if [ "$(get_db_short_name "db-publisher")" != "publisher" ]; then
  echo "❌ Error: get_db_short_name failed for db-publisher"
  exit 1
fi
if [ "$(get_db_upper_name "db-publisher")" != "PUBLISHER" ]; then
  echo "❌ Error: get_db_upper_name failed for db-publisher"
  exit 1
fi

echo "✅ Short and upper name extraction tests passed!"

# 2. Test Blueprint 41 Resolution (All-in-One: db-proxy)
echo "🔍 Testing Blueprint 41 resolution..."
(
  export DB_PROXY="db-proxy-oracle"
  export DB_PUBLISHER="NONE"
  export DB_FORMS="NONE"
  export DB_ALISE="NONE"

  if [ "$(resolve_service_target_db "publisher")" != "db-proxy" ]; then
    echo "❌ Error: Blueprint 41 publisher DB resolution failed (expected db-proxy)"
    exit 1
  fi
  if [ "$(resolve_service_target_db "forms")" != "db-proxy" ]; then
    echo "❌ Error: Blueprint 41 forms DB resolution failed (expected db-proxy)"
    exit 1
  fi
  if [ "$(resolve_service_target_db "apex")" != "db-proxy" ]; then
    echo "❌ Error: Blueprint 41 apex DB resolution failed (expected db-proxy)"
    exit 1
  fi
)
echo "✅ Blueprint 41 resolution passed!"

# 3. Test Blueprint 43 Resolution (2-DB Hybrid: db-proxy + db-publisher)
echo "🔍 Testing Blueprint 43 resolution..."
(
  export DB_PROXY="db-proxy-oracle"
  export DB_PUBLISHER="appinfra-standard-gvenzl"
  export DB_FORMS="NONE"
  export DB_ALISE="NONE"

  if [ "$(resolve_service_target_db "publisher")" != "db-publisher" ]; then
    echo "❌ Error: Blueprint 43 publisher DB resolution failed (expected db-publisher)"
    exit 1
  fi
  if [ "$(resolve_service_target_db "forms")" != "db-publisher" ]; then
    echo "❌ Error: Blueprint 43 forms DB resolution failed (expected db-publisher)"
    exit 1
  fi
  if [ "$(resolve_service_target_db "apex")" != "db-proxy" ]; then
    echo "❌ Error: Blueprint 43 apex DB resolution failed (expected db-proxy)"
    exit 1
  fi
)
echo "✅ Blueprint 43 resolution passed!"

# 4. Test Blueprint 42 Resolution (Fully Isolated: db-proxy, db-publisher, db-forms)
echo "🔍 Testing Blueprint 42 resolution..."
(
  export DB_PROXY="db-proxy-oracle"
  export DB_PUBLISHER="db-publisher-oracle"
  export DB_FORMS="db-forms-oracle"
  export DB_ALISE="db-alise-oracle"

  if [ "$(resolve_service_target_db "publisher")" != "db-publisher" ]; then
    echo "❌ Error: Blueprint 42 publisher DB resolution failed (expected db-publisher)"
    exit 1
  fi
  if [ "$(resolve_service_target_db "forms")" != "db-forms" ]; then
    echo "❌ Error: Blueprint 42 forms DB resolution failed (expected db-forms)"
    exit 1
  fi
  if [ "$(resolve_service_target_db "apex")" != "db-proxy" ]; then
    echo "❌ Error: Blueprint 42 apex DB resolution failed (expected db-proxy)"
    exit 1
  fi
)
echo "✅ Blueprint 42 resolution passed!"

# 5. Test Zero Cross-DB Fallback (Fail-Fast on non-existent DB)
echo "🔍 Testing zero cross-db fallback fail-fast..."
if get_db_sys_password "db-non-existent-12345" 2>/dev/null; then
  echo "❌ Error: get_db_sys_password should fail on non-existent DB without cross-fallback!"
  exit 1
fi
echo "✅ Fail-fast validation passed!"

echo "test-credentials-matrix: PASS"
