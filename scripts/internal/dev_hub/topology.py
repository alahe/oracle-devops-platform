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
            "client": "Developer / Browser",
            "db_layer": "Oracle 23ai Database Tier (SEPS Wallet)",
            "remote_db": "Remote Oracle Database<br/>Autonomous / Cloud ADB",
            "ords_name": "app-ords :8088 / :8448<br/>ORDS 26.2 REST Gateway",
            "pub_name": "app-publisher :9502<br/>Analytics Publisher 2025",
            "forms_name": "app-forms :9001<br/>Forms 14c Services",
            "forms_gui": "app-forms noVNC :6082<br/>Forms Builder GUI",
            "forms_pub_name": "app-forms-publisher<br/>Forms 14c & Publisher",
            "ide_name": "web-ide-dev :8090<br/>VS Code Web IDE",
            "designer_name": "app-publisher-designer<br/>noVNC Desktop :6083",
            "pool_conn": "JDBC / SEPS Pool",
            "jdbc_rcu": "JDBC Thin / RCU",
            "dblink": "Database Link / REST",
            "sqlnet": "SQLNet TNS / SEPS",
            "remote_conn": "Cloud mTLS / SQLNet",
            "proxy_desc": "APEX 26.1 Proxy<br/>Outbound REST & SSO",
            "alise_desc": "ALISE Business Data<br/>& PL/SQL Logic",
            "pub_desc": "Publisher RCU Metadata<br/>& Repository",
            "forms_desc": "Forms 14c RCU Metadata<br/>& Application Server",
            "unified_desc": "Unified Forms 14c<br/>& Publisher Repository",
            "adb_desc": "Autonomous Database<br/>Cloud mTLS Gateway",
            "standalone_desc": "Dedicated Oracle 23ai<br/>Standalone PDB",
            "gvenzl_desc": "Gerald Venzl Image<br/>Autonomous PDB"
        },
        "et": {
            "client": "Arendaja / Veebibrauser",
            "db_layer": "Oracle 23ai Andmebaasikiht (SEPS Wallet)",
            "remote_db": "Kaugandmebaas Oracle DB<br/>Autonomous / Cloud ADB",
            "ords_name": "app-ords :8088 / :8448<br/>ORDS 26.2 REST Lüüs",
            "pub_name": "app-publisher :9502<br/>Analytics Publisher 2025",
            "forms_name": "app-forms :9001<br/>Forms 14c Teenused",
            "forms_gui": "app-forms noVNC :6082<br/>Forms Builder GUI",
            "forms_pub_name": "app-forms-publisher<br/>Forms 14c & Publisher",
            "ide_name": "web-ide-dev :8090<br/>VS Code Web IDE",
            "designer_name": "app-publisher-designer<br/>noVNC Töölaud :6083",
            "pool_conn": "JDBC / SEPS Bassein",
            "jdbc_rcu": "JDBC Thin / RCU",
            "dblink": "Database Link / REST",
            "sqlnet": "SQLNet TNS / SEPS",
            "remote_conn": "Pilve mTLS / SQLNet",
            "proxy_desc": "APEX 26.1 Proxy<br/>Väljuv REST & SSO",
            "alise_desc": "ALISE Äriandmed<br/>& PL/SQL Loogika",
            "pub_desc": "Publisher RCU Metaandmed<br/>& Hoidla",
            "forms_desc": "Forms 14c RCU Metaandmed<br/>& Rakendusserver",
            "unified_desc": "Ühendatud Forms 14c<br/>& Publisher Hoidla",
            "adb_desc": "Autonomous Database<br/>Pilve mTLS Lüüs",
            "standalone_desc": "Eraldiseisev Oracle 23ai<br/>Puhas PDB",
            "gvenzl_desc": "Gerald Venzl Tõmmis<br/>Autonoomne PDB"
        },
        "fi": {
            "client": "Kehittäjä / Verkkoselain",
            "db_layer": "Oracle 23ai -tietokantakerros (SEPS Wallet)",
            "remote_db": "Etätietokanta Oracle DB<br/>Autonomous / Cloud ADB",
            "ords_name": "app-ords :8088 / :8448<br/>ORDS 26.2 -yhdyskäytävä",
            "pub_name": "app-publisher :9502<br/>Analytics Publisher 2025",
            "forms_name": "app-forms :9001<br/>Forms 14c -palvelut",
            "forms_gui": "app-forms noVNC :6082<br/>Forms Builder GUI",
            "forms_pub_name": "app-forms-publisher<br/>Forms 14c & Publisher",
            "ide_name": "web-ide-dev :8090<br/>VS Code Web IDE",
            "designer_name": "app-publisher-designer<br/>noVNC Työpöytä :6083",
            "pool_conn": "JDBC / SEPS -allas",
            "jdbc_rcu": "JDBC Thin / RCU",
            "dblink": "Database Link / REST",
            "sqlnet": "SQLNet TNS / SEPS",
            "remote_conn": "Pilvi mTLS / SQLNet",
            "proxy_desc": "APEX 26.1 Proxy<br/>Lähtevä REST & SSO",
            "alise_desc": "ALISE-liiketoimintatiedot<br/>& PL/SQL-logiikka",
            "pub_desc": "Publisher RCU -metatiedot<br/>& Säilö",
            "forms_desc": "Forms 14c RCU -metatiedot<br/>& Sovelluspalvelin",
            "unified_desc": "Yhdistetty Forms 14c<br/>& Publisher -säilö",
            "adb_desc": "Autonomous Database<br/>Pilvi-mTLS-yhdyskäytävä",
            "standalone_desc": "Erillinen Oracle 23ai<br/>Puhdas PDB",
            "gvenzl_desc": "Gerald Venzl -kuva<br/>Autonominen PDB"
        },
        "sv": {
            "client": "Utvecklare / Webbläsare",
            "db_layer": "Oracle 23ai Databaslager (SEPS Wallet)",
            "remote_db": "Fjärrdatabas Oracle DB<br/>Autonomous / Cloud ADB",
            "ords_name": "app-ords :8088 / :8448<br/>ORDS 26.2 Gateway",
            "pub_name": "app-publisher :9502<br/>Analytics Publisher 2025",
            "forms_name": "app-forms :9001<br/>Forms 14c Tjänster",
            "forms_gui": "app-forms noVNC :6082<br/>Forms Builder GUI",
            "forms_pub_name": "app-forms-publisher<br/>Forms 14c & Publisher",
            "ide_name": "web-ide-dev :8090<br/>VS Code Web IDE",
            "designer_name": "app-publisher-designer<br/>noVNC Skrivbord :6083",
            "pool_conn": "JDBC / SEPS Pool",
            "jdbc_rcu": "JDBC Thin / RCU",
            "dblink": "Database Link / REST",
            "sqlnet": "SQLNet TNS / SEPS",
            "remote_conn": "Moln mTLS / SQLNet",
            "proxy_desc": "APEX 26.1 Proxy<br/>Utgående REST & SSO",
            "alise_desc": "ALISE Affärsdata<br/>& PL/SQL-logik",
            "pub_desc": "Publisher RCU Metainfo<br/>& Databasarkiv",
            "forms_desc": "Forms 14c RCU Metainfo<br/>& Applikationsserver",
            "unified_desc": "Förenad Forms 14c<br/>& Publisher-arkiv",
            "adb_desc": "Autonomous Database<br/>Moln mTLS Gateway",
            "standalone_desc": "Fristående Oracle 23ai<br/>Ren PDB",
            "gvenzl_desc": "Gerald Venzl Avbildning<br/>Autonom PDB"
        },
        "lv": {
            "client": "Izstrādātājs / Pārlūks",
            "db_layer": "Oracle 23ai Datubāzes Slānis (SEPS Wallet)",
            "remote_db": "Attālinātā Oracle DB<br/>Autonomous / Cloud ADB",
            "ords_name": "app-ords :8088 / :8448<br/>ORDS 26.2 Vārteja",
            "pub_name": "app-publisher :9502<br/>Analytics Publisher 2025",
            "forms_name": "app-forms :9001<br/>Forms 14c Pakalpojumi",
            "forms_gui": "app-forms noVNC :6082<br/>Forms Builder GUI",
            "forms_pub_name": "app-forms-publisher<br/>Forms 14c & Publisher",
            "ide_name": "web-ide-dev :8090<br/>VS Code Web IDE",
            "designer_name": "app-publisher-designer<br/>noVNC Darbvirsma :6083",
            "pool_conn": "JDBC / SEPS Pūls",
            "jdbc_rcu": "JDBC Thin / RCU",
            "dblink": "Database Link / REST",
            "sqlnet": "SQLNet TNS / SEPS",
            "remote_conn": "Mākoņa mTLS / SQLNet",
            "proxy_desc": "APEX 26.1 Proxy<br/>Izejošais REST & SSO",
            "alise_desc": "ALISE Biznesa Dati<br/>& PL/SQL Loģika",
            "pub_desc": "Publisher RCU Metadati<br/>& Repozitorijs",
            "forms_desc": "Forms 14c RCU Metadati<br/>& Lietotņu Serveris",
            "unified_desc": "Apvienots Forms 14c<br/>& Publisher Repozitorijs",
            "adb_desc": "Autonomous Database<br/>Mākoņa mTLS Vārteja",
            "standalone_desc": "Savrupa Oracle 23ai<br/>Tīra PDB",
            "gvenzl_desc": "Gerald Venzl Attēls<br/>Autonoma PDB"
        },
        "lt": {
            "client": "Kūrėjas / Naršyklė",
            "db_layer": "Oracle 23ai DB Sluoksnis (SEPS Wallet)",
            "remote_db": "Nutolusi Oracle DB<br/>Autonomous / Cloud ADB",
            "ords_name": "app-ords :8088 / :8448<br/>ORDS 26.2 Šliuzas",
            "pub_name": "app-publisher :9502<br/>Analytics Publisher 2025",
            "forms_name": "app-forms :9001<br/>Forms 14c Paslaugos",
            "forms_gui": "app-forms noVNC :6082<br/>Forms Builder GUI",
            "forms_pub_name": "app-forms-publisher<br/>Forms 14c & Publisher",
            "ide_name": "web-ide-dev :8090<br/>VS Code Web IDE",
            "designer_name": "app-publisher-designer<br/>noVNC Darbalaukis :6083",
            "pool_conn": "JDBC / SEPS Telkinys",
            "jdbc_rcu": "JDBC Thin / RCU",
            "dblink": "Database Link / REST",
            "sqlnet": "SQLNet TNS / SEPS",
            "remote_conn": "Debesies mTLS / SQLNet",
            "proxy_desc": "APEX 26.1 Proxy<br/>Išeinantis REST & SSO",
            "alise_desc": "ALISE Verslo Duomenys<br/>& PL/SQL Logika",
            "pub_desc": "Publisher RCU Metaduomenys<br/>& Saugykla",
            "forms_desc": "Forms 14c RCU Metaduomenys<br/>& Programų Serveris",
            "unified_desc": "Sujungtas Forms 14c<br/>& Publisher Saugykla",
            "adb_desc": "Autonomous Database<br/>Debesies mTLS Šliuzas",
            "standalone_desc": "Atskira Oracle 23ai<br/>Gryna PDB",
            "gvenzl_desc": "Gerald Venzl Atvaizdis<br/>Autonominė PDB"
        }
    }
    t = L.get(lang, L["en"])
    lines = ["flowchart TB"]
    lines.append(f'    Client["🌐 {t["client"]}"]')

    # Resolve active profiles
    ords_p = env_v.get("ORDS_PROFILE")
    if ords_p and ords_p.upper() == "NONE": ords_p = None
    pub_p = env_v.get("PUBLISHER_PROFILE")
    if pub_p and pub_p.upper() == "NONE": pub_p = None
    forms_p = env_v.get("FORMS_PROFILE")
    if forms_p and forms_p.upper() == "NONE": forms_p = None
    forms_pub_p = env_v.get("FORMS_PUBLISHER_PROFILE")
    if forms_pub_p and forms_pub_p.upper() == "NONE": forms_pub_p = None
    ide_p = env_v.get("WEB_IDE_PROFILE")
    if ide_p and ide_p.upper() == "NONE": ide_p = None
    des_p = env_v.get("PUBLISHER_DESIGNER_PROFILE")
    if des_p and des_p.upper() == "NONE": des_p = None

    # Application Tier Connections from Client
    if ords_p:
        lines.append(f'    Client -->|HTTPS 8448 / HTTP 8088| ORDS["🚀 {t["ords_name"]}"]')
    if pub_p:
        lines.append(f'    Client -->|HTTP 9502| Pub["📊 {t["pub_name"]}"]')
    if forms_p:
        lines.append(f'    Client -->|HTTP 9001| Forms["📐 {t["forms_name"]}"]')
        lines.append(f'    Client -->|noVNC 6082| FormsGUI["🎨 {t["forms_gui"]}"]')
    if forms_pub_p:
        lines.append(f'    Client -->|HTTP 9005 / 9505| FormsPub["📐 {t["forms_pub_name"]}"]')
        lines.append(f'    Client -->|noVNC 6085| FormsPubGUI["🎨 {t["forms_gui"]}"]')
    if ide_p:
        lines.append(f'    Client -->|HTTP 8090| WebIDE["💻 {t["ide_name"]}"]')
    if des_p:
        lines.append(f'    Client -->|noVNC 6083| PubDes["🎨 {t["designer_name"]}"]')

    # Database Tier
    if active_dbs:
        lines.append(f'    subgraph DatabaseLayer ["{t["db_layer"]}"]')
        lines.append('        direction TB')
        for d in active_dbs:
            cn = d.get("c_name", "")
            p = d.get("port", "")
            sh = d.get("short", "DB")

            if "proxy" in cn and "standalone" in cn:
                role_desc = t["standalone_desc"]
            elif "proxy" in cn:
                role_desc = t["proxy_desc"]
            elif "alise" in cn:
                role_desc = t["alise_desc"]
            elif "gvenzl" in cn:
                role_desc = t["gvenzl_desc"]
            elif "adb" in cn:
                role_desc = t["adb_desc"]
            elif "publisher" in cn and "forms" in cn:
                role_desc = t["unified_desc"]
            elif "publisher" in cn:
                role_desc = t["pub_desc"]
            elif "forms" in cn:
                role_desc = t["forms_desc"]
            else:
                role_desc = t["standalone_desc"]

            icon = "🛡️" if "proxy" in cn else ("📦" if "alise" in cn else ("📑" if "pub" in cn else ("📐" if "forms" in cn else "💾")))
            lines.append(f'        DB_{sh}["{icon} {cn} :{p}<br/>FREEPDB1 &bull; SEPS<br/>{role_desc}"]')
        lines.append('    end')

        # Connect Apps to DBs
        if ords_p:
            for d in active_dbs:
                if d.get("ords_enabled", True):
                    lines.append(f'    ORDS -->|{t["pool_conn"]}| DB_{d["short"]}')

        if pub_p:
            has_pub_db = any("pub" in d.get("c_name", "") for d in active_dbs)
            target_db = "DB_PUBLISHER" if has_pub_db else ("DB_FORMS_PUBLISHER" if any("forms-publisher" in d.get("c_name", "") for d in active_dbs) else "DB_PROXY")
            lines.append(f'    Pub -->|{t["jdbc_rcu"]}| {target_db}')

        if forms_p:
            has_forms_db = any("forms" in d.get("c_name", "") for d in active_dbs)
            target_db = "DB_FORMS" if has_forms_db else ("DB_FORMS_PUBLISHER" if any("forms-publisher" in d.get("c_name", "") for d in active_dbs) else "DB_PROXY")
            lines.append(f'    Forms -->|{t["jdbc_rcu"]}| {target_db}')

        if forms_pub_p:
            lines.append(f'    FormsPub -->|{t["jdbc_rcu"]}| DB_FORMS_PUBLISHER')

        # Direct Client connections
        has_apps = any([ords_p, pub_p, forms_p, forms_pub_p, ide_p, des_p])
        if not has_apps:
            # Standalone DB (e.g. BP 2 or BP 3)
            for d in active_dbs:
                lines.append(f'    Client -->|{t["sqlnet"]} :{d["port"]}| DB_{d["short"]}')
        else:
            primary_db = active_dbs[0]["short"]
            lines.append(f'    Client -.->|{t["sqlnet"]}| DB_{primary_db}')

        # Inter-DB Link (Proxy <-> ALISE)
        if any("proxy" in d.get("c_name", "") for d in active_dbs) and any("alise" in d.get("c_name", "") for d in active_dbs):
            lines.append(f'    DB_PROXY -.->|{t["dblink"]}| DB_ALISE')

    else:
        # Zero-DB Blueprints (e.g. 8, 9, 10, 11)
        if ords_p:
            lines.append(f'    RemoteDB["☁️ {t["remote_db"]}"]')
            lines.append(f'    ORDS -->|{t["remote_conn"]}| RemoteDB')
        elif pub_p:
            lines.append(f'    RemoteDB["☁️ {t["remote_db"]}"]')
            lines.append(f'    Pub -->|{t["remote_conn"]}| RemoteDB')

    return "\n".join(lines)
