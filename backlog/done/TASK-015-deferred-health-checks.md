# [TASK-015]: Viivitatud Tsentraalne Tervisekontrolli Arhitektuur

**Staatus:** `DONE`  
**Prioriteet:** `MEDIUM`  
**Valdkond:** `Architecture`  

---

## 1. Probleemi Kirjeldus ja Kontekst
Teenuste liiga varajane kontrollimine paigalduse ajal andis eksitavaid veateateid enne kõigi kasutajate ja basseinide valmimist.

## 2. Eesmärk ja Oodatav Tulemus
Üks keskne ja viivitatud tervisekontroll [`scripts/check-urls.sh`](../../scripts/check-urls.sh), mis valideerib kõik aktiivsed ORDS, APEX ja Publisher teenused korraga pärast paigalduse lõppu.

## 3. Tehniline Teostus
- Skriptid `scripts/check-urls.sh` ja `scripts/internal/generate-setup-report.sh`.

## 4. Verifitseerimine
- Kontrollitud `check-urls.sh` väljundit (kõik aktiivsed basseinid ja TLS staatus).
