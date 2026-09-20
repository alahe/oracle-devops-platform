#!/usr/bin/env python3
"""
Oracle DevOps Platform — Local Dev Hub Bridge & Web Server (scripts/internal/dev-hub-bridge.py)
A full-featured 0-dependency HTTP bridge & dashboard server on http://localhost:8089
allowing Dev Hub to control local Podman containers and resolve port conflicts in real-time.
"""

import http.server
import socketserver
import json
import subprocess
import os
import sys
import urllib.parse
import socket
import re
import glob
import shutil
import datetime
import time
import threading
import ssl
import hashlib
import html

# Ensure scripts/internal is in sys.path for dev_hub imports
INTERNAL_DIR = os.path.abspath(os.path.dirname(__file__))
if INTERNAL_DIR not in sys.path:
    sys.path.insert(0, INTERNAL_DIR)

try:
    from dev_hub.parser import parse_blueprint_env_and_metadata
    from dev_hub.diagnostics import find_latest_log_for_blueprint, find_all_logs_for_blueprint, load_all_passwords
    from dev_hub.copilot import (
        get_copilot_status,
        ask_copilot,
        generate_vscode_deeplink,
        get_ai_status,
        ask_ai,
        generate_ai_deeplink
    )
except Exception:
    parse_blueprint_env_and_metadata = None
    find_latest_log_for_blueprint = None
    find_all_logs_for_blueprint = None
    load_all_passwords = None
    get_script_doc_reference = lambda s: {"doc_file": "docs/testing-framework-and-devhub.md", "doc_key": "testing_framework", "title": "Testing Framework & Dev Hub Architecture"}
    get_copilot_status = lambda: {"status": "ok", "available": False, "auth_type": "none", "offline_ready": True}
    ask_copilot = lambda q, h=None, l="en": {"status": "ok", "reply": "Copilot engine offline", "offline": True}
    generate_vscode_deeplink = lambda q, l="en": {"status": "ok", "vscode_url": f"vscode://github.copilot/chat?message={q}", "clipboard_content": q}
    get_ai_status = lambda: {"status": "ok", "providers": {"copilot": {"available": False}, "antigravity": {"available": False}}}
    ask_ai = lambda p, q, h=None, l="en": {"status": "ok", "reply": "AI engine offline", "offline": True}
    generate_ai_deeplink = lambda t, q, l="en": {"status": "ok", f"{t}_url": f"{t}://chat?message={q}", "clipboard_content": q}

# Ensure standard system and package manager binary directories are in PATH
for p in ["/opt/homebrew/bin", "/usr/local/bin", os.path.expanduser("~/.local/bin")]:
    if os.path.isdir(p) and p not in os.environ.get("PATH", "").split(os.pathsep):
        os.environ["PATH"] = p + os.pathsep + os.environ.get("PATH", "")

PODMAN_BIN = shutil.which("podman") or ("/opt/homebrew/bin/podman" if os.path.isfile("/opt/homebrew/bin/podman") else ("/usr/local/bin/podman" if os.path.isfile("/usr/local/bin/podman") else "podman"))

PORT = int(os.environ.get("DEV_HUB_BRIDGE_PORT", 8089))
HTTPS_PORT = int(os.environ.get("DEV_HUB_BRIDGE_HTTPS_PORT", 8449))
BIND_HOST = os.environ.get("DEV_HUB_BRIDGE_BIND_HOST", "127.0.0.1")
WORKSPACE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "../.."))
DEV_HUB_HTML = os.path.join(WORKSPACE_DIR, "docs/dev-hub.html")

def is_safe_origin(origin):
    """Validates HTTP Origin header against local/trusted origins to prevent CSRF and unauthorized cross-origin calls."""
    if not origin:
        return True  # Direct API client or same-origin call
    clean = origin.strip().rstrip("/")
    if clean == "null":
        return True  # Local file:// scheme in browser
    try:
        parsed = urllib.parse.urlparse(clean)
        host = parsed.hostname or ""
        if host in ("localhost", "127.0.0.1") or host.endswith(".local"):
            return True
        allowed_env = os.environ.get("DEV_HUB_ALLOWED_ORIGINS", "")
        if allowed_env:
            for a in allowed_env.split(","):
                a_clean = a.strip().rstrip("/")
                if clean == a_clean or host == a_clean:
                    return True
    except Exception:
        pass
    return False

MODULE_PORT_MAP = {
    "alise": 1533,
    "ords": 8088,
    "proxy": 1532,
    "web-ide": 8090,
    "publisher": 9502,
    "forms": 9001,
    "designer": 6083,
    "forms-publisher": 9502
}

MODULE_CONTAINER_MAP = {
    "alise": "db-alise",
    "ords": "app-ords",
    "proxy": "db-proxy",
    "web-ide": "web-ide-dev",
    "publisher": "oracle-publisher-dev",
    "forms": "app-forms",
    "designer": "app-publisher-designer",
    "forms-publisher": "app-forms-publisher"
}

MODULE_PROFILE_MAP = {
    "alise": "config/profiles/databases/db-alise-oracle.yaml",
    "proxy": "config/profiles/databases/db-proxy-oracle.yaml",
    "web-ide": "config/profiles/web-ide/web-ide-standard.yaml",
    "publisher": "config/profiles/publisher/publisher-standard.yaml",
    "forms": "config/profiles/forms/forms-standard.yaml",
    "designer": "config/profiles/publisher/publisher-designer-standard.yaml",
    "forms-publisher": "config/profiles/forms-publisher/forms-publisher-unified.yaml"
}

ACTIVE_TASKS = {}
PDF_PREVIEW_STORE = {}

def get_platform_version():
    vfile = os.path.join(WORKSPACE_DIR, "VERSION")
    if os.path.isfile(vfile):
        try:
            with open(vfile, "r", encoding="utf-8") as vf:
                return vf.read().strip()
        except Exception:
            pass
    return "2.3.0"

def get_platform_build_timestamp():
    vfile = os.path.join(WORKSPACE_DIR, "VERSION")
    if os.path.isfile(vfile):
        try:
            mtime = os.path.getmtime(vfile)
            return datetime.datetime.fromtimestamp(mtime).strftime("%Y-%m-%d %H:%M:%S")
        except Exception:
            pass
    return datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

DEVOPS_WHITELIST = {
    "setup-dryrun": ["./scripts/setup-all.sh", "--dry-run"],
    "setup-help": ["./scripts/setup-all.sh", "--help"],
    "setup-studio-full": ["./scripts/setup-all.sh", "-y"],
    "setup-studio-fast": ["./scripts/setup-all.sh", "-s", "-y"],
    "setup-studio-fresh": ["./scripts/setup-all.sh", "--fresh", "-y"],
    "setup-studio-dryrun": ["./scripts/setup-all.sh", "--dry-run"],
    "reset-all": ["./scripts/reset-all.sh", "-y"],
    "reset-system": ["./scripts/reset-all.sh", "--system", "-y"],
    "reset-clean-logs": ["./scripts/reset-all.sh", "--clean-logs", "-y"],
    "reset-studio-std": ["./scripts/reset-all.sh", "-y"],
    "reset-studio-deep": ["./scripts/reset-all.sh", "--system", "-y"],
    "reset-studio-clean": ["./scripts/reset-all.sh", "--clean-logs", "-y"],
    "reset-studio-deep-clean": ["./scripts/reset-all.sh", "--system", "--clean-logs", "-y"],
    "sqlcl-cli": ["./scripts/sqlcl.sh", "/@DB_PROXY_DEV"],
    "reset-help": ["./scripts/reset-all.sh", "--help"],
    "start-containers": ["./scripts/start-containers.sh"],
    "start-containers-help": ["./scripts/start-containers.sh", "--help"],
    "podman-machine-start": [PODMAN_BIN, "machine", "start"],
    "podman-machine-stop": [PODMAN_BIN, "machine", "stop"],
    "start-bridge": ["./scripts/start-bridge.sh", "--restart"],
    "start-bridge-status": ["./scripts/start-bridge.sh", "--status"],
    "deploy-status": ["./scripts/deploy-blueprint.sh", "--status"],
    "check-urls": ["./scripts/check-urls.sh"],
    "check-wallet": ["./scripts/check-wallet.sh"],
    "get-passwords": ["./scripts/get-password.sh", "--list"],
    "rotate-dev": ["./scripts/rotate-password.sh", "db-proxy", "dev"],
    "rotate-all": ["./scripts/rotate-password.sh", "all"],
    "create-dev-user": ["./scripts/create-developer.sh", "dev_user"],
    "register-connections": ["./scripts/register-connections.sh"],
    "clean-logs": ["./scripts/clean-logs.sh"],
    "clean-certs": ["./scripts/clean-certs.sh"],
    "report-repo-stats": ["./scripts/report-repo-stats.sh"],
    "onboard-enterprise": ["./scripts/onboard-enterprise.sh", "--status"],
    "create-snapshot": ["./scripts/snapshots/create-golden-snapshots.sh"],
    "restore-snapshot": ["./scripts/snapshots/restore-golden-snapshots.sh", "--auto", "-b", "0"],
    "clean-snapshots": ["./scripts/snapshots/clean-golden-snapshots.sh", "-y"],
    "trust-cert": ["./scripts/certs/trust-local-cert-mac.sh"] if sys.platform == "darwin" else ["./scripts/certs/trust-local-cert.cmd"],
    "check-precommit": ["./scripts/check-pre-commit.sh", "--full"],
    "test-precommit": ["./scripts/check-pre-commit.sh", "--full"],
    "blueprint-info": ["./scripts/blueprint-info.sh"],
    "update-extensions": ["./scripts/update-extensions.sh"],
    # Testing tab runners (invoked via test runner / legacy compatibility)
    "test-ci": ["./scripts/test-local-ci.sh"],
    "test-containers": ["./tests/test-containers-live.sh"],
    "test-devhub-blueprints": ["./tests/test-devhub-browser-blueprints.sh"],
    "test-devhub-lifecycle": ["./tests/test-devhub-lifecycle-full.sh"],
    "test-devhub-lifecycle-dryrun": ["./tests/test-devhub-lifecycle-full.sh", "--dry-run"],
    "windows-dryrun": ["./scripts/test-windows-dryrun.sh"],
    "security-audit": ["./scripts/test-security-audit.sh"],
    "test-mermaid": ["./tests/unit/test-devhub-mermaid-rendering.sh"],
    "test-publisher-a11y": ["./tests/integration/test-publisher-accessibility-suite.sh"],
    "test-publisher-designer-e2e": ["./tests/integration/test-publisher-designer-e2e.sh"],
    "test-devhub-ui": ["./tests/test-devhub-ui.sh", "--all"],
    "playwright-ui": ["./tests/test-devhub-ui.sh", "--all"],
    "test-batch": ["./tests/test-batch.sh"],
    "batch-runner": ["./tests/test-batch.sh"],
    "rtf-lint": ["./scripts/publisher/validate-rtf-accessibility.sh"],
    "pdf-a11y-validate": ["./scripts/publisher/validate-pdf-accessibility.sh", "templates/publisher/accessibility_suite/01-standard-invoice/output_accessible.pdf"],
    "xml-inspect": ["./scripts/publisher/validate-rtf-accessibility.sh"],
    "test-web-ide": ["./tests/integration/test-web-ide-container.sh"],
    "test-db-profiles": ["./tests/integration/test-db-profiles-and-topology.sh"],
    "test-sqlcl-wallet": ["./tests/integration/test-sqlcl-passwordless-connections.sh"]
}

def get_profile_port(module):
    # Tier 1: Dynamic Environment Variable Overrides
    env_keys = {
        "alise": ["DB_ALISE_PORT", "ALISE_PORT"],
        "proxy": ["DB_PROXY_PORT", "PROXY_PORT"],
        "ords": ["ORDS_PORT", "ORDS_HTTP_PORT"],
        "web-ide": ["WEB_IDE_HTTP_PORT", "WEB_IDE_PORT"],
        "publisher": ["PUBLISHER_HTTP_PORT", "PUBLISHER_PORT"],
        "forms": ["FORMS_HTTP_PORT", "FORMS_PORT"],
        "designer": ["PUBLISHER_DESIGNER_PORT", "DESIGNER_PORT", "PUBLISHER_DESIGNER_HTTP_PORT"],
        "forms-publisher": ["FORMS_PUBLISHER_HTTP_PORT", "PUBLISHER_HTTP_PORT"]
    }
    for env_var in env_keys.get(module, []):
        val = os.environ.get(env_var)
        if val and val.isdigit():
            return int(val)

    # Tier 2: Check Active Blueprint or .env for custom profile definitions or port overrides
    rel_path = None
    abp_file = None
    try:
        abp_marker = os.path.join(WORKSPACE_DIR, ".active_blueprint")
        if os.path.isfile(abp_marker):
            with open(abp_marker, "r", encoding="utf-8") as f:
                abp_num = f.read().strip()
            import glob
            matches = glob.glob(os.path.join(WORKSPACE_DIR, f"config/blueprints/.env.{abp_num}-*"))
            if matches:
                abp_file = matches[0]
    except Exception:
        pass

    env_path = os.path.join(WORKSPACE_DIR, ".env")
    for fpath in ([abp_file, env_path] if abp_file else [env_path]):
        if fpath and os.path.isfile(fpath):
            try:
                with open(fpath, "r", encoding="utf-8") as ef:
                    for line in ef:
                        line = line.strip()
                        if not line or line.startswith("#") or "=" not in line:
                            continue
                        k, v = line.split("=", 1)
                        k, v = k.strip(), v.strip().strip('"\'')
                        for env_var in env_keys.get(module, []):
                            if k == env_var and v.isdigit():
                                return int(v)
                        prof_keys = {
                            "alise": "DB_ALISE",
                            "proxy": "DB_PROXY",
                            "ords": "ORDS_PROFILE",
                            "web-ide": "WEB_IDE_PROFILE",
                            "publisher": "PUBLISHER_PROFILE",
                            "forms": "FORMS_PROFILE",
                            "designer": "PUBLISHER_DESIGNER_PROFILE",
                            "forms-publisher": "FORMS_PUBLISHER_PROFILE"
                        }
                        if k == prof_keys.get(module) and v and v.upper() != "NONE":
                            candidate = f"config/profiles/*/{v}.yaml"
                            import glob
                            c_matches = glob.glob(os.path.join(WORKSPACE_DIR, candidate))
                            if c_matches:
                                rel_path = os.path.relpath(c_matches[0], WORKSPACE_DIR)
            except Exception:
                pass

    if not rel_path:
        rel_path = MODULE_PROFILE_MAP.get(module)
    if not rel_path and module == "designer":
        rel_path = "config/profiles/publisher/publisher-designer-standard.yaml"

    # Tier 3: Parse YAML Profile configuration
    if rel_path:
        full_path = os.path.join(WORKSPACE_DIR, rel_path)
        if not os.path.isfile(full_path) and "publisher-designer" in rel_path:
            full_path = os.path.join(WORKSPACE_DIR, "config/profiles/publisher/publisher-designer-standard.yaml")
        if os.path.isfile(full_path):
            try:
                with open(full_path, "r", encoding="utf-8") as f:
                    content = f.read()
                m = re.search(r"^\s*db_port:\s*([0-9]+)", content, re.MULTILINE)
                if m:
                    return int(m.group(1))
                m = re.search(r"^\s*http_port:\s*([0-9]+)", content, re.MULTILINE)
                if m:
                    return int(m.group(1))
                m = re.search(r"host_port:\s*([0-9]+)", content)
                if m:
                    return int(m.group(1))
                m = re.search(r"^\s*port:\s*([0-9]+)", content, re.MULTILINE)
                if m:
                    return int(m.group(1))
            except Exception:
                pass

    # Tier 4: Fallback defaults
    return MODULE_PORT_MAP.get(module, 8080)

def is_socket_busy(port):
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.settimeout(0.3)
            return s.connect_ex(("127.0.0.1", port)) == 0
    except Exception:
        return False

def get_running_containers_with_ports():
    running = {}
    port_to_container = {}
    try:
        res = subprocess.run(
            [PODMAN_BIN, "ps", "--format", "{{.Names}}\t{{.Status}}\t{{.Ports}}"],
            capture_output=True, text=True, timeout=5, cwd=WORKSPACE_DIR
        )
        for line in res.stdout.strip().split("\n"):
            if not line:
                continue
            parts = line.split("\t")
            cname = parts[0].strip()
            ports_str = parts[2].strip() if len(parts) > 2 else ""
            ports_found = []
            for match in re.finditer(r"(?:0\.0\.0\.0|:::)?([0-9]+)->", ports_str):
                p = int(match.group(1))
                ports_found.append(p)
                port_to_container[p] = cname
            running[cname] = ports_found
    except Exception:
        pass
    return running, port_to_container

def detect_port_conflicts():
    running_containers, port_to_container = get_running_containers_with_ports()
    conflicts = {}
    all_used_ports = set(port_to_container.keys())

    for mod_key, cname in MODULE_CONTAINER_MAP.items():
        is_running = (cname in running_containers) or (mod_key == "publisher" and "app-publisher" in running_containers)
        configured_port = get_profile_port(mod_key)

        if not is_running:
            conflicting_cname = port_to_container.get(configured_port)
            socket_busy = is_socket_busy(configured_port) if not conflicting_cname else True

            if conflicting_cname or socket_busy:
                holder = conflicting_cname or "Host Protsess"
                rec_port = 1532 if mod_key == "proxy" else (configured_port + 1)
                while rec_port in all_used_ports or is_socket_busy(rec_port):
                    rec_port += 1

                conflicts[mod_key] = {
                    "has_conflict": True,
                    "module": mod_key,
                    "container": cname,
                    "configured_port": configured_port,
                    "conflicting_container": holder,
                    "recommended_port": rec_port,
                    "profile_file": MODULE_PROFILE_MAP.get(mod_key, ""),
                    "message": f"Port {configured_port} on juba hõivatud ({holder})!"
                }
            else:
                conflicts[mod_key] = {
                    "has_conflict": False,
                    "module": mod_key,
                    "configured_port": configured_port
                }
        else:
            conflicts[mod_key] = {
                "has_conflict": False,
                "module": mod_key,
                "configured_port": configured_port
            }

    return conflicts

def resolve_port_conflict(module, new_port):
    rel_path = MODULE_PROFILE_MAP.get(module)
    if not rel_path:
        return False, f"Tundmatu moodul: {module}"
    full_path = os.path.join(WORKSPACE_DIR, rel_path)
    if not os.path.exists(full_path):
        full_path = os.path.join(WORKSPACE_DIR, f"config/profiles/databases/db-{module}-oracle.yaml")

    if os.path.exists(full_path):
        with open(full_path, "r", encoding="utf-8") as f:
            content = f.read()

        if "db_port:" in content:
            new_content = re.sub(r"^\s*db_port:\s*[0-9]+", f"  db_port: {new_port}", content, flags=re.MULTILINE)
        elif "http_port:" in content:
            new_content = re.sub(r"^\s*http_port:\s*[0-9]+", f"  http_port: {new_port}", content, flags=re.MULTILINE)
        elif "host_port:" in content:
            new_content = re.sub(r"host_port:\s*[0-9]+", f"host_port: {new_port}", content, count=1)
        else:
            new_content = re.sub(r"^\s*port:\s*[0-9]+", f"  port: {new_port}", content, flags=re.MULTILINE)

        with open(full_path, "w", encoding="utf-8") as f:
            f.write(new_content)

        return True, f"Port {new_port} salvestatud edukalt faili {os.path.basename(full_path)}"
    else:
        return False, f"Profiilifaili ei leitud: {full_path}"

def get_setup_in_progress():
    sip_path = os.path.join(WORKSPACE_DIR, ".setup_in_progress")
    if os.path.isfile(sip_path):
        try:
            with open(sip_path, "r", encoding="utf-8") as f:
                data = json.load(f)
            pid = data.get("pid")
            if pid:
                try:
                    os.kill(int(pid), 0)
                    return data
                except (OSError, ProcessLookupError):
                    try:
                        os.remove(sip_path)
                    except Exception:
                        pass
                    return None
            return data
        except Exception:
            return None
    return None

def get_live_container_status():
    status_map = {}
    running_names = []
    container_health = {}
    active_bp = 0
    try:
        res = subprocess.run(
            [PODMAN_BIN, "ps", "--format", "{{.Names}}\t{{.Status}}\t{{.Ports}}"],
            capture_output=True, text=True, timeout=5, cwd=WORKSPACE_DIR
        )
        for line in res.stdout.strip().split("\n"):
            if line:
                parts = line.split("\t")
                name = parts[0].strip()
                running_names.append(name)
                st = parts[1].lower() if len(parts) > 1 else ""
                if "healthy" in st:
                    container_health[name] = "healthy"
                elif "unhealthy" in st:
                    container_health[name] = "unhealthy"
                elif "starting" in st or "init" in st:
                    probe_port = None
                    ports_str = parts[2].strip() if len(parts) > 2 else ""
                    if ports_str:
                        m_port = re.search(r"(?:0\.0\.0\.0|127\.0\.0\.1|\[::\]|:::)?([0-9]+)->", ports_str)
                        if m_port:
                            probe_port = int(m_port.group(1))

                    if not probe_port:
                        c_to_mod = {
                            "app-ords": "ords",
                            "db-proxy": "proxy",
                            "db-alise": "alise",
                            "oracle-publisher-dev": "publisher",
                            "app-publisher": "publisher",
                            "app-forms": "forms",
                            "app-forms-publisher": "forms-publisher",
                            "web-ide-dev": "web-ide",
                            "app-publisher-designer": "designer",
                            "publisher-designer": "designer",
                        }
                        mod = c_to_mod.get(name)
                        if mod:
                            probe_port = get_profile_port(mod)
                    is_live = False
                    if probe_port:
                        try:
                            import socket
                            for host_target in ("127.0.0.1", "localhost"):
                                s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                                s.settimeout(1.0)
                                if s.connect_ex((host_target, probe_port)) == 0:
                                    is_live = True
                                s.close()
                                if is_live:
                                    break
                        except Exception:
                            is_live = False

                    # Check ORDS pools fallback
                    if not is_live and (name in ("app-publisher", "oracle-publisher-dev")):
                        if isinstance(CACHED_ORDS_POOLS, dict):
                            pub_pool = CACHED_ORDS_POOLS.get("publisher", {})
                            if pub_pool.get("status") in ("online", "degraded"):
                                is_live = True

                    if is_live:
                        container_health[name] = "healthy"
                    else:
                        container_health[name] = "starting"
                else:
                    container_health[name] = "running"

        status_map["alise"] = ("db-alise" in running_names)
        status_map["ords"] = ("app-ords" in running_names)
        status_map["proxy"] = ("db-proxy" in running_names)
        status_map["web-ide"] = ("web-ide-dev" in running_names)
        status_map["publisher"] = ("oracle-publisher-dev" in running_names or "app-publisher" in running_names)
        status_map["forms"] = ("app-forms" in running_names)
        status_map["designer"] = ("app-publisher-designer" in running_names)
        status_map["forms-publisher"] = ("app-forms-publisher" in running_names)
    except Exception:
        status_map = {"alise": False, "ords": True, "proxy": True}

    setup_prog = get_setup_in_progress()
    active_bp = read_active_blueprint()
    return status_map, running_names, active_bp, container_health, setup_prog

def read_active_blueprint():
    abp_path = os.path.join(WORKSPACE_DIR, ".active_blueprint")
    if os.path.isfile(abp_path):
        try:
            with open(abp_path, "r", encoding="utf-8") as f:
                txt = f.read().strip()
                m = re.search(r"(\d+)", txt)
                if m:
                    return int(m.group(1))
        except Exception:
            pass
    return None

CACHED_ORDS_POOLS = {}

def get_live_ords_pools():
    """Query status and latency of configured ORDS database pools (Variant 3)."""
    global CACHED_ORDS_POOLS
    ords_pools = {}
    pools_dir = os.path.join(WORKSPACE_DIR, "config/ords/proxy/databases")
    if not os.path.isdir(pools_dir):
        pools_dir = os.path.join(WORKSPACE_DIR, "config/ords/standalone/databases")
    if not os.path.isdir(pools_dir):
        return ords_pools

    ords_port = os.environ.get("ORDS_PORT", "8088")
    import ssl, urllib.request, time, glob
    ctx = ssl._create_unverified_context()
    opener = urllib.request.build_opener(urllib.request.HTTPSHandler(context=ctx))

    running_containers, _ = get_running_containers_with_ports()
    pool_db_map = {
        "proxy": ["db-proxy", "db-oracle"],
        "alise": ["db-alise"],
        "proxy_standalone": ["db-proxy-standalone"],
        "gvenzl": ["db-gvenzl"],
        "adb": ["db-adb"],
    }

    pool_dirs = [d for d in glob.glob(os.path.join(pools_dir, "*")) if os.path.isdir(d) and os.path.basename(d) != "default"]
    for pd in sorted(pool_dirs):
        pname = os.path.basename(pd)
        pxml = os.path.join(pd, "pool.xml")
        target = "unknown"
        if os.path.isfile(pxml):
            try:
                with open(pxml, "r", encoding="utf-8") as f:
                    content = f.read()
                    m_h = re.search(r"<entry key=\"db.hostname\">([^<]+)</entry>", content)
                    m_p = re.search(r"<entry key=\"db.port\">([^<]+)</entry>", content)
                    m_s = re.search(r"<entry key=\"db.servicename\">([^<]+)</entry>", content)
                    if m_h and m_p and m_s:
                        target = f"{m_h.group(1)}:{m_p.group(1)}/{m_s.group(1)}"
            except Exception:
                pass

        req_dbs = pool_db_map.get(pname)
        if req_dbs and not any(d in running_containers for d in req_dbs):
            if pname == "adb":
                _, _, active_bp, _, _ = get_live_container_status()
                if active_bp != 4:
                    ords_pools[pname] = {
                        "configured": True,
                        "status": "offline",
                        "url": f"http://localhost:{ords_port}/ords/{pname}/",
                        "target": target,
                        "latency_ms": 0,
                        "http_code": 0
                    }
                    continue
            else:
                ords_pools[pname] = {
                    "configured": True,
                    "status": "offline",
                    "url": f"http://localhost:{ords_port}/ords/{pname}/",
                    "target": target,
                    "latency_ms": 0,
                    "http_code": 0
                }
                continue

        t0 = time.time()
        url = f"http://127.0.0.1:{ords_port}/ords/{pname}/"
        status = "offline"
        lat = 0
        http_code = 0
        try:
            req = urllib.request.Request(url, headers={"User-Agent": "DevHubBridge"})
            with opener.open(req, timeout=4.0) as resp:
                lat = int((time.time() - t0) * 1000)
                http_code = resp.status
                status = "online" if resp.status in [200, 301, 302, 303, 307, 308, 401, 403, 404] else "degraded"
        except urllib.error.HTTPError as e:
            lat = int((time.time() - t0) * 1000)
            http_code = e.code
            if e.code in [200, 301, 302, 303, 307, 308, 401, 403, 404]:
                status = "online"
            elif e.code in [500, 502, 503, 504]:
                status = "offline"
            else:
                status = "degraded"
        except Exception:
            status = "offline"

        ords_pools[pname] = {
            "configured": True,
            "status": status,
            "url": f"http://localhost:{ords_port}/ords/{pname}/",
            "target": target,
            "latency_ms": lat,
            "http_code": http_code
        }
    CACHED_ORDS_POOLS = ords_pools
    return ords_pools

def get_system_resources():
    total_ram_gb = 16.0
    avail_ram_gb = 8.0
    try:
        if sys.platform == "darwin":
            out = subprocess.check_output(["sysctl", "-n", "hw.memsize"], timeout=2).decode().strip()
            total_ram_gb = round(int(out) / (1024**3), 1)
            try:
                vm_out = subprocess.check_output(["vm_stat"], timeout=2).decode()
                page_sz = 4096
                m_psz = re.search(r"page size of (\d+) bytes", vm_out)
                if m_psz:
                    page_sz = int(m_psz.group(1))
                m_free = re.search(r"Pages free:\s+(\d+)", vm_out)
                m_inact = re.search(r"Pages inactive:\s+(\d+)", vm_out)
                m_spec = re.search(r"Pages speculative:\s+(\d+)", vm_out)
                f_p = int(m_free.group(1)) if m_free else 0
                i_p = int(m_inact.group(1)) if m_inact else 0
                s_p = int(m_spec.group(1)) if m_spec else 0
                avail_ram_gb = round(((f_p + i_p + s_p) * page_sz) / (1024**3), 1)
            except Exception:
                avail_ram_gb = round(total_ram_gb / 2, 1)
        elif sys.platform.startswith("win") or os.name == "nt":
            try:
                ps_cmd = "(Get-CimInstance Win32_OperatingSystem).TotalVisibleMemorySize; (Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory"
                out = subprocess.check_output(["powershell", "-NoProfile", "-Command", ps_cmd], timeout=3).decode().strip().split()
                if len(out) >= 2:
                    total_ram_gb = round(int(out[0]) / (1024 * 1024), 1)
                    avail_ram_gb = round(int(out[1]) / (1024 * 1024), 1)
            except Exception:
                pass
        elif os.path.isfile("/proc/meminfo"):
            with open("/proc/meminfo", "r", encoding="utf-8") as f:
                content = f.read()
            m_tot = re.search(r"MemTotal:\s+(\d+)\s+kB", content)
            m_avail = re.search(r"MemAvailable:\s+(\d+)\s+kB", content)
            if m_tot:
                total_ram_gb = round(int(m_tot.group(1)) / (1024 * 1024), 1)
            if m_avail:
                avail_ram_gb = round(int(m_avail.group(1)) / (1024 * 1024), 1)
    except Exception:
        pass
    system_reserve_gb = 2.0
    safe_avail_ram_gb = max(0.0, round(avail_ram_gb - system_reserve_gb, 1))
    return {
        "total_ram_gb": total_ram_gb,
        "avail_ram_gb": avail_ram_gb,
        "system_reserve_gb": system_reserve_gb,
        "safe_avail_ram_gb": safe_avail_ram_gb
    }

CONTAINER_MEM_CACHE = {"timestamp": 0, "data": {}}

def get_containers_memory_stats():
    now = time.time()
    if CONTAINER_MEM_CACHE["data"] and (now - CONTAINER_MEM_CACHE["timestamp"]) < 4:
        return CONTAINER_MEM_CACHE["data"]

    mem_stats = {}
    total_mb = 0.0
    try:
        res = subprocess.run([PODMAN_BIN, "stats", "--no-stream", "--format", "json"], capture_output=True, text=True, timeout=4, cwd=WORKSPACE_DIR)
        if res.returncode == 0 and res.stdout.strip():
            data = json.loads(res.stdout)
            for item in data:
                cname = item.get("name", "")
                if not cname:
                    continue
                mem_str = item.get("mem_usage", "")
                used_mb = 0.0
                if "/" in mem_str:
                    used_part = mem_str.split("/")[0].strip()
                    m_val = re.match(r"^([\d\.]+)\s*([a-zA-Z]+)", used_part)
                    if m_val:
                        num = float(m_val.group(1))
                        unit = m_val.group(2).upper()
                        if "G" in unit:
                            used_mb = num * 1024.0
                        elif "M" in unit:
                            used_mb = num
                        elif "K" in unit:
                            used_mb = num / 1024.0
                        elif "B" in unit:
                            used_mb = num / (1024.0 * 1024.0)

                pct_str = str(item.get("mem_percent", "0%")).replace("%", "").strip()
                try:
                    pct = float(pct_str)
                except Exception:
                    pct = 0.0

                used_str = f"{round(used_mb / 1024.0, 2)} GB" if used_mb >= 1024.0 else f"{int(round(used_mb))} MB"
                mem_stats[cname] = {
                    "mem_used_mb": round(used_mb, 1),
                    "mem_used_str": used_str,
                    "mem_percent": round(pct, 1)
                }
                total_mb += used_mb
    except Exception:
        pass

    total_gb = round(total_mb / 1024.0, 2)
    result = {
        "container_memory": mem_stats,
        "containers_total_mem_mb": round(total_mb, 1),
        "containers_total_mem_gb": total_gb
    }
    CONTAINER_MEM_CACHE["timestamp"] = now
    CONTAINER_MEM_CACHE["data"] = result
    return result

def update_blueprint_runtime_ram(active_bp_id, container_mem_map):
    if active_bp_id is None:
        return
    ram_file = os.path.join(WORKSPACE_DIR, "metrics", "blueprint_ram_benchmarks.json")
    if not os.path.isfile(ram_file):
        return
    try:
        with open(ram_file, "r", encoding="utf-8") as f:
            data = json.load(f)
        bps = data.get("blueprints", {})
        bp_str = str(active_bp_id)
        if bp_str in bps:
            target_containers = bps[bp_str].get("containers", [])
            total_mb = 0.0
            for cn in target_containers:
                if cn in container_mem_map:
                    total_mb += container_mem_map[cn].get("mem_used_mb", 0.0)
            if total_mb > 0:
                measured_mb = int(round(total_mb))
                if bps[bp_str].get("runtime_ram_mb") != measured_mb:
                    bps[bp_str]["runtime_ram_mb"] = measured_mb
                    bps[bp_str]["last_measured"] = datetime.datetime.now().isoformat()
                    data["last_updated"] = datetime.datetime.now().isoformat()
                    with open(ram_file, "w", encoding="utf-8") as f:
                        json.dump(data, f, indent=2)
    except Exception:
        pass

def format_bytes_human(sz):
    try:
        sz = int(sz)
        if sz >= 1024**3:
            return f"{round(sz / (1024**3), 2)} GB"
        elif sz >= 1024**2:
            return f"{round(sz / (1024**2), 1)} MB"
        elif sz >= 1024:
            return f"{round(sz / 1024, 1)} KB"
        return f"{sz} B"
    except Exception:
        return str(sz) if sz else "-"

def get_podman_engine_status():
    """
    Checks status of Podman engine, platform virtual machine (macOS/Windows),
    and active containers.
    """
    status = {
        "status": "ok",
        "installed": False,
        "platform": sys.platform,
        "has_machine": False,
        "machine_running": False,
        "machine_name": "",
        "containers_running": 0,
        "containers_total": 0,
        "can_start_machine": False,
        "can_start_containers": False,
        "engine_error": ""
    }

    if not PODMAN_BIN or (isinstance(PODMAN_BIN, str) and not os.path.exists(PODMAN_BIN) and not shutil.which(PODMAN_BIN)):
        status["engine_error"] = "Podman binary not found in PATH"
        return status

    status["installed"] = True

    # Query Podman Machine on macOS / Windows
    if sys.platform in ["darwin", "win32", "cygwin"]:
        try:
            r_mach = subprocess.run([PODMAN_BIN, "machine", "list", "--format", "json"], capture_output=True, text=True, timeout=5, cwd=WORKSPACE_DIR)
            if r_mach.returncode == 0 and r_mach.stdout.strip():
                machines = json.loads(r_mach.stdout)
                if isinstance(machines, list) and machines:
                    status["has_machine"] = True
                    def_m = next((m for m in machines if m.get("Default")), machines[0])
                    status["machine_name"] = def_m.get("Name", "")
                    status["machine_running"] = bool(def_m.get("Running", False))
                    status["can_start_machine"] = not status["machine_running"]
        except Exception as e:
            status["engine_error"] = f"Machine query warning: {str(e)}"

    # Query container status
    try:
        r_ps = subprocess.run([PODMAN_BIN, "ps", "-a", "--format", "json"], capture_output=True, text=True, timeout=5, cwd=WORKSPACE_DIR)
        if r_ps.returncode == 0 and r_ps.stdout.strip():
            raw_c = json.loads(r_ps.stdout)
            if isinstance(raw_c, list):
                status["containers_total"] = len(raw_c)
                status["containers_running"] = sum(1 for c in raw_c if (c.get("State") or "").lower() == "running")
                status["can_start_containers"] = (status["containers_running"] < status["containers_total"]) or (status["containers_total"] == 0)
        else:
            if not status["machine_running"] and status["has_machine"]:
                status["can_start_machine"] = True
    except Exception as e:
        if not status["engine_error"]:
            status["engine_error"] = str(e)

    return status

def get_podman_system_resources():
    containers = []
    volumes = []
    networks = []
    images = []

    vol_container_map = {}

    # 1. Containers
    try:
        res = subprocess.run([PODMAN_BIN, "ps", "-a", "--format", "json"], capture_output=True, text=True, timeout=8, cwd=WORKSPACE_DIR)
        raw_c = json.loads(res.stdout) if (res.returncode == 0 and res.stdout.strip()) else []
        for c in raw_c:
            names = c.get("Names", [])
            name = names[0] if isinstance(names, list) and names else str(names)
            name = name.lstrip("/")

            ports_raw = c.get("Ports", [])
            ports_list = []
            if isinstance(ports_raw, list):
                for p in ports_raw:
                    if isinstance(p, dict):
                        hp = p.get("host_port", p.get("HostPort", ""))
                        cp = p.get("container_port", p.get("ContainerPort", ""))
                        proto = p.get("protocol", "tcp")
                        if hp or cp:
                            ports_list.append(f"{hp}->{cp}/{proto}" if hp else f"{cp}/{proto}")
            ports_str = ", ".join(ports_list) if ports_list else "-"

            created_val = c.get("CreatedAt") or c.get("Created", "")
            if isinstance(created_val, (int, float)):
                try:
                    created_val = datetime.datetime.fromtimestamp(created_val).strftime("%Y-%m-%d %H:%M")
                except Exception:
                    created_val = str(created_val)

            mounts = c.get("Mounts", [])
            if isinstance(mounts, list):
                for m in mounts:
                    if isinstance(m, dict):
                        v_name = m.get("Name") or m.get("Source")
                        if v_name:
                            vol_container_map.setdefault(v_name, []).append(name)

            containers.append({
                "id": c.get("Id", "")[:12],
                "full_id": c.get("Id", ""),
                "name": name,
                "image": c.get("Image", ""),
                "state": (c.get("State") or "").lower(),
                "status": c.get("Status", ""),
                "ports": ports_str,
                "created": str(created_val)
            })
    except Exception as e:
        print(f"Error querying podman containers: {e}", file=sys.stderr)

    # 2. Volumes
    try:
        res = subprocess.run([PODMAN_BIN, "volume", "ls", "--format", "json"], capture_output=True, text=True, timeout=8, cwd=WORKSPACE_DIR)
        raw_v = json.loads(res.stdout) if (res.returncode == 0 and res.stdout.strip()) else []
        for v in raw_v:
            v_name = v.get("Name", "")
            created_val = v.get("CreatedAt") or v.get("Created", "")
            if isinstance(created_val, (int, float)):
                try:
                    created_val = datetime.datetime.fromtimestamp(created_val).strftime("%Y-%m-%d %H:%M")
                except Exception:
                    created_val = str(created_val)

            used_by = vol_container_map.get(v_name, [])
            volumes.append({
                "name": v_name,
                "driver": v.get("Driver", "local"),
                "scope": v.get("Scope", "local"),
                "mountpoint": v.get("Mountpoint", ""),
                "created": str(created_val),
                "used_by": list(set(used_by))
            })
    except Exception as e:
        print(f"Error querying podman volumes: {e}", file=sys.stderr)

    # 3. Networks
    try:
        res = subprocess.run([PODMAN_BIN, "network", "ls", "--format", "json"], capture_output=True, text=True, timeout=8, cwd=WORKSPACE_DIR)
        raw_n = json.loads(res.stdout) if (res.returncode == 0 and res.stdout.strip()) else []
        for n in raw_n:
            subs = n.get("subnets", [])
            sub_list = []
            if isinstance(subs, list):
                for s in subs:
                    if isinstance(s, dict):
                        subnet = s.get("subnet", "")
                        gw = s.get("gateway", "")
                        if subnet:
                            sub_list.append(f"{subnet} (gw: {gw})" if gw else subnet)
            networks.append({
                "name": n.get("name", ""),
                "id": n.get("id", "")[:12],
                "driver": n.get("driver", "bridge"),
                "subnets": ", ".join(sub_list) if sub_list else "-",
                "subnet": ", ".join(sub_list) if sub_list else "-"
            })
    except Exception as e:
        print(f"Error querying podman networks: {e}", file=sys.stderr)

    # 4. Images
    try:
        res = subprocess.run([PODMAN_BIN, "images", "--format", "json"], capture_output=True, text=True, timeout=8, cwd=WORKSPACE_DIR)
        raw_i = json.loads(res.stdout) if (res.returncode == 0 and res.stdout.strip()) else []
        for img in raw_i:
            repo = img.get("Repository", "")
            tag = img.get("Tag", "")
            if not repo and img.get("Names"):
                names = img.get("Names")
                if isinstance(names, list) and names:
                    first = names[0]
                    if ":" in first:
                        repo, tag = first.rsplit(":", 1)
                    else:
                        repo = first

            created_val = img.get("CreatedAt") or img.get("Created", "")
            if isinstance(created_val, (int, float)):
                try:
                    created_val = datetime.datetime.fromtimestamp(created_val).strftime("%Y-%m-%d %H:%M")
                except Exception:
                    created_val = str(created_val)

            sz_h = format_bytes_human(img.get("Size", 0))
            images.append({
                "id": img.get("Id", "")[:12],
                "repository": repo or "<none>",
                "tag": tag or "<none>",
                "size": sz_h,
                "size_human": sz_h,
                "created": str(created_val)
            })
    except Exception as e:
        print(f"Error querying podman images: {e}", file=sys.stderr)

    return {
        "status": "ok",
        "ok": True,
        "engine": get_podman_engine_status(),
        "containers": containers,
        "volumes": volumes,
        "networks": networks,
        "images": images,
        "counts": {
            "containers": len(containers),
            "volumes": len(volumes),
            "networks": len(networks),
            "images": len(images)
        }
    }

def get_all_profiles_metadata():
    profiles_dir = os.path.join(WORKSPACE_DIR, "config/profiles")
    results = []
    if os.path.isdir(profiles_dir):
        for root, _, files in os.walk(profiles_dir):
            for f in files:
                if f.endswith(".yaml"):
                    full_p = os.path.join(root, f)
                    rel_p = os.path.relpath(full_p, WORKSPACE_DIR)
                    cat = os.path.basename(os.path.dirname(full_p))
                    port = None
                    desc = ""
                    image = ""
                    memory = ""
                    try:
                        with open(full_p, "r", encoding="utf-8") as yf:
                            cnt = yf.read()
                        m_p = re.search(r"^\s*(?:db_port|http_port|port):\s*([0-9]+)", cnt, re.MULTILINE)
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
                    results.append({
                        "name": f,
                        "category": cat,
                        "rel_path": rel_p,
                        "port": port,
                        "description": desc,
                        "image": image,
                        "memory": memory,
                        "content": cnt
                    })
    results.sort(key=lambda x: (x["category"], x["name"]))
    return results

def get_all_blueprints_metadata():
    bp_dir = os.path.join(WORKSPACE_DIR, "config/blueprints")
    results = []
    if os.path.isdir(bp_dir):
        for f in os.listdir(bp_dir):
            if f.startswith(".env.") and not f.endswith(".bak") and not f.endswith("~"):
                full_p = os.path.join(bp_dir, f)
                if os.path.isfile(full_p):
                    rel_p = os.path.relpath(full_p, WORKSPACE_DIR)
                    num = None
                    slug = ""
                    m = re.match(r"^\.env\.(\d+)(?:-(.*))?$", f)
                    if m:
                        num = int(m.group(1))
                        slug = m.group(2) or ""
                    title = ""
                    full_cnt = ""
                    try:
                        with open(full_p, "r", encoding="utf-8") as bf:
                            full_cnt = bf.read()
                            for line in full_cnt.splitlines():
                                line_str = line.strip()
                                if line_str.startswith("# Blueprint") or line_str.startswith("# blueprint"):
                                    title = line_str.lstrip("#").strip()
                                    break
                    except Exception:
                        full_cnt = ""
                    if not title:
                        title = f"Blueprint {num if num is not None else f}"
                    results.append({
                        "name": f,
                        "rel_path": rel_p,
                        "number": num if num is not None else 999,
                        "slug": slug,
                        "title": title,
                        "content": full_cnt
                    })
    results.sort(key=lambda x: (x["number"], x["name"]))
    return results

def get_snapshots_list():
    snap_dir = os.path.join(WORKSPACE_DIR, "golden-snapshots")
    if not os.path.isdir(snap_dir):
        return []
    items = []
    files = glob.glob(os.path.join(snap_dir, "*.tar.gz"))
    for f in files:
        bname = os.path.basename(f)
        try:
            sz_bytes = os.path.getsize(f)
        except Exception:
            sz_bytes = 0
        sz_mb = round(sz_bytes / (1024 * 1024), 1)
        try:
            mtime = os.path.getmtime(f)
            mtime_str = datetime.datetime.fromtimestamp(mtime).strftime("%Y-%m-%d %H:%M")
        except Exception:
            mtime_str = ""
        
        meta_f = f[:-7] + ".meta.json"
        meta = {}
        if os.path.isfile(meta_f):
            try:
                with open(meta_f, "r", encoding="utf-8") as mf:
                    meta = json.load(mf)
            except Exception:
                pass
        
        snap_type = meta.get("type")
        if not snap_type:
            if bname.startswith("custom_"):
                snap_type = "custom"
            elif bname.endswith("_latest.tar.gz"):
                snap_type = "golden_latest"
            else:
                snap_type = "golden"
        
        bp_id = meta.get("blueprint_id", "")
        if not bp_id:
            m_bp = re.search(r"bp_?([0-9]+)", bname)
            if m_bp:
                bp_id = m_bp.group(1)
        
        tag = meta.get("tag", "")
        desc = meta.get("description", "")
        created_at = meta.get("created_at") or mtime_str
        is_latest = bname.endswith("_latest.tar.gz")
        is_deletable = (snap_type == "custom") or (not is_latest and not bname.startswith("bp_0_"))

        items.append({
            "file": bname,
            "size_mb": sz_mb,
            "size_human": f"{sz_mb} MB" if sz_mb < 1024 else f"{round(sz_mb/1024, 2)} GB",
            "created_at": created_at,
            "modified_time": mtime_str,
            "blueprint_id": str(bp_id),
            "profile_name": meta.get("profile_name", ""),
            "type": snap_type,
            "tag": tag,
            "description": desc,
            "apex_version": meta.get("apex_version", "26.1"),
            "oracle_db_image": meta.get("oracle_db_image", ""),
            "is_latest": is_latest,
            "is_deletable": is_deletable
        })
    items.sort(key=lambda x: (1 if x["is_latest"] else 2 if x["type"] == "custom" else 3, x["modified_time"]), reverse=True)
    return items

def get_single_credential(alias):
    if not alias:
        return ""
    alias_clean = alias.strip()
    # 1. Primary: query SEPS Wallet dynamically via get-password.sh
    get_pwd_script = os.path.join(WORKSPACE_DIR, "scripts", "get-password.sh")
    if os.path.isfile(get_pwd_script) and os.access(get_pwd_script, os.X_OK):
        try:
            res = subprocess.run([get_pwd_script, alias_clean, "-p"], capture_output=True, text=True, timeout=5, cwd=WORKSPACE_DIR)
            val = res.stdout.strip()
            if val and not val.startswith("❌") and not val.startswith("Error"):
                return val
        except Exception:
            pass
    # 2. In-memory lookup via load_all_passwords()
    if load_all_passwords:
        try:
            pwds = load_all_passwords()
            if alias_clean in pwds and pwds[alias_clean]:
                return pwds[alias_clean]
            if alias_clean.endswith("_USER_DEVELOPER"):
                alt = alias_clean.replace("_USER_DEVELOPER", "_DEV")
                if alt in pwds and pwds[alt]: return pwds[alt]
            elif alias_clean.endswith("_DEV"):
                alt = alias_clean.replace("_DEV", "_USER_DEVELOPER")
                if alt in pwds and pwds[alt]: return pwds[alt]
            if alias_clean.startswith("DB_"):
                alt = alias_clean[3:]
                if alt in pwds and pwds[alt]: return pwds[alt]
            else:
                alt = f"DB_{alias_clean}"
                if alt in pwds and pwds[alt]: return pwds[alt]
        except Exception:
            pass
    return ""

def get_test_suites_catalog():
    """Returns structured catalog of test suites and test scripts."""
    try:
        import importlib
        import dev_hub.testing
        importlib.reload(dev_hub.testing)
        return dev_hub.testing.get_test_suites_catalog(WORKSPACE_DIR)
    except Exception:
        pass
    return {}

def get_publisher_templates_catalog():
    """Scans repository for RTF report templates, matching XML test data, and localized XLF bundles."""
    templates = []
    
    # 1. Samples (templates/publisher/samples/)
    samples_dir = os.path.join(WORKSPACE_DIR, "templates/publisher/samples")
    if os.path.isdir(samples_dir):
        sample_xmls = []
        for f in sorted(os.listdir(samples_dir)):
            full_f = os.path.join(samples_dir, f)
            if f.endswith(".xml") and os.path.isfile(full_f):
                sample_xmls.append({
                    "name": f.replace(".xml", "").replace("_", " ").title(),
                    "filename": f,
                    "path": f"templates/publisher/samples/{f}"
                })
        for f in sorted(os.listdir(samples_dir)):
            if f.endswith(".rtf"):
                base_name = f[:-4]
                locales = ["et"]
                for xlf in os.listdir(samples_dir):
                    if xlf.startswith(base_name) and xlf.endswith(".xlf"):
                        m = re.search(r'_([a-z]{2})\.xlf$', xlf)
                        if m and m.group(1) not in locales:
                            locales.append(m.group(1))
                
                title = base_name.replace("_", " ").title()
                if "Arve Test Standard" in title:
                    title = "Eesti Standardarve (Näidis)"
                elif "Arve Eesti Standard" in title:
                    title = "Standardne Müügiarve (Eesti)"
                elif "Saateleht" in title:
                    title = "Standardne Saateleht (Näidis)"
                elif "Accessible Starter" in title:
                    title = "Ligipääsetav Alusmall (Starter)"

                best_xml = f"templates/publisher/samples/{sample_xmls[0]['filename']}" if sample_xmls else ""
                for sxml in sample_xmls:
                    if "test" in base_name.lower() and "test" in sxml["filename"].lower():
                        best_xml = sxml["path"]
                        break
                    elif "arve" in base_name.lower() and "arve" in sxml["filename"].lower():
                        best_xml = sxml["path"]
                        break
                    elif "saateleht" in base_name.lower() and "saateleht" in sxml["filename"].lower():
                        best_xml = sxml["path"]
                        break

                templates.append({
                    "id": f"sample_{base_name}",
                    "name": title,
                    "filename": f,
                    "category": "samples",
                    "category_label": "Näidismallid (Samples)",
                    "rtf_path": f"templates/publisher/samples/{f}",
                    "default_xml": best_xml,
                    "available_xmls": sample_xmls,
                    "locales": sorted(locales),
                    "is_deployable": True,
                    "deploy_path": "Custom/Invoices/Invoice_Report"
                })

    # 2. Accessibility Suite (templates/publisher/accessibility_suite/)
    a11y_dir = os.path.join(WORKSPACE_DIR, "templates/publisher/accessibility_suite")
    if os.path.isdir(a11y_dir):
        for sub in sorted(os.listdir(a11y_dir)):
            sub_path = os.path.join(a11y_dir, sub)
            rtf_file = os.path.join(sub_path, "template.rtf")
            xml_file = os.path.join(sub_path, "data.xml")
            if os.path.isfile(rtf_file) and os.path.isfile(xml_file):
                title = sub.replace("-", " ").title()
                if "01" in sub:
                    title = "Ligipääsetav Arve (PDF/UA-1 & WCAG AA)"
                elif "02" in sub:
                    title = "Mitmerealine Tabeli Aruanne (Ligipääsetav)"
                elif "03" in sub:
                    title = "Finantsaruanne & Kokkuvõtted (Ligipääsetav)"
                
                templates.append({
                    "id": f"a11y_{sub}",
                    "name": title,
                    "filename": "template.rtf",
                    "category": "accessibility",
                    "category_label": "Ligipääsetavuse Suite (PDF/UA-1)",
                    "rtf_path": f"templates/publisher/accessibility_suite/{sub}/template.rtf",
                    "default_xml": f"templates/publisher/accessibility_suite/{sub}/data.xml",
                    "available_xmls": [{
                        "name": "Suite Test Data XML",
                        "filename": "data.xml",
                        "path": f"templates/publisher/accessibility_suite/{sub}/data.xml"
                    }],
                    "locales": ["et", "en", "fi", "sv", "lv", "lt"],
                    "is_deployable": False,
                    "deploy_path": ""
                })

    # 3. Official Custom Reports (applications/publisher/Custom/)
    custom_dir = os.path.join(WORKSPACE_DIR, "applications/publisher/Custom")
    if os.path.isdir(custom_dir):
        for domain in sorted(os.listdir(custom_dir)):
            domain_path = os.path.join(custom_dir, domain)
            if not os.path.isdir(domain_path) or domain.startswith("."):
                continue
            for rep in sorted(os.listdir(domain_path)):
                rep_path = os.path.join(domain_path, rep)
                if not os.path.isdir(rep_path) or rep.startswith("."):
                    continue
                
                xdo_dirs = glob.glob(os.path.join(rep_path, "*.xdo"))
                if not xdo_dirs:
                    continue
                xdo_dir = xdo_dirs[0]
                rtf_file = os.path.join(xdo_dir, "template.rtf")
                if not os.path.isfile(rtf_file):
                    continue

                available_xmls = []
                xdm_dirs = glob.glob(os.path.join(rep_path, "*.xdm"))
                if xdm_dirs:
                    for xfile in sorted(os.listdir(xdm_dirs[0])):
                        if xfile.endswith(".xml"):
                            available_xmls.append({
                                "name": xfile.replace(".xml", "").replace("_", " ").title(),
                                "filename": xfile,
                                "path": f"applications/publisher/Custom/{domain}/{rep}/{os.path.basename(xdm_dirs[0])}/{xfile}"
                            })

                locales = ["et"]
                for xlf in os.listdir(xdo_dir):
                    m = re.search(r'template_([a-z]{2})\.xlf$', xlf)
                    if m and m.group(1) not in locales:
                        locales.append(m.group(1))

                title = f"Ametlik Raport: {rep.replace('_', ' ')}"
                templates.append({
                    "id": f"custom_{domain}_{rep}",
                    "name": title,
                    "filename": "template.rtf",
                    "category": "custom",
                    "category_label": f"Ametlikud Raportid ({domain})",
                    "rtf_path": f"applications/publisher/Custom/{domain}/{rep}/{os.path.basename(xdo_dir)}/template.rtf",
                    "default_xml": available_xmls[0]["path"] if available_xmls else "templates/publisher/samples/arve_test_andmed.xml",
                    "available_xmls": available_xmls or [{"name": "Vaikimisi Arve Andmed", "filename": "arve_test_andmed.xml", "path": "templates/publisher/samples/arve_test_andmed.xml"}],
                    "locales": sorted(locales),
                    "is_deployable": True,
                    "deploy_path": f"Custom/{domain}/{rep}"
                })

    return templates

def get_test_reports_list():
    """Scans tests/reports/ and returns a structured list of test reports."""
    try:
        from dev_hub.testing import get_test_reports_list as _get_reports
        return _get_reports(WORKSPACE_DIR)
    except Exception:
        pass
    return []

def get_test_coverage_data():
    """Reads and parses tests/reports/test-coverage-report.md."""
    cov_file = os.path.join(WORKSPACE_DIR, "tests", "reports", "test-coverage-report.md")
    if not os.path.isfile(cov_file):
        cov_file = os.path.join(WORKSPACE_DIR, "tests", "test-coverage-report.md")

    if not os.path.isfile(cov_file):
        return {"total": 0, "covered": 0, "percent": 0, "scripts": [], "updated_at": "Never"}

    scripts = []
    total = 0
    covered = 0
    updated_at = ""

    try:
        with open(cov_file, "r", encoding="utf-8", errors="ignore") as f:
            for line in f:
                if "Genereeritud:" in line:
                    updated_at = line.split("Genereeritud:")[-1].strip()
                m = re.search(r"\|\s*\*\*`([^`]+)`\*\*\s*\|\s*([^\|]+)\|\s*([^\|]+)\|", line)
                if m:
                    s_name = m.group(1).strip()
                    s_status_raw = m.group(2).strip()
                    s_tests_raw = m.group(3).strip()
                    is_cov = ("✅" in s_status_raw or "Kaetud" in s_status_raw)
                    total += 1
                    if is_cov:
                        covered += 1
                    scripts.append({
                        "name": s_name,
                        "covered": is_cov,
                        "status": "covered" if is_cov else "uncovered",
                        "tests": [t.strip() for t in s_tests_raw.split(",") if t.strip() and t.strip() != "-"]
                    })
    except Exception:
        pass

    percent = round((covered / total * 100), 1) if total > 0 else 0
    return {
        "total": total,
        "covered": covered,
        "percent": percent,
        "scripts": scripts,
        "updated_at": updated_at
    }

def get_test_execution_history():
    """Loads past test executions from metrics/test_execution_history.json."""
    hist_file = os.path.join(WORKSPACE_DIR, "metrics", "test_execution_history.json")
    if os.path.isfile(hist_file):
        try:
            with open(hist_file, "r", encoding="utf-8") as f:
                data = json.load(f)
                if isinstance(data, list):
                    return data
        except Exception:
            pass
    return []

def record_test_execution(task_info, exit_code):
    """Appends completed test task result to metrics/test_execution_history.json."""
    if not task_info or task_info.get("recorded"):
        return
    task_info["recorded"] = True
    if task_info.get("log_fd"):
        try:
            task_info["log_fd"].close()
        except Exception:
            pass

    hist_file = os.path.join(WORKSPACE_DIR, "metrics", "test_execution_history.json")
    history = []
    if os.path.isfile(hist_file):
        try:
            with open(hist_file, "r", encoding="utf-8") as f:
                history = json.load(f)
                if not isinstance(history, list):
                    history = []
        except Exception:
            history = []

    duration = round(time.time() - task_info.get("start_time", time.time()), 1)
    status_label = "PASS" if exit_code == 0 else "FAIL"
    entry = {
        "id": f"run_{datetime.datetime.now().strftime('%Y%m%d_%H%M%S')}",
        "timestamp": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "suite": task_info.get("suite", "unknown"),
        "target": task_info.get("target", "unknown"),
        "duration_sec": duration,
        "exit_code": exit_code,
        "status": status_label,
        "log_file": task_info.get("log_file", "")
    }
    history.insert(0, entry)
    history = history[:50]
    try:
        os.makedirs(os.path.dirname(hist_file), exist_ok=True)
        with open(hist_file, "w", encoding="utf-8") as f:
            json.dump(history, f, indent=2)
    except Exception:
        pass

class DevHubBridgeHandler(http.server.BaseHTTPRequestHandler):
    def _send_cors_headers(self):
        req_origin = self.headers.get("Origin", "") if hasattr(self, "headers") and self.headers else ""
        if is_safe_origin(req_origin):
            self.send_header("Access-Control-Allow-Origin", req_origin if req_origin else "*")
        else:
            self.send_header("Access-Control-Allow-Origin", "null")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS, HEAD")
        self.send_header("Access-Control-Allow-Headers", "Content-Type, Authorization, X-Requested-With")
        self.send_header("Access-Control-Allow-Private-Network", "true")
        self.send_header("Cache-Control", "no-cache, no-store, must-revalidate")
        self.send_header("X-Content-Type-Options", "nosniff")
        if not self.path.startswith("/api/publisher/pdf"):
            self.send_header("X-Frame-Options", "SAMEORIGIN")

    def _safe_write(self, body, content_type="application/json", status=200):
        try:
            self.send_response(status)
            self._send_cors_headers()
            self.send_header("Content-Type", content_type)
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
        except (BrokenPipeError, ConnectionResetError, ssl.SSLEOFError, OSError):
            pass

    def _send_json(self, data, cb=None, status=200):
        json_str = json.dumps(data)
        if cb:
            body = f"{cb}({json_str});".encode("utf-8")
            ct = "application/javascript"
        else:
            body = json_str.encode("utf-8")
            ct = "application/json"

        self._safe_write(body, ct, status)

    def do_OPTIONS(self):
        self.send_response(200)
        self._send_cors_headers()
        self.end_headers()

    def do_HEAD(self):
        self.send_response(200)
        self._send_cors_headers()
        self.end_headers()

    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        params = urllib.parse.parse_qs(parsed.query)
        cb = params.get("callback", [None])[0]

        if parsed.path == "/api/status" or parsed.path == "/status":
            statuses, running_names, active_bp, container_health, setup_prog = get_live_container_status()
            conflicts = detect_port_conflicts()
            resources = get_system_resources()
            mem_info = get_containers_memory_stats()
            if active_bp is not None:
                update_blueprint_runtime_ram(active_bp, mem_info.get("container_memory", {}))
            include_pools = params.get("include_ords_pools", ["1"])[0]
            if include_pools == "0" and CACHED_ORDS_POOLS:
                ords_pools = CACHED_ORDS_POOLS
            else:
                ords_pools = get_live_ords_pools()
            data = {
                "status": "ok",
                "modules": statuses,
                "running_containers": running_names,
                "container_health": container_health,
                "ords_pools": ords_pools,
                "setup_in_progress": setup_prog,
                "active_blueprint": active_bp,
                "conflicts": conflicts,
                "system_resources": resources,
                "version": get_platform_version(),
                "build_timestamp": get_platform_build_timestamp(),
                "container_memory": mem_info.get("container_memory", {}),
                "containers_total_mem_mb": mem_info.get("containers_total_mem_mb", 0),
                "containers_total_mem_gb": mem_info.get("containers_total_mem_gb", 0)
            }
            json_str = json.dumps(data)
            if cb:
                body = f"{cb}({json_str});".encode("utf-8")
                ct = "application/javascript"
            else:
                body = json_str.encode("utf-8")
                ct = "application/json"

            self._safe_write(body, ct)

        elif parsed.path == "/api/ords/pools":
            ords_pools = get_live_ords_pools()
            data = {"status": "ok", "ords_pools": ords_pools}
            json_str = json.dumps(data)
            body = json_str.encode("utf-8")
            self._safe_write(body, "application/json")

        elif parsed.path == "/api/ords/refresh":
            self.handle_ords_refresh(cb)

        elif parsed.path == "/api/copilot/status":
            self._send_json(get_copilot_status(), cb)

        elif parsed.path == "/api/ai/status":
            self._send_json(get_ai_status(), cb)

        elif parsed.path == "/api/tests/suites":
            self._send_json({"status": "ok", "suites": get_test_suites_catalog()}, cb)

        elif parsed.path == "/api/tests/reports":
            self._send_json({"status": "ok", "reports": get_test_reports_list()}, cb)

        elif parsed.path == "/api/tests/report-content":
            self.handle_tests_report_content(parsed.query, cb)

        elif parsed.path == "/api/tests/script-content":
            self.handle_test_script_content(parsed.query, cb)

        elif parsed.path == "/api/file/raw":
            self.handle_file_raw(parsed.query, cb)

        elif parsed.path == "/api/tests/coverage":
            self._send_json({"status": "ok", "coverage": get_test_coverage_data()}, cb)

        elif parsed.path == "/api/tests/history":
            self._send_json({"status": "ok", "history": get_test_execution_history()}, cb)

        elif parsed.path == "/api/publisher/templates":
            self._send_json({"status": "ok", "templates": get_publisher_templates_catalog()}, cb)

        elif parsed.path == "/api/publisher/pdf":
            self.handle_publisher_pdf(parsed.query)

        elif parsed.path == "/api/report/stats":
            stats_path = os.path.join(WORKSPACE_DIR, "metrics/repo_statistics.json")
            if not os.path.isfile(stats_path):
                subprocess.run([sys.executable, os.path.join(WORKSPACE_DIR, "scripts/internal/generate-repo-report.py")], timeout=8)
            if os.path.isfile(stats_path):
                try:
                    with open(stats_path, "r", encoding="utf-8") as f:
                        sdata = json.load(f)
                    self._send_json({"status": "ok", "stats": sdata}, cb)
                except Exception as e:
                    self._send_json({"status": "error", "error": str(e)}, cb, status=500)
            else:
                self._send_json({"status": "error", "error": "Failed to generate report statistics"}, cb, status=500)

        elif parsed.path == "/api/port-conflicts":
            conflicts = detect_port_conflicts()
            data = {"status": "ok", "conflicts": conflicts}
            json_str = json.dumps(data)
            if cb:
                body = f"{cb}({json_str});".encode("utf-8")
                ct = "application/javascript"
            else:
                body = json_str.encode("utf-8")
                ct = "application/json"

            self.send_response(200)
            self._send_cors_headers()
            self.send_header("Content-Type", ct)
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)

        elif parsed.path == "/api/profiles":
            profs = get_all_profiles_metadata()
            data = {"status": "ok", "profiles": profs}
            json_str = json.dumps(data)
            body = f"{cb}({json_str});".encode("utf-8") if cb else json_str.encode("utf-8")
            ct = "application/javascript" if cb else "application/json"
            self.send_response(200)
            self._send_cors_headers()
            self.send_header("Content-Type", ct)
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)

        elif parsed.path == "/api/snapshots/list" or parsed.path == "/snapshots/list":
            snaps = get_snapshots_list()
            self._send_json({"status": "ok", "snapshots": snaps}, cb)

        elif parsed.path == "/api/podman/resources" or parsed.path == "/podman/resources":
            res = get_podman_system_resources()
            self._send_json({"status": "ok", "resources": res}, cb)

        elif parsed.path in ["/api/podman/engine/status", "/api/podman/status", "/api/podman/machine/status"]:
            status_data = get_podman_engine_status()
            self._send_json(status_data, cb)

        elif parsed.path == "/api/profile":
            rel_p = params.get("path", [""])[0]
            full_p = os.path.normpath(os.path.join(WORKSPACE_DIR, rel_p))
            profiles_root = os.path.join(WORKSPACE_DIR, "config/profiles")
            if os.path.isfile(full_p) and full_p.startswith(profiles_root) and full_p.endswith(".yaml"):
                try:
                    with open(full_p, "r", encoding="utf-8") as f:
                        cnt = f.read()
                    data = {"status": "ok", "path": rel_p, "content": cnt}
                except Exception as e:
                    data = {"status": "error", "error": str(e)}
            else:
                data = {"status": "error", "error": f"Invalid profile path: {rel_p}"}
            json_str = json.dumps(data)
            body = f"{cb}({json_str});".encode("utf-8") if cb else json_str.encode("utf-8")
            ct = "application/javascript" if cb else "application/json"
            self.send_response(200 if data.get("status") == "ok" else 404)
            self._send_cors_headers()
            self.send_header("Content-Type", ct)
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)

        elif parsed.path == "/api/blueprints":
            bps = get_all_blueprints_metadata()
            self._send_json({"status": "ok", "blueprints": bps}, cb)

        elif parsed.path == "/api/blueprint":
            rel_p = params.get("path", [""])[0] or params.get("file", [""])[0]
            if rel_p and not rel_p.startswith("config/blueprints"):
                rel_p = os.path.join("config/blueprints", os.path.basename(rel_p))
            full_p = os.path.normpath(os.path.join(WORKSPACE_DIR, rel_p))
            bp_root = os.path.join(WORKSPACE_DIR, "config/blueprints")
            if os.path.isfile(full_p) and full_p.startswith(bp_root) and os.path.basename(full_p).startswith(".env."):
                try:
                    with open(full_p, "r", encoding="utf-8") as f:
                        cnt = f.read()
                    self._send_json({"status": "ok", "path": rel_p, "name": os.path.basename(full_p), "content": cnt}, cb)
                except Exception as e:
                    self._send_json({"status": "error", "error": str(e)}, cb, status=500)
            else:
                self._send_json({"status": "error", "error": f"Invalid blueprint path: {rel_p}"}, cb, status=404)

        elif parsed.path in ["/api/password", "/api/credential"]:
            alias = params.get("alias", [""])[0] or params.get("name", [""])[0]
            if not alias:
                self._send_json({"status": "error", "error": "Missing alias parameter", "alias": "", "password": ""}, cb, status=400)
            else:
                pwd = get_single_credential(alias)
                if pwd:
                    self._send_json({"status": "ok", "alias": alias, "password": pwd}, cb)
                else:
                    self._send_json({"status": "error", "error": f"Password for alias '{alias}' not found", "alias": alias, "password": ""}, cb, status=404)

        elif parsed.path in ["/api/passwords", "/api/credentials"]:
            pwds = load_all_passwords() if load_all_passwords else {}
            self._send_json({"status": "ok", "passwords": pwds}, cb)

        elif parsed.path in ["/api/publisher/open", "/api/publisher/login"]:
            # Rule 5 Zero-Trust: Passwords are NEVER accepted or transmitted via URL parameters.
            # Query the credential dynamically in-memory from SEPS Wallet using user/role/alias.
            raw_user = params.get("user", [""])[0] or params.get("username", [""])[0] or params.get("role", [""])[0] or "bip_developer"
            alias = params.get("alias", [""])[0]
            dest = params.get("dest", [""])[0] or params.get("target", [""])[0] or "/servlet/home"

            user_clean = raw_user.strip().lower()
            if not alias:
                if user_clean in ["bip_developer", "developer", "dev"]:
                    alias = "PUBLISHER_DEVELOPER"
                    user_clean = "bip_developer"
                elif user_clean in ["bip_user", "user"]:
                    alias = "PUBLISHER_USER"
                    user_clean = "bip_user"
                elif user_clean in ["bip_admin", "admin"]:
                    alias = "PUBLISHER_ADMIN"
                    user_clean = "bip_admin"
                elif user_clean in ["weblogic", "sys", "system", "administrator"]:
                    alias = "PUBLISHER_WEBLOGIC_ADMIN"
                    user_clean = "weblogic"
                else:
                    alias = f"PUBLISHER_{raw_user.strip().upper()}"
                    user_clean = raw_user.strip()
            else:
                user_clean = raw_user.strip()

            pwd = get_single_credential(alias)
            if not pwd and alias == "PUBLISHER_WEBLOGIC_ADMIN":
                pwd = get_single_credential("DB_PUBLISHER_SYS")
            if not pwd and alias != "PUBLISHER_DEVELOPER":
                pwd = get_single_credential("PUBLISHER_DEVELOPER")

            # Destination parsing & whitelist validation (prevents Open Redirect)
            dest_unquoted = urllib.parse.unquote(dest).strip()
            if not (dest_unquoted.startswith("/") or dest_unquoted.startswith("http://localhost:9502/") or dest_unquoted.startswith("http://127.0.0.1:9502/")):
                self.send_response(400)
                self.send_header("Content-Type", "text/plain; charset=utf-8")
                self.end_headers()
                self.wfile.write(b"400 Bad Request: Invalid destination parameter (must target /xmlpserver or localhost:9502)")
                return

            # Canonical Publisher base and destination resolution
            base_login_url = "http://localhost:9502/xmlpserver/login.jsp"
            if dest_unquoted.startswith("http://localhost:9502"):
                target_dest_url = dest_unquoted
            elif dest_unquoted.startswith("http://127.0.0.1:9502"):
                target_dest_url = dest_unquoted.replace("http://127.0.0.1:9502", "http://localhost:9502")
            elif dest_unquoted.startswith("/xmlpserver/"):
                target_dest_url = f"http://localhost:9502{dest_unquoted}"
            elif dest_unquoted.startswith("/"):
                target_dest_url = f"http://localhost:9502/xmlpserver{dest_unquoted}"
            else:
                target_dest_url = "http://localhost:9502/xmlpserver/servlet/home"

            # Detect if navigation targets a specific report/custom page rather than the default home portal
            target_norm = target_dest_url.rstrip("/")
            is_specific_dest = (
                any(marker in target_dest_url for marker in [".xdo", ".xdm", "/Custom/", "/viewHistory", "/myjob"])
                and not (target_norm.endswith("/xmlpserver") or target_norm.endswith("/servlet/home"))
            )

            # Direct top-level navigation (Zero iframes: 100% CSP and SameSite compliant)
            target_form_action = target_dest_url if is_specific_dest else base_login_url

            auto_nav_script = f"""
        var submitted = false;
        function submitLogin() {{
            if (!submitted) {{
                submitted = true;
                document.getElementById('autoPostForm').submit();
            }}
        }}
        // Pre-flight session invalidation: reset any lingering WebLogic sessions (e.g. prior weblogic login)
        try {{
            var resetImg = new Image();
            resetImg.onload = resetImg.onerror = function() {{
                setTimeout(submitLogin, 50);
            }};
            resetImg.src = "http://localhost:9502/xmlpserver/signout.jsp?_ts=" + Date.now();
            setTimeout(submitLogin, 300);
        }} catch(e) {{
            submitLogin();
        }}
"""

            html_content = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="Cache-Control" content="no-store, no-cache, must-revalidate, max-age=0">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Expires" content="0">
    <title>Connecting to Oracle Analytics Publisher...</title>
    <style>
        body {{
            background: #0f172a;
            color: #f8fafc;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100vh;
            margin: 0;
        }}
        .card {{
            background: #1e293b;
            border: 1px solid #334155;
            border-radius: 12px;
            padding: 32px 40px;
            text-align: center;
            box-shadow: 0 10px 30px rgba(0,0,0,0.5);
            max-width: 420px;
        }}
        .spinner {{
            width: 40px;
            height: 40px;
            border: 4px solid rgba(56, 189, 248, 0.2);
            border-top-color: #38bdf8;
            border-radius: 50%;
            animation: spin 0.8s linear infinite;
            margin: 0 auto 18px;
        }}
        @keyframes spin {{ to {{ transform: rotate(360deg); }} }}
    </style>
</head>
<body>
    <div class="card">
        <div class="spinner"></div>
        <h3 style="margin: 0 0 8px 0; color: #38bdf8;">Oracle Analytics Publisher</h3>
        <p style="margin: 0 0 12px 0; color: #94a3b8; font-size: 0.9rem;">Automaatne sisselogimine rollis <b>{html.escape(user_clean)}</b>...</p>
        <noscript>
            <p style="color: #fbbf24;">JavaScript on keelatud. Klõpsa jätkamiseks:</p>
            <button type="submit" form="autoPostForm" style="padding: 8px 16px; background: #38bdf8; border: none; border-radius: 6px; cursor: pointer; font-weight: 600;">Logi sisse</button>
        </noscript>
    </div>

    <form id="autoPostForm" method="POST" action="{html.escape(target_form_action)}">
        <input type="hidden" name="id" value="{html.escape(user_clean)}">
        <input type="hidden" name="passwd" value="{html.escape(pwd)}">
        <input type="hidden" name="_xuil" value="en_US">
        <input type="hidden" name="SUBMIT_BUTTON" value="Sign In">
    </form>

    <script>
{auto_nav_script}
    </script>
</body>
</html>"""
            response_bytes = html_content.encode("utf-8")
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Content-Length", str(len(response_bytes)))
            self.send_header("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0")
            self.send_header("Pragma", "no-cache")
            self.send_header("Expires", "0")
            self.send_header("X-Content-Type-Options", "nosniff")
            self.send_header("Content-Security-Policy", "default-src 'none'; style-src 'unsafe-inline'; script-src 'unsafe-inline'; connect-src http://localhost:9502 http://127.0.0.1:9502; img-src http://localhost:9502 http://127.0.0.1:9502; form-action http://localhost:9502 http://127.0.0.1:9502; frame-src http://localhost:9502 http://127.0.0.1:9502;")
            # Force browser to clear any active WebLogic session for localhost /xmlpserver so new credentials always take effect
            self.send_header("Set-Cookie", "JSESSIONID=deleted; Path=/xmlpserver; Max-Age=0; Expires=Thu, 01 Jan 1970 00:00:00 GMT; HttpOnly; SameSite=Lax")
            self.send_header("Set-Cookie", "ORA_XDO_UI=deleted; Path=/xmlpserver; Max-Age=0; Expires=Thu, 01 Jan 1970 00:00:00 GMT; HttpOnly; SameSite=Lax")
            self.end_headers()
            self.wfile.write(response_bytes)

        elif parsed.path == "/api/version":
            self._send_json({
                "status": "ok",
                "version": get_platform_version(),
                "build_timestamp": get_platform_build_timestamp(),
                "engine": "zero-trust-bip-auto-login",
                "session_invalidation": "active",
                "supported_roles": ["bip_developer", "bip_user", "bip_admin", "weblogic"],
                "active_blueprint": read_active_blueprint()
            }, cb)


        elif parsed.path.startswith("/api/resolve-port-conflict"):
            self.handle_resolve_conflict(parsed.query, cb)

        elif parsed.path == "/api/doc":
            doc_id = params.get("id", [""])[0]
            lang = params.get("lang", ["en"])[0].lower()

            doc_map = {
                "publisher-template-builder": "docs/publisher-template-builder-guide.md",
                "readme": "README.md",
                "quick-login": "docs/quick-login-guide.md",
                "db-topology": "docs/db-profiles-and-topology.md",
                "forms-setup": "docs/forms-setup.md",
                "publisher-setup": "docs/publisher-setup.md",
                "security": "docs/turvalisus.md",
                "web-ide": "docs/web-ide-artifactory.md",
                "apex-deploy": "docs/apex-apps-deployment.md",
                "setup-workflow": "docs/setup-all-workflow.md",
                "future-plans": "docs/future-plans.md",
                "forms-to-apex": "docs/forms-to-apex-migration-guide.md",
                "security-audit": "docs/security-audit-report.md",
                "enterprise-architecture": "docs/enterprise-distributed-architecture.md",
                "enterprise-backlog": "docs/backlog/README.md",
                "fin-001": "docs/backlog/FIN-001-multi-host-inventory-and-profile-engine.md",
                "fin-002": "docs/backlog/FIN-002-proxy-db-remote-container-deployment.md",
                "fin-003": "docs/backlog/FIN-003-publisher-db-remote-container-deployment.md",
                "fin-004": "docs/backlog/FIN-004-standalone-ords-apex-server-deployment.md",
                "fin-005": "docs/backlog/FIN-005-standalone-analytics-publisher-server-deployment.md",
                "fin-006": "docs/backlog/FIN-006-ords-multi-pool-business-db-wiring.md",
                "fin-007": "docs/backlog/FIN-007-publisher-jdbc-business-db-connection.md",
                "fin-008": "docs/backlog/FIN-008-prod-active-standby-sync-and-failover.md",
                "fin-009": "docs/backlog/FIN-009-zero-trust-wallet-and-tls-distribution.md",
                "fin-010": "docs/backlog/FIN-010-dev-test-prod-ci-cd-promotion-pipeline.md",
                "fin-011": "docs/backlog/FIN-011-e2e-health-check-and-disaster-recovery-testing.md"
            }

            rel_path = doc_map.get(doc_id, f"docs/{doc_id}.md")
            target_path = None

            if lang and lang != "en":
                if rel_path == "README.md":
                    loc_candidate = os.path.join(WORKSPACE_DIR, f"docs/{lang}/README.md")
                    if os.path.exists(loc_candidate):
                        target_path = loc_candidate
                elif rel_path.startswith("docs/"):
                    fname = os.path.basename(rel_path)
                    loc_candidate = os.path.join(WORKSPACE_DIR, f"docs/{lang}/{fname}")
                    if os.path.exists(loc_candidate):
                        target_path = loc_candidate

            if not target_path or not os.path.exists(target_path):
                std_candidate = os.path.join(WORKSPACE_DIR, rel_path)
                if os.path.exists(std_candidate):
                    target_path = std_candidate

            if target_path and os.path.exists(target_path):
                with open(target_path, "rb") as f:
                    content = f.read()
                self.send_response(200)
                self._send_cors_headers()
                self.send_header("Content-Type", "text/markdown; charset=utf-8")
                self.send_header("Content-Length", str(len(content)))
                self.end_headers()
                self.wfile.write(content)
            else:
                body = f"# Document '{doc_id}' not found\n\nNo document file found for ID `{doc_id}` (lang: `{lang}`).".encode("utf-8")
                self.send_response(404)
                self._send_cors_headers()
                self.send_header("Content-Type", "text/markdown; charset=utf-8")
                self.send_header("Content-Length", str(len(body)))
                self.end_headers()
                self.wfile.write(body)

        elif parsed.path == "/api/log/read":
            file_name = params.get("file", [""])[0]
            base = os.path.basename(file_name)
            log_path = os.path.join(WORKSPACE_DIR, "install_logs", base) if base else ""

            # If specific file is not found on disk, attempt blueprint resolution fallback
            if not log_path or not os.path.isfile(log_path):
                m_bp = re.search(r"bp_?([0-9]+)", base) if base else None
                alt_info = None
                if m_bp and find_latest_log_for_blueprint:
                    alt_info = find_latest_log_for_blueprint(WORKSPACE_DIR, m_bp.group(1))
                if alt_info and alt_info.get("full_path") and os.path.isfile(alt_info["full_path"]):
                    log_path = alt_info["full_path"]
                    base = os.path.basename(log_path)

            # Security jail check (CWE-22): strictly enforce that resolved log path is inside install_logs/
            allowed_dir = os.path.realpath(os.path.join(WORKSPACE_DIR, "install_logs"))
            if log_path and os.path.isfile(log_path):
                real_target = os.path.realpath(log_path)
                if not (real_target.startswith(allowed_dir + os.sep) or real_target == allowed_dir):
                    log_path = ""

            if not log_path or not os.path.isfile(log_path):
                data = {
                    "status": "ok",
                    "ok": True,
                    "found": False,
                    "file": base,
                    "content": "(Logifaili pole veel loodud või eelnev paigalduslogi puudub. Käivita toiming, et luua logi.)"
                }
                json_str = json.dumps(data)
                body = f"{cb}({json_str});".encode("utf-8") if cb else json_str.encode("utf-8")
                ct = "application/javascript" if cb else "application/json"
                self.send_response(200)
                self._send_cors_headers()
                self.send_header("Content-Type", ct)
                self.send_header("Content-Length", str(len(body)))
                self.end_headers()
                self.wfile.write(body)
            else:
                try:
                    with open(log_path, "r", encoding="utf-8", errors="ignore") as f:
                        lines = f.readlines()
                    content = "".join(lines[-500:]) if len(lines) > 500 else "".join(lines)
                    data = {
                        "status": "ok",
                        "ok": True,
                        "found": True,
                        "file": base,
                        "relative_path": f"install_logs/{base}",
                        "full_path": log_path,
                        "size_bytes": os.path.getsize(log_path),
                        "lines_count": len(lines),
                        "content": content
                    }
                    json_str = json.dumps(data)
                    body = f"{cb}({json_str});".encode("utf-8") if cb else json_str.encode("utf-8")
                    ct = "application/javascript" if cb else "application/json"
                    self.send_response(200)
                    self._send_cors_headers()
                    self.send_header("Content-Type", ct)
                    self.send_header("Content-Length", str(len(body)))
                    self.end_headers()
                    self.wfile.write(body)
                except Exception as e:
                    self.send_response(500)
                    self._send_cors_headers()
                    self.end_headers()
                    self.wfile.write(json.dumps({"status": "error", "ok": False, "error": str(e)}).encode("utf-8"))

        elif parsed.path == "/api/logs/list":
            log_dir = os.path.join(WORKSPACE_DIR, "install_logs")
            logs_list = []
            if os.path.isdir(log_dir):
                for fname in os.listdir(log_dir):
                    if not fname.endswith(".log"):
                        continue
                    full_p = os.path.join(log_dir, fname)
                    if not os.path.isfile(full_p):
                        continue
                    try:
                        stat = os.stat(full_p)
                        size = stat.st_size
                        mtime_ts = stat.st_mtime
                        mtime_str = datetime.datetime.fromtimestamp(mtime_ts).strftime("%Y-%m-%d %H:%M:%S")

                        # Determine category and blueprint ID
                        category = "devops"
                        bp_id = ""
                        m_bp = re.search(r"bp_?([0-9]+)", fname)
                        if m_bp:
                            bp_id = m_bp.group(1)

                        lower_name = fname.lower()
                        if lower_name.startswith("setup") or "setup" in lower_name:
                            category = "setup"
                        elif lower_name.startswith("deploy") or "deploy" in lower_name:
                            category = "deploy"
                        elif lower_name.startswith("test") or "test" in lower_name:
                            category = "test"
                        elif lower_name.startswith("snapshot") or "snapshot" in lower_name or "restore" in lower_name:
                            category = "snapshot"
                        elif lower_name.startswith("reset") or "reset" in lower_name:
                            category = "reset"
                        elif lower_name.startswith("ci_") or "github" in lower_name:
                            category = "ci"

                        # Friendly label
                        label = fname
                        if bp_id:
                            label = f"Blueprint #{bp_id} ({category.capitalize()})"
                        elif "test_browser" in lower_name:
                            label = "Browser Login Test"
                        elif "ci_local" in lower_name:
                            label = "Local CI Simulator"
                        elif "test_all" in lower_name:
                            label = "All Components Test"
                        elif "restore_golden" in lower_name:
                            label = "Golden Snapshot Restore"
                        elif "clean_logs" in lower_name:
                            label = "Clean Logs"

                        logs_list.append({
                            "filename": fname,
                            "relative_path": f"install_logs/{fname}",
                            "size_bytes": size,
                            "size_formatted": f"{size / 1024:.1f} KB" if size > 1024 else f"{size} B",
                            "mtime": mtime_str,
                            "timestamp": mtime_ts,
                            "category": category,
                            "blueprint_id": bp_id,
                            "label": label
                        })
                    except Exception:
                        pass

            # Sort latest modified first
            logs_list.sort(key=lambda x: x["timestamp"], reverse=True)
            self._send_json({"status": "ok", "logs": logs_list, "total": len(logs_list)}, cb)

        elif parsed.path in ["/api/logs/blueprint", "/api/log/blueprint"]:
            bp = params.get("bp", ["0"])[0]
            logs = find_all_logs_for_blueprint(WORKSPACE_DIR, bp) if find_all_logs_for_blueprint else []
            data = {
                "status": "ok",
                "ok": True,
                "blueprint": int(bp) if bp.isdigit() else 0,
                "logs": logs,
                "total": len(logs)
            }
            self._send_json(data, cb)

        elif parsed.path == "/api/log/latest":
            bp = params.get("bp", ["0"])[0]
            info = find_latest_log_for_blueprint(WORKSPACE_DIR, bp) if find_latest_log_for_blueprint else None
            if not info:
                data = {
                    "status": "ok",
                    "ok": True,
                    "found": False,
                    "blueprint": int(bp) if bp.isdigit() else 0,
                    "message": "No log file found for this blueprint"
                }
            else:
                data = info
            json_str = json.dumps(data)
            body = f"{cb}({json_str});".encode("utf-8") if cb else json_str.encode("utf-8")
            ct = "application/javascript" if cb else "application/json"
            self.send_response(200)
            self._send_cors_headers()
            self.send_header("Content-Type", ct)
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)

        elif parsed.path in ["/api/task/status", "/api/snapshots/reset-deep/status"]:
            self.handle_task_status(parsed.query, cb)

        elif parsed.path.startswith("/api/toggle") or parsed.path.startswith("/toggle"):
            self.handle_toggle(parsed.query, cb)

        elif parsed.path in ["/api/bridge/restart", "/api/bridge/reload"]:
            self._send_json({"status": "ok", "message": "Bridge restarting..."}, cb)
            def _restart():
                time.sleep(0.5)
                os.execv(sys.executable, [sys.executable] + sys.argv)
            threading.Thread(target=_restart).start()

        elif parsed.path in ["/", "/dev-hub", "/dev-hub.html", "/index.html"]:
            if os.path.exists(DEV_HUB_HTML):
                with open(DEV_HUB_HTML, "rb") as f:
                    content = f.read()
                self.send_response(200)
                self._send_cors_headers()
                self.send_header("Content-Type", "text/html; charset=utf-8")
                self.send_header("Content-Length", str(len(content)))
                self.end_headers()
                self.wfile.write(content)
            else:
                self._send_json({"status": "error", "error": "Not found"}, cb, status=404)
        else:
            self.send_response(200)
            self._send_cors_headers()
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(b'{"status":"ok","message":"Dev Hub Bridge Active"}')

    def do_POST(self):
        req_origin = self.headers.get("Origin", "")
        if req_origin and not is_safe_origin(req_origin):
            self.send_response(403)
            self._send_cors_headers()
            self.end_headers()
            self.wfile.write(b'{"status":"error","error":"Forbidden: Untrusted Cross-Origin Request"}')
            return

        parsed = urllib.parse.urlparse(self.path)
        params = urllib.parse.parse_qs(parsed.query)
        cb = params.get("callback", [None])[0]

        content_len = int(self.headers.get("Content-Length", 0))
        post_body = self.rfile.read(content_len).decode("utf-8") if content_len > 0 else ""

        if parsed.path.startswith("/api/resolve-port-conflict"):
            self.handle_resolve_conflict(parsed.query or post_body, cb)
        elif parsed.path.startswith("/api/toggle") or parsed.path.startswith("/toggle") or parsed.path.startswith("/api/module/toggle"):
            self.handle_toggle(post_body if post_body.strip().startswith("{") else (parsed.query or post_body), cb)
        elif parsed.path == "/api/profile":
            self.handle_profile_save(post_body, parsed.query, cb)
        elif parsed.path == "/api/blueprint/save" or parsed.path == "/api/blueprint":
            self.handle_blueprint_save(post_body, parsed.query, cb)
        elif parsed.path == "/api/blueprint/create":
            self.handle_blueprint_create(post_body, parsed.query, cb)
        elif parsed.path == "/api/devops/run":
            self.handle_devops_run(post_body, parsed.query, cb)
        elif parsed.path == "/api/snapshots/restore":
            self.handle_snapshot_restore(post_body, parsed.query, cb)
        elif parsed.path == "/api/snapshots/create":
            self.handle_snapshot_create(post_body, parsed.query, cb)
        elif parsed.path == "/api/snapshots/delete":
            self.handle_snapshot_delete(post_body, parsed.query, cb)
        elif parsed.path == "/api/snapshots/reset-deep":
            self.handle_reset_deep(post_body, parsed.query, cb)
        elif parsed.path == "/api/tests/run":
            self.handle_test_run(post_body, parsed.query, cb)
        elif parsed.path == "/api/tests/stop":
            self.handle_test_stop(post_body, parsed.query, cb)
        elif parsed.path == "/api/publisher/render":
            self.handle_publisher_render(post_body, parsed.query, cb)
        elif parsed.path == "/api/publisher/deploy":
            self.handle_publisher_deploy(post_body, parsed.query, cb)
        elif parsed.path == "/api/publisher/audit":
            self.handle_publisher_audit(post_body, parsed.query, cb)
        elif parsed.path == "/api/publisher/test-e2e":
            self.handle_publisher_test_e2e(post_body, parsed.query, cb)
        elif parsed.path == "/api/publisher/open-designer":
            self.handle_publisher_open_designer(post_body, parsed.query, cb)
        elif parsed.path == "/api/copilot/chat":
            self.handle_copilot_chat(post_body, parsed.query, cb)
        elif parsed.path == "/api/ai/chat":
            self.handle_ai_chat(post_body, parsed.query, cb)
        elif parsed.path == "/api/copilot/deeplink":
            self.handle_copilot_deeplink(post_body, parsed.query, cb)
        elif parsed.path == "/api/ai/deeplink":
            self.handle_ai_deeplink(post_body, parsed.query, cb)
        elif parsed.path in ["/api/podman/engine/start", "/api/podman/start"]:
            self.handle_podman_engine_start(post_body, parsed.query, cb)
        elif parsed.path == "/api/podman/action":
            self.handle_podman_action(post_body, parsed.query, cb)
        elif parsed.path == "/api/bridge/restart" or parsed.path == "/api/bridge/reload":
            self._send_json({"status": "ok", "message": "Bridge restarting..."}, cb)
            def _restart():
                time.sleep(0.5)
                os.execv(sys.executable, [sys.executable] + sys.argv)
            import threading
            threading.Thread(target=_restart).start()
        elif parsed.path == "/api/ords/refresh":
            self.handle_ords_refresh(cb)
        elif parsed.path == "/api/report/refresh":
            try:
                subprocess.run([sys.executable, os.path.join(WORKSPACE_DIR, "scripts/internal/generate-repo-report.py")], timeout=10, check=True)
                stats_path = os.path.join(WORKSPACE_DIR, "metrics/repo_statistics.json")
                with open(stats_path, "r", encoding="utf-8") as f:
                    sdata = json.load(f)
                self._send_json({"status": "ok", "stats": sdata, "refreshed": True}, cb)
            except Exception as e:
                self._send_json({"status": "error", "error": str(e)}, cb, status=500)
        else:
            self._send_json({"status": "error", "error": f"Endpoint not found: {parsed.path}"}, cb, status=404)

    def handle_ords_refresh(self, cb=None):
        try:
            subprocess.run([os.path.join(WORKSPACE_DIR, "scripts/internal/manage-ords-pools.sh"), "sync"], capture_output=True, timeout=5)
        except Exception:
            pass
        ords_pools = get_live_ords_pools(force=True) if "force" in get_live_ords_pools.__code__.co_varnames else get_live_ords_pools()
        CONTAINER_MEM_CACHE["timestamp"] = 0
        mem_info = get_containers_memory_stats()
        resources = get_system_resources()
        _, _, active_bp, _, _ = get_live_container_status()
        if active_bp is not None:
            update_blueprint_runtime_ram(active_bp, mem_info.get("container_memory", {}))
        data = {
            "status": "ok",
            "message": "ORDS pools and container RAM synchronized",
            "ords_pools": ords_pools,
            "container_memory": mem_info.get("container_memory", {}),
            "containers_total_mem_mb": mem_info.get("containers_total_mem_mb", 0),
            "containers_total_mem_gb": mem_info.get("containers_total_mem_gb", 0),
            "system_resources": resources
        }
        self._send_json(data, cb)

    def handle_podman_action(self, post_body, query_str, cb=None):
        """Controls Podman resources: containers (start, stop, restart, remove), volumes (remove), images (remove)."""
        res_type = "container"
        action = "stop"
        name = ""
        try:
            if post_body.strip().startswith("{"):
                data = json.loads(post_body)
                res_type = data.get("type", "container").lower()
                action = data.get("action", "stop").lower()
                name = data.get("name", "").strip()
            else:
                q = urllib.parse.parse_qs(post_body or query_str)
                res_type = q.get("type", ["container"])[0].lower()
                action = q.get("action", ["stop"])[0].lower()
                name = q.get("name", [""])[0].strip()
        except Exception as e:
            self._send_json({"status": "error", "error": f"Invalid request body: {str(e)}"}, cb, status=400)
            return

        if not name:
            self._send_json({"status": "error", "error": "Missing resource name/id"}, cb, status=400)
            return

        # Security check: strict regex for container, volume or image name/hash
        if not re.match(r"^[a-zA-Z0-9_.:/-]+$", name):
            self._send_json({"status": "error", "error": f"Invalid resource identifier: {name}"}, cb, status=400)
            return

        cmd = []
        if res_type == "container":
            if action == "start":
                cmd = [PODMAN_BIN, "start", name]
            elif action == "stop":
                cmd = [PODMAN_BIN, "stop", name]
            elif action == "restart":
                cmd = [PODMAN_BIN, "restart", name]
            elif action in ["remove", "rm", "delete"]:
                cmd = [PODMAN_BIN, "rm", "-f", name]
            else:
                self._send_json({"status": "error", "error": f"Unsupported container action: {action}"}, cb, status=400)
                return
        elif res_type == "volume":
            if action in ["remove", "rm", "delete"]:
                cmd = [PODMAN_BIN, "volume", "rm", "-f", name]
            else:
                self._send_json({"status": "error", "error": f"Unsupported volume action: {action}"}, cb, status=400)
                return
        elif res_type == "image":
            if action in ["remove", "rm", "delete", "rmi"]:
                cmd = [PODMAN_BIN, "rmi", "-f", name]
            else:
                self._send_json({"status": "error", "error": f"Unsupported image action: {action}"}, cb, status=400)
                return
        else:
            self._send_json({"status": "error", "error": f"Unsupported resource type: {res_type}"}, cb, status=400)
            return

        try:
            res = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
            if res.returncode == 0:
                self._send_json({
                    "status": "ok",
                    "type": res_type,
                    "action": action,
                    "name": name,
                    "output": res.stdout.strip(),
                    "message": f"Successfully executed '{action}' on {res_type} '{name}'."
                }, cb)
            else:
                err_msg = res.stderr.strip() or res.stdout.strip() or f"Command failed with exit code {res.returncode}"
                self._send_json({
                    "status": "error",
                    "type": res_type,
                    "action": action,
                    "name": name,
                    "error": err_msg
                }, cb, status=500)
        except Exception as e:
            self._send_json({"status": "error", "error": str(e)}, cb, status=500)

    def handle_podman_engine_start(self, post_body, query_str, cb=None):
        """Starts Podman machine (macOS/Windows) and/or platform containers with full execution logging."""
        target = "auto"
        try:
            if post_body.strip().startswith("{"):
                data = json.loads(post_body)
                target = data.get("target", "auto").lower()
            else:
                q = urllib.parse.parse_qs(post_body or query_str)
                target = q.get("target", ["auto"])[0].lower()
        except Exception:
            pass

        eng = get_podman_engine_status()
        log_name = f"podman_startup_{datetime.datetime.now().strftime('%Y%m%d_%H%M%S')}.log"
        log_full = os.path.join(WORKSPACE_DIR, "install_logs", log_name)
        os.makedirs(os.path.join(WORKSPACE_DIR, "install_logs"), exist_ok=True)

        commands_to_run = []
        if target == "machine":
            commands_to_run.append(([PODMAN_BIN, "machine", "start"], "Starting Podman Machine VM"))
        elif target == "containers":
            commands_to_run.append(([os.path.join(WORKSPACE_DIR, "scripts/start-containers.sh")], "Starting Platform Containers"))
        elif target == "machine-stop":
            commands_to_run.append(([PODMAN_BIN, "machine", "stop"], "Stopping Podman Machine VM"))
        else:  # auto / all
            if eng.get("has_machine") and not eng.get("machine_running"):
                commands_to_run.append(([PODMAN_BIN, "machine", "start"], "Starting Podman Machine VM"))
            commands_to_run.append(([os.path.join(WORKSPACE_DIR, "scripts/start-containers.sh")], "Starting Platform Containers"))

        start_t = time.time()
        combined_output = []
        exit_code = 0

        with open(log_full, "w", encoding="utf-8") as lf:
            lf.write(f"=== PODMAN ENGINE & CONTAINER STARTUP: {target.upper()} at {datetime.datetime.now().isoformat()} ===\n\n")
            for cmd, label in commands_to_run:
                lf.write(f"▶️ [{label}]: {' '.join(cmd)}\n")
                try:
                    res = subprocess.run(cmd, cwd=WORKSPACE_DIR, capture_output=True, text=True, timeout=180)
                    out = (res.stdout or "") + ("\n" + res.stderr if res.stderr else "")
                    lf.write(out + "\n\n")
                    combined_output.append(f"[{label}]\n{out.strip()}")
                    if res.returncode != 0:
                        exit_code = res.returncode
                        break
                except Exception as e:
                    err_msg = f"Failed to execute {cmd}: {str(e)}"
                    lf.write(err_msg + "\n\n")
                    combined_output.append(err_msg)
                    exit_code = 1
                    break

        elapsed = round(time.time() - start_t, 2)
        resp_data = {
            "status": "ok" if exit_code == 0 else "error",
            "exit_code": exit_code,
            "duration_s": elapsed,
            "target": target,
            "output": "\n".join(combined_output),
            "log_file": log_name,
            "log_full_path": log_full
        }
        self._send_json(resp_data, cb, status=200 if exit_code == 0 else 500)

    def handle_profile_save(self, post_body, query_str, cb=None):
        rel_p = ""
        new_cnt = ""
        try:
            if post_body.strip().startswith("{"):
                data = json.loads(post_body)
                rel_p = data.get("path", "")
                new_cnt = data.get("content", "")
            else:
                q = urllib.parse.parse_qs(post_body or query_str)
                rel_p = q.get("path", [""])[0]
                new_cnt = q.get("content", [""])[0]
        except Exception:
            pass

        full_p = os.path.normpath(os.path.join(WORKSPACE_DIR, rel_p))
        profiles_root = os.path.join(WORKSPACE_DIR, "config/profiles")

        if not rel_p or not full_p.startswith(profiles_root) or not full_p.endswith(".yaml"):
            self.send_response(400)
            self._send_cors_headers()
            self.end_headers()
            self.wfile.write(b'{"status": "error", "error": "Invalid profile path"}')
            return

        try:
            with open(full_p, "w", encoding="utf-8") as f:
                f.write(new_cnt)

            # Re-generate dev-hub.html in background so ports and metadata reflect changes
            gen_sh = os.path.join(WORKSPACE_DIR, "scripts/internal/generate-dev-hub.sh")
            if os.path.isfile(gen_sh):
                subprocess.Popen([gen_sh], cwd=WORKSPACE_DIR, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

            data = {"status": "ok", "message": f"Profile {os.path.basename(rel_p)} saved successfully!"}
            json_str = json.dumps(data)
            body = f"{cb}({json_str});".encode("utf-8") if cb else json_str.encode("utf-8")
            ct = "application/javascript" if cb else "application/json"
            self.send_response(200)
            self._send_cors_headers()
            self.send_header("Content-Type", ct)
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
        except Exception as e:
            self.send_response(500)
            self._send_cors_headers()
            self.end_headers()
            self.wfile.write(json.dumps({"status": "error", "error": str(e)}).encode("utf-8"))

    def handle_blueprint_create(self, post_body, query_str, cb=None):
        bp_num = ""
        bp_name = ""
        bp_content = ""
        try:
            if post_body.strip().startswith("{"):
                data = json.loads(post_body)
                bp_num = str(data.get("num", "")).strip()
                bp_name = str(data.get("name", "custom")).strip().lower().replace(" ", "-")
                bp_content = data.get("content", "")
            else:
                q = urllib.parse.parse_qs(post_body or query_str)
                bp_num = q.get("num", [""])[0]
                bp_name = q.get("name", ["custom"])[0].lower().replace(" ", "-")
                bp_content = q.get("content", [""])[0]
        except Exception:
            pass

        if not bp_num or not bp_num.isdigit():
            self.send_response(400)
            self._send_cors_headers()
            self.end_headers()
            self.wfile.write(b'{"status": "error", "error": "Invalid blueprint number"}')
            return

        fname = f".env.{bp_num}-{bp_name}"
        target_path = os.path.join(WORKSPACE_DIR, "config/blueprints", fname)
        try:
            with open(target_path, "w", encoding="utf-8") as f:
                f.write(bp_content)

            gen_sh = os.path.join(WORKSPACE_DIR, "scripts/internal/generate-dev-hub.sh")
            if os.path.isfile(gen_sh):
                subprocess.Popen([gen_sh], cwd=WORKSPACE_DIR, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

            data = {"status": "ok", "message": f"Blueprint #{bp_num} ({fname}) created successfully!"}
            json_str = json.dumps(data)
            body = f"{cb}({json_str});".encode("utf-8") if cb else json_str.encode("utf-8")
            ct = "application/javascript" if cb else "application/json"
            self.send_response(200)
            self._send_cors_headers()
            self.send_header("Content-Type", ct)
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
        except Exception as e:
            self.send_response(500)
            self._send_cors_headers()
            self.end_headers()

    def handle_blueprint_save(self, post_body, query_str, cb=None):
        rel_p = ""
        new_cnt = ""
        try:
            if post_body.strip().startswith("{"):
                data = json.loads(post_body)
                rel_p = data.get("path", "") or data.get("file", "")
                new_cnt = data.get("content", "")
            else:
                q = urllib.parse.parse_qs(post_body or query_str)
                rel_p = q.get("path", [""])[0] or q.get("file", [""])[0]
                new_cnt = q.get("content", [""])[0]
        except Exception:
            pass

        if rel_p and not rel_p.startswith("config/blueprints"):
            rel_p = os.path.join("config/blueprints", os.path.basename(rel_p))
        full_p = os.path.normpath(os.path.join(WORKSPACE_DIR, rel_p))
        bp_root = os.path.join(WORKSPACE_DIR, "config/blueprints")

        if not rel_p or not full_p.startswith(bp_root) or not os.path.basename(full_p).startswith(".env."):
            self._send_json({"status": "error", "error": "Invalid blueprint path"}, cb, status=400)
            return

        try:
            with open(full_p, "w", encoding="utf-8") as f:
                f.write(new_cnt)

            gen_sh = os.path.join(WORKSPACE_DIR, "scripts/internal/generate-dev-hub.sh")
            if os.path.isfile(gen_sh):
                subprocess.Popen([gen_sh], cwd=WORKSPACE_DIR, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

            self._send_json({"status": "ok", "message": f"Blueprint {os.path.basename(rel_p)} saved successfully!"}, cb)
        except Exception as e:
            self._send_json({"status": "error", "error": str(e)}, cb, status=500)

    def handle_devops_run(self, post_body, query_str, cb=None):
        cmd_key = ""
        payload = {}
        try:
            if post_body.strip().startswith("{"):
                payload = json.loads(post_body)
                cmd_key = payload.get("command", "")
            else:
                q = urllib.parse.parse_qs(post_body or query_str)
                cmd_key = q.get("command", [""])[0]
                payload = {k: v[0] for k, v in q.items()}
        except Exception:
            pass

        if cmd_key not in DEVOPS_WHITELIST:
            self._send_json({"status": "error", "error": f"Command '{cmd_key}' is not in allowed whitelist"}, cb, status=400)
            return

        # Mutex lock: Prevent concurrent execution of lifecycle-altering operations
        lock_file = os.path.join(WORKSPACE_DIR, ".setup_in_progress")
        is_lifecycle_op = cmd_key.startswith("setup-") or cmd_key.startswith("reset-")
        if is_lifecycle_op and os.path.isfile(lock_file):
            self._send_json({"status": "error", "error": "Teine elutsükli toiming on juba käimas (.setup_in_progress lukk aktiivne)."}, cb, status=409)
            return

        cmd_args = list(DEVOPS_WHITELIST[cmd_key])

        # Security Guardrail: Parameter sanitization with strict regex (No shell injection)
        if cmd_key == "create-dev-user" and "username" in payload:
            user_val = str(payload["username"]).strip()
            if not re.match(r"^[a-zA-Z0-9_]{3,30}$", user_val):
                self._send_json({"status": "error", "error": "Vigane kasutajanimi! Lubatud on ainult tähed, numbrid ja alakriips (3-30 märki)."}, cb, status=400)
                return
            cmd_args = ["./scripts/create-developer.sh", user_val]

        if cmd_key == "sqlcl-cli" and "alias" in payload:
            alias_val = str(payload["alias"]).strip()
            if not re.match(r"^/?[a-zA-Z0-9_@]+$", alias_val):
                self._send_json({"status": "error", "error": "Vigane Wallet alias süntaks!"}, cb, status=400)
                return
            cmd_args = ["./scripts/sqlcl.sh", alias_val]

        start_time = time.time()
        timeout_sec = 300 if is_lifecycle_op else 120

        try:
            res = subprocess.run(
                cmd_args,
                cwd=WORKSPACE_DIR,
                capture_output=True,
                text=True,
                timeout=timeout_sec
            )
            elapsed_sec = round(time.time() - start_time, 2)
            out_comb = res.stdout + ("\n" + res.stderr if res.stderr else "")

            data = {
                "status": "ok",
                "ok": (res.returncode == 0),
                "command": cmd_key,
                "cmd_str": " ".join(cmd_args),
                "exit_code": res.returncode,
                "duration_s": elapsed_sec,
                "stdout": res.stdout,
                "stderr": res.stderr,
                "output": out_comb
            }
            log_fn = f"devops_{cmd_key.replace('-', '_')}.log"
            log_full = os.path.join(WORKSPACE_DIR, "install_logs", log_fn)
            try:
                os.makedirs(os.path.join(WORKSPACE_DIR, "install_logs"), exist_ok=True)
                with open(log_full, "w", encoding="utf-8") as f:
                    f.write(out_comb)
                data["log_file"] = log_fn
                data["log_relative_path"] = f"install_logs/{log_fn}"
                data["log_full_path"] = log_full

                # Audit Trail Invariant (strictly local in install_logs/):
                audit_fn = os.path.join(WORKSPACE_DIR, "install_logs", "audit_events.jsonl")
                audit_entry = {
                    "timestamp": datetime.datetime.now().isoformat(),
                    "command": cmd_key,
                    "cmd_str": " ".join(cmd_args),
                    "exit_code": res.returncode,
                    "duration_s": elapsed_sec
                }
                with open(audit_fn, "a", encoding="utf-8") as af:
                    af.write(json.dumps(audit_entry) + "\n")
            except Exception:
                pass

            self._send_json(data, cb, status=200 if res.returncode == 0 else 500)
        except subprocess.TimeoutExpired:
            self._send_json({"status": "error", "error": f"Käsu täitmine aegus (üle {timeout_sec}s)"}, cb, status=504)
        except Exception as e:
            self._send_json({"status": "error", "error": str(e)}, cb, status=500)

    def handle_resolve_conflict(self, query_str, cb=None):
        params = urllib.parse.parse_qs(query_str)
        module = params.get("module", [""])[0]
        port_str = params.get("new_port", [""])[0]

        if not module or not port_str:
            self.send_response(400)
            self._send_cors_headers()
            self.end_headers()
            self.wfile.write(b'{"error": "Missing module or new_port"}')
            return

        try:
            new_port = int(port_str)
            ok, msg = resolve_port_conflict(module, new_port)
            data = {
                "status": "ok" if ok else "error",
                "module": module,
                "new_port": new_port,
                "message": msg
            }
            json_str = json.dumps(data)
            if cb:
                body = f"{cb}({json_str});".encode("utf-8")
                ct = "application/javascript"
            else:
                body = json_str.encode("utf-8")
                ct = "application/json"

            self.send_response(200 if ok else 500)
            self._send_cors_headers()
            self.send_header("Content-Type", ct)
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
        except Exception as e:
            self.send_response(500)
            self._send_cors_headers()
            self.end_headers()
            self.wfile.write(json.dumps({"error": str(e)}).encode("utf-8"))

    def handle_toggle(self, query_str, cb=None):
        raw_str = (query_str or "").strip()
        module = ""
        action = "start"
        lang = ""
        target_db = ""
        user = ""
        if raw_str.startswith("{"):
            try:
                jdata = json.loads(raw_str)
                module = str(jdata.get("module", ""))
                action = str(jdata.get("action", "start")).lower()
                lang = str(jdata.get("lang", ""))
                target_db = str(jdata.get("target_db", "") or jdata.get("db", ""))
                user = str(jdata.get("user", "") or jdata.get("username", ""))
            except Exception:
                pass
        if not module:
            params = urllib.parse.parse_qs(raw_str)
            module = params.get("module", [""])[0]
            action = params.get("action", ["start"])[0].lower()
            if not lang:
                lang = params.get("lang", [""])[0]
            if not target_db:
                target_db = params.get("target_db", [""])[0] or params.get("db", [""])[0]
            if not user:
                user = params.get("user", [""])[0] or params.get("username", [""])[0]

        if not module and action not in ["rotate", "rotate-password"]:
            self._send_json({"status": "error", "error": "Missing module"}, cb, status=400)
            return

        # Core Base Protection: db-proxy and app-ords stopping requires confirmation
        CORE_PROTECTED = ["core", "proxy", "db-proxy", "ords", "app-ords", "0"]
        confirmed = False
        try:
            if raw_str.startswith("{"):
                confirmed = bool(json.loads(raw_str).get("confirmed", False))
        except Exception:
            pass
        if not confirmed and params.get("confirmed", ["false"])[0].lower() in ["true", "1"]:
            confirmed = True

        if action in ["stop", "down"] and (str(module).lower() in CORE_PROTECTED or str(module) == "0"):
            if not confirmed:
                self._send_json({
                    "status": "error",
                    "requires_confirmation": True,
                    "error": "Core Base Protection: Blueprint #0 (db-proxy and app-ords) is the central Core Base. Stopping it requires confirmation (&confirmed=true)."
                }, cb, status=403)
                return

        if action in ["setup", "activate", "switch", "deploy", "start"] and str(module).isdigit():
            # Check available RAM safety buffer (< 2.0 GB)
            res_mem = get_system_resources()
            if res_mem.get("avail_ram_gb", 8.0) < 2.0 and not (raw_str.startswith("{") and json.loads(raw_str).get("force", False)):
                self._send_json({
                    "status": "error",
                    "error": f"Insufficient available RAM ({res_mem.get('avail_ram_gb')} GB available, minimum 2.0 GB required). Close unused stacks to free memory."
                }, cb, status=400)
                return

            # Check if setup is already in progress for this blueprint
            setup_prog = get_setup_in_progress()
            if setup_prog and str(setup_prog.get("blueprint")) == str(module):
                self._send_json({
                    "status": "ok",
                    "task_running": True,
                    "task": f"setup_bp_{module}",
                    "log_file": f"setup_bp_{module}_latest.log",
                    "log_relative_path": f"install_logs/setup_bp_{module}_latest.log",
                    "message": f"Blueprint #{module} paigaldus juba käib taustal."
                }, cb, status=200)
                return

            # Check duplicate blueprint execution ONLY IF all containers are running and healthy!
            bp_files = glob.glob(os.path.join(WORKSPACE_DIR, f"config/blueprints/.env.{module}-*"))
            if bp_files and parse_blueprint_env_and_metadata and not setup_prog:
                try:
                    meta = parse_blueprint_env_and_metadata(bp_files[0], int(module))
                    cnames = meta.get("container_names", [])
                    _, running_containers, _, c_health, _ = get_live_container_status()
                    if cnames and all(c in running_containers and c_health.get(c) == "healthy" for c in cnames):
                        self._send_json({
                            "status": "ok",
                            "already_active": True,
                            "output": f"Blueprint #{module} is already ACTIVE and healthy ({', '.join(cnames)}).\nKui on probleeme, käivita: Taaskäivita & Uuenda (./scripts/deploy-blueprint.sh -b {module} -u)",
                            "message": f"Blueprint #{module} is already ACTIVE. Kui on probleeme, käivita: Taaskäivita & Uuenda (./scripts/deploy-blueprint.sh -b {module} -u)"
                        }, cb, status=200)
                        return
                except Exception:
                    pass

            cmd = [os.path.join(WORKSPACE_DIR, "scripts/setup-all.sh"), "-b", str(module), "-y"]
            if lang:
                cmd.extend(["--lang", lang])
        elif action in ["dry-run", "dryrun"] and str(module).isdigit():
            cmd = [os.path.join(WORKSPACE_DIR, "scripts/deploy-blueprint.sh"), "-b", str(module), "--dry-run"]
            if lang:
                cmd.extend(["--lang", lang])
        elif action in ["rotate", "rotate-password"]:
            t_db = target_db or (f"db-{module}" if str(module).isalnum() else "db-proxy")
            t_user = user or "dev"
            cmd = [os.path.join(WORKSPACE_DIR, "scripts/rotate-password.sh"), t_db, t_user]
        elif action in ["info", "blueprint-info"] and str(module).isdigit():
            cmd = [os.path.join(WORKSPACE_DIR, "scripts/blueprint-info.sh"), str(module)]
        elif action == "restart" and str(module).isdigit():
            cmd = [os.path.join(WORKSPACE_DIR, "scripts/deploy-blueprint.sh"), "-b", str(module), "-u"]
            if lang:
                cmd.extend(["--lang", lang])
        elif action in ["fast-start", "fast", "faststart"] and str(module).isdigit():
            cmd = [os.path.join(WORKSPACE_DIR, "scripts/setup-all.sh"), "-b", str(module), "--fast", "-y"]
            if lang:
                cmd.extend(["--lang", lang])
        elif action == "stop" and str(module).isdigit():
            bp_files = glob.glob(os.path.join(WORKSPACE_DIR, f"config/blueprints/.env.{module}-*"))
            to_stop = []
            if int(module) == 0:
                to_stop = ["db-proxy", "app-ords"]
            elif bp_files and parse_blueprint_env_and_metadata:
                try:
                    meta = parse_blueprint_env_and_metadata(bp_files[0], int(module))
                    cnames = meta.get("container_names", [])
                    to_stop = [c for c in cnames if c not in ["db-proxy", "app-ords"]]
                except Exception as e:
                    print(f"Error parsing blueprint {module} for stop: {e}", file=sys.stderr)
            if not to_stop and bp_files and int(module) != 0:
                with open(bp_files[0], "r", encoding="utf-8") as f:
                    for line in f:
                        line = line.strip()
                        if line.startswith("DB_") and "=" in line:
                            v = line.split("=")[1].strip().strip('"\'')
                            if v and v.upper() != "NONE":
                                to_stop.append(v)
                        elif "PUBLISHER_PROFILE=" in line and "NONE" not in line:
                            to_stop.append("app-publisher")
                        elif "FORMS_PROFILE=" in line and "NONE" not in line:
                            to_stop.append("app-forms")
                        elif "FORMS_PUBLISHER_PROFILE=" in line and "NONE" not in line:
                            to_stop.append("app-forms-publisher")
                        elif "WEB_IDE_PROFILE=" in line and "NONE" not in line:
                            to_stop.append("web-ide-dev")
                        elif "PUBLISHER_DESIGNER_PROFILE=" in line and "NONE" not in line:
                            to_stop.append("app-publisher-designer")
                to_stop = [c for c in set(to_stop) if c not in ["db-proxy", "app-ords"]]

            if to_stop:
                # Map any legacy aliases if still present
                to_stop = ["app-publisher" if c == "oracle-publisher-dev" else c for c in to_stop]
                to_stop = list(dict.fromkeys(to_stop))
                # Only stop containers that are actually running to prevent "no such container" error
                try:
                    _, running_containers, _, _, _ = get_live_container_status()
                    active_to_stop = [c for c in to_stop if c in running_containers]
                except Exception:
                    active_to_stop = to_stop

                if active_to_stop:
                    cmd = [PODMAN_BIN, "stop"] + active_to_stop
                else:
                    cmd = ["echo", f"Containers ({', '.join(to_stop)}) are already stopped."]
            else:
                cmd = ["echo", "No non-core containers to stop"]
        elif module in ["alise", "db-alise"]:
            if action == "start":
                cmd = [PODMAN_BIN, "start", "db-alise"]
            elif action == "restart":
                cmd = [PODMAN_BIN, "restart", "db-alise"]
            else:
                cmd = [PODMAN_BIN, "stop", "db-alise"]
        elif module in ["web-ide", "webide"]:
            if action == "start":
                has_ide = subprocess.run([PODMAN_BIN, "container", "exists", "web-ide-dev"], capture_output=True).returncode == 0
                if has_ide:
                    cmd = [PODMAN_BIN, "start", "web-ide-dev"]
                else:
                    cmd = [os.path.join(WORKSPACE_DIR, "scripts/module-toggle.sh"), "start", "web-ide"]
            elif action == "restart":
                cmd = [PODMAN_BIN, "restart", "web-ide-dev"]
            else:
                cmd = [PODMAN_BIN, "stop", "web-ide-dev"]
        else:
            cmd = [os.path.join(WORKSPACE_DIR, "scripts/module-toggle.sh"), action, module]

        # 🛡️ ARCHITECTURAL GUARDRAIL (Rule 12 & Invariant 3.6):
        # Long-running operations (setup, activate, deploy, switch, restart, fast-start) MUST NEVER be run synchronously!
        # Synchronous blocking HTTP requests abort with "signal is aborted without reason" at 300s.
        # Dispatch asynchronously via subprocess.Popen, stream to install_logs, and return immediately.
        if action in ["setup", "activate", "switch", "deploy", "restart", "fast-start", "fast", "faststart"] and str(module).isdigit():
            log_name = f"setup_bp_{module}_latest.log" if action not in ["restart", "fast-start", "fast", "faststart"] else f"{action}_bp_{module}_latest.log"
            log_dir = os.path.join(WORKSPACE_DIR, "install_logs")
            os.makedirs(log_dir, exist_ok=True)
            log_path = os.path.join(log_dir, log_name)

            cmd_str = " ".join(cmd)
            full_shell_cmd = f"{cmd_str} >> '{log_path}' 2>&1"
            proc = subprocess.Popen(["/bin/bash", "-c", full_shell_cmd], cwd=WORKSPACE_DIR, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            task_key = f"setup_bp_{module}"
            ACTIVE_TASKS[task_key] = {
                "proc": proc,
                "blueprint": str(module),
                "log_file": log_name,
                "start_time": time.time(),
                "action": action,
                "cmd": cmd_str
            }
            ACTIVE_TASKS["setup"] = ACTIVE_TASKS[task_key]
            self._send_json({
                "status": "ok",
                "async": True,
                "task": task_key,
                "pid": proc.pid,
                "log_file": log_name,
                "log_relative_path": f"install_logs/{log_name}",
                "message": f"Blueprint #{module} {action} started in background"
            }, cb, status=200)
            return

        try:
            start_t = time.time()
            timeout_sec = 120
            res = subprocess.run(cmd, cwd=WORKSPACE_DIR, capture_output=True, text=True, timeout=timeout_sec)
            elapsed_sec = round(time.time() - start_t, 1)

            output_text = res.stdout or ""
            if res.stderr:
                output_text = (output_text + "\n" + res.stderr) if output_text else res.stderr

            is_ok = (res.returncode == 0)
            if action == "stop" and not is_ok:
                if any(x in output_text.lower() for x in ["no such container", "not running", "is not running"]):
                    is_ok = True

            log_info = find_latest_log_for_blueprint(WORKSPACE_DIR, module) if (find_latest_log_for_blueprint and str(module).isdigit()) else None
            data = {
                "status": "ok" if is_ok else "error",
                "ok": is_ok,
                "exit_code": res.returncode,
                "module": module,
                "action": action,
                "cmd": " ".join(cmd),
                "elapsed_seconds": elapsed_sec,
                "output": output_text,
                "log_file": log_info["file"] if log_info else None,
                "log_relative_path": log_info["relative_path"] if log_info else None,
                "log_full_path": log_info["full_path"] if log_info else None,
                "latest_log": log_info,
                "message": f"Module {module} {action} completed in {elapsed_sec}s."
            }
            self._send_json(data, cb, status=200 if is_ok else 500)
        except subprocess.TimeoutExpired:
            log_info = find_latest_log_for_blueprint(WORKSPACE_DIR, module) if (find_latest_log_for_blueprint and str(module).isdigit()) else None
            self._send_json({
                "status": "error",
                "ok": False,
                "error": f"Command timed out after {timeout_sec}s",
                "cmd": " ".join(cmd),
                "log_file": log_info["file"] if log_info else None,
                "log_relative_path": log_info["relative_path"] if log_info else None,
                "log_full_path": log_info["full_path"] if log_info else None,
                "latest_log": log_info
            }, cb, status=504)
        except Exception as e:
            log_info = find_latest_log_for_blueprint(WORKSPACE_DIR, module) if (find_latest_log_for_blueprint and str(module).isdigit()) else None
            self._send_json({
                "status": "error",
                "ok": False,
                "error": str(e),
                "cmd": " ".join(cmd),
                "log_file": log_info["file"] if log_info else None,
                "log_relative_path": log_info["relative_path"] if log_info else None,
                "log_full_path": log_info["full_path"] if log_info else None,
                "latest_log": log_info
            }, cb, status=500)

    def handle_snapshot_restore(self, post_body, query_str, cb=None):
        payload = {}
        try:
            if post_body.strip().startswith("{"):
                payload = json.loads(post_body)
            else:
                q = urllib.parse.parse_qs(post_body or query_str)
                payload = {k: v[0] for k, v in q.items()}
        except Exception:
            pass

        file_name = payload.get("file", "").strip()
        bp_id = payload.get("blueprint", "0")

        cmd = [os.path.join(WORKSPACE_DIR, "scripts/snapshots/restore-golden-snapshots.sh"), "--force"]
        if file_name:
            cmd += ["--file", file_name]
        else:
            cmd += ["--auto", "-b", str(bp_id)]

        try:
            start_t = time.time()
            timeout_sec = 420
            res = subprocess.run(cmd, cwd=WORKSPACE_DIR, capture_output=True, text=True, timeout=timeout_sec)
            elapsed_sec = round(time.time() - start_t, 1)
            log_info = find_latest_log_for_blueprint(WORKSPACE_DIR, bp_id) if find_latest_log_for_blueprint else None
            data = {
                "status": "ok" if res.returncode == 0 else "error",
                "ok": (res.returncode == 0),
                "exit_code": res.returncode,
                "cmd": " ".join(cmd),
                "elapsed_seconds": elapsed_sec,
                "output": res.stdout + ("\n" + res.stderr if res.stderr else ""),
                "log_file": log_info["file"] if log_info else None,
                "log_relative_path": log_info["relative_path"] if log_info else None,
                "log_full_path": log_info["full_path"] if log_info else None,
                "latest_log": log_info
            }
            self._send_json(data, cb, status=200 if res.returncode == 0 else 500)
        except subprocess.TimeoutExpired:
            log_info = find_latest_log_for_blueprint(WORKSPACE_DIR, bp_id) if find_latest_log_for_blueprint else None
            self._send_json({
                "status": "error",
                "ok": False,
                "error": f"Restore command timed out after 420s",
                "cmd": " ".join(cmd),
                "log_file": log_info["file"] if log_info else None,
                "log_relative_path": log_info["relative_path"] if log_info else None,
                "log_full_path": log_info["full_path"] if log_info else None,
                "latest_log": log_info
            }, cb, status=504)
        except Exception as e:
            log_info = find_latest_log_for_blueprint(WORKSPACE_DIR, bp_id) if find_latest_log_for_blueprint else None
            self._send_json({
                "status": "error",
                "ok": False,
                "error": str(e),
                "cmd": " ".join(cmd),
                "log_file": log_info["file"] if log_info else None,
                "log_relative_path": log_info["relative_path"] if log_info else None,
                "log_full_path": log_info["full_path"] if log_info else None,
                "latest_log": log_info
            }, cb, status=500)

    def handle_snapshot_create(self, post_body, query_str, cb=None):
        payload = {}
        try:
            if post_body.strip().startswith("{"):
                payload = json.loads(post_body)
            else:
                q = urllib.parse.parse_qs(post_body or query_str)
                payload = {k: v[0] for k, v in q.items()}
        except Exception:
            pass

        bp_id = payload.get("blueprint", "0")
        tag = payload.get("tag", "").strip()
        desc = payload.get("desc", "").strip()

        cmd = [os.path.join(WORKSPACE_DIR, "scripts/snapshots/create-golden-snapshots.sh"), "-b", str(bp_id), "--force"]
        if tag:
            cmd += ["--tag", tag]
        if desc:
            cmd += ["--desc", desc]

        try:
            start_t = time.time()
            timeout_sec = 360
            res = subprocess.run(cmd, cwd=WORKSPACE_DIR, capture_output=True, text=True, timeout=timeout_sec)
            elapsed_sec = round(time.time() - start_t, 1)

            created_file = ""
            sz_mb = 0
            size_human = ""
            snap_dir = os.path.join(WORKSPACE_DIR, "golden-snapshots")
            if os.path.isdir(snap_dir):
                files = sorted(glob.glob(os.path.join(snap_dir, "*.tar.gz")), key=os.path.getmtime, reverse=True)
                if files:
                    created_file = os.path.basename(files[0])
                    try:
                        sz_bytes = os.path.getsize(files[0])
                        sz_mb = round(sz_bytes / (1024 * 1024), 1)
                        size_human = f"{sz_mb} MB" if sz_mb < 1024 else f"{round(sz_mb/1024, 2)} GB"
                    except Exception:
                        pass

            log_info = find_latest_log_for_blueprint(WORKSPACE_DIR, bp_id) if find_latest_log_for_blueprint else None
            data = {
                "status": "ok" if res.returncode == 0 else "error",
                "ok": (res.returncode == 0),
                "exit_code": res.returncode,
                "cmd": " ".join(cmd),
                "created_file": created_file,
                "size_mb": sz_mb,
                "size_human": size_human,
                "elapsed_seconds": elapsed_sec,
                "output": res.stdout + ("\n" + res.stderr if res.stderr else ""),
                "log_file": log_info["file"] if log_info else None,
                "log_relative_path": log_info["relative_path"] if log_info else None,
                "log_full_path": log_info["full_path"] if log_info else None,
                "latest_log": log_info
            }
            self._send_json(data, cb, status=200 if res.returncode == 0 else 500)
        except subprocess.TimeoutExpired:
            log_info = find_latest_log_for_blueprint(WORKSPACE_DIR, bp_id) if find_latest_log_for_blueprint else None
            self._send_json({
                "status": "error",
                "ok": False,
                "error": f"Create snapshot timed out after 360s",
                "cmd": " ".join(cmd),
                "log_file": log_info["file"] if log_info else None,
                "log_relative_path": log_info["relative_path"] if log_info else None,
                "log_full_path": log_info["full_path"] if log_info else None,
                "latest_log": log_info
            }, cb, status=504)
        except Exception as e:
            log_info = find_latest_log_for_blueprint(WORKSPACE_DIR, bp_id) if find_latest_log_for_blueprint else None
            self._send_json({
                "status": "error",
                "ok": False,
                "error": str(e),
                "cmd": " ".join(cmd),
                "log_file": log_info["file"] if log_info else None,
                "log_relative_path": log_info["relative_path"] if log_info else None,
                "log_full_path": log_info["full_path"] if log_info else None,
                "latest_log": log_info
            }, cb, status=500)

    def handle_snapshot_delete(self, post_body, query_str, cb=None):
        payload = {}
        try:
            if post_body.strip().startswith("{"):
                payload = json.loads(post_body)
            else:
                q = urllib.parse.parse_qs(post_body or query_str)
                payload = {k: v[0] for k, v in q.items()}
        except Exception:
            pass

        file_name = payload.get("file", "").strip()
        if not file_name or "/" in file_name or ".." in file_name or not file_name.endswith(".tar.gz"):
            self._send_json({"status": "error", "error": "Invalid snapshot filename"}, cb, status=400)
            return

        if file_name.endswith("_latest.tar.gz") or file_name == "bp_0_latest.tar.gz":
            self._send_json({"status": "error", "error": "Protected baseline snapshot cannot be deleted"}, cb, status=400)
            return

        target_file = os.path.join(WORKSPACE_DIR, "golden-snapshots", file_name)
        meta_file = target_file[:-7] + ".meta.json"

        try:
            deleted = False
            if os.path.isfile(target_file):
                os.remove(target_file)
                deleted = True
            if os.path.isfile(meta_file):
                os.remove(meta_file)
            if deleted:
                self._send_json({"status": "ok", "message": f"Snapshot {file_name} deleted"}, cb)
            else:
                self._send_json({"status": "error", "error": "File not found"}, cb, status=404)
        except Exception as e:
            self._send_json({"status": "error", "error": str(e)}, cb, status=500)

    def handle_task_status(self, query_str, cb=None):
        q = urllib.parse.parse_qs(query_str)
        task_name = q.get("task", ["reset_deep"])[0]
        task_info = ACTIVE_TASKS.get(task_name)

        # Fallback for generic "setup": find any active setup task
        if not task_info and task_name == "setup":
            for k, v in ACTIVE_TASKS.items():
                if k.startswith("setup_bp_") and v.get("proc") and v["proc"].poll() is None:
                    task_info = v
                    task_name = k
                    break

        if not task_info:
            # Check if setup is running via CLI (detected via .setup_in_progress)
            setup_prog = get_setup_in_progress()
            if setup_prog and (task_name.startswith("setup") or str(setup_prog.get("blueprint")) in task_name):
                bp_id = setup_prog.get("blueprint")
                log_name = f"setup_bp_{bp_id}_latest.log"
                elapsed = round(time.time() - setup_prog.get("start_time", time.time()), 1)
                log_full_path = os.path.join(WORKSPACE_DIR, "install_logs", log_name)
                tail_lines = []
                if os.path.isfile(log_full_path):
                    try:
                        with open(log_full_path, "r", encoding="utf-8", errors="replace") as lf:
                            tail_lines = [ln.rstrip("\r\n") for ln in lf.readlines()[-15:]]
                    except Exception:
                        pass
                self._send_json({
                    "status": "ok",
                    "task": f"setup_bp_{bp_id}",
                    "state": "running",
                    "exit_code": None,
                    "log_file": log_name,
                    "log_relative_path": f"install_logs/{log_name}",
                    "log_tail": tail_lines,
                    "blueprint": bp_id,
                    "elapsed_seconds": elapsed,
                    "duration": elapsed,
                    "external_cli": True
                }, cb)
                return

            self._send_json({"status": "ok", "task": task_name, "state": "unknown", "message": "No active task found"}, cb)
            return

        proc = task_info.get("proc")
        poll_res = proc.poll() if proc else 0
        if poll_res is None:
            state = "running"
        elif poll_res == 0:
            state = "completed"
        else:
            state = "failed"

        if task_info.get("type") == "test" and poll_res is not None and not task_info.get("recorded"):
            record_test_execution(task_info, poll_res)

        duration = round(time.time() - task_info.get("start_time", time.time()), 1)
        log_file = task_info.get("log_file")
        log_full_path = os.path.join(WORKSPACE_DIR, "install_logs", log_file) if log_file else None

        tail_lines = []
        full_content = ""
        if log_full_path and os.path.isfile(log_full_path):
            try:
                with open(log_full_path, "r", encoding="utf-8", errors="replace") as lf:
                    lines = lf.readlines()
                    tail_lines = [ln.rstrip("\r\n") for ln in lines[-30:]]
                    full_content = "".join(lines)
            except Exception:
                pass

        res_data = {
            "status": "ok",
            "task": task_name,
            "state": state,
            "exit_code": poll_res,
            "stdout": full_content,
            "log_file": log_file,
            "log_relative_path": f"install_logs/{log_file}",
            "log_tail": tail_lines,
            "blueprint": task_info.get("blueprint"),
            "elapsed_seconds": duration,
            "duration": duration
        }
        if state == "failed":
            res_data["error"] = f"Task {task_name} exited with non-zero exit code {poll_res}"
        self._send_json(res_data, cb)

    def handle_reset_deep(self, post_body, query_str, cb=None):
        payload = {}
        try:
            if post_body.strip().startswith("{"):
                payload = json.loads(post_body)
            else:
                q = urllib.parse.parse_qs(post_body or query_str)
                payload = {k: v[0] for k, v in q.items()}
        except Exception:
            pass

        bp_id = str(payload.get("blueprint", "0")).strip()
        lang = str(payload.get("lang", "")).strip()
        log_name = f"reset_deep_bp_{bp_id}_latest.log"
        log_dir = os.path.join(WORKSPACE_DIR, "install_logs")
        os.makedirs(log_dir, exist_ok=True)
        log_path = os.path.join(log_dir, log_name)

        try:
            with open(log_path, "w", encoding="utf-8") as f:
                f.write(f"=== Starting Deep Reset & Cold Rebuild for Blueprint {bp_id} at {time.strftime('%Y-%m-%d %H:%M:%S')} ===\n\n")
        except Exception:
            pass

        cmd = f"./scripts/reset-all.sh -y >> '{log_path}' 2>&1 && ./scripts/setup-all.sh -b {bp_id} -y"
        if lang:
            cmd += f" --lang {lang}"
        cmd += f" >> '{log_path}' 2>&1"

        try:
            proc = subprocess.Popen(["/bin/bash", "-c", cmd], cwd=WORKSPACE_DIR, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            ACTIVE_TASKS["reset_deep"] = {
                "proc": proc,
                "blueprint": bp_id,
                "log_file": log_name,
                "start_time": time.time()
            }
            self._send_json({
                "status": "ok",
                "action": "reset_deep",
                "task": "reset_deep",
                "pid": proc.pid,
                "log_file": log_name,
                "log_relative_path": f"install_logs/{log_name}",
                "message": "Deep reset and full cold rebuild started in background"
            }, cb)
        except Exception as e:
            self._send_json({"status": "error", "error": str(e)}, cb, status=500)

    def handle_tests_report_content(self, query_str, cb=None):
        q = urllib.parse.parse_qs(query_str)
        rel_path = q.get("file", [""])[0]
        if not rel_path:
            self._send_json({"status": "error", "error": "No file specified"}, cb, status=400)
            return

        clean_p = os.path.normpath(rel_path).lstrip("/\\")
        # Security: allow reading only from tests/reports/ or install_logs/
        if not (clean_p.startswith("tests/reports/") or clean_p.startswith("install_logs/")):
            self._send_json({"status": "error", "error": "Access denied. Path must be inside tests/reports/ or install_logs/"}, cb, status=403)
            return

        full_p = os.path.join(WORKSPACE_DIR, clean_p)
        if not os.path.isfile(full_p):
            self._send_json({"status": "error", "error": f"File not found: {clean_p}"}, cb, status=404)
            return

        try:
            with open(full_p, "r", encoding="utf-8", errors="replace") as f:
                content = f.read()
            self._send_json({"status": "ok", "file": clean_p, "content": content}, cb)
        except Exception as e:
            self._send_json({"status": "error", "error": str(e)}, cb, status=500)

    def handle_test_script_content(self, query_str, cb=None):
        q = urllib.parse.parse_qs(query_str)
        script_name = q.get("script", [""])[0].strip()
        if not script_name:
            self._send_json({"status": "error", "error": "No script specified"}, cb, status=400)
            return

        parts = script_name.strip().split()
        sname = os.path.basename(parts[0]) if parts else ""
        if not sname.endswith(".sh") or not re.match(r"^[a-zA-Z0-9._-]+$", sname):
            self._send_json({"status": "error", "error": "Invalid script filename"}, cb, status=400)
            return

        candidate_paths = [
            os.path.join(WORKSPACE_DIR, "tests", "unit", sname),
            os.path.join(WORKSPACE_DIR, "tests", "integration", sname),
            os.path.join(WORKSPACE_DIR, "tests", sname),
            os.path.join(WORKSPACE_DIR, "scripts", sname),
            os.path.join(WORKSPACE_DIR, "scripts", "internal", sname)
        ]

        found_path = None
        for p in candidate_paths:
            if os.path.isfile(p):
                found_path = p
                break

        if not found_path:
            self._send_json({"status": "error", "error": f"Script not found: {sname}"}, cb, status=404)
            return

        try:
            with open(found_path, "r", encoding="utf-8", errors="replace") as f:
                content = f.read()
            rel_p = os.path.relpath(found_path, WORKSPACE_DIR)
            doc_info = get_script_doc_reference(sname) if get_script_doc_reference else None
            self._send_json({
                "status": "ok",
                "script": sname,
                "path": rel_p,
                "content": content,
                "doc": doc_info,
                "lines": len(content.splitlines()),
                "size_bytes": os.path.getsize(found_path)
            }, cb)
        except Exception as e:
            self._send_json({"status": "error", "error": str(e)}, cb, status=500)

    def handle_file_raw(self, query_str, cb=None):
        q = urllib.parse.parse_qs(query_str)
        req_path = q.get("path", [""])[0].strip()
        if not req_path:
            self._send_json({"status": "error", "error": "No file path specified"}, cb, status=400)
            return

        # Sanitize path to prevent directory traversal
        clean_rel = os.path.normpath(req_path).lstrip("/\\")
        if clean_rel.startswith("..") or "/../" in clean_rel or "\\..\\" in clean_rel:
            self._send_json({"status": "error", "error": "Invalid file path traversal"}, cb, status=403)
            return

        # Zero-Trust Security check (Rule 5): Never serve unencrypted secrets, wallets, or sensitive files
        forbidden_patterns = [r"\.env($|\.)", r"wallet", r"\.sso$", r"\.p12$", r"\.key$", r"\.git/"]
        for pat in forbidden_patterns:
            if re.search(pat, clean_rel, re.IGNORECASE):
                self._send_json({"status": "error", "error": "Access denied to protected credential or system files"}, cb, status=403)
                return

        target_file = os.path.abspath(os.path.join(WORKSPACE_DIR, clean_rel))
        if not target_file.startswith(WORKSPACE_DIR) or not os.path.isfile(target_file):
            self._send_json({"status": "error", "error": f"File not found: {clean_rel}"}, cb, status=404)
            return

        try:
            if os.path.getsize(target_file) > 1024 * 1024:
                self._send_json({"status": "error", "error": "File exceeds preview size limit (1MB)"}, cb, status=400)
                return

            with open(target_file, "r", encoding="utf-8", errors="replace") as f:
                content = f.read()

            self._send_json({
                "status": "ok",
                "path": clean_rel,
                "filename": os.path.basename(target_file),
                "content": content,
                "lines": len(content.splitlines()),
                "size_bytes": os.path.getsize(target_file)
            }, cb)
        except Exception as e:
            self._send_json({"status": "error", "error": str(e)}, cb, status=500)

    def handle_test_run(self, post_body, query_str, cb=None):
        suite = "unit"
        test_script = ""
        dry_run = False
        lang = "en"
        tiers = []
        try:
            if post_body.strip().startswith("{"):
                data = json.loads(post_body)
                suite = data.get("suite", "unit")
                test_script = (data.get("script") or data.get("test") or "").strip()
                lang = (data.get("lang") or "en").strip().lower()
                dry_run = bool(data.get("dry_run", False))
                tiers_val = data.get("tiers", [])
                if isinstance(tiers_val, list):
                    tiers = [str(t).strip() for t in tiers_val if str(t).strip()]
                elif isinstance(tiers_val, str):
                    tiers = [t.strip() for t in tiers_val.split(",") if t.strip()]
            else:
                q = urllib.parse.parse_qs(post_body or query_str)
                suite = q.get("suite", ["unit"])[0]
                test_script = (q.get("script", [""])[0] or q.get("test", [""])[0]).strip()
                lang = q.get("lang", ["en"])[0].strip().lower()
                dry_run = q.get("dry_run", ["false"])[0].lower() in ["1", "true", "yes"]
                tiers_str = q.get("tiers", [""])[0]
                if tiers_str:
                    tiers = [t.strip() for t in tiers_str.split(",") if t.strip()]
        except Exception:
            pass

        cmd = []
        target_label = suite
        if test_script:
            parts = test_script.strip().split()
            script_file = os.path.basename(parts[0]) if parts else ""
            extra_args = parts[1:] if len(parts) > 1 else []
            target_label = f"{suite} / {test_script}"
            if not script_file.endswith(".sh") or not re.match(r"^[a-zA-Z0-9._-]+$", script_file):
                self._send_json({"status": "error", "error": "Invalid test script filename"}, cb, status=400)
                return

            p_unit = os.path.join(WORKSPACE_DIR, "tests", "unit", script_file)
            p_integ = os.path.join(WORKSPACE_DIR, "tests", "integration", script_file)
            p_tests = os.path.join(WORKSPACE_DIR, "tests", script_file)
            p_scripts = os.path.join(WORKSPACE_DIR, "scripts", script_file)
            if suite == "security_audit" and os.path.isfile(p_scripts):
                cmd = [p_scripts] + extra_args
            elif os.path.isfile(p_unit):
                cmd = [p_unit] + extra_args
            elif os.path.isfile(p_integ):
                cmd = [p_integ] + extra_args
            elif os.path.isfile(p_tests):
                cmd = [p_tests] + extra_args
            elif os.path.isfile(p_scripts):
                cmd = [p_scripts] + extra_args
            else:
                self._send_json({"status": "error", "error": f"Test script {script_file} not found"}, cb, status=404)
                return
        else:
            if suite == "unit":
                cmd = [os.path.join(WORKSPACE_DIR, "tests", "test-all-components.sh")]
            elif suite == "integration":
                cmd = ["bash", "-c", "set -e; for t in tests/integration/*.sh; do [ -x \"$t\" ] && echo \"\n▶️ Running $t...\" && \"$t\"; done; echo \"\n✅ All integration tests passed!\""]
            elif suite == "apex":
                cmd = [os.path.join(WORKSPACE_DIR, "tests", "test-apex-suite.sh")]
            elif suite == "browser":
                cmd = [os.path.join(WORKSPACE_DIR, "tests", "test-browser-login.sh")]
            elif suite == "live":
                cmd = [os.path.join(WORKSPACE_DIR, "tests", "test-live-platform.sh")]
            elif suite == "blueprints_matrix":
                cmd = [os.path.join(WORKSPACE_DIR, "tests", "test-all-blueprints-live.sh")]
            elif suite == "devhub_lifecycle":
                cmd = [os.path.join(WORKSPACE_DIR, "tests", "test-devhub-lifecycle-full.sh"), "--all", "--dry-run"]
            elif suite == "containers_infra":
                cmd = [os.path.join(WORKSPACE_DIR, "tests", "test-containers-live.sh")]
            elif suite == "windows_enterprise":
                win_path = os.path.join(WORKSPACE_DIR, "tests", "test-windows-dryrun.sh")
                if not os.path.isfile(win_path):
                    win_path = os.path.join(WORKSPACE_DIR, "scripts", "test-windows-dryrun.sh")
                cmd = [win_path]
            elif suite == "i18n":
                cmd = [os.path.join(WORKSPACE_DIR, "tests", "test-multilingual-support.sh"), f"--lang={lang}"] if lang != "all" else [os.path.join(WORKSPACE_DIR, "tests", "test-multilingual-support.sh"), "--all"]
            elif suite == "portability":
                cmd = [os.path.join(WORKSPACE_DIR, "tests", "unit", "test-filename-portability.sh")]
            elif suite == "mermaid":
                cmd = [os.path.join(WORKSPACE_DIR, "tests", "unit", "test-devhub-mermaid-rendering.sh")]
            elif suite == "precommit":
                cmd = [os.path.join(WORKSPACE_DIR, "scripts", "check-pre-commit.sh"), "--full"]
            elif suite == "glossary":
                cmd = [os.path.join(WORKSPACE_DIR, "tests", "unit", "test-glossary-parity.sh")]
            elif suite == "tls_security":
                cmd = [os.path.join(WORKSPACE_DIR, "tests", "test-tls-scenarios.sh")]
            elif suite == "security_audit":
                audit_path = os.path.join(WORKSPACE_DIR, "scripts", "test-security-audit.sh")
                if not os.path.isfile(audit_path):
                    audit_path = os.path.join(WORKSPACE_DIR, "tests", "test-security-audit.sh")
                cmd = [audit_path]
            elif suite == "doc_links":
                cmd = [os.path.join(WORKSPACE_DIR, "tests", "unit", "test-devhub-doc-links.sh")]
            elif suite == "title_capitalization":
                cmd = [os.path.join(WORKSPACE_DIR, "tests", "unit", "test-title-capitalization-rules.sh")]
            elif suite in ["batch", "batch_runner", "test_batch"]:
                if not tiers:
                    tiers = ["quick"]
                batch_cmd = [os.path.join(WORKSPACE_DIR, "tests", "test-batch.sh")]
                for tier in tiers:
                    tier_clean = tier.strip()
                    if tier_clean in ["unit", "compliance", "ui", "live", "all", "quick"]:
                        batch_cmd.append(f"--{tier_clean}")
                cmd = batch_cmd
            elif suite in ["ci_sim", "offline_ci"]:
                ci_path = os.path.join(WORKSPACE_DIR, "tests", "test-local-ci.sh")
                if not os.path.isfile(ci_path):
                    ci_path = os.path.join(WORKSPACE_DIR, "scripts", "test-local-ci.sh")
                cmd = [ci_path, "--dry-run"] if dry_run else [ci_path]
            elif suite == "coverage":
                cmd = [os.path.join(WORKSPACE_DIR, "tests", "generate-test-coverage-report.sh")]
            elif suite == "repo_stats":
                cmd = [os.path.join(WORKSPACE_DIR, "tests", "report-repo-stats.sh")]
            else:
                cat = get_test_suites_catalog()
                if suite in cat and "cmd" in cat[suite]:
                    c_parts = cat[suite]["cmd"].strip().split()
                    c_path = c_parts[0]
                    if c_path.startswith("./"):
                        c_path = os.path.join(WORKSPACE_DIR, c_path[2:])
                    cmd = [c_path] + c_parts[1:]
                else:
                    self._send_json({"status": "error", "error": f"Unknown test suite: {suite}"}, cb, status=400)
                    return

        ts = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        log_name = f"test_{suite}_{ts}.log"
        log_full_path = os.path.join(WORKSPACE_DIR, "install_logs", log_name)
        os.makedirs(os.path.join(WORKSPACE_DIR, "install_logs"), exist_ok=True)

        try:
            log_fd = open(log_full_path, "w", encoding="utf-8")
            log_fd.write(f"=== TEST RUNNER DISPATCHED: {target_label} (Lang: {lang.upper()}) at {datetime.datetime.now().isoformat()} ===\n")
            log_fd.write(f"Command: {' '.join(cmd)}\n\n")
            log_fd.flush()

            run_env = os.environ.copy()
            run_env["CLI_LANG"] = lang
            if lang == "en":
                run_env["LANG"] = "en_US.UTF-8"
                run_env["LC_ALL"] = "en_US.UTF-8"
            elif lang == "et":
                run_env["LANG"] = "et_EE.UTF-8"
                run_env["LC_ALL"] = "et_EE.UTF-8"
            elif lang == "fi":
                run_env["LANG"] = "fi_FI.UTF-8"
                run_env["LC_ALL"] = "fi_FI.UTF-8"
            elif lang == "sv":
                run_env["LANG"] = "sv_SE.UTF-8"
                run_env["LC_ALL"] = "sv_SE.UTF-8"
            elif lang == "lv":
                run_env["LANG"] = "lv_LV.UTF-8"
                run_env["LC_ALL"] = "lv_LV.UTF-8"
            elif lang == "lt":
                run_env["LANG"] = "lt_LT.UTF-8"
                run_env["LC_ALL"] = "lt_LT.UTF-8"

            proc = subprocess.Popen(
                cmd,
                cwd=WORKSPACE_DIR,
                stdout=log_fd,
                stderr=subprocess.STDOUT,
                text=True,
                env=run_env
            )

            task_key = f"test_{suite}_{ts}"
            task_info = {
                "proc": proc,
                "log_file": log_name,
                "start_time": time.time(),
                "suite": suite,
                "target": target_label,
                "cmd": " ".join(cmd),
                "type": "test",
                "recorded": False,
                "log_fd": log_fd
            }
            ACTIVE_TASKS[task_key] = task_info
            ACTIVE_TASKS["test_runner"] = task_info

            self._send_json({
                "status": "ok",
                "state": "started",
                "task": "test_runner",
                "task_id": task_key,
                "target": target_label,
                "log_file": log_name,
                "log_relative_path": f"install_logs/{log_name}",
                "pid": proc.pid
            }, cb)
        except Exception as e:
            self._send_json({"status": "error", "error": str(e)}, cb, status=500)

    def handle_test_stop(self, post_body, query_str, cb=None):
        task_info = ACTIVE_TASKS.get("test_runner")
        if not task_info or not task_info.get("proc"):
            self._send_json({"status": "ok", "message": "No running test found"}, cb)
            return

        proc = task_info["proc"]
        if proc.poll() is None:
            try:
                proc.terminate()
                time.sleep(0.5)
                if proc.poll() is None:
                    proc.kill()
            except Exception:
                pass
            self._send_json({"status": "ok", "message": "Test process stopped"}, cb)
        else:
            self._send_json({"status": "ok", "message": "Test process already finished"}, cb)

    def handle_publisher_pdf(self, query_str):
        q = urllib.parse.parse_qs(query_str)
        token = q.get("token", [""])[0]
        preview = PDF_PREVIEW_STORE.get(token)
        if not preview or not os.path.isfile(preview.get("path", "")):
            file_param = q.get("file", [""])[0]
            if file_param and file_param.endswith(".pdf"):
                safe_full = os.path.abspath(os.path.join(WORKSPACE_DIR, file_param))
                if safe_full.startswith(WORKSPACE_DIR) and os.path.isfile(safe_full):
                    preview = {"path": safe_full, "filename": os.path.basename(safe_full)}

        if not preview or not os.path.isfile(preview["path"]):
            self.send_response(404)
            self._send_cors_headers()
            self.send_header("Content-Type", "text/plain; charset=utf-8")
            self.end_headers()
            self.wfile.write(b"PDF faili ei leitud voi see on aegunud.")
            return

        try:
            with open(preview["path"], "rb") as f:
                content = f.read()
            safe_name = preview.get("filename", "report_preview.pdf")
            self.send_response(200)
            self._send_cors_headers()
            self.send_header("Content-Type", "application/pdf")
            self.send_header("Content-Disposition", f'inline; filename="{safe_name}"')
            self.send_header("Cache-Control", "no-cache, no-store, must-revalidate")
            self.send_header("Content-Length", str(len(content)))
            self.end_headers()
            self.wfile.write(content)
        except Exception as e:
            self.send_response(500)
            self._send_cors_headers()
            self.end_headers()
            self.wfile.write(str(e).encode("utf-8"))

    def handle_publisher_render(self, post_body, query_str, cb=None):
        try:
            now = time.time()
            # Clean old preview entries
            for k in list(PDF_PREVIEW_STORE.keys()):
                if now - PDF_PREVIEW_STORE[k].get("created_at", 0) > 3600:
                    try:
                        p = PDF_PREVIEW_STORE[k].get("path")
                        if p and p.startswith("/tmp/bip_preview_") and os.path.isfile(p):
                            os.remove(p)
                    except Exception:
                        pass
                    PDF_PREVIEW_STORE.pop(k, None)

            data = {}
            if post_body and post_body.strip().startswith("{"):
                data = json.loads(post_body)
            else:
                q = urllib.parse.parse_qs(post_body or query_str)
                data = {k: v[0] for k, v in q.items()}

            rtf_rel = data.get("rtf_path", "").strip()
            xml_rel = data.get("xml_path", "").strip()
            locale = data.get("locale", "et").strip()[:2].lower()
            if not locale:
                locale = "et"

            if not rtf_rel:
                self._send_json({"status": "error", "error": "Malli tee (rtf_path) on kohustuslik!"}, cb, status=400)
                return

            rtf_full = os.path.abspath(os.path.join(WORKSPACE_DIR, rtf_rel))
            if not rtf_full.startswith(WORKSPACE_DIR) or not os.path.isfile(rtf_full):
                self._send_json({"status": "error", "error": f"RTF malli faili ei leitud: {rtf_rel}"}, cb, status=404)
                return

            if xml_rel:
                xml_full = os.path.abspath(os.path.join(WORKSPACE_DIR, xml_rel))
                if not xml_full.startswith(WORKSPACE_DIR) or not os.path.isfile(xml_full):
                    self._send_json({"status": "error", "error": f"XML andmefaili ei leitud: {xml_rel}"}, cb, status=404)
                    return
            else:
                xml_full = os.path.join(WORKSPACE_DIR, "templates/publisher/samples/arve_test_andmed.xml")

            prev_dir = os.path.join(WORKSPACE_DIR, "templates/publisher/.previews")
            os.makedirs(prev_dir, exist_ok=True)
            token = f"prev_{int(now)}_{os.getpid()}_{abs(hash(rtf_rel)) % 100000}"
            out_pdf = os.path.join(prev_dir, f"preview_{token}.pdf")

            render_script = os.path.join(WORKSPACE_DIR, "scripts/publisher/test-render.sh")
            start_t = time.time()

            cmd = [render_script, rtf_full, xml_full, out_pdf, "--locale", locale]
            res = subprocess.run(cmd, cwd=WORKSPACE_DIR, capture_output=True, text=True, timeout=30)
            dur = time.time() - start_t

            if os.path.isfile(out_pdf) and os.path.getsize(out_pdf) > 0:
                PDF_PREVIEW_STORE[token] = {
                    "path": out_pdf,
                    "filename": os.path.basename(rtf_rel).replace(".rtf", f"_{locale}.pdf"),
                    "created_at": time.time()
                }
                pdf_size = os.path.getsize(out_pdf)
                self._send_json({
                    "status": "ok",
                    "pdf_token": token,
                    "pdf_url": f"/api/publisher/pdf?token={token}",
                    "pdf_size": pdf_size,
                    "duration_ms": int(dur * 1000),
                    "rtf": rtf_rel,
                    "xml": xml_rel or os.path.relpath(xml_full, WORKSPACE_DIR),
                    "locale": locale,
                    "stdout": res.stdout
                }, cb)
            else:
                raw_err = (res.stderr + "\n" + res.stdout).strip()
                friendly = "PDF genereerimine ebaõnnestus."
                if "unclosed for-each" in raw_err.lower():
                    friendly = "Süntaksiviga mallis: 'Unclosed for-each loop'. Veendu, et igal <?for-each:LINE?> sildil on vastav <?end for-each?>."
                elif "element not found" in raw_err.lower() or "tag not found" in raw_err.lower():
                    friendly = "XML andmete viga: Mallis viidatud väli puudub valitud XML testandmetest."
                elif "syntaxerror" in raw_err.lower():
                    friendly = "Süntaksiviga RTF malli märgendites."

                self._send_json({
                    "status": "error",
                    "error": friendly,
                    "raw_output": raw_err,
                    "duration_ms": int(dur * 1000)
                }, cb, status=500)
        except subprocess.TimeoutExpired:
            self._send_json({"status": "error", "error": "Renderdamine aegus (üle 30s)"}, cb, status=504)
        except Exception as e:
            self._send_json({"status": "error", "error": str(e)}, cb, status=500)

    def handle_publisher_deploy(self, post_body, query_str, cb=None):
        try:
            data = {}
            if post_body and post_body.strip().startswith("{"):
                data = json.loads(post_body)
            else:
                q = urllib.parse.parse_qs(post_body or query_str)
                data = {k: v[0] for k, v in q.items()}

            rep_path = data.get("report_path", "Custom/Invoices/Invoice_Report").strip()
            deploy_script = os.path.join(WORKSPACE_DIR, "scripts/publisher/deploy-template.sh")

            start_t = time.time()
            res = subprocess.run([deploy_script, rep_path, "--render"], cwd=WORKSPACE_DIR, capture_output=True, text=True, timeout=60)
            dur = time.time() - start_t

            out_comb = (res.stdout + "\n" + res.stderr).strip()
            ok = (res.returncode == 0)

            friendly_msg = "Raport edukalt paigaldatud ja serveris testitud!" if ok else "Paigaldamisel tekkis tõrge."
            if "Container app-publisher is not running" in out_comb or "server at http://localhost:9502/xmlpserver is not responding" in out_comb:
                friendly_msg = "Konteiner app-publisher ei tööta või WebLogic server ei vasta pordil 9502. Käivita Publisher enne paigaldamist!"
            elif "ORA-" in out_comb:
                m = re.search(r'ORA-[0-9]{5}: [^\n]+', out_comb)
                if m:
                    friendly_msg = f"Andmebaasi viga paigaldamisel: {m.group(0)}"

            self._send_json({
                "status": "ok" if ok else "error",
                "ok": ok,
                "message": friendly_msg,
                "report_path": rep_path,
                "duration_ms": int(dur * 1000),
                "output": out_comb
            }, cb, status=200 if ok else 500)
        except subprocess.TimeoutExpired:
            self._send_json({"status": "error", "error": "Paigaldus aegus (üle 60s)"}, cb, status=504)
        except Exception as e:
            self._send_json({"status": "error", "error": str(e)}, cb, status=500)

    def handle_publisher_audit(self, post_body, query_str, cb=None):
        try:
            data = {}
            if post_body and post_body.strip().startswith("{"):
                data = json.loads(post_body)
            else:
                q = urllib.parse.parse_qs(post_body or query_str)
                data = {k: v[0] for k, v in q.items()}

            token = data.get("token", "")
            pdf_path = ""
            if token and token in PDF_PREVIEW_STORE:
                pdf_path = PDF_PREVIEW_STORE[token]["path"]
            elif data.get("pdf_path"):
                p = os.path.abspath(os.path.join(WORKSPACE_DIR, data["pdf_path"]))
                if p.startswith(WORKSPACE_DIR) and os.path.isfile(p):
                    pdf_path = p

            if not pdf_path or not os.path.isfile(pdf_path):
                self._send_json({"status": "error", "error": "PDF faili ei leitud auditeerimiseks. Renderda esmalt PDF!"}, cb, status=404)
                return

            audit_script = os.path.join(WORKSPACE_DIR, "scripts/publisher/validate-pdf-accessibility.sh")
            res = subprocess.run([audit_script, pdf_path], cwd=WORKSPACE_DIR, capture_output=True, text=True, timeout=20)
            out_comb = (res.stdout + "\n" + res.stderr).strip()

            compliant = (res.returncode == 0) and ("❌ KRIITILINE" not in out_comb and "❌ TULEMUS" not in out_comb and "FAILED" not in out_comb)

            self._send_json({
                "status": "ok",
                "compliant": compliant,
                "output": out_comb,
                "summary": "PDF vastab PDF/UA-1 ja WCAG 2.1 AA standarditele!" if compliant else "PDF vajab ligipääsetavuse viimistlust."
            }, cb)
        except Exception as e:
            self._send_json({"status": "error", "error": str(e)}, cb, status=500)

    def handle_publisher_test_e2e(self, post_body, query_str, cb=None):
        try:
            data = {}
            if post_body and post_body.strip().startswith("{"):
                data = json.loads(post_body)
            else:
                q = urllib.parse.parse_qs(post_body or query_str)
                data = {k: v[0] for k, v in q.items()}

            rep_path = data.get("report_path", "Custom/Invoices/Invoice_Report").strip()
            expected_text = data.get("expected_text", "").strip()
            xml_rel = data.get("xml_path", "").strip()

            # Resolve catalog template if an ID or RTF path was provided
            catalog = get_publisher_templates_catalog()
            matched_tpl = None
            for tpl in catalog:
                if tpl.get("id") == rep_path or tpl.get("rtf_path") == rep_path:
                    matched_tpl = tpl
                    break

            if matched_tpl:
                target_rep = matched_tpl.get("deploy_path") or "Custom/Invoices/Invoice_Report"
                rtf_src = os.path.join(WORKSPACE_DIR, matched_tpl.get("rtf_path", ""))
                xml_src = os.path.join(WORKSPACE_DIR, xml_rel or matched_tpl.get("default_xml", ""))
                target_dir = os.path.join(WORKSPACE_DIR, "applications/publisher", target_rep)
                if os.path.isfile(rtf_src) and os.path.isdir(target_dir):
                    rep_xdo_dir = os.path.join(target_dir, os.path.basename(target_rep) + ".xdo")
                    if os.path.isdir(rep_xdo_dir):
                        shutil.copy2(rtf_src, os.path.join(rep_xdo_dir, "template.rtf"))
                    if os.path.isfile(xml_src):
                        if os.path.isdir(rep_xdo_dir):
                            shutil.copy2(xml_src, os.path.join(rep_xdo_dir, "sample_data.xml"))
                        dm_dir = os.path.join(target_dir, "Invoice_DataModel.xdm")
                        if os.path.isdir(dm_dir):
                            shutil.copy2(xml_src, os.path.join(dm_dir, "sample_data.xml"))
                rep_path = target_rep

            e2e_script = os.path.join(WORKSPACE_DIR, "scripts/publisher/test-deploy-verify-e2e.sh")
            cmd = [e2e_script, rep_path]
            if expected_text:
                cmd.append(expected_text)

            start_t = time.time()
            res = subprocess.run(cmd, cwd=WORKSPACE_DIR, capture_output=True, text=True, timeout=120)
            dur = time.time() - start_t

            out_comb = (res.stdout + "\n" + res.stderr).strip()
            ok = (res.returncode == 0)

            import glob
            pdf_files = sorted(glob.glob(os.path.join(WORKSPACE_DIR, "install_logs/publisher_e2e_*.pdf")), key=os.path.getmtime, reverse=True)
            pdf_rel = os.path.relpath(pdf_files[0], WORKSPACE_DIR) if pdf_files else ""
            pdf_url = ""
            if pdf_files and os.path.isfile(pdf_files[0]):
                token = hashlib.sha256(f"{pdf_files[0]}_{os.path.getmtime(pdf_files[0])}".encode()).hexdigest()[:16]
                PDF_PREVIEW_STORE[token] = {"path": pdf_files[0], "ts": time.time()}
                pdf_url = f"/api/publisher/pdf?token={token}"

            friendly_msg = "E2E Test edukalt läbitud! Sisu ja ligipääsetavus kinnitatud." if ok else "E2E Testi käivitamisel ilmnes tõrge."
            if "nõutav Blueprint 5" in out_comb:
                friendly_msg = "E2E testimiseks on nõutav Blueprint 5 (Standalone Analytics Publisher). Aktiveeri see Blueprints vaatest!"

            self._send_json({
                "status": "ok",
                "ok": ok,
                "message": friendly_msg,
                "report_path": rep_path,
                "duration_ms": int(dur * 1000),
                "pdf_url": pdf_url,
                "pdf_file": pdf_rel,
                "output": out_comb
            }, cb, status=200)
        except subprocess.TimeoutExpired:
            self._send_json({"status": "error", "error": "E2E Test aegus (üle 120s)"}, cb, status=504)
        except Exception as e:
            self._send_json({"status": "error", "error": str(e)}, cb, status=500)

    def handle_publisher_open_designer(self, post_body, query_str, cb=None):
        try:
            data = {}
            if post_body and post_body.strip().startswith("{"):
                data = json.loads(post_body)
            else:
                q = urllib.parse.parse_qs(post_body or query_str)
                data = {k: v[0] for k, v in q.items()}

            rtf_rel = data.get("rtf_path", "").strip()

            if not rtf_rel:
                catalog = get_publisher_templates_catalog()
                if catalog:
                    rtf_rel = catalog[0].get("rtf_path", "")

            container_name = "app-publisher-designer"
            container_rtf = "/u01/templates/samples/arve_eesti_standard.rtf"

            if rtf_rel:
                clean_rel = rtf_rel.lstrip("/")
                if clean_rel.startswith("templates/publisher/"):
                    sub = clean_rel[len("templates/publisher/"):]
                    container_rtf = f"/u01/templates/{sub}"
                elif os.path.isfile(os.path.join(WORKSPACE_DIR, clean_rel)):
                    host_full = os.path.join(WORKSPACE_DIR, clean_rel)
                    dest_c = f"/u01/templates/custom/{os.path.basename(clean_rel)}"
                    subprocess.run([PODMAN_BIN, "exec", "-u", "oracle", container_name, "mkdir", "-p", "/u01/templates/custom"], timeout=5)
                    subprocess.run([PODMAN_BIN, "cp", host_full, f"{container_name}:{dest_c}"], timeout=5)
                    container_rtf = dest_c

            c_check = subprocess.run([PODMAN_BIN, "ps", "--format", "{{.Names}}"], capture_output=True, text=True, timeout=5)
            if container_name not in c_check.stdout:
                self._send_json({
                    "status": "error",
                    "error": f"Designer konteiner '{container_name}' ei tööta. Käivita see Blueprints vaatest või käsuga: ./scripts/publisher/start-publisher-designer.sh"
                }, cb, status=503)
                return

            # Open target RTF in LibreOffice Writer on display :1
            subprocess.run([
                PODMAN_BIN, "exec", "-d", "-u", "oracle", "-e", "DISPLAY=:1",
                container_name, "libreoffice", "--norestore", "--writer", container_rtf
            ], timeout=5)

            # Bring to focus using xdotool if available, and close any Tip of the Day popup
            doc_base = os.path.basename(container_rtf)
            subprocess.run([
                PODMAN_BIN, "exec", "-d", "-u", "oracle", "-e", "DISPLAY=:1",
                container_name, "bash", "-c", f"sleep 1; xdotool search --name 'Tip of the Day' windowclose 2>/dev/null || true; xdotool search --name '{doc_base}' windowactivate 2>/dev/null || true"
            ], timeout=5)

            designer_url = "http://localhost:6083/vnc.html?autoconnect=true&resize=remote"
            self._send_json({
                "status": "ok",
                "message": f"Malli avamine algatatud LibreOffice Writeris: {os.path.basename(container_rtf)}",
                "container_file": container_rtf,
                "designer_url": designer_url
            }, cb)
        except Exception as e:
            self._send_json({"status": "error", "error": str(e)}, cb, status=500)

    def handle_ai_chat(self, post_body, query_str, cb=None):
        try:
            req = json.loads(post_body) if post_body.strip() else {}
        except Exception:
            req = {}
        provider = req.get("provider", "copilot")
        query = req.get("query") or req.get("message", "")
        history = req.get("history", [])
        lang = req.get("lang", "en")
        res = ask_ai(provider, query, history, lang)
        self._send_json(res, cb)

    def handle_copilot_chat(self, post_body, query_str, cb=None):
        self.handle_ai_chat(post_body, query_str, cb)

    def handle_ai_deeplink(self, post_body, query_str, cb=None):
        try:
            req = json.loads(post_body) if post_body.strip() else {}
        except Exception:
            req = {}
        target = req.get("target") or req.get("provider", "vscode")
        query = req.get("query") or req.get("message", "")
        lang = req.get("lang", "en")
        res = generate_ai_deeplink(target, query, lang)

        if target == "antigravity" and sys.platform == "darwin":
            try:
                for app in ["Antigravity", "Antigravity IDE"]:
                    if os.path.exists(f"/Applications/{app}.app"):
                        subprocess.Popen(["open", "-a", app], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                        break
            except Exception:
                pass

        self._send_json(res, cb)

    def handle_copilot_deeplink(self, post_body, query_str, cb=None):
        self.handle_ai_deeplink(post_body, query_str, cb)

    def log_message(self, format, *args):
        return

class SafeThreadingTCPServer(socketserver.ThreadingTCPServer):
    allow_reuse_address = True
    daemon_threads = True

    def handle_error(self, request, client_address):
        exc_type = sys.exc_info()[0]
        if exc_type and issubclass(exc_type, (BrokenPipeError, ConnectionResetError, ssl.SSLEOFError, OSError)):
            return
        super().handle_error(request, client_address)

def start_https_server(bind_host, https_port, cert_file, key_file):
    try:
        context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
        context.load_cert_chain(certfile=cert_file, keyfile=key_file)
        SafeThreadingTCPServer.allow_reuse_address = True
        with SafeThreadingTCPServer((bind_host, https_port), DevHubBridgeHandler) as httpsd:
            httpsd.socket = context.wrap_socket(httpsd.socket, server_side=True)
            print(f"🔒 Dev Hub Bridge HTTPS server active on https://{bind_host}:{https_port}")
            httpsd.serve_forever()
    except Exception as e:
        print(f"⚠️ Dev Hub Bridge HTTPS server could not start on {https_port}: {e}")

def start_auto_reload_watcher():
    """Monitors core files (VERSION, dev-hub-bridge.py) and hot-reloads via os.execv on modification."""
    watch_files = [
        os.path.join(WORKSPACE_DIR, "VERSION"),
        os.path.abspath(__file__),
    ]
    initial_mtimes = {}
    for f in watch_files:
        if os.path.isfile(f):
            initial_mtimes[f] = os.path.getmtime(f)

    def _watch_loop():
        time.sleep(2)
        while True:
            try:
                for f, init_t in list(initial_mtimes.items()):
                    if os.path.isfile(f):
                        current_t = os.path.getmtime(f)
                        if current_t > init_t:
                            print(f"🔄 [Dev Hub Bridge Auto-Reload] {os.path.basename(f)} muutus kettal. Taaskäivitan sildserveri...", flush=True)
                            time.sleep(0.5)
                            os.execv(sys.executable, [sys.executable] + sys.argv)
            except Exception:
                pass
            time.sleep(1.5)

    watcher = threading.Thread(target=_watch_loop, daemon=True, name="BridgeAutoReloadWatcher")
    watcher.start()

def main():
    SafeThreadingTCPServer.allow_reuse_address = True
    bind_host = BIND_HOST
    cert_file = os.path.join(WORKSPACE_DIR, "config/certs/localhost.crt")
    key_file = os.path.join(WORKSPACE_DIR, "config/certs/localhost.key")

    start_auto_reload_watcher()

    if os.path.isfile(cert_file) and os.path.isfile(key_file):
        https_thread = threading.Thread(
            target=start_https_server,
            args=(bind_host, HTTPS_PORT, cert_file, key_file),
            daemon=True
        )
        https_thread.start()

    with SafeThreadingTCPServer((bind_host, PORT), DevHubBridgeHandler) as httpd:
        print(f"🚀 Dev Hub Bridge & Dashboard server active on http://{bind_host}:{PORT}")
        httpd.serve_forever()

if __name__ == "__main__":
    main()
