# [TASK-022]: Loetav Juurfailisüsteem ja Konteineri Rangem Hardening (`--read-only`)

**Staatus:** `TODO`  
**Prioriteet:** `MEDIUM`  
**Valdkond:** `Security`  

---

## 1. Probleemi Kirjeldus ja Kontekst
Konteinerite turvalisuse tõstmine tootmiskeskkonnas nõuab juurfailisüsteemi muutmise keelamist (`--read-only`).

## 2. Eesmärk ja Oodatav Tulemus
Käivitada teenused loetava failisüsteemiga, suunates ajutised kirjutuskaustad (`/tmp`, `/var/run`) `tmpfs` mälupuhvritesse.

## 3. Tehniline Teostus
- Täiendada `scripts/internal/generate-compose-override.sh` ja profiilide konfiguratsioone.

## 4. Verifitseerimine
- Kontrollida, et konteinerid käivituvad edukalt ilma loata failisüsteemi kirjutamiseta.
