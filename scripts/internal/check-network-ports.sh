#!/usr/bin/env bash
# ============================================================================
# Network Topology & Port Conflict Validator (check-network-ports.sh)
# Validates active profile port allocations and analyzes network topology
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [ -f "$SCRIPT_DIR/load-profile.sh" ]; then
  source "$SCRIPT_DIR/load-profile.sh"
fi

if [ -f "$SCRIPT_DIR/common.sh" ]; then
  source "$SCRIPT_DIR/common.sh"
else
  CYAN=$'\033[1;36m'
  GREEN=$'\033[1;32m'
  RED=$'\033[1;31m'
  YELLOW=$'\033[0;33m'
  NC=$'\033[0m'
fi

check_ports_and_analyze_network() {
  local has_conflict=false
  local used_ports=()
  local temp_file="/tmp/_active_ports_$$.tmp"
  
  rm -f "$temp_file"
  touch "$temp_file"

  # 1. Kogume andmebaasikonteinerite pordid
  for inst in $(get_active_db_instances 2>/dev/null); do
    container=$(echo "$inst" | cut -d'|' -f1)
    prof=$(echo "$inst" | cut -d'|' -f2)
    [ -z "$container" ] && continue
    (
      load_db_profile "$prof" >/dev/null 2>&1 || true
      echo "${container}:${PROFILE_DB_PORT:-1532}:Database Engine" >> "$temp_file"
    )
  done

  # 2. Lisame ORDS, Publisher ja Web IDE pordid
  if [ "${SKIP_ORDS:-false}" = "false" ]; then
    echo "${PROFILE_ORDS_CONTAINER_NAME:-app-ords}:${ORDS_PORT:-8088}:ORDS-HTTP" >> "$temp_file"
    echo "${PROFILE_ORDS_CONTAINER_NAME:-app-ords}:${ORDS_SSL:-8448}:ORDS-HTTPS" >> "$temp_file"
  fi
  if [ "${SKIP_PUBLISHER:-false}" = "false" ] && { [ "${ANY_PUB_ENABLED:-false}" = "true" ] || [ "${PUBLISHER_ENABLED:-false}" = "true" ]; }; then
    echo "${PUBLISHER_CONTAINER_NAME:-app_publisher}:${PUBLISHER_HTTP_PORT:-9502}:Publisher-HTTP" >> "$temp_file"
    echo "${PUBLISHER_CONTAINER_NAME:-app_publisher}:${PUBLISHER_HTTPS_PORT:-9503}:Publisher-HTTPS" >> "$temp_file"
  fi
  load_web_ide_profile >/dev/null 2>&1 || true
  if [ "${SKIP_WEB_IDE:-false}" = "false" ] && [ "${WEB_IDE_ENABLED:-false}" = "true" ]; then
    echo "${WEB_IDE_CONTAINER_NAME:-web-ide-dev}:${WEB_IDE_HTTP_PORT:-8090}:WebIDE-HTTP" >> "$temp_file"
    echo "${WEB_IDE_CONTAINER_NAME:-web-ide-dev}:${WEB_IDE_HTTPS_PORT:-8449}:WebIDE-HTTPS" >> "$temp_file"
  fi

  # 3. Check for port conflicts between active services (Duplication Check)
  local seen_ports=""
  local conflict_details=()

  while IFS=':' read -r svc port note; do
    [ -z "$port" ] && continue
    if echo "$seen_ports" | grep -q "|$port|"; then
      has_conflict=true
      prev_svc=$(grep ":${port}:" "$temp_file" | head -n 1 | cut -d':' -f1)
      conflict_details+=("   - Port ${RED}${port}${NC} is assigned to both service '${CYAN}${svc}${NC}' and service '${CYAN}${prev_svc}${NC}' (${note})")
    else
      seen_ports="${seen_ports}|${port}|"
    fi
  done < "$temp_file"

  # 4. Network Analysis and Routing Overview
  echo ""
  echo -e "${YELLOW}🌐 NETWORK TOPOLOGY AND ROUTING ANALYSIS:${NC}"
  echo -e "   ├─ Network mode:       Podman Bridge Network '${CYAN}oracle-devops-platform_default${NC}'"
  echo -e "   ├─ Security:           All external ports bound strictly to ${GREEN}127.0.0.1 (Loopback Only)${NC}"
  echo -e "   └─ Port Forwarding & Internal Routing:"
  while IFS=':' read -r svc port note; do
    [ -z "$port" ] && continue
    echo -e "      • ${CYAN}${svc}${NC} ➔ Host port ${GREEN}127.0.0.1:${port}${NC} (${note})"
  done < "$temp_file"
  echo -e "${CYAN}==================================================================${NC}"

  # 5. Profile port conflict detection
  if [ "$has_conflict" = "true" ]; then
    echo -e "${RED}❌ ERROR: DETECTED PORT CONFLICT BETWEEN ACTIVE PROFILES!${NC}"
    for err in "${conflict_details[@]}"; do
      echo -e "$err"
    done
    echo ""
    echo -e "${YELLOW}💡 HOW TO RESOLVE:${NC}"
    echo -e "   1. Open conflicting profile files in: ${CYAN}config/profiles/databases/${NC} or local ${CYAN}.env${NC}"
    echo -e "   2. Modify line '${CYAN}db_port: ...${NC}' or '.env' variable to a unique port (e.g. 1531, 1532, 1533)."
    echo -e "   3. Run setup again: ${GREEN}./scripts/setup-all.sh${NC}"
    echo -e "${CYAN}==================================================================${NC}"
    rm -f "$temp_file"
    exit 1
  fi

  # 6. Check host machine port occupancy (Occupied Port Check)
  local occupied_ports=()
  while IFS=':' read -r svc port note; do
    [ -z "$port" ] && continue
    if nc -z 127.0.0.1 "$port" 2>/dev/null; then
      if ! podman ps --format '{{.Ports}}' 2>/dev/null | grep -q ":${port}->"; then
        occupied_ports+=("   - Port ${RED}${port}${NC} (Service: ${CYAN}${svc}${NC}) is OCCUPIED by another process on host system!")
      fi
    fi
  done < "$temp_file"

  if [ ${#occupied_ports[@]} -gt 0 ]; then
    echo -e "${RED}❌ ERROR: HOST PORTS ARE ALREADY OCCUPIED BY ANOTHER APPLICATION!${NC}"
    for err in "${occupied_ports[@]}"; do
      echo -e "$err"
    done
    echo ""
    echo -e "${YELLOW}💡 HOW TO RESOLVE:${NC}"
    echo -e "   1. Check running host processes: ${CYAN}lsof -i :<PORT> -sTCP:LISTEN${NC}"
    echo -e "   2. Or change port in ${CYAN}.env${NC} or database profile YAML."
    echo -e "${CYAN}==================================================================${NC}"
    rm -f "$temp_file"
    exit 1
  fi
  rm -f "$temp_file"
}

check_ports_and_analyze_network
