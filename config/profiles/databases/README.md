# 🗄️ Database Profiles (`config/profiles/databases/`)

This directory contains domain-isolated YAML profiles for configuring **Oracle Database containers** (Standard 23ai Free, Autonomous ADB Free, Gvenzl 23c).

---

## 📂 Database Profiles Matrix

| Profile Filename | Description | DB Type | Wallet Required | Use Case |
| :--- | :--- | :--- | :--- | :--- |
| **`db-lis-oracle.yaml`** | Primary Application DB on Official Oracle Free DB 23ai/26ai | `standard` | Yes | Primary LIS Application |
| **`db-lis-adb.yaml`** | Primary Application DB on Autonomous DB Free | `adb` | Yes | Primary LIS Cloud Emulation |
| **`db-proxy-oracle.yaml`** | APEX Outbound Proxy DB on Official Oracle Free DB 23ai | `standard` | Yes | APEX Outbound Proxy |
| **`db-proxy-adb.yaml`** | APEX Proxy DB on Autonomous DB Free | `adb` | Yes | APEX Proxy on ADB |
| **`db-proxy-gvenzl.yaml`** | APEX Proxy DB on Gvenzl 23c Faststart | `standard` | Yes | APEX Proxy Lightweight |
| **`db-infra-gvenzl.yaml`** | Infrastructure DB for Publisher & Forms (RCU) on Gvenzl | `standard` | Yes | App Infra & Publisher RCU |
| **`db-publisher-oracle.yaml`** | Analytics Publisher Database on Official Oracle Free | `standard` | Yes | Analytics Publisher Dedicated |
| **`db-publisher-gvenzl.yaml`** | Analytics Publisher Database on Gvenzl 23c Faststart | `standard` | Yes | Analytics Publisher Lightweight |
| **`db-cicd.yaml`** | Ephemeral DB for CI/CD Automated Testing | `standard` | No | CI/CD Testing |

---

## ⚙️ Configuration in `.env`

Map active database instances in `.env` using `<NAME>_DB=<profile-name>`, `DB_<NAME>=<profile-name>`, or `<NAME>_PROXY=<profile-name>`:

```bash
# Primary Application Database Container
DB_LIS=db-lis-oracle
# DB_PROXY=db-proxy-oracle
# DB_PUBLISHER=db-publisher-gvenzl
```
