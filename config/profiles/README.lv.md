[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🗄️ Pakalpojumu un datubāzu profilu matrica (`config/profiles/`)

Šajā direktorijā atrodas izolēti YAML profili, ko izmanto **Dinamiskais Profilu Dzinējs** (`load-profile.sh`, `apply-profile-users.sh`, `create-wallet.sh`, `register-connections.sh`).

## 📂 Aktīvās Apakšdirektorijas
* **`config/profiles/databases/`**: Oracle datubāzu profili (`db-proxy-oracle.yaml`, `db-alise-oracle.yaml`, `db-proxy-standalone.yaml`, `db-gvenzl.yaml`, `db-adb.yaml`, `db-publisher-oracle.yaml`, `db-forms-oracle.yaml`).
* **`config/profiles/ords/`**: ORDS vārtejas profili (`ords-standard.yaml`, `ords-standalone.yaml`).
* **`config/profiles/web-ide/`**: Web IDE profili (`web-ide-standard.yaml`).
* **`config/profiles/publisher/`**: Analytics Publisher profili (`publisher-standard.yaml`, `publisher-designer.yaml`).
* **`config/profiles/forms/`**: Oracle Forms 14c profili (`forms-standard.yaml`).
* **`config/profiles/forms-publisher/`**: Apvienotie WebLogic profili (`forms-publisher-unified.yaml`).

## 🗄️ Datubāzu Profilu un portu karte

| Profila Fails | Ražotājs | DB Ports | Blueprints | Galvenās Iezīmes |
| :--- | :--- | :---: | :--- | :--- |
| **`db-publisher-oracle.yaml`** | Oficiālais Oracle | **1531** | BP 5, BP 7 | RCU repozitorija datubāze Analytics Publisher. |
| **`db-proxy-oracle.yaml`** | Oficiālais Oracle | **1532** | BP 0 (Noklusējums) | APEX Proxy, SSO vārteja un REST. |
| **`db-alise-oracle.yaml`** | Oficiālais Oracle | **1533** | BP 1 | Pamata biznesa datubāze, PL/SQL un APEX 26.1. |
| **`db-forms-oracle.yaml`** | Oficiālais Oracle | **1534** | BP 6 | Oracle Forms 14c RCU un lietotņu datubāze. |
| **`db-gvenzl.yaml`** | Gerald Venzl | **1535** | BP 3 | Kopienas attēls veiktspējas salīdzinājumiem. |
| **`db-adb.yaml`** | Autonomous DB | **1536** | BP 4 | Autonomous Database Cloud ar mTLS maku. |
| **`db-proxy-standalone.yaml`** | Oficiālais Oracle | **1537** | BP 2 | Atsevišķa APEX Proxy un SSO vārteja. |
