"""
Oracle DevOps Platform - Developer Hub Blueprint Parser
Parses .env.* files and resolves YAML profile references to build blueprint models.
"""
import os
from .topology import load_yaml_profile, generate_active_blueprint_mermaid

def parse_blueprint_env_and_metadata(bp_file, b_num):
    env_v = {}
    with open(bp_file, "r", encoding="utf-8") as f:
        for line in f:
            line_str = line.strip()
            if not line_str or line_str.startswith("#"):
                continue
            if "=" in line_str:
                k, v = line_str.split("=", 1)
                env_v[k.strip()] = v.strip().strip('"\'')

    # Resolve active DBs for this blueprint dynamically from env_v
    dbs = []
    db_keys = [k for k in env_v.keys() if k.startswith("DB_") and k not in ["DB_ENABLED", "DB_USER", "DB_PASS", "DB_PASSWORD", "DB_REMOTE"]]
    priority_order = ["DB_PROXY", "DB_ALISE", "DB_PROXY_STANDALONE", "DB_GVENZL", "DB_ADB", "DB_PUBLISHER", "DB_FORMS"]
    sorted_db_keys = sorted(db_keys, key=lambda k: priority_order.index(k) if k in priority_order else 99)
    for db_k in sorted_db_keys:
        pval = env_v.get(db_k, "")
        if pval and pval.upper() != "NONE":
            p_data = load_yaml_profile(pval)
            db_cfg = p_data.get("database", {})
            def_c = db_k.lower().replace("_", "-")
            c_name = db_cfg.get("container_name") or (f"db-{pval}" if not pval.startswith("db-") else pval) or def_c
            c_short = c_name.replace("db-", "").replace("-", "_").upper()
            comp = p_data.get("database_features", p_data.get("components", {}))
            ords_conf = comp.get("ords", {})
            apex_conf = comp.get("apex", {})
            pool_name = ords_conf.get("pool_name", c_name.replace("db-", "").replace("-", "_"))
            dbs.append({
                "key": db_k,
                "c_name": c_name,
                "short": c_short,
                "prof_name": pval,
                "pool_name": pool_name,
                "ords_enabled": str(ords_conf.get("enabled", "true")).lower() == "true",
                "apex_enabled": str(apex_conf.get("enabled", "false")).lower() == "true",
                "workspace": apex_conf.get("workspace", f"{c_short}_WORKSPACE"),
                "port": str(db_cfg.get("db_port", "1521")),
                "users": p_data.get("users", [])
            })

    # Fallback if MAIN_DB_PROFILE is specified and not NONE
    if not dbs and env_v.get("MAIN_DB_PROFILE") and env_v.get("MAIN_DB_PROFILE").upper() != "NONE":
        pval = env_v.get("MAIN_DB_PROFILE")
        p_data = load_yaml_profile(pval)
        db_cfg = p_data.get("database", {})
        c_name = db_cfg.get("container_name") or (f"db-{pval}" if not pval.startswith("db-") else pval) or "db-proxy"
        c_short = c_name.replace("db-", "").replace("-", "_").upper()
        comp = p_data.get("database_features", p_data.get("components", {}))
        ords_conf = comp.get("ords", {})
        apex_conf = comp.get("apex", {})
        pool_name = ords_conf.get("pool_name", c_name.replace("db-", "").replace("-", "_"))
        dbs.append({
            "key": "MAIN_DB_PROFILE",
            "c_name": c_name,
            "short": c_short,
            "prof_name": pval,
            "pool_name": pool_name,
            "ords_enabled": str(ords_conf.get("enabled", "true")).lower() == "true",
            "apex_enabled": str(apex_conf.get("enabled", "false")).lower() == "true",
            "workspace": apex_conf.get("workspace", f"{c_short}_WORKSPACE"),
            "port": str(db_cfg.get("db_port", "1521")),
            "users": p_data.get("users", [])
        })

    # Components list (Derived 100% from positive YAML Profile references)
    components = []

    # 1. DB containers (Primary components for database blueprints)
    for d in dbs:
        components.append({
            "name": d["c_name"],
            "type": f"Oracle 23ai Free DB ({d['prof_name']})",
            "host_ports": f"{d['port']} (SQLNet TNS)",
            "desc": f"Dedicated database instance (Service: FREEPDB1) with SEPS Wallet encryption"
        })

    # 1. ORDS Gateway
    ords_p = env_v.get("ORDS_PROFILE")
    if not ords_p and (b_num in [0, 1, 2, 3, 4, 10]) and env_v.get("MAIN_DB_PROFILE", "").upper() != "NONE":
        ords_p = "ords-image"
    if ords_p and ords_p.upper() != "NONE":
        p_data = load_yaml_profile(ords_p)
        ords_cfg = p_data.get("ords", {})
        c_name = ords_cfg.get("container_name", "app-ords")
        h_port = ords_cfg.get("http_port", 8088)
        hs_port = ords_cfg.get("https_port", 8448)
        components.append({
            "name": c_name,
            "type": "ORDS 26.2 REST Gateway & APEX Engine",
            "host_ports": f"{h_port} (HTTP), {hs_port} (HTTPS)",
            "desc": "Jetty web server, Multi-pool routing, APEX static resources & REST endpoints"
        })

    # 2. Analytics Publisher
    pub_p = env_v.get("PUBLISHER_PROFILE")
    if pub_p and pub_p.upper() != "NONE":
        p_data = load_yaml_profile(pub_p)
        pub_cfg = p_data.get("publisher", {})
        c_name = pub_cfg.get("container_name", "app-publisher")
        h_port = pub_cfg.get("http_port", 9502)
        hs_port = pub_cfg.get("https_port", 9503)
        adm_port = pub_cfg.get("admin_port", 9500)
        p_str = f"{h_port} (HTTP)"
        if hs_port: p_str += f", {hs_port} (HTTPS)"
        if adm_port: p_str += f", {adm_port} (Admin)"
        components.append({
            "name": c_name,
            "type": "Oracle Analytics Publisher 2025 (Pixel-Perfect)",
            "host_ports": p_str,
            "desc": "Enterprise PDF/Excel pixel-perfect report generator & REST API"
        })

    # 3. Oracle Forms 14c
    forms_p = env_v.get("FORMS_PROFILE")
    if forms_p and forms_p.upper() != "NONE":
        p_data = load_yaml_profile(forms_p)
        forms_cfg = p_data.get("forms", {})
        c_name = forms_cfg.get("container_name", "app-forms")
        h_port = forms_cfg.get("http_port", 9001)
        vnc_p = forms_cfg.get("vnc_port", 6082)
        adm_p = forms_cfg.get("admin_port", 7001)
        p_str = f"{h_port} (Forms)"
        if vnc_p: p_str += f", {vnc_p} (noVNC)"
        if adm_p: p_str += f", {adm_p} (Admin)"
        components.append({
            "name": c_name,
            "type": "Oracle Forms 14.1.2 & WebLogic Domain",
            "host_ports": p_str,
            "desc": "WebLogic Forms servlet runtime & HTML5 noVNC Forms Builder GUI"
        })

    # 4. Consolidated Forms + Publisher FMW
    fp_p = env_v.get("FORMS_PUBLISHER_PROFILE")
    if fp_p and fp_p.upper() != "NONE":
        p_data = load_yaml_profile(fp_p)
        f_cfg = p_data.get("forms", {})
        p_cfg = p_data.get("publisher", {})
        c_name = f_cfg.get("container_name", "app-forms-publisher")
        p_str = f"{f_cfg.get('http_port', 9001)} (Forms), {p_cfg.get('http_port', 9502)} (Publisher), {f_cfg.get('vnc_port', 6082)} (noVNC), {f_cfg.get('admin_port', 7001)} (Admin)"
        components.append({
            "name": c_name,
            "type": "Consolidated Forms 14c & Publisher FMW Domain",
            "host_ports": p_str,
            "desc": "Unified WebLogic domain running Forms 14c and Analytics Publisher in a single container"
        })

    # 5. Web IDE Workstation
    ide_p = env_v.get("WEB_IDE_PROFILE")
    if ide_p and ide_p.upper() != "NONE":
        p_data = load_yaml_profile(ide_p)
        ide_cfg = p_data.get("web_ide", {})
        c_name = ide_cfg.get("container_name", "web-ide-dev")
        p_cfg = ide_cfg.get("ports", {})
        h_port = p_cfg.get("http_port", 8090)
        hs_port = p_cfg.get("https_port", 8450)
        ci_port = p_cfg.get("cicd_ui_port", 8091)
        p_str = f"{h_port} (HTTP)"
        if hs_port: p_str += f", {hs_port} (HTTPS)"
        if ci_port: p_str += f", {ci_port} (CI/CD)"
        components.append({
            "name": c_name,
            "type": "VS Code Web IDE & SQL Developer",
            "host_ports": p_str,
            "desc": "Browser-based developer workstation with Oracle SQL Developer extension & AI tools"
        })

    # 6. Publisher Designer Workstation
    des_p = env_v.get("PUBLISHER_DESIGNER_PROFILE")
    if des_p and des_p.upper() != "NONE":
        p_data = load_yaml_profile(des_p)
        c_name = p_data.get("container", {}).get("name", "app-publisher-designer")
        p_list = []
        for p in p_data.get("network", {}).get("ports", []):
            hp = p.get("host_port")
            d_str = p.get("description", "")
            if "noVNC" in d_str or hp == 6083:
                p_list.append(f"{hp} (noVNC)")
            elif "VNC" in d_str or hp == 5903:
                p_list.append(f"{hp} (VNC)")
            elif hp:
                p_list.append(str(hp))
        p_str = ", ".join(p_list) if p_list else "6083 (noVNC), 5903 (VNC)"
        components.append({
            "name": c_name,
            "type": "Publisher Desktop Template Designer",
            "host_ports": p_str,
            "desc": "HTML5 noVNC desktop workstation with Microsoft Word and BIP Template Builder for RTF design"
        })


    # Consolidated Users & Portal Entry points list
    all_users = []
    seen_keys = set()

    for d in dbs:
        p_name = d.get("pool_name", d["c_name"].replace("db-", "").replace("-", "_"))
        ws_name = d.get("workspace", f"{d['short']}_WORKSPACE")
        apex_on = d.get("apex_enabled", True)
        ords_on = d.get("ords_enabled", True)

        # 1. APEX Instance Admin (if APEX is enabled)
        if apex_on:
            admin_alias = f"DB_{d['short']}_APEX_ADMIN"
            admin_key = f"{d['c_name']}_ADMIN_{admin_alias}"
            if admin_key not in seen_keys:
                seen_keys.add(admin_key)
                all_users.append({
                    "db": d["c_name"],
                    "username": "ADMIN",
                    "portal_title": "⚙️ APEX Instance Admin",
                    "role": "ADMIN",
                    "scope": "INTERNAL",
                    "wallet_alias": admin_alias,
                    "color": "#f59e0b",
                    "login_url": f"https://localhost:8448/ords/{p_name}/r/apex/workspace-sign-in/administration-sign-in?p10_username=ADMIN"
                })

        # 2. Database Users from Profile
        for u in d.get("users", []):
            u_name = u.get("username", "USER")
            u_role = u.get("role", "NORMAL")
            w_alias = u.get("wallet_alias", f"DB_{d['short']}_{u_name}".upper())
            u_color = u.get("color", "#38bdf8")

            if u_role == "DBA":
                # DBA Database Actions (SDW)
                key = f"{d['c_name']}_{u_name}_{w_alias}_sdw"
                if key not in seen_keys:
                    seen_keys.add(key)
                    all_users.append({
                        "db": d["c_name"],
                        "username": u_name,
                        "portal_title": "📊 Database Actions (DBA / SDW)",
                        "role": u_role,
                        "scope": ws_name,
                        "wallet_alias": w_alias,
                        "color": u_color or "#f59e0b",
                        "login_url": f"https://localhost:8448/ords/{p_name}/dba_admin/sign-in?username={u_name}&r=_sdw" if ords_on else ""
                    })
            elif "DEV" in u_name.upper() or "DEV" in w_alias:
                # 2.1 APEX Developer Workspace
                if apex_on:
                    key_ws = f"{d['c_name']}_DEV_{w_alias}_ws"
                    if key_ws not in seen_keys:
                        seen_keys.add(key_ws)
                        all_users.append({
                            "db": d["c_name"],
                            "username": "DEV",
                            "portal_title": f"🛠️ APEX Workspace ({ws_name})",
                            "role": "DEVELOPER",
                            "scope": ws_name,
                            "wallet_alias": w_alias,
                            "color": "#38bdf8",
                            "login_url": f"https://localhost:8448/ords/{p_name}/r/apex/workspace-sign-in/oracle-apex-sign-in?f4550_p1_company={ws_name}&f4550_p1_username=DEV"
                        })
                # 2.2 Database Actions Developer
                key_dev = f"{d['c_name']}_{u_name}_{w_alias}_sdw"
                if key_dev not in seen_keys:
                    seen_keys.add(key_dev)
                    all_users.append({
                        "db": d["c_name"],
                        "username": u_name,
                        "portal_title": "📊 Database Actions (Developer / SDW)",
                        "role": u_role,
                        "scope": ws_name,
                        "wallet_alias": w_alias,
                        "color": u_color or "#38bdf8",
                        "login_url": f"https://localhost:8448/ords/{p_name}/{u_name.lower()}/sign-in?username={u_name}&r=_sdw" if ords_on else ""
                    })
            else:
                # Standard Schema / Other user
                key_gen = f"{d['c_name']}_{u_name}_{w_alias}"
                if key_gen not in seen_keys:
                    seen_keys.add(key_gen)
                    all_users.append({
                        "db": d["c_name"],
                        "username": u_name,
                        "portal_title": "🗄️ Database Schema & REST",
                        "role": u_role,
                        "scope": ws_name,
                        "wallet_alias": w_alias,
                        "color": u_color or "#4ade80",
                        "login_url": f"https://localhost:8448/ords/{p_name}/{u_name.lower()}/sign-in?username={u_name}&r=_sdw" if ords_on else ""
                    })

    # 3. Middleware Accounts (Publisher, Forms, Web IDE, Designer)
    if pub_p and pub_p.upper() != "NONE":
        p_cfg = load_yaml_profile(pub_p).get("publisher", {})
        h_port = p_cfg.get("http_port", 9502)
        all_users.append({
            "db": "app-publisher",
            "username": "Administrator",
            "portal_title": "📑 Analytics Publisher (BIP Admin)",
            "role": "ADMIN",
            "scope": "xmlpserver",
            "wallet_alias": "DB_PUBLISHER_SYS",
            "color": "#fb923c",
            "login_url": f"http://localhost:{h_port}/xmlpserver"
        })
        all_users.append({
            "db": "app-publisher",
            "username": "weblogic",
            "portal_title": "⚙️ WebLogic Admin Console",
            "role": "WLS ADMIN",
            "scope": "console",
            "wallet_alias": "DB_PUBLISHER_SYS",
            "color": "#fbbf24",
            "login_url": f"http://localhost:{h_port}/console"
        })

    if forms_p and forms_p.upper() != "NONE":
        f_cfg = load_yaml_profile(forms_p).get("forms", {})
        h_port = f_cfg.get("http_port", 9001)
        vnc_p = f_cfg.get("vnc_port", 6082)
        adm_p = f_cfg.get("admin_port", 7001)
        all_users.append({
            "db": "app-forms",
            "username": "weblogic",
            "portal_title": "⚙️ WebLogic Console",
            "role": "WLS ADMIN",
            "scope": "console",
            "wallet_alias": "DB_FORMS_SYS",
            "color": "#fbbf24",
            "login_url": f"http://localhost:{adm_p}/console"
        })
        all_users.append({
            "db": "app-forms",
            "username": "forms_demo",
            "portal_title": "🟢 Forms 14c Runtime Test",
            "role": "RUNTIME",
            "scope": "frmservlet",
            "wallet_alias": "",
            "color": "#4ade80",
            "login_url": f"http://localhost:{h_port}/forms/frmservlet?form=test.fmx"
        })
        if vnc_p:
            all_users.append({
                "db": "app-forms",
                "username": "developer",
                "portal_title": "🎨 Forms Builder GUI (noVNC)",
                "role": "BUILDER",
                "scope": "noVNC 6082",
                "wallet_alias": "",
                "color": "#38bdf8",
                "login_url": f"http://localhost:{vnc_p}/vnc.html"
            })

    if ide_p and ide_p.upper() != "NONE":
        i_cfg = load_yaml_profile(ide_p).get("web_ide", {}).get("ports", {})
        h_port = i_cfg.get("http_port", 8090)
        all_users.append({
            "db": "web-ide-dev",
            "username": "developer",
            "portal_title": "💻 VS Code Web IDE",
            "role": "DEVELOPER",
            "scope": "workstation",
            "wallet_alias": "",
            "color": "#c084fc",
            "login_url": f"http://localhost:{h_port}/?folder=/workspace"
        })

    if des_p and des_p.upper() != "NONE":
        d_cfg = load_yaml_profile(des_p)
        des_port = None
        for p in d_cfg.get("network", {}).get("ports", []):
            if p.get("container_port") == 6080 or "novnc" in str(p.get("description", "")).lower():
                des_port = str(p.get("host_port"))
                break
            elif not des_port and p.get("host_port"):
                des_port = str(p.get("host_port"))
        if not des_port:
            des_port = str(d_cfg.get("http_port") or d_cfg.get("port") or "6083")
        all_users.append({
            "db": "publisher-designer",
            "username": "designer",
            "portal_title": "🎨 BIP Template Designer GUI (noVNC)",
            "role": "DESIGNER",
            "scope": "desktop",
            "wallet_alias": "",
            "color": "#f472b6",
            "login_url": f"http://localhost:{des_port}/vnc.html"
        })


    # Generate diagrams in 6 languages
    diagrams = {}
    for lang in ["en", "et", "fi", "sv", "lv", "lt"]:
        diagrams[lang] = generate_active_blueprint_mermaid(b_num, dbs, env_v, lang)

    container_names = [c["name"] for c in components]
    container_ports = {c["name"]: c["host_ports"] for c in components}

    return {
        "env_vars": env_v,
        "dbs": dbs,
        "components": components,
        "container_names": container_names,
        "container_ports": container_ports,
        "users": all_users,
        "diagrams": diagrams
    }
