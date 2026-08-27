# [TASK-008]: Logide & Diagnostikafailide Puhastamine (`clean-logs.sh`)

**Staatus:** `DONE`  
**Prioriteet:** `LOW`  
**Valdkond:** `Tooling`  

---

## 1. Probleemi Kirjeldus ja Kontekst
Paigaldustestide ja arenduse käigus koguneb `install_logs/` kausta sadu ajutisi faile ja logiarhiive.

## 2. Eesmärk ja Oodatav Tulemus
Üks lihtne CLI käsk, mis kustutab vanad logid, ajutised unzipped kaustad ja WebLogic diagnostikafailid ilma vajalikke faile puutumata.

## 3. Tehniline Teostus
- Skript [`scripts/clean-logs.sh`](../../scripts/clean-logs.sh) ja ühiktest `tests/unit/test-script-clean-logs.sh`.

## 4. Verifitseerimine
- Testitud logide kustutamist ja säilitusreegleid.
