[ 🇬🇧 English ](web-ide-artifactory.md) | [ 🇪🇪 Eesti ](et/web-ide-artifactory.md) | [ 🇫🇮 Suomi ](fi/web-ide-artifactory.md) | [ 🇸🇪 Svenska ](sv/web-ide-artifactory.md) | [ 🇱🇻 Latviešu ](lv/web-ide-artifactory.md) | [ 🇱🇹 Lietuvių ](lt/web-ide-artifactory.md)

# Containerized Web IDE & Enterprise Extension Marketplace

This guide covers configuring and using the **Containerized Web IDE (`web-ide` / `code-server`)** in your browser, integrating enterprise **Artifactory / VS Code Marketplaces**, configuring **Oracle SQL Developer, Google Antigravity, and Microsoft Python**, and running **100% offline, zero-trust GitHub Actions testing**.

---

## 1. Web IDE Architecture & Pre-Installed Tooling

The Web IDE consolidates a complete Oracle DB, AI, and CI/CD development environment into a browser-based VS Code workspace (`localhost/oracle-web-ide:latest`):
- **Browser URL:** `http://localhost:8090` (HTTP) or `https://localhost:8449` (HTTPS).
- **Pre-installed System Tools:** OpenJDK 21, Oracle SQLcl 26.2, Liquibase, Git, Python3 (`venv`, `pytest`), GitHub CLI (`gh`), Nektos `act` CLI runner, `actionlint`, and `yamllint`.
- **Pre-Baked VS Code Extensions:**
  1. 🗄️ **Oracle SQL Developer for VS Code** (`Oracle.sql-developer-for-vscode`, Vendor: Oracle): Database Navigator, SQL Worksheet, PL/SQL Editor, Explain Plan.
  2. 🤖 **Google Antigravity** (`google.antigravity`, Vendor: Google): AI coding assistant, code refactoring, and agentic workflows.
  3. 🐍 **Python Suite** (`ms-python.python`, `ms-python.vscode-pylance`, `ms-python.debugpy`, Vendor: Microsoft): Python language server, debugger, virtual environment management (`venv`), and test discovery.
  4. ⚙️ **GitHub Actions** (`github.vscode-github-actions`, Vendor: GitHub): Workflow syntax highlighting, CI/CD visualization.
  5. 📄 **Red Hat YAML** (`redhat.vscode-yaml`, Vendor: Red Hat): YAML profile and docker-compose schema validation.
- **Automatic `.sql` File Association:**
  - Clicking any `.sql`, `.pls`, `.pks`, or `.pkb` file in the file explorer automatically opens it directly inside **Oracle SQL Developer Editor / Worksheet** with database connection binding.
- **Zero-Trust Connection & Wallet Synchronization:**
  - Host directory `$HOME/.dbtools/connections` mounts to `/config/.dbtools/connections:rw`.
  - Encrypted SEPS Wallet (`config/tns_admin_container`) mounts to `/config/.oracle/tns_admin:ro`.
  - All host connections (`DB_PROXY_DEV`, `DB_ALISE_DEV`, etc.) are immediately available passwordlessly.

---

## 2. 4-Tier Extension Resolution & Air-Gapped Cache (`binaries/extensions/`)

When Web IDE starts, it resolves extensions following this hierarchy:
```
1. 📁 binaries/extensions/*.vsix         ➔ Air-Gapped Local Cache (Highest Priority, 0 Network)
2. 📁 $HOME/.vscode/extensions/          ➔ Desktop VS Code Extension Sync
3. 🌐 download_url in profile YAML       ➔ Downloads & caches to binaries/extensions/
4. 🌐 code-server --install-extension    ➔ Configured Marketplace (Open VSX or Microsoft)
```

### Marketplace Provider Switcher (`.env`):
You can toggle the marketplace source in your `.env` file:
```bash
# Options: openvsx (default) | microsoft | artifactory
VSCODE_MARKETPLACE_PROVIDER=microsoft
```

---

## 3. Offline GitHub Actions Simulation (`act` and `actionlint`)

Web IDE allows running and debugging GitHub Actions workflows (`.github/workflows/*.yml`) **100% locally without uploading code or secrets**:

### 💻 Useful Commands in Web IDE Terminal:
1. **Static AST & Security Linting (actionlint):**
   ```bash
   actionlint
   ```
2. **List all workflows and jobs:**
   ```bash
   act -l
   ```
```

---

## 4. Kohalikud VS Code (.vsix) Laiendused ja Uuendused (UI Update)

1. **Laienduste uuendamine veebiliideses:**
   - Web IDE veebiliideses ("Extensions" vahekaart) saab arendaja teha igal ajal vabalt "Update" või otsida Marketplace'ist uusi laiendusi. Need salvestuvad püsivasse `/config` kettamahtu.
2. **Kohalike .vsix failide offline paigaldamine:**
   - Aseta `.vsix` fail kausta **`binaries/extensions/`**.
   - Käivitamisel tuvastab `scripts/internal/init-web-ide.sh` failid ja paigaldab need automaatselt.

---

## 5. Web IDE Elutsükli Käsud

```bash
# 1. Käivita Blueprint koos Web IDE-ga (nt Blueprint 30):
./scripts/setup-all.sh -b 30

# 2. Käivita olemasolevad konteinerid koos Web IDE-ga:
./scripts/start-containers.sh

# 3. Ehita / uuenda Web IDE konteineripilt lokaalselt:
./docker/web-ide/build-web-ide-image.sh

# 4. Käivita ilma Web IDE-ta (kui mälu on piiratud):
./scripts/setup-all.sh --no-web-ide
./scripts/start-containers.sh --no-web-ide

# 5. Puhasta Web IDE konteiner ja persistentne volume:
./scripts/reset-all.sh all
```