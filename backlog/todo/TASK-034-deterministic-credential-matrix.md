# [TASK-034]: Deterministliku Paroolide ja Saladuste Haldussüsteemi Standardiseerimine (Credential Matrix)

**Staatus:** `IN_PROGRESS`  
**Prioriteet:** `HIGH`  
**Valdkond:** `Security / Topology / Credentials / SEPS Wallet`  
**Seotud Komponendid:** `scripts/internal/credential-helper.sh`, `scripts/internal/generate-passwords.sh`, `scripts/internal/create-wallet.sh`, `scripts/get-password.sh`, `scripts/internal/install-publisher.sh`, `scripts/internal/install-forms.sh`, `scripts/internal/apply-profile-users.sh`, `config/blueprints/.env.43-*`

---

## 1. Probleemi Kirjeldus ja Kontekst
Praeguses koodibaasis oli paroolide pärimisel tekkinud olukord, kus skriptid kasutasid pikki ja ettearvamatuid tagavaraväärtuste ahelaid (*fallback chains*), näiteks otsides `DB_PUBLISHER_SYS` parooli ja selle puudumisel võttes `DB_PROXY_SYS` või `DB_DEV`. 

See tekitas mitme andmebaasiga või hübriid-arhitektuurides (nt Blueprint 41 ja Blueprint 43) olukorra, kus teenus (nt Analytics Publisher või Forms) võis saada vale andmebaasi parooli, kui puudus range seos teenuse ja tema siht-andmebaasi vahel.

---

## 2. Eesmärk ja Oodatav Tulemus
1. **Deterministlik Paroolide Maatriks:** Luua range ja ühtne reeglistik, kus iga andmebaasi instants omab kindlaid rolle (`sys`, `dba_admin`, `dev`, `viewer`, `app`, `schema`).
2. **Keskne Credential Helper (`scripts/internal/credential-helper.sh`):** Kõik abiskriptid kasutavad ühtset funktsiooni `get_db_sys_password "$TARGET_DB"` ja `resolve_service_target_db "$service"`.
3. **Zero Cross-DB Fallback (Fail-Fast):** Puuduva parooli korral antakse kohene ja selge veateade ilma teiste andmebaaside poole hüppamata.
4. **Profiilipõhine Sihtandmebaasi Lahendus:** Forms ja Publisher tuvastavad oma siht-andmebaasi profiilist/topoloogiast (kas jagatud infra DB `db-publisher` või pea-andmebaas `db-proxy`).
5. **Uus Blueprint 43:** Luua ja dokumenteerida 2-andmebaasi hübriid-arhitektuur (`db-proxy` APEX/ORDS-ile + `db-publisher` Formsile ja Publisherile).

---

## 3. Tehniline Plaan
Vaata detailset arhitektuuri ja teostusplaani:
👉 [TASK-034 Implementation Plan](../implementation_plans/TASK-034-deterministic-credential-matrix-plan.md)
