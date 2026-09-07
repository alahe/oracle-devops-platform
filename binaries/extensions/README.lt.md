[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🧩 VS Code Plėtinių Talpykla (`binaries/extensions/`)

Šis katalogas veikia kaip **1 lygio autonominė talpykla** VS Code `.vsix` plėtinių paketams.

---

## 4 Lygių Plėtinių Hierarchija

```
1. 📁 binaries/extensions/*.vsix         ➔ Vietinė autonominė talpykla (Aukščiausias prioritetas)
2. 📁 $HOME/.vscode/extensions/          ➔ Sinchronizuoja darbalaukio VS Code plėtinius
3. 🌐 download_url profilio YAML         ➔ Atsisiunčia iš Artifactory veidrodžio
4. 🌐 code-server --install-extension    ➔ Užklausia plėtinių prekyvietę
```
