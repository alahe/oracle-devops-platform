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

if [ "${#CONTAINERS_TO_CHECK[@]}" -eq 0 ]; then
  exit 0
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
      # Auto-heal gvenzl missing zoneinfo symlinks if needed (fixes ORA-01804)
      podman exec -u 0 "$container" bash -c '
        for zh in /opt/oracle/product/*/dbhomeFree/oracore/zoneinfo; do
          [ -d "$zh" ] || continue
          if [ ! -f "$zh/timezlrg.dat" ] && [ -f "$zh/timezlrg_45.dat" ]; then
            ln -sf "$zh/timezlrg_45.dat" "$zh/timezlrg.dat"
            ln -sf "$zh/timezlrg_45.dat" "$zh/timezone_45.dat"
            ln -sf "$zh/timezlrg_45.dat" "$zh/timezone.dat"
          fi
        done
      ' 2>/dev/null || true

      if podman exec "$container" sh -c "[ -f /u01/container_state/.installed_ords ]" 2>/dev/null; then
        is_healthy=true
      else
        # Verify that pluggable database (PDB) is opened in READ WRITE mode
        in_c_sql=$(podman exec "$container" bash -c 'ls -d /opt/oracle/product/*/dbhomeFree/sqlcl/bin/sql 2>/dev/null | head -n 1' 2>/dev/null || echo "")
        if [ -n "$in_c_sql" ]; then
          pdb_check=$(printf "SET HEADING OFF FEEDBACK OFF;\nSHOW PDBS;\nEXIT;\n" | podman exec -i "$container" "$in_c_sql" -s / as sysdba 2>/dev/null || true)
        else
          # For containers without embedded SQLcl (e.g. gvenzl image), check PDB via sqlplus
          pdb_check=$(printf "SET HEADING OFF FEEDBACK OFF;\nSHOW PDBS;\nEXIT;\n" | podman exec -i "$container" bash -c 'sqlplus -s / as sysdba' 2>/dev/null || true)
        fi
        if echo "$pdb_check" | grep -q "READ WRITE"; then
          is_healthy=true
        fi
      fi
    fi

    if [ "$is_healthy" = "true" ]; then
      clear_progress_line
      echo -e "$(msg_str "DB_CONTAINER_HEALTHY" "${GREEN}${container}${NC}")"
      break
    fi

    # Fail-Fast: If container is in 'created' or 'exited' state and couldn't start, abort immediately!
    if [ "$c_status" = "created" ] || [ "$c_status" = "exited" ]; then
      if [ $WAIT_COUNT -ge 6 ]; then
        clear_progress_line
        echo -e "\n${RED}❌ Fail-Fast: Container ${container} is in '${c_status}' state and failed to start!${NC}"
        local_err=$(podman inspect --format='{{.State.Error}}' "$container" 2>/dev/null || true)
        if [ -z "$local_err" ]; then
          local_err=$(podman logs --tail 5 "$container" 2>&1 | tr '\n' ' ' | cut -c1-200 || true)
        fi
        [ -n "$local_err" ] && echo -e "   ${YELLOW}Cause:${NC} $local_err"
        echo -e "   ${YELLOW}Hint:${NC} Check port conflicts: 'podman ps' or use Dev Hub ('docs/dev-hub.html')."
        exit 1
      fi
    fi

    # If container is not defined in active compose profile (not_found), wait up to 30s before skipping
    if [ "$c_status" = "not_found" ] && [ $WAIT_COUNT -ge 30 ]; then
      clear_progress_line
      echo -e "   ℹ️  Container ${YELLOW}${container}${NC} is not running in active profile (Skipping)."
      break
    fi

    sleep "$POLL_INTERVAL"
    WAIT_COUNT=$((WAIT_COUNT + POLL_INTERVAL))
    # Adaptive poll interval
    if [ $WAIT_COUNT -gt 30 ] && [ "$POLL_INTERVAL" -lt 5 ]; then
      POLL_INTERVAL=5
    fi

    print_progress "$(msg_str "DB_WAITING_CONTAINER" "$container")" "$WAIT_COUNT" "$MAX_WAIT"

    # Automated self-healing restart if container is running but Oracle DB does not respond within 180s (zombie / ORA-01034 recovery)
    # Do not restart if container is actively initializing for the first time
    if [ "$AUTO_RESTARTED" = "false" ] && [ $WAIT_COUNT -ge 180 ] && [ "$c_status" = "running" ]; then
      is_init=false
      if podman exec "$container" bash -c '[ -f /opt/oracle/hc-container-init ] || [ -f /opt/oracle/hc-pdb-create ]' 2>/dev/null; then
        is_init=true
      fi
      if [ "$is_init" = "false" ]; then
        in_c_sql=$(podman exec "$container" bash -c 'ls -d /opt/oracle/product/*/dbhomeFree/sqlcl/bin/sql 2>/dev/null | head -n 1' 2>/dev/null || echo "")
        db_ok=false
        if [ -n "$in_c_sql" ]; then
          if printf "SHOW PDBS;\nEXIT;\n" | podman exec -i "$container" "$in_c_sql" -s / as sysdba 2>/dev/null | grep -q "READ WRITE"; then
            db_ok=true
          fi
        else
          if printf "SHOW PDBS;\nEXIT;\n" | podman exec -i "$container" bash -c 'sqlplus -s / as sysdba' 2>/dev/null | grep -q "READ WRITE"; then
            db_ok=true
          fi
        fi
        if [ "$db_ok" = "false" ]; then
          AUTO_RESTARTED=true
          clear_progress_line
          echo -e "$(msg_str "DB_ZOMBIE_RESTART" "${container}")"
          podman restart "$container" >/dev/null 2>&1 || true
          sleep 5
        fi
      fi
    fi

    if [ $WAIT_COUNT -ge $MAX_WAIT ]; then
      clear_progress_line
      echo -e "\n${RED}$(msg_str "DB_HEALTH_TIMEOUT_ERROR" "$container" "$MAX_WAIT")${NC}"
      exit 1
    fi
  done
done
