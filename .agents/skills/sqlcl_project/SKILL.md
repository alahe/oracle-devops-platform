---
name: sqlcl_project_cicd
description: Juhis Oracle SQLcl Projects (project käskude) kasutamiseks andmebaasi objektide versioonihalduseks ja automaatseks CI/CD tarnimiseks (deploy).
---

# SQLcl Projects: Andmebaasi Rakenduse CI/CD Juhis

See skill juhendab, kuidas kasutada ametlikku Oracle SQLcl `project` käskude perekonda (alates SQLcl versioonist 23.x+), et orkestreerida andmebaasi objektide ja APEX rakenduste elutsüklit Git-põhiselt, ilma et oleks vaja käsitsi kirjutada ja hooldada keerulisi SQL skripte.

---

## 1. SQLcl Projekti Struktuur

SQLcl projekt seob kohaliku andmebaasi skeemi Git repositooriumiga. Projekti algatamisel (`project init`) luuakse järgmine failistruktuur:

```text
projekti_juurkaust/
├── .dbtools/
│   ├── project.config.json    # Projekti konfiguratsioon (skeemid, nited jne)
│   └── filters/
│       └── project.filters    # SQL predikaadid eksportimise filtreerimiseks
├── src/                       # Andmebaasist eksporditud DDL failid (tabelid, triggerid jne)
├── dist/                      # Staged / vabastatud reliisid (genereeritud SQL/Liquibase changelogid)
└── artifact/                  # Valmis pakitud reliisi ZIP arhiivid (gen-artifact väljund)
```

---

## 2. Põhilised Käsud ja Töövoog

Andmebaasi muudatuste tegemisel ja tarnimisel (CI/CD) järgitakse järgmist töövoogu:

### 1. Projekti algatamine (`project init`)
Käivitatakse üks kord projekti algfaasis, et luua konfiguratsioonifailid.
```sql
-- Algatab projekti nimega monitoring_db ja seob selle APEX_PROXY_SCHEMA skeemiga
project init -name monitoring_db -schemas APEX_PROXY_SCHEMA
```

### 2. Muudatuste eksportimine (`project export`)
Tõmbab andmebaasist (nt arenduskeskkonnast) uusima seisuga DDL koodi ja salvestab selle `src/` kataloogi.
```sql
-- Eksport käivitatakse pärast andmebaasis muudatuste tegemist
project export
```
*Soovitus:* Enne eksporti loo uus Giti haru (`git checkout -b feature/alert-job`).

### 3. Muudatuste ettevalmistamine reliisiks (`project stage`)
Võrdleb `src/` kausta sisu eelmise seisuga (või siht-haruga) ja koostab automaatselt Liquibase changelog failid delta-skriptidega kausta `dist/releases/next`.
```sql
project stage
```
*Käsitsi skriptide lisamine:* Kui on vaja lisada andmete migreerimise skripte (DML), saab neid lisada käsuga:
```sql
project stage add-custom -file-name migration_step.sql
```

### 4. Versiooni kinnitamine (`project release`)
Liigutab `next` olekus staged muudatused konkreetsesse versioonikausta (nt `dist/releases/1.0.0`).
```sql
project release -version 1.0.0
```

### 5. Artefakti genereerimine (`project gen-artifact`)
Pakib konkreetse versiooni failid ja Liquibase kontrollfailid kokku üheks ZIP arhiiviks kausta `artifact/`.
```sql
project gen-artifact -version 1.0.0
```
*Tulemus:* Tekib fail `artifact/monitoring_db-1.0.0.zip`. See fail on valmis tarnimiseks Test, UAT ja Production keskkondadesse.

### 6. Artefakti tarnimine (`project deploy`)
Ühendub sihtandmebaasiga ja paigaldab artefakti. SQLcl loeb ZIP failist Liquibase changelogi ja rakendab muudatused järjekorras.
```sql
-- Sisene sihtandmebaasi (nt PROD) ja käivita:
project deploy -file artifact/monitoring_db-1.0.0.zip
```

---

## 3. Eksportimise Filtrid (`project.filters`)

Selleks, et hoida koodibaas puhas ja vältida ajutiste või süsteemsete objektide sattumist Giti, seadistatakse faili `.dbtools/filters/project.filters` SQL-laadsed välistamise reeglid:

```sql
-- Välista kõik ajutised tabelid
object_name not like 'TEMP_%'
-- Välista süsteemsed tabelid ja triggerid
and not (object_type = 'TABLE' and object_name like 'BIN$%')
-- Vali vaid kindlad monitooringu objektid
and object_name in ('APP_CONFIG', 'OUTBOUND_REQUEST_LOG', 'KAFKA_MESSAGE_QUEUE')
```

---

## 4. CI/CD Pipeline Integratsioon

Selle asemel, et jooksutada kohalikke SQL skripte manuaalselt, saab CI/CD runneris (nt Jenkins, GitHub Actions, GitLab CI) kasutada järgmist lihtsat konteineripõhist sammu:

```bash
# Jooksutab SQLcl projekti deploy käsku
podman run --rm -i \
  -v "$(pwd):/workspace" \
  -w /workspace \
  container-registry.oracle.com/database/sqlcl:latest \
  APEX_PROXY_SCHEMA/password@prod-db:1521/FREEPDB1 <<EOF
project deploy -file artifact/monitoring_db-1.0.0.zip
EXIT;
EOF
```

---

## 5. Lokaalne Offline CI/CD Testimine Arendaja Arvutis (`./scripts/test-local-ci.sh`)

Selleks, et testida `.github/workflows/deploy-apex.yml` töövoogu ja `project deploy` käsku **oma arvutis täielikult offline režiimis ilma internetita ja ilma koodi pushimata**:

### Lokaalsed käsulahendused:
```bash
# 1. Kuivkäivitus (Dry-run): Kontrolli workflow ja SQLcl project syntaksit
./scripts/test-local-ci.sh --dry-run

# 2. Täielik lokaalne tarne simulaator oma lokaalse baasi vastu:
./scripts/test-local-ci.sh

# 3. Käivita Nektos 'act' CLI abil:
act -W .github/workflows/deploy-apex.yml
```

### SEPS Walleti eksportimine GitHub Secrets jaoks:
```bash
# Genereeri DB_WALLET_BASE64 võti GitHub Secrets hoidlasse kopeerimiseks:
./scripts/internal/export-ci-secrets.sh
```

---

## 6. Kasulikud Viited (Useful Resources)


*   **Ametlik dokumentatsioon:** [Oracle SQLcl Database Application CI/CD Guide](https://docs.oracle.com/en/database/oracle/sql-developer-command-line/26.2/sqcug/database-application-ci-cd.html)
*   **Reaalse elu näidisprojekt (Real-world examples):** [akluev/realSQLclProject (GitHub)](https://github.com/akluev/realSQLclProject) - Väga hea repositoorium, mis kirjeldab detailset kaustade paigutust, Giti harude haldust ja automaatset CI/CD töövoogu.
*   **Tootejuhi detailne blogipostitus (Jeff Smith):** [Getting Started with SQLcl Projects](https://www.thatjeffsmith.com/archive/2025/05/getting-started-with-sqlcl-projects/)


