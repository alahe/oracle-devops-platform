[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 💻 Web IDE pakalpojuma profilu katalogs (`config/profiles/web-ide/`)

Šajā direktorijā atrodas YAML profili **Web IDE (`code-server`)** pakalpojumam.

## 📂 Web IDE profilu matrica

| Profila Fails | Profila ID | Apraksts | Iekļautie Rīki | Noklusējums Blueprints |
| :--- | :--- | :--- | :--- | :--- |
| **`web-ide-standard.yaml`** | `web-ide-standard` | **🌟 Pilnvērtīga Darbstacija (Noklusējums)** | Google Antigravity AI, Oracle SQL Developer, Python Suite, GitHub Actions, act runner, gh CLI, SQLcl, OpenJDK 21 | **BP 8** |
| **`web-ide-minimal.yaml`** | `web-ide-minimal` | **Viegla VS Code Vide** | Tīrs `code-server` un OpenJDK 21 | Neobligāts (mazs RAM) |
| **`web-ide-disabled.yaml`** | `web-ide-disabled` | **Pakalpojums Izslēgts** | Web IDE atspējots (`enabled: false`) | Atsevišķie DB rasējumi |
