[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🗄️ Databasprofiler (`config/profiles/databases/`)

Denna katalog innehåller domänisolerade YAML-profiler för **Oracle Database-behållare** (Standard 23ai Free, Autonomous ADB Free, Gvenzl 23c).

## 📂 Matris för databasprofiler

| Profilfil | Beskrivning | DB-typ | Wallet krävs | Användningsområde |
| :--- | :--- | :--- | :--- | :--- |
| **`db-alise-oracle.yaml`** | Primär applikationsdatabas Oracle 23ai Free | `standard` | Ja | Primär affärsdatabas |
| **`db-proxy-oracle.yaml`** | APEX Proxy och SSO-gateway 23ai | `standard` | Ja | APEX Proxy och SSO |
| **`db-proxy-standalone.yaml`** | Fristående APEX Proxy på port 1537 | `standard` | Ja | Dedikerad SSO-gateway |
| **`db-gvenzl.yaml`** | Gerald Venzl 23c community-motor | `standard` | Ja | Prestandatester och snabbstart |
| **`db-adb.yaml`** | Autonomous Database Cloud-simulering | `adb` | Ja | Molnanslutning via mTLS |
| **`db-publisher-oracle.yaml`** | Analytics Publisher RCU-databas | `standard` | Ja | Publisher RCU |
| **`db-forms-oracle.yaml`** | Oracle Forms 14c RCU-databas | `standard` | Ja | Forms RCU |
