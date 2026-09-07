[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🧩 VS Code Extensions Cache (`binaries/extensions/`)

This directory serves as the **Tier 1 Air-Gapped & Offline Local Cache** for VS Code `.vsix` extension packages.

---

## 4-Tier Extension Resolution Hierarchy

```
1. 📁 binaries/extensions/*.vsix         ➔ Local offline cache (Highest Priority, 0 Network)
2. 📁 $HOME/.vscode/extensions/          ➔ Auto-syncs desktop VS Code installed extensions
3. 🌐 download_url in profile YAML       ➔ Downloads from Artifactory/Mirror & caches
4. 🌐 code-server --install-extension    ➔ Queries configured marketplace
```

- **Oracle SQL Developer:** `oracle.sql-developer-for-vscode.vsix`
- **Google Antigravity:** `antigravity.vsix`
- **GitHub Actions & Red Hat YAML:** Visual workflow and schema diagnostics.
