[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🏗️ Arhitektūras Paraugu (Blueprints) Katalogs (0 .. 11)

Šis katalogs definē **12 kanoniskos modulāros arhitektūras paraugus**:

---

## 📊 12 Arhitektūras Paraugu Matrica

| ID | Blueprint Nosaukums & Fails | Datu Bāzes Profils & Ports | Pakalpojumu Profili & Porti | Konteineri | Apraksts |
| :---: | :--- | :--- | :--- | :--- | :--- |
| **0** | [`.env.0-default-proxy-ords`](.env.0-default-proxy-ords) *(NOKLUSĒJUMS)* | `db-proxy-oracle.yaml` (:1532) | *(ORDS :8088/8448)* | `db-proxy`, `app-ords` | **Kanoniskais sistēmas noklusējums.** Proxy DB, APEX 26.1, SSO un ORDS. |
| **1** | [`.env.1-standalone-alise-db`](.env.1-standalone-alise-db) | `db-alise-oracle.yaml` (:1533) | *(ORDS :8088/8448)* | `db-alise`, `app-ords` | Galvenā biznesa datubāze, PL/SQL kodols, APEX & ORDS. |
| **2** | [`.env.2-standalone-proxy-db`](.env.2-standalone-proxy-db) | `db-proxy-standalone.yaml` (:1537) | *(ORDS :8088/8448)* | `db-proxy-standalone` | Atsevišķa Proxy DB un SSO vārteja uz porta 1537. |
| **3** | [`.env.3-standalone-gvenzl-db`](.env.3-standalone-gvenzl-db) | `db-gvenzl.yaml` (:1535) | *(ORDS :8088/8448)* | `db-gvenzl`, `app-ords` | Gerald Venzl kopienas dzinējs veiktspējas testiem. |
| **4** | [`.env.4-standalone-autonomous-db`](.env.4-standalone-autonomous-db) | `db-adb.yaml` (:1536) | `ords-standard.yaml` (:8088/8448) | `db-adb`, `app-ords` | Oracle Autonomous Database mākoņa simulācija ar mTLS. |
| **5** | [`.env.5-standalone-publisher`](.env.5-standalone-publisher) | `db-publisher-oracle.yaml` (:1531) | `publisher-standard.yaml` (:9502) | `db-publisher`, `app-publisher` | Atsevišķs Analytics Publisher 2025 un veltīta RCU DB. |
| **6** | [`.env.6-standalone-forms`](.env.6-standalone-forms) | `db-forms-oracle.yaml` (:1534) | `forms-standard.yaml` (:9001, :6082) | `db-forms`, `app-forms` | Atsevišķs Oracle Forms 14c un noVNC Forms Builder. |
| **7** | [`.env.7-consolidated-forms-publisher`](.env.7-consolidated-forms-publisher) | `db-publisher-oracle.yaml` (:1531) | `forms-publisher-unified.yaml` (:9001/9502/6082) | `db-publisher`, `app-forms-publisher` | Apvienots Forms 14c un Publisher vienā WebLogic domēnā. |
| **8** | [`.env.8-standalone-web-ide`](.env.8-standalone-web-ide) | - *(Zero DB)* | `web-ide-standard.yaml` (:8090/8449/8091) | `web-ide-dev` | **⚠️ Testēšanā un izstrādē:** VS Code tīmekļa serveris un SQL Developer darbojas. Artifactory konfigurācija tiek risināta. |
| **9** | [`.env.9-standalone-publisher-designer`](.env.9-standalone-publisher-designer) | - *(Zero DB)* | `publisher-designer-standard.yaml` (:6083 noVNC) | `app-publisher-designer` | **⚠️ Testēšanā un izstrādē:** noVNC konteiners startējas. MS Word un BIP Template Builder integrācija tiek pilnveidota. |
| **10** | [`.env.10-remote-ords`](.env.10-remote-ords) | `MAIN_DB_PROFILE=NONE` | `ords-standalone.yaml` (:8088/8448) | `app-ords` | **⚠️ Testēšanā un izstrādē:** Atsevišķs ORDS konteiners startējas. Maršrutēšana uz attālajām datubāzēm tiek pilnveidota. |
| **11** | [`.env.11-remote-publisher`](.env.11-remote-publisher) | `MAIN_DB_PROFILE=NONE` | `publisher-standard.yaml` (:9502/9503) | `app-publisher` | **⚠️ Testēšanā un izstrādē:** Publisher konteiners startējas. Atskaišu ģenerēšana attālām datubāzēm tiek pilnveidota. |
