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

# Testi KÕIKI 13 blueprinti järjest:
./scripts/setup-all.sh -tb all

# Simuleeri testimist paari sekundiga ilma andmebaase käivitamata:
./scripts/setup-all.sh -tb 1,3,7 --dry-run

# Kuva kõigi testiraportite olek:
./scripts/setup-all.sh -ltr
```

---

## 📊 17 Ametliku Blueprinti Maatriks

| Nr | Faili Nimi | Käivitatavad Konteinerid | Pordid | Otstarve ja Arhitektuurne Kirjeldus |
| :--- | :--- | :--- | :--- | :--- |
| **1** | `.env.1-only-db-lis` | `db-lis` | `1533` | **Ainult LIS Andmebaas:** Lihtne, kiire ja minimaalne lokaalne arendusbaas ilma veebiliideste ja lisateenusteta. |
| **2** | `.env.2-db-lis-with-apex-ords` | `db-lis`, `app-ords` | `1533`, `8088`, `8448` | **Kõik-ühes Monoliit:** LIS andmebaas koos kohapealse APEX 26.1 ja ORDS veebiserveriga ühes masinas. |
| **3** | `.env.3-db-lis-apex-ords-with-proxy` | `db-proxy`, `db-lis`, `app-ords` | `1532`, `1533`, `8088`, `8448` | **🌟 VAIKIMISI TOOTMISLAHENDUS:** 2-kihiline turvaline võrgutopoloogia. Eraldiseisev Proxy DB välisliidestele ja LIS DB siseandmetele. |
| **4** | `.env.4-only-app-publisher` | `db-publisher` | `1531` | **Publisheri Metaandmete Baas:** Eraldiseisev WebLogic RCU / OAS metaandmete andmebaas. |
| **5** | `.env.5-only-ords` | `app-ords` | `8088`, `8448` | **Standalone ORDS Gateway:** Tsentraalne veebiliides kaug- või pilveandmebaaside (Remote DB) teenindamiseks. |
| **6** | `.env.6-ords-with-apex` | `db-proxy`, `app-ords` | `1532`, `8088`, `8448` | **Proxy Veebiserver:** Proxy andmebaas koos APEX-i ja ORDS-iga. |
| **7** | `.env.7-all-services-together` | `db-publisher`, `db-proxy`, `db-lis`, `app-ords`, `app-publisher` | `1531-1533`, `8088`, `8448`, `9502` | **Täielik 4-Kihiline Ettevõtte Stack:** Kõik andmebaasid, ORDS ja Pixel-Perfect Analytics Publisher töötavad koos. |
| **8** | `.env.8-gvenzl-dev-light` | `db-lis-gvenzl` | `1533` | **Gerald Venzl Dev Light:** Kergekaaluline Oracle 23ai konteiner kiireks CI/CD testimiseks. |
| **9** | `.env.9-dev-workstation-with-web-ide` | `db-lis`, `app-ords`, `web-ide-dev` | `1533`, `8088`, `8448`, `8090` | **Zero-Install Arendaja Töōkoht:** Brauseripõhine VS Code Web IDE koos andmebaasi ja ORDS-iga. |
| **10** | `.env.10-hybrid-multi-vendor-db` | `db-proxy-oracle`, `db-lis-gvenzl`, `app-ords` | `1532`, `1533`, `8088`, `8448` | **Hübriidne Klaster:** Oracle DB 23ai ametlik pilt (Proxy) ja Gerald Venzl pilt (LIS) koos töötamas. |
| **11** | `.env.11-cloud-adb-with-web-ide` | `db-proxy-adb`, `app-ords`, `web-ide-dev` | `1532`, `8088`, `8443`, `8090` | **Pilve ADB Emulaator:** Autonomous Database (ATP/ADW) emulaator koos Web IDE-ga. |
| **12** | `.env.12-publisher-gvenzl-with-web-ide` | `db-publisher-gvenzl`, `app-publisher`, `web-ide-dev` | `1531`, `9502`, `8090` | **Publisher Dev Lab:** Pixel-Perfect aruandlus kergel Gvenzl andmebaasil koos Web IDE-ga. |
| **13** | `.env.13-full-enterprise-sandbox-web-ide` | 3 DB-d, `app-ords`, `app-publisher`, `web-ide-dev` | Kõik pordid | **Täielik Ettevõtte Pilvelabor:** Kõik 5 konteinerit koos brauseripõhise täisarenduskeskkonnaga. |
| **14** | `.env.14-forms-with-dedicated-db` | `db-forms`, `app-forms` | `1534`, `9001`, `7001`, `6082` | **Forms 14c ja Pühendatud DB:** Oracle Forms 14c runtime ja WebLogic koos pühendatud RCU andmebaasiga. |
| **15** | `.env.15-forms-full-enterprise` | `db-forms`, `db-lis`, `db-proxy`, `app-forms`, `app-ords` | `1531-1534`, `8088`, `9001`, `7001`, `6082` | **Täielik Enterprise Forms Stack:** Forms + Forms RCU DB + Custom DB + APEX Proxy DB + ORDS (Täielik isolatsioon). |
| **16** | `.env.16-forms-minimal-hybrid` | `db-proxy`, `db-lis`, `app-forms`, `app-ords` | `1531`, `1532`, `8088`, `9001`, `7001`, `6082` | **Minimaalne Hübriid:** Forms + Kombineeritud Forms/APEX Proxy DB + Custom DB + ORDS (Tasakaalustatud ressursikasutus). |
| **17** | `.env.17-forms-all-in-one-db` | `db-proxy`, `app-forms`, `app-ords` | `1532`, `8088`, `9001`, `7001`, `6082` | **All-in-One DB Katsevariant:** Forms + Kõik skeemid ühes Free DB-s + ORDS. |
| **18** | `.env.18-forms-with-embedded-ords` | `db-proxy`, `app-forms` | `1532`, `8088`, `9001`, `7001`, `6082` | **Forms + Sisseehitatud ORDS Jetty:** Kõik-ühes rakendusserver (Forms 9001 + ORDS 8088 ühes `app-forms` konteineris) + DB. |

---

## 🔒 Turvalisus ja Käsitsi Kopeerimine

Kui soovid blueprinti käsitsi aktiveerida ilma skriptita:
```bash
cp config/blueprints/.env.3-db-lis-apex-ords-with-proxy .env
```
Kõik kohalikud muudatused tehakse faili `.env`, mis on `.gitignore` failis ning jääb ainult lokaalseks.

