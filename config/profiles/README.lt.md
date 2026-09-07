[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🗄️ Paslaugų ir Duomenų Bazių Profilių Matrica (`config/profiles/`)

Šiame kataloge yra izoliuoti YAML profiliai, kuriuos naudoja **Dinaminis Profilių Variklis** (`load-profile.sh`, `apply-profile-users.sh`, `create-wallet.sh`, `register-connections.sh`).

## 📂 Aktyvūs Pakatalogiai
* **`config/profiles/databases/`**: Oracle duomenų bazių profiliai (`db-proxy-oracle.yaml`, `db-alise-oracle.yaml`, `db-proxy-standalone.yaml`, `db-gvenzl.yaml`, `db-adb.yaml`, `db-publisher-oracle.yaml`, `db-forms-oracle.yaml`).
* **`config/profiles/ords/`**: ORDS šliuzo profiliai (`ords-standard.yaml`, `ords-standalone.yaml`).
* **`config/profiles/web-ide/`**: Web IDE profiliai (`web-ide-standard.yaml`).
* **`config/profiles/publisher/`**: Analytics Publisher profiliai (`publisher-standard.yaml`, `publisher-designer.yaml`).
* **`config/profiles/forms/`**: Oracle Forms 14c profiliai (`forms-standard.yaml`).
* **`config/profiles/forms-publisher/`**: Suvienyti WebLogic profiliai (`forms-publisher-unified.yaml`).

## 🗄️ Duomenų Bazių Profiliai ir Prievadų Žemėlapis

| Profilio Failas | Gamintojas | DB Prievadas | Blueprints | Pagrindinės Savybės |
| :--- | :--- | :---: | :--- | :--- |
| **`db-publisher-oracle.yaml`** | Oficialus Oracle | **1531** | BP 5, BP 7 | RCU saugyklos duomenų bazė Analytics Publisher. |
| **`db-proxy-oracle.yaml`** | Oficialus Oracle | **1532** | BP 0 (Numatytasis) | APEX Proxy, SSO šliuzas ir REST. |
| **`db-alise-oracle.yaml`** | Oficialus Oracle | **1533** | BP 1 | Pagrindinė verslo DB, PL/SQL ir APEX 26.1. |
| **`db-forms-oracle.yaml`** | Oficialus Oracle | **1534** | BP 6 | Oracle Forms 14c RCU ir programų DB. |
| **`db-gvenzl.yaml`** | Gerald Venzl | **1535** | BP 3 | Bendruomenės atvaizdas našumo palyginimui. |
| **`db-adb.yaml`** | Autonomous DB | **1536** | BP 4 | Autonomous Database Cloud su mTLS pinigine. |
| **`db-proxy-standalone.yaml`** | Oficialus Oracle | **1537** | BP 2 | Atskira APEX Proxy ir SSO vartų aplinka. |
