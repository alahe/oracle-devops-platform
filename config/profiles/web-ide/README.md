# 💻 Web IDE Service Profiles (`config/profiles/web-ide/`)

This directory contains domain-isolated YAML profiles for configuring the **Containerized Web IDE (`code-server`)** service.

---

## 📂 Web IDE Profiles Matrix

| Profile Filename | Description | Included Tools & Extensions | Use Case |
| :--- | :--- | :--- | :--- |
| **`web-ide-antigravity-vsix.yaml`** | Google Antigravity AI CLI + Local VSIX Packages | Antigravity AI Assistant, GitHub CLI (`gh`), auto-installs local `.vsix` packages from `binaries/extensions/` | AI + VSIX extensions |
| **`web-ide-standard.yaml`** | Complete Developer Environment | Google Antigravity, SQLcl, Java 21, Liquibase, SQL Developer extension | Full Stack Dev |
| **`web-ide-minimal.yaml`** | Lightweight VS Code | Pure `code-server` without additional tools | Low Memory / Basic |
| **`web-ide-disabled.yaml`** | Service Disabled | Web IDE container disabled (`enabled: false`) | DB Only mode |

---

## ⚙️ Configuration in `.env`

To select an active Web IDE profile, update your `.env` file:

```bash
# Example: Select purely GitHub Actions & CI/CD workflow testing profile
WEB_IDE_PROFILE=web-ide-cicd-only
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
