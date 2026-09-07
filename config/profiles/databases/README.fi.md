[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🗄️ Tietokantaprofiilit (`config/profiles/databases/`)

Tämä hakemisto sisältää eristetyt YAML-profiilit **Oracle Database -konteille** (Standard 23ai Free, Autonomous ADB Free, Gvenzl 23c).

## 📂 Tietokantaprofiilien matriisi

| Profiilitiedosto | Kuvaus | DB-tyyppi | Wallet vaaditaan | Käyttötapaus |
| :--- | :--- | :--- | :--- | :--- |
| **`db-alise-oracle.yaml`** | Pääliiketoimintatietokanta Oracle Free DB 23ai | `standard` | Kyllä | Ensisijainen liiketoiminta-DB |
| **`db-proxy-oracle.yaml`** | APEX Proxy ja SSO -yhdyskäytävä 23ai | `standard` | Kyllä | APEX Proxy ja SSO |
| **`db-proxy-standalone.yaml`** | Erillinen APEX Proxy portissa 1537 | `standard` | Kyllä | Erillinen SSO-portti |
| **`db-gvenzl.yaml`** | Gerald Venzl 23c -yhteisökuva | `standard` | Kyllä | Vertailu ja nopea käynnistys |
| **`db-adb.yaml`** | Autonomous Database Cloud -simulaatio | `adb` | Kyllä | Pilviyhteys mTLS-lompakolla |
| **`db-publisher-oracle.yaml`** | Analytics Publisher RCU -tietokanta | `standard` | Kyllä | Publisher RCU |
| **`db-forms-oracle.yaml`** | Oracle Forms 14c RCU -tietokanta | `standard` | Kyllä | Forms RCU |
