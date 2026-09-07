[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🗄️ Matris för Tjänste- och databasprofiler (`config/profiles/`)

Denna katalog innehåller domänisolerade YAML-profiler som används av plattformens **Dynamiska Profilhanterare** (`load-profile.sh`, `apply-profile-users.sh`, `create-wallet.sh`, `register-connections.sh`).

## 📂 Aktiva underkataloger
* **`config/profiles/databases/`**: Oracle Database-profiler (`db-proxy-oracle.yaml`, `db-alise-oracle.yaml`, `db-proxy-standalone.yaml`, `db-gvenzl.yaml`, `db-adb.yaml`, `db-publisher-oracle.yaml`, `db-forms-oracle.yaml`).
* **`config/profiles/ords/`**: ORDS Gateway-profiler (`ords-standard.yaml`, `ords-standalone.yaml`).
* **`config/profiles/web-ide/`**: Web IDE-profiler (`web-ide-standard.yaml`).
* **`config/profiles/publisher/`**: Analytics Publisher-profiler (`publisher-standard.yaml`, `publisher-designer.yaml`).
* **`config/profiles/forms/`**: Oracle Forms 14c-profiler (`forms-standard.yaml`).
* **`config/profiles/forms-publisher/`**: Konsoliderade FMW-profiler (`forms-publisher-unified.yaml`).

## 🗄️ Databasprofiler och portkarta

| Profilfil | Tillverkare | DB-port | Blueprints | Nyckelfunktioner |
| :--- | :--- | :---: | :--- | :--- |
| **`db-publisher-oracle.yaml`** | Officiell Oracle | **1531** | BP 5, BP 7 | RCU-metadatabas för Analytics Publisher. |
| **`db-proxy-oracle.yaml`** | Officiell Oracle | **1532** | BP 0 (Standard) | APEX Proxy, SSO Gateway och REST. |
| **`db-alise-oracle.yaml`** | Officiell Oracle | **1533** | BP 1 | Primär affärsdatabas, PL/SQL och APEX 26.1. |
| **`db-forms-oracle.yaml`** | Officiell Oracle | **1534** | BP 6 | Oracle Forms 14c RCU- och applikationsdatabas. |
| **`db-gvenzl.yaml`** | Gerald Venzl | **1535** | BP 3 | Community-avbildning för prestandatester. |
| **`db-adb.yaml`** | Autonomous DB | **1536** | BP 4 | Autonomous Database Cloud med mTLS-plånbok. |
| **`db-proxy-standalone.yaml`** | Officiell Oracle | **1537** | BP 2 | Dedikerad fristående APEX Proxy & SSO-gateway. |
