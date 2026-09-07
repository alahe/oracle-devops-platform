# Workspace Rules for Oracle Free DB in Prod

## 1. Automatic Step Timing & Logging Rule

Whenever a NEW installation, configuration, or restore step is added to the project scripts (`scripts/*.sh` or `scripts/setup-all.sh`):

1. **Duration Measurement & Git Benchmarks (`metrics/`):**
   - Step start and completion timestamps must be measured with second precision (`format_duration`).
   - Results must be persisted into `metrics/setup_benchmarks.json` (JSON) and `metrics/setup_benchmarks.env` (ENV key-value format).
   - The `metrics/` directory must be version-controlled (Git tracked).

2. **Full Local Logging (`install_logs/`):**
   - Complete execution logs (stdout and stderr) must be automatically tee-logged into a timestamped file under `install_logs/` (e.g., `install_logs/setup_step_YYYYMMDD_HHMMSS.log`).
   - The `install_logs/` directory is in `.gitignore` and remains strictly local-only.

---

## 2. Mandatory Documentation Maintenance Rule

Whenever new functionality is added, configurations are modified, or new scripts/containers/parameters are created:

1. **Mandatory Documentation Synchronization:**
   - Corresponding documentation files (primarily `README.md`, and if relevant `docs/*.md`, `patches/README.md`, or `connections/README.md`) MUST BE UPDATED IMMEDIATELY.
   - New functionality usage guides, execution commands, parameters, and expected outcomes must be clearly documented.

2. **Code & Documentation Consistency:**
   - Documentation must contain no outdated or missing commands.
   - Every modification in code or scripts must be reflected in the relevant documentation within the same workflow cycle.

---

## 3. Directory Layout Rule for Scripts

To maintain a clean and professionally structured repository, a **modular 3-tier script layout** is enforced:

1. **User CLI & Daily Developer Tools (`scripts/` root):**
   - **Environment Lifecycle Commands:** `setup-all.sh`, `reset-all.sh`, `start-containers.sh`, `sqlcl.sh`, `deploy-remote.sh`, `test-local-ci.sh`.
   - **Developer Tools:** `get-password.sh` (SEPS Wallet credential reader), `check-urls.sh` (web endpoints diagnostics), `check-wallet.sh` (SEPS connection diagnostics), `create-developer.sh` (developer user provisioning/recovery), `register-connections.sh` (VS Code connections registry), `clean-logs.sh`.

2. **Modular Feature Folders:**
   - **`scripts/snapshots/`:** Golden Snapshot management (`create-golden-snapshots.sh`, `restore-golden-snapshots.sh`, `clean-golden-snapshots.sh`).
   - **`scripts/certs/`:** OS-specific certificate trust tools (`trust-local-cert-mac.sh`, `trust-local-cert.cmd`, `trust-local-cert.ps1`, etc.).
   - **`scripts/publisher/`:** Analytics Publisher operations (`status-publisher.sh`, `restart-publisher.sh`, `backup-publisher-catalog.sh`, `deploy-publisher-reports.sh`).

3. **Internal Automation & Engines (`scripts/internal/`):**
   - All internal helper scripts and SQL initializers reside under `scripts/internal/`:
     - Shared engines: `common.sh`, `load-profile.sh`, `resolve-topology.sh`, `i18n.sh`
     - Generators: `generate-compose-override.sh`, `generate-local-certs.sh`, `generate-passwords.sh`, `create-wallet.sh`
     - Initialization: `wait-db-healthy.sh`, `init-db-instance.sh`, `init-db-instance.sql`, `apply-profile-users.sh`
     - Installers: `install-apex.sh`, `install-publisher.sh`, `install-ords-standalone.sh`, `install-forms.sh`

4. **Backward Compatibility & Relative Paths:**
   - Whenever scripts are relocated, backward compatibility is guaranteed via symlinks or wrappers in `scripts/internal/`, and relative path resolution (`SCRIPT_DIR`, `WORKSPACE_DIR`) must be verified.

---

## 4. Ephemeral Container Fallback Pattern for Restricted Environments

When local tooling restrictions (Java, SQLcl, Liquibase) occur in enterprise or zero-trust environments, always prefer and support the **ephemeral container fallback pattern**:

1. **Configurable Container Images:** All container image references must be overridable via `.env` or YAML profiles (e.g., `SQLCL_CONTAINER_IMAGE`) to allow enterprise Artifactory mirrors.
2. **Execute with `--rm`:** Ephemeral containers performing one-off operations (backups, schema migrations, APEX application exports/imports) must run with `--rm`. This guarantees automatic memory buffer cleanup and credential destruction upon exit.
   - **WSL & Ghost Process Prevention:** Isolates PID 1 processes and prevents orphaned background Java processes during VPN/terminal disconnects.
3. **Unified CLI Wrappers:** Scripts must encapsulate local CLI tools and container execution behind unified functions (e.g., `run_sqlcl`), working seamlessly on both unrestricted developer machines and locked-down corporate hosts.
4. **Anti-Virus & Microsoft Defender Optimization (In-Container Unzip & Execution):**
   - Large archives (APEX, ORDS, Publisher containing 50,000+ files) **MUST NOT be unpacked onto the host disk**. Real-time endpoint inspection causes extreme I/O slowdowns.
   - Archives are transferred as a single file (`podman cp`) or official OCR prebuilt images (`container-registry.oracle.com/database/ords:latest`) are used, with unpacking performed inside the container filesystem (`/tmp`).

---

## 5. Oracle Wallet Mandatory Credential Store Rule & Zero-Trust Architecture

All scripts, automated tests (e.g. `test-browser-login.sh`), CLI utilities, Dev Hub (`docs/dev-hub.html`), and 1-click clipboard helpers must ALWAYS prioritize **Oracle Wallet (SEPS)** for credentials and strictly adhere to **Zero-Trust Principles**:

1. **Retrieve Credentials Strictly from Wallet (Just-In-Time In-Memory):**
   - Passwords and connection properties must be queried dynamically via: `./scripts/get-password.sh <alias>` (compatibility: `./scripts/internal/view-wallet-credential.sh <alias>`).
   - **All Wallet aliases are dynamically loaded from YAML profiles (`config/profiles/*.yaml`).** No hardcoded Wallet aliases (e.g., `DB_APEX_PROXY_SYS`) or usernames are allowed in code.
2. **Strict Prohibition on Plaintext Files & Caches on Disk (Zero-Trust):**
   - **Credentials must NEVER be written to the filesystem in plaintext** (no `.json`, `.txt`, `.env`, or `.cache` files), regardless of file permissions (`chmod 0600` is NOT an exemption).
   - **Encryption at Rest (Mandatory):** Secrets must reside strictly in encrypted form inside the Oracle SEPS Auto-Login Wallet (`cwallet.sso` / `ewallet.p12` with AES-256) or Podman encrypted secret store.
   - **In-Memory JIT Decryption Only:** Passwords may only be decrypted dynamically in-memory at runtime directly from `cwallet.sso` / `mkstore` and destroyed immediately after process execution.
3. **Strict Wallet-Only Synchronization for Web Hub & Tools:**
   - Dev Hub (`docs/dev-hub.html`) and 1-click clipboard helpers MUST ALWAYS use genuine credentials extracted directly in-memory from Oracle Wallet (`create-wallet.sh` / `get-password.sh` / `cwallet.sso` / `ewallet.p12`).
   - **Prohibition on Synthetic / Hash Passwords:** Never generate synthetic or SHA-hashed fallback passwords (`Ora_...`) that do not match the database. Every credential must be verified from the SEPS Wallet.

---

## 6. SQLcl & VS Code CLI Stability Contract Rule

All scripts, wrappers, and connection generators must adhere to **6 stability contracts**:

1. **Prioritize Latest VS Code SQLcl (Binary Resolution Order):** Always prefer the latest SQLcl embedded in the VS Code extension (`find "$HOME/.vscode/extensions" ... | sort -rV | head -n 1`) before falling back to system `$PATH`.
2. **Environment Sanitization (`unset JAVA_HOME` & Clean `JAVA_TOOL_OPTIONS`):** Always run `unset JAVA_HOME` before invoking SQLcl to prevent Java 11/17 conflicts with Java 21+. `JAVA_TOOL_OPTIONS` must only contain `-Doracle.net.tns_admin=$TNS_DIR` without duplicate wallet flags.
3. **Binary Password Fallback:** If `mkstore` returns binary/corrupted characters (`[[ "$PWD_VAL" == *"?"* ]]`), query the credential directly from the Podman secret store.
4. **POSIX & Shell Compatibility:** Do not use non-portable bashisms (like `${ALIAS,,}` or `declare -A`) that fail under `/bin/bash` 3.2 on macOS or `/bin/sh` / `zsh`. Use portable `tr '[:upper:]' '[:lower:]'` and standard arrays.
5. **Multi-Shell Registration:** Auto-export `TNS_ADMIN` and alias `sql` across all shell profiles (`~/.zshrc`, `~/.zshenv`, `~/.bashrc`, `~/.bash_profile`) and maintain the wrapper at `~/Applications/sqlcl/bin/sql`.
6. **Exclusive SQLcl Usage Contract (Strict Prohibition of Legacy SQL*Plus):** SQLcl (`sql`) is the mandatory standard database CLI across all platform automation scripts (`apply-profile-users.sh`, `create-developer.sh`, `init-db-instance.sh`), user provisioning, schema migrations, and CI/CD pipelines. Legacy `sqlplus` is prohibited in automation scripts. In containerized databases, invoke the embedded SQLcl binary at `/opt/oracle/product/*/dbhomeFree/sqlcl/bin/sql -s / as sysdba`. For host and cloud ADB execution, invoke via `./scripts/sqlcl.sh /@ALIAS` or ephemeral container (`container-registry.oracle.com/database/sqlcl:latest`), leveraging Oracle SEPS auto-login wallet.

---

## 7. Standardized Terminal UX, Live Timer & Credential Helper Rule

All installation, management, and test scripts must follow a **standardized terminal UX**:

1. **Live Timer on Long-Running Steps:** Any operation taking longer than a few seconds (APEX install, patching, image pulling, health checks) must provide a real-time updating seconds timer (`run_with_live_timer` or `print_step_progress`).
2. **Standardized Completion Summary:**
   - **Web Services Table:** Distinct target URLs and authentication hints (APEX Builder, APEX Instance Admin, Database Actions, Analytics Publisher, Forms Runtime, Web IDE).
   - **VS Code Connections Tree:** Hierarchical ASCII tree diagram of folders and TNS aliases.
   - **Credential Helper Hint:** Clear `./scripts/get-password.sh <ALIAS>` cheat-sheet.
   - **Total Duration at End:** Total elapsed time displayed in the final block.
   - **Log File Links:** Full details directed to clickable `install_logs/` files.

---

## 8. Dynamic Database Profiles & Multi-DB SEPS Wallet Rule

1. **Zero Hardcoded Names:** Database names (e.g., `proxy`, `lis`, `publisher`), ports, and ORDS pools must never be hardcoded. All values are dynamically resolved from `.env` and YAML profiles (`config/profiles/databases/*.yaml`).
2. **System Accounts in Wallet:** For each database instance, dedicated system aliases are generated automatically:
   - `${DB_PREFIX}_APEX_ADMIN` (APEX `INTERNAL` Workspace administrator password for web)
   - `${DB_PREFIX}_APEX_PUBLIC_USER` / `${DB_PREFIX}_APEX_LISTENER`
   - `${DB_PREFIX}_ORDS_PUBLIC_USER`

---

## 9. Dual- & Multi-Language (EN / ET / FI / SV / LV / LT) Documentation & i18n Synchronization Rule

The platform supports **6 languages (Nordic-Baltic region: 🇬🇧 EN, 🇪🇪 ET, 🇫🇮 FI, 🇸🇪 SV, 🇱🇻 LV, 🇱🇹 LT)**, where **English (EN) is the primary canonical source of truth**, with Estonian (ET), Finnish (FI), Swedish (SV), Latvian (LV), and Lithuanian (LT) as localized convenience layers.

1. **Automatic Documentation Synchronization:**
   - Whenever repository documentation (`README.md`, `docs/*.md`, `config/blueprints/README.md`) is created or modified:
     - Primary documentation is authored in professional technical English.
     - Localized mirrors must be updated in the same cycle: Estonian (`docs/et/*.md`, `config/blueprints/README.et.md`), Finnish (`docs/fi/*.md`, `config/blueprints/README.fi.md`), Swedish (`docs/sv/`), Latvian (`docs/lv/`), and Lithuanian (`docs/lt/`).
     - Every document header must include the language switcher:
       `[ 🇬🇧 English ](...) | [ 🇪🇪 Eesti ](...) | [ 🇫🇮 Suomi ](...) | [ 🇸🇪 Svenska ](...) | [ 🇱🇻 Latviešu ](...) | [ 🇱🇹 Lietuvių ](...)`.

2. **Central Localization Engine (`scripts/internal/i18n.sh`):**
   - Script banners, notifications, service tables, and summaries use `msg_print "KEY" [arg...]` or `msg_str "KEY" [arg...]`.
   - Every newly introduced message key MUST have translations for all 6 languages (`en_*`, `et_*`, `fi_*`, `sv_*`, `lv_*`, `lt_*`).
   - 3-tier fallback guarantee: `Selected Language` $\rightarrow$ `English (en_*)` $\rightarrow$ `Raw Key`.

3. **Machine-Readability Invariants:**
   - Benchmarks (`metrics/setup_benchmarks.json`, `metrics/setup_benchmarks.env`) and log filenames (`install_logs/`) REMAIN 100% IN CANONICAL ENGLISH.
   - Oracle technical errors (`ORA-*`, `PLS-*`, `SP2-*`, HTTP status codes) are always preserved in original format.

4. **Autonomous Execution:**
   - Translation and synchronization must be performed autonomously without requiring separate user reminders.

---

## 10. Mermaid Visual Design & Multi-Line Decision Formatting Rule

Whenever creating or updating Mermaid diagrams (flowcharts, sequence diagrams, state machines, and architecture blueprints in documentation or Dev Hub):

1. **Multi-Line Decision Nodes (Diamonds `{...}`):**
   - Text inside decision diamonds (`{...}`) **MUST NEVER be written as a single long line**.
   - Always break questions/conditions into 2–4 concise lines using HTML `<br/>` tags (e.g., `{1. Kas lokaalne<br/>snapshot olemas<br/>ja versioon klapib?}`).
   - This prevents disproportionately wide, stretched diamond shapes that ruin layout readability.

2. **Compact & Balanced Node Proportions:**
   - Keep all process blocks (`[...]`, `(...)`, `[(...)]`) balanced with max 25–35 characters per line, breaking longer sentences across multiple lines with `<br/>`.

3. **High-Contrast Semantic Flow:**
   - Ensure explicit branch labels on connectors (e.g., `-->|JAH / Kehtiv|` and `-->|EI / Puudub|`).
   - Group related components into clean, labeled `subgraph` blocks.

---

## 11. Clean Blueprint & YAML Profile Single Source of Truth Rule

To guarantee total separation of architecture concerns and zero hardcoding:

1. **Ultra-Clean Blueprints (`config/blueprints/.env.*`):**
   - Blueprints only declare high-level positive profile references for services and databases that are actually needed (`DB_ALISE=db-alise-oracle`, `ORDS_PROFILE=ords-standard`, `FORMS_PROFILE=forms-standard`, `PUBLISHER_PROFILE=publisher-standard`, `WEB_IDE_PROFILE=web-ide-standard`, `PUBLISHER_DESIGNER_PROFILE=publisher-designer-standard`).
   - **Strict Prohibition of `SKIP_*` and Redundant Negative Declarations:** Blueprints and `.env` files **MUST NEVER** contain negative `SKIP_*` variables (e.g. `SKIP_ORDS`, `SKIP_PUBLISHER`, `SKIP_FORMS`, `SKIP_WEB_IDE`). Furthermore, declaring `MAIN_DB_PROFILE=NONE` is **not required**: if no database profile is declared in the blueprint, the orchestration engine automatically detects a 0-database environment (`DB_ENABLED=false`).
   - Blueprints **MUST NEVER** contain low-level database details, port numbers, usernames, roles, or container configurations.

2. **Domain Encapsulation in YAML Profiles (`config/profiles/**/*.yaml`):**
   - 100% of domain specifics, database ports, default services (PDBs), container images, memory limits, tablespaces, quotas, and user definitions reside exclusively in YAML profiles (`config/profiles/databases/*.yaml`, `config/profiles/web-ide/*.yaml`, `config/profiles/publisher/*.yaml`).
   - All users, roles, and wallet aliases are declared in YAML.
   - Built-in `SYS` superuser is automatically managed by the engine without cluttering YAML `users:` arrays.

3. **Multi-Instance Prefix Disambiguation:**
   - When multiple databases share the same profile, the orchestration engine automatically isolates namespaces and wallet aliases using the formula: `DB_${INSTANCE_PREFIX}_${ALIAS_SUFFIX}`.

4. **Zero Hardcoded Configuration in Code:**
   - No database names, ports, PDB services, or usernames may be hardcoded into shell scripts or SQL files.
   - If changes are needed in the future, administrators update the YAML profile or blueprint—never the shell scripts!

5. **Profile-Driven Zero-Database Invariant & Just-In-Time (JIT) Custom Images:**
   - When a blueprint only declares standalone application profiles without any database profiles (e.g., BP 8 Web-IDE or BP 9 Publisher Designer), `get_active_db_instances` returns an empty list, database healthchecks and APEX installations are cleanly skipped (`STATUS_SKIPPED`), and no default database (`db-oracle`) is ever fabricated.
   - Custom images built from local Dockerfiles (`build_local: true` in YAML profile, e.g. `docker/publisher-designer` or `docker/web-ide`) must declare `build: { context: ... }` in `podman-compose.yml` and be checked during orchestration to ensure automatic Just-In-Time compilation if not already present in the local container store.

---

## 12. Asynchronous Long-Running Task & Lifecycle State Contract Rule

To eliminate false browser timeouts, UI freezes, and premature "active" indicators during container installations and cold database builds:

1. **Mandatory Asynchronous Background Task Dispatch:**
   - Any operation requiring more than 10 seconds (e.g. `setup-all.sh`, `deploy-blueprint.sh`, full rebuilds, deep resets, container orchestration) **MUST NEVER** be executed as a synchronous blocking HTTP request with a browser-side timeout (e.g. 300s AbortController).
   - In Dev-Hub and bridge architectures, long-running operations must be dispatched as asynchronous background tasks (`ACTIVE_TASKS` via `subprocess.Popen`) returning an immediate acknowledgement (`task_id`, `pid`, `log_file`).
   - The UI client must track progress by polling `/api/task/status?task=<name>` and stream live logs. It must keep terminal progress active until the backend explicitly returns `completed` (exit code 0) or `failed` (exit code $\neq 0$).

2. **Delayed Active Blueprint Confirmation & Lifecycle Lock:**
   - `.active_blueprint` **MUST NOT** be written at the beginning of `setup-all.sh` or before container health is verified. It is strictly persisted only after 100% of PDB initializations, SEPS Wallet tests, and URL health checks succeed.
   - While setup is running, a lifecycle indicator (`.setup_in_progress`) must declare the ongoing task and blueprint ID, and automatically be cleaned up via `trap` upon script termination.

3. **Multi-Tiered Service Health Reporting:**
   - Container presence in `podman ps` does NOT equal service readiness.
   - The UI and status API must distinguish between:
     - 🔴 **Offline (`status-offline`)**: Container not running.
     - ⏳ **Installing (`status-installing`)**: Setup or rebuild actively executing.
     - 🟡 **Starting / Initializing (`status-init`)**: Container running but container healthcheck is `starting` or database initializations are pending.
     - 🟢 **Online / Healthy (`status-online`)**: Database healthy, SEPS Wallet connected, and web endpoints responsive.
