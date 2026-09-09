[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🗄️ Datubāzu profilu katalogs (`config/profiles/databases/`)

Šajā direktorijā atrodas YAML profili **Oracle Database konteineriem** (Standard 23ai Free, Autonomous ADB Free, Gvenzl 23c).

## 📂 Datubāzu Profilu matrica

| Profila Fails | Apraksts | DB Tips | Wallet Nepieciešams | Pielietojums |
| :--- | :--- | :--- | :--- | :--- |
| **`db-alise-oracle.yaml`** | Galvenā biznesa datubāze Oracle Free DB 23ai | `standard` | Jā | Primārā biznesa DB |
| **`db-proxy-oracle.yaml`** | APEX Proxy un SSO vārteja 23ai | `standard` | Jā | APEX Proxy un SSO |
| **`db-proxy-standalone.yaml`** | Atsevišķa APEX Proxy portā 1537 | `standard` | Jā | Veltīta SSO vārteja |
| **`db-gvenzl.yaml`** | Gerald Venzl 23c kopienas dzinējs | `standard` | Jā | Veiktspējas testi |
| **`db-adb.yaml`** | Autonomous Database mākoņa simulācija | `adb` | Jā | Mākoņa pieslēgums mTLS |
| **`db-publisher-oracle.yaml`** | Analytics Publisher RCU datubāze | `standard` | Jā | Publisher RCU |
| **`db-forms-oracle.yaml`** | Oracle Forms 14c RCU datubāze | `standard` | Jā | Forms RCU |
