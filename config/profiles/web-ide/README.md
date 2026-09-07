[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 💻 Web IDE Service Profiles (`config/profiles/web-ide/`)

This directory contains domain-isolated YAML profiles for configuring the **Containerized Web IDE (`code-server`)** service.

## 📂 Consolidated Web IDE Profiles Matrix

| Profile Filename | Profile ID | Description | Included Tools & Extensions | Default in Blueprints |
| :--- | :--- | :--- | :--- | :--- |
| **`web-ide-standard.yaml`** | `web-ide-standard` | **🌟 Feature-Rich Enterprise Workstation (Default)** | Google Antigravity AI, Oracle SQL Developer, Microsoft Python Suite, GitHub Actions, act runner, actionlint, yamllint, gh CLI, SQLcl, OpenJDK 21 | **BP 8** |
| **`web-ide-minimal.yaml`** | `web-ide-minimal` | **Lightweight VS Code Environment** | Pure `code-server` with OpenJDK 21 without heavy extensions | Optional (low RAM) |
| **`web-ide-disabled.yaml`** | `web-ide-disabled` | **Service Disabled** | Web IDE container disabled (`enabled: false`) | Standalone DB Blueprints |

## ⚙️ Configuration in Blueprints
```bash
WEB_IDE_PROFILE=web-ide-standard
```
