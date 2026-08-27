#!/usr/bin/env bash
# ============================================================================
# Oracle DevOps Platform — Shared Core Shell Library (common.sh)
# Centralizes colors, progress bars, duration formatters, cleanup traps,
# safe credential helpers, benchmark statistics, and performance utilities.
# ============================================================================

# Protect against double-sourcing
if [ -n "${_ORACLE_COMMON_SH_LOADED:-}" ]; then
  return 0 2>/dev/null || exit 0
fi
_ORACLE_COMMON_SH_LOADED=true

_COMMON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$_COMMON_DIR/../.." && pwd)"

# ----------------------------------------------------------------------------
# 1. Terminal Colors & Formatting
# ----------------------------------------------------------------------------
setup_terminal_colors() {
  if [ -t 1 ] || { [ -n "${TERM:-}" ] && [ "${TERM:-}" != "dumb" ]; }; then
    export GREEN=$'\033[1;32m'
    export YELLOW=$'\033[0;33m'
    export ORANGE=$'\033[38;5;208m'
    export CYAN=$'\033[1;36m'
    export RED=$'\033[1;31m'
    export BOLD=$'\033[1m'
    export DIM=$'\033[2m'
    export NC=$'\033[0m'
  else
    export GREEN=''
    export YELLOW=''
    export ORANGE=''
    export CYAN=''
    export RED=''
    export BOLD=''
    export DIM=''
    export NC=''
  fi
}
setup_terminal_colors

# ----------------------------------------------------------------------------
# 2. Time & Duration Formatting
# ----------------------------------------------------------------------------
format_duration() {
  local total_seconds="${1:-0}"
  total_seconds="${total_seconds//[^0-9]/}"
  total_seconds="${total_seconds:-0}"

  if [ "$total_seconds" -lt 60 ]; then
    echo "${total_seconds}s"
  else
    local mins=$((total_seconds / 60))
    local secs=$((total_seconds % 60))
    echo "${mins}m ${secs}s"
  fi
}

# ----------------------------------------------------------------------------
# 3. Benchmark Statistics Resolvers
# ----------------------------------------------------------------------------
get_step_stats() {
  local step_key="$1"
  local default_est="${2:-}"
  local file_pattern="${3:-setup_benchmarks_*.json}"
  local values=()
  local m_dir="$WORKSPACE_DIR/metrics"

  if [ -d "$m_dir" ]; then
    for f in "$m_dir"/$file_pattern; do
      if [ -f "$f" ]; then
        local val
        val=$(grep -m1 "\"$step_key\":" "$f" 2>/dev/null | awk -F: '{print $2}' | tr -d ' ,"\r\n' || echo "")
        if [[ "$val" =~ ^[0-9]+$ ]]; then
          values+=("$val")
        fi
      fi
    done
  fi

  local count=${#values[@]}
  if [ $count -eq 0 ]; then
    if [ -n "$default_est" ]; then
      echo "ootusaeg ~${default_est}"
    fi
    return 0
  fi

  local sum=0
  local min=${values[0]}
  local max=${values[0]}
  for val in "${values[@]}"; do
    sum=$((sum + val))
    if [ $val -lt $min ]; then min=$val; fi
    if [ $val -gt $max ]; then max=$val; fi
  done
  local avg=$((sum / count))
  echo "keskmine: $(format_duration $avg) (min: $(format_duration $min), max: $(format_duration $max))"
}

get_total_setup_stats() {
  get_step_stats "total_duration_seconds" "~15 minutit (kui pilte tõmmatakse esimest korda)" "setup_benchmarks_*.json"
}

# ----------------------------------------------------------------------------
# 4. Step Header & Progress Reporting
# ----------------------------------------------------------------------------
print_header() {
  local step_num="$1"
  local title="$2"
  local step_key="${3:-}"
  local default_est="${4:-}"
  local file_pattern="${5:-}"

  echo -e "${CYAN}==================================================================${NC}"
  echo -e "${YELLOW}${step_num}. ${title}${NC}"
  if [ -n "$step_key" ]; then
    local stats
    stats=$(get_step_stats "$step_key" "$default_est" "$file_pattern" 2>/dev/null || echo "")
    if [ -n "$stats" ]; then
      echo -e "   📊 Ajalooline ooteaeg: ${YELLOW}${stats}${NC}"
    fi
  fi
  echo -e "${CYAN}==================================================================${NC}"
}

print_progress() {
  local msg="$1"
  local count="${2:-0}"
  local max="${3:-15}"

  count="${count//[^0-9]/}"
  count="${count:-0}"
  max="${max//[^0-9]/}"
  max="${max:-15}"
  [ "$max" -le 0 ] && max=15

  local width=20
  local progress=$(( (count * width) / max ))
  [ $progress -gt $width ] && progress=$width
  local remaining=$((width - progress))

  local bar=""
  for ((i=0; i<progress; i++)); do bar="${bar}="; done
  [ $progress -lt $width ] && bar="${bar}>"
  for ((i=0; i<remaining; i++)); do bar="${bar} "; done
  bar="${bar:0:$width}"

  local spin_chars=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
  local spin_idx=$(( (count / 2) % ${#spin_chars[@]} ))
  local spin="${spin_chars[$spin_idx]}"

  local dur_str
  dur_str=$(format_duration "$count")

  if [ -c /dev/tty ]; then
    printf "\r\033[K   %s %-32s [%s] %-7s" "$spin" "$msg" "$bar" "$dur_str" > /dev/tty 2>/dev/null || true
  elif [ -t 1 ] || [ -t 2 ]; then
    printf "\r\033[K   %s %-32s [%s] %-7s" "$spin" "$msg" "$bar" "$dur_str" >&2
  else
    # Non-interactive / CI / piped: print progress at reasonable intervals
    if [ $((count % 30)) -eq 0 ] && [ "$count" -gt 0 ]; then
      echo "   ⏳ [Progress] ${msg}... kestus: ${dur_str}"
    fi
  fi
}

clear_progress_line() {
  if [ -t 1 ] || [ -t 2 ]; then
    printf "\r\033[K" >&2
  fi
}

run_with_live_timer() {
  local msg="$1"
  local log_file="$2"
  local est_max="${3:-60}"
  shift 3
  
  local start_time=$(date +%s)
  
  if [ -n "$log_file" ]; then
    "$@" > "$log_file" 2>&1 &
  else
    "$@" > /dev/null 2>&1 &
  fi
  local pid=$!
  
  while kill -0 "$pid" 2>/dev/null; do
    local elapsed=$(( $(date +%s) - start_time ))
    print_progress "$msg" "$elapsed" "$est_max"
    sleep 1
  done
  
  wait "$pid"
  local exit_code=$?
  clear_progress_line
  return $exit_code
}

# ----------------------------------------------------------------------------
# 5. User Interaction & Prompts
# ----------------------------------------------------------------------------
prompt_user_confirm() {
  local question="$1"
  local target_var="$2"
  local timeout_seconds="${3:-30}"
  local default_val="${4:-N}"
  local desc_yes="${5:-Nõustu}"
  local desc_no="${6:-Loobu}"

  if [ "${FORCE:-false}" = "true" ] || [ "${IS_TEST_MODE:-false}" = "true" ]; then
    eval "$target_var=\"$default_val\""
    return 0
  fi

  echo -e "\n${YELLOW}${question}${NC}"
  echo -e "   [Y] - ${desc_yes}"
  echo -e "   [N] - ${desc_no} (Vaikimisi ${timeout_seconds}s möödumisel)"

  local answer=""
  if [ -t 0 ]; then
    read -t "$timeout_seconds" -p "👉 Sinu valik (Y/N, vaikimisi $default_val): " answer || true
    echo ""
  fi

  answer="${answer:-$default_val}"
  eval "$target_var=\"$answer\""
}

# ----------------------------------------------------------------------------
# 6. Process & Signal Cleanup Traps
# ----------------------------------------------------------------------------
_ORACLE_REGISTERED_PIDS=()

register_child_pid() {
  local pid="$1"
  [ -n "$pid" ] && _ORACLE_REGISTERED_PIDS+=("$pid")
}

cleanup_child_processes() {
  for pid in "${_ORACLE_REGISTERED_PIDS[@]}"; do
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
      kill -TERM "$pid" 2>/dev/null || kill -KILL "$pid" 2>/dev/null || true
    fi
  done
  _ORACLE_REGISTERED_PIDS=()
}

trap 'cleanup_child_processes' INT TERM

# ----------------------------------------------------------------------------
# 7. Fast Compression Engine (Multi-threaded pigz fallback)
# ----------------------------------------------------------------------------
get_fast_gzip_cmd() {
  if command -v pigz >/dev/null 2>&1; then
    local cores
    cores=$(getconf _NPROCESSORS_ONLN 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 2)
    echo "pigz -p ${cores:-2}"
  else
    echo "gzip"
  fi
}

get_fast_gunzip_cmd() {
  if command -v unpigz >/dev/null 2>&1; then
    echo "unpigz"
  elif command -v pigz >/dev/null 2>&1; then
    echo "pigz -d"
  else
    echo "gunzip"
  fi
}
