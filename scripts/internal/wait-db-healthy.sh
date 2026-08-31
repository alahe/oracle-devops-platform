#!/usr/bin/env bash
# ============================================================================
# Adaptive Multi-Phase Healthcheck & Self-Healing Engine
# Verifies container health, TCP listeners, and PDB READ WRITE status.
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source central common helper and profile loader
[ -f "$SCRIPT_DIR/common.sh" ] && source "$SCRIPT_DIR/common.sh"
[ -f "$SCRIPT_DIR/load-profile.sh" ] && source "$SCRIPT_DIR/load-profile.sh"

CONTAINERS_TO_CHECK=()
for arg in "$@"; do
  if [[ "$arg" =~ ^[0-9]+$ ]]; then
    if [ -z "$CUSTOM_MAX_WAIT" ]; then
      CUSTOM_MAX_WAIT="$arg"
    fi
  else
    CONTAINERS_TO_CHECK+=("$arg")
  fi
done

if [ "${#CONTAINERS_TO_CHECK[@]}" -eq 0 ]; then
  for inst in $(get_active_db_instances 2>/dev/null); do
    cname=$(echo "$inst" | cut -d'|' -f1)
    [ -n "$cname" ] && CONTAINERS_TO_CHECK+=("$cname")
  done
fi

MAX_WAIT=${CUSTOM_MAX_WAIT:-450}
if [ "${IS_ADB:-false}" = "true" ] && [ -z "$CUSTOM_MAX_WAIT" ]; then
  MAX_WAIT=2400
fi

echo -e "${YELLOW}$(msg_str "DB_WAIT_ALL_HEALTHY")${NC}"

for container in "${CONTAINERS_TO_CHECK[@]}"; do
  WAIT_COUNT=0
  AUTO_RESTARTED=false
  POLL_INTERVAL=2

  while true; do
    c_status=$(podman inspect --format='{{.State.Status}}' "$container" 2>/dev/null || echo "not_found")
    h_status=$(podman inspect --format='{{.State.Health.Status}}' "$container" 2>/dev/null || echo "none")

    is_healthy=false

    if [ "$c_status" = "running" ]; then
      if [ "$h_status" = "healthy" ] || [ "$h_status" = "none" ] || [ "$h_status" = "starting" ]; then
        if podman exec "$container" sh -c "[ -f /u01/container_state/.installed_ords ]" 2>/dev/null; then
          is_healthy=true
        else
          # Kontrollime, et PDB on avatud READ WRITE olekus
          pdb_check=$(podman exec -i "$container" sh -c 'export ORACLE_HOME=$(ls -d /opt/oracle/product/*/dbhomeFree 2>/dev/null | head -n 1); [ -n "$ORACLE_HOME" ] && export PATH="$ORACLE_HOME/bin:$PATH"; echo -e "SET HEADING OFF FEEDBACK OFF;\nSHOW PDBS;\nEXIT;" | sqlplus -s / as sysdba' 2>/dev/null || true)
          if echo "$pdb_check" | grep -q "READ WRITE"; then
            is_healthy=true
          fi
        fi
      fi
    fi

    if [ "$is_healthy" = "true" ]; then
      clear_progress_line
      echo -e "$(msg_str "DB_CONTAINER_HEALTHY" "${GREEN}${container}${NC}")"
      break
    fi

    # Kui konteinerit ei ole aktiivses compose profiilis defineeritud ega käivitatud (not_found), jätame selle kohe vahele
    if [ "$c_status" = "not_found" ] && [ $WAIT_COUNT -ge 6 ]; then
      clear_progress_line
      echo -e "   ℹ️  Konteinerit ${YELLOW}${container}${NC} ei ole aktiivses profiilis käivitatud (Skipping)."
      break
    fi

    sleep "$POLL_INTERVAL"
    WAIT_COUNT=$((WAIT_COUNT + POLL_INTERVAL))
    # Adaptiivne intervalli reguleerimine
    if [ $WAIT_COUNT -gt 30 ] && [ "$POLL_INTERVAL" -lt 5 ]; then
      POLL_INTERVAL=5
    fi

    print_progress "$(msg_str "DB_WAITING_CONTAINER" "$container")" "$WAIT_COUNT" "$MAX_WAIT"

    # Automaatne iseparanev taaskäivitus kui konteiner töötab, aga Oracle DB ei vasta 45s jooksul (zombie / ORA-01034 taastamine)
    if [ "$AUTO_RESTARTED" = "false" ] && [ $WAIT_COUNT -ge 45 ] && [ "$c_status" = "running" ]; then
      if ! echo -e "SHOW PDBS;\nexit;" | podman exec -i "$container" sqlplus -s -L / as sysdba 2>/dev/null | grep -q "READ WRITE"; then
        AUTO_RESTARTED=true
        clear_progress_line
        echo -e "$(msg_str "DB_ZOMBIE_RESTART" "${container}")"
        podman restart "$container" >/dev/null 2>&1 || true
        sleep 5
      fi
    fi

    if [ $WAIT_COUNT -ge $MAX_WAIT ]; then
      clear_progress_line
      echo -e "\n${RED}$(msg_str "DB_HEALTH_TIMEOUT_ERROR" "$container" "$MAX_WAIT")${NC}"
      exit 1
    fi
  done
done
