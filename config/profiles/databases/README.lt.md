[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🗄️ Duomenų bazių profiliai (`config/profiles/databases/`)

Šiame kataloge yra izoliuoti YAML profiliai **Oracle duomenų bazių konteineriams** (Standard 23ai Free, Autonomous ADB Free, Gvenzl 23c).

## 📂 Duomenų bazių profilių matrica

| Profilio Failas | Aprašymas | DB Tipas | Wallet Reikalingas | Paskirtis |
| :--- | :--- | :--- | :--- | :--- |
| **`db-alise-oracle.yaml`** | Pagrindinė verslo DB Oracle Free DB 23ai | `standard` | Taip | Pagrindinė verslo DB |
| **`db-proxy-oracle.yaml`** | APEX Proxy ir SSO šliuzas 23ai | `standard` | Taip | APEX Proxy ir SSO |
| **`db-proxy-standalone.yaml`** | Atskira APEX Proxy prievade 1537 | `standard` | Taip | Skirta SSO vartų aplinka |
| **`db-gvenzl.yaml`** | Gerald Venzl 23c bendruomenės variklis | `standard` | Taip | Našumo palyginimas |
| **`db-adb.yaml`** | Autonomous Database debesijos modeliavimas | `adb` | Taip | Ryšys su debesimi mTLS |
| **`db-publisher-oracle.yaml`** | Analytics Publisher RCU duomenų bazė | `standard` | Taip | Publisher RCU |
| **`db-forms-oracle.yaml`** | Oracle Forms 14c RCU duomenų bazė | `standard` | Taip | Forms RCU |
