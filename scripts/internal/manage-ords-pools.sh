#!/usr/bin/env bash
# ==============================================================================
# Oracle REST Data Services (ORDS) Multi-Tenant Pool Manager
# Handles dynamic registration, deregistration, sync, and health-probing
# of individual database connection pools (Variant 3: Smart Gateway + Micro-Registrar).
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

ORDS_PORT="${ORDS_PORT:-8088}"
ORDS_SSL_PORT="${ORDS_HTTPS_PORT:-8448}"
MOUNT_DIR="${ORDS_MOUNT_DIR:-proxy}"
BASE_CONF_DIR="$WORKSPACE_DIR/config/ords/$MOUNT_DIR"
DATABASES_DIR="$BASE_CONF_DIR/databases"

# Helper to fetch listener password without disk leakage
get_ords_listener_pwd() {
  local pwd=""
  if command -v podman &>/dev/null && podman secret exists "ords_listener_password" 2>/dev/null; then
    pwd=$(podman secret inspect --showsecret ords_listener_password 2>/dev/null | grep '"SecretData"' | cut -d'"' -f4 | tr -d '\r\n' || true)
  fi
  if [ -z "$pwd" ] && [ -x "$WORKSPACE_DIR/scripts/get-password.sh" ]; then
    pwd=$("$WORKSPACE_DIR/scripts/get-password.sh" ords_listener_password -p 2>/dev/null || true)
  fi
  if [ -z "$pwd" ]; then
    pwd="placeholder"
  fi
  echo "$pwd"
}

cmd="${1:-status}"
shift || true

case "$cmd" in
  register)
    pool_name="${1:-}"
    db_cname="${2:-}"
    db_port="${3:-1521}"
    db_service="${4:-FREEPDB1}"

    if [ -z "$pool_name" ] || [ -z "$db_cname" ]; then
      echo "❌ Usage: $0 register <pool_name> <db_container> [db_port] [db_service]" >&2
      exit 1
    fi

    mkdir -p "$DATABASES_DIR/$pool_name"
    ords_pwd=$(get_ords_listener_pwd)

    cat <<EOF_POOL > "$DATABASES_DIR/$pool_name/pool.xml"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
<properties>
<entry key="db.connectionType">basic</entry>
<entry key="db.hostname">${db_cname}</entry>
<entry key="db.port">${db_port}</entry>
<entry key="db.servicename">${db_service}</entry>
<entry key="db.username">ORDS_PUBLIC_USER</entry>
<entry key="db.password">${ords_pwd}</entry>
<entry key="feature.sdw">true</entry>
<entry key="feature.apex">true</entry>
<entry key="plsql.gateway.mode">proxied</entry>
<entry key="restEnabledSql.active">true</entry>
</properties>
EOF_POOL

    # If default does not exist or this is proxy, mirror to default
    mkdir -p "$DATABASES_DIR/default"
    if [ "$pool_name" = "proxy" ] || [ ! -f "$DATABASES_DIR/default/pool.xml" ]; then
      cp "$DATABASES_DIR/$pool_name/pool.xml" "$DATABASES_DIR/default/pool.xml" 2>/dev/null || true
    fi

    echo "✅ ORDS pool '$pool_name' registered -> ${db_cname}:${db_port}/${db_service}"
    ;;

  deregister)
    pool_name="${1:-}"
    if [ -z "$pool_name" ]; then
      echo "❌ Usage: $0 deregister <pool_name>" >&2
      exit 1
    fi

    if [ -d "$DATABASES_DIR/$pool_name" ]; then
      rm -rf "$DATABASES_DIR/$pool_name"
      echo "🗑️  ORDS pool '$pool_name' deregistered."
    else
      echo "ℹ️  Pool '$pool_name' was not present."
    fi
    ;;

  sync)
    # Sync pools with currently running DB containers
    mkdir -p "$DATABASES_DIR"
    running_dbs=()
    if command -v podman &>/dev/null; then
      while IFS= read -r cname; do
        [ -n "$cname" ] && running_dbs+=("$cname")
      done < <(podman ps --format '{{.Names}}' 2>/dev/null | grep -E '^(db-.*|oracle-db-.*)$' || true)
    fi

    valid_pools=("default" "proxy")
    for c in "${running_dbs[@]}"; do
      pname=$(echo "$c" | sed 's/^db-//' | sed 's/^oracle-db-//' | tr '-' '_')
      valid_pools+=("$pname")
    done

    # Remove stale pools whose DB container is no longer running
    for d in "$DATABASES_DIR"/*; do
      [ -d "$d" ] || continue
      p=$(basename "$d")
      is_valid=false
      for vp in "${valid_pools[@]}"; do
        if [ "$vp" = "$p" ]; then
          is_valid=true
          break
        fi
      done
      if [ "$is_valid" = "false" ]; then
        echo "🧹 Removing orphaned ORDS pool '$p' (container not running)..."
        rm -rf "$d"
      fi
    done
    echo "✅ ORDS pools synchronized with active containers: ${valid_pools[*]}"
    ;;

  status)
    format="${1:-table}"
    mkdir -p "$DATABASES_DIR"
    
    if [ "$format" = "json" ]; then
      DATABASES_DIR="$DATABASES_DIR" ORDS_PORT="$ORDS_PORT" python3 -c '
import os, glob, urllib.request, ssl, time, json

ctx = ssl._create_unverified_context()
opener = urllib.request.build_opener(urllib.request.HTTPSHandler(context=ctx))
urllib.request.install_opener(opener)

pools_dir = os.environ.get("DATABASES_DIR", "config/ords/proxy/databases")
ords_port = os.environ.get("ORDS_PORT", "8088")
pool_dirs = [d for d in glob.glob(f"{pools_dir}/*") if os.path.isdir(d) and os.path.basename(d) != "default"]

result = {}
for pd in sorted(pool_dirs):
    pname = os.path.basename(pd)
    pxml = os.path.join(pd, "pool.xml")
    target = "unknown"
    if os.path.isfile(pxml):
        try:
            with open(pxml, "r", encoding="utf-8") as f:
                content = f.read()
                import re
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
        req = urllib.request.Request(url, headers={"User-Agent": "ORDSManager"})
        with opener.open(req, timeout=1.5) as resp:
            lat = int((time.time() - t0) * 1000)
            http_code = resp.status
            status = "online" if resp.status in [200, 301, 302, 303, 307, 308, 404] else "degraded"
    except urllib.error.HTTPError as e:
        lat = int((time.time() - t0) * 1000)
        http_code = e.code
        status = "online" if e.code in [200, 301, 302, 303, 307, 308, 404] else "degraded"
    except Exception:
        status = "offline"

    result[pname] = {
        "configured": True,
        "status": status,
        "url": f"http://localhost:{ords_port}/ords/{pname}/",
        "target": target,
        "latency_ms": lat,
        "http_code": http_code
    }

print(json.dumps(result, indent=2))
'
    else
      echo -e "\n🌐 Active ORDS Connection Pools (Gateway port: ${ORDS_PORT}):"
      echo -e "-------------------------------------------------------------------------------"
      printf "%-18s %-32s %-12s %-10s\n" "POOL NAME" "TARGET DATABASE" "STATUS" "LATENCY"
      echo -e "-------------------------------------------------------------------------------"
      for pd in "$DATABASES_DIR"/*; do
        [ -d "$pd" ] || continue
        pname=$(basename "$pd")
        [ "$pname" = "default" ] && continue
        
        target="unknown"
        if [ -f "$pd/pool.xml" ]; then
          h=$(grep -oE '<entry key="db.hostname">[^<]+' "$pd/pool.xml" | cut -d'>' -f2 || true)
          p=$(grep -oE '<entry key="db.port">[^<]+' "$pd/pool.xml" | cut -d'>' -f2 || true)
          s=$(grep -oE '<entry key="db.servicename">[^<]+' "$pd/pool.xml" | cut -d'>' -f2 || true)
          [ -n "$h" ] && target="${h}:${p}/${s}"
        fi

        t0=$(python3 -c 'import time; print(time.time())')
        res_code=$(curl -k -s -o /dev/null -w "%{http_code}" --connect-timeout 1 -m 2 "http://127.0.0.1:${ORDS_PORT}/ords/${pname}/" 2>/dev/null || echo "000")
        t1=$(python3 -c 'import time; print(time.time())')
        lat_ms=$(python3 -c "print(int(($t1 - $t0) * 1000))")

        if [[ "$res_code" =~ ^(200|302|404)$ ]]; then
          st_label="🟢 Online"
        elif [ "$res_code" = "000" ]; then
          st_label="🔴 Offline"
        else
          st_label="🟡 Code $res_code"
        fi

        printf "%-18s %-32s %-12s %-10s\n" "$pname" "$target" "$st_label" "${lat_ms}ms"
      done
      echo -e "-------------------------------------------------------------------------------\n"
    fi
    ;;

  *)
    echo "❌ Unknown command '$cmd'. Usage: $0 {register|deregister|sync|status} [args]" >&2
    exit 1
    ;;
esac
