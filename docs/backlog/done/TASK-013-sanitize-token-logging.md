# [TASK-013]: Artifactory ja Git Žetoonide Maskeerimine Logides

**Staatus:** `DONE`  
**Prioriteet:** `HIGH`  
**Valdkond:** `Security`  

---

## 1. Probleemi Kirjeldus ja Kontekst
Paigalduslogidesse (`install_logs/`) võivad sattuda tundlikud autentimistõendid (Bearer tokenid, Artifactory salasõnad).

## 2. Eesmärk ja Oodatav Tulemus
Automaatne logide saniteerija, mis asendab kõik `ACCESS_TOKEN`, `Bearer ...` ja paroolid tekstiga `***MASKED***`.

## 3. Tehniline Teostus
- Skript [`scripts/internal/sanitize-logs.sh`](../../scripts/internal/sanitize-logs.sh).

## 4. Verifitseerimine
- Testitud logifailide sisu saniteerimist.
