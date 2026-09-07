"""
Oracle DevOps Platform - Developer Hub (SPA) HTML Compiler
Compiles standalone dev-hub.html by aggregating database diagnostics,
YAML profiles, architecture diagrams, pure CSS/JS assets, and HTML layout.
"""
import os
import glob
import re
import json
from pathlib import Path
from datetime import datetime

from .catalog import DOC_SPECS, BP_CATALOG, SLIDES_CONTENT
from .topology import load_yaml_profile, generate_active_blueprint_mermaid
from .parser import parse_blueprint_env_and_metadata
from .diagnostics import (
    load_all_passwords,
    load_benchmarks_and_logs,
    get_ords_version,
    get_running_containers,
    get_live_modules,
    find_latest_log_for_blueprint,
)
from .cards import render_service_cards, render_wallet_table_rows

WORKSPACE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../.."))
ASSETS_DIR = os.path.join(os.path.dirname(__file__), "assets")

def build_dev_hub(output_file=None, workspace_dir=None):
    ws = workspace_dir or WORKSPACE_DIR
    target_out = output_file or os.path.join(ws, "docs/dev-hub.html")

    # 1. Load documentation files
    docs_data = []
    for spec in DOC_SPECS:
        contents = {}
        for lang, rel_f in spec["files"].items():
            fp = os.path.join(ws, rel_f)
            if not os.path.exists(fp):
                fp = os.path.join(ws, spec["rel"])
            c = ""
            if os.path.exists(fp):
                try:
                    with open(fp, "r", encoding="utf-8", errors="ignore") as f:
                        c = f.read()
                except Exception:
                    pass
            contents[lang] = c
        
        docs_data.append({
            "id": spec["id"],
            "rel": spec["rel"],
            "titles": spec["titles"],
            "contents": contents
        })

    # 2. Parse all 12 canonical blueprints (0..11)
    bp_files = sorted(glob.glob(os.path.join(ws, "config/blueprints/.env.*")))
    bp_list = []
    for bp_file in bp_files:
        b_base = os.path.basename(bp_file)
        m = re.search(r"\.env\.(\d+)", b_base)
        if m:
            b_num = int(m.group(1))
            info = BP_CATALOG.get(b_num)
            if info:
                cat = info["cat"]
                ram = info["ram"]
                conts = info["conts"]
                titles = {lang: info.get(lang, info["en"])[0] for lang in ["en", "et", "fi", "sv", "lv", "lt"]}
                descs = {lang: info.get(lang, info["en"])[1] for lang in ["en", "et", "fi", "sv", "lv", "lt"]}
            else:
                cat = "core"
                ram = "3-4 GB"
                conts = "Active Containers"
                title_def = f"Blueprint #{b_num}"
                desc_def = f"Architecture blueprint configuration #{b_num}."
                titles = {l: title_def for l in ["en", "et", "fi", "sv", "lv", "lt"]}
                descs = {l: desc_def for l in ["en", "et", "fi", "sv", "lv", "lt"]}

            bench_file = os.path.join(ws, "metrics", f"blueprint_{b_num}_benchmarks.json")
            bp_bench = None
            if os.path.isfile(bench_file):
                try:
                    with open(bench_file, "r", encoding="utf-8") as bf:
                        bp_bench = json.load(bf)
                except Exception:
                    pass
            
            latest_log_info = find_latest_log_for_blueprint(ws, b_num)
            latest_log = latest_log_info["file"] if latest_log_info else None

            details = parse_blueprint_env_and_metadata(bp_file, b_num)
            bp_list.append({
                "num": b_num,
                "file": b_base,
                "cat": cat,
                "ram": ram,
                "containers": conts,
                "testing": info.get("testing", False) if info else False,
                "titles": titles,
                "descs": descs,
                "components": details["components"],
                "container_names": details["container_names"],
                "container_ports": details["container_ports"],
                "env_vars": details["env_vars"],
                "users": details["users"],
                "diagrams": details["diagrams"],
                "benchmarks": bp_bench,
                "latest_log": latest_log,
                "latest_log_info": latest_log_info
            })

    bp_list.sort(key=lambda x: x["num"])

    # 3. Parse active blueprint and active environment
    active_bp_num = 0
    if os.environ.get("SELECTED_BLUEPRINT"):
        try: active_bp_num = int(os.environ["SELECTED_BLUEPRINT"])
        except ValueError: pass
    elif os.environ.get("ACTIVE_BLUEPRINT"):
        try: active_bp_num = int(os.environ["ACTIVE_BLUEPRINT"])
        except ValueError: pass
    elif os.environ.get("ACTIVE_BP_ID"):
        try: active_bp_num = int(os.environ["ACTIVE_BP_ID"])
        except ValueError: pass
    else:
        active_bp_file_path = os.path.join(ws, ".active_blueprint")
        if os.path.exists(active_bp_file_path):
            try:
                with open(active_bp_file_path, "r", encoding="utf-8") as f:
                    val = f.read().strip()
                    if val != "":
                        active_bp_num = int(val)
            except Exception:
                pass

    bp_matches = sorted(glob.glob(os.path.join(ws, f"config/blueprints/.env.{active_bp_num}-*")))
    if not bp_matches:
        bp_matches = sorted(glob.glob(os.path.join(ws, f"config/blueprints/.env.{active_bp_num}")))
    if not bp_matches:
        bp_matches = sorted(glob.glob(os.path.join(ws, "config/blueprints/.env.0-*")))

    active_bp_file = bp_matches[0] if bp_matches else None
    env_vars = {}
    if active_bp_file and os.path.exists(active_bp_file):
        with open(active_bp_file, "r", encoding="utf-8") as f:
            for line in f:
                line_str = line.strip()
                if not line_str or line_str.startswith("#"):
                    continue
                if "=" in line_str:
                    k, v = line_str.split("=", 1)
                    env_vars[k.strip()] = v.strip().strip('"\'')

    # Root .env overlay
    env_path = os.path.join(ws, ".env")
    if os.path.exists(env_path):
        with open(env_path, "r", encoding="utf-8") as f:
            for line in f:
                line_str = line.strip()
                if not line_str or line_str.startswith("#"):
                    m = re.search(r'(?:STSENAARIUM|BLUEPRINT|Blueprint|Scenario)\s*(\d+)', line_str, re.IGNORECASE)
                    if m: active_bp_num = int(m.group(1))
                    m2 = re.search(r'\.env\.(\d+)-', line_str)
                    if m2: active_bp_num = int(m2.group(1))
                    continue
                if "=" in line_str:
                    k, v = line_str.split("=", 1)
                    env_vars[k.strip()] = v.strip().strip('"\'')

    # 4. Resolve active databases
    # 4. Resolve active databases
    active_db_list = []
    db_keys = [k for k in env_vars.keys() if k.startswith("DB_") and k not in ["DB_ENABLED", "DB_USER", "DB_PASS", "DB_PASSWORD", "DB_REMOTE"]]
    priority_order = ["DB_PROXY", "DB_ALISE", "DB_PROXY_STANDALONE", "DB_GVENZL", "DB_ADB", "DB_PUBLISHER", "DB_FORMS"]
    sorted_db_keys = sorted(db_keys, key=lambda k: priority_order.index(k) if k in priority_order else 99)
    for db_k in sorted_db_keys:
        pval = env_vars.get(db_k, "")
        if not pval or pval.upper() == "NONE":
            continue
        p_data = load_yaml_profile(pval)
        db_cfg = p_data.get("database", {})
        def_c = db_k.lower().replace("_", "-")
        c_name = db_cfg.get("container_name") or (f"db-{pval}" if not pval.startswith("db-") else pval) or def_c
        c_short = c_name.replace("db-", "").replace("-", "_").upper()
        comp = p_data.get("database_features", p_data.get("components", {}))
        ords_conf = comp.get("ords", {})
        apex_conf = comp.get("apex", {})
        pool_name = ords_conf.get("pool_name", "")
        if not pool_name or pool_name == "default":
            if ords_conf.get("url_mapping"):
                m_path = ords_conf.get("url_mapping").strip("/").split("/")[-1]
                pool_name = m_path if m_path else c_name.replace("db-", "").replace("-", "_")
            else:
                pool_name = c_name.replace("db-", "").replace("-", "_")
        active_db_list.append({
            "key": db_k,
            "c_name": c_name,
            "short": c_short,
            "prof_name": pval,
            "profile": p_data,
            "pool_name": pool_name,
            "ords_enabled": str(ords_conf.get("enabled", "true")).lower() == "true",
            "apex_enabled": str(apex_conf.get("enabled", "false")).lower() == "true",
            "workspace": apex_conf.get("workspace", f"{c_short}_WORKSPACE"),
            "port": str(db_cfg.get("db_port", "1521")),
            "users": p_data.get("users", [])
        })

    # Fallback if MAIN_DB_PROFILE is specified and not NONE
    if not active_db_list and env_vars.get("MAIN_DB_PROFILE") and env_vars.get("MAIN_DB_PROFILE").upper() != "NONE":
        pval = env_vars.get("MAIN_DB_PROFILE")
        p_data = load_yaml_profile(pval)
        db_cfg = p_data.get("database", {})
        c_name = db_cfg.get("container_name") or (f"db-{pval}" if not pval.startswith("db-") else pval) or "db-proxy"
        c_short = c_name.replace("db-", "").replace("-", "_").upper()
        comp = p_data.get("database_features", p_data.get("components", {}))
        ords_conf = comp.get("ords", {})
        apex_conf = comp.get("apex", {})
        pool_name = ords_conf.get("pool_name", c_name.replace("db-", "").replace("-", "_"))
        active_db_list.append({
            "key": "MAIN_DB_PROFILE",
            "c_name": c_name,
            "short": c_short,
            "prof_name": pval,
            "profile": p_data,
            "pool_name": pool_name,
            "ords_enabled": str(ords_conf.get("enabled", "true")).lower() == "true",
            "apex_enabled": str(apex_conf.get("enabled", "false")).lower() == "true",
            "workspace": apex_conf.get("workspace", f"{c_short}_WORKSPACE"),
            "port": str(db_cfg.get("db_port", "1521")),
            "users": p_data.get("users", [])
        })

    # Fallback: check running DB containers if empty
    if not active_db_list:
        fallback_candidates = [
            ("db-proxy", "DB_PROXY", "db-proxy-oracle"),
            ("db-alise", "DB_ALISE", "db-alise-oracle"),
            ("db-proxy-standalone", "DB_PROXY_STANDALONE", "db-proxy-standalone"),
            ("db-gvenzl", "DB_GVENZL", "db-gvenzl"),
            ("db-adb", "DB_ADB", "db-adb"),
            ("db-publisher", "DB_PUBLISHER", "db-publisher-oracle"),
            ("db-forms", "DB_FORMS", "db-forms-oracle"),
        ]
        for def_c, def_k, def_prof in fallback_candidates:
            try:
                import subprocess
                res = subprocess.run(["podman", "container", "exists", def_c], capture_output=True)
                if res.returncode == 0:
                    p_data = load_yaml_profile(def_prof)
                    c_short = def_c.replace("db-", "").replace("-", "_").upper()
                    comp = p_data.get("database_features", p_data.get("components", {}))
                    ords_conf = comp.get("ords", {})
                    apex_conf = comp.get("apex", {})
                    pool_name = ords_conf.get("pool_name", def_c.replace("db-", "").replace("-", "_"))
                    active_db_list.append({
                        "key": def_k,
                        "c_name": def_c,
                        "short": c_short,
                        "prof_name": def_prof,
                        "profile": p_data,
                        "pool_name": pool_name,
                        "ords_enabled": str(ords_conf.get("enabled", "true")).lower() == "true",
                        "apex_enabled": str(apex_conf.get("enabled", "false")).lower() == "true",
                        "workspace": apex_conf.get("workspace", f"{c_short}_WORKSPACE"),
                        "port": str(p_data.get("database", {}).get("db_port", "1521")),
                        "users": p_data.get("users", [])
                    })
            except Exception:
                pass

    all_dbs_for_services = list(active_db_list)
    existing_cnames = {d["c_name"] for d in all_dbs_for_services}

    # Dynamically discover all database profiles from config/profiles/databases/
    db_profiles_dir = os.path.join(ws, "config/profiles/databases")
    if os.path.isdir(db_profiles_dir):
        for f in sorted(os.listdir(db_profiles_dir)):
            if f.endswith(".yaml"):
                prof_name = f[:-5]
                try:
                    p_data = load_yaml_profile(prof_name)
                    if not p_data:
                        continue
                    db_cfg = p_data.get("database", {})
                    c_name = db_cfg.get("container_name") or prof_name.replace("-oracle", "")
                    if not c_name.startswith("db-"):
                        c_name = "db-" + c_name
                    if c_name not in existing_cnames:
                        c_short = c_name.replace("db-", "").replace("-", "_").upper()
                        comp = p_data.get("database_features", p_data.get("components", {}))
                        ords_conf = comp.get("ords", {})
                        apex_conf = comp.get("apex", {})
                        pool_name = ords_conf.get("pool_name", c_name.replace("db-", "").replace("-", "_"))
                        def_k = f"DB_{c_short}"
                        all_dbs_for_services.append({
                            "key": def_k,
                            "c_name": c_name,
                            "short": c_short,
                            "prof_name": prof_name,
                            "profile": p_data,
                            "pool_name": pool_name,
                            "ords_enabled": str(ords_conf.get("enabled", "true")).lower() == "true",
                            "apex_enabled": str(apex_conf.get("enabled", "false")).lower() == "true",
                            "workspace": apex_conf.get("workspace", f"{c_short}_WORKSPACE"),
                            "port": str(db_cfg.get("db_port", "1521")),
                            "users": p_data.get("users", [])
                        })
                        existing_cnames.add(c_name)
                except Exception:
                    pass

    # 5. Live containers & modules status
    running_containers = get_running_containers()
    if not running_containers:
        running_containers = [d["c_name"] for d in active_db_list]
    live_modules = get_live_modules(running_containers)

    # 6. Active blueprint Mermaid diagram (6 languages)
    active_bp_mermaid_dict = {
        lang: generate_active_blueprint_mermaid(active_bp_num, active_db_list, env_vars, lang)
        for lang in ["en", "et", "fi", "sv", "lv", "lt"]
    }

    # 7. SEPS Wallet & Benchmarks
    passwords_map = load_all_passwords(ws, all_dbs_for_services)
    benchmarks_raw = load_benchmarks_and_logs(ws, active_bp_num)

    # 8. Render Dynamic HTML Elements
    ide_profile = env_vars.get("WEB_IDE_PROFILE", "web-ide-standard")
    designer_profile = env_vars.get("DESIGNER_PROFILE", "publisher-designer")
    pub_profile = env_vars.get("PUBLISHER_PROFILE", "publisher-standard")
    forms_profile = env_vars.get("FORMS_PROFILE", "forms-standard")
    services_cards_html = render_service_cards(
        bp_list, active_bp_num, running_containers, all_dbs_for_services, ide_profile, designer_profile
    )
    wallet_table_rows_html = render_wallet_table_rows(
        all_dbs_for_services, passwords_map, pub_profile, forms_profile, running_containers=running_containers
    )

    # 9. Read static assets
    def read_asset(fname):
        p = os.path.join(ASSETS_DIR, fname)
        with open(p, "r", encoding="utf-8") as f:
            return f.read()

    style_css = read_asset("style.css")
    app_js = read_asset("app.js")
    i18n_js = read_asset("i18n.js")
    diagrams_js = read_asset("diagrams.js")
    layout_tpl = read_asset("templates/layout.html")

    # 10. Assemble Standalone HTML
    replacements = {
        "%STYLE_CSS%": style_css,
        "%APP_JS%": app_js,
        "%I18N_JS%": i18n_js,
        "%DIAGRAMS_JS%": diagrams_js,
        "%ACTIVE_BP_NUM%": str(active_bp_num),
        "%SERVICES_CARDS_HTML%": services_cards_html,
        "%WALLET_TABLE_ROWS_HTML%": wallet_table_rows_html,
        "%DOCS_DATA_JSON%": json.dumps(docs_data, ensure_ascii=False),
        "%BLUEPRINTS_DATA_JSON%": json.dumps(bp_list, ensure_ascii=False),
        "%ACTIVE_BP_MERMAID_JSON%": json.dumps(active_bp_mermaid_dict),
        "%BENCHMARKS_DATA_JSON%": json.dumps(benchmarks_raw["setup"]),
        "%RESET_BENCHMARKS_DATA_JSON%": json.dumps(benchmarks_raw["reset"]),
        "%LOGS_DATA_JSON%": json.dumps(benchmarks_raw["logs"]),
        "%RUNNING_CONTAINERS_JSON%": json.dumps(list(running_containers)),
        "%LIVE_MODULES_JSON%": json.dumps(live_modules),
        "%SLIDES_CONTENT_JSON%": json.dumps(SLIDES_CONTENT),
        "%PASSWORDS_MAP_JSON%": json.dumps(passwords_map)
    }

    final_html = layout_tpl
    for token, val in replacements.items():
        final_html = final_html.replace(token, val)

    os.makedirs(os.path.dirname(target_out), exist_ok=True)
    with open(target_out, "w", encoding="utf-8") as f:
        f.write(final_html)

    print(f"✅ Developer Hub HTML generated to: {target_out}")
    return target_out

if __name__ == "__main__":
    build_dev_hub()
