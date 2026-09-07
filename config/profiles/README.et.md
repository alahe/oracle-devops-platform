[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🗄️ Teenuste ja Andmebaaside Profiilide Maatriks (`config/profiles/`)

See kataloog sisaldab domeenipõhiselt isoleeritud YAML profiile, mida kasutab **Dünaamiline Profiilide Mootor** (`load-profile.sh`, `apply-profile-users.sh`, `create-wallet.sh`, `register-connections.sh`).

## 📂 Aktiivsed Profiilide Alamkataloogid
* **`config/profiles/databases/`**: Oracle andmebaaside profiilid (`db-proxy-oracle.yaml`, `db-alise-oracle.yaml`, `db-proxy-standalone.yaml`, `db-gvenzl.yaml`, `db-adb.yaml`, `db-publisher-oracle.yaml`, `db-forms-oracle.yaml`).
* **`config/profiles/ords/`**: ORDS lüüsi profiilid (`ords-standard.yaml`, `ords-standalone.yaml`).
* **`config/profiles/web-ide/`**: Web IDE arendustöökoha profiilid (`web-ide-standard.yaml`).
* **`config/profiles/publisher/`**: Analytics Publisher profiilid (`publisher-standard.yaml`, `publisher-designer.yaml`).
* **`config/profiles/forms/`**: Oracle Forms 14c profiilid (`forms-standard.yaml`).
* **`config/profiles/forms-publisher/`**: Konsolideeritud ühendatud WebLogic profiilid (`forms-publisher-unified.yaml`).

## 🗄️ Andmebaasi Profiilid ja Deterministlik Portide Kaart

| Profiili Fail | Tõmmise Tootja | DB Port | Seotud Blueprintid | Põhiomadused |
| :--- | :--- | :---: | :--- | :--- |
| **`db-publisher-oracle.yaml`** | Ametlik Oracle | **1531** | BP 5, BP 7 | BIPLATFORM & MDS RCU repositooriumi andmebaas Publisherile. |
| **`db-proxy-oracle.yaml`** | Ametlik Oracle | **1532** | BP 0 (Vaikekäivitus) | APEX Proxy, SSO turvavärav ja avalikud REST teenused. |
| **`db-alise-oracle.yaml`** | Ametlik Oracle | **1533** | BP 1 | Ärirakenduste põhibaas, PL/SQL mootor ja APEX 26.1. |
| **`db-forms-oracle.yaml`** | Ametlik Oracle | **1534** | BP 6 | Oracle Forms 14c RCU ja rakenduste taustabaas. |
| **`db-gvenzl.yaml`** | Gerald Venzl | **1535** | BP 3 | Kogukonnatõmmis jõudlustestideks ja kiireks stardiks. |
| **`db-adb.yaml`** | Autonomous DB | **1536** | BP 4 | Oracle Autonomous Database Cloud simulatsioon mTLS walletiga. |
| **`db-proxy-standalone.yaml`** | Ametlik Oracle | **1537** | BP 2 | Eraldiseisev isoleeritud APEX Proxy ja SSO lüüs. |
