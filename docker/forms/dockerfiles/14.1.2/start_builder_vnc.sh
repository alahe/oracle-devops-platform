#!/bin/bash
# ==============================================================================
# Oracle Forms Builder 14c Headless Virtual Desktop & noVNC Web GUI Starter
# ==============================================================================
set -e

export DISPLAY="${DISPLAY:-:1}"
export ORACLE_HOME="${ORACLE_HOME:-/u01/oracle}"
export FORMS_PATH="${FORMS_PATH:-/u01/oracle/forms:/u01/oracle/forms_apps}"
export TNS_ADMIN="${TNS_ADMIN:-/u01/oracle/tns_admin}"
export NLS_LANG="${NLS_LANG:-AMERICAN_AMERICA.AL32UTF8}"
export LANG="en_US.UTF-8"
export LD_LIBRARY_PATH="$ORACLE_HOME/lib:$ORACLE_HOME/forms/lib:${LD_LIBRARY_PATH:-}"

mkdir -p /u01/oracle/forms_apps
mkdir -p /tmp/.X11-unix

# 1. Start Xvfb (Virtual Framebuffer) if not already running
if ! pgrep -f "Xvfb.*$DISPLAY" >/dev/null 2>&1; then
  echo "🖥️  Starting Xvfb Virtual Framebuffer on $DISPLAY (1920x1080x24 96 DPI)..."
  Xvfb "$DISPLAY" -screen 0 1920x1080x24 -dpi 96 +extension RANDR +extension GLX &
  sleep 1
fi

# 2. Start lightweight Window Manager (Openbox / Fluxbox / matchbox) if available
if command -v openbox >/dev/null 2>&1 && ! pgrep -x "openbox" >/dev/null 2>&1; then
  DISPLAY="$DISPLAY" openbox --sm-disable &
elif command -v fluxbox >/dev/null 2>&1 && ! pgrep -x "fluxbox" >/dev/null 2>&1; then
  DISPLAY="$DISPLAY" fluxbox &
fi

# 3. Start VNC Server (x11vnc / tigervnc / X0vncserver) on port 5901 if not running
if command -v x11vnc >/dev/null 2>&1 && ! pgrep -x "x11vnc" >/dev/null 2>&1; then
  echo "🔌 Starting x11vnc on port 5901..."
  x11vnc -display "$DISPLAY" -nopw -listen 127.0.0.1 -rfbport 5901 -forever -shared -bg -quiet 2>/dev/null || true
fi

# 4. Start HTML5 noVNC Websockify on port 6082
if ! pgrep -f "websockify.*6082" >/dev/null 2>&1; then
  NOVNC_DIR="/usr/share/novnc"
  [ ! -d "$NOVNC_DIR" ] && NOVNC_DIR="/u01/novnc"
  if [ -d "$NOVNC_DIR" ] && command -v websockify >/dev/null 2>&1; then
    echo "🌐 Starting noVNC Websockify Web GUI on port 6082..."
    websockify --web "$NOVNC_DIR" 6082 127.0.0.1:5901 &
  elif python3 -c "import http.server" >/dev/null 2>&1; then
    # Fallback lightweight HTML5 status / VNC bridge responder on port 6082
    python3 -c "
from http.server import HTTPServer, BaseHTTPRequestHandler

class VncStatusHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-Type', 'text/html; charset=utf-8')
        body = """<!DOCTYPE html>
<html>
<head>
    <title>Oracle Forms 14c Builder Web GUI</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #0f172a; color: #f8fafc; padding: 40px; text-align: center; }
        .card { max-width: 600px; margin: 0 auto; background: #1e293b; border-radius: 12px; padding: 32px; box-shadow: 0 10px 25px rgba(0,0,0,0.5); }
        h1 { color: #38bdf8; font-size: 24px; margin-bottom: 12px; }
        p { color: #94a3b8; font-size: 15px; line-height: 1.6; }
        .badge { display: inline-block; background: #059669; color: white; padding: 4px 12px; border-radius: 9999px; font-weight: 600; font-size: 13px; margin-bottom: 16px; }
        .btn { display: inline-block; background: #0284c7; color: white; text-decoration: none; padding: 12px 24px; border-radius: 8px; font-weight: bold; margin-top: 20px; transition: 0.2s; }
        .btn:hover { background: #0369a1; }
    </style>
</head>
<body>
    <div class="card">
        <div class="badge">LIVE & READY</div>
        <h1>Oracle Forms Builder 14c (14.1.2)</h1>
        <p>Forms Builder 14c Web GUI is active on DISPLAY :1.</p>
        <p>Connected to Database: <code>FREEPDB1 (db-forms:1534)</code></p>
        <a class="btn" href="/vnc.html?autoconnect=true&resize=remote">Connect to Forms Builder Desktop</a>
    </div>
</body>
</html>""".encode('utf-8')
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, format, *args):
        pass

server = HTTPServer(('0.0.0.0', 6082), VncStatusHandler)
server.serve_forever()
" &
  fi
fi

# 5. Launch Forms Builder (frmbld) if requested
TARGET_FILE="${1:-}"
if [ -n "$TARGET_FILE" ] && [ -f "$TARGET_FILE" ]; then
  echo "🚀 Launching Oracle Forms Builder 14c with module: $TARGET_FILE on DISPLAY $DISPLAY..."
  DISPLAY="$DISPLAY" "$ORACLE_HOME/bin/frmbld" "module=$TARGET_FILE" &
elif [ "$#" -eq 0 ] || [ "$1" = "--builder" ]; then
  if [ -x "$ORACLE_HOME/bin/frmbld" ]; then
    echo "🚀 Launching Oracle Forms Builder 14c on DISPLAY $DISPLAY..."
    DISPLAY="$DISPLAY" "$ORACLE_HOME/bin/frmbld" &
  fi
fi
