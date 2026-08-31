[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](docs/et/README.md) | [ 🇫🇮 Suomi ](docs/fi/README.md) | [ 🇸🇪 Svenska ](docs/sv/README.md) | [ 🇱🇻 Latviešu ](docs/lv/README.md) | [ 🇱🇹 Lietuvių ](docs/lt/README.md)

# Oracle DevOps Platform

> **Production-ready, zero license cost (0 €), and 100% passwordless (SEPS Wallet) Oracle 23ai, APEX 26, Forms 14c, Publisher, and Web IDE development & DevOps platform.**

---

## 🎯 Value Proposition & Core Benefits

1. 💰 **Massive Cost Savings (0 € License Cost):** Powered by Oracle Database Free 23ai (JSON-Relational Duality, Kafka, APEX 26.1), saving thousands in enterprise license fees.
2. 🔒 **100% Passwordless & Leak-Proof (SEPS Wallet):** Oracle Wallet (SEPS) and Podman Secrets eliminate credentials from files, logs, and `ps aux` outputs. Single-click developer authentication.
3. ⚡ **Ready in Seconds (Prebuilt Images & Snapshots):** Prebuilt container images start complete enterprise stacks in **1–2 minutes instead of 15 minutes**.

---

## 📦 Architecture Stacks (Decade Matrix)

The platform provides **23 canonical environment blueprints** organized across 5 logical series:

| Series | Stack Name | Active Containers | Key Features | Detailed Guide |
| :---: | :--- | :--- | :--- | :--- |
| **1–9** | **Core DB & APEX** | `db-alise`, `db-proxy`, `app-ords` | Oracle 23ai Free DB, APEX 26.1 Builder, multi-pool ORDS, REST Enabled SQL | 🗄️ **[config/blueprints/README.md](config/blueprints/README.md)** |
| **10–19** | **Analytics Publisher** | `db-publisher`, `app-publisher`, `app-ords` | Pixel Perfect PDF/Excel reports, WebLogic BI domain, RCU metadata, `PUBLISHER_READER` wallet | 📑 **[docs/publisher-setup.md](docs/publisher-setup.md)** |
| **20–29** | **Oracle Forms 14c** | `db-forms`, `app-forms`, `app-ords` | Forms Services 14.1.2 (`/forms/frmservlet`), test form (`test.fmx`), batch compile, APEX migration | 📐 **[docs/forms-setup.md](docs/forms-setup.md)** |
| **30–39** | **Web IDE & CI/CD** | `web-ide-dev`, `db-alise`, `app-ords` | Browser VS Code (Port 8090), Oracle SQL Dev, Antigravity AI, offline GitHub Actions (`act`) | 💻 **[docs/web-ide-artifactory.md](docs/web-ide-artifactory.md)** |
| **40–49** | **Ultimate Enterprise** | All services combined | Forms 14c + Publisher + APEX 26.1 + ORDS + Web IDE (all-in-one & isolated models) | 🌟 **[config/blueprints/README.md](config/blueprints/README.md)** |

---

## 🚀 Quickstart CLI Cheat-Sheet

```bash
# 1. Start desired blueprint (e.g. BP 41: All-in-One Enterprise or BP 43: Hybrid 2-DB):
./scripts/setup-all.sh -b 41

# 2. View credentials & services matrix table (or copy password to clipboard via -c):
./scripts/get-password.sh
./scripts/get-password.sh DB_PROXY_DEV -c
./scripts/get-password.sh DB_PROXY_APEX_ADMIN -c

# 3. Quick Login & Zero-Friction Web Access Guide:
# 👉 See: docs/quick-login-guide.md (or docs/et/quick-login-guide.md)

# 4. Rotate credentials securely (zero downtime, updates DB, Podman Secrets, & SEPS Wallet):
./scripts/rotate-password.sh db-proxy dev
./scripts/rotate-password.sh all

# 5. Test active web service endpoints:
./scripts/check-urls.sh

# 6. Run automated end-to-end browser & UI login authentication test:
./scripts/test-browser-login.sh

# 7. Check SEPS passwordless Oracle Wallet connections:
./scripts/check-wallet.sh

# 8. Run multi-language (i18n) verification suite (Rule 9: EN, ET, FI, SV, LV, LT):
./tests/test-multilingual-support.sh

# 9. Create or restore Golden Snapshots (instant ~15s recovery):
./scripts/snapshots/create-golden-snapshots.sh
./scripts/snapshots/restore-golden-snapshots.sh

# 10. Clean logs, temporary files, and old snapshots:
./scripts/clean-logs.sh -y
./scripts/snapshots/clean-golden-snapshots.sh -y

# 11. Reset environment to clean slate:
./scripts/reset-all.sh -y
```

---

## 📑 Dedicated User Guides

- 🚀 **[docs/forms-to-apex-migration-guide.md](docs/forms-to-apex-migration-guide.md):** **Oracle Forms to APEX Modernization & Migration Guide** — Business case, TCO comparison, 5-stage automated migration workflow, PL/SQL extraction, and AI vibe-coding with [Oracle APEXlang DSL](https://docs.oracle.com/en/database/oracle/apex/26.1/apxln/).
- 📐 **[docs/forms-setup.md](docs/forms-setup.md):** Oracle Forms 14c Guide — Port map (9001/7001/6082), test form access (`frmservlet?form=test.fmx`), adding forms to `forms_apps/`, compiling, and APEX migration.
- 📑 **[docs/publisher-setup.md](docs/publisher-setup.md):** Analytics Publisher Guide — Port 9502 (`/xmlpserver`), RCU metadata DB, `PUBLISHER_READER` Wallet account, JDBC data source wiring, and report deployment.
- 💻 **[docs/web-ide-artifactory.md](docs/web-ide-artifactory.md):** Web IDE Guide — VS Code extensions (Oracle SQL Developer, Antigravity AI, GitHub Actions), host connection sync, and offline GitHub Actions testing (`act`).
- 🌐 **[docs/dev-hub.html](docs/dev-hub.html):** **Developer & DevOps Command Center** — Served on **`http://localhost:8088/`** and **`https://localhost:8448/`** (ORDS) as well as **`http://localhost:6082/vnc.html`** (Forms). Features live latency polling, interactive Mermaid architecture diagrams, 23 Blueprints Explorer, in-browser Markdown Documentation Reader, collapsible SEPS Wallet credentials matrix, and DevOps Command Dispatcher in 6 languages (🇬🇧 EN, 🇪🇪 ET, 🇫🇮 FI, 🇸🇪 SV, 🇱🇻 LV, 🇱🇹 LT).
- 📊 **[config/blueprints/README.md](config/blueprints/README.md):** Full technical matrix for all 23 architecture blueprints.
- 📖 **[Oracle APEX 26.1 APEXlang Reference Manual](https://docs.oracle.com/en/database/oracle/apex/26.1/apxln/):** Official Oracle specification for declarative `.apx` grammar, compiler AST nodes, and CLI commands.
