# VS Code Extensions Cache (`binaries/extensions/`) & Air-Gapped Resolution

This directory serves as the **Tier 1 Air-Gapped & Offline Local Cache** for VS Code `.vsix` extension packages.

When the Web IDE container (`web-ide-dev`) starts up (`scripts/internal/init-web-ide.sh` & `scripts/internal/install-web-ide-extensions.sh`), it scans this directory and automatically installs all `.vsix` files with highest priority before making any external network requests.

---

## 4-Tier Extension Resolution Hierarchy

```
1. 📁 binaries/extensions/*.vsix         ➔ Local offline cache (Highest Priority, 0 Network)
2. 📁 $HOME/.vscode/extensions/          ➔ Auto-syncs desktop VS Code installed extensions
3. 🌐 download_url in profile YAML       ➔ Downloads from Artifactory/Mirror & caches to binaries/extensions/
4. 🌐 code-server --install-extension    ➔ Queries configured marketplace (Open VSX or Microsoft Marketplace)
```

---

## 📦 Supported Official Extensions

| Extension Name | Publisher / Vendor | Recommended `.vsix` Filename | Purpose |
| :--- | :--- | :--- | :--- |
| **Oracle SQL Developer** | Oracle | `oracle.sql-developer-for-vscode.vsix` | Database Object Browser, SQL Worksheet, Explain Plan, SEPS Wallet |
| **Google Antigravity** | Google | `antigravity.vsix` / `google.antigravity.vsix` | AI Pair Programmer & Agentic Orchestrator |
| **Python** | Microsoft | `ms-python.python.vsix` | Python Language Server & Virtual Environments (`venv`, `pytest`) |
| **Pylance** | Microsoft | `ms-python.vscode-pylance.vsix` | Fast Python Type Checking & IntelliSense |
| **Python Debugger** | Microsoft | `ms-python.debugpy.vsix` | Python Debug Adapter |
| **GitHub Actions** | GitHub | `github.vscode-github-actions.vsix` | Visual Workflow Management & CI/CD diagnostics |
| **Red Hat YAML** | Red Hat | `redhat.vscode-yaml.vsix` | YAML & GitHub Workflow schema validation |

---

## ⚡ Automatic `.sql` File Association
Upon container initialization, all `.sql`, `.pls`, `.pks`, and `.pkb` files are automatically mapped to `oracle-sql` and configured to open directly inside the **Oracle SQL Developer Editor / SQL Worksheet** with interactive execution and database connection bindings.
