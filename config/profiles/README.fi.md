[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🗄️ Palvelu- ja tietokantaprofiilien matriisi (`config/profiles/`)

Tämä hakemisto sisältää YAML-profiilit, joita **Dynaaminen Profiilimoottori** käyttää (`load-profile.sh`, `apply-profile-users.sh`, `create-wallet.sh`, `register-connections.sh`).

## 📂 Aktiiviset alihakemistot
* **`config/profiles/databases/`**: Oracle Database -profiilit (`db-proxy-oracle.yaml`, `db-alise-oracle.yaml`, `db-proxy-standalone.yaml`, `db-gvenzl.yaml`, `db-adb.yaml`, `db-publisher-oracle.yaml`, `db-forms-oracle.yaml`).
* **`config/profiles/ords/`**: ORDS-yhdyskäytävän profiilit (`ords-standard.yaml`, `ords-standalone.yaml`).
* **`config/profiles/web-ide/`**: Web-IDE-profiilit (`web-ide-standard.yaml`).
* **`config/profiles/publisher/`**: Analytics Publisher -profiilit (`publisher-standard.yaml`, `publisher-designer.yaml`).
* **`config/profiles/forms/`**: Oracle Forms 14c -profiilit (`forms-standard.yaml`).
* **`config/profiles/forms-publisher/`**: Yhdistetyt WebLogic-profiilit (`forms-publisher-unified.yaml`).

## 🗄️ Tietokantaprofiilit ja porttikartta

| Profiilitiedosto | Valmistaja | DB-portti | Blueprintit | Ominaisuudet |
| :--- | :--- | :---: | :--- | :--- |
| **`db-publisher-oracle.yaml`** | Virallinen Oracle | **1531** | BP 5, BP 7 | RCU-metatietokanta Analytics Publisherille. |
| **`db-proxy-oracle.yaml`** | Virallinen Oracle | **1532** | BP 0 (Oletus) | APEX Proxy, SSO-yhdyskäytävä ja REST. |
| **`db-alise-oracle.yaml`** | Virallinen Oracle | **1533** | BP 1 | Pääliiketoimintatietokanta, PL/SQL ja APEX 26.1. |
| **`db-forms-oracle.yaml`** | Virallinen Oracle | **1534** | BP 6 | Oracle Forms 14c RCU- ja sovellustietokanta. |
| **`db-gvenzl.yaml`** | Gerald Venzl | **1535** | BP 3 | Yhteisökuva suorituskykyvertailuihin. |
| **`db-adb.yaml`** | Autonomous DB | **1536** | BP 4 | Autonomous Database Cloud mTLS-lompakolla. |
| **`db-proxy-standalone.yaml`** | Virallinen Oracle | **1537** | BP 2 | Erillinen APEX Proxy ja SSO -kontti. |
