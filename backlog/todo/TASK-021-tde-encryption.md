# [TASK-021]: Automaatne TDE (Transparent Data Encryption) Tugi ja Võtmehaldus

**Staatus:** `TODO`  
**Prioriteet:** `HIGH`  
**Valdkond:** `Security`  

---

## 1. Probleemi Kirjeldus ja Kontekst
Andmebaasi tabeliruumid ja kettalogid peavad toodangus olema krüpteeritud AES-256 võtmega, et kaitsta andmeid varguse või volitamata kettale ligipääsu eest.

## 2. Eesmärk ja Oodatav Tulemus
Automaatne Oracle TDE keystore/walleti initsialiseerimine ja `ENCRYPT_TABLESPACES=ALL` jõustamine kõigis andmebaasides.

## 3. Tehniline Teostus
- Skript `scripts/internal/init-db-instance.sh` ja SQL direktiivid (`ADMINISTER KEY MANAGEMENT SET KEY`).

## 4. Verifitseerimine
- Kontrollpäring `SELECT tablespace_name, encrypted FROM dba_tablespaces;`
