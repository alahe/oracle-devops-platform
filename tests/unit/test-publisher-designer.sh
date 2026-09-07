#!/usr/bin/env bash
# ==============================================================================
# Unit Test: Oracle Analytics Publisher Designer Workstation Architecture
# Validates Dockerfile, profile, sample RTF templates, CLI tools, and 6-language docs
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "🔍 Running Publisher Designer Workstation Unit Tests..."

# 1. Verify Dockerfile and Entrypoint
test -f "$WORKSPACE_DIR/docker/publisher-designer/Dockerfile"
test -f "$WORKSPACE_DIR/docker/publisher-designer/entrypoint.sh"
test -x "$WORKSPACE_DIR/docker/publisher-designer/entrypoint.sh"
test -f "$WORKSPACE_DIR/docker/publisher-designer/render-template.sh"
test -x "$WORKSPACE_DIR/docker/publisher-designer/render-template.sh"
echo "  ✅ Dockerfile and container runtime scripts verified."

# 2. Verify Profile & Compose
test -f "$WORKSPACE_DIR/config/profiles/publisher/publisher-designer-standard.yaml"
test -f "$WORKSPACE_DIR/config/profiles/publisher/publisher-designer.yaml"
grep -q "publisher-designer" "$WORKSPACE_DIR/podman-compose.yml"
grep -q "build_local" "$WORKSPACE_DIR/config/profiles/publisher/publisher-designer-standard.yaml"
grep -q "context: ./docker/publisher-designer" "$WORKSPACE_DIR/podman-compose.yml"
echo "  ✅ YAML profiles (standard & legacy), JIT build config, and Compose build verified."

# 2.1. Verify Profile-Driven Zero-DB Invariant
unset DB_PROXY DB_ALISE DB_PUBLISHER DB_FORMS MAIN_DB_PROFILE DB_ENABLED || true
source "$WORKSPACE_DIR/config/blueprints/.env.9-standalone-publisher-designer"
source "$WORKSPACE_DIR/scripts/internal/load-profile.sh"
load_db_profile
load_publisher_designer_profile
test "$DB_ENABLED" = "false"
test -z "$(get_active_db_instances)"
is_publisher_designer_enabled
echo "  ✅ Profile-Driven Zero-Database Invariant verified (0 DBs, Designer enabled)."

# 3. Verify Sample RTF templates and XML datasets
test -f "$WORKSPACE_DIR/templates/publisher/samples/arve_eesti_standard.rtf"
test -f "$WORKSPACE_DIR/templates/publisher/samples/arve_näidisandmed.xml"
test -f "$WORKSPACE_DIR/templates/publisher/samples/saateleht_standard.rtf"
test -f "$WORKSPACE_DIR/templates/publisher/samples/saateleht_andmed.xml"
grep -q "<?for-each:G_LINES?>" "$WORKSPACE_DIR/templates/publisher/samples/arve_eesti_standard.rtf"
grep -q "<INVOICE_NUM>" "$WORKSPACE_DIR/templates/publisher/samples/arve_näidisandmed.xml"
echo "  ✅ Sample RTF templates and XML datasets verified."

# 4. Verify CLI Tools
for script in "start-designer.sh" "open-designer.sh" "stop-designer.sh" "test-render.sh" "deploy-template.sh"; do
  test -f "$WORKSPACE_DIR/scripts/publisher/$script"
  test -x "$WORKSPACE_DIR/scripts/publisher/$script"
done
echo "  ✅ All 5 Publisher Designer CLI scripts verified."

# 5. Verify 6-Language Documentation
for doc in "docs/publisher-template-builder-guide.md" \
           "docs/et/publisher-template-builder-guide.md" \
           "docs/fi/publisher-template-builder-guide.md" \
           "docs/sv/publisher-template-builder-guide.md" \
           "docs/lv/publisher-template-builder-guide.md" \
           "docs/lt/publisher-template-builder-guide.md"; do
  test -f "$WORKSPACE_DIR/$doc"
  grep -q "noVNC" "$WORKSPACE_DIR/$doc"
done
# 6. Verify Container Lifecycle Pre-flight & 6-Language Localization
! grep -q "Tuvastati töötav andmebaasikonteiner" "$WORKSPACE_DIR/scripts/setup-all.sh"
grep -q "WARN_FOREIGN_CONTAINER_DETECTED" "$WORKSPACE_DIR/scripts/setup-all.sh"
grep -q "PROMPT_STOP_FOREIGN_CONTAINER" "$WORKSPACE_DIR/scripts/setup-all.sh"
grep -q "STOPPING_PREVIOUS_BP_CONTAINER" "$WORKSPACE_DIR/scripts/setup-all.sh"

source "$WORKSPACE_DIR/scripts/internal/i18n.sh"
for l in en et fi sv lv lt; do
  export CLI_LANG=$l
  test -n "$(msg_str "WARN_FOREIGN_CONTAINER_DETECTED" "test" "9")"
  test -n "$(msg_str "PROMPT_STOP_FOREIGN_CONTAINER")"
  test -n "$(msg_str "STOPPING_PREVIOUS_BP_CONTAINER" "test")"
done
echo "  ✅ Container lifecycle pre-flight & 6-language localization verified."

echo "🎉 All Publisher Designer Workstation unit tests PASSED (100%)!"
