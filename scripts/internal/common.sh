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

# Source central localization engine
if [ -f "$_COMMON_DIR/i18n.sh" ]; then
  # shellcheck source=/dev/null
  source "$_COMMON_DIR/i18n.sh"
fi

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
# 2.5 Custom Image Naming & In-DB Version Detection (Auto-Tagging)
# ----------------------------------------------------------------------------
format_custom_image_tag() {
  local db_ver="${1:-23ai}"
  local apex_ver="${2:-26.1}"
  local ords_ver="${3:-}"
  local flavor="${4:-}"

  # Clean DB version (e.g. 23.4.0.24.05 -> 23ai or 23.4)
  if [[ "$db_ver" =~ ^23\.[0-9] ]] || [ "$db_ver" = "23" ]; then
    db_ver="23ai"
  elif [[ "$db_ver" =~ ^19\.[0-9] ]] || [ "$db_ver" = "19" ]; then
    db_ver="19c"
  elif [[ "$db_ver" =~ ^21\.[0-9] ]] || [ "$db_ver" = "21" ]; then
    db_ver="21c"
  fi

  # Clean APEX version (e.g. 26.1.0.123 -> 26.1)
  if [[ "$apex_ver" =~ ^([0-9]+\.[0-9]+) ]]; then
    apex_ver="${BASH_REMATCH[1]}"
  fi

  # Clean ORDS version (e.g. 26.2.2.r... -> 26.2)
  if [ -n "$ords_ver" ] && [[ "$ords_ver" =~ ^([0-9]+\.[0-9]+) ]]; then
    ords_ver="${BASH_REMATCH[1]}"
  fi

  local tag_result="$db_ver"
  if [ -n "$flavor" ]; then
    tag_result="${tag_result}-${flavor}"
  fi

  if [ -n "$apex_ver" ] && [ "$apex_ver" != "NONE" ]; then
    tag_result="${tag_result}-apex${apex_ver}"
  fi

  if [ -n "$ords_ver" ] && [ "$ords_ver" != "NONE" ]; then
    tag_result="${tag_result}-ords${ords_ver}"
  fi

  echo "$tag_result"
}

# ----------------------------------------------------------------------------
# 2.5 Standardized In-Container SQLcl Invocation (Rule 6)
# ----------------------------------------------------------------------------
run_container_sqlcl() {
  local target="$1"
  shift
  local cli="podman"
  if ! command -v podman >/dev/null 2>&1 && command -v docker >/dev/null 2>&1; then
    cli="docker"
  fi

  local in_c_sql
  in_c_sql=$($cli exec "$target" bash -c 'ls -d /opt/oracle/product/*/dbhomeFree/sqlcl/bin/sql 2>/dev/null | head -n 1' 2>/dev/null || echo "")
  if [ -n "$in_c_sql" ]; then
    $cli exec -i "$target" "$in_c_sql" "$@"
    return $?
  elif $cli exec "$target" bash -c 'command -v sqlplus >/dev/null 2>&1'; then
    $cli exec -i "$target" sqlplus "$@"
    return $?
  fi

  if [ -x "$WORKSPACE_DIR/scripts/sqlcl.sh" ]; then
    "$WORKSPACE_DIR/scripts/sqlcl.sh" "$@"
    return $?
  fi
  return 1
}

detect_container_db_versions() {
  local c_name="$1"
  [ -z "$c_name" ] && return 1

  local cli="podman"
  if ! command -v podman >/dev/null 2>&1 && command -v docker >/dev/null 2>&1; then
    cli="docker"
  fi

  local db_info=""
  local in_c_sql
  in_c_sql=$($cli exec "$c_name" bash -c 'ls -d /opt/oracle/product/*/dbhomeFree/sqlcl/bin/sql 2>/dev/null | head -n 1' 2>/dev/null || echo "")
  local sql_script="SET FEEDBACK OFF
SET HEADING OFF
SET PAGESIZE 0
SET VERIFY OFF
BEGIN
  FOR p IN (SELECT name FROM v\$pdbs WHERE open_mode = 'READ WRITE' AND name != 'PDB\$SEED' AND ROWNUM = 1) LOOP
    EXECUTE IMMEDIATE 'ALTER SESSION SET CONTAINER = ' || p.name;
  END LOOP;
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
SELECT (SELECT version_full FROM v\$instance) || '|' ||
       NVL((SELECT version FROM dba_registry WHERE comp_id = 'APEX'), 'NONE') || '|' ||
       NVL((SELECT version FROM ords_metadata.ords_version WHERE ROWNUM = 1), 'NONE')
FROM dual;
EXIT;
"
  if [ -n "$in_c_sql" ]; then
    db_info=$(printf "%s\n" "$sql_script" | $cli exec -i "$c_name" "$in_c_sql" -s / as sysdba 2>/dev/null | grep "|" | tr -d ' \r\n' | head -n 1 || echo "")
  elif $cli exec "$c_name" bash -c 'command -v sqlplus >/dev/null 2>&1'; then
    db_info=$(printf "%s\n" "$sql_script" | $cli exec -i "$c_name" bash -c 'sqlplus -s / as sysdba' 2>/dev/null | grep "|" | tr -d ' \r\n' | head -n 1 || echo "")
  fi

  if [ -n "$db_info" ]; then
    local d_ver=$(echo "$db_info" | cut -d'|' -f1)
    local a_ver=$(echo "$db_info" | cut -d'|' -f2)
    local o_ver=$(echo "$db_info" | cut -d'|' -f3)

    if [[ "$d_ver" =~ ^23\. ]]; then
      d_ver="23ai"
    elif [[ "$d_ver" =~ ^26\. ]]; then
      d_ver="26ai"
    fi
    echo "${d_ver}:${a_ver}:${o_ver}"
  else
    echo "23ai:26.1:NONE"
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
      msg_str "BENCHMARK_EST" "$default_est"
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
  msg_str "BENCHMARK_AVG" "$(format_duration $avg)"
}

get_total_setup_stats() {
  get_step_stats "total_duration_seconds" "~15m" "setup_benchmarks_*.json"
}

get_blueprint_stats() {
  local bp_id="$1"
  local m_dir="$WORKSPACE_DIR/metrics"
  local bp_file="$m_dir/blueprint_${bp_id}_benchmarks.json"
  [ ! -f "$bp_file" ] && bp_file="$m_dir/blueprint_${bp_id}_benchmark.json"
  if [ ! -f "$bp_file" ]; then
    echo ""
    return 0
  fi

  python3 -c "
import json, sys
try:
    data = json.load(open('$bp_file'))
    avg = data.get('average_duration_seconds', 0)
    min_d = data.get('min_duration_seconds', 0)
    max_d = data.get('max_duration_seconds', 0)
    cnt = data.get('runs_count', len(data.get('history', [])))
    def fmt(s):
        return f'{s}s' if s < 60 else f'{s//60}m {s%60}s'
    if cnt > 0:
        print(f'avg: {fmt(avg)} (min: {fmt(min_d)}, max: {fmt(max_d)}, measurements: {cnt})')
except Exception:
    pass
" 2>/dev/null || echo ""
}

save_blueprint_benchmark() {
  local bp_id="$1"
  local duration_secs="$2"
  [ -z "$bp_id" ] || [ -z "$duration_secs" ] && return 0
  local m_dir="$WORKSPACE_DIR/metrics"
  mkdir -p "$m_dir"
  local bp_file="$m_dir/blueprint_${bp_id}_benchmarks.json"

  python3 -c "
import json, os, datetime
p = '$bp_file'
d = int('$duration_secs')
now_str = datetime.datetime.now().isoformat()
data = {'blueprint_id': int('$bp_id'), 'history': []}
if os.path.exists(p):
    try:
        data = json.load(open(p))
    except Exception:
        pass
hist = data.get('history', [])
hist.append({'timestamp': now_str, 'duration_seconds': d})
durations = [h.get('duration_seconds', 0) for h in hist if isinstance(h, dict) and 'duration_seconds' in h]
data['history'] = hist
data['runs_count'] = len(durations)
if durations:
    data['average_duration_seconds'] = int(sum(durations) / len(durations))
    data['min_duration_seconds'] = min(durations)
    data['max_duration_seconds'] = max(durations)
with open(p, 'w') as f:
    json.dump(data, f, indent=2)
" 2>/dev/null || true
}

# ----------------------------------------------------------------------------
# 3.5 Container Secret Helper (SEPS / Podman Secrets)
# ----------------------------------------------------------------------------
get_container_secret() {
  local container="$1"
  local name="$2"
  local val=""

  # 1. Container-specific secret names (e.g. proxy_dev_password, proxy_db_sys_password)
  if [ -n "$container" ]; then
    local c_short=$(echo "$container" | sed 's/^db-//' | tr '-' '_')
    val=$(podman secret inspect --showsecret "${c_short}_${name}" 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
    [ -z "$val" ] && val=$(podman secret inspect --showsecret "${c_short}_db_${name}" 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
    [ -z "$val" ] && val=$(podman secret inspect --showsecret "${container}_${name}" 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
  fi

  # 2. Direct match for generic secret name (fallback)
  if [ -z "$val" ]; then
    val=$(podman secret inspect --showsecret "$name" 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
  fi

  # 3. Running container /run/secrets/ files
  if [ -z "$val" ] && [ -n "$container" ] && podman container exists "$container" 2>/dev/null; then
    val=$(podman exec "$container" cat "/run/secrets/$name" 2>/dev/null | tr -d '\r\n' || true)
  fi

  echo "$val"
}

# ----------------------------------------------------------------------------
# 4. Terminal Cursor & Live Progress Engine
# ----------------------------------------------------------------------------
LIVE_TIMER_INTERVAL="${LIVE_TIMER_INTERVAL:-3}"

hide_cursor() {
  if [ -t 3 ]; then
    printf "\033[?25l" >&3 2>/dev/null || true
  elif [ -t 1 ] && [ -c /dev/tty ]; then
    printf "\033[?25l" > /dev/tty 2>/dev/null || true
  elif [ -t 1 ] || [ -t 2 ]; then
    tput civis 2>/dev/null || printf "\033[?25l" 2>/dev/null || true
  fi
}

restore_cursor() {
  if [ -t 3 ]; then
    printf "\033[?25h" >&3 2>/dev/null || true
  elif [ -t 1 ] && [ -c /dev/tty ]; then
    printf "\033[?25h" > /dev/tty 2>/dev/null || true
  elif [ -t 1 ] || [ -t 2 ]; then
    tput cnorm 2>/dev/null || printf "\033[?25h" 2>/dev/null || true
  fi
}

show_cursor() {
  restore_cursor "$@"
}

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
      echo -e "   📊 $(msg_str "BENCHMARK_LABEL") ${YELLOW}${stats}${NC}"
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

  if [ -t 3 ]; then
    printf "\r\033[K   %s %-32s [%s] %-7s" "$spin" "$msg" "$bar" "$dur_str" >&3
  elif ( true >/dev/tty ) 2>/dev/null; then
    printf "\r\033[K   %s %-32s [%s] %-7s" "$spin" "$msg" "$bar" "$dur_str" > /dev/tty 2>/dev/null || true
  elif [ -t 1 ] || [ -t 2 ]; then
    printf "\r\033[K   %s %-32s [%s] %-7s" "$spin" "$msg" "$bar" "$dur_str" >&2
  else
    # Non-interactive / CI / piped: print progress at interval
    local int_val="${LIVE_TIMER_INTERVAL:-3}"
    int_val="${int_val//[^0-9]/}"
    [ -z "$int_val" ] || [ "$int_val" -le 0 ] && int_val=3
    local dur_lbl="duration"
    if declare -f msg_str >/dev/null 2>&1; then
      dur_lbl="$(msg_str "LABEL_DURATION")"
    fi
    if [ $((count % (int_val * 2))) -eq 0 ] && [ "$count" -gt 0 ]; then
      echo "   ⏳ [Progress] ${msg}... ${dur_lbl}: ${dur_str}"
    fi
  fi
}

clear_progress_line() {
  if [ -t 3 ]; then
    printf "\r\033[K" >&3
  elif ( true >/dev/tty ) 2>/dev/null; then
    printf "\r\033[K" > /dev/tty 2>/dev/null || true
  elif [ -t 1 ] || [ -t 2 ]; then
    printf "\r\033[K" >&2
  fi
}

run_with_live_timer() {
  local msg="$1"
  local log_file="$2"
  local est_max="${3:-60}"
  shift 3
  
  local start_time=$(date +%s)
  local interval="${LIVE_TIMER_INTERVAL:-3}"
  interval="${interval//[^0-9]/}"
  [ -z "$interval" ] || [ "$interval" -le 0 ] && interval=3

  hide_cursor
  if [ -n "$log_file" ]; then
    "$@" > "$log_file" 2>&1 &
  else
    "$@" > /dev/null 2>&1 &
  fi
  local pid=$!
  
  while kill -0 "$pid" 2>/dev/null; do
    local elapsed=$(( $(date +%s) - start_time ))
    print_progress "$msg" "$elapsed" "$est_max"
    sleep "$interval"
  done
  
  wait "$pid"
  local exit_code=$?
  clear_progress_line
  restore_cursor
  return $exit_code
}

run_substep() {
  local sub_id="$1"
  local title="$2"
  local is_last="${3:-false}"
  local log_file="${4:-}"
  local est_secs="${5:-15}"
  shift 5

  local branch="├─"
  [ "$is_last" = "true" ] && branch="└─"

  local start_t=$(date +%s)
  hide_cursor
  if [ -n "$log_file" ]; then
    "$@" > "$log_file" 2>&1 &
  else
    "$@" > /dev/null 2>&1 &
  fi
  local pid=$!

  local interval="${LIVE_TIMER_INTERVAL:-3}"
  interval="${interval//[^0-9]/}"
  [ -z "$interval" ] || [ "$interval" -le 0 ] && interval=3

  while kill -0 "$pid" 2>/dev/null; do
    local elapsed=$(( $(date +%s) - start_t ))
    local dur_str=$(format_duration "$elapsed")
    if [ -t 3 ]; then
      printf "\r\033[K   ${CYAN}%s${NC} [Alamsamm %s]: %s... ⏳ %s" "$branch" "$sub_id" "$title" "$dur_str" >&3
    elif ( true >/dev/tty ) 2>/dev/null; then
      printf "\r\033[K   ${CYAN}%s${NC} [Alamsamm %s]: %s... ⏳ %s" "$branch" "$sub_id" "$title" "$dur_str" > /dev/tty 2>/dev/null || true
    elif [ -t 1 ] || [ -t 2 ]; then
      printf "\r\033[K   ${CYAN}%s${NC} [Alamsamm %s]: %s... ⏳ %s" "$branch" "$sub_id" "$title" "$dur_str" >&2
    fi
    sleep "$interval"
  done

  wait "$pid"
  local exit_code=$?
  local total_dur=$(( $(date +%s) - start_t ))
  local total_str=$(format_duration "$total_dur")
  clear_progress_line
  restore_cursor

  if [ $exit_code -eq 0 ]; then
    echo -e "   ${CYAN}${branch}${NC} [Step ${sub_id}]: ${title}... ${GREEN}✅ [Done: ${total_str}]${NC}"
  else
    echo -e "   ${CYAN}${branch}${NC} [Step ${sub_id}]: ${title}... ${RED}❌ [Error code ${exit_code}]${NC}"
  fi
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
  local desc_yes="${5:-Yes}"
  local desc_no="${6:-No}"

  if [ "${FORCE:-false}" = "true" ] || [ "${IS_TEST_MODE:-false}" = "true" ]; then
    eval "$target_var=\"$default_val\""
    return 0
  fi

  echo -e "\n${YELLOW}${question}${NC}"
  echo -e "   [Y] - ${desc_yes}"
  echo -e "   [N] - ${desc_no} (Default after ${timeout_seconds}s)"

  local answer=""
  if [ -t 0 ]; then
    read -t "$timeout_seconds" -p "👉 Your choice (Y/N, default $default_val): " answer || true
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
  restore_cursor
  if [ -n "${_ORACLE_REGISTERED_PIDS+x}" ] && [ ${#_ORACLE_REGISTERED_PIDS[@]} -gt 0 ]; then
    for pid in "${_ORACLE_REGISTERED_PIDS[@]}"; do
      if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
        kill -TERM "$pid" 2>/dev/null || kill -KILL "$pid" 2>/dev/null || true
      fi
    done
  fi
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
