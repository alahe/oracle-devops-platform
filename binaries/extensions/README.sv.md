[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🧩 VS Code Tilläggscache (`binaries/extensions/`)

Denna katalog fungerar som **Nivå 1 offline-cache** för VS Code `.vsix`-tillägg.

---

## 4-Nivåers Hierarki för Tilläggshantering

```
1. 📁 binaries/extensions/*.vsix         ➔ Lokal offline-cache (Högsta prioritet)
2. 📁 $HOME/.vscode/extensions/          ➔ Synkroniserar lokala VS Code-tillägg
3. 🌐 download_url i profil-YAML         ➔ Hämtar från Artifactory-spegel
4. 🌐 code-server --install-extension    ➔ Söker på marknadsplats
```
