#!/usr/bin/env bash
# ==============================================================================
# Entrypoint for Oracle Analytics Publisher Desktop Designer Container
# Boots Xvfb, XFCE desktop, VNC server, and noVNC web listener on port 6080
# Supports 6 Nordic-Baltic Languages: EN, ET, FI, SV, LV, LT via APP_LANG
# ==============================================================================
set -euo pipefail

APP_LANG="${APP_LANG:-et}"
APP_LANG="$(echo "$APP_LANG" | tr '[:upper:]' '[:lower:]' | cut -c1-2)"

echo "================================================================================"
echo "🚀 Starting Oracle Analytics Publisher Designer Workstation..."
echo "   User:       $(whoami)"
echo "   Display:    ${DISPLAY:-:1}"
echo "   Language:   $APP_LANG"
echo "   noVNC Port: 6080 (Host mapped to 6083)"
echo "   WINEPREFIX: ${WINEPREFIX:-/u01/oracle/.wine}"
echo "================================================================================"

mkdir -p /u01/oracle/Desktop /u01/oracle/.config/xfce4 /u01/templates /u01/binaries /u01/logs

# Resolve localized folder and shortcut names
case "$APP_LANG" in
  en)
    DIR_STUDIO_NAME="📁 1. LibreOffice Studio (Recommended)"
    DIR_WORD_NAME="📁 2. MS Word & Wine (Optional)"
    TITLE_WRITER="LibreOffice Writer (RTF Designer)"
    DESC_WRITER="Open and design RTF templates visually"
    TITLE_STUDIO="🚀 Oracle Publisher Template Studio"
    DESC_STUDIO="Integrated 3-window studio: LibreOffice + Live PDF + XML Inspector"
    TITLE_INSPECTOR="🏷️ XML Field Inspector"
    DESC_INSPECTOR="Browse XML fields and insert Oracle XDO tags into LibreOffice"
    TITLE_RENDER="⚡ Fast-Render Invoice PDF"
    DESC_RENDER="Compile arve_test_standard.rtf sample into PDF"
    TITLE_WORD="Microsoft Word (Oracle BI Publisher)"
    DESC_WORD="Design Pixel-Perfect RTF templates in Microsoft Word with Publisher Add-in"
    TITLE_INSTALL="⚡ Install Word & Publisher Designer"
    DESC_INSTALL="Run Microsoft Word and Oracle BI Publisher Add-in setup wizard"
    TITLE_ARRANGE="📐 Arrange Studio Windows (3-Pane)"
    DESC_ARRANGE="Align LibreOffice, Evince PDF and XML Inspector side-by-side"
    ;;
  fi)
    DIR_STUDIO_NAME="📁 1. LibreOffice Studio (Suositeltu)"
    DIR_WORD_NAME="📁 2. MS Word & Wine (Valinnainen)"
    TITLE_WRITER="LibreOffice Writer (RTF-suunnittelija)"
    DESC_WRITER="Avaa ja muotoile RTF-mallipohjia visuaalisesti"
    TITLE_STUDIO="🚀 Oracle Publisher Mallipohjastudio"
    DESC_STUDIO="Integroitu 3-ikkunainen studio: LibreOffice + Live PDF + XML-tarkastaja"
    TITLE_INSPECTOR="🏷️ XML-kenttien Tarkastaja"
    DESC_INSPECTOR="Selaa XML-kenttiä ja lisää Oracle XDO -tunnisteita LibreOfficeen"
    TITLE_RENDER="⚡ Pika-Renderöi Lasku PDF"
    DESC_RENDER="Käännä arve_test_standard.rtf näyte-PDF-tiedostoksi"
    TITLE_WORD="Microsoft Word (Oracle BI Publisher)"
    DESC_WORD="Suunnittele Pixel-Perfect RTF -malleja Microsoft Wordissa Publisher-lisäosalla"
    TITLE_INSTALL="⚡ Asenna Word & Publisher Designer"
    DESC_INSTALL="Käynnistä Microsoft Wordin ja Oracle BI Publisher -lisäosan asennusvelho"
    TITLE_ARRANGE="📐 Järjestä Studion Ikkunat"
    DESC_ARRANGE="Kohdista LibreOffice, Evince PDF ja XML-tarkastaja vierekkäin"
    ;;
  sv)
    DIR_STUDIO_NAME="📁 1. LibreOffice Studio (Rekommenderas)"
    DIR_WORD_NAME="📁 2. MS Word & Wine (Valfritt)"
    TITLE_WRITER="LibreOffice Writer (RTF-designer)"
    DESC_WRITER="Öppna och designa RTF-mallar visuellt"
    TITLE_STUDIO="🚀 Oracle Publisher Mallstudio"
    DESC_STUDIO="Integrerad 3-fönsters studio: LibreOffice + Live PDF + XML-granskare"
    TITLE_INSPECTOR="🏷️ XML Fältgranskare"
    DESC_INSPECTOR="Bläddra bland XML-fält och infoga Oracle XDO-taggar i LibreOffice"
    TITLE_RENDER="⚡ Snabb-rendera Faktura PDF"
    DESC_RENDER="Kompilera arve_test_standard.rtf till exempel-PDF"
    TITLE_WORD="Microsoft Word (Oracle BI Publisher)"
    DESC_WORD="Designa Pixel-Perfect RTF-mallar i Microsoft Word med Publisher-tillägg"
    TITLE_INSTALL="⚡ Installera Word & Publisher Designer"
    DESC_INSTALL="Kör installationsguiden för Microsoft Word och Oracle BI Publisher-tillägg"
    TITLE_ARRANGE="📐 Ordna Studiofönster"
    DESC_ARRANGE="Placera LibreOffice, Evince PDF och XML-granskare sida vid sida"
    ;;
  lv)
    DIR_STUDIO_NAME="📁 1. LibreOffice Studio (Ieteicams)"
    DIR_WORD_NAME="📁 2. MS Word & Wine (Pēc izvēles)"
    TITLE_WRITER="LibreOffice Writer (RTF noformētājs)"
    DESC_WRITER="Atvērt un noformēt RTF veidnes vizuāli"
    TITLE_STUDIO="🚀 Oracle Publisher Veidņu Studija"
    DESC_STUDIO="Integrēta 3-logu studija: LibreOffice + Live PDF + XML inspektors"
    TITLE_INSPECTOR="🏷️ XML Lauku Inspektors"
    DESC_INSPECTOR="Pārlūkot XML laukus un ievietot Oracle XDO tagus LibreOffice"
    TITLE_RENDER="⚡ Ātrā Rēķina PDF Renderēšana"
    DESC_RENDER="Kompilēt arve_test_standard.rtf par parauga PDF failu"
    TITLE_WORD="Microsoft Word (Oracle BI Publisher)"
    DESC_WORD="Noformēt Pixel-Perfect RTF veidnes programmā Microsoft Word ar Publisher spraudni"
    TITLE_INSTALL="⚡ Instalēt Word un Publisher Designer"
    DESC_INSTALL="Palaist Microsoft Word un Oracle BI Publisher spraudņa instalēšanas vedni"
    TITLE_ARRANGE="📐 Sakārtot Studijas Logus"
    DESC_ARRANGE="Novietot LibreOffice, Evince PDF un XML inspektoru blakus"
    ;;
  lt)
    DIR_STUDIO_NAME="📁 1. LibreOffice Studio (Rekomenduojama)"
    DIR_WORD_NAME="📁 2. MS Word & Wine (Neprivaloma)"
    TITLE_WRITER="LibreOffice Writer (RTF rengyklė)"
    DESC_WRITER="Atidaryti ir vizualiai kurti RTF šablonus"
    TITLE_STUDIO="🚀 Oracle Publisher Šablonų Studija"
    DESC_STUDIO="Integruota 3 langų studija: LibreOffice + Live PDF + XML inspektorius"
    TITLE_INSPECTOR="🏷️ XML Laukų Inspektorius"
    DESC_INSPECTOR="Naršyti XML laukus ir įterpti Oracle XDO žymas į LibreOffice"
    TITLE_RENDER="⚡ Greitas Sąskaitos PDF Generavimas"
    DESC_RENDER="Kompiliuoti arve_test_standard.rtf į pavyzdinį PDF failą"
    TITLE_WORD="Microsoft Word (Oracle BI Publisher)"
    DESC_WORD="Kurti Pixel-Perfect RTF šablonus programoje Microsoft Word su Publisher priedu"
    TITLE_INSTALL="⚡ Įdiegti Word ir Publisher Designer"
    DESC_INSTALL="Paleisti Microsoft Word ir Oracle BI Publisher priedo diegimo vedlį"
    TITLE_ARRANGE="📐 Išdėstyti Studijos Langus"
    DESC_ARRANGE="Lygiuoti LibreOffice, Evince PDF ir XML inspektorių greta"
    ;;
  et|*)
    APP_LANG="et"
    DIR_STUDIO_NAME="📁 1. LibreOffice Studio (Soovitatav)"
    DIR_WORD_NAME="📁 2. MS Word & Wine (Valikuline)"
    TITLE_WRITER="LibreOffice Writer (RTF Kujundaja)"
    DESC_WRITER="Ava ja kujunda RTF malle visuaalselt"
    TITLE_STUDIO="🚀 Oracle Publisher Template Studio"
    DESC_STUDIO="Integreeritud 3-aknaga stuudio: LibreOffice + Live PDF + XML Inspektor"
    TITLE_INSPECTOR="🏷️ XML Väljade Inspektor"
    DESC_INSPECTOR="Sirvi XML välju ja lisa Oracle XDO tage LibreOffice'isse"
    TITLE_RENDER="⚡ Kiir-Renderda Arve PDF"
    DESC_RENDER="Kompileeri arve_test_standard.rtf näidis PDF-iks"
    TITLE_WORD="Microsoft Word (Oracle BI Publisher)"
    DESC_WORD="Kujunda Pixel-Perfect RTF malle Microsoft Wordis koos Publisher lisandmooduliga"
    TITLE_INSTALL="⚡ Paigalda Word & Publisher Designer"
    DESC_INSTALL="Käivita Microsoft Wordi ja Oracle BI Publisher lisandmooduli paigaldusviisard"
    TITLE_ARRANGE="📐 Korrasta Stuudio Aknad"
    DESC_ARRANGE="Paiguta LibreOffice, Evince PDF ja XML Inspektor kõrvuti"
    ;;
esac

DIR_STUDIO="/u01/oracle/Desktop/$DIR_STUDIO_NAME"
DIR_WORD="/u01/oracle/Desktop/$DIR_WORD_NAME"
mkdir -p "$DIR_STUDIO" "$DIR_WORD"

# A. Group 1: LibreOffice Studio (Recommended)
cat << EOF > "$DIR_STUDIO/LibreOffice-RTF-Editor.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=$TITLE_WRITER
Comment=$DESC_WRITER
Exec=libreoffice --norestore --writer /u01/templates/samples/arve_test_standard.rtf
Icon=libreoffice-writer
Path=/u01/templates
Terminal=false
StartupNotify=true
Categories=Office;
EOF

cat << EOF > "$DIR_STUDIO/Oracle-Publisher-Studio.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=$TITLE_STUDIO
Comment=$DESC_STUDIO
Exec=/u01/oracle/bin/launch-studio.sh
Icon=preferences-desktop-theme
Path=/u01/templates
Terminal=false
StartupNotify=true
Categories=Development;Office;
EOF

cat << EOF > "$DIR_STUDIO/Oracle-XML-Inspector.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=$TITLE_INSPECTOR
Comment=$DESC_INSPECTOR
Exec=/u01/oracle/bin/xml-field-inspector.py --lang $APP_LANG
Icon=x-office-document
Path=/u01/templates
Terminal=false
StartupNotify=true
Categories=Development;
EOF

cat << EOF > "$DIR_STUDIO/Test-Render-Invoice.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=$TITLE_RENDER
Comment=$DESC_RENDER
Exec=/bin/bash -c '/u01/oracle/bin/render-template.sh /u01/templates/samples/arve_test_standard.rtf /u01/templates/samples/arve_test_andmed.xml /u01/templates/samples/valmis_arve.pdf --locale $APP_LANG && cp -f /u01/templates/samples/valmis_arve.pdf /u01/templates/samples/valmis_arve_$APP_LANG.pdf'
Icon=application-pdf
Terminal=true
Categories=Development;
EOF

# B. Group 2: MS Word & Wine (Optional)
cat << EOF > "$DIR_WORD/Oracle-Template-Builder.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=$TITLE_WORD
Comment=$DESC_WORD
Exec=/u01/oracle/bin/launch-word.sh
Icon=x-office-document
Path=/u01/templates
Terminal=false
StartupNotify=true
Categories=Office;Development;
EOF

cat << EOF > "$DIR_WORD/Install-Word-BIP.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=$TITLE_INSTALL
Comment=$DESC_INSTALL
Exec=/u01/oracle/bin/install-word-bip.sh
Icon=system-software-install
Path=/u01/binaries
Terminal=true
StartupNotify=true
Categories=Development;Settings;
EOF

cat << EOF > "$DIR_STUDIO/Arrange-Studio-Windows.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=$TITLE_ARRANGE
Comment=$DESC_ARRANGE
Exec=/u01/oracle/bin/arrange-studio-windows.sh
Icon=view-split-left-right
Path=/u01/templates
Terminal=false
StartupNotify=true
Categories=Development;Office;Utility;
EOF

# C. Quick 1-click Studio Launchers directly on Desktop Root
cp "$DIR_STUDIO/Oracle-Publisher-Studio.desktop" /u01/oracle/Desktop/
cp "$DIR_STUDIO/Arrange-Studio-Windows.desktop" /u01/oracle/Desktop/

chmod +x /u01/oracle/Desktop/*.desktop "$DIR_STUDIO"/*.desktop "$DIR_WORD"/*.desktop 2>/dev/null || true

# 2. Check and make scripts executable
chmod +x /u01/oracle/bin/*.sh /u01/oracle/bin/*.py /u01/entrypoint.sh 2>/dev/null || true

# 2b. Initialize LibreOffice Oracle Publisher Profile with chosen language
if [ -f /u01/oracle/bin/setup-libreoffice-profile.sh ]; then
  /u01/oracle/bin/setup-libreoffice-profile.sh "$APP_LANG" || true
fi

# 2c. Ensure clean XFCE icon theme configuration (elementary-xfce-dark)
mkdir -p /u01/oracle/.config/xfce4/xfconf/xfce-perchannel-xml
if [ ! -f /u01/oracle/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
  cat << 'EOF' > /u01/oracle/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xsettings" version="1.0">
  <property name="Net" type="empty">
    <property name="ThemeName" type="string" value="Greybird"/>
    <property name="IconThemeName" type="string" value="elementary-xfce-dark"/>
  </property>
</channel>
EOF
fi

# 2d. Clean up XFCE Applications Menu (Remove dead Web Browser, Mail Reader, and Internet menu)
if [ -f /u01/oracle/bin/xfce-applications.menu ]; then
  mkdir -p /etc/xdg/menus /u01/oracle/.config/menus
  cp /u01/oracle/bin/xfce-applications.menu /etc/xdg/menus/xfce-applications.menu 2>/dev/null || true
  cp /u01/oracle/bin/xfce-applications.menu /u01/oracle/.config/menus/xfce-applications.menu 2>/dev/null || true
fi

# Hide non-working desktop entries
for dead_app in xfce4-web-browser.desktop xfce4-mail-reader.desktop x11vnc.desktop; do
  if [ -f "/usr/share/applications/$dead_app" ]; then
    grep -q "NoDisplay=true" "/usr/share/applications/$dead_app" 2>/dev/null || echo "NoDisplay=true" >> "/usr/share/applications/$dead_app" 2>/dev/null || true
  fi
done

# Ensure system-wide desktop entries exist for publisher tools
cat << 'EOF' > /usr/share/applications/oracle-publisher-studio.desktop 2>/dev/null || true
[Desktop Entry]
Version=1.0
Type=Application
Name=🚀 Oracle Publisher Template Studio
Comment=Integrated Studio: LibreOffice Writer + Live PDF + XML Inspector
Exec=/u01/oracle/bin/launch-studio.sh
Icon=preferences-desktop-theme
Terminal=false
StartupNotify=true
Categories=Development;Office;X-Xfce-Toplevel;
EOF

cat << 'EOF' > /usr/share/applications/oracle-xml-inspector.desktop 2>/dev/null || true
[Desktop Entry]
Version=1.0
Type=Application
Name=🏷️ XML Field Inspector
Comment=Browse XML fields and insert Oracle XDO tags
Exec=/u01/oracle/bin/xml-field-inspector.py
Icon=x-office-document
Terminal=false
StartupNotify=true
Categories=Development;Office;X-Xfce-Toplevel;
EOF

cat << 'EOF' > /usr/share/applications/libreoffice-rtf-editor.desktop 2>/dev/null || true
[Desktop Entry]
Version=1.0
Type=Application
Name=📝 LibreOffice Writer (RTF Designer)
Comment=Design RTF templates visually
Exec=libreoffice --norestore --writer /u01/templates/samples/arve_test_standard.rtf
Icon=libreoffice-writer
Terminal=false
StartupNotify=true
Categories=Office;X-Xfce-Toplevel;
EOF

cat << 'EOF' > /usr/share/applications/arrange-studio-windows.desktop 2>/dev/null || true
[Desktop Entry]
Version=1.0
Type=Application
Name=📐 Korrasta Stuudio Aknad (Arrange Windows)
Comment=Align LibreOffice, Evince PDF, and XML Inspector side-by-side
Exec=/u01/oracle/bin/arrange-studio-windows.sh
Icon=view-split-left-right
Terminal=false
StartupNotify=true
Categories=Development;Office;Utility;X-Xfce-Toplevel;
EOF

# Update bottom dock launcher-19 (replace dead Web Browser with Template Studio)
if [ -d /u01/oracle/.config/xfce4/panel/launcher-19 ]; then
  find /u01/oracle/.config/xfce4/panel/launcher-19 -name "*.desktop" -exec sed -i 's|exo-open --launch WebBrowser.*|/u01/oracle/bin/launch-studio.sh|g' {} + 2>/dev/null || true
  find /u01/oracle/.config/xfce4/panel/launcher-19 -name "*.desktop" -exec sed -i 's|Name=.*|Name=🚀 Oracle Publisher Template Studio|g' {} + 2>/dev/null || true
fi

# 3. Clean any existing X lock files
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1 || true

# 4. Start Virtual Framebuffer (Xvfb)
echo "🖥️ Starting Xvfb on display ${DISPLAY:-:1} (1920x1080x24)..."
Xvfb :1 -screen 0 1920x1080x24 &
sleep 2

# 5. Start XFCE4 Window Manager & Session
echo "🎨 Starting XFCE Desktop session..."
export DISPLAY=:1
xfce4-session &
sleep 2

# 6. Start VNC Server (x11vnc)
echo "🔒 Starting VNC Server on port 5900..."
x11vnc -display :1 -nopw -listen localhost -xkb -ncache 10 -ncache_cr -forever -shared &
sleep 2

# 7. Start websockify noVNC HTTP Gateway
echo "🌐 Starting noVNC WebSocket Gateway on port 6080..."
echo "   Access URL: http://localhost:6083/vnc.html"
websockify --web /usr/share/novnc/ 6080 localhost:5900 &

# 8. Check if Office installer is waiting in /u01/binaries and Word is not installed yet
if [ ! -f "${WINEPREFIX:-/u01/oracle/.wine}/drive_c/Program Files/Microsoft Office/Office14/WINWORD.EXE" ] && \
   [ ! -f "${WINEPREFIX:-/u01/oracle/.wine}/drive_c/Program Files (x86)/Microsoft Office/Office14/WINWORD.EXE" ] && \
   [ ! -f "${WINEPREFIX:-/u01/oracle/.wine}/drive_c/Program Files/Microsoft Office/root/Office16/WINWORD.EXE" ]; then
  if find /u01/binaries -maxdepth 3 \( -iname "setup.exe" -o -iname "office*.exe" \) 2>/dev/null | grep -q .; then
    echo "📦 Detected Office installers in /u01/binaries. Starting background installation..."
    /u01/oracle/bin/install-word-bip.sh > /u01/logs/install_word_bip.log 2>&1 &
  fi
fi

# Keep container alive and stream main logs
echo "✅ Oracle Analytics Publisher Designer environment is READY!"
echo "   Browse to: http://localhost:6083/vnc.html"

touch /u01/logs/designer.log
exec tail -f /u01/logs/designer.log
