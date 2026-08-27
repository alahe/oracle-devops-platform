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

# Kuvage kõigi kavandite tabel ilma käivitamata:
./scripts/setup-all.sh -l
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
```

---

## 📊 13 Ametliku Blueprinti Maatriks

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

---

## 🔒 Turvalisus ja Käsitsi Kopeerimine

Kui soovid blueprinti käsitsi aktiveerida ilma skriptita:
```bash
cp config/blueprints/.env.3-db-lis-apex-ords-with-proxy .env
```
Kõik kohalikud muudatused tehakse faili `.env`, mis on `.gitignore` failis ning jääb ainult lokaalseks.
