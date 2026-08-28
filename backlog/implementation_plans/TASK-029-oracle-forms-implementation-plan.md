# [TASK-029]: Oracle Forms 14c (14.1.2) Konteiner, Metaandmete Andmebaas, RCU, Testvormi Loop ja Profiilid

**Staatus:** `IN_PLANNING`  
**Prioriteet:** `HIGH`  
**Valdkond:** `Architecture` | `Orchestration` | `Tooling` | `Forms 14c`  
**Seotud Profiilid:** `config/profiles/databases/db-forms-*.yaml`, `config/blueprints/.env.14-forms-with-dedicated-db`  
**Dokumentatsioon:** [docs/forms-setup.md](../../docs/forms-setup.md), [docs/db-profiles-and-topology.md](../../docs/db-profiles-and-topology.md)  
**Oskusteave:** [.agents/skills/oracle_forms_devops/SKILL.md](../../.agents/skills/oracle_forms_devops/SKILL.md)  

---

## 1. Tarkvarapakettide Organisatsioon ja Jagamine (`binaries/`)

| Kataloog | Pakett | Otstarve ja Jagamine |
| :--- | :--- | :--- |
| **`binaries/java/`** | `jdk-17.0.12_linux-x64_bin.rpm`<br>`jdk-17.0.12_linux-aarch64_bin.rpm` | **Ametlik Oracle Java 17 LTS:** Jagatud Publisheri ja Forms 14c vahel. |
| **`binaries/middleware/`** | `V1045135-01.zip`<br>(sisaldab `fmw_14.1.2.0.0_infrastructure.jar`) | **Oracle FMW Infrastructure 14.1.2:** WebLogic baasinfrastruktuur Publisherile ja Formsile. |
| **`binaries/forms/`** | `V1045121-01.zip`<br>(sisaldab `fmw_14.1.2.0.0_fr_linux64.bin`) | **Oracle Forms and Reports 14.1.2:** Silent paigaldaja Forms teenustele. |
| **`binaries/publisher/`** | `V1055080-01.zip` | **Analytics Publisher:** OAS / BIP paigaldusfail. |

---

## 2. Arhitektuur ja Komponendid (Forms 14.1.2)

```
                              ┌─────────────────────────────────────────────────────────┐
                              │                   KASUTAJA / VEEB                       │
                              │  http://localhost:9001/forms/frmservlet (Forms Runtime)  │
                              │  http://localhost:9001/forms/frmservlet?form=test.fmx   │
                              │  http://localhost:7001/console (WLS Admin Console)      │
                              └───────────────────────────┬─────────────────────────────┘
                                                          │
                                                          ▼
┌────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ 📦 app-forms (Oracle Forms 14.1.2 & WebLogic 14c Konteiner)                                                    │
│  ├─ Alus: binaries/java/ (JDK 17 LTS) + binaries/middleware/ (FMW 14.1.2 Infrastructure)                      │
│  ├─ Paigaldus: binaries/forms/V1045121-01.zip (Forms 14.1.2 silent installer)                                 │
│  ├─ WebLogic Server 14.1.2 (AdminServer: 7001)                                                                 │
│  ├─ Forms Managed Server 14.1.2 (WLS_FORMS: 9001 HTTP, 9002 HTTPS)                                            │
│  ├─ Forms Standalone Launcher (FSAL) & Browser Web start tugi                                                 │
│  ├─ Entrypoint: /u01/createAndStartFormsDomain.sh (wait_for_db.sh -> RCU -> WLST -> Start)                      │
│  └─ Rakenduste ja testvormide maht: /u01/oracle/forms_apps/*.fmx (sh test.fmx)                                 │
└─────────────────────────────────────────────────────────┬──────────────────────────────────────────────────────┘
                                                          │ RCU JDBC (localhost:1534 / db-forms:1521)
                                                          ▼
┌────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ 🗄️ db-forms (Forms Metaandmete & RCU Andmebaas)                                                                 │
│  ├─ Konteiner: db-forms (Oracle 23ai Free / 26ai)                                                              │
│  ├─ Port: 1534 -> 1521/FREEPDB1                                                                                │
│  ├─ RCU Skeemid: FORMS_STB, FORMS_OPSS, FORMS_IAU, FORMS_WLS, FORMS_UCS (Loodud RCU 14.1.2 silent režiimis)   │
│  ├─ Arendajakonto: FORMS_DEV, FORMS_SCHEMA                                                                     │
│  └─ SEPS Wallet: DB_FORMS_SYS, DB_FORMS_DBA_ADMIN, DB_FORMS_DEV, DB_FORMS_SCHEMA                               │
└────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Forms Testvormi ja Teenuse Automaatne Testimistsükkel (End-to-End Loop)

Skript teostab automaatset testimist ja valideerimist seni, kuni Forms teenus on 100% töökõlblik:

1. **Forms Runtime Endpointi Kontroll (`http://localhost:9001/forms/frmservlet`):**
   - Skript `scripts/internal/test-forms-service.sh` ootab kuni `WLS_FORMS` vastab HTTP staatusega `200 OK`.
2. **Forms Testvormi Käivitus (`test.fmx` / `frmservlet?form=test.fmx`):**
   - Paigaldatakse Forms 14c standardne testvorm `test.fmx` kausta `/u01/oracle/forms_apps`.
   - Verifitseeritakse, et Forms konfiguratsioonifailis `formsweb.cfg` on `form=test.fmx` ja `envFile=default.env` aktiivne.
   - Pärimise ja vastuse kontroll: kontrollitakse, et HTTP päring tagastab korrektse Forms Java Web Start / FSAL / HTML5 käivitaja konfiguratsiooni ilma `FRM-` vigadeta.
3. **Pidev Kordustestimine (Loop Until Operational):**
   - Kui server vajab initsialiseerumiseks aega, ootab skript reaalajas loenduriga (`run_with_live_timer`) kuni server on valmis ja testvorm vastab.

---

## 4. Tehnilised Failid ja Muudatused

### 4.1. YAML Andmebaasi Profiilid (`config/profiles/databases/`)
- `config/profiles/databases/db-forms-oracle.yaml`: port 1534, teenus FREEPDB1, kasutajad `FORMS_SCHEMA`, `FORMS_DEV`.
- `config/profiles/databases/db-forms-gvenzl.yaml`: Gerald Venzl alternatiiv.

### 4.2. Docker / Podman Konteineri Ehitus (`docker/forms/`)
- `docker/forms/dockerfiles/14.1.2/Dockerfile`: Oracle Linux 8 baasil, paigaldab JDK 17, FMW Infrastructure 14.1.2 ja Forms 14.1.2.
- `docker/forms/dockerfiles/14.1.2/createAndStartFormsDomain.sh`: Konteineri käivitusskript.
- `docker/forms/dockerfiles/14.1.2/create_forms_domain.py`: WLST Python skript WebLogic `forms_domain` loomiseks.
- `docker/forms/build-forms-image.sh`: Pildiehitaja `localhost/oracle-forms:14.1.2`.

### 4.3. Orkestreerimise ja Sisemised Abiskriptid
- `scripts/internal/init-forms-rcu.sh`: RCU 14c repositooriumiskeemide loomine.
- `scripts/internal/install-forms.sh`: Forms 14c paigaldus ja käivitus.
- `scripts/internal/test-forms-service.sh`: Forms runtime ja testvormi valideerija.
- `scripts/internal/resolve-topology.sh`: `DB_FORMS` ja `app-forms` topoloogia tuvastus.
- `scripts/internal/generate-compose-override.sh`: `app-forms` ja `db-forms` lisamine.
- `scripts/setup-all.sh`: Forms 14c sammud.

### 4.4. Forms Haldusskriptid (`scripts/forms/`)
- `scripts/forms/status-forms.sh`: Forms teenuste ja URL-ide diagnostika.
- `scripts/forms/restart-forms.sh`: Taaskäivitus.
- `scripts/forms/deploy-forms-apps.sh`: `.fmx` ja `.mmx` rakenduste automaatne tarne.

### 4.5. Arhitektuursed Blueprintid (`config/blueprints/`)
- `config/blueprints/.env.14-forms-with-dedicated-db`: Blueprint 14.

### 4.6. Dokumentatsioon ja Skilli Faile (`docs/` ja `.agents/skills/`)
- `docs/forms-setup.md`: Forms 14c juhend.
- `.agents/skills/oracle_forms_devops/SKILL.md`: Forms 14c DevOps oskusteave.
- `README.md` ja `scripts/README.md`.

---

## 5. Ühiktestid (`tests/unit/`)
- `tests/unit/test-forms-profile-and-topology.sh`
- `tests/unit/test-script-status-forms.sh`
- `tests/unit/test-script-deploy-forms-apps.sh`
- Kõigi 65+ testi 100% edukus.
rne konteinerisse)

---

## 4. Verifitseerimine ja Automaattestid
- **Ühiktest:** `tests/unit/test-forms-profile-and-topology.sh` (kontrollib Forms profiilide laadimist, pordi eraldust ja konteinerite tuvastust).
- **Tervisekontroll:** `check-urls.sh` ja `test-urls.sh` kontrollivad Forms URL-i (nt `http://localhost:9001/forms/frmservlet`).
