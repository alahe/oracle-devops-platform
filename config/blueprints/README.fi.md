[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](../../docs/sv/README.md) | [ 🇱🇻 Latviešu ](../../docs/lv/README.md) | [ 🇱🇹 Lietuvių ](../../docs/lt/README.md)

# 🏗️ Ympäristön Arkkitehtuurisuunnitelmat (Environment Blueprints)

Tämä luettelo on **ympäristön kaikkien arkkitehtuurisuunnitelmien (Blueprints)** keskitetty ja kanoninen tietolähde.

Jokainen blueprint (`.env.<N>-*`) määrittää kokonaisvaltaisen infrastruktuurimallin yksinkertaisesta kehitystietokannasta täydelliseen 5-konttiseen yrityspilvilaboratorioon.

---

## 🚀 Pikakäynnistyksen Komennot

### 1. Tuotanto ja Kehitys (Turvallinen / Säilyttää Datan):
Valitse ja aktivoi haluttu blueprint:
```bash
# Aktivoi Blueprint 3 (OLETUS 2-kerroksinen tuotantoratkaisu):
./scripts/setup-all.sh -b 3 --lang fi

# Tai hae blueprint-luettelo ilman käynnistystä:
./scripts/setup-all.sh -lb --lang fi

# Tarkastele tietyn blueprintin yksityiskohtia:
./scripts/setup-all.sh -sb 3 --lang fi

# Etsi blueprintejä avainsanalla:
./scripts/setup-all.sh --search publisher

# Simuloi käynnistystä ilman asennusta (Dry-Run):
./scripts/setup-all.sh -b 3 --dry-run
```

### 2. Automaattitestaus ja CI/CD (Puhdas Alku reset-all -y kera):
```bash
# Testaa yksittäistä blueprintiä puhtaalta pöydältä:
./scripts/setup-all.sh -tb 3

# Testaa useita blueprintejä peräkkäin:
./scripts/setup-all.sh -tb 1,5,8,10

# Testaa KAIKKI blueprintit peräkkäin:
./scripts/setup-all.sh -tb all
```

---

## 📊 Kanoninen Blueprint-Matriisi (Decade Matrix)

### 🔹 Sarja 1–9: Core APEX & Tietokanta-arkkitehtuurit
| Nro | Tiedostonimi | Kontit | Portit | Tarkoitus ja Arkkitehtuuri |
| :--- | :--- | :--- | :--- | :--- |
| **1** | `.env.1-simple-standard` | `db-proxy`, `app-ords` | `1532`, `8088/8448` | Standardi kehitys- ja APEX-ympäristö. |
| **2** | `.env.2-custom-db-only` | `db-alise`, `app-ords` | `1533`, `8088/8448` | Erillinen sovellustietokanta suoralla REST SQL -tuella. |
| **3** | `.env.3-hybrid-proxy-custom` | `db-proxy`, `db-alise`, `app-ords` | `1532/1533`, `8088/8448` | 2-tietokantainen hybridiarkkitehtuuri eristetyllä sovelluslogiikalla. |

### 🔹 Sarja 10–19: Analytics Publisher (Pixel Perfect)
| Nro | Tiedostonimi | Kontit | Portit | Tarkoitus ja Arkkitehtuuri |
| :--- | :--- | :--- | :--- | :--- |
| **10** | `.env.10-publisher-dedicated-db` | `db-publisher`, `app-publisher` | `1535`, `9502/9500` | Erillinen Publisher RCU-metatietokannalla. |
| **11** | `.env.11-publisher-full-enterprise` | 3 DB:tä, `app-ords`, `app-publisher` | `1532/1533/1535`, `8088`, `9502` | Täysin eristetty yrityspino raportointiin ja APEXiin. |

### 🔹 Sarja 20–29: Oracle Forms 14c
| Nro | Tiedostonimi | Kontit | Portit | Tarkoitus ja Arkkitehtuuri |
| :--- | :--- | :--- | :--- | :--- |
| **20** | `.env.20-forms-dedicated-db` | `db-forms`, `app-forms` | `1534`, `9001/7001/6082` | Erillinen Forms 14c Services ja testilomake. |
| **21** | `.env.21-forms-on-proxy-db` | `db-proxy`, `app-forms`, `app-ords` | `1532`, `9001`, `8088` | Forms 14c jaetulla RCU-tietokannalla. |

### 🔹 Sarja 30–39: Web IDE & CI/CD
| Nro | Tiedostonimi | Kontit | Portit | Tarkoitus ja Arkkitehtuuri |
| :--- | :--- | :--- | :--- | :--- |
| **30** | `.env.30-web-ide-with-proxy-db` | `web-ide-dev`, `db-proxy`, `app-ords` | `8090`, `1532`, `8088` | Selainpohjainen VS Code ja SQL Developer. |

### 🔹 Sarja 40–49: Ultimate Enterprise
| Nro | Tiedostonimi | Kontit | Portit | Tarkoitus ja Arkkitehtuuri |
| :--- | :--- | :--- | :--- | :--- |
| **40** | `.env.40-ultimate-all-in-one-enterprise` | Kaikki 5 konttia | Kaikki portit | Forms 14c + Publisher + APEX 26.1 + ORDS + Web IDE (erilliset tietokannat). |
| **41** | `.env.41-all-in-one-single-db-enterprise` | `db-proxy`, `app-ords`, `app-publisher`, `app-forms`, `web-ide-dev` | Kaikki portit | Kaikki palvelut yhdistettynä 1 tietokantaan. |
| **43** | `.env.43-all-in-one-2db-hybrid-enterprise` | `db-proxy`, `db-alise`, `app-ords`, `app-publisher`, `app-forms`, `web-ide-dev` | Kaikki portit | 2-tietokantainen hybridiyritysjärjestelmä. |
