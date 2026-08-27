# [TASK-012]: Rootless Konteinerite Režiim & Privileegide Piiramine

**Staatus:** `DONE`  
**Prioriteet:** `HIGH`  
**Valdkond:** `Security`  

---

## 1. Probleemi Kirjeldus ja Kontekst
Konteinerist väljamurdmise riskide ennetamine ja minimaalsete õiguste tagamine.

## 2. Eesmärk ja Oodatav Tulemus
Lisada kõigile konteinerite käivitustele `--security-opt=no-new-privileges` ja tagada täielik rootless ühilduvus.

## 3. Tehniline Teostus
- Uuendatud `scripts/internal/generate-compose-override.sh` ja Podman skriptid.

## 4. Verifitseerimine
- Kontrollitud `security_opt` parameetreid aktiivsetel konteineritel.
