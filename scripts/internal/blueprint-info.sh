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

  desc=$(grep -m 1 -E "^# Kasutus:|^# Usage:|^# Eesmärk:" "$bp_file" 2>/dev/null | sed -E 's/^#[[:space:]]*(Kasutus:|Usage:|Eesmärk:)[[:space:]]*//' || echo "")
  if [ -z "$desc" ]; then
    desc=$(sed -n '2p' "$bp_file" 2>/dev/null | grep "^#" | sed -E 's/^#[[:space:]]*//' || echo "")
  fi

  if [ -z "$title" ]; then
    title="Blueprint ${num} ($(basename "$bp_file"))"
  fi
  if [ -z "$desc" ]; then
    desc="Konfiguratsioonimudel ${num}"
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
  local db_lis=""
  local db_forms=""
  local skip_ords=""
  local skip_publisher=""
  local skip_forms=""
  local skip_web_ide=""

  # Parse variables directly from file safely
  db_publisher=$(grep -E "^DB_PUBLISHER=" "$bp_file" 2>/dev/null | cut -d'=' -f2 | tr -d ' "\r\n' || echo "")
  db_proxy=$(grep -E "^DB_PROXY=" "$bp_file" 2>/dev/null | cut -d'=' -f2 | tr -d ' "\r\n' || echo "")
  db_alise=$(grep -E "^(DB_ALISE|DB_LIS)=" "$bp_file" 2>/dev/null | tail -n 1 | cut -d'=' -f2 | tr -d ' "\r\n' || echo "")
  db_forms=$(grep -E "^DB_FORMS=" "$bp_file" 2>/dev/null | cut -d'=' -f2 | tr -d ' "\r\n' || echo "")
  skip_ords=$(grep -E "^SKIP_ORDS=" "$bp_file" 2>/dev/null | cut -d'=' -f2 | tr -d ' "\r\n' || echo "")
  skip_publisher=$(grep -E "^SKIP_PUBLISHER=" "$bp_file" 2>/dev/null | cut -d'=' -f2 | tr -d ' "\r\n' || echo "")
  skip_forms=$(grep -E "^SKIP_FORMS=" "$bp_file" 2>/dev/null | cut -d'=' -f2 | tr -d ' "\r\n' || echo "")
  skip_web_ide=$(grep -E "^SKIP_WEB_IDE=" "$bp_file" 2>/dev/null | cut -d'=' -f2 | tr -d ' "\r\n' || echo "")
  web_ide_prof=$(grep -E "^WEB_IDE_PROFILE=" "$bp_file" 2>/dev/null | cut -d'=' -f2 | tr -d ' "\r\n' || echo "")

  local containers=()

  # Database containers
  if [ -n "$db_publisher" ] && [ "$db_publisher" != "NONE" ]; then
    if [ "$db_publisher" != "$db_proxy" ] && [ "$db_publisher" != "$db_alise" ]; then
      containers+=("db-publisher")
    fi
  fi
  if [ -n "$db_proxy" ] && [ "$db_proxy" != "NONE" ]; then
    containers+=("db-proxy")
  fi
  if [ -n "$db_alise" ] && [ "$db_alise" != "NONE" ]; then
    if [ "$db_alise" != "$db_proxy" ]; then
      containers+=("db-alise")
    fi
  fi
  if [ -n "$db_forms" ] && [ "$db_forms" != "NONE" ]; then
    if [ "$db_forms" != "$db_proxy" ] && [ "$db_forms" != "$db_alise" ] && [ "$db_forms" != "$db_publisher" ]; then
      containers+=("db-forms")
    fi
  fi

  # Application containers
  if [ "$skip_ords" = "false" ] || { [ -z "$skip_ords" ] && [ "${#containers[@]}" -gt 0 ] && [ "$skip_forms" != "false" ]; }; then
    containers+=("app-ords")
  fi

  if [ "$skip_publisher" = "false" ]; then
    containers+=("app-publisher")
  fi

  if [ "$skip_forms" = "false" ]; then
    containers+=("app-forms")
  fi

  # Web IDE container detection
  local bp_basename
  bp_basename=$(basename "$bp_file")
  if [ "$web_ide_prof" = "web-ide-dev" ] || [ "$skip_web_ide" = "false" ]; then
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

  echo -e "\n${CYAN}=========================================================================================================${NC}"
  echo -e "${BOLD}🏗️   ORACLE DEVOPS PLATFORM — AMETLIKUD ARHITEKTUURSED KAVANDID (BLUEPRINTS)${NC}"
  echo -e "${CYAN}=========================================================================================================${NC}"
  printf "┌────┬──────────────────────────────────────────┬─────────────────────────────┬──────────────────────────────────────────────┐\n"
  printf "│ %-2s │ %-40s │ %-27s │ %-44s │\n" "Nr" "Blueprint (Kavandi Fail)" "Käivitatavad Konteinerid" "Otstarve ja Kirjeldus"
  printf "├────┼──────────────────────────────────────────┼─────────────────────────────┼──────────────────────────────────────────────┤\n"

  # Find all blueprints and sort numerically
  local all_files=()
  while IFS= read -r f; do
    [ -n "$f" ] && all_files+=("$f")
  done < <(find "$BLUEPRINTS_DIR" -maxdepth 1 -type f -name ".env.*" 2>/dev/null | sed -E 's/.*\.env\.([0-9]+).*/\1 &/' | sort -n -k1,1 | awk '{print $2}')

  local match_count=0
  local last_group=""

  for bp_file in "${all_files[@]}"; do
    local bp_name
    bp_name=$(basename "$bp_file")
    local num
    num=$(echo "$bp_name" | sed -E 's/^\.env\.([0-9]+).*/\1/')

    # Extract containers
    local containers
    containers=$(extract_blueprint_containers "$num")
    containers="${containers:-None}"
    if [ ${#containers} -gt 27 ]; then
      containers="${containers:0:24}..."
    fi

    # Extract metadata
    local meta
    meta=$(get_blueprint_meta "$num")
    local title
    title=$(echo "$meta" | awk -F':::' '{print $1}')
    local desc
    desc=$(echo "$meta" | awk -F':::' '{print $2}')

    # Apply optional filter
    if [ -n "$filter" ]; then
      local combined_text="$num $bp_file $containers $title $desc"
      if ! echo "$combined_text" | grep -qi "$filter"; then
        continue
      fi
    fi

    match_count=$((match_count + 1))

    # Decade group header
    local cur_group=""
    if [ "$num" -lt 10 ]; then
      cur_group="Grupp 1: Üksiktooted Eraldi (Standalone Isolates 1–9)"
    elif [ "$num" -lt 20 ]; then
      cur_group="Grupp 2: Konsolideeritud Teenused (Combined Subsystems 10–19)"
    elif [ "$num" -lt 30 ]; then
      cur_group="Grupp 3: Kihiline Ettevõtte Virn (Layered Stacks 20–29)"
    else
      cur_group="Grupp 4: Hübriidsed Virnad (Hybrid Stacks 30–39)"
    fi

    if [ -z "$filter" ] && [ "$cur_group" != "$last_group" ]; then
      if [ -n "$last_group" ]; then
        printf "├────┼──────────────────────────────────────────┼─────────────────────────────┼──────────────────────────────────────────────┤\n"
      fi
      printf "│ \033[1;33m%-2s\033[0m │ \033[1;33m%-40s\033[0m │ %-27s │ %-44s │\n" "::" "🔹 ${cur_group}" "" ""
      printf "├────┼──────────────────────────────────────────┼─────────────────────────────┼──────────────────────────────────────────────┤\n"
      last_group="$cur_group"
    fi

    if [ ${#bp_name} -gt 40 ]; then
      bp_name="${bp_name:0:37}..."
    fi

    local summary="${desc:-$title}"
    if [ ${#summary} -gt 44 ]; then
      summary="${summary:0:41}..."
    fi

    printf "│ %2d │ %-40s │ %-27s │ %-44s │\n" "$num" "$bp_name" "$containers" "$summary"
  done

  echo -e "└────┴──────────────────────────────────────────┴─────────────────────────────┴──────────────────────────────────────────────┘\n"

  if [ -n "$filter" ] && [ "$match_count" -eq 0 ]; then
    echo -e "   ℹ️  No blueprints found matching search keyword: '${YELLOW}$filter${NC}'"
  fi

  echo -e "💡 ${YELLOW}Run in production/development (no reset):${NC}    ./scripts/setup-all.sh -b <NUM|NAME>"
  echo -e "🧪 ${YELLOW}Run in automated test mode (clean slate):${NC}    ./scripts/setup-all.sh -tb <NUM|NAME|all>"
  echo -e "🔍 ${YELLOW}Inspect detailed configuration:${NC}              ./scripts/setup-all.sh -sb <NUM|NAME>"
  echo -e "🔎 ${YELLOW}Search blueprints by keyword:${NC}                ./scripts/setup-all.sh --search <KEYWORD>\n"
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
  echo -e "${BOLD}🏗️   DETAILNE BLUEPRINTI ÜLEVAADE (BLUEPRINT INSPECTION)${NC}"
  echo -e "${CYAN}==================================================================${NC}"
  echo -e "🔹 ${BOLD}Number:${NC}        ${YELLOW}$num${NC}"
  echo -e "🔹 ${BOLD}Kavandi fail:${NC}  ${CYAN}$bp_name${NC}"
  echo -e "🔹 ${BOLD}Pealkiri:${NC}      ${BOLD}$title${NC}"
  echo -e "🔹 ${BOLD}Kirjeldus:${NC}     $desc"

  local bp_stats=""
  if [ -f "$WORKSPACE_DIR/scripts/internal/common.sh" ]; then
    bp_stats=$(get_blueprint_stats "$num" 2>/dev/null || echo "")
  fi
  if [ -n "$bp_stats" ]; then
    local hist_lbl="Ajalooline kestus"
    if declare -f msg_str >/dev/null 2>&1; then
      hist_lbl="$(msg_str "LABEL_HIST_DURATION")"
    fi
    echo -e "🔹 ${BOLD}${hist_lbl}:${NC} ${YELLOW}$bp_stats${NC}"
  fi

  echo -e "\n🔹 ${BOLD}Plaanis käivitada järgmised konteinerid:${NC}"
  for c in $containers; do
    case "$c" in
      db-publisher)
        echo -e "      ├── 🗄️  ${GREEN}db-publisher${NC}   [Publisher RCU]    Port: 1531 -> 1521/FREEPDB1"
        ;;
      db-proxy)
        echo -e "      ├── 🗄️  ${GREEN}db-proxy${NC}       [APEX/SSO Proxy]   Port: 1532 -> 1521/FREEPDB1"
        ;;
      db-alise|db-lis)
        echo -e "      ├── 🗄️  ${GREEN}db-alise${NC}       [ALISE Schema Engine] Port: 1533 -> 1521/FREEPDB1"
        ;;
      db-forms)
        echo -e "      ├── 🗄️  ${GREEN}db-forms${NC}       [Forms RCU DB]     Port: 1534 -> 1521/FREEPDB1"
        ;;
      app-ords)
        echo -e "      ├── 🌐  ${CYAN}app-ords${NC}       [ORDS & APEX Web]  Pordid: 8088 (HTTP), 8448 (HTTPS)"
        ;;
      app-publisher)
        echo -e "      ├── 📊  ${MAGENTA}app-publisher${NC}  [Pixel Perfect]    Pordid: 9502 (HTTP), 9503 (HTTPS)"
        ;;
      app-forms)
        echo -e "      ├── 📐  ${MAGENTA}app-forms${NC}      [Forms 14c Services] Pordid: 9001, 7001, 6082"
        ;;
      web-ide-dev)
        echo -e "      └── 💻  ${BLUE}web-ide-dev${NC}    [VS Code Web IDE]  Pordid: 8090 (HTTP), 8449 (HTTPS)"
        ;;
    esac
  done

  echo -e "${CYAN}==================================================================${NC}"
  echo -e "🚀 ${BOLD}Käivituskäsk (Toodang / Arendus):${NC}  ./scripts/setup-all.sh -b ${num}"
  echo -e "🧪 ${BOLD}Testimiskäsk (Puhas Algseis):${NC}       ./scripts/setup-all.sh -tb ${num}"
  echo -e "🔍 ${BOLD}Simuleerimise käsk (Dry-run):${NC}       ./scripts/setup-all.sh -b ${num} --dry-run\n"
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
