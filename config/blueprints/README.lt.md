[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🏗️ Architektūrinių Šablonų (Blueprints) Katalogas (0 .. 11)

Šis katalogas apibrėžia **12 kanoninių modulinių architektūrinių šablonų**:

---

## 📊 12 Architektūrinių Šablonų Matrica

| ID | Blueprint Pavadinimas & Failas | Duomenų Bazės Profilis & Prievadas | Paslaugų Profiliai & Prievadai | Konteineriai | Aprašymas |
| :---: | :--- | :--- | :--- | :--- | :--- |
| **0** | [`.env.0-default-proxy-ords`](.env.0-default-proxy-ords) *(NUMATYTASIS)* | `db-proxy-oracle.yaml` (:1532) | *(ORDS :8088/8448)* | `db-proxy`, `app-ords` | **Kanoninis sistemos numatytasis.** Proxy DB, APEX 26.1, SSO ir ORDS. |
| **1** | [`.env.1-standalone-alise-db`](.env.1-standalone-alise-db) | `db-alise-oracle.yaml` (:1533) | *(ORDS :8088/8448)* | `db-alise`, `app-ords` | Pagrindinė verslo duomenų bazė, PL/SQL branduolys, APEX ir ORDS. |
| **2** | [`.env.2-standalone-proxy-db`](.env.2-standalone-proxy-db) | `db-proxy-standalone.yaml` (:1537) | *(ORDS :8088/8448)* | `db-proxy-standalone` | Atskira Proxy DB ir SSO vartai specialiame 1537 prievade. |
| **3** | [`.env.3-standalone-gvenzl-db`](.env.3-standalone-gvenzl-db) | `db-gvenzl.yaml` (:1535) | *(ORDS :8088/8448)* | `db-gvenzl`, `app-ords` | Gerald Venzl bendruomenės variklis našumo testams. |
| **4** | [`.env.4-standalone-autonomous-db`](.env.4-standalone-autonomous-db) | `db-adb.yaml` (:1536) | `ords-standard.yaml` (:8088/8448) | `db-adb`, `app-ords` | Oracle Autonomous Database debesijos modeliavimas su mTLS. |
| **5** | [`.env.5-standalone-publisher`](.env.5-standalone-publisher) | `db-publisher-oracle.yaml` (:1531) | `publisher-standard.yaml` (:9502) | `db-publisher`, `app-publisher` | Atskiras Analytics Publisher 2025 ir speciali RCU DB. |
| **6** | [`.env.6-standalone-forms`](.env.6-standalone-forms) | `db-forms-oracle.yaml` (:1534) | `forms-standard.yaml` (:9001, :6082) | `db-forms`, `app-forms` | Atskiras Oracle Forms 14c ir noVNC Forms Builder. |
| **7** | [`.env.7-consolidated-forms-publisher`](.env.7-consolidated-forms-publisher) | `db-publisher-oracle.yaml` (:1531) | `forms-publisher-unified.yaml` (:9001/9502/6082) | `db-publisher`, `app-forms-publisher` | Suvienytas Forms 14c ir Publisher bendrame WebLogic domene. |
| **8** | [`.env.8-standalone-web-ide`](.env.8-standalone-web-ide) | - *(Zero DB)* | `web-ide-standard.yaml` (:8090/8449/8091) | `web-ide-dev` | **⚠️ Testuojama ir tobulinama:** VS Code žiniatinklio serveris ir SQL Developer veikia. Artifactory konfigūracija sprendžiama. |
| **9** | [`.env.9-standalone-publisher-designer`](.env.9-standalone-publisher-designer) | - *(Zero DB)* | `publisher-designer-standard.yaml` (:6083 noVNC) | `app-publisher-designer` | **⚠️ Testuojama ir tobulinama:** noVNC konteineris pasileidžia. MS Word ir BIP Template Builder integracija tobulinama. |
| **10** | [`.env.10-remote-ords`](.env.10-remote-ords) | `MAIN_DB_PROFILE=NONE` | `ords-standalone.yaml` (:8088/8448) | `app-ords` | **⚠️ Testuojama ir tobulinama:** Atskiras ORDS konteineris pasileidžia. Maršrutizavimas į nuotolines DB tobulinamas. |
| **11** | [`.env.11-remote-publisher`](.env.11-remote-publisher) | `MAIN_DB_PROFILE=NONE` | `publisher-standard.yaml` (:9502/9503) | `app-publisher` | **⚠️ Testuojama ir tobulinama:** Publisher konteineris pasileidžia. Ataskaitų generavimas nuotolinėms DB tobulinamas. |
