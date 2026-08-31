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
   - **`scripts/patches/`:** Manual patch application utilities (`apply-apex-patch.sh`, `apply-publisher-patch.sh`).

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

## 5. Oracle Wallet Mandatory Credential Store Rule

All scripts, automated tests (e.g. `test-browser-login.sh`), CLI utilities, and tools must ALWAYS prioritize **Oracle Wallet (SEPS)** for credentials:

1. **Retrieve Credentials from Wallet:**
   - Passwords and connection properties must be queried via: `./scripts/get-password.sh <alias>` (compatibility: `./scripts/internal/view-wallet-credential.sh <alias>`).
   - **All Wallet aliases are dynamically loaded from YAML profiles (`config/profiles/*.yaml`).** No hardcoded Wallet aliases (e.g., `DB_APEX_PROXY_SYS`) or usernames are allowed in code.
2. **Prevent Hardcoding & `ps aux` Leaks:** Credentials must never be written to files in plaintext or exposed as process command-line arguments.

---

## 6. SQLcl & VS Code CLI Stability Contract Rule

All scripts, wrappers, and connection generators must adhere to **5 stability contracts**:

1. **Prioritize Latest VS Code SQLcl (Binary Resolution Order):** Always prefer the latest SQLcl embedded in the VS Code extension (`find "$HOME/.vscode/extensions" ... | sort -rV | head -n 1`) before falling back to system `$PATH`.
2. **Environment Sanitization (`unset JAVA_HOME` & Clean `JAVA_TOOL_OPTIONS`):** Always run `unset JAVA_HOME` before invoking SQLcl to prevent Java 11/17 conflicts with Java 21+. `JAVA_TOOL_OPTIONS` must only contain `-Doracle.net.tns_admin=$TNS_DIR` without duplicate wallet flags.
3. **Binary Password Fallback:** If `mkstore` returns binary/corrupted characters (`[[ "$PWD_VAL" == *"?"* ]]`), query the credential directly from the Podman secret store.
4. **POSIX & Shell Compatibility:** Do not use non-portable bashisms (like `${ALIAS,,}` or `declare -A`) that fail under `/bin/bash` 3.2 on macOS or `/bin/sh` / `zsh`. Use portable `tr '[:upper:]' '[:lower:]'` and standard arrays.
5. **Multi-Shell Registration:** Auto-export `TNS_ADMIN` and alias `sql` across all shell profiles (`~/.zshrc`, `~/.zshenv`, `~/.bashrc`, `~/.bash_profile`) and maintain the wrapper at `~/Applications/sqlcl/bin/sql`.

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
