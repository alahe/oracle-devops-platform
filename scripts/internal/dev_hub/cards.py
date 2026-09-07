"""
Oracle DevOps Platform - Developer Hub Dynamic Cards & Wallet Tables
Renders the 12 blueprint cards for Tab 1 and the SEPS Wallet credentials table.
"""
from .catalog import BP_COLOR_THEMES
from .topology import load_yaml_profile

def is_container_online(cn, running_containers):
    if running_containers is None:
        return True
    if cn.startswith("ords/"):
        return "app-ords" in running_containers
    if cn in running_containers:
        return True
    if cn == "app-publisher" and "oracle-publisher-dev" in running_containers:
        return True
    if cn == "oracle-publisher-dev" and "app-publisher" in running_containers:
        return True
    if cn in ["publisher-designer", "app-publisher-designer"] and any(x in running_containers for x in ["publisher-designer", "app-publisher-designer"]):
        return True
    if cn in ["forms-designer", "app-forms"] and any(x in running_containers for x in ["forms-designer", "app-forms"]):
        return True
    if cn in ["db-oracle", "db-proxy"] and any(x in running_containers for x in ["db-oracle", "db-proxy"]):
        return True
    return False


def render_service_cards(bp_list, active_bp_num, running_containers_initial, all_dbs_for_services, ide_profile, designer_profile):
    cards = []
    proxy_db = next((d for d in all_dbs_for_services if d.get("c_name") == "db-proxy"), None)
    proxy_port = proxy_db.get("port", "1532") if proxy_db else "1532"
    proxy_ws = proxy_db.get("workspace", "PROXY_WORKSPACE") if proxy_db else "PROXY_WORKSPACE"

    proxy_sa_db = next((d for d in all_dbs_for_services if d.get("c_name") == "db-proxy-standalone"), None)
    proxy_sa_ws = proxy_sa_db.get("workspace", "PROXY_STANDALONE_WORKSPACE") if proxy_sa_db else "PROXY_STANDALONE_WORKSPACE"

    alise_db = next((d for d in all_dbs_for_services if d.get("c_name") == "db-alise"), None)
    alise_port = alise_db.get("port", "1533") if alise_db else "1533"
    alise_ws = alise_db.get("workspace", "ALISE_WORKSPACE") if alise_db else "ALISE_WORKSPACE"

    ide_cfg = load_yaml_profile(ide_profile) if ide_profile != "NONE" else load_yaml_profile("web-ide-standard")
    ide_port = ide_cfg.get("web_ide", {}).get("ports", {}).get("http_port", "8090")

    designer_cfg = load_yaml_profile(designer_profile) if designer_profile != "NONE" else load_yaml_profile("publisher-designer")
    designer_port = designer_cfg.get("port", "6083")

    pub_cfg = load_yaml_profile("publisher-standard")
    pub_port = pub_cfg.get("publisher", {}).get("http_port", "9502")

    forms_cfg = load_yaml_profile("forms-standard")
    forms_runtime_port = forms_cfg.get("forms", {}).get("http_port", "9001")
    forms_vnc_port = forms_cfg.get("forms", {}).get("vnc_port", "6082")
    forms_wls_port = forms_cfg.get("forms", {}).get("admin_port", "7001")

    for b in bp_list:
        b_num = b["num"]
        b_cat = b.get("cat", "core")
        theme = BP_COLOR_THEMES.get(b_num, {"icon": "📦", "color": "#38bdf8", "border": "rgba(56,189,248,0.3)"})
        b_icon = theme["icon"]
        b_color = theme["color"]

        is_active = (b_num == active_bp_num)
        is_core = (b_num == 0)
        cnames = b.get("container_names", [])
        primary_c = cnames[0] if cnames else f"bp-{b_num}"

        # Check running status initially
        matched = 0
        container_chips = []
        if running_containers_initial is not None and cnames:
            for cn in cnames:
                cn_online = is_container_online(cn, running_containers_initial)
                if cn_online:
                    matched += 1
                chip_cls = "chip-online" if cn_online else "chip-offline"
                if cn.startswith("ords/"):
                    pname = cn.replace("ords/", "")
                    chip_title = f"ORDS Pool: {pname} ({'online' if cn_online else 'offline'})"
                    container_chips.append(f'<span class="container-chip {chip_cls} chip-ords" data-cname="{cn}" data-ords-pool="{pname}" title="{chip_title}"><span class="chip-dot"></span>🌐 {cn}</span>')
                else:
                    chip_title = f"{cn} (online)" if cn_online else f"{cn} (offline)"
                    container_chips.append(f'<span class="container-chip {chip_cls}" data-cname="{cn}" title="{chip_title}"><span class="chip-dot"></span>{cn}</span>')

            is_up = (matched == len(cnames))
            is_partial = (0 < matched < len(cnames))
            if b_num == 10:
                has_local_db = any(d in running_containers_initial for d in ["db-proxy", "db-alise", "db-proxy-standalone", "db-publisher", "db-forms", "db-gvenzl", "db-adb"])
                if has_local_db and b_num != active_bp_num:
                    is_up = False
                    is_partial = False
            elif b_num == 1 and not is_container_online("db-alise", running_containers_initial):
                is_up = False
                is_partial = False
            elif b_num == 2 and not is_container_online("db-proxy-standalone", running_containers_initial):
                is_up = False
                is_partial = False
            elif b_num == 3 and not is_container_online("db-gvenzl", running_containers_initial):
                is_up = False
                is_partial = False
            elif b_num == 4 and not is_container_online("db-adb", running_containers_initial) and b_num != active_bp_num:
                is_up = False
                is_partial = False
        else:
            is_up = False
            is_partial = False
            for cn in cnames:
                if cn.startswith("ords/"):
                    pname = cn.replace("ords/", "")
                    container_chips.append(f'<span class="container-chip chip-offline chip-ords" data-cname="{cn}" data-ords-pool="{pname}" title="ORDS Pool: {pname}"><span class="chip-dot"></span>🌐 {cn}</span>')
                else:
                    container_chips.append(f'<span class="container-chip chip-offline" data-cname="{cn}" title="{cn}"><span class="chip-dot"></span>{cn}</span>')

        if is_up:
            card_cls = ""
            status_cls = "status-online"
            status_txt = "Aktiivne"
            status_i18n = "status_online"
            sort_weight = 0
        elif is_partial:
            card_cls = "card-partial"
            status_cls = "status-partial"
            status_txt = f"Osaline ({matched}/{len(cnames)})"
            status_i18n = "status_partial"
            sort_weight = 1
        else:
            card_cls = "card-offline"
            status_cls = "status-offline"
            status_txt = "Seisatud"
            status_i18n = "status_offline"
            sort_weight = 2

        chips_html = f'<div class="card-containers-row">{"".join(container_chips)}</div>' if container_chips else ""

        # Resolve status URL for healthcheck
        status_url = ""
        if b_num == 0:
            status_url = "https://localhost:8448/ords/proxy/"
        elif b_num == 1:
            status_url = "https://localhost:8448/ords/alise/"
        elif b_num == 2:
            status_url = "https://localhost:8448/ords/proxy/"
        elif b_num == 3:
            status_url = "https://localhost:8448/ords/gvenzl/"
        elif b_num == 4:
            status_url = "https://localhost:8448/ords/alise/"
        elif b_num in [5, 11]:
            status_url = f"http://localhost:{pub_port}/xmlpserver"
        elif b_num == 6:
            status_url = f"http://localhost:{forms_runtime_port}/forms/frmservlet?form=test.fmx"
        elif b_num == 7:
            status_url = "http://localhost:9001/forms/frmservlet?form=test.fmx"
        elif b_num == 8:
            status_url = f"http://localhost:{ide_port}"
        elif b_num == 9:
            status_url = f"http://localhost:{designer_port}/vnc.html"
        elif b_num == 10:
            status_url = "https://localhost:8448/ords/_/landing"
        else:
            status_url = "https://localhost:8448/ords/"

        # Titles & Descriptions
        t_en = b.get("titles", {}).get("en", f"Blueprint #{b_num}")
        t_et = b.get("titles", {}).get("et", t_en)
        d_en = b.get("descs", {}).get("en", "")
        d_et = b.get("descs", {}).get("et", d_en)
        conts_str = b.get("containers", ", ".join(cnames))
        cnames_str = ",".join(cnames)

        # Endpoints HTML (1-Click Launch with credentials and prefilled username)
        ep_links = []
        if b_num == 0:
            ep_links.append(f'<a href="https://localhost:8448/ords/proxy/r/apex/workspace-sign-in/oracle-apex-sign-in?f4550_p1_company={proxy_ws}&f4550_p1_username=DEV" target="_blank" class="btn-endpoint" onclick="openServiceWithCredentials(\'https://localhost:8448/ords/proxy/r/apex/workspace-sign-in/oracle-apex-sign-in?f4550_p1_company={proxy_ws}&f4550_p1_username=DEV\', \'DB_PROXY_DEV\', \'DEV\', event)" title="Developer Workspace ({proxy_ws})">🛠️ APEX Workspace (DEV) ↗</a>')
            ep_links.append('<a href="https://localhost:8448/ords/proxy/r/apex/workspace-sign-in/administration-sign-in?p10_username=ADMIN" target="_blank" class="btn-endpoint" onclick="openServiceWithCredentials(\'https://localhost:8448/ords/proxy/r/apex/workspace-sign-in/administration-sign-in?p10_username=ADMIN\', \'DB_PROXY_APEX_ADMIN\', \'ADMIN\', event)" title="Instance Admin">⚙️ APEX Admin (ADMIN) ↗</a>')
            ep_links.append('<a href="https://localhost:8448/ords/proxy/user_developer/sign-in?username=USER_DEVELOPER&r=_sdw" target="_blank" class="btn-endpoint" onclick="openServiceWithCredentials(\'https://localhost:8448/ords/proxy/user_developer/sign-in?username=USER_DEVELOPER&r=_sdw\', \'DB_PROXY_DEV\', \'USER_DEVELOPER\', event)" data-i18n-title="tip_db_actions_wait" title="Database Actions (warmup ~1 min)">📊 DB Actions (DEV) ↗</a>')
            ep_links.append('<a href="https://localhost:8448/ords/proxy/dba_admin/sign-in?username=DBA_ADMIN&r=_sdw" target="_blank" class="btn-endpoint" onclick="openServiceWithCredentials(\'https://localhost:8448/ords/proxy/dba_admin/sign-in?username=DBA_ADMIN&r=_sdw\', \'DB_PROXY_DBA_ADMIN\', \'DBA_ADMIN\', event)" data-i18n-title="tip_db_actions_wait" title="Database Actions (warmup ~1 min)">📊 DB Actions (DBA_ADMIN) ↗</a>')
            ep_links.append('<a href="https://localhost:8448/ords/proxy/" target="_blank" class="btn-endpoint" title="ORDS Landing for Proxy">🌐 ORDS (proxy) ↗</a>')
        elif b_num in [1, 3, 4]:
            ep_links.append(f'<a href="https://localhost:8448/ords/alise/r/apex/workspace-sign-in/oracle-apex-sign-in?f4550_p1_company={alise_ws}&f4550_p1_username=DEV" target="_blank" class="btn-endpoint" onclick="openServiceWithCredentials(\'https://localhost:8448/ords/alise/r/apex/workspace-sign-in/oracle-apex-sign-in?f4550_p1_company={alise_ws}&f4550_p1_username=DEV\', \'DB_ALISE_DEV\', \'DEV\', event)" title="Developer Workspace ({alise_ws})">🛠️ APEX Workspace (DEV) ↗</a>')
            ep_links.append('<a href="https://localhost:8448/ords/alise/r/apex/workspace-sign-in/administration-sign-in?p10_username=ADMIN" target="_blank" class="btn-endpoint" onclick="openServiceWithCredentials(\'https://localhost:8448/ords/alise/r/apex/workspace-sign-in/administration-sign-in?p10_username=ADMIN\', \'DB_ALISE_APEX_ADMIN\', \'ADMIN\', event)" title="Instance Admin">⚙️ APEX Admin (ADMIN) ↗</a>')
            ep_links.append('<a href="https://localhost:8448/ords/alise/user_developer/sign-in?username=USER_DEVELOPER&r=_sdw" target="_blank" class="btn-endpoint" onclick="openServiceWithCredentials(\'https://localhost:8448/ords/alise/user_developer/sign-in?username=USER_DEVELOPER&r=_sdw\', \'DB_ALISE_DEV\', \'USER_DEVELOPER\', event)" data-i18n-title="tip_db_actions_wait" title="Database Actions (warmup ~1 min)">📊 DB Actions (DEV) ↗</a>')
            ep_links.append('<a href="https://localhost:8448/ords/alise/dba_admin/sign-in?username=DBA_ADMIN&r=_sdw" target="_blank" class="btn-endpoint" onclick="openServiceWithCredentials(\'https://localhost:8448/ords/alise/dba_admin/sign-in?username=DBA_ADMIN&r=_sdw\', \'DB_ALISE_DBA_ADMIN\', \'DBA_ADMIN\', event)" data-i18n-title="tip_db_actions_wait" title="Database Actions (warmup ~1 min)">📊 DB Actions (DBA_ADMIN) ↗</a>')
            ep_links.append('<a href="https://localhost:8448/ords/alise/" target="_blank" class="btn-endpoint" title="ORDS Landing for Alise">🌐 ORDS (alise) ↗</a>')
        elif b_num == 2:
            ep_links.append(f'<a href="https://localhost:8448/ords/proxy_standalone/r/apex/workspace-sign-in/oracle-apex-sign-in?f4550_p1_company={proxy_sa_ws}&f4550_p1_username=USER_DEVELOPER" target="_blank" class="btn-endpoint" onclick="openServiceWithCredentials(\'https://localhost:8448/ords/proxy_standalone/r/apex/workspace-sign-in/oracle-apex-sign-in?f4550_p1_company={proxy_sa_ws}&f4550_p1_username=USER_DEVELOPER\', \'DB_PROXY_STANDALONE_DEV\', \'USER_DEVELOPER\', event)" title="SSO Workspace">🛠️ APEX Workspace (DEV) ↗</a>')
            ep_links.append('<a href="https://localhost:8448/ords/proxy_standalone/r/apex/workspace-sign-in/administration-sign-in?p10_username=ADMIN" target="_blank" class="btn-endpoint" onclick="openServiceWithCredentials(\'https://localhost:8448/ords/proxy_standalone/r/apex/workspace-sign-in/administration-sign-in?p10_username=ADMIN\', \'DB_PROXY_STANDALONE_APEX_ADMIN\', \'ADMIN\', event)" title="Instance Admin">⚙️ APEX Admin (ADMIN) ↗</a>')
            ep_links.append('<a href="https://localhost:8448/ords/proxy_standalone/user_developer/sign-in?username=USER_DEVELOPER&r=_sdw" target="_blank" class="btn-endpoint" onclick="openServiceWithCredentials(\'https://localhost:8448/ords/proxy_standalone/user_developer/sign-in?username=USER_DEVELOPER&r=_sdw\', \'DB_PROXY_STANDALONE_DEV\', \'USER_DEVELOPER\', event)" data-i18n-title="tip_db_actions_wait" title="Database Actions (warmup ~1 min)">📊 DB Actions (DEV) ↗</a>')
            ep_links.append('<a href="https://localhost:8448/ords/proxy_standalone/dba_admin/sign-in?username=DBA_ADMIN&r=_sdw" target="_blank" class="btn-endpoint" onclick="openServiceWithCredentials(\'https://localhost:8448/ords/proxy_standalone/dba_admin/sign-in?username=DBA_ADMIN&r=_sdw\', \'DB_PROXY_STANDALONE_DBA_ADMIN\', \'DBA_ADMIN\', event)" data-i18n-title="tip_db_actions_wait" title="Database Actions (warmup ~1 min)">📊 DB Actions (DBA_ADMIN) ↗</a>')
            ep_links.append('<a href="https://localhost:8448/ords/proxy_standalone/" target="_blank" class="btn-endpoint" title="SSO REST Gateway">🌐 ORDS (proxy_standalone) ↗</a>')
        elif b_num == 5:
            ep_links.append(f'<a href="http://localhost:{pub_port}/xmlpserver" target="_blank" class="btn-endpoint" onclick="openServiceWithCredentials(\'http://localhost:{pub_port}/xmlpserver\', \'DB_PUBLISHER_SYS\', \'Administrator\', event)" style="border-color:rgba(251,146,60,0.5); color:#fb923c;">📑 Open Analytics Publisher (BIP) ↗</a>')
            ep_links.append(f'<a href="http://localhost:{pub_port}/console" target="_blank" class="btn-endpoint" onclick="openServiceWithCredentials(\'http://localhost:{pub_port}/console\', \'DB_PUBLISHER_SYS\', \'weblogic\', event)" style="color:#fbbf24;">⚙️ WebLogic Admin Console ↗</a>')
        elif b_num == 6:
            ep_links.append(f'<a href="http://localhost:{forms_runtime_port}/forms/frmservlet?form=test.fmx" target="_blank" class="btn-endpoint" style="color:#4ade80;">🟢 Forms Test Form ↗</a>')
            ep_links.append(f'<a href="http://localhost:{forms_vnc_port}/vnc.html" target="_blank" class="btn-endpoint" style="color:#38bdf8;">🎨 Forms Builder GUI (noVNC) ↗</a>')
            ep_links.append(f'<a href="http://localhost:{forms_wls_port}/console" target="_blank" class="btn-endpoint" onclick="openServiceWithCredentials(\'http://localhost:{forms_wls_port}/console\', \'DB_FORMS_SYS\', \'weblogic\', event)" style="color:#fbbf24;">⚙️ WebLogic Console ↗</a>')
        elif b_num == 7:
            ep_links.append('<a href="http://localhost:9502/xmlpserver" target="_blank" class="btn-endpoint" onclick="openServiceWithCredentials(\'http://localhost:9502/xmlpserver\', \'DB_PUBLISHER_SYS\', \'Administrator\', event)" style="color:#fb923c;">📑 Analytics Publisher ↗</a>')
            ep_links.append('<a href="http://localhost:9001/forms/frmservlet?form=test.fmx" target="_blank" class="btn-endpoint" style="color:#4ade80;">🟢 Forms Test Form ↗</a>')
            ep_links.append('<a href="http://localhost:6082/vnc.html" target="_blank" class="btn-endpoint" style="color:#38bdf8;">🎨 Forms Builder GUI ↗</a>')
            ep_links.append('<a href="http://localhost:7001/console" target="_blank" class="btn-endpoint" onclick="openServiceWithCredentials(\'http://localhost:7001/console\', \'DB_FORMS_SYS\', \'weblogic\', event)" style="color:#fbbf24;">⚙️ Unified WLS Console ↗</a>')
        elif b_num == 8:
            ep_links.append(f'<a href="http://localhost:{ide_port}/?folder=/workspace" target="_blank" class="btn-endpoint" style="border-color:rgba(192,132,252,0.5); color:#c084fc;">💻 Open VS Code Web IDE ↗</a>')
        elif b_num == 9:
            ep_links.append(f'<a href="http://localhost:{designer_port}/vnc.html" target="_blank" class="btn-endpoint" style="border-color:rgba(244,114,182,0.5); color:#f472b6;">🎨 Open Template Designer GUI ↗</a>')
        elif b_num == 10:
            ep_links.append('<a href="https://localhost:8448/ords/_/landing" target="_blank" class="btn-endpoint" style="color:#06b6d4;">🔗 Central ORDS Landing ↗</a>')
            ep_links.append('<a href="https://localhost:8448/ords/" target="_blank" class="btn-endpoint">🌐 Remote Routing Edge ↗</a>')
        elif b_num == 11:
            ep_links.append(f'<a href="http://localhost:{pub_port}/xmlpserver" target="_blank" class="btn-endpoint" onclick="openServiceWithCredentials(\'http://localhost:{pub_port}/xmlpserver\', \'DB_PUBLISHER_SYS\', \'Administrator\', event)" style="color:#fb923c;">📑 Open Analytics Publisher (BIP) ↗</a>')
            ep_links.append(f'<a href="http://localhost:{pub_port}/console" target="_blank" class="btn-endpoint" onclick="openServiceWithCredentials(\'http://localhost:{pub_port}/console\', \'DB_PUBLISHER_SYS\', \'weblogic\', event)" style="color:#fbbf24;">⚙️ WebLogic Admin Console ↗</a>')

        # Actions: Single Unified Action Button ("⚡ Käivitused & Haldus") + Icon Copy Button
        copy_tip = "tip_copy_stop_cmd" if is_up and b_num > 0 else "tip_copy_deploy_cmd"
        copy_title = "Kopeeri peatamiskäsk" if is_up and b_num > 0 else "Kopeeri juurutamiskäsk"
        action_main_html = f'<button type="button" class="btn btn-primary btn-action-main btn-service-switch" onclick="openBlueprintModal({b_num}, \'ops\')"><span>⚡</span> <span data-i18n="btn_manage_ops">Käivitused & Haldus</span></button>'
        action_btns_html = f"""
            {action_main_html}
            <button type="button" class="btn btn-secondary btn-icon btn-bp-copy" onclick="handleCopyBpCmd({b_num}, this)" data-i18n-title="{copy_tip}" title="{copy_title}"><span>📋</span></button>
        """
        testing_badge_html = ""
        if b.get("testing", False) or b_num in [8, 9, 10, 11]:
            testing_badge_html = '<span class="status-pill" style="background: rgba(245, 158, 11, 0.15); color: #f59e0b; border: 1px solid rgba(245, 158, 11, 0.35); font-size: 0.74rem; font-weight: 600;" title="Konteiner käivitub, kuid funktsionaalsus on aktiivsel testimisel ja täiustamisel"><span class="status-dot" style="background:#f59e0b;"></span><span class="status-text" data-i18n="badge_testing_refinement">⚠️ Testimisel / Täiustamisel</span></span>'

        card_html = f"""            <!-- Blueprint #{b_num}: {t_en} -->
                <div class=\"card {card_cls}\" data-container=\"{primary_c}\" data-cnames=\"{cnames_str}\" data-bp=\"{b_num}\" data-cat=\"{b_cat}\" style=\"border-color: {theme['border']};\">
                    <div class=\"card-top\">
                        <div class=\"card-header-flex\">
                            <div style=\"display:flex; align-items:center; gap:10px;\">
                                <span style=\"font-size:1.4rem;\">{b_icon}</span>
                                <h3 style=\"margin:0;\" data-bp-title=\"{b_num}\">#{b_num} {t_et}</h3>
                            </div>
                            <div style=\"display:flex; align-items:center; gap:6px; flex-wrap:wrap;\">
                                {testing_badge_html}
                                <span class=\"status-pill {status_cls}\" data-status-url=\"{status_url}\">
                                    <span class=\"status-dot\"></span>
                                    <span class=\"status-text\" data-i18n=\"{status_i18n}\">{status_txt}</span>
                                </span>
                            </div>
                        </div>
                        <p class=\"card-desc\" data-bp-desc=\"{b_num}\">{d_et}</p>
                        {chips_html}
                        <div class=\"card-meta\">
                            <span>⚡ RAM: <code>{b.get('ram', '2-3 GB')}</code> &nbsp;|&nbsp; 🔑 <span data-i18n=\"meta_accounts\">Kontosid</span>: <code>{len(b.get('users', []))}</code></span>
                            <div style=\"display:flex; align-items:center; gap:8px;\">
                                <a href=\"javascript:void(0)\" onclick=\"openBlueprintModal({b_num}, 'arch')\" class=\"card-meta-link\" style=\"font-size:0.8rem; color:#38bdf8; display:inline-flex; align-items:center; gap:3px;\" title=\"Vaata arhitektuuri ja topoloogiat\"><span>📐</span> <span data-i18n=\"modal_tab_arch\">Arhitektuur</span> ↗</a>
                                <span style=\"color:#475569; font-size:0.8rem;\">|</span>
                                <a href=\"javascript:void(0)\" onclick=\"openBlueprintModal({b_num}, 'ops')\" class=\"card-meta-link\" style=\"font-size:0.8rem; color:#c084fc; display:inline-flex; align-items:center; gap:3px;\" title=\"Vaata käivitusi ja haldust\"><span>⚡</span> <span data-i18n=\"modal_tab_ops\">Haldus</span> ↗</a>
                            </div>
                        </div>
                        <div class=\"card-endpoints-flex\">{''.join(ep_links)}</div>
                    </div>
                    <div class=\"card-action-flex\">
                        {action_btns_html}
                    </div>
                </div>"""
        cards.append((sort_weight, b_num, card_html))

    # Active cards are always at the front
    cards.sort(key=lambda x: (x[0], x[1]))
    return "\n".join(x[2] for x in cards)


def get_user_desc_key(u_name, u_role, u_alias):
    u_upper = u_name.upper()
    if u_role == "SYSDBA" or u_upper == "SYS":
        return "desc_u_sys"
    elif u_role == "DBA" or "DBA" in u_alias or "DBA" in u_upper:
        return "desc_u_dba"
    elif "DEV" in u_alias or u_upper in ["DEV", "USER_DEVELOPER"]:
        return "desc_u_dev"
    elif "APP" in u_alias or "APP" in u_upper:
        return "desc_u_app"
    elif "VIEWER" in u_alias or "VIEWER" in u_upper or u_role == "VIEWER":
        return "desc_u_viewer"
    return "desc_u_generic"


def render_wallet_table_rows(all_dbs_for_services, passwords_map=None, pub_profile="publisher-standard", forms_profile="forms-standard", forms_wls_port="7001", pub_port="9502", running_containers=None):
    passwords_map = passwords_map or {}
    table_rows = []
    for db_info in all_dbs_for_services:
        c_name = db_info["c_name"]
        c_short = db_info["short"]
        p_name = db_info["pool_name"]
        ws_name = db_info.get("workspace", f"{c_short}_WORKSPACE")
        db_port = db_info["port"]
        users = db_info["users"]
        is_up = is_container_online(c_name, running_containers)
        status_badge = '<span class="badge badge-success" style="font-size:0.75rem; padding:3px 8px;">🟢 <span data-i18n="status_online">Töös</span></span>' if is_up else '<span class="badge badge-danger" style="font-size:0.75rem; padding:3px 8px; background:rgba(239,68,68,0.2); color:#f87171; border:1px solid rgba(239,68,68,0.4);">🔴 <span data-i18n="status_offline">Maas</span></span>'

        if db_info.get("apex_enabled", True):
            admin_alias = f"DB_{c_short}_APEX_ADMIN"
            admin_url = f"https://localhost:8448/ords/{p_name}/apex_admin"
            table_rows.append(f"""                    <tr id=\"row-{admin_alias}\" data-cname=\"{c_name}\">
                            <td><strong>⚙️ APEX Instance Admin</strong><br/><span style=\"font-size:0.75rem; color:#64748b;\">{c_name} (Port {db_port})</span></td>
                            <td class=\"wallet-status-cell\" data-cname=\"{c_name}\">{status_badge}</td>
                            <td>
                                <span style=\"background:rgba(245,158,11,0.18); color:#f59e0b; padding:3px 8px; border-radius:4px; font-weight:700; font-size:0.95rem; cursor:pointer; display:inline-block; margin-bottom:2px;\" onclick=\"copyUsername('ADMIN', this)\" data-i18n-title=\"tip_copy_user\" title=\"Click to copy username to clipboard\">ADMIN</span><br/>
                                <span style=\"font-size:0.75rem; color:#94a3b8;\" data-i18n=\"desc_u_apex_admin\">APEX Platform Administrator</span>
                            </td>
                            <td><span style=\"background:rgba(56,189,248,0.15); color:#38bdf8; padding:3px 8px; border-radius:4px; font-weight:600; font-size:0.85rem; cursor:pointer;\" onclick=\"copyUsername('INTERNAL', this)\" data-i18n-title=\"tip_copy_ws\" title=\"Click to copy workspace name to clipboard\">INTERNAL</span> <span style=\"font-size:0.75rem; color:#94a3b8;\">(Workspace)</span></td>
                            <td><code style=\"color:#22c55e; cursor:pointer;\" onclick=\"copyBadge(this, '{admin_alias}')\" title=\"Click to copy alias\">{admin_alias}</code></td>
                            <td>
                                <div style=\"display:flex; gap:4px; flex-wrap:wrap; align-items:center;\">
                                    <button class=\"btn btn-sm btn-primary\" style=\"padding: 4px 8px; font-size: 0.75rem;\" onclick=\"openServiceWithCredentials('{admin_url}', '{admin_alias}', 'ADMIN', event)\" data-i18n-title=\"tip_open_service\" title=\"Opens portal & copies password to clipboard\"><span>🚀</span> <span data-i18n=\"btn_launch_apex\">APEX</span></button>
                                    <button class=\"copy-btn\" style=\"position:static; padding: 4px 8px; font-size: 0.75rem;\" onclick=\"copyBadge(this, 'sql /@{admin_alias}')\" title=\"Copy passwordless SQLcl connection\"><span>💻</span> <code>sql /@{admin_alias}</code></button>
                                    <button class=\"copy-btn\" style=\"position:static; padding: 4px 8px; font-size: 0.75rem;\" onclick=\"handleCopyPassword('{admin_alias}', this)\" data-i18n-title=\"tip_copy_pwd\" title=\"Copy password to clipboard\">📋 <span data-i18n=\"btn_copy_pwd\">Parool</span></button>
                                </div>
                            </td>
                        </tr>""")

        for u in users:
            u_name = u.get("username", "")
            u_role = u.get("role", "NORMAL")
            u_alias = u.get("wallet_alias", f"DB_{c_short}_{u_name}")
            u_color = u.get("color", "#38bdf8")
            desc_k = get_user_desc_key(u_name, u_role, u_alias)

            svc_desc = f"🗄️ {c_name} User"
            is_dev = ("DEV" in u_alias or u_name.upper() in ["DEV", "USER_DEVELOPER"])
            is_dba = (u_role == "DBA" or "DBA" in u_alias or "DBA" in u_name.upper())
            is_sysdba = (u_role == "SYSDBA" or u_name.upper() == "SYS")

            if is_sysdba:
                svc_desc = f"🔴 Database SYSDBA ({c_name})"
            elif is_dba:
                svc_desc = f"🔵 Database Administrator ({c_name})"
            elif is_dev:
                svc_desc = f"🛠️ Developer & DB Actions ({c_name})"

            scope_badge = f"""<span style=\"background:rgba(148,163,184,0.15); color:#cbd5e1; padding:3px 8px; border-radius:4px; font-weight:600; font-size:0.85rem;\">{u_role}</span>"""
            if is_dev:
                scope_badge = f"""<span style=\"background:rgba(56,189,248,0.15); color:#38bdf8; padding:3px 8px; border-radius:4px; font-weight:600; font-size:0.85rem; cursor:pointer;\" onclick=\"copyUsername('{ws_name}', this)\" data-i18n-title=\"tip_copy_ws\" title=\"Click to copy workspace name to clipboard\">{ws_name}</span> <span style=\"font-size:0.75rem; color:#94a3b8;\">({u_role})</span>"""

            btn_list = []
            if is_dev:
                apex_url = f"https://localhost:8448/ords/{p_name}/r/apex/workspace-sign-in/oracle-apex-sign-in?f4550_p1_company={ws_name}&f4550_p1_username={u_name}"
                sdw_url = f"https://localhost:8448/ords/{p_name}/user_developer/sign-in?username={u_name}&r=_sdw"
                btn_list.append(f"""<button class=\"btn btn-sm btn-primary\" style=\"padding: 4px 8px; font-size: 0.75rem;\" onclick=\"openServiceWithCredentials('{apex_url}', '{u_alias}', '{u_name}', event)\" data-i18n-title=\"tip_open_service\" title=\"Opens APEX Builder & copies password\"><span>🚀</span> <span data-i18n=\"btn_launch_apex\">APEX</span></button>""")
                btn_list.append(f"""<button class=\"btn btn-sm btn-secondary\" style=\"padding: 4px 8px; font-size: 0.75rem; color:#38bdf8; border-color:rgba(56,189,248,0.3);\" onclick=\"openServiceWithCredentials('{sdw_url}', '{u_alias}', '{u_name}', event)\" data-i18n-title=\"tip_db_actions_wait\" title=\"Database Actions (warmup ~1 min)\"><span>📊</span> <span data-i18n=\"btn_launch_sdw\">DB Actions</span></button>""")
            elif is_dba:
                sdw_url = f"https://localhost:8448/ords/{p_name}/dba_admin/sign-in?username={u_name}&r=_sdw"
                btn_list.append(f"""<button class=\"btn btn-sm btn-secondary\" style=\"padding: 4px 8px; font-size: 0.75rem; color:#38bdf8; border-color:rgba(56,189,248,0.3);\" onclick=\"openServiceWithCredentials('{sdw_url}', '{u_alias}', '{u_name}', event)\" data-i18n-title=\"tip_db_actions_wait\" title=\"Database Actions (warmup ~1 min)\"><span>📊</span> <span data-i18n=\"btn_launch_sdw\">DB Actions</span></button>""")

            btn_list.append(f"""<button class=\"copy-btn\" style=\"position:static; padding: 4px 8px; font-size: 0.75rem;\" onclick=\"copyBadge(this, 'sql /@{u_alias}')\" title=\"Copy passwordless SQLcl connection\"><span>💻</span> <code>sql /@{u_alias}</code></button>""")
            btn_list.append(f"""<button class=\"copy-btn\" style=\"position:static; padding: 4px 8px; font-size: 0.75rem;\" onclick=\"handleCopyPassword('{u_alias}', this)\" data-i18n-title=\"tip_copy_pwd\" title=\"Copy password to clipboard\">📋 <span data-i18n=\"btn_copy_pwd\">Parool</span></button>""")

            actions_html = f'<div style=\"display:flex; gap:4px; flex-wrap:wrap; align-items:center;\">{"".join(btn_list)}</div>'

            table_rows.append(f"""                    <tr id=\"row-{u_alias}\" data-cname=\"{c_name}\">
                            <td><strong>{svc_desc}</strong><br/><span style=\"font-size:0.75rem; color:#64748b;\">{c_name} (Port {db_port})</span></td>
                            <td class=\"wallet-status-cell\" data-cname=\"{c_name}\">{status_badge}</td>
                            <td>
                                <span style=\"background:rgba(56,189,248,0.18); color:{u_color}; padding:3px 8px; border-radius:4px; font-weight:700; font-size:0.95rem; cursor:pointer; display:inline-block; margin-bottom:2px;\" onclick=\"copyUsername('{u_name}', this)\" data-i18n-title=\"tip_copy_user\" title=\"Click to copy username to clipboard\">{u_name}</span><br/>
                                <span style=\"font-size:0.75rem; color:#94a3b8;\" data-i18n=\"{desc_k}\">User Account</span>
                            </td>
                            <td>{scope_badge}</td>
                            <td><code style=\"color:#22c55e; cursor:pointer;\" onclick=\"copyBadge(this, '{u_alias}')\" title=\"Click to copy alias\">{u_alias}</code></td>
                            <td>
                                {actions_html}
                            </td>
                        </tr>""")

    # System credentials for Middleware services if configured/present
    if "DB_PUBLISHER_SYS" in passwords_map or pub_profile != "NONE":
        pub_alias = "DB_PUBLISHER_SYS"
        pub_url = f"http://localhost:{pub_port}/xmlpserver"
        is_pub_up = is_container_online("app-publisher", running_containers)
        pub_status_badge = '<span class="badge badge-success" style="font-size:0.75rem; padding:3px 8px;">🟢 <span data-i18n="status_online">Töös</span></span>' if is_pub_up else '<span class="badge badge-danger" style="font-size:0.75rem; padding:3px 8px; background:rgba(239,68,68,0.2); color:#f87171; border:1px solid rgba(239,68,68,0.4);">🔴 <span data-i18n="status_offline">Maas</span></span>'
        table_rows.append(f"""                    <tr id=\"row-{pub_alias}\" data-cname=\"app-publisher\">
                            <td><strong>📑 Analytics Publisher Admin</strong><br/><span style=\"font-size:0.75rem; color:#64748b;\">app-publisher (Port {pub_port})</span></td>
                            <td class=\"wallet-status-cell\" data-cname=\"app-publisher\">{pub_status_badge}</td>
                            <td>
                                <span style=\"background:rgba(251,146,60,0.18); color:#fb923c; padding:3px 8px; border-radius:4px; font-weight:700; font-size:0.95rem; cursor:pointer; display:inline-block; margin-bottom:2px;\" onclick=\"copyUsername('weblogic', this)\" data-i18n-title=\"tip_copy_user\" title=\"Click to copy username\">weblogic</span><br/>
                                <span style=\"font-size:0.75rem; color:#94a3b8;\">Publisher Superuser</span>
                            </td>
                            <td><span style=\"background:rgba(251,146,60,0.15); color:#fb923c; padding:3px 8px; border-radius:4px; font-weight:600; font-size:0.85rem;\">WLS_ADMIN</span></td>
                            <td><code style=\"color:#22c55e; cursor:pointer;\" onclick=\"copyBadge(this, '{pub_alias}')\" title=\"Click to copy alias\">{pub_alias}</code></td>
                            <td>
                                <button class=\"btn btn-sm btn-primary\" style=\"padding: 4px 8px; font-size: 0.75rem; margin-right: 4px;\" onclick=\"openServiceWithCredentials('{pub_url}', '{pub_alias}', 'weblogic', event)\" data-i18n-title=\"tip_open_service\" title=\"Opens portal & copies password to clipboard\"><span>🚀</span> <span data-i18n=\"btn_launch_copy\">Launch & Copy</span></button>
                                <button class=\"copy-btn\" style=\"position:static; padding: 4px 8px; font-size: 0.75rem;\" onclick=\"handleCopyPassword('{pub_alias}', this)\" data-i18n-title=\"tip_copy_pwd\" title=\"Copy password to clipboard\">📋 <span data-i18n=\"btn_copy_pwd\">Password</span></button>
                            </td>
                        </tr>""")

    if "DB_FORMS_SYS" in passwords_map or forms_profile != "NONE":
        forms_alias = "DB_FORMS_SYS"
        forms_url = f"http://localhost:{forms_wls_port}/console"
        is_forms_up = is_container_online("app-forms", running_containers)
        forms_status_badge = '<span class="badge badge-success" style="font-size:0.75rem; padding:3px 8px;">🟢 <span data-i18n="status_online">Töös</span></span>' if is_forms_up else '<span class="badge badge-danger" style="font-size:0.75rem; padding:3px 8px; background:rgba(239,68,68,0.2); color:#f87171; border:1px solid rgba(239,68,68,0.4);">🔴 <span data-i18n="status_offline">Maas</span></span>'
        table_rows.append(f"""                    <tr id=\"row-{forms_alias}\" data-cname=\"app-forms\">
                            <td><strong>⚙️ WebLogic Admin (Forms / WLS)</strong><br/><span style=\"font-size:0.75rem; color:#64748b;\">app-forms (Port {forms_wls_port})</span></td>
                            <td class=\"wallet-status-cell\" data-cname=\"app-forms\">{forms_status_badge}</td>
                            <td>
                                <span style=\"background:rgba(74,222,128,0.18); color:#4ade80; padding:3px 8px; border-radius:4px; font-weight:700; font-size:0.95rem; cursor:pointer; display:inline-block; margin-bottom:2px;\" onclick=\"copyUsername('weblogic', this)\" data-i18n-title=\"tip_copy_user\" title=\"Click to copy username\">weblogic</span><br/>
                                <span style=\"font-size:0.75rem; color:#94a3b8;\">Domain Administrator</span>
                            </td>
                            <td><span style=\"background:rgba(74,222,128,0.15); color:#4ade80; padding:3px 8px; border-radius:4px; font-weight:600; font-size:0.85rem;\">WLS_ADMIN</span></td>
                            <td><code style=\"color:#22c55e; cursor:pointer;\" onclick=\"copyBadge(this, '{forms_alias}')\" title=\"Click to copy alias\">{forms_alias}</code></td>
                            <td>
                                <button class=\"btn btn-sm btn-primary\" style=\"padding: 4px 8px; font-size: 0.75rem; margin-right: 4px;\" onclick=\"openServiceWithCredentials('{forms_url}', '{forms_alias}', 'weblogic', event)\" data-i18n-title=\"tip_open_service\" title=\"Opens portal & copies password to clipboard\"><span>🚀</span> <span data-i18n=\"btn_launch_copy\">Launch & Copy</span></button>
                                <button class=\"copy-btn\" style=\"position:static; padding: 4px 8px; font-size: 0.75rem;\" onclick=\"handleCopyPassword('{forms_alias}', this)\" data-i18n-title=\"tip_copy_pwd\" title=\"Copy password to clipboard\">📋 <span data-i18n=\"btn_copy_pwd\">Password</span></button>
                            </td>
                        </tr>""")

    return "\n".join(table_rows)
