[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🏗️ Arkkitehtuurimallien (Blueprints) Luettelo (0 .. 11)

Tämä hakemisto sisältää **12 kanonista modulaarista arkkitehtuurimallia**, jotka kattavat koko yritystason alustan:

---

## 📊 12 Arkkitehtuurimallin Matriisi

| ID | Blueprint Nimi & Tiedosto | Tietokantaprofiili & Portti | Palveluprofiilit & Portit | Kontit | Kuvaus |
| :---: | :--- | :--- | :--- | :--- | :--- |
| **0** | [`.env.0-default-proxy-ords`](.env.0-default-proxy-ords) *(OLETUS)* | `db-proxy-oracle.yaml` (:1532) | *(ORDS :8088/8448)* | `db-proxy`, `app-ords` | **Kanoninen järjestelmän oletus.** Proxy DB, APEX 26.1, SSO ja ORDS. |
| **1** | [`.env.1-standalone-alise-db`](.env.1-standalone-alise-db) | `db-alise-oracle.yaml` (:1533) | *(ORDS :8088/8448)* | `db-alise`, `app-ords` | Ensisijainen liiketoimintatietokanta, PL/SQL-ydin, APEX & ORDS. |
| **2** | [`.env.2-standalone-proxy-db`](.env.2-standalone-proxy-db) | `db-proxy-standalone.yaml` (:1537) | *(ORDS :8088/8448)* | `db-proxy-standalone` | Erillinen Proxy DB ja SSO-yhdyskäytävä portissa 1537. |
| **3** | [`.env.3-standalone-gvenzl-db`](.env.3-standalone-gvenzl-db) | `db-gvenzl.yaml` (:1535) | *(ORDS :8088/8448)* | `db-gvenzl`, `app-ords` | Gerald Venzl -yhteisökuva suorituskykytesteihin. |
| **4** | [`.env.4-standalone-autonomous-db`](.env.4-standalone-autonomous-db) | `db-adb.yaml` (:1536) | `ords-standard.yaml` (:8088/8448) | `db-adb`, `app-ords` | Oracle Autonomous Database -pilvisimulaatio mTLS- ja Dev Hub -tuella. |
| **5** | [`.env.5-standalone-publisher`](.env.5-standalone-publisher) | `db-publisher-oracle.yaml` (:1531) | `publisher-standard.yaml` (:9502) | `db-publisher`, `app-publisher` | Erillinen Analytics Publisher 2025 ja oma RCU DB. |
| **6** | [`.env.6-standalone-forms`](.env.6-standalone-forms) | `db-forms-oracle.yaml` (:1534) | `forms-standard.yaml` (:9001, :6082) | `db-forms`, `app-forms` | Erillinen Oracle Forms 14c ja noVNC Forms Builder. |
| **7** | [`.env.7-consolidated-forms-publisher`](.env.7-consolidated-forms-publisher) | `db-publisher-oracle.yaml` (:1531) | `forms-publisher-unified.yaml` (:9001/9502/6082) | `db-publisher`, `app-forms-publisher` | Yhdistetty Forms 14c ja Publisher samassa WebLogic-ympäristössä. |
| **8** | [`.env.8-standalone-web-ide`](.env.8-standalone-web-ide) | - *(Zero DB)* | `web-ide-standard.yaml` (:8090/8449/8091) | `web-ide-dev` | **⚠️ Testauksessa ja kehitteillä:** VS Code -verkkopalvelin ja SQL Developer toimivat. Artifactory-peilikonfiguraatio on ratkaisematta. |
| **9** | [`.env.9-standalone-publisher-designer`](.env.9-standalone-publisher-designer) | - *(Zero DB)* | `publisher-designer-standard.yaml` (:6083 noVNC) | `app-publisher-designer` | **⚠️ Testauksessa ja kehitteillä:** noVNC-kontti käynnistyy. MS Word ja BIP Template Builder -integraatio on kehityksessä. |
| **10** | [`.env.10-remote-ords`](.env.10-remote-ords) | `MAIN_DB_PROFILE=NONE` | `ords-standalone.yaml` (:8088/8448) | `app-ords` | **⚠️ Testauksessa ja kehitteillä:** Erillinen ORDS-kontti käynnistyy. Reititys etätietokantoihin on kehitteillä. |
| **11** | [`.env.11-remote-publisher`](.env.11-remote-publisher) | `MAIN_DB_PROFILE=NONE` | `publisher-standard.yaml` (:9502/9503) | `app-publisher` | **⚠️ Testauksessa ja kehitteillä:** Publisher-kontti käynnistyy. Raportointi etätietokantoja vasten on kehitteillä. |
