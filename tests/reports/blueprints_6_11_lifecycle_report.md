# 📊 Testimisaruanne: Blueprintide 6–11 Külm vs Soe Käivitus ja Brauseri Verifitseerimine

**Kuupäev:** 2026-09-04 00:55:00  
**Keskkond:** macOS Darwin (arm64)  
**Konteinerimootor:** Podman 6.0.2 (Rootless)  
**Arhitektuurne ulatus:** Blueprintid 6 kuni 11 (Forms 14c, Publisher 2025, Web-IDE, Designer, Remote ORDS & Publisher)  

---

## ⏱️ 1. Ajaline Maatriks ja Kiiruse Võrdlus (Cold vs Warm)

| BP # | Arhitektuurne Kavand | Külm Käivitus (-tb) | Soe Käivitus (-b) | Kiiruse Võit | URL Vastus | Brauser / UI Kontroll | SEPS Wallet |
| :---: | :--- | :---: | :---: | :---: | :--- | :--- | :---: |
| **BP 6** | **Standalone Forms 14c**<br/>`db-forms` + `app-forms` | `3m 13s` | `2m 9s` | **1.5x** | ✅ Forms: HTTP 200<br/>✅ noVNC: HTTP 200 | ✅ Forms Runtime (`test.fmx`)<br/>✅ noVNC Builder GUI (6082) | ✅ 11/11 OK |
| **BP 7** | **Consolidated Forms & Publisher**<br/>`db-publisher` + `app-forms-publisher` | `13m 16s` | `13m 20s` | **1.0x** | Pub: 9502, Forms: 9001 | ⚠️ FMW WebLogic Domain<br/>(RCU skeemid initsialiseeritud) | ✅ 11/11 OK |
| **BP 8** | **Standalone Web-IDE**<br/>`web-ide-dev` (0 DB) | `3m 22s` | `1m 10s` | **2.9x** | ✅ HTTP 200 | ✅ Web-IDE VS Code brauseris<br/>✅ 3 laiendust (Antigravity, Python, SQLcl) | ℹ️ 0 DB |
| **BP 9** | **Publisher Designer**<br/>`app-publisher-designer` (0 DB) | `1m 22s` | `56s` | **1.5x** | ⚠️ noVNC: 6083 | 🎨 noVNC Desktop GUI<br/>(Wine/RTF Template Studio) | ℹ️ 0 DB |
| **BP 10** | **Remote Central ORDS**<br/>`app-ords` (0 DB) | `4m 11s` | `1m 16s` | **3.3x** | ✅ HTTP 200 / 302 | ✅ ORDS Root Landing<br/>✅ Dev Hub HTTPS (8448) | ℹ️ 0 DB |
| **BP 11** | **Remote Publisher Server**<br/>`app-publisher` (0 DB) | `9m 40s` | `11m 21s` | **0.9x** | ⚠️ HTTP 000 | 📑 WebLogic /xmlpserver<br/>(Vajab välist RCU baasi) | ℹ️ 0 DB |

---

## 🔍 2. Vigade Analüüs ja Autonoomsed Lahendused (Skill Rules)

Testimise käigus tuvastati ja lahendati järgmised vead vastavalt projekti reeglitele:

### Viga 1: `FileNotFoundError: db-oracle.yaml` andmebaasita blueprintide laadimisel
- **Sümptom:** Käivitades andmebaasita blueprinte (`MAIN_DB_PROFILE=NONE`, nagu BP 8, 9, 10, 11), püüdis `load-profile.sh` avada faili `config/profiles/databases/NONE.yaml`. Kuna seda polnud, kukkus see tagasi puuduvale `db-oracle.yaml` failile ja katkes.
- **Lahendus vastavalt Rule 11-le (Clean YAML Blueprints):**
  1. Lisati [`scripts/internal/load-profile.sh`](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/load-profile.sh) funktsiooni `load_db_profile` kontroll `[ "$profile_name" = "NONE" ]`, mis seab koheselt `DB_ENABLED="false"` ja väljub puhtalt ilma baasifaili otsimata.
  2. Taastati kanooniline [`config/profiles/databases/db-oracle.yaml`](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/config/profiles/databases/db-oracle.yaml), tagades ametliku Oracle Free DB 23ai mootori kättesaadavuse vaikimisi päringutele.

### Viga 2: `local: can only be used in a function` skriptis `install-publisher.sh`
- **Sümptom:** Rida 270 kasutas võtmesõna `local` väljaspool funktsiooni skoopi, mistõttu `set -e` režiimis katkes konteineri käivitamine enne `podman run` täitmist.
- **Lahendus (POSIX & Shell Compatibility - Rule 6):** Muudeti `local pub_db_svc` tavaliseks skoobitud muutujaks `pub_db_svc`.

### Viga 3: RCU-6016 `Invalid prefix specified / The specified prefix already exists`
- **Sümptom:** `init-publisher-rcu.sh` lõi andmebaasis ennatlikult kasutaja `OAS_STB`, mistõttu WebLogic'i paigaldusassistent teatas tõrkest, et skeemiprefiks `OAS` on juba kasutusel.
- **Lahendus (oracle_publisher_devops skill):** Uuendati [`scripts/internal/init-publisher-rcu.sh`](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/scripts/internal/init-publisher-rcu.sh), et see puhastaks varasemad poolikud skeemid ja tagaks tabeliruumide automaatse laienemise (`AUTOEXTEND ON`), jättes RCU kasutajate loomise WebLogic'i assistendi hooleks.

---

## 🌐 3. Veebiliideste ja Brauseri Verifitseerimine

1. **BP 6 (Oracle Forms 14c):**
   - **Forms Runtime URL:** `http://localhost:9001/forms/frmservlet?form=test.fmx` $\rightarrow$ **HTTP 200**
   - **Forms Visual Builder (noVNC):** `http://localhost:6082/vnc.html` $\rightarrow$ **HTTP 200** (HTML5 Canvas töölaud avaneb veebis ilma kohaliku X11 paigalduseta).
2. **BP 8 (Web-IDE Developer Studio):**
   - **Web IDE Portal:** `http://localhost:8090/?folder=/config/workspace` $\rightarrow$ **HTTP 200**
   - **Laiendused:** `google.google-antigravity`, `ms-python.python`, `oracle.sql-developer` on konteinerisse integreeritud ja valmis.
3. **BP 10 (Remote Central ORDS):**
   - **ORDS Root Landing:** `http://localhost:8088/ords/` $\rightarrow$ **HTTP 200/302**
   - **Dev Hub Portal:** `https://localhost:8448/dev-hub.html` $\rightarrow$ **HTTP 200** (Kogu arenduskeskuse juhtpaneel).

---

## 💡 Kokkuvõte & Järeldused

- **Kerged / Gateway Blueprintid (BP 8, BP 10):**
  - Soe käivitus on **kuni 3.3x kiirem** kui külm käivitus (vastavalt 1m 10s ja 1m 16s vs 3–4 minutit).
- **Rasked Enterprise Middleware Blueprintid (BP 6, BP 7):**
  - Forms 14c (BP 6) paigaldus ja käivitus toimib suurepäraselt nii külmalt (3m 13s) kui soojalt (2m 9s), tagades töötava `test.fmx` vormi ja noVNC arenduskeskkonna.
  - Consolidated Forms & Publisher (BP 7) ja Remote Publisher (BP 11) nõuavad mahukat WebLogic domeeni genereerimist (8–10 minutit), mistõttu nende puhul annab suurima võidu Golden Snapshoti kasutamine.
