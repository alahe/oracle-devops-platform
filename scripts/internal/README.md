# ⚙️ Internal Scripts Directory (`scripts/internal/`)

According to **Rule 3 (Directory Layout Rule for Scripts)**, this directory contains auxiliary automation engines, profile parsers, database initializers, automated setup steps, and SQL files used internally by the environment orchestrator (`setup-all.sh`).

> 💡 **Developer Tools:** Developer CLI tools (`get-password.sh`, `check-urls.sh`, `check-wallet.sh`, `create-developer.sh`, `register-connections.sh`) are located directly in [`scripts/`](../README.md).

---

## 📂 Internal Scripts Reference

### 📦 1. Profile Engine & Topology Management
| Script | Description |
| :--- | :--- |
| **[load-profile.sh](load-profile.sh)** | Dynamic YAML Profile parser (`config/profiles/*/*.yaml`). Enforces 3-level precedence hierarchy for container images and ZIP URLs. |
| **[resolve-topology.sh](resolve-topology.sh)** | Multi-instance topology manager (`config/topology.yaml`). Resolves non-clashing ports (`1532`, `1533`, `8443`, `8444`). |
| **[apply-profile-users.sh](apply-profile-users.sh)** | Dynamic DB user provisioning, role assignments (`DB_DEVELOPER_ROLE`, `CONSOLE_DEVELOPER`), ORDS REST mapping, and APEX workspace user creation. |

### 🚀 2. APEX & ORDS Engine Installation
| Script | Description |
| :--- | :--- |
| **[install-apex.sh](install-apex.sh)** | Automated APEX engine installation (`@apexins.sql`) into standard Oracle Free DB 23ai instances. |
| **[install-ords-standalone.sh](install-ords-standalone.sh)** | Standalone ORDS installer script for Linux server deployments outside Docker. |
| **[deploy-apex-apps.sh](deploy-apex-apps.sh)** | Sequential APEX application importer for application files in `binaries/apex_apps/`. |
| **[deploy-apex.sql](deploy-apex.sql)** | SQLcl PL/SQL wrapper for importing APEX application SQL exports. |

### 🔌 3. Profile-Driven Instance Initialization
| Script / SQL | Description |
| :--- | :--- |
| **[init-db-instance.sh](init-db-instance.sh)** | Generic profile-driven database initializer script for ANY profile (`proxy`, `appinfra`, `bizapp`, `cicd`). |
| **[init-db-instance.sql](init-db-instance.sql)** | Profile-driven PL/SQL script configuring memory tuning, tablespaces, and REST Network ACLs. |

### 🔑 4. Security, Secrets & Certificates
| Script | Description |
| :--- | :--- |
| **[create-wallet.sh](create-wallet.sh)** | Generates Oracle SEPS (Secure External Password Store) auto-login wallets (`cwallet.sso`). |
| **[export-ci-secrets.sh](export-ci-secrets.sh)** | Packages local SEPS Wallet as Base64 encoded string (`DB_WALLET_BASE64`) for GitHub Secrets and CI/CD pipelines. |
| **[generate-passwords.sh](generate-passwords.sh)** | Generates high-entropy random passwords and registers them as Podman Secrets. |
| **[sanitize-logs.sh](sanitize-logs.sh)** | Stream filter for stdout/stderr log output; masks secrets/tokens (`token=***MASKED***`). Supports `DEBUG_LOG_UNSANITIZED=true` override for emergency debugging. |
| **[generate-local-certs.sh](generate-local-certs.sh)** | Generates local Root CA and SSL certs (`config/certs/`) and trusts them in macOS Keychain, Windows, or WSL. |

### 💻 5. Containerized Web IDE Initialization
| Script | Description |
| :--- | :--- |
| **[init-web-ide.sh](init-web-ide.sh)** | Pre-configures code-server settings, SEPS Wallet sync, and SQL Developer connections inside the Containerized Web IDE (`web-ide`). |
| **[install-web-ide-extensions.sh](install-web-ide-extensions.sh)** | Installs required and custom VS Code extensions (VSIX) inside the containerized Web IDE. |

### ⚡ 6. Orchestration & Core Optimization Utilities
| Script | Description |
| :--- | :--- |
| **[common.sh](common.sh)** | Central shared core shell library (colors, duration formatters, progress reporting, signal cleanup traps, and pigz compression helpers). |
| **[generate-compose-override.sh](generate-compose-override.sh)** | Dynamic Podman Compose override generator (`podman-compose.override.yml`) based on active database profiles and Podman secrets. |
| **[wait-db-healthy.sh](wait-db-healthy.sh)** | 2-phase adaptive healthcheck & self-healing engine verifying container health, TCP listeners, and PDB READ WRITE status. |
| **[generate-setup-report.sh](generate-setup-report.sh)** | Benchmark & setup report generator exporting JSON benchmarks, ENV metrics, and blueprint audit Markdown reports. |



