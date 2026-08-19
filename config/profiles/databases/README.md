# 🗄️ Database Profiles (`config/profiles/databases/`)

This directory contains domain-isolated YAML profiles for configuring **Oracle Database containers** (Standard 23ai Free, Autonomous ADB Free, Gvenzl 23c).

---

## 📂 Database Profiles Matrix

| Profile Filename | Description | DB Type | Wallet Required | Use Case |
| :--- | :--- | :--- | :--- | :--- |
| **`app-free.yaml`** | Primary Application DB on Official Oracle Free DB 23ai/26ai | `standard` | Yes | Primary Application |
| **`app-adb.yaml`** | Primary Application DB on Autonomous DB Free | `adb` | Yes | Primary Application |
| **`proxy-free.yaml`** | APEX Proxy DB on Official Oracle Free DB 23ai/26ai | `standard` | Yes | APEX Proxy |
| **`proxy-adb.yaml`** | APEX Proxy DB on Autonomous DB Free | `adb` | Yes | APEX Proxy |
| **`proxy-gvenzl.yaml`** | APEX Proxy DB on Gvenzl 23c Faststart | `standard` | Yes | APEX Proxy |
| **`proxy-ords-standalone.yaml`** | APEX Proxy DB + Dedicated Standalone ORDS (Ports 8085/8445) | `standard` | Yes | Standalone ORDS |
| **`proxy-ords-external.yaml`** | APEX Proxy DB + External Corporate ORDS Server | `standard` | Yes | External Corporate ORDS |
| **`appinfra.yaml`** | Infrastructure DB for Publisher & Forms (RCU) | `standard` | Yes | App Infra |
| **`cicd.yaml`** | Ephemeral DB for CI/CD Automated Testing | `standard` | No | CI/CD Testing |

---

## ⚙️ Configuration in `.env`

Map active database instances in `.env` using `<NAME>_DB=<profile-name>`, `DB_<NAME>=<profile-name>`, or `<NAME>_PROXY=<profile-name>`:

```bash
# Primary Application Database Container
PUB_DB=app-free
# DB_PROXY=proxy-adb
# ords_proxy=proxy-ords-standalone
```
