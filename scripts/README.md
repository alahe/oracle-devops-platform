[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🛠️ CLI Scripts and Developer Tools Reference

This guide provides comprehensive documentation for all environment lifecycle, diagnostic, administrative, and developer scripts in the project.

All scripts adhere to a strict **3-tier modular directory layout** (Rule 3), where daily developer CLI commands reside in the `scripts/` root directory, and specialized sub-processes, lifecycle operations, and internal automation engines are cleanly separated into dedicated subdirectories.

---

## 📁 3-Tier Script Directory Layout

```text
scripts/
├── 🚀 ENVIRONMENT LIFECYCLE COMMANDS:
│   ├── setup-all.sh                 # Complete environment setup (Blueprints 0-11 & CLI)
│   ├── reset-all.sh                 # Environment, volumes, and network cleanup
│   ├── start-containers.sh          # Start or resume stopped containers
│   ├── deploy-remote.sh             # Remote deployment to cloud and target hosts
│   └── test-local-ci.sh             # Local GitHub Actions CI/CD simulation runner
│
├── 🔑 DEVELOPER & ADMIN CLI TOOLS:
│   ├── get-password.sh              # SEPS Wallet credential and password retrieval
│   ├── check-urls.sh                # HTTP health check for web endpoints, pools, and URLs
│   ├── check-wallet.sh              # SEPS Wallet passwordless TNS connection diagnostics
│   ├── sqlcl.sh                     # Smart SQLcl CLI wrapper (SEPS Wallet /@ALIAS support)
│   ├── create-developer.sh          # Developer account provisioning and password recovery
│   ├── register-connections.sh      # VS Code Oracle SQL Developer connection synchronizer
│   ├── publish-image-to-artifactory.sh # Image publishing to Artifactory & .env update
│   └── clean-logs.sh                # Installation logs and temporary cache cleanup
│
├── 📁 snapshots/                    # 📸 Golden Snapshots management (instant ~15s recovery)
│   ├── create-golden-snapshots.sh   # Creates compressed .tar.gz archive of database volumes
│   ├── restore-golden-snapshots.sh  # Restores database to last known working state
│   └── clean-golden-snapshots.sh    # Cleans old archives while keeping latest copy
│
├── 📁 certs/                        # 🛡️ Local SSL/TLS certificate trust tools (Zero-Admin / Non-Root)
│   ├── trust-local-cert-mac.sh      # macOS Keychain trust installer (0-Root)
│   ├── trust-local-cert.cmd / .ps1  # Windows Certificate Store trust scripts (0-Admin)
│   └── untrust-local-cert-mac.sh    # Certificate removal tools
│
├── 📁 publisher/                    # 📑 Analytics Publisher management and operations
│   ├── status-publisher.sh          # Publisher service and WebLogic server status
│   ├── restart-publisher.sh         # Graceful restart of Publisher container
│   ├── backup-publisher-catalog.sh  # Report catalog export and backup
│   └── deploy-publisher-reports.sh  # Report import and Git catalog synchronization
│
├── 📁 forms/                        # 📐 Oracle Forms 14c management and operations
│   ├── status-forms.sh              # Forms Runtime and WebLogic diagnostics
│   ├── restart-forms.sh             # Graceful restart of Forms container
│   └── deploy-forms-apps.sh         # .fmx application delivery to /u01/oracle/forms_apps
│
└── 📁 internal/                     # ⚙️ Non-interactive internal automation engines
    ├── common.sh, load-profile.sh, generate-compose-override.sh, create-wallet.sh ...
```

---

## 1. Automated Environment Setup (`setup-all.sh`)

The `./scripts/setup-all.sh` script executes full environment setup: downloads required software packages, orchestrates containers via Podman, waits for database and ORDS readiness, runs database schema migrations (Liquibase), installs APEX with bundle patches, and measures step durations (Rule 1).

> 🏛️ **Modular & Profile-Driven Architecture:**
> The `setup-all.sh` script acts as the **central orchestrator**, providing interactive CLI UI, live timers (Rule 7), benchmark collection (`metrics/`), and logging (`install_logs/`), delegating all domain tasks to modular helper engines in `scripts/internal/`:
> - 📦 **Shared core library:** `common.sh` (colors, metrics, progress bars, cleanup traps, compression)
> - 📄 **Compose Override:** `generate-compose-override.sh` (dynamic override & secrets management)
> - 📦 **Profiles & Topology:** `load-profile.sh` (single-pass YAML parsing & caching) & `resolve-topology.sh`
> - ⌛ **Health Check:** `wait-db-healthy.sh` (2-phase adaptive healthcheck and self-healing)
> - 🔌 **Instance Initialization:** `init-db-instance.sh`
> - 👤 **Users & Roles:** `apply-profile-users.sh`
> - 🔒 **Certificate Trust:** `generate-local-certs.sh`
> - 💻 **VS Code Connections:** `register-connections.sh`
> - 📊 **Reports & Metrics:** `generate-setup-report.sh` (JSON benchmarks and blueprint audit reports)

> 📊 **Detailed workflow diagrams and architectural invariants (idempotence, SQLcl fallback, Defender optimizations) are documented in: [docs/setup-all-workflow.md](../docs/setup-all-workflow.md)**

> [!IMPORTANT]
> **SQLcl Container Fallback Pattern (Rule 4):** Prior to execution, the script checks whether a local **SQLcl** binary exists (system `$PATH` or VS Code extension). If not found, it seamlessly falls back to the **SQLcl container image** (`SQLCL_CONTAINER_IMAGE`). This guarantees schema migrations and APEX imports succeed on clean machines without local Java/SQLcl.

**Syntax:**
```bash
./scripts/setup-all.sh [-b <0-11>] [-tb <0-11|LIST|all>] [-lb] [-sb <0-11>] [--search <QUERY>] [--dry-run] [-ltr] [-i] [--force | -y] [--no-publisher] [--no-ords] [--no-monitor-app]
```

**Options & Parameters:**
*   **`-b <N>` / `--blueprint <N>`:** Production and developer mode. Activates exactly **one** selected blueprint (0–11) and preserves existing database data (Idempotent / No-Reset).
*   **`-tb <LIST|all>` / `--test-blueprints`:** Automated CI/CD test mode. Automatically runs `reset-all.sh -y` before each test to guarantee clean baseline, testing a single blueprint, comma-separated list (`-tb 1,5,8`), or all blueprints (`-tb all`).
*   **`-lb` / `-l` / `--list-blueprints`:** Displays a dynamic ASCII overview table of all 12 supported blueprints without starting any services.
*   **`-sb <N>` / `--show-blueprint <N>`:** Displays detailed specifications for blueprint `<N>` (containers, ports, APEX/ORDS settings, RAM budget, and TLS requirements).
*   **`--search <QUERY>` / `--search-blueprints`:** Searches and filters blueprints by keyword (e.g. `publisher`, `ords`, `web-ide`, `remote`).
*   **`--dry-run`:** Simulates execution and validates configuration without performing actual setup (supports both `-b <N> --dry-run` and `-tb 1,3,7 --dry-run`).
*   **`-ltr` / `--list-test-reports`:** Displays status of all blueprint test reports in `tests/reports/blueprints/`.
*   **`-i` / `--select`:** Opens interactive selection menu in terminal with a 30s countdown timer.
*   **`--force` / `-y`:** Skips pre-installation confirmation and disk space checks (designed for automated CI/CD pipelines).
*   **`--no-publisher`:** Skips local Publisher database (`db-publisher`) startup to conserve RAM.
*   **`--from-snapshot`:** Restores database data volumes from a saved Golden Snapshot before startup (**instant start in ~30s**).
*   **`--build-image`:** Automatically saves database container state as a canonical pre-configured container image (`localhost/oracle-free-apex:<TAG>`).
*   **`--parallel`:** Enables parallel initialization of multi-DB setups and Publisher (requires $\ge$ 8 GB free RAM).
*   **`--sequential`:** Enforces strict sequential step-by-step installation (default safe mode).

**Example Commands:**
```bash
# 1. PRODUCTION & REGULAR DEVELOPMENT (Idempotent / Preserves Data):
./scripts/setup-all.sh -b 3             # Activate recommended 2-tier production blueprint
./scripts/setup-all.sh --blueprint 7    # Activate Full Enterprise 4-tier stack
./scripts/setup-all.sh -lb              # View blueprint matrix table
./scripts/setup-all.sh -sb 3            # View detailed container tree for Blueprint 3
./scripts/setup-all.sh --search pub     # Search blueprints matching 'pub'
./scripts/setup-all.sh -b 3 --dry-run   # Simulate launch without making changes

# 2. AUTOMATED TESTING & CI/CD (Clean state with automatic reset-all.sh -y):
./scripts/setup-all.sh -tb 3            # Test single blueprint from scratch
./scripts/setup-all.sh -tb 1,5,8        # Test sequence of selected blueprints
./scripts/setup-all.sh -tb all          # Test ALL 12 blueprints sequentially
./scripts/setup-all.sh -tb 1,3,7 --dry-run # Validate test matrix in seconds
./scripts/setup-all.sh -ltr             # Check blueprint test reports status

# 3. Interactive full installation:
./scripts/setup-all.sh
```

### 💡 Intelligent Software Package Buffering (`binaries/`)
The `setup-all.sh` script applies smart local caching for binary distributions:
1. **ORDS package (`binaries/ords/`):** Checks for local zip file (e.g. `ords-latest.zip`). If present, uses it directly; otherwise downloads from active YAML profile `PROFILE_ORDS_DOWNLOAD_URL`.
2. **APEX package (`binaries/apex/`):** Detects required APEX version from database profile. Checks `binaries/apex/` (e.g. `apex-latest.zip`, `apex_24.2.zip`). Uses local archive if present or downloads automatically.
3. Marker file `apex/.unzipped_source` ensures archive unpacking is triggered only when version changes.

### 🚀 Microsoft Defender & Endpoint Security Optimization
In corporate environments running strict endpoint inspection (e.g. Microsoft Defender), unpacking 50,000+ APEX files on the host disk causes severe I/O degradation:
* **Automatic Detection:** When running containerized databases (`oracle-db-apex-proxy`), APEX archives are never unpacked onto the host disk.
* **In-Container Execution:** Archives are transferred into the container as a single file and extracted in the container's isolated `/tmp/` volume.
* **Static Images Volume:** Static assets are populated directly into a named container volume (`apex_images` ➡️ `/opt/oracle/apex_images/images/`), bypassing host antivirus inspection entirely.

---

## 2. Container Startup (`start-containers.sh`)

The `./scripts/start-containers.sh` script starts existing local database and ORDS containers, monitoring health status until databases reach `healthy` state.

**Syntax:**
```bash
./scripts/start-containers.sh [--no-ords] [--no-publisher]
```

**Parameters:**
- `--no-ords`: Skips starting ORDS container (starts database containers only).
- `--no-publisher`: Skips starting Publisher database container.

**Example Commands:**
```bash
# Start all local containers:
./scripts/start-containers.sh

# Start databases only (without ORDS):
./scripts/start-containers.sh --no-ords
```

---

## 3. Environment & Component Reset (`reset-all.sh`)

The `./scripts/reset-all.sh` script is a **modular profile-aware teardown engine** that stops and removes containers, profiles (`config/profiles/*.yaml`), persistent volumes, and networks.

> 🏛️ **Profile-Aware Teardown Engine:**
> Incorporates `load-profile.sh` to ensure switching between profiles (e.g. 23c -> ADB 19c) automatically purges associated data volumes (`apex_proxy_oradata`, `apex_proxy_data`, `publisher_oradata`, `apex_images`), preventing volume cross-contamination and `ORA-65156` conflicts.

**Syntax:**
```bash
./scripts/reset-all.sh [component] [--profile <profile>] [--logs | -l] [--force | -y] [--system]
```

**Component Choices:**
- `all` (Default): Stops and removes all components (APEX Proxy, Publisher, ORDS) including volumes and networks.
- `db-apex-proxy`: Removes only the APEX Proxy database container and its persistent volume.
- `db-publisher`: Removes only the Publisher database container and its volume.
- `ords`: Removes only the local ORDS container.

**Flags:**
- `--logs` / `-l`: Cleans installation logs (`install_logs/*.log`), unzipped directories (`unzipped_log*`), and diagnostic bundles (`clean-logs.sh`).
- `--profile <name>`: Specifies exact profile name to tear down (defaults to `.env` `MAIN_DB_PROFILE`).
- `--force` / `-y`: Bypasses interactive confirmation (for automated CI/CD runners).
- `--system`: Performs full Podman system prune (prunes containers, images, and volumes to free disk space).

**Example Commands:**
```bash
# Complete reset of local development environment:
./scripts/reset-all.sh all

# Full reset including logs without prompt:
./scripts/reset-all.sh all --logs --force

# Reset specific profile:
./scripts/reset-all.sh all --profile proxy-adb-oracle --force
```

---

## 4. Golden Snapshots Management (`scripts/snapshots/`)

Provides fast cold backups and recovery (~15s) of database data volumes:

### 4.1. Creating Snapshots (`create-golden-snapshots.sh`)
```bash
# Standard base snapshot:
./scripts/snapshots/create-golden-snapshots.sh

# Named custom snapshot:
./scripts/snapshots/create-golden-snapshots.sh --name "crm-app"
```

### 4.2. Restoring Snapshots (`restore-golden-snapshots.sh`)
```bash
# Restore latest base snapshot:
./scripts/snapshots/restore-golden-snapshots.sh --force

# Restore named snapshot:
./scripts/snapshots/restore-golden-snapshots.sh --name "crm-app"
```

### 4.3. Cleaning Snapshots (`clean-golden-snapshots.sh`)
```bash
./scripts/snapshots/clean-golden-snapshots.sh
```

---

## 4.5. Log & Diagnostics Cleanup (`clean-logs.sh`)

Removes installation logs, temporary unzipped directories, and WebLogic diagnostic archives:

```bash
./scripts/clean-logs.sh [-y | --force]
```

### 4.5.1. Log Sanitization & Security (`sanitize-logs.sh`)
All script logs are automatically filtered through `scripts/internal/sanitize-logs.sh` to mask passwords and bearer tokens. For emergency troubleshooting, log masking can be bypassed with:
```bash
DEBUG_LOG_UNSANITIZED=true ./scripts/setup-all.sh
```

---

## 5. Developer & Administrator CLI Tools

### 5.1. SEPS Wallet Credential Reader (`get-password.sh`)
Extracts passwords securely in-memory from Oracle Wallet without storing plaintext on disk:
```bash
# Syntax:
./scripts/get-password.sh <ALIAS>

# Examples:
./scripts/get-password.sh DB_PROXY_DEV          # Proxy DB developer password
./scripts/get-password.sh DB_PROXY_APEX_ADMIN    # APEX INTERNAL admin password
./scripts/get-password.sh DB_PROXY_SYS           # Proxy DB SYS administrator password
```

### 5.2. Web Services HTTP Health Check (`check-urls.sh`)
Validates HTTP/HTTPS response codes (200/302) and TLS certificates across all active endpoints:
```bash
./scripts/check-urls.sh
```

### 5.3. SEPS Connection Diagnostics (`check-wallet.sh`)
Executes `SELECT status FROM v$instance` across all registered TNS aliases via SQLcl passwordless authentication:
```bash
./scripts/check-wallet.sh
```

### 5.4. Smart SQLcl CLI Wrapper (`sqlcl.sh`)
Connects to database instances instantly using SEPS Wallet aliases:
```bash
# Connect as developer:
./scripts/sqlcl.sh /@DB_PROXY_DEV

# Connect as SYSDBA:
./scripts/sqlcl.sh /@DB_PROXY_SYS as sysdba

# Execute SQL script:
./scripts/sqlcl.sh /@DB_PROXY_DEV @my_script.sql
```

### 5.5. Developer Account Provisioning (`create-developer.sh`)
Provisions developer users across database and APEX with random passwords registered in SEPS Wallet:
```bash
./scripts/create-developer.sh
```

### 5.6. VS Code Connections Synchronization (`register-connections.sh`)
Synchronizes connection tree and passwords with VS Code Oracle SQL Developer extension:
```bash
./scripts/register-connections.sh
```

---

## 6. Local Certificate Trust (`scripts/certs/`)

* 🍎 **macOS (0-Root):**
  * `./scripts/certs/trust-local-cert-mac.sh` (Installs into `login.keychain-db` without sudo)
  * `./scripts/certs/untrust-local-cert-mac.sh` (Removes certificate)
* 🪟 **Windows & WSL (0-Admin):**
  * `scripts\certs\trust-local-cert.cmd` (Double-clickable CMD script)
  * `scripts\certs\trust-local-cert.ps1` (PowerShell script)
  * `scripts\certs\untrust-local-cert.cmd` (Removes certificate)

---

## 7. Analytics Publisher Operations (`scripts/publisher/`)

* 📊 **Status check:** `./scripts/publisher/status-publisher.sh`
* 🔄 **Restart container:** `./scripts/publisher/restart-publisher.sh`
* 📦 **Catalog backup:** `./scripts/publisher/backup-publisher-catalog.sh`
* 🚀 **Deploy reports:** `./scripts/publisher/deploy-publisher-reports.sh`

---

## 8. Remote Deployment & Multi-Cloud Testing (`deploy-remote.sh`)

Deploys blueprints (e.g. Blueprint 10 ORDS Gateway or Blueprint 11 Publisher) to cloud VMs (Azure VM or OCI Compute):

```bash
./scripts/deploy-remote.sh \
  --host 20.123.45.67 \
  --user azureuser \
  --key ~/.ssh/id_rsa \
  --blueprint 10 \
  --wallet ~/Downloads/Wallet_FREEADB.zip
```

### Multi-Cloud Automated Testing (`tests/test-remote-multicloud.sh`)
```bash
./tests/test-remote-multicloud.sh \
  --azure-ip 20.123.45.67 \
  --oci-ip 130.61.12.34 \
  --db-alias DB_ADB_ADMIN
```

### Dev-Hub Browser Blueprints E2E Testing (`tests/test-devhub-browser-blueprints.sh`)
```bash
./tests/test-devhub-browser-blueprints.sh --all
```

---

## 9. Manual Patch Application (`scripts/internal/`)

* 🩹 **APEX Bundle Patch:** `./scripts/internal/apply-apex-patch.sh`
* 🩹 **Analytics Publisher OPatch:** `./scripts/internal/apply-publisher-patch.sh`

---

## 10. Internal Automation Engines (`scripts/internal/`)

Internal setup, profile, SQL, and orchestration engines reside in:
* 📁 **[`scripts/internal/README.md`](internal/README.md)**

---

## 11. Troubleshooting: Podman Machine Recovery Runbook

When experiencing Podman socket errors (`Get ".../containers/json": EOF`) or database container timeouts:

```bash
# 1. Restart Podman VM:
podman machine stop
podman machine start

# 2. Reset incomplete volumes:
./scripts/reset-all.sh --force

# 3. Clean reinstall:
./scripts/setup-all.sh --force
```
