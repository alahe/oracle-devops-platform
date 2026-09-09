"""
Oracle DevOps Platform - Developer Hub Topology & Architecture
Generates dynamic Mermaid architecture diagrams and loads YAML profiles.
"""
import os
import re
import yaml

WORKSPACE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../.."))

def load_yaml_profile(pname):
    if not pname or str(pname).upper() == "NONE":
        return {}
    subdirs = ["databases", "ords", "web-ide", "publisher", "forms", "forms-publisher", ""]
    target_pfile = None
    for sd in subdirs:
        p = os.path.join(WORKSPACE_DIR, "config/profiles", sd, f"{pname}.yaml")
        if os.path.isfile(p):
            target_pfile = p
            break
    if not target_pfile:
        for root, _, files in os.walk(os.path.join(WORKSPACE_DIR, "config/profiles")):
            if f"{pname}.yaml" in files:
                target_pfile = os.path.join(root, f"{pname}.yaml")
                break
    if not target_pfile or not os.path.isfile(target_pfile):
        return {"profile": {"id": pname}, "_rel_path": ""}

    rel_p = os.path.relpath(target_pfile, WORKSPACE_DIR)
    try:
        import yaml
        with open(target_pfile, "r", encoding="utf-8") as f:
            data = yaml.safe_load(f) or {}
            data["_rel_path"] = rel_p
            return data
    except Exception:
        return {"profile": {"id": pname}, "_rel_path": rel_p}

def get_all_profiles_metadata(ws=None, include_content=True):
    ws = ws or WORKSPACE_DIR
    profiles_dir = os.path.join(ws, "config/profiles")
    results = []
    if os.path.isdir(profiles_dir):
        for root, _, files in os.walk(profiles_dir):
            for f in sorted(files):
                if f.endswith(".yaml"):
                    full_p = os.path.join(root, f)
                    rel_p = os.path.relpath(full_p, ws)
                    cat = os.path.basename(os.path.dirname(full_p))
                    port = None
                    desc = ""
                    image = ""
                    memory = ""
                    cnt = ""
                    try:
                        with open(full_p, "r", encoding="utf-8", errors="ignore") as yf:
                            cnt = yf.read()
                        m_p = re.search(r"(?:db_port|http_port|host_port|port):\s*([0-9]+)", cnt)
                        if m_p:
                            port = int(m_p.group(1))
                        m_d = re.search(r"^\s*description:\s*[\"']?([^\"'\n\r]+)", cnt, re.MULTILINE)
                        if m_d:
                            desc = m_d.group(1).strip()
                        m_i = re.search(r"^\s*(?:container_image|image):\s*[\"']?([^\"'\n\r]+)", cnt, re.MULTILINE)
                        if m_i:
                            image = m_i.group(1).strip()
                        m_m = re.search(r"^\s*memory_limit:\s*[\"']?([^\"'\n\r]+)", cnt, re.MULTILINE)
                        if m_m:
                            memory = m_m.group(1).strip()
                    except Exception:
                        pass
                    item = {
                        "name": f,
                        "category": cat,
                        "rel_path": rel_p,
                        "port": port,
                        "description": desc,
                        "image": image,
                        "memory": memory
                    }
                    if include_content:
                        item["content"] = cnt
                    results.append(item)
    results.sort(key=lambda x: (x["category"], x["name"]))
    return results

def generate_active_blueprint_mermaid(bp_num, active_dbs, env_v, lang="en"):
    L = {
        "en": {
            "client": "Developer / Web Browser",
            "db_layer": "Oracle 23ai Database Tier - SEPS Wallet Secured",
            "ords_label": "app-ords - ORDS 26.2 Gateway",
            "pub_label": "app-publisher - Analytics Publisher 2025",
            "forms_label": "app-forms - Forms 14c Services",
            "vnc_label": "app-forms - HTML5 noVNC Forms Builder",
            "ide_label": "web-ide-dev - VS Code Web IDE",
            "pool_conn": "JDBC / SEPS Connection Pool",
            "jdbc_thin": "JDBC Thin / RCU Schemas",
            "dblink": "Database Link / Secure REST",
            "seps_conn": "SEPS Wallet / SQLcl",
            "proxy_role": "APEX 26.1 Proxy, Outbound REST and SSO",
            "alise_role": "ALISE Business Data and PL/SQL Logic",
            "pub_role": "Publisher RCU Metadata and Repo",
            "forms_role": "Forms 14c RCU Metadata and Repo"
        },
        "et": {
            "client": "Arendaja / Veebibrauser",
            "db_layer": "Oracle 23ai Andmebaasikiht - SEPS Walletiga Kaitstud",
            "ords_label": "app-ords - ORDS 26.2 Lüüs",
            "pub_label": "app-publisher - Analytics Publisher 2025",
            "forms_label": "app-forms - Forms 14c Teenused",
            "vnc_label": "app-forms - HTML5 noVNC Forms Builder",
            "ide_label": "web-ide-dev - VS Code Web IDE",
            "pool_conn": "JDBC / SEPS Ühendusbassein",
            "jdbc_thin": "JDBC Thin / RCU Metaandmed",
            "dblink": "Database Link / Turvaline REST",
            "seps_conn": "SEPS Wallet / SQLcl",
            "proxy_role": "APEX 26.1 Proxy, Väljuv REST ja SSO",
            "alise_role": "ALISE Äriandmed ja PL/SQL Loogika",
            "pub_role": "Publisher RCU Metaandmed ja Hoidla",
            "forms_role": "Forms 14c RCU Metaandmed ja Hoidla"
        },
        "fi": {
            "client": "Kehittäjä / Verkkoselain",
            "db_layer": "Oracle 23ai -tietokantakerros - SEPS Wallet -suojattu",
            "ords_label": "app-ords - ORDS 26.2 -yhdyskäytävä",
            "pub_label": "app-publisher - Analytics Publisher 2025",
            "forms_label": "app-forms - Forms 14c -palvelut",
            "vnc_label": "app-forms - HTML5 noVNC Forms Builder",
            "ide_label": "web-ide-dev - VS Code Web IDE",
            "pool_conn": "JDBC / SEPS -yhteysallas",
            "jdbc_thin": "JDBC Thin / RCU-metatiedot",
            "dblink": "Database Link / Suojattu REST",
            "seps_conn": "SEPS Wallet / SQLcl",
            "proxy_role": "APEX 26.1 Proxy, Lähtevä REST ja SSO",
            "alise_role": "ALISE-liiketoimintatiedot ja PL/SQL",
            "pub_role": "Publisher RCU -metatiedot",
            "forms_role": "Forms 14c RCU -metatiedot"
        },
        "sv": {
            "client": "Utvecklare / Webbläsare",
            "db_layer": "Oracle 23ai Databaslager - SEPS Wallet-säkrat",
            "ords_label": "app-ords - ORDS 26.2 Gateway",
            "pub_label": "app-publisher - Analytics Publisher 2025",
            "forms_label": "app-forms - Forms 14c Tjänster",
            "vnc_label": "app-forms - HTML5 noVNC Forms Builder",
            "ide_label": "web-ide-dev - VS Code Web IDE",
            "pool_conn": "JDBC / SEPS Anslutningspool",
            "jdbc_thin": "JDBC Thin / RCU Metainformation",
            "dblink": "Database Link / Säker REST",
            "seps_conn": "SEPS Wallet / SQLcl",
            "proxy_role": "APEX 26.1 Proxy, Utgående REST och SSO",
            "alise_role": "ALISE Affärsdata och PL/SQL-logik",
            "pub_role": "Publisher RCU Metainformation",
            "forms_role": "Forms 14c RCU Metainformation"
        },
        "lv": {
            "client": "Izstrādātājs / Pārlūks",
            "db_layer": "Oracle 23ai Datubāzes Slānis - SEPS Wallet Aizsargāts",
            "ords_label": "app-ords - ORDS 26.2 Vārteja",
            "pub_label": "app-publisher - Analytics Publisher 2025",
            "forms_label": "app-forms - Forms 14c Pakalpojumi",
            "vnc_label": "app-forms - HTML5 noVNC Forms Builder",
            "ide_label": "web-ide-dev - VS Code Web IDE",
            "pool_conn": "JDBC / SEPS Savienojumu Pūls",
            "jdbc_thin": "JDBC Thin / RCU Metadati",
            "dblink": "Database Link / Drošs REST",
            "seps_conn": "SEPS Wallet / SQLcl",
            "proxy_role": "APEX 26.1 Proxy, Izejošais REST un SSO",
            "alise_role": "ALISE Biznesa Dati un PL/SQL Loģika",
            "pub_role": "Publisher RCU Metadati",
            "forms_role": "Forms 14c RCU Metadati"
        },
        "lt": {
            "client": "Kūrėjas / Naršyklė",
            "db_layer": "Oracle 23ai Duomenų Bazių Sluoksnis - Apsaugotas SEPS Wallet",
            "ords_label": "app-ords - ORDS 26.2 Šliuzas",
            "pub_label": "app-publisher - Analytics Publisher 2025",
            "forms_label": "app-forms - Forms 14c Paslaugos",
            "vnc_label": "app-forms - HTML5 noVNC Forms Builder",
            "ide_label": "web-ide-dev - VS Code Web IDE",
            "pool_conn": "JDBC / SEPS Ryšių Telkinys",
            "jdbc_thin": "JDBC Thin / RCU Metaduomenys",
            "dblink": "Database Link / Saugus REST",
            "seps_conn": "SEPS Wallet / SQLcl",
            "proxy_role": "APEX 26.1 Proxy, Išeinantis REST ir SSO",
            "alise_role": "ALISE Verslo Duomenys ir PL/SQL Logika",
            "pub_role": "Publisher RCU Metaduomenys",
            "forms_role": "Forms 14c RCU Metaduomenys"
        }
    }
    t = L.get(lang, L["en"])
    lines = ["graph TD"]
    lines.append(f'    Client["🌐 {t["client"]}"]')
    
    if not env_v.get("SKIP_ORDS", "false").lower() == "true":
        lines.append(f'    Client -->|HTTPS 8448 / HTTP 8088| ORDS["🚀 {t["ords_label"]}"]')
    if env_v.get("SKIP_PUBLISHER", "true").lower() == "false" or bp_num in [10, 11, 12, 13, 41, 42, 43]:
        lines.append(f'    Client -->|HTTP 9502| Pub["📊 {t["pub_label"]}"]')
    if env_v.get("SKIP_FORMS", "true").lower() == "false" or bp_num in [20, 21, 22, 23, 41, 42, 43]:
        lines.append(f'    Client -->|HTTP 9001| Forms["📐 {t["forms_label"]}"]')
        lines.append(f'    Client -->|noVNC 6082| FormsGUI["🎨 {t["vnc_label"]}"]')
    if not env_v.get("SKIP_WEB_IDE", "true").lower() == "true" or bp_num in [30, 31, 32, 33, 34, 41, 42, 43]:
        lines.append(f'    Client -->|HTTP 8090| WebIDE["💻 {t["ide_label"]}"]')
        
    lines.append(f'    subgraph DatabaseLayer ["{t["db_layer"]}"]')
    for d in active_dbs:
        cn = d["c_name"]
        p = d["port"]
        sh = d["short"]
        role_key = f"{sh.lower()}_role"
        role_desc = t.get(role_key, "Business Data and Schemas")
        icon = "🛡️" if "proxy" in cn else ("📦" if "alise" in cn else ("📑" if "pub" in cn else "📐"))
        lines.append(f'        DB_{sh}["{icon} {cn} : {p}<br/>FREEPDB1<br/>{role_desc}"]')
    lines.append('    end')
    
    for d in active_dbs:
        sh = d["short"]
        if d["ords_enabled"] and not env_v.get("SKIP_ORDS", "false").lower() == "true":
            lines.append(f'    ORDS -->|{t["pool_conn"]}| DB_{sh}')
            
    if (env_v.get("SKIP_PUBLISHER", "true").lower() == "false" or bp_num in [10, 11, 12, 13, 41, 42, 43]):
        has_pub_db = any(d["short"] == "PUBLISHER" for d in active_dbs)
        target_db = "DB_PUBLISHER" if has_pub_db else "DB_PROXY"
        lines.append(f'    Pub -->|{t["jdbc_thin"]}| {target_db}')
        
    if (env_v.get("SKIP_FORMS", "true").lower() == "false" or bp_num in [20, 21, 22, 23, 41, 42, 43]):
        has_forms_db = any(d["short"] == "FORMS" for d in active_dbs)
        target_db = "DB_FORMS" if has_forms_db else "DB_PROXY"
        lines.append(f'    Forms -->|{t["jdbc_thin"]}| {target_db}')
        
    has_proxy = any(d["short"] == "PROXY" for d in active_dbs)
    has_alise = any(d["short"] == "ALISE" for d in active_dbs)
    if has_proxy and has_alise:
        lines.append(f'    DB_PROXY -.->|{t["dblink"]}| DB_ALISE')
        
    return "\n".join(lines)
