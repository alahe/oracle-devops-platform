#!/usr/bin/env bash
# ============================================================================
# Utility Script: System Prerequisites & Resource Inspector
# Purpose: Validates free RAM, CPU cores, Podman machine disk space, and auto-tunes execution mode.
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source central localization engine
if [ -f "$SCRIPT_DIR/i18n.sh" ]; then
  # shellcheck source=/dev/null
  source "$SCRIPT_DIR/i18n.sh"
fi

# Color definitions
CYAN='\033[1;36m'
GREEN='\033[1;32m'
YELLOW='\033[0;33m'
RED='\033[1;31m'
NC='\033[0m'

echo -e "${CYAN}==================================================================${NC}"
echo -e "${YELLOW}$(msg_str "CHECK_SYSTEM_RESOURCES")${NC}"
echo -e "${CYAN}==================================================================${NC}"

# 1. Check Podman binary availability
if ! command -v podman >/dev/null 2>&1 && ! command -v docker >/dev/null 2>&1; then
  echo -e "${RED}❌ ERROR: Neither Podman nor Docker utility was found on system!${NC}"
  exit 1
fi

# 2. Check Podman machine disk space inside VM
if command -v podman >/dev/null 2>&1; then
  FREE_DISK_MB=$(podman machine ssh podman-machine-default "df -m /sysroot | tail -n 1" 2>/dev/null | awk '{print $4}' || echo "20000")
  if [[ "$FREE_DISK_MB" =~ ^[0-9]+$ ]]; then
    FREE_DISK_GB=$((FREE_DISK_MB / 1024))
    if [ "$FREE_DISK_GB" -lt 10 ]; then
      echo -e "${RED}⚠️  CRITICAL WARNING: Podman VM free disk space is critically low: ${FREE_DISK_GB} GB!${NC}"
      echo -e "${YELLOW}   💡 Recommendation: Free up disk space: podman system prune -a or ./scripts/snapshots/clean-golden-snapshots.sh -y${NC}"
    elif [ "$FREE_DISK_GB" -lt 20 ]; then
      echo -e "${YELLOW}⚠️  WARNING: Podman VM free disk space is low: ${FREE_DISK_GB} GB (Recommended at least 20 GB)${NC}"
      echo -e "${YELLOW}   💡 Recommendation: Free up disk space: ./scripts/snapshots/clean-golden-snapshots.sh -y${NC}"
    else
      echo -e "   ├─ $(msg_str "RES_PODMAN_DISK"): ${GREEN}${FREE_DISK_GB} GB${NC}"
    fi
  fi
fi

# 3. Check System Memory (RAM)
TOTAL_RAM_MB=8192
if command -v sysctl >/dev/null 2>&1; then
  TOTAL_RAM_BYTES=$(sysctl -n hw.memsize 2>/dev/null || echo "8589934592")
  TOTAL_RAM_MB=$((TOTAL_RAM_BYTES / 1024 / 1024))
elif [ -f /proc/meminfo ]; then
  TOTAL_RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
  TOTAL_RAM_MB=$((TOTAL_RAM_KB / 1024))
fi

TOTAL_RAM_GB=$((TOTAL_RAM_MB / 1024))
echo -e "   ├─ $(msg_str "RES_HOST_RAM"): ${GREEN}${TOTAL_RAM_GB} GB${NC}"

# Auto-tune STRICT_SEQUENTIAL_MODE if RAM is limited (< 8GB) or multi-container active
if [ "$TOTAL_RAM_GB" -lt 8 ] || [ "${FORCE_SEQUENTIAL:-true}" = "true" ]; then
  export STRICT_SEQUENTIAL_MODE=true
  echo -e "   └─ $(msg_str "RES_EXEC_MODE"): ${YELLOW}$(msg_str "RES_MODE_SEQ")${NC}"
else
  export STRICT_SEQUENTIAL_MODE=false
  echo -e "   └─ $(msg_str "RES_EXEC_MODE"): ${GREEN}$(msg_str "RES_MODE_PAR")${NC}"
fi

echo -e "${CYAN}==================================================================${NC}"
