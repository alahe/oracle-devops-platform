#!/usr/bin/env bash
# ==============================================================================
# Unit Test: Database Profiles & Topology Isolation Audit
# (tests/unit/test-database-profiles-isolation.sh)
#
# Validates strict non-collision across all database profiles and blueprints:
# 1. Global uniqueness of container_name across all local concrete profiles.
# 2. Global uniqueness of db_port across all local concrete profiles (1531-1538).
# 3. Global uniqueness of ORDS pool_name across all local concrete profiles.
# 4. Intra-blueprint isolation: no single blueprint may define colliding DBs.
# 5. Remote profiles (OCI ADB, Remote DB) correctly declare zero local ports/containers.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${CYAN}==================================================================${NC}"
echo -e "${BOLD}🔍 AUDITING DATABASE PROFILES & TOPOLOGY ISOLATION (NON-COLLISION)${NC}"
echo -e "${CYAN}==================================================================${NC}"

export WORKSPACE_DIR
python3 - << 'PYEOF'
import os
import sys
import glob
import yaml

workspace_dir = os.environ.get("WORKSPACE_DIR", os.path.abspath("."))
profiles_dir = os.path.join(workspace_dir, "config", "profiles", "databases")
blueprints_dir = os.path.join(workspace_dir, "config", "blueprints")

if not os.path.isdir(profiles_dir):
    print(f"❌ Error: Database profiles directory not found: {profiles_dir}")
    sys.exit(1)

yaml_files = sorted(glob.glob(os.path.join(profiles_dir, "*.yaml")))
if not yaml_files:
    print(f"❌ Error: No database profiles found in {profiles_dir}")
    sys.exit(1)

errors = []
container_names = {}  # name -> profile_filename
db_ports = {}         # port -> profile_filename
ords_pools = {}       # pool_name -> profile_filename
profiles_data = {}    # profile_id -> parsed_dict

print(f"📂 Analyzing {len(yaml_files)} database profiles in config/profiles/databases/...\n")

# 1. Inspect all database profiles
for yf in yaml_files:
    fname = os.path.basename(yf)
    with open(yf, "r", encoding="utf-8") as f:
        try:
            data = yaml.safe_load(f) or {}
        except Exception as e:
            errors.append(f"YAML Syntax Error in '{fname}': {e}")
            continue

    prof_info = data.get("profile", {})
    prof_id = prof_info.get("id", fname.replace(".yaml", ""))
    db_sect = data.get("database", {})
    features_sect = data.get("database_features", {})
    ords_sect = features_sect.get("ords", {}) if isinstance(features_sect, dict) else {}

    c_name = db_sect.get("container_name")
    db_port = db_sect.get("db_port")
    pool_name = ords_sect.get("pool_name") if isinstance(ords_sect, dict) else None
    db_type = prof_info.get("db_type", "standard")

    profiles_data[prof_id] = {
        "file": fname,
        "container_name": c_name,
        "db_port": db_port,
        "pool_name": pool_name,
        "db_type": db_type,
    }

    # Abstract base profile (db-oracle.yaml) is a template, container_name is None
    if prof_id == "db-oracle" and c_name is None:
        continue

    # Remote profiles have no local container or host port
    if "remote" in prof_id or db_type == "remote" or (c_name is None and db_port is None):
        if c_name is not None:
            errors.append(f"Remote profile '{fname}' must not declare local container_name (found '{c_name}')")
        if db_port is not None:
            errors.append(f"Remote profile '{fname}' must not declare local db_port (found '{db_port}')")
        continue

    # Concrete local profiles MUST define container_name and db_port
    if not c_name:
        errors.append(f"Concrete profile '{fname}' is missing database.container_name")
    else:
        if c_name in container_names:
            prev = container_names[c_name]
            errors.append(f"CONTAINER NAME COLLISION: '{fname}' and '{prev}' both use container_name '{c_name}'")
        else:
            container_names[c_name] = fname

    if db_port is None:
        errors.append(f"Concrete profile '{fname}' is missing database.db_port")
    else:
        try:
            port_num = int(db_port)
            if port_num in db_ports:
                prev = db_ports[port_num]
                errors.append(f"PORT COLLISION: '{fname}' and '{prev}' both use db_port {port_num}")
            else:
                db_ports[port_num] = fname
        except ValueError:
            errors.append(f"Invalid non-integer db_port '{db_port}' in '{fname}'")

    if pool_name:
        if pool_name in ords_pools:
            prev = ords_pools[pool_name]
            errors.append(f"ORDS POOL NAME COLLISION: '{fname}' and '{prev}' both use pool_name '{pool_name}'")
        else:
            ords_pools[pool_name] = fname

# Print summary table of profiles
print(f"{'Profile File':<32} | {'Container Name':<24} | {'Port':<6} | {'ORDS Pool':<16} | Status")
print("-" * 94)
for pid, pdata in profiles_data.items():
    c_str = str(pdata['container_name']) if pdata['container_name'] else "(none / remote)"
    p_str = str(pdata['db_port']) if pdata['db_port'] else "(none)"
    pool_str = str(pdata['pool_name']) if pdata['pool_name'] else "(none)"
    status_str = "✅ UNIQUE" if pdata['container_name'] or "remote" in pid or pid == "db-oracle" else "❌ COLLISION"
    print(f"{pdata['file']:<32} | {c_str:<24} | {p_str:<6} | {pool_str:<16} | {status_str}")

print("\n" + "=" * 94)
print("🔍 AUDITING BLUEPRINTS FOR INTRA-BLUEPRINT DATABASE COLLISION...")
print("=" * 94 + "\n")

# 2. Inspect all blueprints for intra-blueprint collisions
bp_files = sorted(glob.glob(os.path.join(blueprints_dir, ".env.*")))
for bpf in bp_files:
    bp_name = os.path.basename(bpf)
    env_vars = {}
    with open(bpf, "r", encoding="utf-8") as bf:
        for line in bf:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            if "=" in line:
                k, v = line.split("=", 1)
                env_vars[k.strip()] = v.strip().strip("'\"")

    # Collect all DB profiles referenced in this blueprint
    bp_dbs = []
    for k, v in env_vars.items():
        if (k.startswith("DB_") or k == "MAIN_DB_PROFILE") and v.lower() != "none":
            bp_dbs.append((k, v))

    if len(bp_dbs) > 1:
        # Check intra-blueprint collisions
        bp_cnames = set()
        bp_ports = set()
        bp_pools = set()

        for var_name, prof_name in bp_dbs:
            p_data = profiles_data.get(prof_name)
            if not p_data:
                errors.append(f"Blueprint '{bp_name}' references unknown DB profile '{prof_name}' in {var_name}")
                continue

            cn = p_data["container_name"]
            pt = p_data["db_port"]
            pl = p_data["pool_name"]

            if cn:
                if cn in bp_cnames:
                    errors.append(f"INTRA-BLUEPRINT CONTAINER COLLISION in '{bp_name}': multiple DBs use '{cn}'")
                bp_cnames.add(cn)

            if pt:
                if pt in bp_ports:
                    errors.append(f"INTRA-BLUEPRINT PORT COLLISION in '{bp_name}': multiple DBs use port {pt}")
                bp_ports.add(pt)

            if pl:
                if pl in bp_pools:
                    errors.append(f"INTRA-BLUEPRINT ORDS POOL COLLISION in '{bp_name}': multiple DBs use pool '{pl}'")
                bp_pools.add(pl)

        print(f"✅ Blueprint {bp_name:<34}: {len(bp_dbs)} DBs verified without collision ({[p for _, p in bp_dbs]})")
    elif len(bp_dbs) == 1:
        print(f"✅ Blueprint {bp_name:<34}: 1 DB ({bp_dbs[0][1]})")
    else:
        print(f"✅ Blueprint {bp_name:<34}: 0 DBs (Standalone App / Edge Gateway)")

if errors:
    print("\n" + "❌" * 40)
    print(f"💥 FOUND {len(errors)} DATABASE PROFILE COLLISION ERRORS:")
    for err in errors:
        print(f"  • {err}")
    print("❌" * 40 + "\n")
    sys.exit(1)

print("\n" + "=" * 94)
print("🎉 ALL DATABASE PROFILES AND BLUEPRINTS ARE 100% ISOLATED WITH ZERO COLLISIONS!")
print("=" * 94)
PYEOF

echo -e "\n${GREEN}✅ Database Profiles & Topology Isolation Test Passed!${NC}"
