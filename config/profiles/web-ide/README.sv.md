[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 💻 Profiler för web IDE (`config/profiles/web-ide/`)

Denna katalog innehåller YAML-profiler för **Web IDE (`code-server`)**.

## 📂 Matris för web ide-profiler

| Profilfil | Profil-ID | Beskrivning | Verktyg och Tillägg | Standard i Blueprints |
| :--- | :--- | :--- | :--- | :--- |
| **`web-ide-standard.yaml`** | `web-ide-standard` | **🌟 Komplett Företagsarbetsstation (Standard)** | Google Antigravity AI, Oracle SQL Developer, Python Suite, GitHub Actions, act runner, gh CLI, SQLcl, OpenJDK 21 | **BP 8** |
| **`web-ide-minimal.yaml`** | `web-ide-minimal` | **Lättvikts VS Code-miljö** | Ren `code-server` och OpenJDK 21 | Valfri (lågt RAM) |
| **`web-ide-disabled.yaml`** | `web-ide-disabled` | **Tjänst Inaktiverad** | Web IDE inaktiverad (`enabled: false`) | Fristående DB-ritningar |
