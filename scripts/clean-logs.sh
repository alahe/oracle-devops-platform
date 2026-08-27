#!/usr/bin/env bash
# ============================================================================
# Log and Temporary Diagnostic Artifact Cleaner Script
# Cleans install_logs/*.log, unzipped_log* directories, and bieeconfiglogs*.zip archives
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

LOG_DIR="$WORKSPACE_DIR/install_logs"

if [ -f "$SCRIPT_DIR/internal/common.sh" ]; then
  source "$SCRIPT_DIR/internal/common.sh"
else
  CYAN=$'\033[1;36m'
  GREEN=$'\033[1;32m'
  YELLOW=$'\033[0;33m'
  RED=$'\033[1;31m'
  NC=$'\033[0m'
fi

FORCE=false
for arg in "$@"; do
  case $arg in
    -y|--force|--yes|-y*|--y*|-Y|--YES)
      FORCE=true
      ;;
  esac
done

echo -e "${CYAN}==================================================================${NC}"
echo -e "${CYAN}🧹 Puhastan paigalduslogid, ajutised kataloogid ja arhiivid...${NC}"
echo -e "${CYAN}==================================================================${NC}"

if [ "$FORCE" = "false" ]; then
  read -p "$(echo -e "${YELLOW}❓ Kas soovid kustutada kõik logid, unzipped_log* kataloogid ja bieeconfiglogs*.zip failid? (y/N): ${NC}")" CONFIRM
  if [[ ! "$CONFIRM" =~ ^[YyJj] ]]; then
    echo -e "${RED}❌ Logide puhastamine tühistatud.${NC}"
    exit 0
  fi
fi

COUNT_LOGS=0
COUNT_DIRS=0
COUNT_ZIPS=0

# 1. Clear install_logs/*.log
if [ -d "$LOG_DIR" ]; then
  shopt -s nullglob
  log_files=("$LOG_DIR"/*.log)
  shopt -u nullglob
  COUNT_LOGS=${#log_files[@]}
  if [ $COUNT_LOGS -gt 0 ]; then
    rm -f "$LOG_DIR"/*.log
    echo -e "   ✅ Kustutatud ${COUNT_LOGS} logifaili kaustast install_logs/"
  fi
fi

# 2. Clear unzipped_log* directories
shopt -s nullglob
unzipped_dirs=("$LOG_DIR"/unzipped_log* "$WORKSPACE_DIR"/unzipped_log*)
shopt -u nullglob
COUNT_DIRS=${#unzipped_dirs[@]}
if [ $COUNT_DIRS -gt 0 ]; then
  for d in "${unzipped_dirs[@]}"; do
    [ -d "$d" ] && rm -rf "$d"
  done
  echo -e "   ✅ Kustutatud ${COUNT_DIRS} unzipped_log* kataloogi koos sisuga."
fi

# 3. Clear bieeconfiglogs*.zip diagnostic archives
shopt -s nullglob
biee_zips=("$LOG_DIR"/bieeconfiglogs*.zip "$WORKSPACE_DIR"/bieeconfiglogs*.zip "$WORKSPACE_DIR"/binaries/publisher/bieeconfiglogs*.zip)
shopt -u nullglob
COUNT_ZIPS=${#biee_zips[@]}
if [ $COUNT_ZIPS -gt 0 ]; then
  for z in "${biee_zips[@]}"; do
    [ -f "$z" ] && rm -f "$z"
  done
  echo -e "   ✅ Kustutatud ${COUNT_ZIPS} bieeconfiglogs*.zip arhiivi."
fi

echo -e "${CYAN}==================================================================${NC}"
echo -e "${GREEN}✅ LOGIDE JA DIAGNOOSTIKA PUHASTAMINE TEHTUD!${NC}"
echo -e "${CYAN}==================================================================${NC}"
