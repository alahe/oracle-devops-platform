# 🛠️ Internal Scripts Directory (`scripts/internal/`)

According to **Rule 3 (Directory Layout Rule for Scripts)**, this directory contains all auxiliary scripts, profile parsers, database initializers, automated setup steps, and SQL files used internally by the environment orchestrator (`setup-all.sh`).

---

## 📂 Internal Scripts Reference

### 📦 1. Profile Engine & Topology Management
| Script | Description |
| :--- | :--- |
| **[load-db-profile.sh](load-db-profile.sh)** | Dynamic YAML Profile parser (`config/profiles/*.yaml`). Enforces 3-level precedence hierarchy for container images and ZIP URLs. |
| **[resolve-topology.sh](resolve-topology.sh)** | Multi-instance topology manager (`config/topology.yaml`). Resolves non-clashing ports (`1532`, `1533`, `8443`, `8444`). |
| **[apply-profile-users.sh](apply-profile-users.sh)** | Dynamic DB user provisioning, role assignments (`DB_DEVELOPER_ROLE`, `CONSOLE_DEVELOPER`), ORDS REST mapping, and APEX workspace user creation. |

### 🚀 2. APEX & ORDS Installation & Patching
| Script | Description |
| :--- | :--- |
| **[install-apex.sh](install-apex.sh)** | Automated APEX engine installation (`@apexins.sql`) into standard Oracle Free DB 23ai instances. |
| **[apply-apex-patch.sh](apply-apex-patch.sh)** | Applies APEX Bundle Patches (`catpatch.sql` / `p*.zip`) to APEX installations. |
| **[install-ords-standalone.sh](install-ords-standalone.sh)** | Standalone ORDS installer script for Linux server deployments outside Docker. |
| **[deploy-apex-apps.sh](deploy-apex-apps.sh)** | Sequential APEX application importer for application files in `binaries/apex_apps/`. |
| **[deploy-apex.sql](deploy-apex.sql)** | SQLcl PL/SQL wrapper for importing APEX application SQL exports. |

### 🔌 3. Profile-Driven Instance Initialization
| Script / SQL | Description |
| :--- | :--- |
| **[init-db-instance.sh](init-db-instance.sh)** | Generic profile-driven database initializer script for ANY profile (`proxy`, `appinfra`, `bizapp`, `cicd`). |
| **[init-db-instance.sql](init-db-instance.sql)** | Profile-driven PL/SQL script configuring memory tuning, tablespaces, and REST Network ACLs. |
| **[init-apex-proxy.sh](init-apex-proxy.sh)** | Backward-compatible wrapper calling `init-db-instance.sh proxy-adb-oracle`. |
| **[init-publisher.sh](init-publisher.sh)** | Backward-compatible wrapper calling `init-db-instance.sh appinfra-standard-gvenzl`. |

### 🔑 4. Security, Wallets & Certificates
| Script | Description |
| :--- | :--- |
| **[create-wallet.sh](create-wallet.sh)** | Generates Oracle SEPS (Secure External Password Store) auto-login wallets (`cwallet.sso`). |
| **[view-wallet-credential.sh](view-wallet-credential.sh)** | Securely retrieves and prints database passwords stored inside SEPS Wallet files. |
| **[export-ci-secrets.sh](export-ci-secrets.sh)** | Packages local SEPS Wallet as Base64 encoded string (`DB_WALLET_BASE64`) for GitHub Secrets and CI/CD pipelines. |
| **[generate-passwords.sh](generate-passwords.sh)** | Generates high-entropy random passwords and registers them as Podman Secrets. |

| **[generate-local-certs.sh](generate-local-certs.sh)** | Generates local Root CA and SSL certs (`config/certs/`) and trusts them in macOS Keychain, Windows, or WSL. |
| **[create-developer.sh](create-developer.sh)** | Interactive CLI helper for creating additional APEX developer accounts and database schemas. |

### 💻 5. VS Code & Client Connections Registration
| Script | Description |
| :--- | :--- |
| **[register-connections-sqlcl.sh](register-connections-sqlcl.sh)** | Registers VS Code SQL Developer extension connection profiles, folder organization (`/MYATP`, `/Publisher`), title case names, and colors. |
| **[register-connections.sh](register-connections.sh)** | Dynamically generates VS Code / SQL Developer connection folders, credentials, and custom color codes across `SQLcl`, `~/.dbtools/`, `~/.sqldev/connections.json`, and `dbtools.properties` using `.env` folder name, active YAML profile configuration, and Oracle Wallet (SEPS). |
| **[init-web-ide.sh](init-web-ide.sh)** | Pre-configures code-server settings, SEPS Wallet sync, and SQL Developer connections inside the Containerized Web IDE (`web-ide`). |

