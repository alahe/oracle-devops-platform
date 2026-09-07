#!/usr/bin/env bash
# ==============================================================================
# Entrypoint for Oracle Analytics Publisher Desktop Designer Container
# Boots Xvfb, XFCE desktop, VNC server, and noVNC web listener on port 6080
# ==============================================================================
set -euo pipefail

echo "================================================================================"
echo "🚀 Starting Oracle Analytics Publisher Designer Workstation..."
echo "   User:      $(whoami)"
echo "   Display:   ${DISPLAY}"
echo "   noVNC Port: 6080 (Host mapped to 6083)"
echo "================================================================================"

# 1. Prepare XFCE Desktop directory and shortcuts
mkdir -p /u01/oracle/Desktop /u01/oracle/.config/xfce4

cat << 'EOF' > /u01/oracle/Desktop/Oracle-Template-Builder.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=Oracle BI Publisher Desktop (Template Builder)
Comment=Design Pixel-Perfect RTF Reports with Oracle Publisher Add-In
Exec=/u01/oracle/bin/launch-word.sh
Icon=x-office-document
Path=/u01/templates
Terminal=false
StartupNotify=true
Categories=Office;Development;
EOF

cat << 'EOF' > /u01/oracle/Desktop/LibreOffice-RTF-Editor.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=LibreOffice Writer (RTF Template Designer)
Comment=Open and Edit RTF / DOCX Publisher Templates
Exec=libreoffice --writer
Icon=libreoffice-writer
Path=/u01/templates
Terminal=false
StartupNotify=true
Categories=Office;
EOF

cat << 'EOF' > /u01/oracle/Desktop/Test-Render-Invoice.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=⚡ Kiir-Renderda Arve PDF
Comment=Kompileeri arve_eesti_standard.rtf näidis PDF-iks
Exec=/u01/oracle/bin/render-template.sh /u01/templates/samples/arve_eesti_standard.rtf /u01/templates/samples/arve_naidisandmed.xml /u01/templates/samples/valmis_arve.pdf
Icon=application-pdf
Terminal=true
Categories=Development;
EOF

chmod +x /u01/oracle/Desktop/*.desktop || true

# 2. Create helper launcher script for Word / Wine environment
mkdir -p /u01/oracle/bin
cat << 'EOF' > /u01/oracle/bin/launch-word.sh
#!/usr/bin/env bash
echo "Launching Oracle Analytics Publisher Desktop Word environment..."
if command -v wine &>/dev/null; then
    wine "C:\\Program Files\\Microsoft Office\\root\\Office16\\WINWORD.EXE" /u01/templates/samples/arve_eesti_standard.rtf 2>/dev/null || \
    libreoffice --writer /u01/templates/samples/arve_eesti_standard.rtf
else
    libreoffice --writer /u01/templates/samples/arve_eesti_standard.rtf
fi
EOF
chmod +x /u01/oracle/bin/launch-word.sh

# 3. Clean any existing X lock files
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1 || true

# 4. Start Virtual Framebuffer (Xvfb)
echo "🖥️ Starting Xvfb on display ${DISPLAY} (1920x1080x24)..."
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

echo "================================================================================"
echo "✅ Oracle Analytics Publisher Designer Workstation is READY!"
echo "   Web Desktop: http://localhost:6083/vnc.html"
echo "   Templates:   /u01/templates"
echo "================================================================================"

# Keep foreground process alive
wait -n
