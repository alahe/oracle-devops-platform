#!/usr/bin/env bash
# ==============================================================================
# Oracle DevOps Platform — Master Multi-Language & i18n Verification Suite
#
# Validates Rule 9 (Dual- & Multi-Language Synchronization Rule) across:
#   1. Script Messages & i18n Central Engine (scripts/internal/i18n.sh & scripts/)
#   2. Documentation & Language Switchers (README.md, docs/, config/blueprints/)
#
# Supports 6 Nordic-Baltic Languages:
#   🇬🇧 EN (Canonical Source of Truth), 🇪🇪 ET, 🇫🇮 FI, 🇸🇪 SV, 🇱🇻 LV, 🇱🇹 LT
#
# Usage:
#   ./tests/test-multilingual-support.sh [OPTIONS]
# Options:
#   --all            Run all verification suites (default)
#   --check-scripts  Run only script messages & i18n engine tests
#   --check-docs     Run only documentation language & switcher tests
#   --lang <code/all> Filter by specific language (en, et, fi, sv, lv, lt, all)
#   --verbose, -v    Show detailed diagnostics for each test item
#   --json           Output results in JSON format for CI/CD metrics
#   --help, -h       Display this help message
# ==============================================================================

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors & Formatting
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# Mode flags
RUN_SCRIPTS=true
RUN_DOCS=true
VERBOSE=false
JSON_MODE=false
TARGET_LANG="all"

# Test counters
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_WARNED=0

START_TIME=$(date +%s)

# Parse CLI arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --check-scripts)
      RUN_SCRIPTS=true
      RUN_DOCS=false
      shift
      ;;
    --check-docs)
      RUN_SCRIPTS=false
      RUN_DOCS=true
      shift
      ;;
    --all)
      RUN_SCRIPTS=true
      RUN_DOCS=true
      shift
      ;;
    --lang)
      TARGET_LANG="${2:-all}"
      shift 2
      ;;
    -v|--verbose)
      VERBOSE=true
      shift
      ;;
    --json)
      JSON_MODE=true
      shift
      ;;
    -h|--help)
      cat <<'EOF'
Oracle DevOps Platform — Multi-Language & i18n Verification Suite

Usage:
  ./tests/test-multilingual-support.sh [OPTIONS]

Options:
  --all            Run all verification suites (default)
  --check-scripts  Run only script messages & i18n engine tests
  --check-docs     Run only documentation language & switcher tests
  --lang <code>    Filter check by language (en, et, fi, sv, lv, lt, all)
  -v, --verbose    Show verbose test diagnostics
  --json           Output results as JSON for CI/CD
  -h, --help       Show this help message

Languages Tested (6 Nordic-Baltic):
  🇬🇧 EN  English (Canonical Primary Source of Truth)
  🇪🇪 ET  Estonian
  🇫🇮 FI  Finnish
  🇸🇪 SV  Swedish
  🇱🇻 LV  Latvian
  🇱🇹 LT  Lithuanian
EOF
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

log_ui() {
  if [ "$JSON_MODE" = "false" ]; then
    echo -e "$@"
  fi
  return 0
}

# Source i18n engine
if [ -f "$WORKSPACE_DIR/scripts/internal/i18n.sh" ]; then
  # shellcheck source=/dev/null
  source "$WORKSPACE_DIR/scripts/internal/i18n.sh"
else
  echo -e "${RED}❌ Fatal: scripts/internal/i18n.sh not found in workspace!${NC}" >&2
  exit 1
fi

log_ui "${CYAN}================================================================================${NC}"
log_ui "${BOLD}🌐 MULTI-LANGUAGE & i18n COMPLIANCE VERIFICATION SUITE (Rule 9)${NC}"
log_ui "   Target Scope: 🇬🇧 EN | 🇪🇪 ET | 🇫🇮 FI | 🇸🇪 SV | 🇱🇻 LV | 🇱🇹 LT"
log_ui "   Workspace:    $WORKSPACE_DIR"
log_ui "${CYAN}================================================================================${NC}"

# ==============================================================================
# SECTION 1: SCRIPT MESSAGES & i18n CENTRAL ENGINE TESTS
# ==============================================================================
run_script_i18n_tests() {
  log_ui "\n${YELLOW}▶️ [FAAS 1]: Skriptide Sõnumite & i18n Mootori Kontroll (Scripts & Engine)...${NC}"

  # 1.1 Language Resolution Test
  TESTS_TOTAL=$((TESTS_TOTAL + 1))
  log_ui "  └─ 1. Keele tuvastamine (Language Resolution & Aliases)..."
  
  RES_ERR=0
  TEST_CASES=(
    "et:et" "est:et" "ee:et"
    "fi:fi" "fin:fi" "suomi:fi"
    "sv:sv" "swe:sv" "se:sv"
    "lv:lv" "lav:lv"
    "lt:lt" "lit:lt"
    "en:en" "eng:en" "gb:en" "us:en"
    "unknown_lang:en"
  )

  for pair in "${TEST_CASES[@]}"; do
    input_lang="${pair%%:*}"
    expected="${pair##*:}"
    resolved=$(CLI_LANG="$input_lang" resolve_cli_lang)
    if [ "$resolved" != "$expected" ]; then
      log_ui "     ${RED}❌ CLI_LANG='$input_lang' expected '$expected' but got '$resolved'${NC}"
      RES_ERR=$((RES_ERR + 1))
    elif [ "$VERBOSE" = "true" ]; then
      log_ui "     ${GREEN}✓${NC} '$input_lang' -> '$resolved'"
    fi
  done

  if [ $RES_ERR -eq 0 ]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    log_ui "     ${GREEN}✅ Keeletuvastus läbis kõik 15 testvarianti puhtalt!${NC}"
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi

  # 1.2 Dictionary Key Symmetry across all 6 languages
  TESTS_TOTAL=$((TESTS_TOTAL + 1))
  log_ui "  └─ 2. Sõnastiku sümmeetria kontroll (Key Symmetry across 6 Languages)..."

  SYM_RESULT=$(python3 -c '
import re, sys

i18n_path = "'"$WORKSPACE_DIR"'/scripts/internal/i18n.sh"
with open(i18n_path, "r", encoding="utf-8") as f:
    lines = f.readlines()

keys_by_lang = {}
for line in lines:
    m = re.match(r"^_reg_msg\s+([a-z]+)\s+([A-Za-z0-9_]+)\s+\"(.*)\"", line)
    if m:
        lang, key, text = m.group(1), m.group(2), m.group(3)
        keys_by_lang.setdefault(lang, {})[key] = text

all_langs = ["en", "et", "fi", "sv", "lv", "lt"]
en_keys = set(keys_by_lang.get("en", {}).keys())

missing_total = 0
empty_total = 0
details = []

for l in all_langs:
    l_keys = set(keys_by_lang.get(l, {}).keys())
    missing = en_keys - l_keys
    if missing:
        missing_total += len(missing)
        details.append(f"❌ {l.upper()} puuduvad võtmed ({len(missing)}): {sorted(list(missing))}")
    for k, v in keys_by_lang.get(l, {}).items():
        if not v.strip():
            empty_total += 1
            details.append(f"❌ {l.upper()} tühi tõlge võtmel: {k}")

total_en = len(en_keys)
print(f"{total_en}|{missing_total}|{empty_total}")
for d in details:
    print(d)
')

  TOTAL_EN_KEYS=$(echo "$SYM_RESULT" | head -n 1 | cut -d'|' -f1)
  MISSING_KEYS_CNT=$(echo "$SYM_RESULT" | head -n 1 | cut -d'|' -f2)
  EMPTY_KEYS_CNT=$(echo "$SYM_RESULT" | head -n 1 | cut -d'|' -f3)

  if [ "$MISSING_KEYS_CNT" -eq 0 ] && [ "$EMPTY_KEYS_CNT" -eq 0 ]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    log_ui "     ${GREEN}✅ 100% Sümmeetria: Kõik ${TOTAL_EN_KEYS} võtit on tõlgitud kõigis 6 keeles!${NC}"
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    log_ui "     ${RED}❌ Tõlkevead: ${MISSING_KEYS_CNT} puuduvat võtit, ${EMPTY_KEYS_CNT} tühja kirjet!${NC}"
    if [ "$JSON_MODE" = "false" ]; then
      echo "$SYM_RESULT" | tail -n +2
    fi
  fi

  # 1.3 Format String Specifier Token Symmetry (%s, %d, %f)
  TESTS_TOTAL=$((TESTS_TOTAL + 1))
  log_ui "  └─ 3. Format specifier (%s, %d) parameetrite sümmeetria..."

  FMT_RESULT=$(python3 -c '
import re, sys

i18n_path = "'"$WORKSPACE_DIR"'/scripts/internal/i18n.sh"
with open(i18n_path, "r", encoding="utf-8") as f:
    lines = f.readlines()

data = {}
for line in lines:
    m = re.match(r"^_reg_msg\s+([a-z]+)\s+([A-Za-z0-9_]+)\s+\"(.*)\"", line)
    if m:
        lang, key, text = m.group(1), m.group(2), m.group(3)
        specifiers = re.findall(r"%[0-9]*\.?[0-9]*[sdifxX%]", text)
        data.setdefault(key, {})[lang] = specifiers

mismatches = []
for key, langs in data.items():
    en_spec = langs.get("en", [])
    for l, spec in langs.items():
        if len(spec) != len(en_spec):
            mismatches.append(f"❌ Parameetrite arvu erinevus võtmel [{key}] ({l.upper()}: {len(spec)} vs EN: {len(en_spec)})")

print(f"{len(mismatches)}")
for m in mismatches:
    print(m)
')

  FMT_MISMATCHES=$(echo "$FMT_RESULT" | head -n 1)
  if [ "$FMT_MISMATCHES" -eq 0 ]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    log_ui "     ${GREEN}✅ Format-parameetrid (%s, %d jne) ühtivad 100% kõigis keeltes!${NC}"
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    log_ui "     ${RED}❌ Leiti ${FMT_MISMATCHES} formaadi parameetri lahknevust!${NC}"
    if [ "$JSON_MODE" = "false" ]; then
      echo "$FMT_RESULT" | tail -n +2
    fi
  fi

  # 1.4 Script Key Usage & Unregistered Keys Audit
  TESTS_TOTAL=$((TESTS_TOTAL + 1))
  log_ui "  └─ 4. Skriptides kasutatavate teadete registreerituse audit..."

  SCRIPT_AUDIT=$(python3 -c '
import glob, re, os, sys

workspace = "'"$WORKSPACE_DIR"'"
i18n_path = os.path.join(workspace, "scripts/internal/i18n.sh")

# Load registered EN keys
with open(i18n_path, "r", encoding="utf-8") as f:
    i18n_content = f.read()

en_keys = set(re.findall(r"_reg_msg\s+en\s+([A-Za-z0-9_]+)\s+", i18n_content))

# Scan all production shell scripts
unregistered = []
total_usages = 0
used_keys = set()

for sh in glob.glob(os.path.join(workspace, "scripts/**/*.sh"), recursive=True):
    if "i18n.sh" in sh:
        continue
    with open(sh, "r", encoding="utf-8", errors="ignore") as f:
        content = f.read()
    matches = re.findall(r"msg_(?:print|err|str)\s+[\"'\''\"]([A-Za-z0-9_]+)[\"'\''\"]", content)
    for m in matches:
        total_usages += 1
        used_keys.add(m)
        if m not in en_keys:
            unregistered.append((os.path.relpath(sh, workspace), m))

print(f"{total_usages}|{len(used_keys)}|{len(unregistered)}")
for path, k in unregistered:
    print(f"❌ Registreerimata võti skriptis {path}: {k}")
')

  TOTAL_USAGES=$(echo "$SCRIPT_AUDIT" | head -n 1 | cut -d'|' -f1)
  UNIQUE_USED_KEYS=$(echo "$SCRIPT_AUDIT" | head -n 1 | cut -d'|' -f2)
  UNREGISTERED_CNT=$(echo "$SCRIPT_AUDIT" | head -n 1 | cut -d'|' -f3)

  if [ "$UNREGISTERED_CNT" -eq 0 ]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    log_ui "     ${GREEN}✅ Kõik ${TOTAL_USAGES} teadete väljakutset (${UNIQUE_USED_KEYS} unikaalset võtit) on i18n mootoris registreeritud!${NC}"
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    log_ui "     ${RED}❌ Leiti ${UNREGISTERED_CNT} registreerimata võtit skriptides!${NC}"
    if [ "$JSON_MODE" = "false" ]; then
      echo "$SCRIPT_AUDIT" | tail -n +2
    fi
  fi

  # 1.5 3-Tier Fallback Hierarchy & Dynamic Resolution
  TESTS_TOTAL=$((TESTS_TOTAL + 1))
  log_ui "  └─ 5. Kolmetasemelise varunduse (3-Tier Fallback) test..."

  FB_ERR=0
  # Tier 1: Target language value
  export ACTIVE_CLI_LANG="fi"
  export CLI_LANG="fi"
  out_fi=$(msg_str "TITLE_SETUP")
  if [[ "$out_fi" != *"YMPÄRISTÖN ASENNUS"* ]]; then
    FB_ERR=$((FB_ERR + 1))
  fi

  # Tier 2: Fallback to EN if specific language variable missing
  unset _I18N_fi_DUMMY_TIER_KEY 2>/dev/null || true
  _reg_msg en DUMMY_TIER_KEY "English Fallback Value"
  export ACTIVE_CLI_LANG="fi"
  export CLI_LANG="fi"
  out_fb=$(msg_str "DUMMY_TIER_KEY")
  if [ "$out_fb" != "English Fallback Value" ]; then
    FB_ERR=$((FB_ERR + 1))
  fi

  # Tier 3: Fallback to raw key if completely unknown
  out_raw=$(msg_str "UNKNOWN_NONEXISTENT_KEY_9999")
  if [ "$out_raw" != "UNKNOWN_NONEXISTENT_KEY_9999" ]; then
    FB_ERR=$((FB_ERR + 1))
  fi

  # Reset active lang
  export ACTIVE_CLI_LANG="en"
  export CLI_LANG="en"

  if [ $FB_ERR -eq 0 ]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    log_ui "     ${GREEN}✅ 3-tasemeline rikketaluvus (Tase 1 -> Tase 2 -> Tase 3) toimib tõrgeteta!${NC}"
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    log_ui "     ${RED}❌ 3-tasemelise varunduse test ebaõnnestus!${NC}"
  fi

  # 1.6 Machine-Readability Invariant Check (Rule 9.3)
  TESTS_TOTAL=$((TESTS_TOTAL + 1))
  log_ui "  └─ 6. Masinloetavuse puutumatuse kontroll (Rule 9.3 Machine-Readability)..."

  MR_RESULT=$(python3 -c '
import os, json, re

workspace = "'"$WORKSPACE_DIR"'"
metrics_json = os.path.join(workspace, "metrics/setup_benchmarks.json")
metrics_env = os.path.join(workspace, "metrics/setup_benchmarks.env")

non_ascii_keys = []
if os.path.exists(metrics_json):
    with open(metrics_json, "r", encoding="utf-8") as f:
        data = json.load(f)
    for k in data.keys():
        if not re.match(r"^[a-zA-Z0-9_]+$", k):
            non_ascii_keys.append(f"metrics_json:{k}")

if os.path.exists(metrics_env):
    with open(metrics_env, "r", encoding="utf-8") as f:
        for line in f:
            if "=" in line and not line.startswith("#"):
                k = line.split("=")[0].strip()
                if not re.match(r"^[a-zA-Z0-9_]+$", k):
                    non_ascii_keys.append(f"metrics_env:{k}")

print(f"{len(non_ascii_keys)}")
for k in non_ascii_keys:
    print(f"❌ Mittestandardne võti mõõdikutes: {k}")
')

  MR_ERR_CNT=$(echo "$MR_RESULT" | head -n 1)
  if [ "$MR_ERR_CNT" -eq 0 ]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    log_ui "     ${GREEN}✅ CI/CD mõõdikud ja logide nimed vastavad rangelt kanoonilisele inglise keelele!${NC}"
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    log_ui "     ${RED}❌ Mõõdikute võtmetes tuvastati mitte-kanoonilisi elemente!${NC}"
    if [ "$JSON_MODE" = "false" ]; then
      echo "$MR_RESULT" | tail -n +2
    fi
  fi
  return 0
}

# ==============================================================================
# SECTION 2: DOCUMENTATION MULTI-LANGUAGE VERIFICATION
# ==============================================================================
run_doc_multilingual_tests() {
  log_ui "\n${YELLOW}▶️ [FAAS 2]: Dokumentatsiooni Mitmekeelsuse Kontroll (Docs & Switchers)...${NC}"

  # 2.1 Language Switcher Header Integrity & Target Validation
  TESTS_TOTAL=$((TESTS_TOTAL + 1))
  log_ui "  └─ 1. Keelelüliti päiste (Language Switcher Headers) kontroll..."

  DOCS_SWITCHER_RESULT=$(python3 -c '
import glob, re, os, sys

workspace = "'"$WORKSPACE_DIR"'"
broken_links = []
valid_switchers = 0

all_mds = glob.glob(os.path.join(workspace, "**/*.md"), recursive=True)
for md in all_mds:
    rel_md = os.path.relpath(md, workspace)
    if "/." in rel_md or rel_md.startswith(".") or "install_logs" in rel_md or "node_modules" in rel_md or "tests/reports" in rel_md:
        continue
    
    with open(md, "r", encoding="utf-8", errors="ignore") as f:
        head_lines = [f.readline() for _ in range(5)]
    head = "".join(head_lines)
    
    # Check if this is a localized or core doc
    if re.search(r"\[.*(?:English|Eesti|Suomi|Svenska|Latviešu|Lietuvių).*\]\(", head):
        valid_switchers += 1
        dir_path = os.path.dirname(md)
        links = re.findall(r"\[([^\]]+)\]\(([^)]+)\)", head_lines[0] if head_lines else "")
        for text, link in links:
            clean = link.split("#")[0].strip()
            if not clean or clean.startswith("http") or clean.startswith("mailto:"):
                continue
            target = os.path.normpath(os.path.join(dir_path, clean))
            if not os.path.exists(target):
                broken_links.append((rel_md, text, link, os.path.relpath(target, workspace)))

print(f"{valid_switchers}|{len(broken_links)}")
for src, txt, lnk, tgt in broken_links:
    print(f"❌ Katkine keelelüliti link failis {src}: [{txt}]({lnk}) -> {tgt} puudub!")
')

  VALID_SWITCHERS=$(echo "$DOCS_SWITCHER_RESULT" | head -n 1 | cut -d'|' -f1)
  BROKEN_SWITCHER_LINKS=$(echo "$DOCS_SWITCHER_RESULT" | head -n 1 | cut -d'|' -f2)

  if [ "$BROKEN_SWITCHER_LINKS" -eq 0 ] && [ "$VALID_SWITCHERS" -gt 0 ]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    log_ui "     ${GREEN}✅ Kõik ${VALID_SWITCHERS} keelelülitit on korrektsed ja viitavad eksisteerivatele failidele!${NC}"
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    log_ui "     ${RED}❌ Leiti ${BROKEN_SWITCHER_LINKS} katkist linki keelelülitite päistes!${NC}"
    if [ "$JSON_MODE" = "false" ]; then
      echo "$DOCS_SWITCHER_RESULT" | tail -n +2
    fi
  fi

  # 2.2 Localized Documents Inventory & Coverage Matrix
  TESTS_TOTAL=$((TESTS_TOTAL + 1))
  log_ui "  └─ 2. Dokumentide lokaliseerimise maatriks (Localization Matrix)..."

  MATRIX_RESULT=$(python3 -c '
import os, glob

workspace = "'"$WORKSPACE_DIR"'"
langs = ["en", "et", "fi", "sv", "lv", "lt"]
doc_counts = {}

# Canonical EN count in docs/ and root
en_files = [f for f in glob.glob(os.path.join(workspace, "docs/*.md"))]
if os.path.exists(os.path.join(workspace, "README.md")):
    en_files.append(os.path.join(workspace, "README.md"))
if os.path.exists(os.path.join(workspace, "config/blueprints/README.md")):
    en_files.append(os.path.join(workspace, "config/blueprints/README.md"))

doc_counts["en"] = len(en_files)

# Localized folders
for l in ["et", "fi", "sv", "lv", "lt"]:
    l_files = glob.glob(os.path.join(workspace, f"docs/{l}/*.md"))
    bp_file = os.path.join(workspace, f"config/blueprints/README.{l}.md")
    if os.path.exists(bp_file):
        l_files.append(bp_file)
    doc_counts[l] = len(l_files)

print("|".join([f"{l}:{doc_counts[l]}" for l in langs]))
')

  IFS='|' read -r -a LANG_COUNTS <<< "$MATRIX_RESULT" || true

  log_ui "     ${BLUE}📋 Dokumentide arv keelte lõikes:${NC}"
  for item in "${LANG_COUNTS[@]}"; do
    l_code=$(echo "$item" | cut -d':' -f1)
    l_cnt=$(echo "$item" | cut -d':' -f2)
    case "$l_code" in
      en) log_ui "        🇬🇧 EN (Canonical Source): ${BOLD}${l_cnt} docs${NC}" ;;
      et) log_ui "        🇪🇪 ET (Estonian):         ${BOLD}${l_cnt} docs${NC}" ;;
      fi) log_ui "        🇫🇮 FI (Finnish):          ${BOLD}${l_cnt} docs${NC}" ;;
      sv) log_ui "        🇸🇪 SV (Swedish):          ${BOLD}${l_cnt} docs${NC}" ;;
      lv) log_ui "        🇱🇻 LV (Latvian):          ${BOLD}${l_cnt} docs${NC}" ;;
      lt) log_ui "        🇱🇹 LT (Lithuanian):       ${BOLD}${l_cnt} docs${NC}" ;;
    esac
  done

  # Verify at least minimal core documentation exists for each of the 6 languages
  MINIMAL_LANG_FAIL=0
  for item in "${LANG_COUNTS[@]}"; do
    l_cnt=$(echo "$item" | cut -d':' -f2)
    if [ "$l_cnt" -lt 1 ]; then
      MINIMAL_LANG_FAIL=$((MINIMAL_LANG_FAIL + 1))
    fi
  done

  if [ $MINIMAL_LANG_FAIL -eq 0 ]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    log_ui "     ${GREEN}✅ Kõik 6 keelt omavad ametlikke lokaliseeritud juhendeid!${NC}"
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    log_ui "     ${RED}❌ Mõnedel keeltel puuduvad lokaliseeritud failid!${NC}"
  fi
  return 0
}

# Run requested sections
if [ "$RUN_SCRIPTS" = "true" ]; then
  run_script_i18n_tests
fi

if [ "$RUN_DOCS" = "true" ]; then
  run_doc_multilingual_tests
fi

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

# JSON output mode for CI/CD metrics
if [ "$JSON_MODE" = "true" ]; then
  python3 -c '
import json, sys

failed = int("'"$TESTS_FAILED"'")
result = {
    "test_suite": "multilingual_i18n_verification",
    "status": "PASSED" if failed == 0 else "FAILED",
    "total_tests": '"$TESTS_TOTAL"',
    "passed_tests": '"$TESTS_PASSED"',
    "failed_tests": failed,
    "duration_seconds": '"$DURATION"',
    "languages": ["en", "et", "fi", "sv", "lv", "lt"],
    "canonical_primary": "en"
}
print(json.dumps(result, indent=2))
'
  exit "$TESTS_FAILED"
fi

# ==============================================================================
# SECTION 3: STANDARDIZED TERMINAL SUMMARY (Rule 7)
# ==============================================================================
log_ui "\n${CYAN}================================================================================${NC}"
if [ $TESTS_FAILED -eq 0 ]; then
  log_ui "${GREEN}${BOLD}🎉 MULTI-LANGUAGE & i18n TESTID LÄBITUD EDUKALT! (100% PASS)${NC}"
  log_ui "   📊 Kontrollitud teste: ${BOLD}${TESTS_TOTAL} / ${TESTS_TOTAL}${NC}"
  log_ui "   🌐 Toetatud keeled:    🇬🇧 EN | 🇪🇪 ET | 🇫🇮 FI | 🇸🇪 SV | 🇱🇻 LV | 🇱🇹 LT"
  log_ui "   ⌛ Kogukestus:         ${YELLOW}${DURATION}s${NC}"
  log_ui "${CYAN}================================================================================${NC}"
  exit 0
else
  log_ui "${RED}${BOLD}❌ MULTI-LANGUAGE TESTIDES LEITI VIGASID! (${TESTS_FAILED} ebaõnnestus)${NC}"
  log_ui "   📊 Kontrollitud teste: ${TESTS_TOTAL} (Läbis: ${TESTS_PASSED}, Ebaõnnestus: ${TESTS_FAILED})"
  log_ui "   ⌛ Kogukestus:         ${DURATION}s"
  log_ui "${CYAN}================================================================================${NC}"
  exit 1
fi
