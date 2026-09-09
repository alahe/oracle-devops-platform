# Platform Frequently Asked Questions (FAQ)

[ 🇬🇧 English ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/faq.md) | [ 🇪🇪 Eesti ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/et/faq.md) | [ 🇫🇮 Suomi ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/fi/faq.md) | [ 🇸🇪 Svenska ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/sv/faq.md) | [ 🇱🇻 Latviešu ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/lv/faq.md) | [ 🇱🇹 Lietuvių ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/lt/faq.md)

> Single Source of Truth (SSOT) covering architecture, zero-trust security, beginner onboarding, and troubleshooting.

---

**Jump to category:** [Beginner & Basics](#beginner) • [Architecture & Cloud](#architect) • [DBA & Security](#dba_security) • [Troubleshooting & Recovery](#troubleshooting)

---

<a id="beginner"></a>
## Beginner & Basics

<details class="faq-item" id="faq-ram-requirements" data-cat="beginner">
<summary class="faq-summary"><strong>🧠 What are the container RAM requirements (4–8 GB min)?</strong> <span class="faq-cat-tag">Beginner & Basics</span></summary>

<div class="faq-body">

**Answer:** Oracle 23ai Free requires at least 2.5 GB RAM to operate. If your Podman or Docker virtual machine is allocated less than 4 GB, the database container will terminate unexpectedly (OOM Killer / exit code 137). For multi-container blueprints (Proxy + Business DB + ORDS + Forms), allocate at least 8 GB RAM.

**Helpful Commands:**
```bash
# Check and increase Podman VM memory (macOS / Windows WSL2):
podman machine stop
podman machine set --memory 8192 --cpus 4
podman machine start
```

**Related Documentation & Scripts:** [docs/prerequisites.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/prerequisites.md), [scripts/check-prerequisites.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/check-prerequisites.sh)

</div>
</details>

<details class="faq-item" id="faq-ssl-warning" data-cat="beginner">
<summary class="faq-summary"><strong>🔒 How to handle the browser "Connection is not private" SSL warning?</strong> <span class="faq-cat-tag">Beginner & Basics</span></summary>

<div class="faq-body">

**Answer:** Local HTTPS (https://localhost:8448) uses a self-signed root certificate generated automatically for your machine. You can click 'Advanced' -> 'Proceed to localhost' in your browser, or install the certificate once into your OS trust store using the provided zero-admin scripts.

**Helpful Commands:**
```bash
# macOS Keychain trust:
./scripts/certs/trust-local-cert-mac.sh
# Windows CurrentUser trust (Zero-UAC):
./scripts/certs/trust-local-cert.cmd
```

**Related Documentation & Scripts:** [docs/ssl-certificates.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/ssl-certificates.md), [scripts/certs/trust-local-cert-mac.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/certs/trust-local-cert-mac.sh)

</div>
</details>

<details class="faq-item" id="faq-stop-restart" data-cat="beginner">
<summary class="faq-summary"><strong>🌙 How to pause and resume the environment at the end of the day?</strong> <span class="faq-cat-tag">Beginner & Basics</span></summary>

<div class="faq-body">

**Answer:** At the end of your workday, stop containers to free up your computer's RAM and CPU without losing any data. In the morning, restart the containers in seconds without re-running setup.

**Helpful Commands:**
```bash
# Stop containers without data loss:
./scripts/reset-all.sh
# Resume existing containers in seconds:
./scripts/start-containers.sh
```

**Related Documentation & Scripts:** [docs/quick-login-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/quick-login-guide.md), [scripts/start-containers.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/start-containers.sh), [scripts/reset-all.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/reset-all.sh)

</div>
</details>

<details class="faq-item" id="faq-vscode-connection" data-cat="beginner">
<summary class="faq-summary"><strong>💻 How do I connect to databases using VS Code Oracle SQL Developer?</strong> <span class="faq-cat-tag">Beginner & Basics</span></summary>

<div class="faq-body">

**Answer:** The platform includes an automated registration script that writes database connections directly into VS Code's extension storage (`dbtools-connections.json`) and securely stores passwords in your OS Keychain (macOS / Windows Credential Manager). Run register-connections.sh and reload VS Code to see your ready-to-use connections tree.

**Helpful Commands:**
```bash
# Register connections automatically into VS Code:
./scripts/register-connections.sh
# Test connection via CLI:
./scripts/sqlcl.sh /@DB_PROXY_DEV
```

**Related Documentation & Scripts:** [docs/vscode-oracle-developer-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/vscode-oracle-developer-guide.md), [scripts/register-connections.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/register-connections.sh)

</div>
</details>

<a id="architect"></a>
## Architecture & Cloud

<details class="faq-item" id="faq-apex-vs-raw-code" data-cat="architect">
<summary class="faq-summary"><strong>🚀 Why choose APEX & declarative blueprints instead of AI-generated raw code (React/Node)?</strong> <span class="faq-cat-tag">Architecture & Cloud</span></summary>

<div class="faq-body">

**Answer:** Generating 10,000+ lines of imperative React/Node glue code creates massive long-term maintenance debt — your team must audit, debug, patch, and maintain every single line. In APEX, declarative blueprints (APEXlang DSL) define business logic, while built-in, certified database engines handle CSRF/XSS protection, session state, responsive rendering, and zero-latency SQL execution out of the box.

**Helpful Commands:**
```bash
# Compile human-readable APEXlang DSL (.apx) into APEX application:
./scripts/sqlcl.sh /@DB_PROXY_DEV @apex/app_100.apx
```

**Related Documentation & Scripts:** [docs/architecture-overview.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/architecture-overview.md), [docs/apex-devhub-test-plan.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/apex-devhub-test-plan.md)

</div>
</details>

<details class="faq-item" id="faq-free-db-limits" data-cat="architect">
<summary class="faq-summary"><strong>💾 Are Oracle Free DB limits (2 GB RAM / 12 GB user data) sufficient for enterprise dev?</strong> <span class="faq-cat-tag">Architecture & Cloud</span></summary>

<div class="faq-body">

**Answer:** Yes, absolutely. By decoupling the lightweight presentation layer (Proxy DB) from the business database, and utilizing zero-footprint REST streaming (AutoREST / ORDS), the local database stores only realistic development test subsets. When workloads scale to production, code deploys seamlessly to Oracle Autonomous Database (ADB) in OCI without refactoring.

**Helpful Commands:**
```bash
# Hybrid deployment blueprint test:
./scripts/setup-all.sh --blueprint 10  # BP 10: Hybrid Cloud ADB
```

**Related Documentation & Scripts:** [docs/blueprints-overview.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/blueprints-overview.md), [docs/remote-multicloud-setup-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/remote-multicloud-setup-guide.md)

</div>
</details>

<details class="faq-item" id="faq-version-control-cicd" data-cat="architect">
<summary class="faq-summary"><strong>📜 How are version control, Liquibase changelogs, and zero-trust CI/CD verified?</strong> <span class="faq-cat-tag">Architecture & Cloud</span></summary>

<div class="faq-body">

**Answer:** The platform enforces Git-first workflows using official SQLcl split exports, declarative Liquibase changelogs (`controller.xml`), and APEXlang AST validations. Secrets are never checked into Git; pipelines connect using passwordless Oracle SEPS wallets or ephemeral containers, simulating offline CI/CD without cloud dependencies.

**Helpful Commands:**
```bash
# Run offline local CI pipeline simulation:
./scripts/test-local-ci.sh
```

**Related Documentation & Scripts:** [docs/sqlcl-liquibase-guide.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/sqlcl-liquibase-guide.md), [scripts/test-local-ci.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/test-local-ci.sh)

</div>
</details>

<a id="dba_security"></a>
## DBA & Security

<details class="faq-item" id="faq-wallet-passwords" data-cat="dba_security">
<summary class="faq-summary"><strong>🔐 Where are passwords stored? (SEPS Wallet vs plaintext files)</strong> <span class="faq-cat-tag">DBA & Security</span></summary>

<div class="faq-body">

**Answer:** In accordance with strict Zero-Trust rules (Rule 5), passwords are NEVER written to the disk in plaintext files (.txt, .json, .env). All credentials reside encrypted inside the Oracle SEPS Auto-Login Wallet (cwallet.sso / ewallet.p12 with AES-256). Passwords are only decrypted in-memory on demand via get-password.sh.

**Helpful Commands:**
```bash
# View password in terminal or copy directly to clipboard (-c):
./scripts/get-password.sh DB_PROXY_DEV
./scripts/get-password.sh DB_PROXY_DEV -c
# Connect passwordlessly via SEPS Wallet alias:
./scripts/sqlcl.sh /@DB_PROXY_DEV
```

**Related Documentation & Scripts:** [docs/wallet-management.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/wallet-management.md), [scripts/get-password.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/get-password.sh), [scripts/check-wallet.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/check-wallet.sh)

</div>
</details>

<details class="faq-item" id="faq-enterprise-proxy-artifactory" data-cat="dba_security">
<summary class="faq-summary"><strong>🏢 Can this platform run behind corporate TLS-inspecting proxies and private Artifactory?</strong> <span class="faq-cat-tag">DBA & Security</span></summary>

<div class="faq-body">

**Answer:** Yes. The platform follows Rule 4 (Ephemeral Container Fallback) and Enterprise Standards. All container image references are configurable via YAML profiles or environment variables (e.g., pointing to internal Artifactory or Harbor mirrors), corporate CA bundles are automatically injected into WSL2 and containers, and HTTP_PROXY/HTTPS_PROXY settings are respected.

**Helpful Commands:**
```bash
# Inspect corporate proxy and Artifactory compatibility:
./scripts/onboard-enterprise.sh --status
# Run non-destructive enterprise pre-flight checks:
./scripts/test-windows-dryrun.sh
```

**Related Documentation & Scripts:** [docs/enterprise-artifactory-and-proxy.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/enterprise-artifactory-and-proxy.md), [scripts/onboard-enterprise.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/onboard-enterprise.sh)

</div>
</details>

<a id="troubleshooting"></a>
## Troubleshooting & Recovery

<details class="faq-item" id="faq-port-conflicts" data-cat="troubleshooting">
<summary class="faq-summary"><strong>🔌 How to resolve port conflicts (8448, 1521, 8080 already in use)?</strong> <span class="faq-cat-tag">Troubleshooting & Recovery</span></summary>

<div class="faq-body">

**Answer:** If your terminal outputs `bind: address already in use`, another web server, container, or local Oracle listener is bound to that port. Identify and terminate the conflicting process or remap the host port cleanly in your `.env` file without modifying any script code.

**Helpful Commands:**
```bash
# Identify conflicting process on port:
lsof -i :8448   # macOS/Linux
# Change port dynamically in .env:
HOST_HTTPS_PORT=8449
HOST_DB_PORT=1522
```

**Related Documentation & Scripts:** [docs/port-matrix-and-firewall.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/port-matrix-and-firewall.md), [scripts/check-urls.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/check-urls.sh)

</div>
</details>

<details class="faq-item" id="faq-golden-snapshots" data-cat="troubleshooting">
<summary class="faq-summary"><strong>⚡ How does Golden Snapshot recovery work in ~15 seconds without reinstalling?</strong> <span class="faq-cat-tag">Troubleshooting & Recovery</span></summary>

<div class="faq-body">

**Answer:** A Golden Snapshot captures the fully configured database files, metadata, and schemas right after setup completes. Instead of running a fresh 12-minute installation, the restore script stops the container, cleanly restores the verified snapshot files, and brings the database back online in about 15 seconds.

**Helpful Commands:**
```bash
# Restore clean initial state of active blueprint in ~15s:
./scripts/snapshots/restore-golden-snapshots.sh
# Create golden snapshot manually:
./scripts/snapshots/create-golden-snapshots.sh
```

**Related Documentation & Scripts:** [docs/golden-snapshots.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/golden-snapshots.md), [scripts/snapshots/restore-golden-snapshots.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/snapshots/restore-golden-snapshots.sh)

</div>
</details>

<details class="faq-item" id="faq-windows-wsl2-filesystem" data-cat="troubleshooting">
<summary class="faq-summary"><strong>🪟 Why must the repository be cloned in WSL2 ext4 and never under /mnt/c/?</strong> <span class="faq-cat-tag">Troubleshooting & Recovery</span></summary>

<div class="faq-body">

**Answer:** In accordance with Rule 14, execution from the Windows host mount (`/mnt/c/...`) is strictly prohibited. Plan9 (9P) translation between Linux and NTFS causes severe I/O slowdowns (10x–50x slower) and strips POSIX file permissions, breaking SEPS Wallet security (`chmod 0600` failure). Always clone inside `~/oracle-free-db-in-prod`.

**Helpful Commands:**
```bash
# Clone inside native WSL2 Linux filesystem:
cd ~
git clone https://github.com/allanlahe/oracle-free-db-in-prod.git
cd oracle-free-db-in-prod
```

**Related Documentation & Scripts:** [docs/windows-wsl2-enterprise-setup.md](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/windows-wsl2-enterprise-setup.md), [scripts/check-prerequisites.sh](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/check-prerequisites.sh)

</div>
</details>

