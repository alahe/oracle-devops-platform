# [TASK-017]: Automaatne Versiooni Tuvastamine (DB, APEX, ORDS)

**Staatus:** `DONE`  
**Prioriteet:** `MEDIUM`  
**Valdkond:** `Tooling`  

---

## 1. Probleemi Kirjeldus ja Kontekst
Käsitsi versiooninumbrite sisestamine ja seadistamine tekitas vigu ja ebakõlasid tegelike tarkvarapakettidega.

## 2. Eesmärk ja Oodatav Tulemus
Automaatne versioonide tuvastus otse konteinerite piltidelt (`podman image inspect` sildid) ja zip-arhiivide failinimedest ning manifestidest.

## 3. Tehniline Teostus
- Skriptid `scripts/setup-all.sh`, `scripts/internal/install-apex.sh`, `scripts/internal/generate-setup-report.sh`.

## 4. Verifitseerimine
- Kontrollitud versiooniinfo korrektsust paigalduse päises ja testiaruannetes.
