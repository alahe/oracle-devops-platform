[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](../../docs/sv/README.md) | [ 🇱🇻 Latviešu ](../../docs/lv/README.md) | [ 🇱🇹 Lietuvių ](../../docs/lt/README.md)

# 🏗️ Keskkondade Arhitektuursed Kavandid (Environment Blueprints)

Käesolev kataloog on **keskkonna kõigi 13 toetatud arhitektuurse kavandi (Blueprints)** keskne ja ainus kanooniline tõeallikas.

Iga blueprint (`.env.<N>-*`) defineerib tervikliku infrastruktuuri mudeli alates lihtsast arendusandmebaasist kuni täieliku 5-konteinerilise ettevõtte pilvelaborini.

---

## 🚀 Kiirkäivituse Käsud

### 1. Toodang ja Tavaarendus (Ohutu / Idempotentne / Säilitab Andmed):
Vali ja aktiveeri täpselt üks ametlik blueprint:
```bash
# Aktiveeri Blueprint 3 (VAIKIMISI 2-kihiline tootmislahendus):
./scripts/setup-all.sh -b 3

# Või pikema käsuga:
./scripts/setup-all.sh --blueprint 7

# Kuva kõigi kavandite tabel ilma käivitamata:
./scripts/setup-all.sh -lb

# Vaata konkreetse blueprinti detailset konfiguratsiooni ja konteinereid:
./scripts/setup-all.sh -sb 3

# Otsi blueprinte märksõna järgi:
./scripts/setup-all.sh --search publisher

# Simuleeri käivitust ilma paigalduseta (Dry-Run):
./scripts/setup-all.sh -b 3 --dry-run
```

### 2. Automaattestimine ja CI/CD (Puhas Algseis koos reset-all -y):
Käivita automatiseeritud testid ja mõõdikute kogumine:
```bash
# Testi üksikut blueprinti puhtalt lehelt:
./scripts/setup-all.sh -tb 3

# Testi valitud blueprintide jada:
./scripts/setup-all.sh -tb 1,5,8,10

# Testi KÕIKI blueprinti järjest:
./scripts/setup-all.sh -tb all

# Simuleeri testimist paari sekundiga ilma andmebaase käivitamata:
./scripts/setup-all.sh -tb 1,3,7 --dry-run

# Kuva kõigi testiraportite olek:
./scripts/setup-all.sh -ltr
```

### 3. Kahefaasiline Süvatestimine ja Reaalne E2E Maatriks (Cold + Warm + Sisselogimine):
Käivita 2-faasiline täielik regressiooni- ja stabiilsustest (Faas 1: Külmstart nullist + Faas 2: Soestart ja E2E brauseri/Walleti autentimine):
```bash
# Testi valitud blueprintide täiskomplekti:
./scripts/internal/run_blueprint_matrix_test.sh 7 10 11 31

# Testi kogu platvormi blueprintide maatriksit (3–43):
./scripts/internal/run_blueprint_matrix_test.sh

# Masinloetav raport genereeritakse faili: metrics/matrix_test_report_<TIMESTAMP>.json
```

---

## 📊 Kanooniline Kümnendikepõhine Blueprintide Maatriks (Decade Matrix)

### 🔹 Seeria 1–9: Core APEX & Andmebaasi Arhitektuurid (Põhikeskkonnad)
| Nr | Faili Nimi | Käivitatavad Konteinerid | Pordid | Otstarve ja Arhitektuurne Kirjeldus |
| :--- | :--- | :--- | :--- | :--- |
| **1** | `.env.1-only-db-alise` | `db-alise` | `1533` | **Ainult ALISE Andmebaas:** Minimaalne lokaalne arendusbaas ilma veebiliideste ja lisateenusteta. |
| **2** | `.env.2-db-alise-with-apex-ords` | `db-alise`, `app-ords` | `1533`, `8088`, `8448` | **Kõik-ühes Monoliit:** ALISE andmebaas koos kohapealse APEX 26.1 ja ORDS veebiserveriga ühes masinas. |
| **3** | `.env.3-db-alise-apex-ords-with-proxy` | `db-proxy`, `db-alise`, `app-ords` | `1532`, `1533`, `8088`, `8448` | **🌟 VAIKIMISI TOOTMISLAHENDUS:** 2-kihiline turvaline võrgutopoloogia. Eraldatud Proxy DB ja ALISE DB. |
| **4** | `.env.4-only-ords` | `app-ords` | `8088`, `8448` | **Standalone ORDS Gateway:** Tsentraalne veebiliides kaug- või pilveandmebaaside teenindamiseks. |
| **5** | `.env.5-ords-with-apex` | `db-proxy`, `app-ords` | `1532`, `8088`, `8448` | **Proxy Veebiserver:** Proxy andmebaas koos APEX-i ja ORDS-iga. |
| **6** | `.env.6-gvenzl-dev-light` | `db-alise` | `1533` | **Gerald Venzl Dev Light:** Kergekaaluline Gerald Venzl andmebaas kiireks CI/CD testimiseks. |
| **7** | `.env.7-hybrid-multi-vendor-db` | `db-proxy`, `db-alise`, `app-ords` | `1532`, `1533`, `8088`, `8448` | **Hübriidne Klaster:** Oracle DB 23ai ametlik pilt (Proxy) ja Gerald Venzl pilt (ALISE) koos töötamas. |

---

### 🔹 Seeria 10–19: Analytics Publisher Arhitektuurid (Pixel-Perfect Aruandlus)
| Nr | Faili Nimi | Käivitatavad Konteinerid | Pordid | Otstarve ja Arhitektuurne Kirjeldus |
| :--- | :--- | :--- | :--- | :--- |
| **10** | `.env.10-publisher-dedicated-db` | `db-publisher`, `app-publisher` | `1531`, `9502` | **Pühendatud Publisher DB:** Analytics Publisher eraldiseisva RCU metaandmete andmebaasiga. |
| **11** | `.env.11-publisher-full-enterprise` | `db-publisher`, `db-alise`, `db-proxy`, `app-ords`, `app-publisher` | `1531-1533`, `8088`, `9502` | **Täisisoleeritud Publisher Stack:** Kõik 3 andmebaasi, ORDS ja Pixel-Perfect Publisher koos. |
| **12** | `.env.12-publisher-minimal-hybrid` | `db-proxy`, `db-alise`, `app-ords`, `app-publisher` | `1531`, `1532`, `8088`, `9502` | **Minimaalne Publisher Hübriid:** Kombineeritud Publisher/Proxy DB + ALISE DB + ORDS + Publisher. |
| **13** | `.env.13-publisher-all-in-one-db` | `db-proxy`, `app-ords`, `app-publisher` | `1532`, `8088`, `9502` | **Kõik-ühes Publisher DB:** Kõik RCU ja äriskeemid ühes Free DB-s (`db-proxy`) + ORDS + Publisher. |

---

### 🔹 Seeria 20–29: Oracle Forms 14c Arhitektuurid (Forms & Moderniseerimine)
| Nr | Faili Nimi | Käivitatavad Konteinerid | Pordid | Otstarve ja Arhitektuurne Kirjeldus |
| :--- | :--- | :--- | :--- | :--- |
| **20** | `.env.20-forms-dedicated-db` | `db-forms`, `app-forms` | `1534`, `9001`, `7001`, `6082` | **Forms 14c ja Pühendatud DB:** Oracle Forms 14c runtime ja WebLogic koos pühendatud RCU andmebaasiga. |
| **21** | `.env.21-forms-full-enterprise` | `db-forms`, `db-alise`, `db-proxy`, `app-forms`, `app-ords` | `1531-1534`, `8088`, `9001` | **Täielik Enterprise Forms Stack:** Forms + Forms RCU DB + Custom DB + APEX Proxy DB + ORDS (Täielik isolatsioon). |
| **22** | `.env.22-forms-minimal-hybrid` | `db-proxy`, `db-alise`, `app-forms`, `app-ords` | `1531`, `1532`, `8088`, `9001` | **Minimaalne Forms Hübriid:** Kombineeritud Forms/Proxy DB + ALISE DB + ORDS + Forms Services. |
| **23** | `.env.23-forms-with-embedded-ords` | `db-proxy`, `app-forms` | `1532`, `8088`, `9001`, `7001`, `6082` | **Forms + Sisseehitatud ORDS Jetty:** Kõik-ühes rakendusserver (Forms 9001 + ORDS 8088 ühes konteineris) + DB. |

---

### 🔹 Seeria 30–39: Zero-Install Arendaja Tööjaamad & Pilvelaborid (Web IDE & Cloud)
| Nr | Faili Nimi | Käivitatavad Konteinerid | Pordid | Otstarve ja Arhitektuurne Kirjeldus |
| :--- | :--- | :--- | :--- | :--- |
| **30** | `.env.30-dev-workstation-with-web-ide` | `db-alise`, `app-ords`, `web-ide-dev` | `1533`, `8088`, `8090` | **Zero-Install Arendaja Töökoht:** Brauseripõhine VS Code Web IDE (Oracle SQL Dev + Google Antigravity + GitHub Actions + Red Hat YAML) koos ALISE DB ja ORDS-iga. Sünkroonib automaatselt host-masina SEPS Walleti ja ühendused. |
| **31** | `.env.31-cloud-adb-with-web-ide` | `db-proxy`, `app-ords`, `web-ide-dev` | `1532`, `8088`, `8090` | **Pilve ADB Emulaator + Web IDE:** Autonomous Database (ATP/ADW) pilveemulaator koos brauseripõhise VS Code Web IDE, Oracle tööriistade ja Antigravity AI assistendiga. |
| **32** | `.env.32-publisher-gvenzl-with-web-ide` | `db-publisher`, `app-publisher`, `web-ide-dev` | `1531`, `9502`, `8090` | **Publisher Dev Lab + Web IDE:** Pixel-Perfect aruandlus kergel Gvenzl andmebaasil koos täieliku brauseripõhise Web IDE arenduskeskkonnaga. |
| **33** | `.env.33-full-enterprise-sandbox-web-ide` | 3 DB-d, `app-ords`, `app-publisher`, `web-ide-dev` | Kõik pordid | **Täielik Ettevõtte Pilvelabor:** Kõik andmebaasid ja teenused koos brauseripõhise täisarenduskeskkonna (Oracle SQL Dev, Antigravity AI, GitHub Actions) ja SEPS Walletiga. |
| **34** | `.env.34-proxy-alise-apex-ords-with-web-ide` | `db-proxy`, `db-alise`, `app-ords`, `web-ide-dev` | `1532`, `1533`, `8088`, `8090` | **2-Kihiline Ettevõtte Stäkk + Web IDE:** Meie soovitatud 2-kihiline tootmislahendus (Proxy + ALISE) koos brauseripõhise VS Code Web IDE-ga. |

---

### 🔹 Seeria 40–49: Ultimate Enterprise Kõik-Ühes (Forms + Publisher + APEX + ORDS)
| Nr | Faili Nimi | Käivitatavad Konteinerid | Pordid | Otstarve ja Arhitektuurne Kirjeldus |
| :--- | :--- | :--- | :--- | :--- |
| **40** | `.env.40-ultimate-all-in-one-enterprise` | `db-proxy`, `app-forms`, `app-publisher`, `app-ords` | `1532`, `8088`, `9502`, `9001` | **🌟 Ultimate Enterprise All-in-One:** Forms 14c + Analytics Publisher + APEX 26.1 + ORDS ühendatud andmebaasil ilma Web IDE-ta. |
| **41** | `.env.41-ultimate-all-in-one-enterprise-with-web-ide` | `db-proxy`, `app-forms`, `app-publisher`, `app-ords`, `web-ide-dev` | `1532`, `8088`, `9502`, `9001`, `8090` | **Ultimate Enterprise Kõik-Ühes + Web IDE:** Forms 14c + Publisher + APEX + ORDS + Web IDE ühendatud andmebaasil (`db-proxy`). |
| **42** | `.env.42-ultimate-full-enterprise-isolated-with-web-ide` | `db-forms`, `db-publisher`, `db-proxy`, `db-alise`, `app-forms`, `app-publisher`, `app-ords`, `web-ide-dev` | Kõik pordid | **Täielikult Isoleeritud Enterprise Pilvelabor + Web IDE:** Forms ja Publisher töötavad **eraldi konteinerites ja eraldi andmebaasidel** koos Web IDE-ga. |
| **43** | `.env.43-proxy-ords-apex-with-shared-forms-publisher-db-web-ide` | `db-proxy`, `db-publisher`, `app-forms`, `app-publisher`, `app-ords`, `web-ide-dev` | `1531`, `1532`, `8088`, `9502`, `9001`, `8090` | **2-Andmebaasi Hübriid Enterprise + Web IDE:** APEX/ORDS Proxy andmebaas (`db-proxy`) + Ühine Middleware Infra andmebaas (`db-publisher`) Forms 14c ja Publisher RCU skeemide jaoks. |

---

## 🔒 Turvalisus ja Käsitsi Kopeerimine

Kui soovid blueprinti käsitsi aktiveerida ilma skriptita:
```bash
cp config/blueprints/.env.3-db-alise-apex-ords-with-proxy .env
```
Kõik kohalikud muudatused tehakse faili `.env`, mis on `.gitignore` failis ning jääb ainult lokaalseks.