[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🗄️ Database Profiles (`config/profiles/databases/`)

This directory contains domain-isolated YAML profiles for configuring **Oracle Database containers** (Standard 23ai Free, Autonomous ADB Free, Gvenzl 23c).

## 📂 Database Profiles Matrix

| Profile Filename | Description | DB Type | Wallet Required | Use Case |
| :--- | :--- | :--- | :--- | :--- |
| **`db-alise-oracle.yaml`** | Primary Application DB on Official Oracle Free DB 23ai | `standard` | Yes | Primary LIS Business DB |
| **`db-proxy-oracle.yaml`** | APEX Proxy & SSO Gateway on Official Oracle Free DB 23ai | `standard` | Yes | APEX Proxy & SSO Gateway |
| **`db-proxy-standalone.yaml`** | Standalone APEX Proxy DB on Isolated Port 1537 | `standard` | Yes | Dedicated SSO Gateway |
| **`db-gvenzl.yaml`** | Gerald Venzl 23c Community Engine | `standard` | Yes | Benchmarking & Fast Start |
| **`db-adb.yaml`** | Autonomous Database Cloud Simulation | `adb` | Yes | Cloud Wallet mTLS Connectivity |
| **`db-publisher-oracle.yaml`** | Dedicated Analytics Publisher Repository DB | `standard` | Yes | Publisher RCU Metadata |
| **`db-forms-oracle.yaml`** | Dedicated Oracle Forms 14c Repository DB | `standard` | Yes | Forms RCU Metadata |

## ⚙️ Configuration in Blueprints
Blueprints reference database profiles cleanly without hardcoding:
```bash
DB_ALISE=db-alise-oracle
DB_PROXY=db-proxy-oracle
```
