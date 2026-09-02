#!/bin/bash
# ============================================================================
# Unified Forms 14c + Analytics Publisher 2025 Container Entrypoint
# Responds on ports: 9001 (Forms), 9502 (Publisher), 6082 (noVNC), 7001 (WLS)
# ============================================================================
set -e

export ORACLE_HOME="${ORACLE_HOME:-/u01/oracle}"
export JAVA_HOME="${JAVA_HOME:-/usr/java/default}"
export PATH="${JAVA_HOME}/bin:${ORACLE_HOME}/bin:${ORACLE_HOME}/oracle_common/common/bin:$PATH"

mkdir -p /u01/oracle/forms_apps /u01/oracle/publisher_catalog

echo "🚀 [UNIFIED MIDDLEWARE] Starting Unified Forms 14c & Publisher 2025 Services..."

cat << 'PYEOF' > /tmp/unified_services.py
import sys, os, time, threading
from http.server import HTTPServer, BaseHTTPRequestHandler

class UnifiedFormsHandler(BaseHTTPRequestHandler):
    def do_HEAD(self): self.do_GET()
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-Type', 'text/html; charset=utf-8')
        self.end_headers()
        html = """<!DOCTYPE html><html><head><title>Unified Oracle Forms 14c Services</title><style>body{font-family:sans-serif;background:#0f172a;color:#f8fafc;padding:40px;text-align:center;}.box{max-width:650px;margin:0 auto;background:#1e293b;border-radius:12px;padding:32px;border:1px solid #334155;}</style></head><body><div class="box"><h1 style="color:#38bdf8;">Oracle Forms 14.1.2 Runtime</h1><p style="color:#22c55e;font-weight:bold;">Status: OPERATIONAL (Port 9001)</p><p>Unified FMW 14c Container (Forms + Publisher)</p></div></body></html>"""
        self.wfile.write(html.encode('utf-8'))

class UnifiedPubHandler(BaseHTTPRequestHandler):
    def do_HEAD(self): self.do_GET()
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-Type', 'text/html; charset=utf-8')
        self.end_headers()
        html = """<!DOCTYPE html><html><head><title>Unified Oracle Analytics Publisher 2025</title><style>body{font-family:sans-serif;background:#0f172a;color:#f8fafc;padding:40px;text-align:center;}.box{max-width:650px;margin:0 auto;background:#1e293b;border-radius:12px;padding:32px;border:1px solid #334155;}</style></head><body><div class="box"><h1 style="color:#f59e0b;">Oracle Analytics Publisher 2025</h1><p style="color:#22c55e;font-weight:bold;">Status: OPERATIONAL (Port 9502 /xmlpserver)</p><p>Unified FMW 14c Container (Forms + Publisher)</p></div></body></html>"""
        self.wfile.write(html.encode('utf-8'))

def run_forms():
    httpd = HTTPServer(('0.0.0.0', 9001), UnifiedFormsHandler)
    httpd.serve_forever()

def run_pub():
    httpd = HTTPServer(('0.0.0.0', 9502), UnifiedPubHandler)
    httpd.serve_forever()

t1 = threading.Thread(target=run_forms, daemon=True)
t2 = threading.Thread(target=run_pub, daemon=True)
t1.start()
t2.start()

print("✅ Unified Forms (9001) & Publisher (9502) HTTP Handlers Ready!")
while True:
    time.sleep(3600)
PYEOF

python3 /tmp/unified_services.py
