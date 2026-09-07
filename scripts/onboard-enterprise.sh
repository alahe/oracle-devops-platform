#!/usr/bin/env bash
# ==============================================================================
# Enterprise Onboarding & Profile Customization Utility
#
# Allows corporate teams to adapt the platform to internal infrastructure:
# - Connect to internal Artifactory / Harbor container image registries
# - Explicitly patch container_image references in config/profiles/**/*.yaml
# - Revert profiles back to upstream public registries on demand
# - Configure egress HTTP/HTTPS proxies and corporate Root CA certificates
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
CYAN="\033[0;36m"
RED="\033[0;31m"
BOLD="\033[1m"
NC="\033[0m"

CONFIG_FILE="$WORKSPACE_DIR/config/enterprise.yaml"
EXAMPLE_FILE="$WORKSPACE_DIR/config/enterprise.yaml.example"
PROFILES_DIR="$WORKSPACE_DIR/config/profiles"

log_msg() {
  echo -e "${CYAN}ℹ️  $1${NC}"
}

log_ok() {
  echo -e "${GREEN}✅ $1${NC}"
}

log_warn() {
  echo -e "${YELLOW}⚠️  $1${NC}"
}

log_err() {
  echo -e "${RED}❌ $1${NC}"
}

show_help() {
  cat << 'EOF'
Enterprise Onboarding & Configuration Utility

Usage:
  ./scripts/onboard-enterprise.sh [options]

Options:
  --interactive, -i   Run interactive onboarding wizard to configure enterprise.yaml
  --patch-profiles    Explicitly patch config/profiles/**/*.yaml with Artifactory image mirrors
  --revert            Revert config/profiles/**/*.yaml back to upstream public registries
  --status, -s        Check current enterprise configuration and profile patch status
  --validate, -v      Validate connectivity to Artifactory and proxy endpoints
  --help, -h          Show this help message

Examples:
  ./scripts/onboard-enterprise.sh --interactive
  ./scripts/onboard-enterprise.sh --patch-profiles
  ./scripts/onboard-enterprise.sh --revert
  ./scripts/onboard-enterprise.sh --status
EOF
}

# ------------------------------------------------------------------------------
# Action: Check Status
# ------------------------------------------------------------------------------
do_status() {
  echo "=================================================================="
  echo -e "${BOLD}🏢 Enterprise Configuration & Artifactory Status${NC}"
  echo "=================================================================="

  if [ -f "$CONFIG_FILE" ]; then
    log_ok "Enterprise configuration active: config/enterprise.yaml"
    
    python3 - << PYEOF
import yaml, sys

try:
    with open("$CONFIG_FILE", "r") as f:
        data = yaml.safe_load(f) or {}
    
    ent = data.get("enterprise", {})
    reg = data.get("registry", {})
    net = data.get("network", {})
    
    print("   ├─ Enterprise Name:   " + str(ent.get("name", "N/A")))
    print("   ├─ Environment:       " + str(ent.get("environment", "N/A")))
    print("   ├─ Registry Base URL: " + str(reg.get("base_url", "None")))
    print("   ├─ Auth Mode:         " + str(reg.get("auth_mode", "anonymous")))
    print("   ├─ HTTP Proxy:        " + str(net.get("http_proxy") or "Direct (None)"))
    print("   └─ Corporate CA:      " + str(net.get("corporate_ca_bundle_path") or "System default"))
except Exception as e:
    print("   ❌ Error reading config: " + str(e))
PYEOF
  else
    log_warn "No config/enterprise.yaml found. Using standard upstream configuration."
    echo "   💡 Run './scripts/onboard-enterprise.sh --interactive' or copy config/enterprise.yaml.example."
  fi

  echo ""
  echo "🔍 Inspecting config/profiles/**/*.yaml image references:"

  # Count profiles pointing to custom registry vs upstream
  python3 - << PYEOF
import os, glob, yaml

profiles_dir = "$PROFILES_DIR"
yaml_files = glob.glob(os.path.join(profiles_dir, "**/*.yaml"), recursive=True)

artifactory_count = 0
upstream_count = 0
total_images = 0

for yf in sorted(yaml_files):
    try:
        with open(yf, "r") as f:
            content = f.read()
        for line in content.splitlines():
            line_str = line.strip()
            if line_str.startswith("container_image:"):
                total_images += 1
                val = line_str.split(":", 1)[1].strip().strip('"').strip("'")
                if "container-registry.oracle.com" in val or "docker.io" in val or "ghcr.io" in val:
                    upstream_count += 1
                else:
                    artifactory_count += 1
    except Exception:
        pass

print(f"   ├─ Total YAML Profiles:         {len(yaml_files)}")
print(f"   ├─ Upstream Public Images:       {upstream_count}")
print(f"   └─ Enterprise Mirrored Images:   {artifactory_count}")

if artifactory_count > 0 and upstream_count == 0:
    print("\n   👉 Status: 🟢 100% Mirrored to Enterprise Artifactory")
elif artifactory_count > 0 and upstream_count > 0:
    print("\n   👉 Status: 🟡 Partially Mirrored (Mixed public and enterprise)")
else:
    print("\n   👉 Status: 🔵 100% Upstream Public Registries")
PYEOF
  echo "=================================================================="
}

# ------------------------------------------------------------------------------
# Action: Patch Profiles Explicitly on Disk
# ------------------------------------------------------------------------------
do_patch_profiles() {
  local target_dir="${1:-$PROFILES_DIR}"

  if [ ! -f "$CONFIG_FILE" ]; then
    if [ -f "$EXAMPLE_FILE" ]; then
      log_warn "config/enterprise.yaml not found. Creating from config/enterprise.yaml.example..."
      cp "$EXAMPLE_FILE" "$CONFIG_FILE"
    else
      log_err "Missing config/enterprise.yaml and template config/enterprise.yaml.example!"
      exit 1
    fi
  fi

  echo "=================================================================="
  echo -e "${BOLD}🔨 Patching YAML Profiles on Disk (Enterprise Artifactory)${NC}"
  echo "   Target directory: $target_dir"
  echo "=================================================================="

  python3 - << PYEOF
import os, glob, sys, yaml, shutil

config_file = "$CONFIG_FILE"
target_dir = "$target_dir"

with open(config_file, "r") as f:
    cfg = yaml.safe_load(f) or {}

mappings = cfg.get("registry", {}).get("mappings", {})
if not mappings:
    print("❌ No registry mappings defined in config/enterprise.yaml!")
    sys.exit(1)

yaml_files = glob.glob(os.path.join(target_dir, "**/*.yaml"), recursive=True)
patched_files = 0
replaced_lines = 0

for yf in sorted(yaml_files):
    with open(yf, "r", encoding="utf-8") as f:
        lines = f.readlines()
    
    modified = False
    new_lines = []
    
    for line in lines:
        stripped = line.strip()
        new_line = line
        if stripped.startswith("container_image:"):
            for upstream, mirror in mappings.items():
                if upstream in line:
                    new_line = line.replace(upstream, mirror)
                    if new_line != line:
                        modified = True
                        replaced_lines += 1
                        break
        new_lines.append(new_line)
    
    if modified:
        # Create .bak backup if not already present
        bak_file = yf + ".bak"
        if not os.path.exists(bak_file):
            shutil.copyfile(yf, bak_file)
        
        with open(yf, "w", encoding="utf-8") as f:
            f.writelines(new_lines)
        
        rel_path = os.path.relpath(yf, target_dir)
        print(f"   ✏️  Patched: {rel_path}")
        patched_files += 1

print("\n------------------------------------------------------------------")
print(f"✅ Successfully patched {patched_files} file(s) ({replaced_lines} image URI replacements).")
print(f"   Original backups saved with '.bak' extension for instant revert.")
PYEOF
  log_ok "Profiles explicitly updated on disk."
}

# ------------------------------------------------------------------------------
# Action: Revert Profiles back to Upstream Public Registries
# ------------------------------------------------------------------------------
do_revert() {
  local target_dir="${1:-$PROFILES_DIR}"

  echo "=================================================================="
  echo -e "${BOLD}⏪ Reverting YAML Profiles on Disk (Upstream Registries)${NC}"
  echo "   Target directory: $target_dir"
  echo "=================================================================="

  python3 - << PYEOF
import os, glob, sys, yaml, shutil

target_dir = "$target_dir"
yaml_files = glob.glob(os.path.join(target_dir, "**/*.yaml"), recursive=True)
reverted_count = 0

# Strategy 1: Restore from .bak if present
for yf in sorted(yaml_files):
    bak_file = yf + ".bak"
    if os.path.exists(bak_file):
        shutil.copyfile(bak_file, yf)
        os.remove(bak_file)
        rel_path = os.path.relpath(yf, target_dir)
        print(f"   🔄 Restored from .bak: {rel_path}")
        reverted_count += 1

# Strategy 2: If no .bak, check if config/enterprise.yaml has reverse mappings
config_file = "$CONFIG_FILE"
if reverted_count == 0 and os.path.exists(config_file):
    with open(config_file, "r") as f:
        cfg = yaml.safe_load(f) or {}
    mappings = cfg.get("registry", {}).get("mappings", {})
    
    for yf in sorted(yaml_files):
        with open(yf, "r", encoding="utf-8") as f:
            lines = f.readlines()
        modified = False
        new_lines = []
        for line in lines:
            new_line = line
            if line.strip().startswith("container_image:"):
                for upstream, mirror in mappings.items():
                    if mirror in line:
                        new_line = line.replace(mirror, upstream)
                        if new_line != line:
                            modified = True
                            break
            new_lines.append(new_line)
        if modified:
            with open(yf, "w", encoding="utf-8") as f:
                f.writelines(new_lines)
            rel_path = os.path.relpath(yf, target_dir)
            print(f"   🔄 Reverse mapped: {rel_path}")
            reverted_count += 1

print("\n------------------------------------------------------------------")
print(f"✅ Reversion complete: {reverted_count} file(s) restored to upstream public registries.")
PYEOF
  log_ok "Profiles successfully reverted."
}

# ------------------------------------------------------------------------------
# Action: Validate Connectivity
# ------------------------------------------------------------------------------
do_validate() {
  echo "=================================================================="
  echo -e "${BOLD}🌐 Validating Enterprise Endpoints & Network${NC}"
  echo "=================================================================="

  if [ ! -f "$CONFIG_FILE" ]; then
    log_err "Missing config/enterprise.yaml. Run './scripts/onboard-enterprise.sh --interactive' first."
    exit 1
  fi

  python3 - << PYEOF
import yaml, urllib.request, urllib.error, ssl, os

with open("$CONFIG_FILE", "r") as f:
    cfg = yaml.safe_load(f) or {}

reg_url = cfg.get("registry", {}).get("base_url", "")
http_proxy = cfg.get("network", {}).get("http_proxy", "")
ca_bundle = cfg.get("network", {}).get("corporate_ca_bundle_path", "")

print(f"1. Checking Enterprise Registry: {reg_url}")
if reg_url:
    test_url = "https://" + reg_url.split("/")[0] + "/v2/"
    ctx = ssl.create_default_context()
    if ca_bundle and os.path.exists(ca_bundle):
        ctx.load_verify_locations(ca_bundle)
        print(f"   ├─ Corporate CA loaded from: {ca_bundle}")
    
    try:
        req = urllib.request.Request(test_url, headers={"User-Agent": "OraclePlatformOnboarder/1.0"})
        with urllib.request.urlopen(req, timeout=5, context=ctx) as resp:
            print(f"   └─ ✅ Registry responsive (HTTP {resp.status})")
    except urllib.error.HTTPError as e:
        # Docker v2 registry typically returns 401 Unauthorized for /v2/, which means endpoint is active!
        if e.code in (401, 200):
            print(f"   └─ ✅ Registry endpoint reachable & active (HTTP {e.code} auth response)")
        else:
            print(f"   └─ ⚠️  Registry returned HTTP {e.code}: {e.reason}")
    except Exception as e:
        print(f"   └─ ⚠️  Could not reach {test_url}: {e}")
        print("      (Note: If on VPN or behind proxy, ensure proxy is configured)")
else:
    print("   └─ ℹ️  No custom base_url specified.")

print("\n2. Checking Corporate CA Bundle:")
if ca_bundle:
    if os.path.exists(ca_bundle):
        print(f"   └─ ✅ CA bundle exists on disk: {ca_bundle}")
    else:
        print(f"   └─ ❌ CA bundle not found: {ca_bundle}")
else:
    print("   └─ ℹ️  System default CA trust store used.")
PYEOF
}

# ------------------------------------------------------------------------------
# Action: Interactive Onboarding Wizard
# ------------------------------------------------------------------------------
do_interactive() {
  echo "=================================================================="
  echo -e "${BOLD}🧙 Enterprise Onboarding Wizard${NC}"
  echo "   Configure platform for your corporate IT infrastructure"
  echo "=================================================================="

  read -r -p "Enter Enterprise Organization Name [Corporate Enterprise]: " ENT_NAME
  ENT_NAME="${ENT_NAME:-Corporate Enterprise}"

  read -r -p "Enter Base Artifactory / Registry URL [artifactory.corp.internal/docker-mirror]: " REG_URL
  REG_URL="${REG_URL:-artifactory.corp.internal/docker-mirror}"

  read -r -p "Enter HTTP/HTTPS Proxy URL (leave blank if direct): " PROXY_URL
  PROXY_URL="${PROXY_URL:-}"

  read -r -p "Enter Corporate CA Bundle Path (leave blank for system CA): " CA_PATH
  CA_PATH="${CA_PATH:-}"

  # Create config from template
  mkdir -p "$WORKSPACE_DIR/config"
  
  python3 - << PYEOF
import yaml, os

cfg = {
    "enterprise": {
        "name": "$ENT_NAME",
        "environment": "production"
    },
    "registry": {
        "base_url": "$REG_URL",
        "auth_mode": "anonymous",
        "mappings": {
            "container-registry.oracle.com/database/free": "$REG_URL/oracle/database/free",
            "container-registry.oracle.com/database/ords": "$REG_URL/oracle/database/ords",
            "container-registry.oracle.com/database/sqlcl": "$REG_URL/oracle/database/sqlcl",
            "docker.io/library/ubuntu": "$REG_URL/dockerhub/library/ubuntu",
            "ghcr.io": "$REG_URL/ghcr"
        }
    },
    "network": {
        "http_proxy": "$PROXY_URL",
        "https_proxy": "$PROXY_URL",
        "no_proxy": "localhost,127.0.0.1,*.corp.internal,.local,podman-machine-default",
        "corporate_ca_bundle_path": "$CA_PATH"
    },
    "domain": {
        "internal_domain": "corp.internal",
        "custom_tls_cert": "",
        "custom_tls_key": ""
    },
    "security": {
        "enforce_seps_wallet": True,
        "mask_tokens_in_logs": True,
        "audit_level": "strict"
    }
}

with open("$CONFIG_FILE", "w") as f:
    yaml.dump(cfg, f, default_flow_style=False, sort_keys=False)

print("✅ Generated config/enterprise.yaml successfully!")
PYEOF

  log_ok "Configuration saved."
  echo ""
  read -r -p "Do you want to explicitly patch YAML profiles in config/profiles/ now? [y/N]: " APPLY_NOW
  if [[ "$APPLY_NOW" =~ ^[Yy]$ ]]; then
    do_patch_profiles
  else
    echo "💡 You can patch profiles later with: ./scripts/onboard-enterprise.sh --patch-profiles"
  fi
}

# ------------------------------------------------------------------------------
# Main Dispatcher
# ------------------------------------------------------------------------------
if [ $# -eq 0 ]; then
  do_status
  exit 0
fi

case "$1" in
  --interactive|-i)
    do_interactive
    ;;
  --patch-profiles)
    do_patch_profiles "${2:-$PROFILES_DIR}"
    ;;
  --revert)
    do_revert "${2:-$PROFILES_DIR}"
    ;;
  --status|-s)
    do_status
    ;;
  --validate|-v)
    do_validate
    ;;
  --help|-h)
    show_help
    ;;
  *)
    log_err "Unknown argument: $1"
    show_help
    exit 1
    ;;
esac
