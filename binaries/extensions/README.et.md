[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🧩 VS Code Laienduste Puhver (`binaries/extensions/`)

See kataloog toimib **1. taseme võrguvaba lokaalse puhvrina** VS Code `.vsix` laienduste pakettidele.

---

## 4-Astmeline Laienduste Lahendamise Hierarhia

```
1. 📁 binaries/extensions/*.vsix         ➔ Lokaalne võrguvaba puhver (Kõrgeim prioriteet)
2. 📁 $HOME/.vscode/extensions/          ➔ Sünkroniseerib töölaua VS Code laiendused
3. 🌐 download_url profiili YAML-is      ➔ Laeb alla Artifactory peeglist
4. 🌐 code-server --install-extension    ➔ Pärib konfigureeritud marketplace-ist
```

- **Oracle SQL Developer:** `oracle.sql-developer-for-vscode.vsix`
- **Google Antigravity:** `antigravity.vsix`
- **GitHub Actions & Red Hat YAML:** Töövoogude ja skeemide diagnostika.
