[ 🇬🇧 English ](database-image-switching-guide.md) | [ 🇪🇪 Eesti ](et/database-image-switching-guide.md) | [ 🇫🇮 Suomi ](fi/database-image-switching-guide.md) | [ 🇸🇪 Svenska ](sv/database-image-switching-guide.md) | [ 🇱🇻 Latviešu ](lv/database-image-switching-guide.md) | [ 🇱🇹 Lietuvių ](lt/database-image-switching-guide.md)

# 🔄 Database Container Image Switching & Multi-Vendor Guide

This guide explains how to switch between different Oracle 23ai container images, test community vs official builds, lock internal database web interfaces, and maximize build cache reuse.

---

## 🎯 1. Supported Base Images & Roles

The platform supports dual-vendor container images and custom FastStart layers:

| Image Name | Vendor & Source | Role | Primary Blueprints |
| :--- | :--- | :--- | :--- |
| `container-registry.oracle.com/database/free:latest` | **Oracle Official (OCR)** | Canonical enterprise production baseline | **All Standard Blueprints (1–6, 10–34)** |
| `docker.io/gvenzl/oracle-free:latest` | **Gerald Venzl (Docker Hub)** | Community build with rapid security patches | **Blueprint #7 (Alternate Vendor Test)** |
| `localhost/oracle-free-apex:23ai-apex26.1` | **FastStart Golden Base** | Pre-baked APEX 26.1 layer (0s compilation) | **Shared Across All DB Profiles** |

---

## 🚀 2. How to Switch Database Images (3 Methods)

### Method A: Single Command via Blueprint #7
To test the alternative Docker Hub community build side-by-side:
```bash
./scripts/deploy-blueprint.sh 7
```

### Method B: CLI Environment Override (Any Blueprint)
Override the container image dynamically without changing files:
```bash
ORACLE_CONTAINER_IMAGE="docker.io/gvenzl/oracle-free:latest" ./scripts/setup-all.sh -b 3 --fast
```

### Method C: Declarative YAML Profile Configuration
In your database profile (e.g. `config/profiles/databases/db-proxy-oracle.yaml`):
```yaml
database:
  container_image: "container-registry.oracle.com/database/free:latest"
```

---

## 🔒 3. Internal Database Security Lockdown (`--lock-internal-apex`)

When running multi-database stacks (e.g. Blueprint #21, #23) with internal metadata databases (`db-forms`, `db-publisher`):
```bash
./scripts/setup-all.sh -b 23 --lock-internal-apex --fast
```
**What happens:**
1. Both databases boot instantly using the unified FastStart base image.
2. In `db-forms` and `db-publisher`, `APEX_PUBLIC_USER` and `APEX_LISTENER` accounts are automatically locked (`ACCOUNT LOCK`).
3. Dedicated ORDS web routing pools are omitted, ensuring **100% internal network isolation**.

---

## ⚡ 4. Fast & Single-Pass Testing Flags

| Flag | Script | Description |
| :--- | :--- | :--- |
| `--fast` / `--skip-tests` | `setup-all.sh`, `deploy-blueprint.sh` | Skips post-provisioning E2E diagnostic checks (saves ~30–45s) |
| `--snapshot-mode base` | `setup-all.sh` | Creates golden snapshot of clean base DB before applications are deployed |
| `--snapshot-mode release` | `setup-all.sh` | Creates golden snapshot of full DB + deployed applications (default) |
| `--single-pass` / `--pass1-only` | `run_blueprint_matrix_test.sh` | Runs only Pass 1 cold provisioning (saves ~1.5h in CI) |
| `--unified-middleware` | `setup-all.sh` | Runs unified Forms+Publisher container saving 50% RAM |
