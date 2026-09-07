# 💻 Web IDE Service Profiles (`config/profiles/web-ide/`)

This directory contains domain-isolated YAML profiles for configuring the **Containerized Web IDE (`code-server`)** service.

---

## 📂 Consolidated Web IDE Profiles Matrix

| Profile Filename | Profile ID | Description | Included Tools & Extensions | Default in Blueprints |
| :--- | :--- | :--- | :--- | :--- |
| **`web-ide-standard.yaml`** | `web-ide-standard` | **🌟 Maximum Feature-Rich Enterprise Workstation (Default)** | Google Antigravity AI, Oracle SQL Developer, Microsoft Python Suite (Pylance + Debugger + pytest), GitHub Actions, act runner, actionlint, yamllint, gh CLI, SQLcl, OpenJDK 21, auto `.sql` binding | **BP 4**, BP 11, BP 20, BP 21, BP 22, BP 23, BP 24, BP 30, BP 31 |
| **`web-ide-minimal.yaml`** | `web-ide-minimal` | **Lightweight VS Code Environment** | Pure `code-server` with OpenJDK 21 without heavy extensions | Optional (low RAM / basic) |
| **`web-ide-disabled.yaml`** | `web-ide-disabled` | **Service Disabled** | Web IDE container disabled (`enabled: false`) | BP 1, BP 2, BP 3, BP 5, BP 6, BP 7, BP 10 |

---

## ⚙️ Configuration in `.env`

To select an active Web IDE profile, set `WEB_IDE_PROFILE` in your `.env` file:

```bash
# Default Enterprise Workstation with all features (Blueprint 4 default):
WEB_IDE_PROFILE=web-ide-standard

# Or lightweight minimal mode:
WEB_IDE_PROFILE=web-ide-minimal

# Or disabled:
WEB_IDE_PROFILE=web-ide-disabled
```

---

## 🛠️ YAML Schema Structure

Profiles allow full customization of enabled tools, download URLs, and VS Code extensions:

```yaml
web_ide:
  enabled: true
  container_name: web-ide-dev
  container_image: lscr.io/linuxserver/code-server:latest

  # Dynamic CLI Tools
  tools:
    github_cli:
      enabled: true
    act_cli:
      enabled: true
    antigravity:
      enabled: false

  # Dynamic VS Code Extensions
  extensions:
    - id: "github.vscode-github-actions"
      enabled: true
```
