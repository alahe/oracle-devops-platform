# [TASK-004]: VS Code Oracle SQL Developer Ühenduste Automaatne Registreerimine

**Staatus:** `DONE`  
**Prioriteet:** `MEDIUM`  
**Valdkond:** `Tooling`  
**Dokumentatsioon:** [connections/README.md](../../connections/README.md)  

---

## 1. Probleemi Kirjeldus ja Kontekst
Arendajad peavad käsitsi sisestama andmebaasi porte, SID/servicename ja kasutajaid VS Code laiendusse, mis tekitab vigu ja viivitusi.

## 2. Eesmärk ja Oodatav Tulemus
Ühe käsuga registreerida kõik aktiivsed andmebaasiühendused hierarhilistes kaustades (`/APEX`, `/Publisher`, `/MYATP`) otse VS Code SQL Developer laienduse `connections.json` faili.

## 3. Tehniline Teostus
- Skript [`scripts/register-connections.sh`](../../scripts/register-connections.sh) ja abifunktsioonid.
- SQLcl `connmgr` utiliidi kasutamine paroolide krüpteeritud talletamiseks.

## 4. Verifitseerimine
- Kontrollitud ühenduste teket VS Code külgribal ja paroolivaba ühendumist.
