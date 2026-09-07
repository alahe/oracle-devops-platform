#!/usr/bin/env bash
# ============================================================================
# Oracle DevOps Platform — Blueprint Discovery, Inspection & CLI Engine
# (scripts/internal/blueprint-info.sh)
#
# Provides dynamic blueprint inspection, ASCII table formatting, detailed
# container breakdowns, dry-run simulations, and test report listings.
# Used by setup-all.sh, test runners, and developer CLI tools.
# ============================================================================

set -e

# Use isolated local script directory variable to avoid caller pollution
_BP_INFO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$_BP_INFO_DIR/../.." && pwd)"

# Color definitions
CYAN=$'\033[1;36m'
GREEN=$'\033[1;32m'
RED=$'\033[1;31m'
YELLOW=$'\033[0;33m'
BOLD=$'\033[1m'
BLUE=$'\033[1;34m'
MAGENTA=$'\033[1;35m'
NC=$'\033[0m'

BLUEPRINTS_DIR="$WORKSPACE_DIR/config/blueprints"

# ----------------------------------------------------------------------------
# ----------------------------------------------------------------------------
# 1. Helper: Resolve Blueprint File Path by Number or Name
# ----------------------------------------------------------------------------
get_blueprint_file() {
  local query="$1"
  [ -z "$query" ] && return 1

  # If query is already an existing file path
  if [ -f "$query" ]; then
    echo "$query"
    return 0
  fi

  local bp_file=""

  # If query is purely numeric
  if [[ "$query" =~ ^[0-9]+$ ]]; then
    bp_file=$(find "$BLUEPRINTS_DIR" -maxdepth 1 -type f \( -name ".env.${query}-*" -o -name ".env.${query}" \) 2>/dev/null | head -n 1)
  else
    # Query is a string/name (e.g. "forms-with-embedded-ords", "publisher-dedicated", "ultimate")
    local clean_q
    clean_q=$(echo "$query" | tr '[:upper:]' '[:lower:]' | sed -E 's/^\.env\.//; s/^[0-9]+[-_]//')
    bp_file=$(find "$BLUEPRINTS_DIR" -maxdepth 1 -type f -iname ".env.*-${clean_q}*" 2>/dev/null | head -n 1)
    if [ -z "$bp_file" ]; then
      bp_file=$(find "$BLUEPRINTS_DIR" -maxdepth 1 -type f -iname ".env.*${clean_q}*" 2>/dev/null | head -n 1)
    fi
  fi

  if [ -n "$bp_file" ] && [ -f "$bp_file" ]; then
    echo "$bp_file"
    return 0
  fi
  return 1
}

# ----------------------------------------------------------------------------
# 1.1 Helper: Extract Blueprint Number from File or Query
# ----------------------------------------------------------------------------
get_blueprint_number() {
  local query="$1"
  local bp_file
  bp_file=$(get_blueprint_file "$query" 2>/dev/null || echo "")
  if [ -n "$bp_file" ]; then
    local bname
    bname=$(basename "$bp_file")
    echo "$bname" | sed -E 's/^\.env\.([0-9]+).*/\1/'
    return 0
  fi
  local num
  num=$(echo "$query" | sed -E 's/.*\.env\.([0-9]+).*/\1/; s/[^0-9]//g')
  if [ -n "$num" ]; then
    echo "$num"
    return 0
  fi
  return 1
}

# ----------------------------------------------------------------------------
# 2. Helper: Extract Blueprint Metadata (Title & Description)
# ----------------------------------------------------------------------------
get_blueprint_meta() {
  local query="$1"
  local bp_file
  bp_file=$(get_blueprint_file "$query") || return 1

  local num
  num=$(get_blueprint_number "$query" 2>/dev/null || echo "")

  local title=""
  local desc=""

  title=$(grep -m 1 -E "^# Blueprint [0-9]+:|^# STSENAARIUM|^# SCENARIO|^# BLUEPRINT" "$bp_file" 2>/dev/null | sed -E 's/^#[[:space:]]*//' || echo "")
  if [ -z "$title" ]; then
    title=$(head -n 1 "$bp_file" 2>/dev/null | grep "^#" | sed -E 's/^#[[:space:]]*//' || echo "")
  fi

  desc=$(grep -m 1 -E "^# Usage:|^# Description:|^# Purpose:" "$bp_file" 2>/dev/null | sed -E 's/^#[[:space:]]*(Usage:|Description:|Purpose:)[[:space:]]*//' || echo "")
  if [ -z "$desc" ]; then
    desc=$(sed -n '2p' "$bp_file" 2>/dev/null | grep "^#" | sed -E 's/^#[[:space:]]*//' || echo "")
  fi

  if [ -z "$title" ]; then
    title="Blueprint ${num} ($(basename "$bp_file"))"
  fi
  if [ -z "$desc" ]; then
    desc="Configuration Blueprint ${num}"
  fi

  echo "${title}:::${desc}"
}

# ----------------------------------------------------------------------------
# 3. Dynamic Container Extraction Engine
# ----------------------------------------------------------------------------
extract_blueprint_containers() {
  local query="$1"
  local bp_file
  bp_file=$(get_blueprint_file "$query") || return 1

  local db_publisher=""
  local db_proxy=""
  local db_alise=""
  local db_publisher=""
  local db_forms=""
  local web_ide_prof=""
  local ords_prof=""
  local publisher_prof=""
  local forms_prof=""
  local designer_prof=""
  local forms_publisher_prof=""

  # Parse variables directly from file safely
  local db_profs=()
  for k in $(grep -E "^DB_[A-Z0-9_]+=" "$bp_file" 2>/dev/null | cut -d'=' -f2 | tr -d ' "\r\n' || true); do
    [ -n "$k" ] && [ "$k" != "NONE" ] && db_profs+=("$k")
  done
  web_ide_prof=$(grep -E "^WEB_IDE_PROFILE=" "$bp_file" 2>/dev/null | cut -d'=' -f2 | tr -d ' "\r\n' || echo "")
  ords_prof=$(grep -E "^ORDS_PROFILE=" "$bp_file" 2>/dev/null | cut -d'=' -f2 | tr -d ' "\r\n' || echo "")
  publisher_prof=$(grep -E "^PUBLISHER_PROFILE=" "$bp_file" 2>/dev/null | cut -d'=' -f2 | tr -d ' "\r\n' || echo "")
  forms_prof=$(grep -E "^FORMS_PROFILE=" "$bp_file" 2>/dev/null | cut -d'=' -f2 | tr -d ' "\r\n' || echo "")
  designer_prof=$(grep -E "^PUBLISHER_DESIGNER_PROFILE=" "$bp_file" 2>/dev/null | cut -d'=' -f2 | tr -d ' "\r\n' || echo "")
  forms_publisher_prof=$(grep -E "^FORMS_PUBLISHER_PROFILE=" "$bp_file" 2>/dev/null | cut -d'=' -f2 | tr -d ' "\r\n' || echo "")

  local containers=()

  # Database containers
  for prof in "${db_profs[@]}"; do
    [ -z "$prof" ] || [ "$prof" = "NONE" ] && continue
    local pfile="$WORKSPACE_DIR/config/profiles/databases/${prof}.yaml"
    [ ! -f "$pfile" ] && pfile="$WORKSPACE_DIR/config/profiles/${prof}.yaml"
    local c_name=""
    if [ -f "$pfile" ]; then
      c_name=$(grep -E '^[[:space:]]*container_name:' "$pfile" | head -n 1 | sed -E 's/.*:[[:space:]]*"?([^" #]+)"?.*/\1/' | tr -d '\r\n')
    fi
    [ -z "$c_name" ] && c_name="db-${prof#db-}"
    if [[ ! " ${containers[*]} " =~ " ${c_name} " ]]; then
      containers+=("$c_name")
    fi
  done

  # Check embedded ORDS enablement from DB profiles
  local has_db_ords=false
  for prof in "${db_profs[@]}"; do
    [ -z "$prof" ] || [ "$prof" = "NONE" ] && continue
    local pfile="$WORKSPACE_DIR/config/profiles/databases/${prof}.yaml"
    [ ! -f "$pfile" ] && pfile="$WORKSPACE_DIR/config/profiles/${prof}.yaml"
    if [ -f "$pfile" ]; then
      local o_en
      o_en=$(awk '/ords:/{flag=1;next}/forms:|apex:|publisher:|users:/{flag=0}flag' "$pfile" | grep -E '^[[:space:]]*enabled:' | head -n 1 | sed -E 's/.*:[[:space:]]*"?([^" #]+)"?.*/\1/' | tr -d '\r\n')
      if [ "$o_en" = "true" ]; then
        has_db_ords=true
        break
      fi
    fi
  done

  # Application containers
  if [ -n "$ords_prof" ] && [ "$ords_prof" != "NONE" ] && [ "$ords_prof" != "disabled" ]; then
    containers+=("app-ords")
  elif [ "$ords_prof" != "NONE" ] && [ "$ords_prof" != "disabled" ] && [ "$has_db_ords" = "true" ]; then
    containers+=("app-ords")
  fi

  if [ -n "$publisher_prof" ] && [ "$publisher_prof" != "NONE" ] && [ "$publisher_prof" != "disabled" ]; then
    containers+=("app-publisher")
  elif [ -n "$db_publisher" ] && [ "$db_publisher" != "NONE" ] && [ -n "$publisher_prof" ] && [ "$publisher_prof" != "NONE" ]; then
    containers+=("app-publisher")
  fi

  if [ -n "$forms_prof" ] && [ "$forms_prof" != "NONE" ] && [ "$forms_prof" != "disabled" ]; then
    containers+=("app-forms")
  elif [ -n "$db_forms" ] && [ "$db_forms" != "NONE" ] && [ -n "$forms_prof" ] && [ "$forms_prof" != "NONE" ]; then
    containers+=("app-forms")
  fi

  if [ -n "$designer_prof" ] && [ "$designer_prof" != "NONE" ] && [ "$designer_prof" != "disabled" ]; then
    containers+=("app-publisher-designer")
  fi

  if [ -n "$forms_publisher_prof" ] && [ "$forms_publisher_prof" != "NONE" ]; then
    local pfile="$WORKSPACE_DIR/config/profiles/forms-publisher/${forms_publisher_prof}.yaml"
    [ ! -f "$pfile" ] && pfile="$WORKSPACE_DIR/config/profiles/${forms_publisher_prof}.yaml"
    local c_name=""
    if [ -f "$pfile" ]; then
      c_name=$(grep -E '^[[:space:]]*container_name:' "$pfile" | head -n 1 | sed -E 's/.*:[[:space:]]*"?([^" #]+)"?.*/\1/' | tr -d '\r\n')
    fi
    if [ "$c_name" = "app-forms-publisher" ] && ! podman container exists app-forms-publisher 2>/dev/null; then
      [[ ! " ${containers[*]} " =~ " app-forms " ]] && containers+=("app-forms")
      [[ ! " ${containers[*]} " =~ " app-publisher " ]] && containers+=("app-publisher")
    else
      [ -z "$c_name" ] && c_name="app-forms-publisher"
      if [[ ! " ${containers[*]} " =~ " ${c_name} " ]]; then
        containers+=("$c_name")
      fi
    fi
  fi

  # Web IDE container detection
  if [ -n "$web_ide_prof" ] && [ "$web_ide_prof" != "NONE" ] && [ "$web_ide_prof" != "web-ide-disabled" ] && [ "$web_ide_prof" != "disabled" ] && [ "$web_ide_prof" != "false" ]; then
    containers+=("web-ide-dev")
  fi

  echo "${containers[*]}"
}

# ----------------------------------------------------------------------------
# 4. Print Dynamic Blueprints ASCII Table (Grouped by Decade Series)
# ----------------------------------------------------------------------------
print_blueprints_table() {
  local filter="${1:-}"
  filter=$(echo "$filter" | tr '[:upper:]' '[:lower:]')

  echo -e "\n${CYAN}==================================================================${NC}"
  echo -e "${BOLD}🚀 ORACLE DEVOPS PLATFORM — ARCHITECTURAL BLUEPRINTS${NC}"
  echo -e "${CYAN}==================================================================${NC}"

  # Find all blueprints and sort numerically
  local all_files=()
  while IFS= read -r f; do
    [ -n "$f" ] && all_files+=("$f")
  done < <(find "$BLUEPRINTS_DIR" -maxdepth 1 -type f -name ".env.*" 2>/dev/null | sed -E 's/.*\.env\.([0-9]+).*/\1 &/' | sort -n -k1,1 | awk '{print $2}')

  local last_group=""
  local match_count=0

  for bp_file in "${all_files[@]}"; do
    local bp_name
    bp_name=$(basename "$bp_file" | sed -E 's/^\.env\.//')
    local num
    num=$(echo "$bp_name" | sed -E 's/^([0-9]+).*/\1/')

    # Extract containers
    local containers
    containers=$(extract_blueprint_containers "$num" 2>/dev/null || echo "")
    containers="${containers:-None}"

    # Extract metadata
    local meta
    meta=$(get_blueprint_meta "$num" 2>/dev/null || echo "")
    local desc
    desc=$(echo "$meta" | awk -F':::' '{print $2}')
    [ -z "$desc" ] && desc=$(echo "$meta" | awk -F':::' '{print $1}')

    # Apply optional filter
    if [ -n "$filter" ]; then
      local combined_text="$num $bp_name $containers $desc"
      if ! echo "$combined_text" | grep -qi -- "$filter"; then
        continue
      fi
    fi

    match_count=$((match_count + 1))

    # Group header
    local cur_group=""
    if [ "$num" -eq 0 ]; then
      cur_group="Default Standard"
    elif [ "$num" -le 4 ]; then
      cur_group="Database Stacks (1–4)"
    elif [ "$num" -le 7 ]; then
      cur_group="Enterprise Middleware (5–7)"
    elif [ "$num" -le 9 ]; then
      cur_group="Developer Studio (8–9)"
    else
      cur_group="Remote & Edge Gateways (10–11)"
    fi

    if [ -z "$filter" ] && [ "$cur_group" != "$last_group" ]; then
      echo -e "\n ${BOLD}🔹 ${cur_group}:${NC}"
      last_group="$cur_group"
    fi

    local tag=""
    if [ "$num" -eq 0 ]; then
      tag=" ${GREEN}(Default)${NC}"
    fi

    printf "   ${CYAN}[%2d]${NC} ${BOLD}%-35s${NC} ${YELLOW}%-28s${NC}%b\n" "$num" "$bp_name" "$containers" "$tag"
  done

  if [ -n "$filter" ] && [ "$match_count" -eq 0 ]; then
    echo -e "   ℹ️  No blueprints found matching search keyword: '${YELLOW}$filter${NC}'"
  fi

  echo -e "\n${CYAN}==================================================================${NC}"
  echo -e "💡 Commands:  ${YELLOW}-b <NUM>${NC} (Deploy) | ${YELLOW}-tb <NUM>${NC} (Test) | ${YELLOW}-sb <NUM>${NC} (Inspect)\n"
}

# ----------------------------------------------------------------------------
# 5. Show Detailed Blueprint Inspection Breakdown
# ----------------------------------------------------------------------------
show_blueprint_details() {
  local query="$1"
  local bp_file
  bp_file=$(get_blueprint_file "$query")

  if [ -z "$bp_file" ] || [ ! -f "$bp_file" ]; then
    echo -e "\n${RED}❌ ERROR: Blueprint '${query}' not found!${NC}"
    echo -e "ℹ️  Use command: ${CYAN}./scripts/setup-all.sh --list-blueprints${NC} to view available blueprints.\n"
    return 1
  fi

  local num
  num=$(get_blueprint_number "$query")
  local bp_name
  bp_name=$(basename "$bp_file")
  local meta
  meta=$(get_blueprint_meta "$num")
  local title
  title=$(echo "$meta" | awk -F':::' '{print $1}')
  local desc
  desc=$(echo "$meta" | awk -F':::' '{print $2}')

  local containers
  containers=$(extract_blueprint_containers "$num")

  echo -e "\n${CYAN}==================================================================${NC}"
  echo -e "${BOLD}🏗️   DETAILED BLUEPRINT INSPECTION${NC}"
  echo -e "${CYAN}==================================================================${NC}"
  echo -e "🔹 ${BOLD}Number:${NC}        ${YELLOW}$num${NC}"
  echo -e "🔹 ${BOLD}Blueprint file:${NC} ${CYAN}$bp_name${NC}"
  echo -e "🔹 ${BOLD}Title:${NC}          ${BOLD}$title${NC}"
  echo -e "🔹 ${BOLD}Description:${NC}    $desc"

  local bp_stats=""
  if [ -f "$WORKSPACE_DIR/scripts/internal/common.sh" ]; then
    bp_stats=$(get_blueprint_stats "$num" 2>/dev/null || echo "")
  fi
  if [ -n "$bp_stats" ]; then
    local hist_lbl="Historical duration"
    if declare -f msg_str >/dev/null 2>&1; then
      hist_lbl="$(msg_str "LABEL_HIST_DURATION")"
    fi
    echo -e "🔹 ${BOLD}${hist_lbl}:${NC} ${YELLOW}$bp_stats${NC}"
  fi

  echo -e "\n🔹 ${BOLD}Planned containers to start:${NC}"
  for c in $containers; do
    case "$c" in
      db-publisher|db-publisher-*)
        local pfile="$WORKSPACE_DIR/config/profiles/databases/${c}.yaml"
        [ ! -f "$pfile" ] && pfile="$WORKSPACE_DIR/config/profiles/databases/db-publisher-oracle.yaml"
        p_port=$(grep -E '^[[:space:]]*db_port:' "$pfile" 2>/dev/null | head -n 1 | awk -F: '{print $2}' | sed -E 's/#.*//' | tr -d ' "\r\n')
        p_svc=$(grep -E '^[[:space:]]*default_service:' "$pfile" 2>/dev/null | head -n 1 | awk -F: '{print $2}' | sed -E 's/#.*//' | tr -d ' "\r\n')
        echo -e "      ├── 🗄️  ${GREEN}${c}${NC}   [Publisher RCU]    Port: ${p_port:-1531} -> 1521/${p_svc:-FREEPDB1}"
        ;;
      db-proxy|db-proxy-*)
        local pfile="$WORKSPACE_DIR/config/profiles/databases/${c}.yaml"
        [ ! -f "$pfile" ] && pfile="$WORKSPACE_DIR/config/profiles/databases/db-proxy-oracle.yaml"
        p_port=$(grep -E '^[[:space:]]*db_port:' "$pfile" 2>/dev/null | head -n 1 | awk -F: '{print $2}' | sed -E 's/#.*//' | tr -d ' "\r\n')
        p_svc=$(grep -E '^[[:space:]]*default_service:' "$pfile" 2>/dev/null | head -n 1 | awk -F: '{print $2}' | sed -E 's/#.*//' | tr -d ' "\r\n')
        echo -e "      ├── 🗄️  ${GREEN}${c}${NC}       [APEX/SSO Proxy]   Port: ${p_port:-1532} -> 1521/${p_svc:-FREEPDB1}"
        ;;
      db-alise*|db-lis*)
        local pfile="$WORKSPACE_DIR/config/profiles/databases/${c}.yaml"
        [ ! -f "$pfile" ] && pfile="$WORKSPACE_DIR/config/profiles/databases/db-alise-oracle.yaml"
        p_port=$(grep -E '^[[:space:]]*db_port:' "$pfile" 2>/dev/null | head -n 1 | awk -F: '{print $2}' | sed -E 's/#.*//' | tr -d ' "\r\n')
        p_svc=$(grep -E '^[[:space:]]*default_service:' "$pfile" 2>/dev/null | head -n 1 | awk -F: '{print $2}' | sed -E 's/#.*//' | tr -d ' "\r\n')
        echo -e "      ├── 🗄️  ${GREEN}${c}${NC}       [ALISE Schema Engine] Port: ${p_port:-1533} -> 1521/${p_svc:-FREEPDB1}"
        ;;
      db-forms|db-forms-*)
        local pfile="$WORKSPACE_DIR/config/profiles/databases/${c}.yaml"
        [ ! -f "$pfile" ] && pfile="$WORKSPACE_DIR/config/profiles/databases/db-forms-oracle.yaml"
        p_port=$(grep -E '^[[:space:]]*db_port:' "$pfile" 2>/dev/null | head -n 1 | awk -F: '{print $2}' | sed -E 's/#.*//' | tr -d ' "\r\n')
        p_svc=$(grep -E '^[[:space:]]*default_service:' "$pfile" 2>/dev/null | head -n 1 | awk -F: '{print $2}' | sed -E 's/#.*//' | tr -d ' "\r\n')
        echo -e "      ├── 🗄️  ${GREEN}${c}${NC}       [Forms RCU DB]     Port: ${p_port:-1534} -> 1521/${p_svc:-FREEPDB1}"
        ;;
      app-ords)
        echo -e "      ├── 🌐  ${CYAN}app-ords${NC}       [ORDS & APEX Web]  Ports: 8088 (HTTP), 8448 (HTTPS)"
        ;;
      app-publisher)
        echo -e "      ├── 📊  ${MAGENTA}app-publisher${NC}  [Pixel Perfect]    Ports: 9502 (HTTP), 9503 (HTTPS)"
        ;;
      app-publisher-designer)
        echo -e "      ├── 🎨  ${MAGENTA}app-publisher-designer${NC} [Template Studio] Ports: 6083 (noVNC), 5903 (VNC)"
        ;;
      app-forms)
        echo -e "      ├── 📐  ${MAGENTA}app-forms${NC}      [Forms 14c Services] Ports: 9001, 7001, 6082"
        ;;
      web-ide-dev)
        echo -e "      └── 💻  ${BLUE}web-ide-dev${NC}    [VS Code Web IDE]  Ports: 8090 (HTTP), 8449 (HTTPS)"
        ;;
    esac
  done

  echo -e "${CYAN}==================================================================${NC}"
  echo -e "🚀 ${BOLD}Launch Command (Production / Dev):${NC}  ./scripts/setup-all.sh -b ${num}"
  echo -e "🧪 ${BOLD}Testing Command (Clean Scratch):${NC}    ./scripts/setup-all.sh -tb ${num}"
  echo -e "🔍 ${BOLD}Simulation Command (Dry-run):${NC}       ./scripts/setup-all.sh -b ${num} --dry-run\n"
}

# ----------------------------------------------------------------------------
# 6. Simulate Blueprint Dry-Run (Pre-flight Validation without modifying state)
# ----------------------------------------------------------------------------
simulate_blueprint_dry_run() {
  local query="$1"
  local is_test_mode="${2:-false}"

  local bp_file
  bp_file=$(get_blueprint_file "$query")
  if [ -z "$bp_file" ]; then
    echo -e "${RED}❌ ERROR: Blueprint '${query}' not found!${NC}"
    return 1
  fi

  local num
  num=$(get_blueprint_number "$query")
  local bp_name
  bp_name=$(basename "$bp_file")
  local containers
  containers=$(extract_blueprint_containers "$num")

  local bp_stats=""
  if [ -f "$WORKSPACE_DIR/scripts/internal/common.sh" ]; then
    source "$WORKSPACE_DIR/scripts/internal/common.sh" 2>/dev/null || true
    bp_stats=$(get_blueprint_stats "$num" 2>/dev/null || echo "")
  fi

  echo -e "\n${CYAN}==================================================================${NC}"
  echo -e "${YELLOW}$(msg_str "DRY_RUN_HEADER" "$num" "$bp_name")${NC}"
  echo -e "${CYAN}==================================================================${NC}"
  echo -e "   ├─ 📋 $(msg_str "LABEL_SELECTED_BP"):      ${GREEN}${bp_name}${NC}"
  echo -e "   ├─ ⚙️  $(msg_str "LABEL_MODE"):                 $( [ "$is_test_mode" = "true" ] && echo "${YELLOW}$(msg_str "MODE_TEST")${NC}" || echo "${GREEN}$(msg_str "MODE_PROD")${NC}" )"
  [ -n "$bp_stats" ] && echo -e "   ├─ ⏱️  $(msg_str "BENCHMARK_LABEL")     ${YELLOW}${bp_stats}${NC}"
  echo -e "   ├─ 📦 $(msg_str "LABEL_DETECTED_CONTAINERS"): ${CYAN}${containers}${NC}"
  echo -e "   ├─ 🛡️  $(msg_str "LABEL_CONFIG_STATUS")"
  echo -e "   └─ 🌐 $(msg_str "LABEL_PORT_CHECK")"
  echo -e "${CYAN}==================================================================${NC}"
  echo -e "${GREEN}$(msg_str "DRY_RUN_SUCCESS" "$num")${NC}\n"
}

# ----------------------------------------------------------------------------
# 7. List Blueprint Test Reports
# ----------------------------------------------------------------------------
list_blueprint_test_reports() {
  local reports_dir="$WORKSPACE_DIR/tests/reports/blueprints"
  echo -e "\n${CYAN}==================================================================${NC}"
  echo -e "${BOLD}📊   BLUEPRINT TEST REPORTS STATUS (BLUEPRINT TEST REPORTS)${NC}"
  echo -e "${CYAN}==================================================================${NC}"
  printf "┌────┬──────────────────────────────────────────┬──────────────┬─────────────────────────────┐\n"
  printf "│ %-2s │ %-40s │ %-12s │ %-27s │\n" "No" "Blueprint" "Report" "Latest Test File"
  printf "├────┼──────────────────────────────────────────┼──────────────┼─────────────────────────────┤\n"

  local all_files=()
  while IFS= read -r f; do
    [ -n "$f" ] && all_files+=("$f")
  done < <(find "$BLUEPRINTS_DIR" -maxdepth 1 -type f -name ".env.*" 2>/dev/null | sed -E 's/.*\.env\.([0-9]+).*/\1 &/' | sort -n -k1,1 | awk '{print $2}')

  for bp_file in "${all_files[@]}"; do
    local bp_name
    bp_name=$(basename "$bp_file")
    local num
    num=$(echo "$bp_name" | sed -E 's/^\.env\.([0-9]+).*/\1/')
    local rep_file="$reports_dir/blueprint_${num}_report.md"

    local status="❌ Missing"
    local report_name="-"
    if [ -f "$rep_file" ]; then
      status="✅ Present"
      report_name="blueprint_${num}_report.md"
    fi

    printf "│ %2d │ %-40s │ %-12s │ %-27s │\n" "$num" "$bp_name" "$status" "$report_name"
  done
  printf "└────┴──────────────────────────────────────────┴──────────────┴─────────────────────────────┘\n"
  echo -e "📁 ${YELLOW}Reports directory:${NC} $reports_dir\n"
}

# ----------------------------------------------------------------------------
# CLI Execution Entry Point (when run directly)
# ----------------------------------------------------------------------------
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  case "${1:-}" in
    -l|--list|--list-blueprints|list|--summary|summary)
      print_blueprints_table "${2:-}"
      ;;
    -s|-sb|--show|--inspect|inspect)
      show_blueprint_details "${2:-0}"
      ;;
    --reports|reports)
      list_blueprint_test_reports
      ;;
    *)
      print_blueprints_table "${1:-}"
      ;;
  esac
fi
