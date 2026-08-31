#!/usr/bin/env bash
# ============================================================================
# Oracle Forms 14c (14.1.2) Installation & Provisioning Engine
# Orchestrates DB RCU initialization, container lifecycle, and endpoint readiness
# ============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source common helpers
[ -f "$SCRIPT_DIR/i18n.sh" ] && source "$SCRIPT_DIR/i18n.sh"
[ -f "$SCRIPT_DIR/common.sh" ] && source "$SCRIPT_DIR/common.sh"
[ -f "$SCRIPT_DIR/load-profile.sh" ] && source "$SCRIPT_DIR/load-profile.sh"

START_FORMS_TOTAL=$(date +%s)
LOG_DIR="$WORKSPACE_DIR/install_logs"
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$LOG_DIR/forms_engine_install_${TIMESTAMP}.log"

if [ "${MASTER_SETUP:-false}" != "true" ]; then
  exec > >(tee -a "$LOG_FILE") 2>&1
fi

echo -e "\n${CYAN}==================================================================${NC}"
echo -e "${BOLD}$(msg_str "FORMS_INSTALL_HEADER")${NC}"
echo -e "${CYAN}==================================================================${NC}"

# 1. Samm: Lae profiil ja initsialiseeri RCU Skeemid andmebaasis
FORMS_PROF=$(get_active_db_instances 2>/dev/null | grep -i "forms" | head -n 1 | cut -d'|' -f2)
FORMS_PROF="${FORMS_PROF:-db-forms-oracle}"
load_db_profile "$FORMS_PROF" >/dev/null 2>&1 || true

FORMS_HTTP="${PROFILE_FORMS_HTTP_PORT:-9001}"
FORMS_HTTPS="${PROFILE_FORMS_HTTPS_PORT:-9002}"
FORMS_ADMIN="${PROFILE_FORMS_ADMIN_PORT:-7001}"
FORMS_BUILDER="${PROFILE_FORMS_BUILDER_PORT:-6082}"
FORMS_CONTAINER="${PROFILE_FORMS_CONTAINER_NAME:-app-forms}"
FORMS_IMAGE="${FORMS_CONTAINER_IMAGE:-}"
if [ -z "$FORMS_IMAGE" ]; then
  if podman image exists "localhost/oracle-free-forms-prebuilt:14.1.2" 2>/dev/null; then
    FORMS_IMAGE="localhost/oracle-free-forms-prebuilt:14.1.2"
    echo -e "   ✅ Detected prebuilt Forms image: ${CYAN}${FORMS_IMAGE}${NC}"
  elif podman image exists "localhost/oracle-forms:14.1.2" 2>/dev/null; then
    FORMS_IMAGE="localhost/oracle-forms:14.1.2"
    echo -e "   ✅ Detected existing Forms image: ${CYAN}${FORMS_IMAGE}${NC}"
  elif podman image exists "oracle-forms:14.1.2" 2>/dev/null; then
    FORMS_IMAGE="oracle-forms:14.1.2"
    echo -e "   ✅ Detected existing Forms image: ${CYAN}${FORMS_IMAGE}${NC}"
  else
    FORMS_IMAGE="localhost/oracle-forms:14.1.2"
  fi
fi

if [ -f "$SCRIPT_DIR/init-forms-rcu.sh" ]; then
  print_header "1" "$(msg_str "FORMS_STEP_1_TITLE" "db-forms")" "" "5s"
  "$SCRIPT_DIR/init-forms-rcu.sh" || true
fi

# 2. Samm: Kontrolli ja ehita/käivita Forms 14c konteiner
print_header "2" "$(msg_str "FORMS_STEP_2_TITLE" "$FORMS_IMAGE")" "" "5s"
if ! podman image exists "$FORMS_IMAGE" 2>/dev/null; then
  if [ -x "$WORKSPACE_DIR/docker/forms/build-forms-image.sh" ]; then
    "$WORKSPACE_DIR/docker/forms/build-forms-image.sh" "14.1.2" || true
  fi
fi

# 3. Samm: Käivita app-forms konteiner
NET_NAME=$(podman inspect "db-forms" --format '{{range $k, $v := .NetworkSettings.Networks}}{{$k}}{{end}}' 2>/dev/null || podman inspect "db-proxy" --format '{{range $k, $v := .NetworkSettings.Networks}}{{$k}}{{end}}' 2>/dev/null || podman inspect "db-lis" --format '{{range $k, $v := .NetworkSettings.Networks}}{{$k}}{{end}}' 2>/dev/null || echo "")
NET_ARG=""
[ -n "$NET_NAME" ] && NET_ARG="--network $NET_NAME"

EMBEDDED_ORDS_ARG=""
if [ "${ENABLE_EMBEDDED_ORDS:-false}" = "true" ] || [ "${ORDS_MODE:-}" = "embedded" ]; then
  EMBEDDED_ORDS_PORT="${ORDS_PORT:-8088}"
  EMBEDDED_ORDS_ARG="-p 127.0.0.1:${EMBEDDED_ORDS_PORT}:8088 -e ENABLE_EMBEDDED_ORDS=true"
fi

if podman container exists "$FORMS_CONTAINER" 2>/dev/null; then
  podman rm -f "$FORMS_CONTAINER" >/dev/null 2>&1 || true
fi

mkdir -p "$WORKSPACE_DIR/forms_apps"
if [ -x "$WORKSPACE_DIR/scripts/internal/generate-dev-hub.sh" ]; then
  "$WORKSPACE_DIR/scripts/internal/generate-dev-hub.sh" "$WORKSPACE_DIR/docs/dev-hub.html" >/dev/null 2>&1 || true
fi

TNS_VOL=""
[ -d "$WORKSPACE_DIR/config/tns_admin" ] && TNS_VOL="-v $WORKSPACE_DIR/config/tns_admin:/u01/oracle/tns_admin:ro"
HUB_VOL=""
[ -f "$WORKSPACE_DIR/docs/dev-hub.html" ] && HUB_VOL="-v $WORKSPACE_DIR/docs/dev-hub.html:/u01/oracle/dev-hub.html:ro"

podman run -d \
  --name "$FORMS_CONTAINER" \
  --hostname "$FORMS_CONTAINER" \
  $NET_ARG \
  -p "127.0.0.1:${FORMS_HTTP}:9001" \
  -p "127.0.0.1:${FORMS_HTTPS}:9002" \
  -p "127.0.0.1:${FORMS_ADMIN}:7001" \
  -p "127.0.0.1:${FORMS_BUILDER}:6082" \
  $EMBEDDED_ORDS_ARG \
  -v "$WORKSPACE_DIR/forms_apps:/u01/oracle/forms_apps:rw" \
  -v "$WORKSPACE_DIR/docker/forms/dockerfiles/14.1.2/createAndStartFormsDomain.sh:/u01/createAndStartFormsDomain.sh:ro" \
  $TNS_VOL \
  $HUB_VOL \
  --entrypoint "/bin/bash" \
  "$FORMS_IMAGE" /u01/createAndStartFormsDomain.sh >/dev/null 2>&1 || true

FORMS_TOTAL_SECS=$(( $(date +%s) - START_FORMS_TOTAL ))
FORMS_TIME=$(format_duration "$FORMS_TOTAL_SECS")

echo -e "${GREEN}$(msg_str "FORMS_TEST_COMPLETED_STEP" "${YELLOW}${FORMS_TIME}${GREEN}")${NC}"
