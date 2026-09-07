[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🗄️ Andmebaasi Profiilid (`config/profiles/databases/`)

See kataloog sisaldab domeenipõhiselt isoleeritud YAML profiile **Oracle andmebaasi konteineritele** (Standard 23ai Free, Autonomous ADB Free, Gvenzl 23c).

## 📂 Andmebaasi Profiilide Maatriks

| Profiili Fail | Kirjeldus | DB Tüüp | Wallet Nõutud | Kasutusvaldkond |
| :--- | :--- | :--- | :--- | :--- |
| **`db-alise-oracle.yaml`** | Ärirakenduste põhibaasi ametlik Oracle 23ai Free profiil | `standard` | Jah | Ärirakenduste põhibaasi LIS |
| **`db-proxy-oracle.yaml`** | APEX Proxy ja SSO turvavärav ametlikul Oracle 23ai Free | `standard` | Jah | APEX Proxy ja SSO lüüs |
| **`db-proxy-standalone.yaml`** | Eraldiseisev APEX Proxy isoleeritud pordil 1537 | `standard` | Jah | Spetsiaalne SSO värav |
| **`db-gvenzl.yaml`** | Gerald Venzl 23c kogukonnamootor | `standard` | Jah | Jõudlustestid ja kiirstart |
| **`db-adb.yaml`** | Autonoomse pilvebaasi simulatsioon | `adb` | Jah | Pilveühendus mTLS walletiga |
| **`db-publisher-oracle.yaml`** | Spetsiaalne Analytics Publisher repositooriumi DB | `standard` | Jah | Publisher RCU metaandmed |
| **`db-forms-oracle.yaml`** | Spetsiaalne Oracle Forms 14c repositooriumi DB | `standard` | Jah | Forms RCU metaandmed |

## ⚙️ Konfiguratsioon Blueprintides
Blueprindid viitavad profiilidele positiivse seosena ilma koodi risustamata:
```bash
DB_ALISE=db-alise-oracle
DB_PROXY=db-proxy-oracle
```
