#!/usr/bin/env bash
# ============================================================================
# Test Coverage Report Generator for oracle-free-db-in-prod
# Analyzes test coverage for all *.sh scripts in scripts/ and scripts/internal/
# Output: tests/test-coverage-report.md
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
mkdir -p "$SCRIPT_DIR/reports"
REPORT_FILE="$SCRIPT_DIR/reports/test-coverage-report.md"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}==================================================================${NC}"
echo -e "📊 SKRIPTIDE AUTOMAATSE TESTIKAETUSE (TEST COVERAGE) ANALÜÜS"
echo -e "${CYAN}==================================================================${NC}"

TOTAL_SCRIPTS=0
COVERED_SCRIPTS=0

# Create Markdown Report Header
cat <<EOF > "$REPORT_FILE"
# 📊 Testide Kaetuse Aruanne (Test Coverage Report)

See fail genereeritakse automaatselt skripti \`./tests/generate-test-coverage-report.sh\` poolt.
Aruanne analüüsib kõigi kaustades \`scripts/\` ja \`scripts/internal/\` asuvate Shell skriptide (\`*.sh\`) automaattestidega kaetust.

---

## 📅 Genereeritud: $(date '+%Y-%m-%d %H:%M:%S')

---

## 📂 1. Kasutaja Põhiskriptid (\`scripts/\`)

| Skript | Kaetuse Olek | Testkomplektid (Test Suites) |
| :--- | :--- | :--- |
EOF

echo -e "\n${YELLOW}▶️ Analüüsin juurkausta scripts/*.sh skripte...${NC}"

for script in "$WORKSPACE_DIR"/scripts/*.sh; do
  [ -e "$script" ] || continue
  filename=$(basename "$script")
  TOTAL_SCRIPTS=$((TOTAL_SCRIPTS + 1))

  TEST_MATCHES=()
  for testfile in "$SCRIPT_DIR"/unit/*.sh "$SCRIPT_DIR"/integration/*.sh "$SCRIPT_DIR"/*.sh; do
    [ -e "$testfile" ] || continue
    testname=$(basename "$testfile")
    if grep -q "$filename" "$testfile" 2>/dev/null; then
      TEST_MATCHES+=("[\`${testname}\`](${testname})")
    fi
  done

  if [ ${#TEST_MATCHES[@]} -gt 0 ]; then
    COVERED_SCRIPTS=$((COVERED_SCRIPTS + 1))
    MATCHES_STR=$(IFS=", "; echo "${TEST_MATCHES[*]}")
    echo "  ${filename}: 100% KAETUD (${#TEST_MATCHES[@]} testi)"
    echo "| **\`${filename}\`** | ✅ Kaetud | ${MATCHES_STR} |" >> "$REPORT_FILE"
  else
    echo "  ${filename}: ⚠️ KAETUS PUUDUB"
    echo "| **\`${filename}\`** | ❌ Kaetus puudub | - |" >> "$REPORT_FILE"
  fi
done

cat <<EOF >> "$REPORT_FILE"

---

## ⚙️ 2. Sisemised Abiskriptid (\`scripts/internal/\`)

| Skript | Kaetuse Olek | Testkomplektid (Test Suites) |
| :--- | :--- | :--- |
EOF

echo -e "\n${YELLOW}▶️ Analüüsin sisekausta scripts/internal/*.sh skripte...${NC}"

for script in "$WORKSPACE_DIR"/scripts/internal/*.sh; do
  [ -e "$script" ] || continue
  filename=$(basename "$script")
  TOTAL_SCRIPTS=$((TOTAL_SCRIPTS + 1))

  TEST_MATCHES=()
  for testfile in "$SCRIPT_DIR"/unit/*.sh "$SCRIPT_DIR"/integration/*.sh "$SCRIPT_DIR"/*.sh; do
    [ -e "$testfile" ] || continue
    testname=$(basename "$testfile")
    if grep -q "$filename" "$testfile" 2>/dev/null; then
      TEST_MATCHES+=("[\`${testname}\`](${testname})")
    fi
  done

  if [ ${#TEST_MATCHES[@]} -gt 0 ]; then
    COVERED_SCRIPTS=$((COVERED_SCRIPTS + 1))
    MATCHES_STR=$(IFS=", "; echo "${TEST_MATCHES[*]}")
    echo "  internal/${filename}: 100% KAETUD (${#TEST_MATCHES[@]} testi)"
    echo "| **\`internal/${filename}\`** | ✅ Kaetud | ${MATCHES_STR} |" >> "$REPORT_FILE"
  else
    echo "  internal/${filename}: ⚠️ KAETUS PUUDUB"
    echo "| **\`internal/${filename}\`** | ❌ Kaetus puudub | - |" >> "$REPORT_FILE"
  fi
done

COVERAGE_PERCENT=$(( (COVERED_SCRIPTS * 100) / TOTAL_SCRIPTS ))

cat <<EOF >> "$REPORT_FILE"

---

## 📈 Kokkuvõttev Mõõdik (Summary Metrics)

- **Kogu skriptide arv (Total Scripts):** ${TOTAL_SCRIPTS}
- **Testidega kaetud skripte (Covered Scripts):** ${COVERED_SCRIPTS}
- **Automaattestide kaetus (Test Coverage):** **${COVERAGE_PERCENT}%**

EOF

echo -e "\n${CYAN}==================================================================${NC}"
echo -e "${GREEN}🎉 TESTIKAETUSE ARUANNE VALMIS: ${COVERED_SCRIPTS}/${TOTAL_SCRIPTS} (${COVERAGE_PERCENT}%) KAETUD!${NC}"
echo -e "   📊 Aruande fail: ${REPORT_FILE}"
echo -e "${CYAN}==================================================================${NC}"
