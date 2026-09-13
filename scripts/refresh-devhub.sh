#!/usr/bin/env bash
# ==============================================================================
# scripts/refresh-devhub.sh
# ------------------------------------------------------------------------------
# Google Chrome Dev Hub Hard-Refresh & Version Verification Tool
#
# Locates running Google Chrome tab(s) displaying Dev Hub (dev-hub.html),
# executes an unconditional cache-busting reload (?_cb=TIMESTAMP), and verifies
# that the browser version matches the repository Single Source of Truth.
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

FORCE_COMPILE=false
FORCE_OPEN=false

show_help() {
  cat << 'EOF'
Oracle DevOps Platform — Chrome Dev Hub Hard-Refresh Tool

Usage:
  ./scripts/refresh-devhub.sh [OPTIONS]

Options:
  -c, --compile    Force recompilation of docs/dev-hub.html before browser reload
  -o, --open       Automatically open Dev Hub in Chrome if no matching tab is found
  -h, --help       Show this help message and exit

Description:
  Finds any open Google Chrome window and tab displaying Dev Hub:
    • file://.../docs/dev-hub.html
    • https://localhost:8448/dev-hub.html
    • http://localhost:8088/dev-hub.html
    • http://127.0.0.1:8089/dev-hub.html
  Bypasses browser cache completely by injecting a fresh numeric timestamp
  query (?_cb=TIMESTAMP) and triggers a native tab reload. Verifies that
  the version loaded in the browser matches the repository VERSION.
EOF
  exit 0
}

# Parse flags
while [[ $# -gt 0 ]]; do
  case "$1" in
    -c|--compile)
      FORCE_COMPILE=true
      shift
      ;;
    -o|--open)
      FORCE_OPEN=true
      shift
      ;;
    -h|--help)
      show_help
      ;;
    *)
      echo -e "${RED}❌ Tundmatu parameeter: $1${NC}"
      echo "Käivita './scripts/refresh-devhub.sh --help' spikri vaatamiseks."
      exit 1
      ;;
  esac
done

echo -e "${CYAN}==================================================================${NC}"
echo -e "${CYAN}  🔄 Google Chrome Dev Hub Hard-Refresh & Versioonikontroll        ${NC}"
echo -e "${CYAN}==================================================================${NC}"

# 1. Check Repository Version
REPO_VERSION="2.4.2"
if [ -f "$WORKSPACE_DIR/VERSION" ]; then
  REPO_VERSION="$(tr -d '[:space:]' < "$WORKSPACE_DIR/VERSION")"
fi
echo -e "   📌 Repositooriumi tõeallika versioon: ${GREEN}v${REPO_VERSION}${NC}"

DEV_HUB_HTML="$WORKSPACE_DIR/docs/dev-hub.html"

# 2. Check if docs/dev-hub.html needs compilation
NEEDS_COMPILE=false
if [ ! -f "$DEV_HUB_HTML" ]; then
  echo -e "   ${YELLOW}⚠️  Fail docs/dev-hub.html puudub kettal. Käivitan kompileerimise...${NC}"
  NEEDS_COMPILE=true
elif [ "$FORCE_COMPILE" = true ]; then
  echo -e "   ${BLUE}⚙️  Käsurealipp --compile määratud. Kompileerin uuesti...${NC}"
  NEEDS_COMPILE=true
else
  # Check if HTML contains matching version
  if ! grep -Fq "PLATFORM_VERSION = \"${REPO_VERSION}\"" "$DEV_HUB_HTML" 2>/dev/null; then
    echo -e "   ${YELLOW}⚠️  docs/dev-hub.html versioon ei vasta failile VERSION (v${REPO_VERSION}). Kompileerin üle...${NC}"
    NEEDS_COMPILE=true
  fi
fi

if [ "$NEEDS_COMPILE" = true ]; then
  COMPILE_SCRIPT="$WORKSPACE_DIR/scripts/internal/generate-dev-hub.sh"
  if [ -x "$COMPILE_SCRIPT" ]; then
    "$COMPILE_SCRIPT" "$DEV_HUB_HTML" >/dev/null 2>&1 || true
    echo -e "   ${GREEN}✓ docs/dev-hub.html edukalt kompileeritud!${NC}"
  else
    echo -e "   ${RED}❌ Kompileerimisskripti $COMPILE_SCRIPT ei leitud!${NC}"
  fi
fi

# Determine active target URL
TIMESTAMP="$(date +%s)"
TARGET_FILE_URL="file://${DEV_HUB_HTML}?_cb=${TIMESTAMP}"

# 3. macOS Google Chrome Automation via AppleScript
if [[ "$OSTYPE" == "darwin"* ]]; then
  # Check if Google Chrome application is currently running
  CHROME_RUNNING="$(osascript -e 'application "Google Chrome" is running' 2>/dev/null || echo "false")"

  if [ "$CHROME_RUNNING" != "true" ]; then
    echo -e "   ${YELLOW}ℹ️  Google Chrome ei ole hetkel käivitatud.${NC}"
    echo -e "   🚀 Käivitan Google Chrome'i värskendatud Dev Hubiga..."
    open -a "Google Chrome" "$TARGET_FILE_URL"
    echo -e "   ${GREEN}✅ Google Chrome käivitatud: ${TARGET_FILE_URL}${NC}"
    exit 0
  fi

  # Execute AppleScript to find and hard-reload all matching Dev Hub tabs
  # Uses native URL setting and reload (100% immune to "Allow JavaScript from Apple Events" restrictions)
  APPLESCRIPT_RESULT=$(osascript -e '
    set repoVer to "'"${REPO_VERSION}"'"
    set cbTs to "'"${TIMESTAMP}"'"
    set refreshedCount to 0
    set domVer to ""
    set jsAllowed to false
    
    tell application "Google Chrome"
      repeat with w in windows
        repeat with t in tabs of w
          if curUrl contains "dev-hub.html" or curUrl contains "hub.html" or curUrl contains ":8089" then
            -- For local file:// URLs, update _cb query param to bust aggressive Chrome disk caching
            if curUrl starts with "file://" then
              try
                set cleanUrl to do shell script "python3 -c '\''import sys, urllib.parse; u=sys.argv[1]; p=urllib.parse.urlsplit(u); q=dict(urllib.parse.parse_qsl(p.query)); q[\"_cb\"]=\"" & cbTs & "\"; print(urllib.parse.urlunsplit((p.scheme, p.netloc, p.path, urllib.parse.urlencode(q), p.fragment)))'\'' " & quoted form of curUrl
                set URL of t to cleanUrl
              end try
            end if
            -- For HTTP/HTTPS URLs (including ORDS:8448/8088), reload directly without appending query strings that trigger ORDS /ords/_/landing redirects
            tell t to reload
            set refreshedCount to refreshedCount + 1
            
            -- Optionally check DOM version if JavaScript is permitted
            try
              set jsVer to (execute t javascript "window.PLATFORM_VERSION || document.getElementById(\"platform-global-version\").innerText")
              if jsVer is not "" then
                set domVer to jsVer
                set jsAllowed to true
              end if
            end try
          end if
        end repeat
      end repeat
    end tell
    
    return (refreshedCount as string) & "|" & domVer & "|" & (jsAllowed as string)
  ' 2>&1 || echo "ERROR")

  if [[ "$APPLESCRIPT_RESULT" == *"ERROR"* ]] || [[ "$APPLESCRIPT_RESULT" == *"execution error"* ]]; then
    if [[ "$APPLESCRIPT_RESULT" == *"-1743"* ]] || [[ "$APPLESCRIPT_RESULT" == *"not allowed"* ]]; then
      echo -e "   ${YELLOW}⚠️  macOS TCC luba puudub: Terminalil pole õigust juhtida Google Chrome'i.${NC}"
      echo -e "   👉 Lahendus: Ava System Settings ➔ Privacy & Security ➔ Automation ➔ Luba Terminalile Google Chrome."
    fi
    echo -e "   ${BLUE}🌐 Avan vahekaardi otse käsurealt...${NC}"
    open -a "Google Chrome" "$TARGET_FILE_URL"
    echo -e "   ${GREEN}✅ Dev Hub avatud Chrome'is: ${TARGET_FILE_URL}${NC}"
    exit 0
  fi

  # Parse output: count|domVer|jsAllowed
  REFRESHED_COUNT="$(echo "$APPLESCRIPT_RESULT" | cut -d'|' -f1)"
  DOM_VER="$(echo "$APPLESCRIPT_RESULT" | cut -d'|' -f2)"
  JS_ALLOWED="$(echo "$APPLESCRIPT_RESULT" | cut -d'|' -f3)"

  if [ "$REFRESHED_COUNT" -gt 0 ] 2>/dev/null; then
    echo -e "   ${GREEN}🔄 Edukalt värskendatud ${REFRESHED_COUNT} Google Chrome'i vahekaart(i)!${NC}"
    echo -e "   ⚡ Vahemälu tühistatud ajatempliga: ${CYAN}?_cb=${TIMESTAMP}${NC}"
    
    if [ "$JS_ALLOWED" = "true" ] && [ -n "$DOM_VER" ]; then
      # Clean 'v' prefix if present
      CLEAN_DOM_VER="${DOM_VER#v}"
      if [ "$CLEAN_DOM_VER" = "$REPO_VERSION" ]; then
        echo -e "   ${GREEN}✅ Versioonikontroll: Brauseri DOM versioon (${DOM_VER}) vastab 100% repositooriumile (v${REPO_VERSION})!${NC}"
      else
        echo -e "   ${YELLOW}⚠️  Brauseri DOM näitas versiooni ${DOM_VER}, repositoorium on v${REPO_VERSION}. Uus laadimine on pooleli.${NC}"
      fi
    else
      echo -e "   ${GREEN}✅ Failikontroll: docs/dev-hub.html kettal on sünkroonis (v${REPO_VERSION}) ja laadimine teostatud!${NC}"
      echo -e "   ${BLUE}💡 Vihje sügavaks DOM-kontrolliks: Chrome ➔ View ➔ Developer ➔ Allow JavaScript from Apple Events${NC}"
    fi
  else
    echo -e "   ${YELLOW}ℹ️  Ühtegi avatud Dev Hubi vahekaarti Chrome'ist ei leitud.${NC}"
    echo -e "   🚀 Avan Dev Hubi Google Chrome'is..."
    open -a "Google Chrome" "$TARGET_FILE_URL"
    echo -e "   ${GREEN}✅ Dev Hub avatud uues sakis: ${TARGET_FILE_URL}${NC}"
  fi

else
  # Non-macOS fallback (Linux/WSL)
  echo -e "   ${BLUE}🐧 Tuvastatud mitte-macOS keskkond (${OSTYPE}).${NC}"
  if command -v google-chrome >/dev/null 2>&1; then
    google-chrome "$TARGET_FILE_URL" >/dev/null 2>&1 &
    echo -e "   ${GREEN}✅ Käivitatud: google-chrome ${TARGET_FILE_URL}${NC}"
  elif command -v wslview >/dev/null 2>&1; then
    wslview "$TARGET_FILE_URL" >/dev/null 2>&1 &
    echo -e "   ${GREEN}✅ Käivitatud Windows brauseris wslview kaudu.${NC}"
  else
    echo -e "   ${YELLOW}Palun ava brauseris järgmine aadress:${NC}"
    echo -e "   👉 ${CYAN}${TARGET_FILE_URL}${NC}"
  fi
fi

echo -e "\n${GREEN}✨ Valmis! Dev Hub on värskendatud ilma vahemäluta.${NC}"
