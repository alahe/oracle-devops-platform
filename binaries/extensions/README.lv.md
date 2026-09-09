[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🧩 VS Code paplašinājumu kešatmiņa (`binaries/extensions/`)

Šis direktorijs kalpo kā **1. līmeņa bezsaistes kešatmiņa** VS Code `.vsix` paplašinājumu pakotnēm.

---

## 4 Līmeņu Paplašinājumu Hierarhija

```
1. 📁 binaries/extensions/*.vsix         ➔ Lokālā bezsaistes kešatmiņa (Augstākā prioritāte)
2. 📁 $HOME/.vscode/extensions/          ➔ Sinhronizē darbvirsmas VS Code paplašinājumus
3. 🌐 download_url profila YAML          ➔ Lejupielādē no Artifactory spoguļa
4. 🌐 code-server --install-extension    ➔ Vaicā tirgus vietnei
```
