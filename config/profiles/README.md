# 🗄️ Service & Database Profiles Matrix (`config/profiles/`)

This directory contains domain-isolated YAML profile configurations used by the **Dynamic Profile Engine** (`load-profile.sh`, `apply-profile-users.sh`, `create-wallet.sh`, `register-connections.sh`).

---

## 📂 Subdirectories Architecture

* **[`config/profiles/databases/`](databases/README.md)**: Oracle Database profiles (`proxy-adb-oracle.yaml`, `bizapp-standard-oracle.yaml` etc.).
* **[`config/profiles/web-ide/`](web-ide/README.md)**: Web IDE service profiles (`web-ide-cicd-only.yaml`, `web-ide-cicd-antigravity.yaml`, `web-ide-standard.yaml`, `web-ide-minimal.yaml`, `web-ide-disabled.yaml`).

---

## 🗄️ Pre-Configured Database Profiles (`config/profiles/databases/`)

| Profile Filename | Description | DB Type | Use Case |
| :--- | :--- | :--- | :--- |
| **`proxy-standard-gvenzl.yaml`** | APEX Proxy DB on Gvenzl 23c Faststart | `standard` | APEX Proxy |
| **`proxy-adb-oracle.yaml`** | APEX Proxy DB on Autonomous DB Free | `adb` | APEX Proxy |
| **`proxy-standard-oracle.yaml`** | APEX Proxy DB on Official Oracle Free DB 23ai | `standard` | APEX Proxy |
| **`bizapp-standard-oracle.yaml`** | General Business App DB on Official Oracle Free DB | `standard` | Business App |
| **`bizapp-adb-oracle.yaml`** | General Business App DB on Autonomous DB Free | `adb` | Business App |
| **`appinfra-standard-gvenzl.yaml`** | Infrastructure DB for Publisher & Forms (RCU) | `standard` | App Infra |
| **`cicd-standard-oracle.yaml`** | Ephemeral DB for CI/CD Automated Testing | `standard` | CI/CD |

---

## 👤 Customizing Schemas, Users, and Wallets

You can edit existing YAML profiles or create custom profiles to change schema names, database users, roles, and SEPS Wallet aliases:

```yaml
users:
  - username: sys
    role: SYSDBA
    wallet_alias: DB_APEX_PROXY_SYS
    color: "#E74C3C"

  # Custom Schema Name (e.g., MY_COMPANY_SCHEMA):
  - username: MY_COMPANY_SCHEMA
    role: NORMAL
    wallet_alias: DB_MY_COMPANY_SCHEMA
    color: "#2980B9"

  # Custom Developer Account:
  - username: ALLANLAHE
    role: NORMAL
    ords_enabled: true
    ords_alias: allanlahe
    roles: [DB_DEVELOPER_ROLE]
    wallet_alias: DB_ALLANLAHE
    color: "#F39C12"
```

Refer to [docs/db-profiles-and-topology.md](../../docs/db-profiles-and-topology.md) for full architecture and topology details.
