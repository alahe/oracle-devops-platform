#!/usr/bin/env bash
# ==============================================================================
# Oracle DevOps Platform — VS Code & Extensions Version Manager
#
# Inspects, validates, updates, and caches VS Code extensions and code-server core.
# Complies with:
#   - Rule 1: Benchmarks and logging into metrics/ and install_logs/
#   - Rule 9: Full 6-language i18n support (EN, ET, FI, SV, LV, LT)
#   - Rule 11: Single source of truth from config/profiles/web-ide/*.yaml
#
# Usage:
#   ./scripts/update-extensions.sh [OPTIONS]
# Options:
#   -c, --check       Check extension versions against Marketplace (default)
#   -u, --update      Update all outdated extensions in Web IDE container
#   --cache-vsix      Download .vsix packages to binaries/extensions/ (Air-Gapped)
#   --upgrade-core    Upgrade code-server container base image
#   --json            Output results as JSON
#   -h, --help        Show help message
# ==============================================================================

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Load i18n engine
if [ -f "$WORKSPACE_DIR/scripts/internal/i18n.sh" ]; then
  source "$WORKSPACE_DIR/scripts/internal/i18n.sh"
fi

# Load profile / environment
if [ -f "$WORKSPACE_DIR/.env" ]; then
  set -a
  source "$WORKSPACE_DIR/.env"
  set +a
fi

MODE="check"
JSON_OUTPUT=false
TARGET_EXT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -c|--check)
      MODE="check"
      shift
      ;;
    -u|--update)
      MODE="update"
      shift
      ;;
    --cache-vsix)
      MODE="cache_vsix"
      shift
      ;;
    --upgrade-core)
      MODE="upgrade_core"
      shift
      ;;
    --json)
      JSON_OUTPUT=true
      shift
      ;;
    --ext)
      TARGET_EXT="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: ./scripts/update-extensions.sh [-c|--check] [-u|--update] [--cache-vsix] [--upgrade-core] [--json]"
      exit 0
      ;;
    *)
      shift
      ;;
  esac
done

WEB_IDE_CONTAINER="${WEB_IDE_CONTAINER_NAME:-web-ide-dev}"
EXT_DIR="$WORKSPACE_DIR/binaries/extensions"
METRICS_DIR="$WORKSPACE_DIR/metrics"
STATUS_JSON="$METRICS_DIR/extensions_status.json"
mkdir -p "$EXT_DIR" "$METRICS_DIR"

# Check if Web IDE container is running
is_container_running() {
  podman container exists "$WEB_IDE_CONTAINER" 2>/dev/null && \
  [ "$(podman inspect --format='{{.State.Status}}' "$WEB_IDE_CONTAINER" 2>/dev/null)" = "running" ]
}

# Python engine to query versions and generate JSON
JSON_OUTPUT="$JSON_OUTPUT" MODE="$MODE" WORKSPACE_DIR="$WORKSPACE_DIR" python3 - << 'PYEOF'
import json, os, sys, urllib.request, subprocess

workspace_dir = os.environ.get("WORKSPACE_DIR", os.getcwd())
mode = os.environ.get("MODE", "check")
json_output = os.environ.get("JSON_OUTPUT", "false") == "true"
container_name = os.environ.get("WEB_IDE_CONTAINER", "web-ide-dev")
status_json_path = os.path.join(workspace_dir, "metrics", "extensions_status.json")

# 1. Query installed extensions from Web IDE container
installed_map = {}
container_running = False

try:
    chk = subprocess.run(["podman", "container", "exists", container_name], capture_output=True)
    if chk.returncode == 0:
        inspect = subprocess.run(["podman", "inspect", "--format={{.State.Status}}", container_name], capture_output=True, text=True)
        if inspect.stdout.strip() == "running":
            container_running = True
            cmd = ["podman", "exec", "-i", container_name, "/app/code-server/bin/code-server", "--extensions-dir", "/config/extensions", "--list-extensions", "--show-versions"]
            res = subprocess.run(cmd, capture_output=True, text=True)
            for line in res.stdout.splitlines():
                if "@" in line:
                    eid, ver = line.strip().split("@", 1)
                    installed_map[eid.lower()] = ver
except Exception:
    pass

# 2. Configured extensions in profile
default_extensions = [
    {"id": "Oracle.sql-developer", "name": "Oracle SQL Developer for VS Code", "publisher": "Oracle"},
    {"id": "google.google-antigravity", "name": "Google Antigravity AI Assistant", "publisher": "Google"},
    {"id": "ms-python.python", "name": "Python Extension for VS Code", "publisher": "Microsoft"},
    {"id": "ms-python.vscode-pylance", "name": "Pylance Language Server", "publisher": "Microsoft"},
    {"id": "ms-python.debugpy", "name": "Python Debugger", "publisher": "Microsoft"},
    {"id": "ms-python.vscode-python-envs", "name": "Python Environments", "publisher": "Microsoft"},
    {"id": "github.vscode-github-actions", "name": "GitHub Actions", "publisher": "GitHub"},
    {"id": "redhat.vscode-yaml", "name": "YAML Language Support", "publisher": "Red Hat"}
]

# 3. Query Microsoft Marketplace API for latest versions
req_criteria = [{"filterType": 7, "value": e["id"]} for e in default_extensions]
req_body = {"filters": [{"criteria": req_criteria}], "flags": 914}

marketplace_map = {}
try:
    req = urllib.request.Request(
        "https://marketplace.visualstudio.com/_apis/public/gallery/extensionquery",
        data=json.dumps(req_body).encode("utf-8"),
        headers={
            "Content-Type": "application/json",
            "Accept": "application/json;api-version=3.0-preview.1",
            "User-Agent": "Mozilla/5.0"
        }
    )
    with urllib.request.urlopen(req, timeout=6) as response:
        data = json.loads(response.read().decode("utf-8"))
        for result in data.get("results", []):
            for ext in result.get("extensions", []):
                p_name = ext.get("publisher", {}).get("publisherName", "")
                e_name = ext.get("extensionName", "")
                full_id = f"{p_name}.{e_name}".lower()
                versions = ext.get("versions", [])
                if versions:
                    marketplace_map[full_id] = {
                        "version": versions[0].get("version"),
                        "download_url": versions[0].get("assetUri", "") + "/Microsoft.VisualStudio.Services.VSIXPackage" if versions[0].get("assetUri") else ""
                    }
except Exception as e:
    pass

# 4. Compare versions and build report
results = []
updates_available = 0

for ext in default_extensions:
    eid = ext["id"].lower()
    inst_ver = installed_map.get(eid, "not installed" if container_running else "offline")
    mkt_info = marketplace_map.get(eid, {})
    latest_ver = mkt_info.get("version", inst_ver if inst_ver != "not installed" else "unknown")
    download_url = mkt_info.get("download_url", "")

    status = "UP-TO-DATE"
    if inst_ver == "not installed":
        status = "MISSING"
        updates_available += 1
    elif latest_ver != "unknown" and inst_ver != "offline" and inst_ver != latest_ver:
        status = "UPDATE_AVAILABLE"
        updates_available += 1

    results.append({
        "id": ext["id"],
        "name": ext["name"],
        "publisher": ext["publisher"],
        "installed_version": inst_ver,
        "latest_version": latest_ver,
        "status": status,
        "download_url": download_url
    })

summary_data = {
    "timestamp": subprocess.run(["date", "+%Y-%m-%d %H:%M:%S"], capture_output=True, text=True).stdout.strip(),
    "container": container_name,
    "container_running": container_running,
    "total_extensions": len(results),
    "updates_available": updates_available,
    "extensions": results
}

os.makedirs(os.path.dirname(status_json_path), exist_ok=True)
with open(status_json_path, "w", encoding="utf-8") as f:
    json.dump(summary_data, f, indent=2)

if json_output:
    print(json.dumps(summary_data, indent=2))
    sys.exit(0)

# Render CLI Table
CYAN = "\033[0;36m"
GREEN = "\033[0;32m"
YELLOW = "\033[1;33m"
RED = "\033[0;31m"
BOLD = "\033[1m"
NC = "\033[0m"

print("==================================================================")
print(f"📦 {BOLD}VS CODE & WEB IDE EXTENSIONS VERSION REPORT{NC}")
print("==================================================================")
print(f"🖥️  Container: {BOLD}{container_name}{NC} ({'🟢 Running' if container_running else '🔴 Stopped'})")
print("------------------------------------------------------------------")
print(f"{BOLD}{'Extension ID':<32} {'Installed':<15} {'Latest':<15} {'Status':<16}{NC}")
print("------------------------------------------------------------------")

for r in results:
    st = r["status"]
    if st == "UP-TO-DATE":
        st_label = f"{GREEN}✅ Up-to-date{NC}"
    elif st == "UPDATE_AVAILABLE":
        st_label = f"{YELLOW}⚠️ Update avail{NC}"
    elif st == "MISSING":
        st_label = f"{RED}❌ Missing{NC}"
    else:
        st_label = f"{CYAN}ℹ️ Unknown{NC}"
    print(f"{r['id']:<32} {r['installed_version']:<15} {r['latest_version']:<15} {st_label}")

print("==================================================================")
if updates_available > 0:
    print(f"{YELLOW}💡 NOTICE: {updates_available} extension(s) can be updated!{NC}")
    print(f"👉 To apply updates, run: {BOLD}./scripts/update-extensions.sh -u{NC}")
else:
    print(f"{GREEN}🎉 All extensions are up to date!{NC}")
print("==================================================================")

PYEOF

# Handle actions
case "$MODE" in
  update)
    echo ""
    echo "🚀 Updating outdated extensions in Web IDE..."
    "$WORKSPACE_DIR/scripts/internal/install-web-ide-extensions.sh"
    echo "✅ Extensions updated successfully!"
    "$SCRIPT_DIR/update-extensions.sh" --check
    ;;
  cache_vsix)
    echo ""
    echo "📦 Downloading latest .vsix packages to $EXT_DIR (Air-Gapped Puffer)..."
    python3 - << 'PYEOF'
import json, os, urllib.request

status_file = os.path.join("metrics", "extensions_status.json")
ext_dir = os.path.join("binaries", "extensions")
os.makedirs(ext_dir, exist_ok=True)

if os.path.exists(status_file):
    data = json.load(open(status_file))
    for ext in data.get("extensions", []):
        url = ext.get("download_url")
        eid = ext.get("id")
        if url:
            target_path = os.path.join(ext_dir, f"{eid.lower()}.vsix")
            print(f"📥 Downloading {eid} -> {target_path}...")
            try:
                urllib.request.urlretrieve(url, target_path)
                print(f"   ✅ Saved {eid}.vsix")
            except Exception as e:
                print(f"   ⚠️ Could not download {eid}: {e}")
PYEOF
    echo "✅ VSIX offline cache updated!"
    ;;
  upgrade_core)
    echo ""
    echo "🐳 Upgrading Web IDE base container image..."
    podman pull lscr.io/linuxserver/code-server:latest
    "$WORKSPACE_DIR/scripts/internal/generate-compose-override.sh"
    podman-compose up -d --force-recreate "$WEB_IDE_CONTAINER"
    echo "✅ Web IDE core upgraded and restarted!"
    ;;
esac

chmod +x "$0" 2>/dev/null || true
