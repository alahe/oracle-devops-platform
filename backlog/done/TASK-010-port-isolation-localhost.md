# [TASK-010]: Konteinerite Pordi Isoleerimine (`127.0.0.1`)

**Staatus:** `DONE`  
**Prioriteet:** `HIGH`  
**Valdkond:** `Security`  

---

## 1. Probleemi Kirjeldus ja Kontekst
Vaikimisi `0.0.0.0` portide sidumine avab kohalikud teenused samas kohalikus võrgus (Wi-Fi, LAN) olevatele teistele seadmetele.

## 2. Eesmärk ja Oodatav Tulemus
Kõik avaldatavad pordid (DB `1532`/`1533`, ORDS `8088`/`8448`, Publisher `9502`, Web IDE `8090`/`8449`) on rangelt seotud `127.0.0.1` liidesega.

## 3. Tehniline Teostus
- Uuendatud `scripts/internal/generate-compose-override.sh` ja profiilide portide resolutsioon.

## 4. Verifitseerimine
- Kontrollitud `podman ps --format "{{.Ports}}"` väljundit.
