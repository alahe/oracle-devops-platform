[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 💻 Web IDE teenuse profiilid (`config/profiles/web-ide/`)

See kataloog sisaldab domeenipõhiselt isoleeritud YAML profiile **konteineriseeritud Web IDE (`code-server`)** teenuse seadistamiseks.

## 📂 Konsolideeritud web IDE profiilide maatriks

| Profiili Fail | Profiili ID | Kirjeldus | Kaasatud Tööriistad ja Laiendused | Vaikimisi Blueprintides |
| :--- | :--- | :--- | :--- | :--- |
| **`web-ide-standard.yaml`** | `web-ide-standard` | **🌟 Täielik Ettevõtte Tööjaam (Vaikimisi)** | Google Antigravity AI, Oracle SQL Developer, Python Suite, GitHub Actions, act runner, actionlint, yamllint, gh CLI, SQLcl, OpenJDK 21 | **BP 8** |
| **`web-ide-minimal.yaml`** | `web-ide-minimal` | **Kergekaaluline VS Code Keskkond** | Puhas `code-server` ja OpenJDK 21 ilma raskete laiendusteta | Valikuline (väike RAM) |
| **`web-ide-disabled.yaml`** | `web-ide-disabled` | **Teenus Välja Lülitatud** | Web IDE konteiner deaktiveeritud (`enabled: false`) | Eraldiseisvad DB Blueprintid |

## ⚙️ Konfiguratsioon blueprintides
```bash
WEB_IDE_PROFILE=web-ide-standard
```
