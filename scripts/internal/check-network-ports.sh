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

  # 3. Kontrollime pordikonflikte aktiivsete teenuste vahel (Duplication Check)
  local seen_ports=""
  local conflict_details=()

  while IFS=':' read -r svc port note; do
    [ -z "$port" ] && continue
    if echo "$seen_ports" | grep -q "|$port|"; then
      has_conflict=true
      prev_svc=$(grep ":${port}:" "$temp_file" | head -n 1 | cut -d':' -f1)
      conflict_details+=("   - Port ${RED}${port}${NC} on määratud korraga teenusele '${CYAN}${svc}${NC}' ja teenusele '${CYAN}${prev_svc}${NC}' (${note})")
    else
      seen_ports="${seen_ports}|${port}|"
    fi
  done < "$temp_file"

  # 4. Trükime võrgu analüüsi ja marsruutimise ülevaate
  echo ""
  echo -e "${YELLOW}🌐 VÕRGU TOPOLOOGIA JA MARSRUUTIMISE ANALÜÜS (Network Analysis):${NC}"
  echo -e "   ├─ Võrgu režiim:       Podman Bridge Network '${CYAN}oracle-devops-platform_default${NC}'"
  echo -e "   ├─ Turvaala:           Kõik välised pordid on sidustatud rangelt ${GREEN}127.0.0.1 (Loopback Only)${NC}"
  echo -e "   └─ Suunamised (Port Forwarding & Internal Routing):"
  while IFS=':' read -r svc port note; do
    [ -z "$port" ] && continue
    echo -e "      • ${CYAN}${svc}${NC} ➔ Hosti port ${GREEN}127.0.0.1:${port}${NC} (${note})"
  done < "$temp_file"
  echo -e "${CYAN}==================================================================${NC}"

  # 5. Kui esineb dubleerimine profiilide vahel:
  if [ "$has_conflict" = "true" ]; then
    echo -e "${RED}❌ VIGA: TUVASTATI PORDI KONFLIKT AKTIIVSETE PROFIILIDE VAHEL!${NC}"
    for err in "${conflict_details[@]}"; do
      echo -e "$err"
    done
    echo ""
    echo -e "${YELLOW}💡 KUIDAS PARANDADA:${NC}"
    echo -e "   1. Ava konfliktsed profiilifailid kaustast: ${CYAN}config/profiles/databases/${NC} või lokaalne fail ${CYAN}.env${NC}"
    echo -e "   2. Muuda ühes failis rida '${CYAN}db_port: ...${NC}' või '.env' muutujat n-ö unikaalseks pordiks (nt 1531, 1532, 1533)."
    echo -e "   3. Käivita paigaldus uuesti: ${GREEN}./scripts/setup-all.sh${NC}"
    echo -e "${CYAN}==================================================================${NC}"
    rm -f "$temp_file"
    exit 1
  fi

  # 6. Kontrollime host-masina pordi hõivatust (Occupied Port Check)
  local occupied_ports=()
  while IFS=':' read -r svc port note; do
    [ -z "$port" ] && continue
    if nc -z 127.0.0.1 "$port" 2>/dev/null; then
      if ! podman ps --format '{{.Ports}}' 2>/dev/null | grep -q ":${port}->"; then
        occupied_ports+=("   - Port ${RED}${port}${NC} (Teenus: ${CYAN}${svc}${NC}) on host-süsteemis teise rakenduse poolt HÕIVATUD!")
      fi
    fi
  done < "$temp_file"

  rm -f "$temp_file"

  if [ "${#occupied_ports[@]}" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  HOIATUS: Mõned pordid on host-süsteemis teise protsessi poolt kasutusel!${NC}"
    for occ in "${occupied_ports[@]}"; do
      echo -e "$occ"
    done
    echo -e "   💡 Märkus: Sule teine rakendus või muuda pordi väärtust failis [.env](file://${WORKSPACE_DIR}/.env)."
    echo -e "${CYAN}==================================================================${NC}"
  fi
}

check_ports_and_analyze_network
