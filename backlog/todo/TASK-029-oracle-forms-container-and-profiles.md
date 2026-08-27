# [TASK-029]: Oracle Forms 14c Konteineri, Metaandmete Andmebaasi ja Profiilide Tugi

**Staatus:** `TODO`  
**Prioriteet:** `HIGH`  
**Valdkond:** `Architecture` | `Orchestration` | `Tooling`  
**Seotud Blueprintid / Profiilid:** `config/profiles/databases/db-forms-*.yaml`, `config/blueprints/`  
**Dokumentatsioon:** [docs/forms-setup.md](../../docs/forms-setup.md), [docs/db-profiles-and-topology.md](../../docs/db-profiles-and-topology.md)  

---

## 1. Probleemi Kirjeldus ja Kontekst
Projekti arhitektuuris on juba edukalt toetatud **Analytics Publisher (Pixel Perfect)** eraldiseisva rakenduse ja andmebaasina (`app-publisher` ja `db-publisher`). Ettevõtte pärandsüsteemide ja ärirakenduste moderniseerimiseks ning kohalikuks käivitamiseks on vajalik lisada sarnane autonoomne tugi **Oracle Forms 14c (Fusion Middleware 14c / Forms Services 14.1.2)** lahendusele.

Nagu Publisher, vajab ka Oracle Forms 14c omaette WebLogic 14c / RCU metaandmete andmebaasi (`db-forms`), rakendusserveri konteinerit (`app-forms`), lokaalset allalaaditud paigaldusfailide puhverdamist (`binaries/forms/`) ning YAML profiile.

---

## 2. Eesmärk ja Oodatav Tulemus
1. **Forms 14c Rakendusserveri Konteiner (`app-forms`):**
   - WebLogic Forms Services 14c (Java 17/21 baasil) autonoomne konteiner, mis serveerib Forms 14c rakendusi üle HTTP/HTTPS liideste (pordid nt `9001` HTTP / `9002` HTTPS).
2. **Forms Metaandmete Andmebaas (`db-forms`):**
   - Pühendatud andmebaas RCU (Repository Creation Utility 14c) skeemide (`WLS_RUNTIME`, `OPSS`, `IAU` jne) ja Forms konfiguratsiooni talletamiseks (port `1534`).
3. **Puhverdatud Allalaadimised (`binaries/forms/`):**
   - Forms 14c paigaldusfailide (`.bin`, `.zip`, `.jar`) kohalik haldus ja automaatne allalaadimine sisevõrgu Artifactory või Oracle hoidlast.
4. **YAML Profiilid ja Topoloogia:**
   - Uued profiilid:
     - `config/profiles/databases/db-forms-oracle.yaml` (Oracle 23ai baasil)
     - `config/profiles/databases/db-forms-gvenzl.yaml` (Gerald Venzl kergekaalulisel baasil)
5. **Automaatne SEPS Wallet ja TNS Integratsioon:**
   - Walleti aliased `DB_FORMS_SYS`, `DB_FORMS_DEV`, `DB_FORMS_SCHEMA` ja `DB_DB_FORMS_*`.
   - VS Code ühenduste automaatne registreerimine kausta `/db-forms`.

---

## 3. Tehniline Teostus ja Arhitektuur

### 3.1 YAML Profiilid
- Luua `config/profiles/databases/db-forms-oracle.yaml`:
  - Port: `1534`
  - Container: `db-forms`
  - Service: `FREEPDB1`
  - Users: `SYS`, `DBA_ADMIN`, `FORMS_SCHEMA`, `FORMS_DEV`

### 3.2 Topoloogia ja Konteinerite Orkestreerimine
- Täiendada `scripts/internal/resolve-topology.sh` ja `load-profile.sh` toetama `DB_FORMS` muutujat.
- Täiendada `scripts/internal/generate-compose-override.sh` ja `docker-compose.yml` tooma sisse `app-forms` ja `db-forms` teenused.
- Lisada `binaries/forms/` kaust `.gitignore` erandiga failide puhverdamiseks.

### 3.3 Elutsükli ja Halduse Skriptid (`scripts/forms/`)
- `scripts/forms/status-forms.sh` (Forms WebLogic ja FrmSrv staatus)
- `scripts/forms/restart-forms.sh` (Forms teenuse taaskäivitamine)
- `scripts/forms/deploy-forms-apps.sh` (`.fmx` / `.mmx` failide tarne konteinerisse)

---

## 4. Verifitseerimine ja Automaattestid
- **Ühiktest:** `tests/unit/test-forms-profile-and-topology.sh` (kontrollib Forms profiilide laadimist, pordi eraldust ja konteinerite tuvastust).
- **Tervisekontroll:** `check-urls.sh` ja `test-urls.sh` kontrollivad Forms URL-i (nt `http://localhost:9001/forms/frmservlet`).
