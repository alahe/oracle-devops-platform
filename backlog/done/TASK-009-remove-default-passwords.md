# [TASK-009]: Vaikimisi Varuparoolide Eemaldamine ja SEPS Wallet

**Staatus:** `DONE`  
**Prioriteet:** `HIGH`  
**Valdkond:** `Security`  
**Dokumentatsioon:** [docs/turvalisus.md](../../docs/turvalisus.md)  

---

## 1. Probleemi Kirjeldus ja Kontekst
Koodis ja skriptides esinenud vaike-paroolid (`OraclePass2026!`) kujutasid endast turvariski ja ei vastanud toodangustandardile.

## 2. Eesmärk ja Oodatav Tulemus
Kõigi paroolide dünaamiline genereerimine, hoidmine Podman secret store'is ja pärimine paroolivabast **Oracle Walletist (SEPS)** utiliidi `./scripts/get-password.sh <ALIAS>` kaudu.

## 3. Tehniline Teostus
- Skriptid `scripts/get-password.sh`, `scripts/internal/create-wallet.sh`, `scripts/internal/generate-passwords.sh`.
- Kõvakodeeritud paroolide täielik eemaldamine.

## 4. Verifitseerimine
- Kontrollitud `check-wallet.sh` ja `get-password.sh` toimimist.
