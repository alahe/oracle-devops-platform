# 🗄️ Database Profiles (`config/profiles/databases/`)

This directory contains domain-isolated YAML profiles for configuring **Oracle Database containers** (Standard 23ai Free, Autonomous ADB Free, Gvenzl 23c).

---

## 📂 Database Profiles Matrix

| Profile Filename | Description | DB Type | Wallet Required | Use Case |
| :--- | :--- | :--- | :--- | :--- |
| **`proxy-standard-gvenzl.yaml`** | APEX Proxy DB on Gvenzl 23c Faststart | `standard` | Yes | APEX Proxy |
| **`proxy-adb-oracle.yaml`** | APEX Proxy DB on Autonomous DB Free | `adb` | Yes | APEX Proxy |
| **`proxy-standard-oracle.yaml`** | APEX Proxy DB on Official Oracle Free DB 23ai | `standard` | Yes | APEX Proxy |
| **`bizapp-standard-oracle.yaml`** | General Business App DB on Official Oracle Free DB | `standard` | Yes | Business App |
| **`bizapp-adb-oracle.yaml`** | General Business App DB on Autonomous DB Free | `adb` | Yes | Business App |
| **`appinfra-standard-gvenzl.yaml`** | Infrastructure DB for Publisher & Forms (RCU) | `standard` | Yes | App Infra |
| **`cicd-standard-oracle.yaml`** | Ephemeral DB for CI/CD Automated Testing | `standard` | No | CI/CD Testing |

---

## ⚙️ Configuration in `.env`

Map active database instances in `.env` using `<NAME>_DB=<profile-name>` or `DB_<NAME>=<profile-name>`:

```bash
# Primary APEX Outbound Proxy Database Container
PUB_DB=bizapp-standard-oracle
# DB_PROXY=proxy-adb-oracle
```
