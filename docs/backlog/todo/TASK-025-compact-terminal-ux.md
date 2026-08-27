# [TASK-025]: Terminali Progressi ja Ajakulu Kompaktne Kuvamine

**Staatus:** `TODO`  
**Prioriteet:** `MEDIUM`  
**Valdkond:** `Tooling`  

---

## 1. Probleemi Kirjeldus ja Kontekst
Pikkade operatsioonide ajal ei tohi terminali ekraan risustuda sadade korduvate ridadega, kuid arendaja vajab selget reaalajas teadmist, et töö käib.

## 2. Eesmärk ja Oodatav Tulemus
Ühel real kohapeal uuenev TTY staatusriba (`\r\033[K`) koos spinneri ja sekundiloenduriga interaktiivses terminalis ning harv kokkuvõte logifailides.

## 3. Tehniline Teostus
- Funktsiooni `print_progress` ja `run_with_live_timer` optimeerimine failis [`scripts/internal/common.sh`](../../scripts/internal/common.sh).

## 4. Verifitseerimine
- Visuaalne kontroll terminalis ja logifailide analüüs.
