[ 🇬🇧 English ](README.md)

# 🗄️ Service & Database Profiles Matrix (`config/profiles/`)

This directory contains domain-isolated YAML profile configurations used by the **Dynamic Profile Engine** (`load-profile.sh`, `apply-profile-users.sh`, `create-wallet.sh`, `register-connections.sh`).

---

## 📂 Active Profile Subdirectories

* **`config/profiles/databases/`**: Dedicated Oracle Database engine profiles (`db-proxy-oracle.yaml`, `db-alise-oracle.yaml`, `db-proxy-standalone.yaml`, `db-gvenzl.yaml`, `db-adb.yaml`, `db-publisher-oracle.yaml`, `db-forms-oracle.yaml`).
* **`config/profiles/ords/`**: Dedicated ORDS Gateway profiles (`ords-standard.yaml`, `ords-standalone.yaml`).
* **`config/profiles/web-ide/`**: Web IDE service profiles (`web-ide-standard.yaml`).
* **`config/profiles/publisher/`**: Analytics Publisher profiles (`publisher-standard.yaml`, `publisher-designer.yaml`).
* **`config/profiles/forms/`**: Oracle Forms 14c profiles (`forms-standard.yaml`).
* **`config/profiles/forms-publisher/`**: Consolidated Unified FMW profiles (`forms-publisher-unified.yaml`).

---

## 🗄️ Active Database Profiles & Deterministic Port Map

| Profile Filename | Image Vendor | DB Port | Associated Blueprints | Key Features |
| :--- | :--- | :---: | :--- | :--- |
| **`db-publisher-oracle.yaml`** | Official Oracle | **1531** | BP 5, BP 7 | BIPLATFORM & MDS RCU Repository database for Analytics Publisher. |
| **`db-proxy-oracle.yaml`** | Official Oracle | **1532** | BP 0 (Default) | APEX Proxy, SSO Gateway, and public REST services. |
| **`db-alise-oracle.yaml`** | Official Oracle | **1533** | BP 1 | Core Business DB, PL/SQL engine, and APEX 26.1. |
| **`db-forms-oracle.yaml`** | Official Oracle | **1534** | BP 6 | Dedicated Oracle Forms 14c RCU & application backend. |
| **`db-gvenzl.yaml`** | Gerald Venzl | **1535** | BP 3 | Alternate community image engine for benchmarking & fast starts. |
| **`db-adb.yaml`** | Autonomous DB | **1536** | BP 4 | Oracle Autonomous Database Cloud simulation with mTLS cloud wallet. |
| **`db-proxy-standalone.yaml`** | Official Oracle | **1537** | BP 2 | Dedicated Standalone APEX Proxy & SSO Gateway container. |

