[ 🇬🇧 English ](future-plans.md) | [ 🇪🇪 Eesti ](et/future-plans.md) | [ 🇫🇮 Suomi ](fi/future-plans.md) | [ 🇸🇪 Svenska ](sv/future-plans.md) | [ 🇱🇻 Latviešu ](lv/future-plans.md) | [ 🇱🇹 Lietuvių ](lt/future-plans.md)

# 🛡️ Development Environment Expansion & Security Roadmap (Future Plans)

> [!NOTE]
> **Future planning has been reorganized into a modular Backlog system:**
> All discrete tasks, architectural blueprints, and lifecycle tracking reside under **[`backlog/`](../backlog/README.md)**:
> - 🟢 **Completed tasks:** [`backlog/done/`](../backlog/done/)
> - 🟡 **Pending / Proposed tasks:** [`backlog/todo/`](../backlog/todo/)
> - 📄 **Task template:** [`backlog/template.md`](../backlog/template.md)

This document consolidates the **implementation audit (Status Verification)** of the platform, the comprehensive catalog of realized features, and the roadmap for remaining security hardening and enterprise production requirements.

---

## 📊 SUMMARY STATUS MATRIX

| ID | Capability / Feature Area | Realized Status | Implementation Notes |
|---|---|---|---|
| **1.1** | Containerized Web IDE (`code-server`) | **✅ COMPLETED** | `web-ide` container, OpenJDK 21, SQLcl, VS Code extensions |
| **1.2** | GitHub Actions & Offline `act` CI/CD | **✅ COMPLETED** | `scripts/test-local-ci.sh`, `.dbtools/project.config.json` |
| **1.3** | Analytics Publisher (Pixel Perfect) Deployment | **✅ COMPLETED** | `oracle/analyticsserver:2025`, HTTP 200 OK verified |
| **1.4** | VS Code SQL Developer Automated Connection Registry | **✅ COMPLETED** | `register-connections.sh`, folders `/APEX`, `/Publisher`, `/MYATP` |
| **1.5** | Cross-Platform SSL Root Certificate Trust | **✅ COMPLETED** | macOS `security`, Windows `certutil`, WSL interop |
| **1.6** | Dynamic YAML Database Profile Engine | **✅ COMPLETED** | 7 YAML profiles, `resolve-topology.sh` dynamic resolver |
| **1.7** | Automated Test Framework (Unit & E2E) | **✅ COMPLETED** | `test-all-components.sh`, `test-e2e-system.sh`, unit tests |
| **2.1** | Elimination of Hardcoded Fallback Passwords | **✅ COMPLETED** | All fallback passwords removed, resolved strictly via SEPS Wallet/Secrets |
| **2.2** | WebLogic REST & Publisher HTTPS Reverse Proxy | **✅ COMPLETED** | Nginx TLS 1.3 reverse proxy (`publisher-ssl-proxy.conf`) |
| **3.1** | Host Port Isolation (`127.0.0.1`) | **✅ COMPLETED** | Ports strictly bound to local interface (`127.0.0.1`) |
| **3.2** | Rootless Container Execution & Privilege Drop | **✅ COMPLETED** | Added `--security-opt=no-new-privileges` across all invocations |
| **4.1** | Log Secret Masking & Token Redaction | **✅ COMPLETED** | Created `sanitize-logs.sh`, redacting tokens and passwords |
| **1.14** | Universal Real-time Progress & Unbuffered Streaming | **✅ COMPLETED** | Hybrid `print_step_progress` & `sed -u` unbuffered filter |
| **1.15** | Unified Post-Deployment Healthcheck Architecture | **✅ COMPLETED** | Central verification `test-urls.sh` (ORDS, APEX, Publisher, Web IDE) |
| **1.16** | 4-Tier Enterprise Distributed Topology | **✅ COMPLETED** | `publisher-free` + `proxy-gvenzl` + `app-free`, Outbound REST ACLs |
| **1.17** | Automated Image/Artifact Version Detection | **✅ COMPLETED** | Detected via container labels & manifest inspection |
| **1.18** | Setup Speedup (APEX DB 15m ➔ 1–2m) | **✅ COMPLETED** | FastStart/Artifactory images, Golden Snapshots (~30s), runtime mode (`TASK-018`) |
| **1.19** | Analytics Publisher & Multi-DB Speedup | **✅ COMPLETED** | Pre-built domain image (~45s), parallel orchestration (`TASK-019`) |
| **1.20** | Multi-DB SEPS Wallet & TNS Synchronization | **✅ COMPLETED** | Parallel database SEPS wallets & synchronized `tnsnames.ora` (`TASK-027`) |
| **1.21** | VS Code Wallet Full-User Synchronization | **✅ COMPLETED** | Auto-registration of all profile schemas in VS Code (`TASK-028`) |
| **1.22** | Oracle Forms 14c Container & noVNC Support | **✅ COMPLETED** | Forms 14c runtime, HTML5 noVNC builder GUI (port 6083) (`TASK-029`) |
| **1.23** | Canonical Container-Prefixed SEPS Wallets | **✅ COMPLETED** | Zero hardcoding via `DB_${PREFIX}_*` formula (`TASK-030`) |
| **1.24** | Compact Terminal Progress & Elapsed Time Bar | **✅ COMPLETED** | In-place TTY refresh (`\r\033[K`), historical benchmark tracking (`TASK-025`) |
| **1.25** | `setup-all.sh` Blueprint Discovery & Inspection CLI | **✅ COMPLETED** | `--list-blueprints` (`-lb`), `--show-blueprint <N>`, `--search-blueprints` (`TASK-026`) |
| **2.13** | Reorganization of Future Plans into Backlog | **✅ COMPLETED** | Modular `backlog/todo/` and `backlog/done/` structures |
| **4.2** | Clean Workspace Logs & Diagnostics (`clean-logs.sh`) | **✅ COMPLETED** | Script `scripts/clean-logs.sh` created and verified (`TASK-008`) |
| **5.1** | Official Enterprise PKI / TLS Certificates | **❌ NOT STARTED** | Currently utilizing local self-signed `localCA.pem` |
| **6.1** | OCI Always Free Cloud Remote Deployment Test | **🟡 IN PROGRESS** | `deploy-remote.sh` ready, awaiting cloud tenancy execution (`TASK-020`) |
| **6.2** | GitHub Actions Cloud Continuous Delivery | **🟡 IN PROGRESS** | `deploy-remote-cloud.yml` workflow ready, awaiting secrets (`TASK-020`) |
| **2.8** | Automated TDE (Transparent Data Encryption) Support | **🟡 IN PROGRESS** | AES-256 tablespace encryption on disk (`TASK-021`) |
| **2.9** | Read-Only Root Filesystem & Container Hardening | **🟡 IN PROGRESS** | Read-only container rootfs with dedicated `tmpfs` mounts (`TASK-022`) |
| **2.10** | Central Unified Auditing & SIEM Forwarding | **❌ NOT STARTED** | Oracle Unified Auditing policies & audit forwarder (`TASK-023`) |
| **2.11** | WAF & OAuth2 / OIDC Entra-ID Integration for REST | **🟡 IN PROGRESS** | Nginx ModSecurity WAF & ORDS OAuth2 token enforcement (`TASK-024`) |

---

## 🟢 1. Realized and Validated Capabilities

### 1.1 Containerized Developer Workspace (VS Code + SQL Developer + Git)
- **Status:** **✅ COMPLETED & VALIDATED**
- **Documentation:** 📄 [docs/web-ide-artifactory.md](web-ide-artifactory.md)
- **Validation:** Inspected `web-ide` profile and Dockerfile. Image includes pre-installed OpenJDK 21, Oracle SQLcl, Liquibase, Git, Python 3, GitHub CLI (`gh`), `act` CLI, and VS Code extensions (`Oracle.sql-developer-for-vscode`, `github.vscode-github-actions`). Accessible via browser at `http://localhost:8090`.

### 1.2 GitHub Actions / CI/CD Workflow & Offline Local Testing
- **Status:** **✅ COMPLETED & VALIDATED**
- **Documentation:** 📄 [docs/devops-lifecycle-guide.md](devops-lifecycle-guide.md)
- **Validation:** SQLcl Projects automation (`.dbtools/project.config.json`), local offline simulator [`./scripts/test-local-ci.sh`](../scripts/test-local-ci.sh), and local workflow actions verified.

### 1.3 Oracle Analytics Publisher (Pixel Perfect) Local Deployment
- **Status:** **✅ COMPLETED & VALIDATED**
- **Documentation:** 📄 [docs/publisher-setup.md](publisher-setup.md)
- **Validation:** Deployment tested and verified (`oracle/analyticsserver:2025`). Endpoint `/xmlpserver/login.jsp` on port `9502` returns **HTTP 200 OK** and `<title>Oracle Analytics Publisher Login</title>`.

### 1.4 Universal VS Code Connection Registration
- **Status:** **✅ COMPLETED & VALIDATED**
- **Documentation:** 📄 [connections/README.md](../connections/README.md)
- **Validation:** Automatically provisions connections into VS Code Oracle SQL Developer extension under `/APEX` (Standard DB), `/MYATP` (ADB mode), and `/Publisher` (Publisher DB).

### 1.5 Cross-Platform SSL Root Certificate Trust
- **Status:** **✅ COMPLETED & VALIDATED**
- **Validation:** `setup-all.sh` and `generate-local-certs.sh` trust local Root CA (`config/certs/localCA.pem`) in the host operating system keychain (macOS `security`, Windows `certutil`, WSL interop).

### 1.6 Dynamic YAML Database Profile Engine & Topology Manager
- **Status:** **✅ COMPLETED & VALIDATED**
- **Documentation:** 📄 [docs/db-profiles-and-topology.md](db-profiles-and-topology.md)
- **Validation:** 7 standard YAML profiles (`config/profiles/*.yaml`) and [`resolve-topology.sh`](../scripts/internal/resolve-topology.sh) resolving port allocations and memory constraints dynamically.

### 1.7 Modular Automated Test Framework
- **Status:** **✅ COMPLETED & VALIDATED**
- **Documentation:** 📄 [tests/README.md](../tests/README.md)
- **Validation:** Modular test suite ([`test-all-components.sh`](../tests/test-all-components.sh) and [`test-e2e-system.sh`](../tests/integration/test-e2e-system.sh)) verifying ORDS REST endpoints, APEX engine, wallet encryption, and SSL certificates with 0 manual intervention.

### 1.8 Workspace Clean-Up Utility (`clean-logs.sh`)
- **Status:** **✅ COMPLETED & VALIDATED**
- **Documentation:** 📄 [scripts/README.md](../scripts/README.md)
- **Validation:** Script [`./scripts/clean-logs.sh`](../scripts/clean-logs.sh) cleans all execution logs, unzipped directories, and diagnostic bundles.

### 1.9 Elimination of Hardcoded Passwords
- **Status:** **✅ COMPLETED & VALIDATED**
- **Description:** Removed legacy hardcoded fallback passwords across all scripts. All credentials are dynamically extracted from **Oracle Wallet (SEPS)** and **Podman Secrets Store**.

### 1.10 Host Port Isolation (`127.0.0.1`)
- **Status:** **✅ COMPLETED & VALIDATED**
- **Description:** All container service ports (DB `1532`/`1533`, ORDS `8088`/`8448`, Publisher `9500`/`9502`/`9503`, Web IDE `8090`/`8449`) are bound strictly to localhost (`127.0.0.1`), preventing unwanted network exposure.

### 1.11 WebLogic REST API & Publisher HTTPS Reverse Proxy
- **Status:** **✅ COMPLETED & VALIDATED**
- **Description:** Configured Nginx TLS 1.3 reverse proxy ([`config/nginx/publisher-ssl-proxy.conf`](../config/nginx/publisher-ssl-proxy.conf)) protecting WebLogic AdminServer (port `9500`) and Publisher UI (port `9502`).

### 1.12 Rootless Container Mode & Privilege Boundaries
- **Status:** **✅ COMPLETED & VALIDATED**
- **Description:** Added `--security-opt=no-new-privileges` to container runs and compose templates to prevent container breakout vulnerabilities.

### 1.13 Log Secret Masking & Token Redaction
- **Status:** **✅ COMPLETED & VALIDATED**
- **Description:** Script [`scripts/internal/sanitize-logs.sh`](../scripts/internal/sanitize-logs.sh) automatically strips access tokens, bearer headers, and passwords from logs, replacing them with `***MASKED***`.

### 1.14 Universal Real-Time Terminal Progress & Unbuffered Streaming
- **Status:** **✅ COMPLETED & VALIDATED**
- **Description:** Implemented hybrid Option C double-stream logging (`print_step_progress`) and unbuffered streaming filter (`sed -u -E`), providing live second counters without polluting disk logs with `\r` control characters.

### 1.16 LIS Enterprise Topology (4-Tier Architecture)
- **Status:** **✅ COMPLETED & VALIDATED**
- **Description:** Standard enterprise 4-tier model (`db-publisher` metadata + `db-proxy` APEX/SSO gateway + `db-alise` isolated core DB + `app_ords` multi-pool ORDS gateway + `app_publisher` BI Publisher).

### 1.18 Setup Speedup (APEX DB 15m ➔ 1–2m)
- **Status:** **✅ COMPLETED & VALIDATED**
- **Backlog Reference:** 📄 [`backlog/done/TASK-018-apex-install-speedup.md`](../backlog/done/TASK-018-apex-install-speedup.md)
- **Implementation:** FastStart/Artifactory internal images, Golden Snapshot recovery (~30s), DB SGA/PGA memory tuning, and APEX Runtime-only installation option.

### 1.19 Analytics Publisher & Multi-DB Speedup
- **Status:** **✅ COMPLETED & VALIDATED**
- **Backlog Reference:** 📄 [`backlog/done/TASK-019-publisher-speedup.md`](../backlog/done/TASK-019-publisher-speedup.md)
- **Implementation:** Pre-built WebLogic BI domain image (~45s startup), configurable parallelism, and domain builder utility.

### 1.20 Multi-DB SEPS Wallet & TNS Synchronization
- **Status:** **✅ COMPLETED & VALIDATED**
- **Backlog Reference:** 📄 [`backlog/done/TASK-027-multi-db-seps-wallet-and-tns-alignment.md`](../backlog/done/TASK-027-multi-db-seps-wallet-and-tns-alignment.md)

### 1.21 VS Code Wallet Full-User Synchronization
- **Status:** **✅ COMPLETED & VALIDATED**
- **Backlog Reference:** 📄 [`backlog/done/TASK-028-vscode-wallet-all-users-sync.md`](../backlog/done/TASK-028-vscode-wallet-all-users-sync.md)

### 1.22 Oracle Forms 14c Container & noVNC Support
- **Status:** **✅ COMPLETED & VALIDATED**
- **Backlog Reference:** 📄 [`backlog/done/TASK-029-oracle-forms-container-and-profiles.md`](../backlog/done/TASK-029-oracle-forms-container-and-profiles.md)

### 1.23 Canonical Container-Prefixed SEPS Wallets
- **Status:** **✅ COMPLETED & VALIDATED**
- **Backlog Reference:** 📄 [`backlog/done/TASK-030-canonical-container-prefix-wallets.md`](../backlog/done/TASK-030-canonical-container-prefix-wallets.md)

### 1.24 Compact Terminal Progress & Elapsed Time Bar
- **Status:** **✅ COMPLETED & VALIDATED**
- **Backlog Reference:** 📄 [`backlog/done/TASK-025-compact-terminal-ux.md`](../backlog/done/TASK-025-compact-terminal-ux.md)

### 1.25 `setup-all.sh` Blueprint Discovery & Inspection CLI
- **Status:** **✅ COMPLETED & VALIDATED**
- **Backlog Reference:** 📄 [`backlog/done/TASK-026-blueprint-cli-params.md`](../backlog/done/TASK-026-blueprint-cli-params.md)

---

## 🔴 2. Pending and Future Engineering Tasks

### 2.1 Enterprise PKI / CA Certificate Support
- **Status:** **❌ NOT STARTED**
- **Objective:** Replace self-signed `localCA.pem` with enterprise internal CA or Let's Encrypt certificates in production deployments.

### 2.2 Oracle Cloud Infrastructure (OCI) Automated Remote Deployment
- **Status:** **🟡 IN PROGRESS**
- **Backlog Reference:** 📄 [`backlog/todo/TASK-020-cloud-oci-deployment.md`](../backlog/todo/TASK-020-cloud-oci-deployment.md)

### 2.3 Transparent Data Encryption (TDE) & Keystore Lifecycle
- **Status:** **🟡 IN PROGRESS**
- **Backlog Reference:** 📄 [`backlog/todo/TASK-021-tde-encryption.md`](../backlog/todo/TASK-021-tde-encryption.md)

### 2.4 Read-Only Container Filesystem & Security Hardening
- **Status:** **🟡 IN PROGRESS**
- **Backlog Reference:** 📄 [`backlog/todo/TASK-022-readonly-hardening.md`](../backlog/todo/TASK-022-readonly-hardening.md)

### 2.5 Central Unified Auditing & SIEM Forwarding
- **Status:** **❌ NOT STARTED**
- **Backlog Reference:** 📄 [`backlog/todo/TASK-023-unified-auditing-siem.md`](../backlog/todo/TASK-023-unified-auditing-siem.md)

### 2.6 WAF & OAuth2 / OIDC Entra-ID Integration for REST APIs
- **Status:** **🟡 IN PROGRESS**
- **Backlog Reference:** 📄 [`backlog/todo/TASK-024-waf-oauth2-entra-id.md`](../backlog/todo/TASK-024-waf-oauth2-entra-id.md)
