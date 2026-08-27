# [TASK-014]: Universaalne Reaalaegne Progress ja Puhverdamata Väljund

**Staatus:** `DONE`  
**Prioriteet:** `MEDIUM`  
**Valdkond:** `Tooling`  

---

## 1. Probleemi Kirjeldus ja Kontekst
Pikematel sammudel (APEX paigaldus, patchimine) puudus reaalajas tagasiside, kui väljund oli suunatud logifaili.

## 2. Eesmärk ja Oodatav Tulemus
Reaalaegne sekundite loendur ja spinner terminalis (`/dev/tty`), säilitades samal ajal puhtad logifailid ilma `\r` koodideta.

## 3. Tehniline Teostus
- Funktsioon `print_progress` failis [`scripts/internal/common.sh`](../../scripts/internal/common.sh).
- `POLL_INTERVAL=2` failis `install-apex.sh`.

## 4. Verifitseerimine
- Kontrollitud terminali tagasisidet ja logide puhtust.
