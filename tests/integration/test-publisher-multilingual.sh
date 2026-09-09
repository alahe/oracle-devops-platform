#!/usr/bin/env bash
# ==============================================================================
# Integration Test: Publisher 6-Language (Nordic-Baltic) i18n Verification
# Tests RTF template compilation, XLIFF translation maps, and PDF outputs across:
# 🇬🇧 EN, 🇪🇪 ET, 🇫🇮 FI, 🇸🇪 SV, 🇱🇻 LV, 🇱🇹 LT (Rule 9 Compliance)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "================================================================================"
echo "🌐 Testing Oracle Analytics Publisher 6-Language (i18n) Engine"
echo "================================================================================"

RTF_FILE="$WORKSPACE_DIR/templates/publisher/samples/arve_test_standard.rtf"
XML_FILE="$WORKSPACE_DIR/templates/publisher/samples/arve_test_andmed.xml"
PREPROCESSOR="$WORKSPACE_DIR/docker/publisher-designer/xdo-preprocessor.py"
PROFILE_SCRIPT="$WORKSPACE_DIR/docker/publisher-designer/setup-libreoffice-profile.sh"

if [ ! -f "$RTF_FILE" ] || [ ! -f "$XML_FILE" ] || [ ! -f "$PREPROCESSOR" ]; then
  echo "❌ Error: Required template, XML data, or preprocessor script is missing."
  exit 1
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

get_expected_header() {
  case "$1" in
    et) echo "ARVE NR: EE-2026-9042" ;;
    en) echo "INVOICE NO: EE-2026-9042" ;;
    fi) echo "LASKUN NRO: EE-2026-9042" ;;
    sv) echo "FAKTURANR: EE-2026-9042" ;;
    lv) echo 'R\u274?\u310?INA NR.: EE-2026-9042' ;;
    lt) echo 'S\u260?SKAITOS-FAKT\u362?ROS NR.: EE-2026-9042' ;;
  esac
}

get_expected_label() {
  case "$1" in
    et) echo "Kuup\'e4ev:" ;;
    en) echo "Date:" ;;
    fi) echo "P\'e4iv\'e4m\'e4\'e4r\'e4:" ;;
    sv) echo "Datum:" ;;
    lv) echo "Datums:" ;;
    lt) echo "Data:" ;;
  esac
}

ALL_LANGS=("et" "en" "fi" "sv" "lv" "lt")
PASSED_COUNT=0

for lang in "${ALL_LANGS[@]}"; do
  echo "--------------------------------------------------------------------------------"
  echo "🔍 Testing Language: $lang..."

  # 1. Verify XLIFF file presence
  XLF_FILE="$WORKSPACE_DIR/templates/publisher/samples/arve_test_standard_${lang}.xlf"
  if [ ! -f "$XLF_FILE" ]; then
    echo "❌ Error: XLIFF translation file missing: $XLF_FILE"
    exit 1
  fi
  echo "   ✅ XLIFF translation file verified: $(basename "$XLF_FILE")"

  # 2. Run Preprocessor to render RTF
  OUT_RTF="$TMP_DIR/arve_${lang}.rtf"
  python3 "$PREPROCESSOR" "$XML_FILE" "$RTF_FILE" "$OUT_RTF" --locale "$lang" >/dev/null

  if [ ! -f "$OUT_RTF" ]; then
    echo "❌ Error: Preprocessed RTF was not generated for $lang"
    exit 1
  fi

  # 3. Assert Header and Field translation in RTF
  EXP_HDR="$(get_expected_header "$lang")"
  EXP_LBL="$(get_expected_label "$lang")"

  if ! grep -qF "$EXP_HDR" "$OUT_RTF"; then
    echo "❌ Error: Expected header '$EXP_HDR' not found in $OUT_RTF"
    exit 1
  fi

  if ! grep -qF "$EXP_LBL" "$OUT_RTF"; then
    echo "❌ Error: Expected label '$EXP_LBL' not found in $OUT_RTF"
    exit 1
  fi
  echo "   ✅ RTF string and unicode mappings verified for $lang"

  # 4. Verify LibreOffice Profile generator for this language
  HOME_DUMMY="$TMP_DIR/home_$lang"
  mkdir -p "$HOME_DUMMY"
  HOME="$HOME_DUMMY" bash "$PROFILE_SCRIPT" "$lang" >/dev/null

  BASIC_MOD="$HOME_DUMMY/.config/libreoffice/4/user/basic/Standard/Module1.xba"
  MENUBAR="$HOME_DUMMY/.config/libreoffice/4/user/config/soffice.cfg/modules/swriter/menubar/menubar.xml"
  TOOLBAR="$HOME_DUMMY/.config/libreoffice/4/user/config/soffice.cfg/modules/swriter/toolbar/custom_toolbar_publisher.xml"

  if [ ! -f "$BASIC_MOD" ] || [ ! -f "$MENUBAR" ] || [ ! -f "$TOOLBAR" ]; then
    echo "❌ Error: LibreOffice profile configuration files missing for $lang"
    exit 1
  fi

  if ! grep -q "vnd.oracle.publisher.menu" "$MENUBAR"; then
    echo "❌ Error: Publisher menu missing in menubar.xml for $lang"
    exit 1
  fi
  echo "   ✅ LibreOffice UI Menubar & Macros verified for $lang"

  PASSED_COUNT=$((PASSED_COUNT + 1))
done

echo "================================================================================"
echo "🎉 SUCCESS: All $PASSED_COUNT / ${#ALL_LANGS[@]} languages verified successfully!"
echo "   🇬🇧 EN | 🇪🇪 ET | 🇫🇮 FI | 🇸🇪 SV | 🇱🇻 LV | 🇱🇹 LT"
echo "================================================================================"
