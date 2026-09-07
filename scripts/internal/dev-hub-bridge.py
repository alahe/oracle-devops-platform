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

# Ensure scripts/internal is in sys.path for dev_hub imports
INTERNAL_DIR = os.path.abspath(os.path.dirname(__file__))
if INTERNAL_DIR not in sys.path:
    sys.path.insert(0, INTERNAL_DIR)

try:
    from dev_hub.parser import parse_blueprint_env_and_metadata
    from dev_hub.diagnostics import find_latest_log_for_blueprint, load_all_passwords
    from dev_hub.testing import get_script_doc_reference
except Exception:
    parse_blueprint_env_and_metadata = None
    find_latest_log_for_blueprint = None
    load_all_passwords = None
    get_script_doc_reference = lambda s: {"doc_file": "docs/testing-framework-and-devhub.md", "doc_key": "testing_framework", "title": "Testing Framework & Dev Hub Architecture"}

# Ensure standard system and package manager binary directories are in PATH
for p in ["/opt/homebrew/bin", "/usr/local/bin", os.path.expanduser("~/.local/bin")]:
    if os.path.isdir(p) and p not in os.environ.get("PATH", "").split(os.pathsep):
        os.environ["PATH"] = p + os.pathsep + os.environ.get("PATH", "")

PODMAN_BIN = shutil.which("podman") or ("/opt/homebrew/bin/podman" if os.path.isfile("/opt/homebrew/bin/podman") else ("/usr/local/bin/podman" if os.path.isfile("/usr/local/bin/podman") else "podman"))

PORT = int(os.environ.get("DEV_HUB_BRIDGE_PORT", 8089))
WORKSPACE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "../.."))
DEV_HUB_HTML = os.path.join(WORKSPACE_DIR, "docs/dev-hub.html")

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
    "designer": "config/profiles/publisher/publisher-designer.yaml",
    "forms-publisher": "config/profiles/forms-publisher/forms-publisher-unified.yaml"
}

ACTIVE_TASKS = {}

DEVOPS_WHITELIST = {
    "check-urls": ["./scripts/check-urls.sh"],
    "check-wallet": ["./scripts/check-wallet.sh"],
    "get-passwords": ["./scripts/get-password.sh", "--list"],
    "rotate-dev": ["./scripts/rotate-password.sh", "db-proxy", "dev"],
    "rotate-all": ["./scripts/rotate-password.sh", "all"],
    "restore-snapshot": ["./scripts/snapshots/restore-golden-snapshots.sh", "--auto", "-b", "0"],
    "create-snapshot": ["./scripts/snapshots/create-golden-snapshots.sh"],
    "clean-snapshots": ["./scripts/snapshots/clean-golden-snapshots.sh", "-y"],
    "reset-all": ["./scripts/reset-all.sh", "-y"],
    "deploy-status": ["./scripts/deploy-blueprint.sh", "--status"],
    "clean-logs": ["./scripts/clean-logs.sh"],
    "test-ci": ["./scripts/test-local-ci.sh"],
    "test-containers": ["./tests/test-containers-live.sh"],
    "register-connections": ["./scripts/register-connections.sh"],
    "trust-cert": ["./scripts/certs/trust-local-cert-mac.sh"] if sys.platform == "darwin" else ["./scripts/certs/trust-local-cert.cmd"],
    "update-extensions": ["./scripts/update-extensions.sh"],
    "blueprint-info": ["./scripts/blueprint-info.sh"],
    "test-devhub-blueprints": ["./tests/test-devhub-browser-blueprints.sh"]
}

def get_profile_port(module):
    rel_path = MODULE_PROFILE_MAP.get(module)
    if not rel_path:
        return MODULE_PORT_MAP.get(module, 8080)
    full_path = os.path.join(WORKSPACE_DIR, rel_path)
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
            m = re.search(r"^\s*port:\s*([0-9]+)", content, re.MULTILINE)
            if m:
                return int(m.group(1))
            m = re.search(r"host_port:\s*([0-9]+)", content)
            if m:
                return int(m.group(1))
        except Exception:
            pass
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
                    if name == "app-ords":
                        try:
                            import socket
                            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                            s.settimeout(0.5)
                            ords_p = int(os.environ.get("ORDS_PORT", "8088"))
                            if s.connect_ex(("127.0.0.1", ords_p)) == 0:
                                container_health[name] = "healthy"
                            else:
                                container_health[name] = "starting"
                            s.close()
                        except Exception:
                            container_health[name] = "starting"
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

    abp_path = os.path.join(WORKSPACE_DIR, ".active_blueprint")
    if os.path.isfile(abp_path):
        try:
            with open(abp_path, "r", encoding="utf-8") as f:
                txt = f.read().strip()
                m = re.search(r"(\d+)", txt)
                if m:
                    active_bp = int(m.group(1))
        except Exception:
            pass

    return status_map, running_names, active_bp, container_health, setup_prog

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

        t0 = time.time()
        url = f"http://127.0.0.1:{ords_port}/ords/{pname}/"
        status = "offline"
        lat = 0
        http_code = 0
        try:
            req = urllib.request.Request(url, headers={"User-Agent": "DevHubBridge"})
            with opener.open(req, timeout=1.2) as resp:
                lat = int((time.time() - t0) * 1000)
                http_code = resp.status
                status = "online" if resp.status in [200, 301, 302, 303, 307, 308, 404] else "degraded"
        except urllib.error.HTTPError as e:
            lat = int((time.time() - t0) * 1000)
            http_code = e.code
            status = "online" if e.code in [200, 301, 302, 303, 307, 308, 404] else "degraded"
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
    return {"total_ram_gb": total_ram_gb, "avail_ram_gb": avail_ram_gb}

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
                        "memory": memory
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
                    try:
                        with open(full_p, "r", encoding="utf-8") as bf:
                            for line in bf:
                                line_str = line.strip()
                                if line_str.startswith("# Blueprint") or line_str.startswith("# blueprint"):
                                    title = line_str.lstrip("#").strip()
                                    break
                    except Exception:
                        pass
                    if not title:
                        title = f"Blueprint {num if num is not None else f}"
                    results.append({
                        "name": f,
                        "rel_path": rel_p,
                        "number": num if num is not None else 999,
                        "slug": slug,
                        "title": title
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
    unit_tests = []
    unit_dir = os.path.join(WORKSPACE_DIR, "tests", "unit")
    if os.path.isdir(unit_dir):
        for f in sorted(os.listdir(unit_dir)):
            if f.endswith(".sh") and not f.startswith("."):
                unit_tests.append(f)

    integration_tests = []
    integ_dir = os.path.join(WORKSPACE_DIR, "tests", "integration")
    if os.path.isdir(integ_dir):
        for f in sorted(os.listdir(integ_dir)):
            if f.endswith(".sh") and not f.startswith("."):
                integration_tests.append(f)

    return {
        "unit": {
            "key": "unit",
            "title": "Unit Test Suite",
            "desc": f"Fast isolation tests ({len(unit_tests)} scripts) validating configs, SEPS wallet, script syntax, and logic without live DB",
            "icon": "🧪",
            "count": len(unit_tests),
            "tests": unit_tests,
            "cmd": "./tests/test-all-components.sh"
        },
        "integration": {
            "key": "integration",
            "title": "Integration Test Suite",
            "desc": f"Multi-database topology ({len(integration_tests)} scripts), compose override generation, profile roles, and connection handshakes",
            "icon": "⚙️",
            "count": len(integration_tests),
            "tests": integration_tests,
            "cmd": "tests/integration/*.sh"
        },
        "live": {
            "key": "live",
            "title": "End-to-End Live Platform",
            "desc": "Full regression against active running containers, database listeners, and web service endpoints",
            "icon": "🚀",
            "count": 1,
            "tests": ["test-live-platform.sh"],
            "cmd": "./tests/test-live-platform.sh"
        },
        "i18n": {
            "key": "i18n",
            "title": "Multilingual & i18n Parity",
            "desc": "Full 6-language compliance audit (Rule 9): checks dictionary symmetry, headers, and translations",
            "icon": "🌐",
            "count": 1,
            "tests": ["test-multilingual-support.sh"],
            "cmd": "./tests/test-multilingual-support.sh --all"
        },
        "portability": {
            "key": "portability",
            "title": "Cross-Platform Portability",
            "desc": "Strict verification of Rule 13: Windows NTFS/FAT forbidden chars, device names, and ASCII path standards",
            "icon": "🛡️",
            "count": 1,
            "tests": ["test-filename-portability.sh"],
            "cmd": "./tests/unit/test-filename-portability.sh"
        },
        "browser": {
            "key": "browser",
            "title": "Browser & SSO End-to-End",
            "desc": "Simulates browser interactions, APEX login flows, Dev Hub shortcuts, and SSO authentication",
            "icon": "🖥️",
            "count": 2,
            "tests": ["test-browser-login.sh", "test-devhub-browser-blueprints.sh"],
            "cmd": "./scripts/test-browser-login.sh"
        },
        "ci_sim": {
            "key": "ci_sim",
            "title": "Local GitHub Actions CI Simulator",
            "desc": "Executes or dry-runs repository CI/CD workflows offline using ephemeral containers",
            "icon": "🐙",
            "count": 1,
            "tests": ["test-local-ci.sh"],
            "cmd": "./scripts/test-local-ci.sh --dry-run"
        },
        "coverage": {
            "key": "coverage",
            "title": "Test Coverage Report Generator",
            "desc": "Analyzes test coverage of all scripts/ and scripts/internal/ files and updates markdown reports",
            "icon": "📊",
            "count": 1,
            "tests": ["generate-test-coverage-report.sh"],
            "cmd": "./tests/generate-test-coverage-report.sh"
        }
    }

def get_test_reports_list():
    """Scans tests/reports/ and returns a structured list of test reports."""
    reports = []
    reports_dir = os.path.join(WORKSPACE_DIR, "tests", "reports")
    if not os.path.isdir(reports_dir):
        return reports

    for root, dirs, files in os.walk(reports_dir):
        for f in sorted(files):
            if f.endswith(".md"):
                full_p = os.path.join(root, f)
                rel_p = os.path.relpath(full_p, WORKSPACE_DIR)
                title = f
                status = "INFO"
                try:
                    with open(full_p, "r", encoding="utf-8", errors="ignore") as rf:
                        lines = [rf.readline() for _ in range(5)]
                        for ln in lines:
                            if ln.startswith("# "):
                                title = ln.replace("# ", "").strip()
                                break
                except Exception:
                    pass

                f_lower = f.lower()
                if "pass" in f_lower or "success" in f_lower or "live" in f_lower or "matrix" in f_lower:
                    status = "PASS"
                elif "fail" in f_lower or "error" in f_lower:
                    status = "FAIL"

                stat = os.stat(full_p)
                reports.append({
                    "name": f,
                    "rel_path": rel_p,
                    "title": title,
                    "status": status,
                    "size": stat.st_size,
                    "mtime": datetime.datetime.fromtimestamp(stat.st_mtime).strftime("%Y-%m-%d %H:%M:%S")
                })
    reports.sort(key=lambda x: x["mtime"], reverse=True)
    return reports

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
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS, HEAD")
        self.send_header("Access-Control-Allow-Headers", "*")
        self.send_header("Access-Control-Allow-Private-Network", "true")
        self.send_header("Cache-Control", "no-cache, no-store, must-revalidate")

    def _send_json(self, data, cb=None, status=200):
        json_str = json.dumps(data)
        if cb:
            body = f"{cb}({json_str});".encode("utf-8")
            ct = "application/javascript"
        else:
            body = json_str.encode("utf-8")
            ct = "application/json"

        self.send_response(status)
        self._send_cors_headers()
        self.send_header("Content-Type", ct)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

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
                "system_resources": resources
            }
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

        elif parsed.path == "/api/ords/pools":
            ords_pools = get_live_ords_pools()
            data = {"status": "ok", "ords_pools": ords_pools}
            json_str = json.dumps(data)
            body = json_str.encode("utf-8")
            self.send_response(200)
            self._send_cors_headers()
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)

        elif parsed.path == "/api/ords/refresh":
            try:
                subprocess.run([os.path.join(WORKSPACE_DIR, "scripts/internal/manage-ords-pools.sh"), "sync"], capture_output=True, timeout=5)
            except Exception:
                pass
            ords_pools = get_live_ords_pools()
            data = {"status": "ok", "message": "ORDS pools synchronized", "ords_pools": ords_pools}
            json_str = json.dumps(data)
            body = json_str.encode("utf-8")
            self.send_response(200)
            self._send_cors_headers()
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)

        elif parsed.path == "/api/tests/suites":
            self._send_json({"status": "ok", "suites": get_test_suites_catalog()}, cb)

        elif parsed.path == "/api/tests/reports":
            self._send_json({"status": "ok", "reports": get_test_reports_list()}, cb)

        elif parsed.path == "/api/tests/report-content":
            self.handle_tests_report_content(parsed.query, cb)

        elif parsed.path == "/api/tests/script-content":
            self.handle_test_script_content(parsed.query, cb)

        elif parsed.path == "/api/tests/coverage":
            self._send_json({"status": "ok", "coverage": get_test_coverage_data()}, cb)

        elif parsed.path == "/api/tests/history":
            self._send_json({"status": "ok", "history": get_test_execution_history()}, cb)

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
                self.send_response(404)
                self.end_headers()
        else:
            self.send_response(200)
            self._send_cors_headers()
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(b'{"status":"ok","message":"Dev Hub Bridge Active"}')

    def do_POST(self):
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
        elif parsed.path == "/api/podman/action":
            self.handle_podman_action(post_body, parsed.query, cb)
        else:
            self.send_response(404)
            self.end_headers()

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
        try:
            if post_body.strip().startswith("{"):
                data = json.loads(post_body)
                cmd_key = data.get("command", "")
            else:
                q = urllib.parse.parse_qs(post_body or query_str)
                cmd_key = q.get("command", [""])[0]
        except Exception:
            pass

        if cmd_key not in DEVOPS_WHITELIST:
            self.send_response(400)
            self._send_cors_headers()
            self.end_headers()
            self.wfile.write(json.dumps({"status": "error", "error": f"Command '{cmd_key}' is not in allowed whitelist"}).encode("utf-8"))
            return

        cmd_args = DEVOPS_WHITELIST[cmd_key]
        try:
            res = subprocess.run(
                cmd_args,
                cwd=WORKSPACE_DIR,
                capture_output=True,
                text=True,
                timeout=120
            )
            data = {
                "status": "ok",
                "ok": (res.returncode == 0),
                "command": cmd_key,
                "cmd_str": " ".join(cmd_args),
                "exit_code": res.returncode,
                "stdout": res.stdout,
                "stderr": res.stderr,
                "output": res.stdout + ("\n" + res.stderr if res.stderr else "")
            }
            log_fn = f"devops_{cmd_key.replace('-', '_')}.log"
            log_full = os.path.join(WORKSPACE_DIR, "install_logs", log_fn)
            try:
                with open(log_full, "w", encoding="utf-8") as f:
                    f.write(data["output"])
                data["log_file"] = log_fn
                data["log_relative_path"] = f"install_logs/{log_fn}"
                data["log_full_path"] = log_full
            except Exception:
                pass
            json_str = json.dumps(data)
            body = f"{cb}({json_str});".encode("utf-8") if cb else json_str.encode("utf-8")
            ct = "application/javascript" if cb else "application/json"
            self.send_response(200)
            self._send_cors_headers()
            self.send_header("Content-Type", ct)
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
        except subprocess.TimeoutExpired:
            self.send_response(504)
            self._send_cors_headers()
            self.end_headers()
            self.wfile.write(json.dumps({"status": "error", "error": "Command timed out after 120s"}).encode("utf-8"))
        except Exception as e:
            self.send_response(500)
            self._send_cors_headers()
            self.end_headers()
            self.wfile.write(json.dumps({"status": "error", "error": str(e)}).encode("utf-8"))

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

        # Core Base Protection: db-proxy and app-ords cannot be stopped via Web UI
        CORE_PROTECTED = ["core", "proxy", "db-proxy", "ords", "app-ords", "0"]
        if action in ["stop", "down"] and (str(module).lower() in CORE_PROTECTED or str(module) == "0"):
            self._send_json({
                "status": "error",
                "error": "Core Base Protection: db-proxy and app-ords cannot be stopped via Web UI."
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
        elif action == "stop" and str(module).isdigit():
            bp_files = glob.glob(os.path.join(WORKSPACE_DIR, f"config/blueprints/.env.{module}-*"))
            to_stop = []
            if bp_files and parse_blueprint_env_and_metadata:
                try:
                    meta = parse_blueprint_env_and_metadata(bp_files[0], int(module))
                    cnames = meta.get("container_names", [])
                    to_stop = [c for c in cnames if c not in ["db-proxy", "app-ords"]]
                except Exception as e:
                    print(f"Error parsing blueprint {module} for stop: {e}", file=sys.stderr)
            if not to_stop and bp_files:
                with open(bp_files[0], "r", encoding="utf-8") as f:
                    for line in f:
                        line = line.strip()
                        if line.startswith("DB_") and "=" in line:
                            v = line.split("=")[1].strip().strip('"\'')
                            if v and v.upper() != "NONE":
                                to_stop.append(v)
                        elif "PUBLISHER_PROFILE=" in line and "NONE" not in line:
                            to_stop.extend(["oracle-publisher-dev", "app-publisher"])
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
                cmd = [PODMAN_BIN, "stop"] + to_stop
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
        # Long-running operations (setup, activate, deploy, switch, restart) MUST NEVER be run synchronously!
        # Synchronous blocking HTTP requests abort with "signal is aborted without reason" at 300s.
        # Dispatch asynchronously via subprocess.Popen, stream to install_logs, and return immediately.
        if action in ["setup", "activate", "switch", "deploy", "restart"] and str(module).isdigit():
            log_name = f"setup_bp_{module}_latest.log" if action != "restart" else f"deploy_bp_{module}_latest.log"
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

        sname = os.path.basename(script_name)
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

    def handle_test_run(self, post_body, query_str, cb=None):
        suite = "unit"
        test_script = ""
        dry_run = False
        lang = "en"
        try:
            if post_body.strip().startswith("{"):
                data = json.loads(post_body)
                suite = data.get("suite", "unit")
                test_script = (data.get("script") or data.get("test") or "").strip()
                lang = (data.get("lang") or "en").strip().lower()
                dry_run = bool(data.get("dry_run", False))
            else:
                q = urllib.parse.parse_qs(post_body or query_str)
                suite = q.get("suite", ["unit"])[0]
                test_script = (q.get("script", [""])[0] or q.get("test", [""])[0]).strip()
                lang = q.get("lang", ["en"])[0].strip().lower()
                dry_run = q.get("dry_run", ["false"])[0].lower() in ["1", "true", "yes"]
        except Exception:
            pass

        cmd = []
        target_label = suite
        if test_script:
            test_script = os.path.basename(test_script)
            target_label = f"{suite} / {test_script}"
            if not test_script.endswith(".sh") or not re.match(r"^[a-zA-Z0-9._-]+$", test_script):
                self._send_json({"status": "error", "error": "Invalid test script filename"}, cb, status=400)
                return

            p_unit = os.path.join(WORKSPACE_DIR, "tests", "unit", test_script)
            p_integ = os.path.join(WORKSPACE_DIR, "tests", "integration", test_script)
            p_tests = os.path.join(WORKSPACE_DIR, "tests", test_script)
            p_scripts = os.path.join(WORKSPACE_DIR, "scripts", test_script)
            if os.path.isfile(p_unit):
                cmd = [p_unit]
            elif os.path.isfile(p_integ):
                cmd = [p_integ]
            elif os.path.isfile(p_tests):
                cmd = [p_tests]
            elif os.path.isfile(p_scripts):
                cmd = [p_scripts]
            else:
                self._send_json({"status": "error", "error": f"Test script {test_script} not found"}, cb, status=404)
                return
        else:
            if suite == "unit":
                cmd = [os.path.join(WORKSPACE_DIR, "tests", "test-all-components.sh")]
            elif suite == "integration":
                cmd = ["bash", "-c", "set -e; for t in tests/integration/*.sh; do [ -x \"$t\" ] && echo \"\n▶️ Running $t...\" && \"$t\"; done; echo \"\n✅ All integration tests passed!\""]
            elif suite == "live":
                cmd = [os.path.join(WORKSPACE_DIR, "tests", "test-live-platform.sh")]
            elif suite == "i18n":
                cmd = [os.path.join(WORKSPACE_DIR, "tests", "test-multilingual-support.sh"), f"--lang={lang}"] if lang != "all" else [os.path.join(WORKSPACE_DIR, "tests", "test-multilingual-support.sh"), "--all"]
            elif suite == "portability":
                cmd = [os.path.join(WORKSPACE_DIR, "tests", "unit", "test-filename-portability.sh")]
            elif suite == "browser":
                cmd = [os.path.join(WORKSPACE_DIR, "tests", "test-browser-login.sh")]
            elif suite == "ci_sim":
                cmd = [os.path.join(WORKSPACE_DIR, "scripts", "test-local-ci.sh"), "--dry-run"] if dry_run else [os.path.join(WORKSPACE_DIR, "scripts", "test-local-ci.sh")]
            elif suite == "coverage":
                cmd = [os.path.join(WORKSPACE_DIR, "tests", "generate-test-coverage-report.sh")]
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

    def log_message(self, format, *args):
        return

def main():
    socketserver.ThreadingTCPServer.allow_reuse_address = True
    with socketserver.ThreadingTCPServer(("0.0.0.0", PORT), DevHubBridgeHandler) as httpd:
        print(f"🚀 Dev Hub Bridge & Dashboard server active on http://localhost:{PORT}")
        httpd.serve_forever()

if __name__ == "__main__":
    main()
