[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🏗️ Katalog över Arkitekturritningar (Blueprints 0 .. 11)

Denna katalog definierar **12 kanoniska modulära arkitekturritningar** för hela företagsplattformen:

---

## 📊 12 Arkitekturritningar Matris

| ID | Blueprint Namn & Fil | Databasprofil & Port | Tjänsteprofiler & Portar | Behållare | Beskrivning |
| :---: | :--- | :--- | :--- | :--- | :--- |
| **0** | [`.env.0-default-proxy-ords`](.env.0-default-proxy-ords) *(STANDARD)* | `db-proxy-oracle.yaml` (:1532) | *(ORDS :8088/8448)* | `db-proxy`, `app-ords` | **Kanonisk systemstandard.** Proxy DB, APEX 26.1, SSO och ORDS. |
| **1** | [`.env.1-standalone-alise-db`](.env.1-standalone-alise-db) | `db-alise-oracle.yaml` (:1533) | *(ORDS :8088/8448)* | `db-alise`, `app-ords` | Primär affärsdatabas, PL/SQL-kärna, APEX & ORDS. |
| **2** | [`.env.2-standalone-proxy-db`](.env.2-standalone-proxy-db) | `db-proxy-standalone.yaml` (:1537) | *(ORDS :8088/8448)* | `db-proxy-standalone` | Fristående Proxy DB och SSO-gateway på port 1537. |
| **3** | [`.env.3-standalone-gvenzl-db`](.env.3-standalone-gvenzl-db) | `db-gvenzl.yaml` (:1535) | *(ORDS :8088/8448)* | `db-gvenzl`, `app-ords` | Gerald Venzl community-avbildning för prestandatester. |
| **4** | [`.env.4-standalone-autonomous-db`](.env.4-standalone-autonomous-db) | `db-adb.yaml` (:1536) | `ords-standard.yaml` (:8088/8448) | `db-adb`, `app-ords` | Oracle Autonomous Database molnsimulering med mTLS. |
| **5** | [`.env.5-standalone-publisher`](.env.5-standalone-publisher) | `db-publisher-oracle.yaml` (:1531) | `publisher-standard.yaml` (:9502) | `db-publisher`, `app-publisher` | Fristående Analytics Publisher 2025 och dedikerad RCU DB. |
| **6** | [`.env.6-standalone-forms`](.env.6-standalone-forms) | `db-forms-oracle.yaml` (:1534) | `forms-standard.yaml` (:9001, :6082) | `db-forms`, `app-forms` | Fristående Oracle Forms 14c och noVNC Forms Builder. |
| **7** | [`.env.7-consolidated-forms-publisher`](.env.7-consolidated-forms-publisher) | `db-publisher-oracle.yaml` (:1531) | `forms-publisher-unified.yaml` (:9001/9502/6082) | `db-publisher`, `app-forms-publisher` | Konsoliderad Forms 14c och Publisher i samma WebLogic-domän. |
| **8** | [`.env.8-standalone-web-ide`](.env.8-standalone-web-ide) | - *(Zero DB)* | `web-ide-standard.yaml` (:8090/8449/8091) | `web-ide-dev` | **⚠️ Under testning och utveckling:** VS Code webbserver och SQL Developer fungerar. Artifactory-spegelkonfigurationen åtgärdas. |
| **9** | [`.env.9-standalone-publisher-designer`](.env.9-standalone-publisher-designer) | - *(Zero DB)* | `publisher-designer-standard.yaml` (:6083 noVNC) | `app-publisher-designer` | **⚠️ Under testning och utveckling:** noVNC-behållaren startar. Integrering av MS Word och BIP Template Builder utvecklas. |
| **10** | [`.env.10-remote-ords`](.env.10-remote-ords) | `MAIN_DB_PROFILE=NONE` | `ords-standalone.yaml` (:8088/8448) | `app-ords` | **⚠️ Under testning och utveckling:** Fristående ORDS-behållare startar. Gateway-dirigering mot fjärrdatabaser utvecklas. |
| **11** | [`.env.11-remote-publisher`](.env.11-remote-publisher) | `MAIN_DB_PROFILE=NONE` | `publisher-standard.yaml` (:9502/9503) | `app-publisher` | **⚠️ Under testning och utveckling:** Publisher-behållaren startar. Rapportgenerering mot fjärrdatabaser utvecklas. |
