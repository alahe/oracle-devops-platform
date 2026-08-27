#!/usr/bin/env bash
# ============================================================================
# Log Sanitizer Utility: Masks tokens, Bearer headers, and URL passwords
# Reusable stream filter for stdout/stderr and install_logs/*.log
# ============================================================================

sanitize_text() {
  if [ "${DEBUG_LOG_UNSANITIZED:-false}" = "true" ] || [ "${SHOW_SENSITIVE_TOKENS:-false}" = "true" ]; then
    cat
    return 0
  fi
  # Use -u (unbuffered) so stream flushes immediately without block buffering
  sed -u -E \
    -e 's/(token=)[^&"'\''[:space:]]+/\1***MASKED***/gI' \
    -e 's/(ACCESS_TOKEN=)[^"'\''[:space:]]+/\1***MASKED***/gI' \
    -e 's/(Bearer[[:space:]]+)[^"'\''[:space:]]+/\1***MASKED***/gI' \
    -e 's/(Authorization:[[:space:]]*[A-Za-z0-9_]+[[:space:]]+)[^"'\''[:space:]]+/\1***MASKED***/gI' \
    -e 's/(ARTIFACTORY_TOKEN=)[^"'\''[:space:]]+/\1***MASKED***/gI' \
    -e 's/(PUBLISHER_DOWNLOAD_TOKEN=)[^"'\''[:space:]]+/\1***MASKED***/gI' \
    -e 's/(GITHUB_TOKEN=)[^"'\''[:space:]]+/\1***MASKED***/gI' \
    -e 's/(password=)[^&"'\''[:space:]]+/\1***MASKED***/gI'
}

# Reusable progress indicator for long-running setup loops (Option C: Dual-Stream TTY/Log)
# - Screen / /dev/tty: Overwrites line using \r in real-time
# - Log stream / Pipe: Emits periodic clean \n line every N seconds (default 15s)
print_step_progress() {
  local msg="$1"
  local elapsed="$2"
  local interval="${3:-}"
  interval="${interval//[^0-9]/}"
  interval="${interval:-${PROGRESS_INTERVAL:-7}}"
  local elapsed_num="${elapsed//[^0-9]/}"
  elapsed_num="${elapsed_num:-0}"
  local formatted_time=""

  if declare -f format_duration >/dev/null 2>&1; then
    formatted_time="$(format_duration "$elapsed_num")"
  else
    local m=$((elapsed_num / 60))
    local s=$((elapsed_num % 60))
    formatted_time="${m}m ${s}s"
  fi

  if [ -t 1 ]; then
    # Interactive stdout TTY: update single line in-place
    printf "\r\033[K   ⏳ %s... kestus: \033[1;33m%s\033[0m" "$msg" "$formatted_time"
  elif ( true >/dev/tty ) 2>/dev/null; then
    # Direct TTY available: update single line in-place
    printf "\r\033[K   ⏳ %s... kestus: \033[1;33m%s\033[0m" "$msg" "$formatted_time" > /dev/tty 2>/dev/null || true
  else
    # Piped / Log stream: emit clean progress line every interval (default 7s)
    if [ "$interval" -gt 0 ] && [ $((elapsed_num % interval)) -eq 0 ] && [ "$elapsed_num" -gt 0 ]; then
      echo -e "   ⏳ ${msg}... kestus: ${formatted_time}"
    fi
  fi
}

export -f sanitize_text 2>/dev/null || true
export -f print_step_progress 2>/dev/null || true

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  sanitize_text
fi
