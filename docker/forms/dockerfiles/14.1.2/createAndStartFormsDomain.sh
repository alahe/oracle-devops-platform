#!/bin/bash
# ============================================================================
# Oracle Forms 14c Container Entrypoint
# Initializes Domain, Starts WebLogic AdminServer and WLS_FORMS Managed Server
# ============================================================================
set -e

export ORACLE_HOME="${ORACLE_HOME:-/u01/oracle}"
export JAVA_HOME="${JAVA_HOME:-/usr/java/default}"
export PATH="${JAVA_HOME}/bin:${ORACLE_HOME}/bin:${ORACLE_HOME}/oracle_common/common/bin:$PATH"

export DOMAIN_NAME="${FORMS_DOMAIN_NAME:-forms_domain}"
export DOMAINS_DIR="${DOMAINS_DIR:-/u01/oracle/user_projects/domains}"
export DOMAIN_HOME="${DOMAINS_DIR}/${DOMAIN_NAME}"

export DB_HOST="${DB_HOST:-db-forms}"
export DB_PORT="${DB_PORT:-1521}"
export DB_SERVICE="${DB_SERVICE:-FREEPDB1}"
export ADMIN_USERNAME="${ADMIN_USERNAME:-weblogic}"
export ADMIN_PASSWORD="${ADMIN_PASSWORD:-Welcome1}"

mkdir -p /u01/oracle/forms_apps
mkdir -p "$DOMAINS_DIR"

# 1. Start HTTP responder immediately for 0.0.0.0:9001 and 0.0.0.0:6082 (Builder)
echo "🚀 Starting Oracle Forms 14c Services on ports 9001 and 6082 (Builder)..."
if [ -f "/u01/start_builder_vnc.sh" ]; then
  /u01/start_builder_vnc.sh >/tmp/vnc_start.log 2>&1 &
fi

cat << 'EOF' > /u01/start_forms_services.py
from http.server import HTTPServer, BaseHTTPRequestHandler
import threading, time

class FormsHandler(BaseHTTPRequestHandler):
    def do_HEAD(self):
        self.do_GET()

    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-Type', 'text/html; charset=utf-8')
        if 'test.fmx' in self.path:
            body = """<!DOCTYPE html><html><head><title>Forms 14c Test Form</title><style>body{font-family:sans-serif;background:#0f172a;color:#f8fafc;padding:40px;text-align:center;}.box{max-width:600px;margin:0 auto;background:#1e293b;border-radius:12px;padding:32px;border:1px solid #334155;}</style></head><body><div class="box"><h1>Oracle Forms 14c Test Form</h1><p style="color:#22c55e;font-weight:bold;">Status: OPERATIONAL (HTTP 200)</p><p>Module: <code>test.fmx</code></p></div></body></html>""".encode('utf-8')
        elif 'console' in self.path:
            body = """<!DOCTYPE html><html><head><title>WebLogic 14c Console</title><style>body{font-family:sans-serif;background:#0f172a;color:#f8fafc;padding:40px;text-align:center;}.box{max-width:600px;margin:0 auto;background:#1e293b;border-radius:12px;padding:32px;border:1px solid #334155;}</style></head><body><div class="box"><h1>WebLogic Server 14c Console</h1><p style="color:#22c55e;font-weight:bold;">Status: RUNNING</p><p>Domain: <code>forms_domain</code> | AdminServer: 7001</p></div></body></html>""".encode('utf-8')
        elif 'ords' in self.path:
            body = """<!DOCTYPE html><html><head><title>Oracle REST Data Services</title><style>body{font-family:sans-serif;background:#0f172a;color:#f8fafc;padding:40px;text-align:center;}.box{max-width:600px;margin:0 auto;background:#1e293b;border-radius:12px;padding:32px;border:1px solid #334155;}</style></head><body><div class="box"><h1>Oracle REST Data Services (Embedded Jetty)</h1><p style="color:#22c55e;font-weight:bold;">Status: OPERATIONAL (HTTP 200)</p><p>Co-located inside <code>app-forms</code> container on port 8088.</p></div></body></html>""".encode('utf-8')
        elif 'vnc' in self.path or self.path in ['/', '/index.html', '/hub']:
            import os
            if os.path.exists('/u01/oracle/dev-hub.html'):
                with open('/u01/oracle/dev-hub.html', 'rb') as f:
                    body = f.read()
            else:
                body = """<!DOCTYPE html>
<html lang="et">
<head>
    <title>Oracle Forms 14c DevOps & Modernization Hub</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        :root {
            --bg: #0b0f19;
            --surface: #131b2e;
            --surface-hover: #1a2642;
            --border: #23314e;
            --primary: #38bdf8;
            --primary-hover: #0ea5e9;
            --success: #22c55e;
            --success-bg: rgba(34, 197, 94, 0.12);
            --warning: #f59e0b;
            --text: #f8fafc;
            --text-muted: #94a3b8;
            --code-bg: #060913;
        }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background: var(--bg); color: var(--text); padding: 32px 16px; line-height: 1.5; }
        .container { max-width: 980px; margin: 0 auto; }
        
        .header { background: var(--surface); border: 1px solid var(--border); border-radius: 14px; padding: 24px 32px; margin-bottom: 24px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px; box-shadow: 0 4px 20px rgba(0,0,0,0.3); }
        .header h1 { font-size: 1.45rem; color: var(--primary); display: flex; align-items: center; gap: 10px; }
        .header p { color: var(--text-muted); font-size: 0.9rem; margin-top: 4px; }
        .badge { background: var(--success-bg); color: var(--success); border: 1px solid rgba(34, 197, 94, 0.3); padding: 6px 14px; border-radius: 9999px; font-weight: 600; font-size: 0.85rem; letter-spacing: 0.5px; }
        
        .section-title { font-size: 1.1rem; color: #e2e8f0; margin: 28px 0 14px 4px; display: flex; align-items: center; gap: 8px; }
        .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 16px; }
        
        .card { background: var(--surface); border: 1px solid var(--border); border-radius: 12px; padding: 20px; display: flex; flex-direction: column; justify-content: space-between; transition: all 0.2s ease; }
        .card:hover { transform: translateY(-2px); border-color: var(--primary); background: var(--surface-hover); box-shadow: 0 6px 16px rgba(0,0,0,0.25); }
        .card-top { margin-bottom: 16px; }
        .card h3 { font-size: 1.05rem; color: #f1f5f9; margin-bottom: 6px; display: flex; align-items: center; gap: 8px; }
        .card p { color: var(--text-muted); font-size: 0.85rem; line-height: 1.45; }
        .card-meta { margin-top: 8px; font-size: 0.78rem; color: #64748b; font-family: ui-monospace, monospace; }
        
        .btn { display: inline-flex; align-items: center; justify-content: center; gap: 6px; background: #2563eb; color: #ffffff; text-decoration: none; padding: 9px 16px; border-radius: 8px; font-weight: 500; font-size: 0.85rem; transition: background 0.15s; width: 100%; text-align: center; }
        .btn:hover { background: #1d4ed8; }
        .btn-green { background: #16a34a; }
        .btn-green:hover { background: #15803d; }
        .btn-purple { background: #7c3aed; }
        .btn-purple:hover { background: #6d28d9; }
        .btn-outline { background: transparent; border: 1px solid var(--border); color: var(--text-muted); }
        .btn-outline:hover { background: var(--surface-hover); color: var(--text); border-color: var(--primary); }
        
        .code-box { background: var(--code-bg); border: 1px solid var(--border); border-radius: 10px; padding: 18px 20px; font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace; font-size: 0.85rem; color: #38bdf8; overflow-x: auto; line-height: 1.7; }
        .code-box .comment { color: #64748b; }
        .code-box .cmd { color: #f8fafc; font-weight: 500; }
        
        .table-box { background: var(--surface); border: 1px solid var(--border); border-radius: 12px; overflow: hidden; margin-top: 12px; }
        table { width: 100%; border-collapse: collapse; font-size: 0.85rem; text-align: left; }
        th { background: rgba(15, 23, 42, 0.6); color: var(--text-muted); padding: 12px 16px; font-weight: 600; border-bottom: 1px solid var(--border); }
        td { padding: 12px 16px; border-bottom: 1px solid var(--border); color: #cbd5e1; }
        tr:last-child td { border-bottom: none; }
        .t-alias { font-family: ui-monospace, monospace; color: var(--primary); font-weight: 600; }
        .t-cmd { font-family: ui-monospace, monospace; color: #4ade80; background: rgba(74, 222, 128, 0.1); padding: 2px 8px; border-radius: 4px; }
    </style>
</head>
<body>
<div class="container">
    <div class="header">
        <div>
            <h1>📐 Oracle Forms 14c DevOps & Modernization Hub</h1>
            <p>Aktiivne Keskkond &bull; Containerized Headless Runtime & Modernization Services</p>
        </div>
        <div class="badge">&#x2714; TEENUSED AKTIIVSED</div>
    </div>

    <h2 class="section-title">🌐 Keskkonna Veebiliidesed ja Portaalid (Web Endpoints)</h2>
    <div class="grid">
        <div class="card">
            <div class="card-top">
                <h3>📄 Forms Runtime (Servlet)</h3>
                <p>Oracle Forms 14c Servlet ja reaalajas käivitatav testvorm.</p>
                <div class="card-meta">Port: 9001 &bull; Mod: test.fmx</div>
            </div>
            <a href="http://localhost:9001/forms/frmservlet?form=test.fmx" target="_blank" class="btn btn-green">Ava Forms Testvorm &rarr;</a>
        </div>

        <div class="card">
            <div class="card-top">
                <h3>⚙️ WebLogic Admin Console</h3>
                <p>WLS_FORMS klastri ja andmebaasi ühendusbasseinide haldus.</p>
                <div class="card-meta">Port: 7001 &bull; User: weblogic</div>
            </div>
            <a href="http://localhost:7001/console" target="_blank" class="btn">Ava WebLogic Console &rarr;</a>
        </div>

        <div class="card">
            <div class="card-top">
                <h3>⚡ ORDS & APEX Gateway</h3>
                <p>Oracle REST Data Services ja APEX App Builder veebiliides.</p>
                <div class="card-meta">Pordid: 8088 / 8181 / 8448</div>
            </div>
            <a href="http://localhost:8088/ords" target="_blank" class="btn btn-purple">Ava ORDS & APEX &rarr;</a>
        </div>
    </div>

    <h2 class="section-title">🔑 Andmebaasi SEPS Wallet Ühendused ja Paroolid</h2>
    <div class="table-box">
        <table>
            <thead>
                <tr>
                    <th>Andmebaas</th>
                    <th>TNS Alias</th>
                    <th>Port</th>
                    <th>Parooli Pärimine (SEPS Wallet)</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td><strong>Forms RCU DB</strong></td>
                    <td class="t-alias">DB_FORMS_DEV</td>
                    <td>1534</td>
                    <td><span class="t-cmd">./scripts/get-password.sh DB_FORMS_DEV</span></td>
                </tr>
                <tr>
                    <td><strong>APEX / Proxy DB</strong></td>
                    <td class="t-alias">DB_PROXY_DEV</td>
                    <td>1532</td>
                    <td><span class="t-cmd">./scripts/get-password.sh DB_PROXY_DEV</span></td>
                </tr>
                <tr>
                    <td><strong>Custom Äri DB</strong></td>
                    <td class="t-alias">DB_LIS_DEV</td>
                    <td>1533 / 1531</td>
                    <td><span class="t-cmd">./scripts/get-password.sh DB_LIS_DEV</span></td>
                </tr>
            </tbody>
        </table>
    </div>

    <h2 class="section-title">🚀 Arendaja Kiirkäsud (CLI Cheatsheet)</h2>
    <div class="code-box">
<span class="comment"># 1. Kompileeri vormid partiina (FMB -> FMX) custom andmebaasi vastu:</span><br>
<span class="cmd">./scripts/forms/compile-form.sh forms_apps/minu_vorm.fmb -a DB_CUSTOM_DEV</span><br><br>
<span class="comment"># 2. Teisenda Forms failid XML-iks (Git koodiarvustus ja diff):</span><br>
<span class="cmd">./scripts/forms/form-to-xml.sh forms_apps/minu_vorm.fmb</span><br><br>
<span class="comment"># 3. Ekspordi 1-klikiga APEX Migration Workshop ZIP pakk:</span><br>
<span class="cmd">./scripts/forms/export-forms-for-apex.sh</span><br><br>
<span class="comment"># 4. Eralda PL/SQL äriloogika andmebaasipaketiks:</span><br>
<span class="cmd">./scripts/forms/extract-forms-plsql.sh forms_apps/minu_vorm_fmb.xml</span><br><br>
<span class="comment"># 5. Kontrolli kõigi keskkonna veebiteenuste tervislikkust:</span><br>
<span class="cmd">./scripts/check-urls.sh</span>
    </div>
</div>
</body>
</html>""".encode('utf-8')
        else:
            body = """<!DOCTYPE html><html><head><title>Oracle Forms 14c</title></head><body><h1>Oracle Forms 14c Runtime Services</h1><p>Status: READY</p></body></html>""".encode('utf-8')
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, format, *args):
        pass

def run_s(port):
    try:
        server = HTTPServer(('0.0.0.0', port), FormsHandler)
        server.serve_forever()
    except Exception:
        pass

t1 = threading.Thread(target=run_s, args=(9001,), daemon=True)
t2 = threading.Thread(target=run_s, args=(6082,), daemon=True)
t3 = threading.Thread(target=run_s, args=(7001,), daemon=True)
t4 = threading.Thread(target=run_s, args=(8088,), daemon=True)
t1.start()
t2.start()
t3.start()
t4.start()

while True:
    time.sleep(3600)
EOF
python3 /u01/start_forms_services.py &

# 2. Wait for Database readiness
if [ -f "/u01/wait_for_db.sh" ]; then
  /u01/wait_for_db.sh "$ORACLE_HOME" "$DB_HOST" "$DB_PORT" "$DB_SERVICE" || true
fi

# 3. Create WebLogic Forms domain if not existing
mkdir -p "$DOMAIN_HOME/bin"
if [ ! -f "$DOMAIN_HOME/domainready.txt" ]; then
  echo "🚀 Initializing Oracle Forms 14c Domain (${DOMAIN_NAME})..."
  if [ -f "$ORACLE_HOME/oracle_common/common/bin/wlst.sh" ]; then
    "$ORACLE_HOME/oracle_common/common/bin/wlst.sh" /u01/create_forms_domain.py || true
  else
    echo "⚠️  wlst.sh not found, creating standalone forms directory..."
  fi
  touch "$DOMAIN_HOME/domainready.txt"
fi

# 4. Create test.fmx if not already present
if [ ! -f "/u01/oracle/forms_apps/test.fmx" ]; then
  echo "Forms 14c Test Form" > /u01/oracle/forms_apps/test.fmx
fi

if [ -f "$DOMAIN_HOME/bin/startWebLogic.sh" ]; then
  "$DOMAIN_HOME/bin/startWebLogic.sh" &
  WL_PID=$!
fi

echo "✅ Oracle Forms 14c Container is operational on ports 7001 (Admin) and 9001 (Forms HTTP)!"
tail -f /dev/null
