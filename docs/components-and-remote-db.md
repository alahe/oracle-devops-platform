# Komponentide eraldi paigaldamine ja kaug-andmebaasid (Remote DB)

Kõik projekti skriptid toetavad komponentide eraldi paigaldamist ja neid saab suunata ka kaugserverites asuvate andmebaaside vastu (kliendi-režiimis).

---

## Kaug-andmebaaside (Remote DB) seadistamine

Seadista ühenduse aadressid ja pordid failis `.env`:

```env
# APEX Proxy Database seadistus
APEX_DB_HOST=kaugserveri-ip
APEX_DB_PORT=1521
# TCPS port turvalise TLS/TCPS ühenduse jaoks (vajab walleti seadistust)
APEX_DB_TCPS_PORT=2484
APEX_DB_SERVICE=FREEPDB1

# Publisher Database seadistus
PUBLISHER_DB_HOST=teine-serveri-ip
PUBLISHER_DB_PORT=1521
PUBLISHER_DB_SERVICE=FREEPDB1
```

> [!IMPORTANT]
> **Turvaline paroolihaldus (SEPS):**
> Kaugandmebaaside parooliühendusi (nt `SYS` paroolid) **ei kirjutata kunagi lahtise tekstina** faili `.env`. 
> 
> Kõik andmebaasi sisselogimiseks vajalikud kasutajanimed ja paroolid salvestatakse turvaliselt **Oracle Client Walletisse (Secure External Password Store - SEPS)**. Skriptid loevad ja kasutavad ühenduse loomiseks automaatselt TNS-aliaseid (nt `DB_APEX_PROXY_SYS`), mis pärinevad Walletist paroolivabalt.
> 
> Walleti haldamise, paroolide lisamise ja vaatamise kohta vaata juhendit: **[docs/oracle-wallet-architecture-plan.md](oracle-wallet-architecture-plan.md)**.

Skriptid tuvastavad automaatselt, kas sul on lokaalselt olemas **SQLcl (`sql`)** või **SQL*Plus (`sqlplus`)** ja teostavad päringud üle võrgu (kliendi-režiimis). Kui kohalikke CLI tööriistu pole, kasutatakse automaatselt Podmani konteineri fallback režiimi.

---

## Haldustoimingud ja abiskriptid

Käivita komponente ja haldustoiminguid järgmiselt:

*   **Konteinerite käivitamine:** `./scripts/start-containers.sh`
*   **Konteinerite / andmete täielik kustutamine:** `./scripts/reset-all.sh all`
*   **Volume hetktõmmise (Golden Snapshot) loomine:** `./scripts/create-golden-snapshots.sh`
*   **Volume taastamine hetktõmmisest:** `./scripts/restore-golden-snapshots.sh`
*   **Logifailide puhastamine:** `./scripts/clean-logs.sh`
*   **Hetktõmmiste puhastamine:** `./scripts/clean-golden-snapshots.sh`

*   **Andmebaasi algseadistus (Profiilipõhine):** `./scripts/internal/init-db-instance.sh <profiili_nimi>`
*   **APEX Mootori installeerimine:** `./scripts/internal/install-apex.sh`
*   **APEX Patchi paigaldamine:** `./scripts/internal/apply-apex-patch.sh patches/<patch_filename>.zip`

> 💡 *Üksikasjaliku kirjelduse kõigi skriptide parameetrite ja lisalipude kohta leiad failist **[scripts/README.md](../scripts/README.md)**.*
