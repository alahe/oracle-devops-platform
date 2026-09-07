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

# 1.1. Check if running inside WSL2 on a Windows NTFS mount (/mnt/c/...)
if grep -qEi 'Microsoft|Subsystem' /proc/version 2>/dev/null; then
  if [[ "$WORKSPACE_DIR" =~ ^/mnt/[a-zA-Z]/ ]]; then
    echo -e "${YELLOW}⚠️  WARNING: Project running on Windows NTFS mount: ${WORKSPACE_DIR}${NC}"
    echo -e "${YELLOW}   Plan9 (9P) filesystem overhead causes a 10x–50x I/O slowdown on Windows!${NC}"
    echo -e "${CYAN}   💡 Recommendation: For maximum speed, clone and run inside native WSL2 ext4:${NC}"
    echo -e "${CYAN}      cd ~ && git clone <repo-url> && cd oracle-free-db-in-prod${NC}"
  else
    echo -e "   ├─ WSL2 Filesystem: ${GREEN}Native Linux ext4 (~/)${NC}"
  fi
fi

# 1.2. Check Hyper-V dynamic excluded ports on Windows/WSL2
if command -v netsh.exe >/dev/null 2>&1; then
  EXCL_PORTS=$(netsh.exe interface ipv4 show excludedportrange protocol=tcp 2>/dev/null || true)
  if [ -n "$EXCL_PORTS" ]; then
    for chk_port in 1532 1533 8088 8448 9502 6083; do
      is_excluded=$(echo "$EXCL_PORTS" | awk -v p="$chk_port" '$1 ~ /^[0-9]+$/ && $2 ~ /^[0-9]+$/ { if (p >= $1 && p <= $2) print "yes" }')
      if [ "$is_excluded" = "yes" ]; then
        echo -e "${RED}⚠️  PORT CONFLICT WARNING: Port $chk_port is reserved by Windows Hyper-V dynamic port range!${NC}"
        echo -e "${YELLOW}   💡 Recommendation: Restart Windows NAT or reserve ports via: netsh int ipv4 add excludedportrange protocol=tcp startport=$chk_port numberofports=1${NC}"
      fi
    done
  fi
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

# 3. Check System Memory (RAM) Cross-Platform (Windows / macOS / Linux / WSL2)
TOTAL_RAM_MB=8192
AVAIL_RAM_MB=4096

if [ -f /proc/meminfo ]; then
  # Linux / WSL2
  TOT_KB=$(grep -i MemTotal /proc/meminfo 2>/dev/null | awk '{print $2}')
  AVAIL_KB=$(grep -i MemAvailable /proc/meminfo 2>/dev/null | awk '{print $2}')
  [ -n "$TOT_KB" ] && TOTAL_RAM_MB=$((TOT_KB / 1024))
  [ -n "$AVAIL_KB" ] && AVAIL_RAM_MB=$((AVAIL_KB / 1024))
elif command -v sysctl >/dev/null 2>&1 && sysctl -n hw.memsize >/dev/null 2>&1; then
  # macOS
  TOTAL_RAM_BYTES=$(sysctl -n hw.memsize 2>/dev/null || echo "8589934592")
  TOTAL_RAM_MB=$((TOTAL_RAM_BYTES / 1024 / 1024))
  if command -v vm_stat >/dev/null 2>&1; then
    PAGE_SIZE=$(vm_stat 2>/dev/null | grep "page size of" | awk '{print $8}' || echo "4096")
    FREE_PAGES=$(vm_stat 2>/dev/null | grep "Pages free:" | awk '{print $3}' | tr -d '.' || echo "0")
    INACT_PAGES=$(vm_stat 2>/dev/null | grep "Pages inactive:" | awk '{print $3}' | tr -d '.' || echo "0")
    SPEC_PAGES=$(vm_stat 2>/dev/null | grep "Pages speculative:" | awk '{print $3}' | tr -d '.' || echo "0")
    AVAIL_BYTES=$(( (FREE_PAGES + INACT_PAGES + SPEC_PAGES) * PAGE_SIZE ))
    AVAIL_RAM_MB=$(( AVAIL_BYTES / 1024 / 1024 ))
  else
    AVAIL_RAM_MB=$((TOTAL_RAM_MB / 2))
  fi
elif command -v powershell.exe >/dev/null 2>&1; then
  # Windows Native (Git Bash / CMD / PowerShell)
  WIN_MEM=$(powershell.exe -NoProfile -NonInteractive -Command "
    \$os = Get-CimInstance Win32_OperatingSystem;
    [math]::Round(\$os.TotalVisibleMemorySize / 1024); [math]::Round(\$os.FreePhysicalMemory / 1024)
  " 2>/dev/null | tr -d '\r')
  P_TOT=$(echo "$WIN_MEM" | sed -n '1p')
  P_FREE=$(echo "$WIN_MEM" | sed -n '2p')
  [[ "$P_TOT" =~ ^[0-9]+$ ]] && TOTAL_RAM_MB="$P_TOT"
  [[ "$P_FREE" =~ ^[0-9]+$ ]] && AVAIL_RAM_MB="$P_FREE"
elif command -v wmic.exe >/dev/null 2>&1; then
  # Windows Fallback
  W_FREE=$(wmic.exe OS get FreePhysicalMemory /Value 2>/dev/null | grep -i FreePhysicalMemory | cut -d= -f2 | tr -d '\r\n ')
  W_TOT=$(wmic.exe OS get TotalVisibleMemorySize /Value 2>/dev/null | grep -i TotalVisibleMemorySize | cut -d= -f2 | tr -d '\r\n ')
  [[ "$W_TOT" =~ ^[0-9]+$ ]] && TOTAL_RAM_MB=$((W_TOT / 1024))
  [[ "$W_FREE" =~ ^[0-9]+$ ]] && AVAIL_RAM_MB=$((W_FREE / 1024))
fi

# Account for Podman Linux VM memory limit on macOS/Windows
if command -v podman >/dev/null 2>&1 && podman machine list 2>/dev/null | grep -q "Currently running"; then
  VM_AVAIL=$(podman machine ssh "grep MemAvailable /proc/meminfo" 2>/dev/null | awk '{print int($2/1024)}' || true)
  if [ -n "$VM_AVAIL" ] && [ "$VM_AVAIL" -gt 0 ] 2>/dev/null; then
    if [ "$VM_AVAIL" -lt "$AVAIL_RAM_MB" ]; then
      AVAIL_RAM_MB="$VM_AVAIL"
    fi
  fi
  VM_TOT=$(podman machine ssh "grep MemTotal /proc/meminfo" 2>/dev/null | awk '{print int($2/1024)}' || true)
  if [ -n "$VM_TOT" ] && [ "$VM_TOT" -lt 4096 ] 2>/dev/null; then
    echo -e "${YELLOW}⚠️  WARNING: Podman VM memory is low: ${VM_TOT} MB (Minimum 4096 MB required)${NC}"
  fi
fi

TOTAL_RAM_GB=$((TOTAL_RAM_MB / 1024))
AVAIL_RAM_GB=$((AVAIL_RAM_MB / 1024))
echo -e "   ├─ $(msg_str "RES_HOST_RAM"): ${GREEN}${TOTAL_RAM_GB} GB${NC} (${TOTAL_RAM_MB} MB)"
echo -e "   ├─ $(msg_str "RES_AVAIL_RAM"): ${CYAN}${AVAIL_RAM_GB} GB${NC} (${AVAIL_RAM_MB} MB)"

# Live Container Memory Inspection (podman stats / cgroups)
if command -v podman >/dev/null 2>&1; then
  LIVE_MEM_SUM=$(podman stats --no-stream --format "{{.MemUsage}}" 2>/dev/null | awk -F'/' '{print $1}' | tr '\n' ' ' || true)
  if [ -n "$LIVE_MEM_SUM" ]; then
    echo -e "   ├─ Container Memory Load: ${YELLOW}${LIVE_MEM_SUM}${NC}"
  fi
fi

# Safety Buffer Check (< 2048 MB free RAM guard)
MIN_SAFE_RAM_MB=${MIN_SAFE_RAM_MB:-2048}
if [ "$AVAIL_RAM_MB" -lt "$MIN_SAFE_RAM_MB" ] && [ "${FORCE_DEPLOY:-false}" != "true" ] && [ "${SKIP_RAM_CHECK:-false}" != "true" ] && [ "${IS_TEST_MODE:-false}" != "true" ]; then
  echo -e "\n${RED}==================================================================${NC}"
  msg_print "RES_INSUFFICIENT_RAM" "$AVAIL_RAM_MB" "$MIN_SAFE_RAM_MB"
  echo -e "${YELLOW}💡 Recommendation: Close unused containers or apps, or bypass with: --force${NC}"
  echo -e "${RED}==================================================================${NC}\n"
  exit 1
fi

# Auto-tune STRICT_SEQUENTIAL_MODE if RAM is limited (< 8GB) or multi-container active
if [ "$TOTAL_RAM_GB" -lt 8 ] || [ "$AVAIL_RAM_GB" -lt 4 ] || [ "${FORCE_SEQUENTIAL:-true}" = "true" ]; then
  export STRICT_SEQUENTIAL_MODE=true
  echo -e "   └─ $(msg_str "RES_EXEC_MODE"): ${YELLOW}$(msg_str "RES_MODE_SEQ")${NC}"
else
  export STRICT_SEQUENTIAL_MODE=false
  echo -e "   └─ $(msg_str "RES_EXEC_MODE"): ${GREEN}$(msg_str "RES_MODE_PAR")${NC}"
fi

echo -e "${CYAN}==================================================================${NC}"
