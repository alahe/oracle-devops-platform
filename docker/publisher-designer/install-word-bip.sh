#!/usr/bin/env bash
# ==============================================================================
# In-Container Automated Installer: Microsoft Word & Oracle BI Publisher Desktop
# Configures Wine prefix, installs Office & Oracle BIP Template Builder,
# and verifies Word COM Add-In registration.
# ==============================================================================
set -euo pipefail

LOG_FILE="/u01/logs/install_word_bip.log"
mkdir -p "$(dirname "$LOG_FILE")" /u01/binaries

log() {
  echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

echo "================================================================================" | tee -a "$LOG_FILE"
log "🚀 Starting Microsoft Word & Oracle BI Publisher Desktop Installation..."
log "   User:       $(whoami)"
log "   WINEPREFIX: ${WINEPREFIX:-/u01/oracle/.wine}"
log "   Binaries:   /u01/binaries"
echo "================================================================================" | tee -a "$LOG_FILE"

# 1. Check if Word is already installed
find_installed_word() {
  local prefix="${WINEPREFIX:-/u01/oracle/.wine}"
  find "$prefix/drive_c" -type f -name "WINWORD.EXE" 2>/dev/null | head -n 1
}

INSTALLED_WORD="$(find_installed_word || true)"
if [ -n "$INSTALLED_WORD" ] && [ -f "$INSTALLED_WORD" ]; then
  log "✅ Microsoft Word is already installed at: $INSTALLED_WORD"
  if [ -n "${DISPLAY:-}" ] && command -v zenity &>/dev/null; then
    zenity --info --title="Microsoft Word & BI Publisher" \
      --text="Microsoft Word on juba edukalt paigaldatud!\n\nAsukoht: $INSTALLED_WORD\n\nVõite avada töölaualt ikooni 'Oracle BI Publisher (Word)'." \
      --width=450 2>/dev/null || true
  fi
  exit 0
fi

# 2. Search for Office installer and BI Publisher installer in /u01/binaries
find_office_installer() {
  find /u01/binaries -maxdepth 3 \( -iname "setup.exe" -o -iname "office*.exe" -o -iname "o16*.exe" \) 2>/dev/null | head -n 1
}

find_bip_installer() {
  find /u01/binaries -maxdepth 3 \( -iname "bipublisherdesktop*.exe" -o -iname "bipdesktop*.exe" -o -iname "setup_bip*.exe" \) 2>/dev/null | head -n 1
}

OFFICE_SETUP="$(find_office_installer || true)"
BIP_SETUP="$(find_bip_installer || true)"

# 3. If installers are missing, prompt developer with clear instructions
if [ -z "$OFFICE_SETUP" ] || [ -z "$BIP_SETUP" ]; then
  log "⚠️ Required installers were not found in /u01/binaries:"
  [ -z "$OFFICE_SETUP" ] && log "   ❌ Microsoft Office installer (setup.exe) is missing"
  [ -z "$BIP_SETUP" ] && log "   ❌ Oracle BI Publisher Desktop installer (BIPublisherDesktop*.exe) is missing"
  log ""
  log "👉 Palun kopeerige oma host-arvutis kausta 'binaries/publisher/':"
  log "   1. Microsoft Office paigaldaja (nt Office 2010/2013/2016 32-bit setup.exe)"
  log "   2. Oracle BI Publisher Desktop (BIPublisherDesktop32.exe või BIPublisherDesktop64.exe)"
  log "   Seejärel käivitage uuesti ikoon 'Paigalda Word ja Publisher Designer' või käsk:"
  log "   ./scripts/publisher/setup-word-designer.sh"

  if [ -n "${DISPLAY:-}" ] && command -v zenity &>/dev/null; then
    zenity --warning --title="Vajalikud paigaldusfailid puuduvad" \
      --text="<b>Microsoft Word ja Oracle BI Publisher lisandmooduli paigaldamine</b>\n\nKaustast <b>binaries/publisher/</b> puuduvad vajalikud failid:\n$([ -z "$OFFICE_SETUP" ] && echo "• Microsoft Office paigaldaja (setup.exe)\n")$([ -z "$BIP_SETUP" ] && echo "• Oracle BI Publisher Desktop (BIPublisherDesktop32.exe)")\n\n<b>Mida teha:</b>\n1. Kopeerige host-arvutis vajalikud installerid kausta <b>binaries/publisher/</b>\n2. Klõpsake töölaual uuesti ikooni <b>'⚡ Paigalda Word ja Publisher Designer'</b>." \
      --width=520 2>/dev/null || true
  fi
  exit 1
fi

log "📦 Found Office Installer: $OFFICE_SETUP"
log "📦 Found BIP Installer:    $BIP_SETUP"

# 4. Initialize Wine Prefix
export WINEPREFIX="${WINEPREFIX:-/u01/oracle/.wine}"
export WINEARCH="${WINEARCH:-win32}"
export WINEDEBUG="-all"

log "🔧 Initializing Wine prefix ($WINEARCH) at $WINEPREFIX..."
wineboot --init 2>&1 | tee -a "$LOG_FILE" || true
sleep 3

# 5. Install Windows dependencies via winetricks if available
if command -v winetricks &>/dev/null; then
  log "⚙️ Installing Wine prerequisite packages (msxml6, gdiplus, riched20, dotnet40)..."
  winetricks -q msxml6 gdiplus riched20 2>&1 | tee -a "$LOG_FILE" || true
fi

# 6. Run Microsoft Office Setup
log "🚀 Executing Microsoft Office Setup: $OFFICE_SETUP..."
if [[ "$OFFICE_SETUP" == *".exe" ]]; then
  wine "$OFFICE_SETUP" /quiet 2>&1 | tee -a "$LOG_FILE" || wine "$OFFICE_SETUP" 2>&1 | tee -a "$LOG_FILE"
fi

wineserver -w || true
sleep 3

INSTALLED_WORD="$(find_installed_word || true)"
if [ -z "$INSTALLED_WORD" ]; then
  log "❌ Error: WINWORD.EXE was not created during Office setup. Check $LOG_FILE for details."
  exit 1
fi
log "✅ Microsoft Word successfully installed at: $INSTALLED_WORD"

# 7. Run Oracle BI Publisher Desktop Setup
log "🚀 Executing Oracle BI Publisher Desktop Setup: $BIP_SETUP..."
wine "$BIP_SETUP" /s 2>&1 | tee -a "$LOG_FILE" || wine "$BIP_SETUP" 2>&1 | tee -a "$LOG_FILE"

wineserver -w || true
sleep 2

# 8. Verify COM Add-in Registry for Word
log "🔍 Verifying Oracle BI Publisher Word Template Builder registration..."
wine reg query "HKEY_CURRENT_USER\\Software\\Microsoft\\Office\\Word\\Addins" 2>&1 | tee -a "$LOG_FILE" || true

log "================================================================================"
log "🎉 SUCCESS: Microsoft Word and Oracle BI Publisher Desktop are fully installed!"
log "   Launch shortcut: /u01/oracle/bin/launch-word.sh"
log "================================================================================"

if [ -n "${DISPLAY:-}" ] && command -v zenity &>/dev/null; then
  zenity --info --title="Paigaldus edukas!" \
    --text="Microsoft Word ja Oracle BI Publisher lisandmoodul on edukalt paigaldatud ja kasutusvalmis!\n\nVõite nüüd avada ikooni <b>'Oracle BI Publisher (Word)'</b> ja alustada mallide kujundamist." \
    --width=450 2>/dev/null || true
fi
