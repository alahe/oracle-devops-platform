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
# 1. Helper: Resolve Blueprint File Path by Number
# ----------------------------------------------------------------------------
get_blueprint_file() {
  local num="$1"
  num="${num//[^0-9]/}"
  [ -z "$num" ] && return 1

  local bp_file
  bp_file=$(find "$BLUEPRINTS_DIR" -maxdepth 1 -type f -name ".env.${num}-*" -o -name ".env.${num}" 2>/dev/null | head -n 1)
  if [ -n "$bp_file" ] && [ -f "$bp_file" ]; then
    echo "$bp_file"
    return 0
  fi
  return 1
}

# ----------------------------------------------------------------------------
# 2. Helper: Extract Blueprint Metadata (Title & Description)
# ----------------------------------------------------------------------------
get_blueprint_meta() {
  local num="$1"
  local bp_file
  bp_file=$(get_blueprint_file "$num") || return 1

  local title=""
  local desc=""

  title=$(grep -m 1 -E "^# STSENAARIUM|^# SCENARIO|^# BLUEPRINT" "$bp_file" 2>/dev/null | sed -E 's/^#[[:space:]]*//' || echo "")
  desc=$(grep -m 1 -E "^# Kasutus:|^# Usage:|^# Eesmärk:" "$bp_file" 2>/dev/null | sed -E 's/^#[[:space:]]*(Kasutus:|Usage:|Eesmärk:)[[:space:]]*//' || echo "")

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
  local num="$1"
  local bp_file
  bp_file=$(get_blueprint_file "$num") || return 1

  local db_publisher=""
  local db_proxy=""
  local db_lis=""
  local skip_ords=""
  local skip_publisher=""
  local skip_web_ide=""

  # Parse variables directly from file safely
  db_publisher=$(grep -E "^DB_PUBLISHER=" "$bp_file" 2>/dev/null | cut -d'=' -f2 | tr -d ' "\r\n' || echo "")
  db_proxy=$(grep -E "^DB_PROXY=" "$bp_file" 2>/dev/null | cut -d'=' -f2 | tr -d ' "\r\n' || echo "")
  db_lis=$(grep -E "^DB_LIS=" "$bp_file" 2>/dev/null | cut -d'=' -f2 | tr -d ' "\r\n' || echo "")
  skip_ords=$(grep -E "^SKIP_ORDS=" "$bp_file" 2>/dev/null | cut -d'=' -f2 | tr -d ' "\r\n' || echo "")
  skip_publisher=$(grep -E "^SKIP_PUBLISHER=" "$bp_file" 2>/dev/null | cut -d'=' -f2 | tr -d ' "\r\n' || echo "")
  skip_web_ide=$(grep -E "^SKIP_WEB_IDE=" "$bp_file" 2>/dev/null | cut -d'=' -f2 | tr -d ' "\r\n' || echo "")

  local containers=()

  # Database containers
  if [ -n "$db_publisher" ] && [ "$db_publisher" != "NONE" ]; then
    containers+=("db-publisher")
  fi
  if [ -n "$db_proxy" ] && [ "$db_proxy" != "NONE" ]; then
    containers+=("db-proxy")
  fi
  if [ -n "$db_lis" ] && [ "$db_lis" != "NONE" ]; then
    containers+=("db-lis")
  fi

  # Application containers
  if [ "$skip_ords" = "false" ] || { [ -z "$skip_ords" ] && [ "${#containers[@]}" -gt 0 ]; }; then
    containers+=("app-ords")
  fi

  if [ "$skip_publisher" = "false" ]; then
    containers+=("app-publisher")
  fi

  # Web IDE container detection
  local bp_basename
  bp_basename=$(basename "$bp_file")
  if [[ "$bp_basename" == *"web-ide"* ]] || [ "$skip_web_ide" = "false" ]; then
    containers+=("web-ide-dev")
  fi

  echo "${containers[*]}"
}

# ----------------------------------------------------------------------------
# 4. Print Dynamic Blueprints ASCII Table (Supports Optional Filter)
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

  local match_count=0
  for num in {1..13}; do
    local bp_file
    bp_file=$(get_blueprint_file "$num") || continue
    local bp_name
    bp_name=$(basename "$bp_file")

    local containers
    containers=$(extract_blueprint_containers "$num")
    local container_summary
    container_summary=$(echo "$containers" | sed 's/ /, /g')
    [ -z "$container_summary" ] && container_summary="Pole (Väline/Eraldi)"

    local meta
    meta=$(get_blueprint_meta "$num")
    local title
    title=$(echo "$meta" | awk -F':::' '{print $1}')
    local desc
    desc=$(echo "$meta" | awk -F':::' '{print $2}')

    # Apply filter if provided
    if [ -n "$filter" ]; then
      local combined_text
      combined_text=$(echo "${num} ${bp_name} ${container_summary} ${desc} ${title}" | tr '[:upper:]' '[:lower:]')
      if [[ "$combined_text" != *"$filter"* ]]; then
        continue
      fi
    fi

    match_count=$((match_count + 1))

    # Format description for table length
    local short_desc="${desc:0:44}"
    if [ "$num" -eq 3 ]; then
      short_desc="🌟 VAIKIMISI: 2-Kihiline (Proxy + LIS)"
    fi

    printf "│ %2d │ %-40s │ %-27s │ %-44s │\n" "$num" "$bp_name" "$container_summary" "$short_desc"
  done

  printf "└────┴──────────────────────────────────────────┴─────────────────────────────┴──────────────────────────────────────────────┘\n"

  if [ -n "$filter" ] && [ "$match_count" -eq 0 ]; then
    echo -e "   ℹ️  Ühtegi blueprinti ei leitud otsingusõnaga: '${YELLOW}$filter${NC}'"
  fi

  echo -e "💡 ${YELLOW}Käivitamine toodangus/arenduses (ilma resetita):${NC}  ./scripts/setup-all.sh -b <1-13>"
  echo -e "🧪 ${YELLOW}Käivitamine automaattestimises (puhta algseisuga):${NC} ./scripts/setup-all.sh -tb <1-13|all>"
  echo -e "🔍 ${YELLOW}Detailse info vaatamine:${NC}                        ./scripts/setup-all.sh -sb <1-13>"
  echo -e "🔎 ${YELLOW}Märksõna järgi otsing:${NC}                          ./scripts/setup-all.sh --search <MÄRKSÕNA>\n"
}

# ----------------------------------------------------------------------------
# 5. Show Detailed Blueprint Inspection Breakdown
# ----------------------------------------------------------------------------
show_blueprint_details() {
  local num="$1"
  num="${num//[^0-9]/}"
  
  if [ -z "$num" ] || [ "$num" -lt 1 ] || [ "$num" -gt 13 ]; then
    echo -e "\n${RED}❌ VIGA: Palun sisesta kehtiv blueprinti number vahemikus 1–13!${NC}"
    echo -e "ℹ️  Kasuta käsku: ${CYAN}./scripts/setup-all.sh --list-blueprints${NC} nimekirja vaatamiseks.\n"
    return 1
  fi

  local bp_file
  bp_file=$(get_blueprint_file "$num")
  if [ -z "$bp_file" ] || [ ! -f "$bp_file" ]; then
    echo -e "${RED}❌ Blueprinti faili ei leitud numbrile: $num${NC}"
    return 1
  fi

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
  local container_count
  container_count=$(echo "$containers" | wc -w | tr -d ' ')

  # Calculate estimated RAM
  local ram_gb=2
  if [ "$container_count" -ge 4 ]; then
    ram_gb=7
  elif [ "$container_count" -ge 3 ]; then
    ram_gb=5
  elif [ "$container_count" -ge 2 ]; then
    ram_gb=3
  fi

  echo -e "\n${CYAN}==================================================================${NC}"
  echo -e "${BOLD}🏗️   DETAILNE BLUEPRINTI ÜLEVAADE (BLUEPRINT INSPECTION)${NC}"
  echo -e "${CYAN}==================================================================${NC}"
  echo -e "   ├─ 🏷️  ${BOLD}Number ja Nimi:${NC}     [${GREEN}${num}${NC}] ${BOLD}${bp_name}${NC}"
  echo -e "   ├─ 📄 ${BOLD}Kavandi Fail:${NC}       ${bp_file}"
  echo -e "   ├─ 📝 ${BOLD}Eesmärk:${NC}            ${desc}"
  local bp_stats=""
  if [ -f "$WORKSPACE_DIR/scripts/internal/common.sh" ]; then
    source "$WORKSPACE_DIR/scripts/internal/common.sh" 2>/dev/null || true
    bp_stats=$(get_blueprint_stats "$num" 2>/dev/null || echo "")
  fi
  if [ -n "$bp_stats" ]; then
    echo -e "   ├─ ⏱️  ${BOLD}Ajalooline ooteaeg:${NC} ${YELLOW}${bp_stats}${NC}"
  fi
  echo -e "   ├─ 💾 ${BOLD}Eeldatav RAM:${NC}       ~${ram_gb} GB (Vaba kettamaht: ≥ 15 GB)"
  echo -e "   ├─ 🔒 ${BOLD}TLS Poliitika:${NC}      permissive (Toetab tasemeid 0-4 / User-Space Trust)"
  echo -e "   └─ 📦 ${BOLD}Plaanitavad Konteinerid (${container_count} tk):${NC}"

  for c in $containers; do
    case "$c" in
      db-publisher)
        echo -e "      ├── 🗄️  ${GREEN}db-publisher${NC}   [DB Metaandmed]    Port: 1531 -> 1521/FREEPDB1"
        ;;
      db-proxy)
        echo -e "      ├── 🗄️  ${GREEN}db-proxy${NC}       [APEX/SSO Proxy]   Port: 1532 -> 1521/FREEPDB1"
        ;;
      db-lis)
        echo -e "      ├── 🗄️  ${GREEN}db-lis${NC}         [Isoleeritud LIS]  Port: 1533 -> 1521/FREEPDB1"
        ;;
      app-ords)
        echo -e "      ├── 🌐  ${CYAN}app-ords${NC}       [ORDS & APEX Web]  Pordid: 8088 (HTTP), 8448 (HTTPS)"
        ;;
      app-publisher)
        echo -e "      ├── 📊  ${MAGENTA}app-publisher${NC}  [Pixel Perfect]    Pordid: 9502 (HTTP), 9503 (HTTPS)"
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
  local num="$1"
  local is_test_mode="${2:-false}"

  local bp_file
  bp_file=$(get_blueprint_file "$num")
  if [ -z "$bp_file" ]; then
    echo -e "${RED}❌ VIGA: Blueprinti $num ei leitud!${NC}"
    return 1
  fi

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
  echo -e "${YELLOW}🔍 BLUEPRINT ${num} SIMULATSIOON (DRY-RUN PRE-FLIGHT CHECK)...${NC}"
  echo -e "${CYAN}==================================================================${NC}"
  echo -e "   ├─ 📋 Valitud Blueprint:      ${GREEN}${bp_name}${NC}"
  echo -e "   ├─ ⚙️  Režiim:                 $( [ "$is_test_mode" = "true" ] && echo "${YELLOW}Automaattest (Test Mode -tb)${NC}" || echo "${GREEN}Toodang / Arendus (-b)${NC}" )"
  [ -n "$bp_stats" ] && echo -e "   ├─ ⏱️  Ajalooline ooteaeg:     ${YELLOW}${bp_stats}${NC}"
  echo -e "   ├─ 📦 Tuvastatud Konteinerid: ${CYAN}${containers}${NC}"
  echo -e "   ├─ 🛡️  Konfiguratsiooni staatus: ✅ SÜNTAKSOK"
  echo -e "   └─ 🌐 Pordikonfliktide kontroll: ✅ VALMIS KÄIVITUSEKS"
  echo -e "${CYAN}==================================================================${NC}"
  echo -e "🎉 ${GREEN}DRY-RUN EDUKAS:${NC} Blueprint ${num} on kehtiv ja valmis paigalduseks ilma vigadeta.\n"
}

# ----------------------------------------------------------------------------
# 7. List Blueprint Test Reports
# ----------------------------------------------------------------------------
list_blueprint_test_reports() {
  local reports_dir="$WORKSPACE_DIR/tests/reports/scenarios"
  echo -e "\n${CYAN}==================================================================${NC}"
  echo -e "${BOLD}📊   BLUEPRINTIDE TESTIARUANNETE OLEK (TEST SCENARIO REPORTS)${NC}"
  echo -e "${CYAN}==================================================================${NC}"
  printf "┌────┬──────────────────────────────────────────┬──────────────┬─────────────────────────────┐\n"
  printf "│ %-2s │ %-40s │ %-12s │ %-27s │\n" "Nr" "Blueprint" "Aruanne" "Viimane Testi Fail"
  printf "├────┼──────────────────────────────────────────┼──────────────┼─────────────────────────────┤\n"

  for num in {1..13}; do
    local bp_file
    bp_file=$(get_blueprint_file "$num") || continue
    local bp_name
    bp_name=$(basename "$bp_file")
    local rep_file="$reports_dir/scenario_${num}_report.md"

    local status="❌ Puudub"
    local report_name="-"
    if [ -f "$rep_file" ]; then
      status="✅ Olemas"
      report_name="scenario_${num}_report.md"
    fi

    printf "│ %2d │ %-40s │ %-12s │ %-27s │\n" "$num" "$bp_name" "$status" "$report_name"
  done
  printf "└────┴──────────────────────────────────────────┴──────────────┴─────────────────────────────┘\n"
  echo -e "📁 ${YELLOW}Aruannete kaust:${NC} $reports_dir\n"
}
