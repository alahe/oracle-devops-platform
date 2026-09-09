#!/usr/bin/env bash
# ==============================================================================
# Oracle DevOps Platform — Repository Statistics & Architecture Metrics Reporter
# (tests/report-repo-stats.sh)
#
# Gathers comprehensive repository metrics, code breakdown (LOC), testing suite
# distribution, architecture blueprints, profiles, and 6-language i18n parity.
#
# Outputs:
#   - Terminal summary (ANSI color formatted)
#   - Markdown report: tests/reports/repo-stats-report.md
#   - JSON metrics:    metrics/repo_stats.json
#
# Usage:
#   ./tests/report-repo-stats.sh
#   ./tests/report-repo-stats.sh --json
#   ./tests/report-repo-stats.sh --markdown /path/to/custom-report.md
#   ./tests/report-repo-stats.sh --help
# ==============================================================================

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Output paths
REPORT_DIR="$SCRIPT_DIR/reports"
METRICS_DIR="$WORKSPACE_DIR/metrics"
mkdir -p "$REPORT_DIR" "$METRICS_DIR"

MD_OUT="$REPORT_DIR/repo-stats-report.md"
JSON_OUT="$METRICS_DIR/repo_stats.json"

JSON_ONLY=false
QUIET=false

show_help() {
  cat <<EOF
Usage: $0 [options]

Options:
  -j, --json               Output JSON format only to stdout
  -m, --markdown <FILE>    Custom markdown output path (default: tests/reports/repo-stats-report.md)
  -q, --quiet              Suppress terminal output, only generate files
  -h, --help               Show this help message

Outputs generated:
  - Markdown Report: tests/reports/repo-stats-report.md
  - JSON Metrics:    metrics/repo_stats.json
EOF
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -j|--json)
      JSON_ONLY=true
      shift
      ;;
    -m|--markdown)
      MD_OUT="$2"
      shift 2
      ;;
    -q|--quiet)
      QUIET=true
      shift
      ;;
    -h|--help)
      show_help
      ;;
    *)
      echo "Tundmatu parameeter: $1" >&2
      show_help
      ;;
  esac
done

# Colors
CYAN='\033[1;36m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
BOLD='\033[1m'
NC='\033[0m'

# Run python helper to collect structured statistics
export WORKSPACE_DIR MD_OUT JSON_OUT
python3 - <<'EOF'
import os
import sys
import json
import glob
import re
from datetime import datetime

WORKSPACE = os.environ.get("WORKSPACE_DIR") or os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
MD_OUT = os.environ.get("MD_OUT") or os.path.join(WORKSPACE, "tests/reports/repo-stats-report.md")
JSON_OUT = os.environ.get("JSON_OUT") or os.path.join(WORKSPACE, "metrics/repo_stats.json")

def count_lines(filepath):
    try:
        with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
            return sum(1 for _ in f)
    except Exception:
        return 0

def get_git_files():
    try:
        import subprocess
        res = subprocess.run(["git", "ls-files"], cwd=WORKSPACE, capture_output=True, text=True, check=True)
        return [f.strip() for f in res.stdout.strip().split("\n") if f.strip()]
    except Exception:
        # Fallback to os.walk
        all_files = []
        for root, dirs, files in os.walk(WORKSPACE):
            if ".git" in root or "node_modules" in root or ".gemini" in root:
                continue
            for f in files:
                rel = os.path.relpath(os.path.join(root, f), WORKSPACE)
                all_files.append(rel)
        return all_files

files = get_git_files()
total_files = len(files)

# 1. Code categories & lines of code
categories = {
    "Shell Scripts (.sh, .cmd, .ps1)": {"exts": [".sh", ".cmd", ".ps1"], "files": 0, "loc": 0},
    "Python (.py)": {"exts": [".py"], "files": 0, "loc": 0},
    "SQL (.sql)": {"exts": [".sql"], "files": 0, "loc": 0},
    "APEXlang DSL (.apx)": {"exts": [".apx"], "files": 0, "loc": 0},
    "YAML Profiles & Configs (.yaml, .yml)": {"exts": [".yaml", ".yml"], "files": 0, "loc": 0},
    "JSON Data & Metrics (.json)": {"exts": [".json"], "files": 0, "loc": 0},
    "Markdown Documentation (.md)": {"exts": [".md"], "files": 0, "loc": 0},
    "Web Frontend (.html, .js, .css)": {"exts": [".html", ".js", ".mjs", ".css"], "files": 0, "loc": 0},
}

for rel_p in files:
    full_p = os.path.join(WORKSPACE, rel_p)
    _, ext = os.path.splitext(rel_p)
    ext = ext.lower()
    
    matched = False
    for cat_name, data in categories.items():
        if ext in data["exts"]:
            data["files"] += 1
            data["loc"] += count_lines(full_p)
            matched = True
            break

total_loc = sum(d["loc"] for d in categories.values())

# 2. Testing Suite Breakdown
unit_tests = [f for f in files if f.startswith("tests/unit/") and f.endswith(".sh")]
integration_tests = [f for f in files if f.startswith("tests/integration/") and f.endswith(".sh")]
suite_tests = [f for f in files if re.match(r"^tests/test-[^/]+\.sh$", f)]
all_test_scripts = unit_tests + integration_tests + suite_tests
test_reports = [f for f in files if f.startswith("tests/reports/") and f.endswith(".md")]

test_stats = {
    "unit_tests_count": len(unit_tests),
    "unit_tests_loc": sum(count_lines(os.path.join(WORKSPACE, f)) for f in unit_tests),
    "integration_tests_count": len(integration_tests),
    "integration_tests_loc": sum(count_lines(os.path.join(WORKSPACE, f)) for f in integration_tests),
    "suite_tests_count": len(suite_tests),
    "suite_tests_loc": sum(count_lines(os.path.join(WORKSPACE, f)) for f in suite_tests),
    "total_test_scripts": len(all_test_scripts),
    "total_test_loc": sum(count_lines(os.path.join(WORKSPACE, f)) for f in all_test_scripts),
    "test_reports_count": len(test_reports)
}

# 3. Architecture Blueprints & Profiles
bp_files = glob.glob(os.path.join(WORKSPACE, "config/blueprints/.env.*"))
db_profiles = glob.glob(os.path.join(WORKSPACE, "config/profiles/databases/*.yaml"))
mid_profiles = []
for sub in ["ords", "forms", "publisher", "forms-publisher", "web-ide", "publisher-designer"]:
    mid_profiles.extend(glob.glob(os.path.join(WORKSPACE, f"config/profiles/{sub}/*.yaml")))

arch_stats = {
    "blueprints_count": len(bp_files),
    "db_profiles_count": len(db_profiles),
    "middleware_profiles_count": len(mid_profiles),
    "total_profiles_count": len(db_profiles) + len(mid_profiles)
}

# 4. Multi-Language i18n Distribution
lang_docs = {
    "en": sum(1 for f in files if f.endswith(".md") and not any(f.startswith(f"docs/{l}/") or f.endswith(f".{l}.md") for l in ["et", "fi", "sv", "lv", "lt"])),
    "et": sum(1 for f in files if f.endswith(".md") and (f.startswith("docs/et/") or f.endswith(".et.md"))),
    "fi": sum(1 for f in files if f.endswith(".md") and (f.startswith("docs/fi/") or f.endswith(".fi.md"))),
    "sv": sum(1 for f in files if f.endswith(".md") and (f.startswith("docs/sv/") or f.endswith(".sv.md"))),
    "lv": sum(1 for f in files if f.endswith(".md") and (f.startswith("docs/lv/") or f.endswith(".lv.md"))),
    "lt": sum(1 for f in files if f.endswith(".md") and (f.startswith("docs/lt/") or f.endswith(".lt.md"))),
}

# Count Dev Hub dictionary keys in i18n.js
i18n_keys = {}
i18n_js_file = os.path.join(WORKSPACE, "scripts/internal/dev_hub/assets/i18n.js")
if os.path.isfile(i18n_js_file):
    with open(i18n_js_file, "r", encoding="utf-8") as f:
        content = f.read()
        for lang in ["en", "et", "fi", "sv", "lv", "lt"]:
            match = re.search(r"['\"]?" + lang + r"['\"]?:\s*\{([^}]+)\}", content)
            if match:
                k_count = len(re.findall(r"^\s*[a-zA-Z0-9_]+:\s*", match.group(1), re.MULTILINE))
                i18n_keys[lang] = k_count

stats_data = {
    "timestamp": datetime.now().isoformat(),
    "total_git_files": total_files,
    "total_lines_of_code": total_loc,
    "code_breakdown": categories,
    "test_suite": test_stats,
    "architecture": arch_stats,
    "localization": {
        "languages": ["en", "et", "fi", "sv", "lv", "lt"],
        "markdown_docs_by_lang": lang_docs,
        "devhub_i18n_keys": i18n_keys
    }
}

# Write JSON output
os.makedirs(os.path.dirname(JSON_OUT), exist_ok=True)
with open(JSON_OUT, "w", encoding="utf-8") as jf:
    json.dump(stats_data, jf, indent=2, ensure_ascii=False)

# Write Markdown report
os.makedirs(os.path.dirname(MD_OUT), exist_ok=True)
with open(MD_OUT, "w", encoding="utf-8") as mf:
    mf.write(f"# 📊 Repositooriumi Statistika ja Koodibaasi Mõõdikud\n\n")
    mf.write(f"> **Genereeritud:** `{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}` | **Faile kokku:** `{total_files}` | **Koodiridu (LOC):** `{total_loc:,}`\n\n")
    mf.write("---\n\n")

    mf.write("## 1. 💻 Programmeerimiskeelte ja Failitüüpide Jaotus\n\n")
    mf.write("| Komponent / Keel | Faile | Ridu (LOC) | Osakaal (LOC) |\n")
    mf.write("| :--- | :---: | :---: | :---: |\n")
    for cat_name, data in categories.items():
        pct = (data["loc"] / total_loc * 100) if total_loc > 0 else 0
        mf.write(f"| **{cat_name}** | `{data['files']}` | `{data['loc']:,}` | `{pct:.1f}%` |\n")
    mf.write(f"| **KOKKU** | **`{total_files}`** | **`{total_loc:,}`** | **`100.0%`** |\n\n")
    mf.write("---\n\n")

    mf.write("## 2. 🧪 Testimissüsteemi ja Kvaliteedikontrolli Mõõdikud\n\n")
    mf.write("| Testikategooria | Skripte / Aruandeid | Ridu (LOC) | Kirjeldus |\n")
    mf.write("| :--- | :---: | :---: | :--- |\n")
    mf.write(f"| **Ühiktestid (`tests/unit/*.sh`)** | `{test_stats['unit_tests_count']}` | `{test_stats['unit_tests_loc']:,}` | Kiired, isoleeritud testid (profiilid, süntaks, i18n, pariteet) |\n")
    mf.write(f"| **Integratsioonitestid (`tests/integration/*.sh`)** | `{test_stats['integration_tests_count']}` | `{test_stats['integration_tests_loc']:,}` | Mitme komponendi koostöö ja topoloogia testid |\n")
    mf.write(f"| **Platvormi & E2E Testikomplektid (`tests/*.sh`)** | `{test_stats['suite_tests_count']}` | `{test_stats['suite_tests_loc']:,}` | Täielikud elutsükli-, brauseri- ja turvaauditid |\n")
    mf.write(f"| **Aruanded ja Benchmarkid (`tests/reports/`)** | `{test_stats['test_reports_count']}` | — | Automatiseeritud Markdown testitulemuste raportid |\n")
    mf.write(f"| **TESTISKIPTE KOKKU** | **`{test_stats['total_test_scripts']}`** | **`{test_stats['total_test_loc']:,}`** | **Testikaetus üle kogu platvormi** |\n\n")
    mf.write("---\n\n")

    mf.write("## 3. 🏗️ Arhitektuursed Blueprindid ja Profiilid\n\n")
    mf.write("| Ressurss | Kogus | Asukoht | Märkused |\n")
    mf.write("| :--- | :---: | :--- | :--- |\n")
    mf.write(f"| **Arhitektuurilised Blueprindid** | `{arch_stats['blueprints_count']}` | `config/blueprints/.env.*` | BP 0 kuni BP 11 (Kanoonilised lahendused) |\n")
    mf.write(f"| **Andmebaasiprofiilid (DB)** | `{arch_stats['db_profiles_count']}` | `config/profiles/databases/*.yaml` | Oracle 23ai Free, ALISE, Forms, Publisher, ADB, Gvenzl |\n")
    mf.write(f"| **Vahevara profiilid (Middleware)** | `{arch_stats['middleware_profiles_count']}` | `config/profiles/{{ords,forms,publisher...}}` | ORDS, Forms, Publisher, Web-IDE, Designer |\n")
    mf.write(f"| **Profiile kokku** | **`{arch_stats['total_profiles_count']}`** | `config/profiles/` | 100% deklaratiivne konfiguratsioon |\n\n")
    mf.write("---\n\n")

    mf.write("## 4. 🌍 Lokaliseerimise Pariteet (6 Keelt: 🇬🇧 EN, 🇪🇪 ET, 🇫🇮 FI, 🇸🇪 SV, 🇱🇻 LV, 🇱🇹 LT)\n\n")
    mf.write("| Keel | Lipuke | Dokumente (`.md`) | Dev Hub Sõnastiku Võtmeid |\n")
    mf.write("| :--- | :---: | :---: | :---: |\n")
    flags = {"en": "🇬🇧", "et": "🇪🇪", "fi": "🇫🇮", "sv": "🇸🇪", "lv": "🇱🇻", "lt": "🇱🇹"}
    names = {"en": "Inglise (Canonical)", "et": "Eesti", "fi": "Soome", "sv": "Rootsi", "lv": "Läti", "lt": "Leedu"}
    for l in ["en", "et", "fi", "sv", "lv", "lt"]:
        mf.write(f"| **{names[l]}** | {flags[l]} `{l.upper()}` | `{lang_docs[l]}` | `{i18n_keys.get(l, 0)}` |\n")
    mf.write("\n---\n")

EOF

if [ "$JSON_ONLY" = "true" ]; then
  cat "$JSON_OUT"
  exit 0
fi

if [ "$QUIET" = "false" ]; then
  echo -e "${CYAN}==================================================================${NC}"
  echo -e "${BOLD}📊 REPOSITOORIUMI STATISTIKA JA MÕÕDIKUD (REPO STATS)${NC}"
  echo -e "${CYAN}==================================================================${NC}"

  # Read JSON data and print compact ANSI table
  python3 - <<'EOF'
import os
import json

WORKSPACE = os.environ.get("WORKSPACE_DIR", ".")
JSON_OUT = os.environ.get("JSON_OUT", os.path.join(WORKSPACE, "metrics/repo_stats.json"))
MD_OUT = os.environ.get("MD_OUT", os.path.join(WORKSPACE, "tests/reports/repo-stats-report.md"))

with open(JSON_OUT, "r", encoding="utf-8") as f:
    d = json.load(f)

tot_f = d["total_git_files"]
tot_loc = d["total_lines_of_code"]
t_stats = d["test_suite"]
a_stats = d["architecture"]
loc_stats = d["localization"]

print(f"\n📂 \033[1;36mFailid ja Koodiridade Kogumaht (LOC):\033[0m")
print(f"   - Faile Git registris:      \033[1;32m{tot_f:,}\033[0m")
print(f"   - Koodiridu kokku:          \033[1;32m{tot_loc:,}\033[0m LOC\n")

print(f"💻 \033[1;34mKoodi jaotus kategooriate lõikes:\033[0m")
for cat, c_data in d["code_breakdown"].items():
    pct = (c_data["loc"] / tot_loc * 100) if tot_loc > 0 else 0
    print(f"   • {cat:<36} \033[1m{c_data['files']:4d}\033[0m faili | \033[1;32m{c_data['loc']:7,d}\033[0m LOC ({pct:4.1f}%)")

print(f"\n🧪 \033[1;33mAutomaattestide Süsteem:\033[0m")
print(f"   • Ühiktestid (tests/unit/):        \033[1;32m{t_stats['unit_tests_count']:3d}\033[0m skripti ({t_stats['unit_tests_loc']:,} LOC)")
print(f"   • Integratsioonitestid:            \033[1;32m{t_stats['integration_tests_count']:3d}\033[0m skripti ({t_stats['integration_tests_loc']:,} LOC)")
print(f"   • Platvormi testikomplektid:       \033[1;32m{t_stats['suite_tests_count']:3d}\033[0m skripti ({t_stats['suite_tests_loc']:,} LOC)")
print(f"   • Testiskripte kokku:              \033[1;32m{t_stats['total_test_scripts']:3d}\033[0m skripti (\033[1m{t_stats['total_test_loc']:,}\033[0m LOC)")
print(f"   • Aruandeid (tests/reports/):      \033[1;32m{t_stats['test_reports_count']:3d}\033[0m raportit")

print(f"\n🏗️  \033[1;35mArhitektuur ja Blueprindid:\033[0m")
print(f"   • Blueprinte (BP 0..11):           \033[1;32m{a_stats['blueprints_count']:3d}\033[0m lahendust")
print(f"   • Andmebaasiprofiile:              \033[1;32m{a_stats['db_profiles_count']:3d}\033[0m profiili")
print(f"   • Vahevara profiile:               \033[1;32m{a_stats['middleware_profiles_count']:3d}\033[0m profiili")

print(f"\n🌍 \033[1;36mLokaliseerimise Pariteet (6 Keelt):\033[0m")
docs = loc_stats["markdown_docs_by_lang"]
keys = loc_stats["devhub_i18n_keys"]
flags = {"en": "🇬🇧 EN", "et": "🇪🇪 ET", "fi": "🇫🇮 FI", "sv": "🇸🇪 SV", "lv": "🇱🇻 LV", "lt": "🇱🇹 LT"}
for l in ["en", "et", "fi", "sv", "lv", "lt"]:
    print(f"   • {flags[l]}: \033[1;32m{docs.get(l, 0):3d}\033[0m dokumenti | \033[1;34m{keys.get(l, 0):3d}\033[0m Dev Hub sõnastiku võtit")

print(f"\n📄 \033[1mRaportid salvestatud:\033[0m")
print(f"   • Markdown: \033[1;36m{MD_OUT}\033[0m")
print(f"   • JSON:     \033[1;36m{JSON_OUT}\033[0m")
EOF

  echo -e "${CYAN}==================================================================${NC}"
  echo -e "${GREEN}🎉 Repositooriumi statistika edukalt kogutud ja salvestatud!${NC}"
  echo -e "${CYAN}==================================================================${NC}"
fi

exit 0
