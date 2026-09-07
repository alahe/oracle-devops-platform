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

Skriptid kasutavad vaikimisi ja kohustuslikuna **Oracle SQLcl (`sql`)** klienti (Reegel 6 Leping 6) koos Oracle SEPS Walletiga (`./scripts/sqlcl.sh /@ALIAS`), mis tagab paroolivaba ja turvalise ühenduse ilma parooli lekkimiseta protsessitabelis (`ps aux`). Kui kohalikku SQLcl-i pole paigaldatud, käivitatakse automaatselt ephemeral SQLcl konteiner (`container-registry.oracle.com/database/sqlcl:latest`). Vananenud `sqlplus` on platvormi automatiseerimises keelatud.

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

---

## 🌐 Multi-Cloud (Azure VM + OCI Autonomous DB) ja Kaugtestimine

Ettevõtte tasemel hajutatud pilvekeskkonna (Blueprint 4 Cloud ADB + Blueprint 10 ORDS Gateway + Blueprint 11 Analytics Publisher) seadistamiseks ja valideerimiseks:

*   **Samm-sammuline paigaldusjuhend:** **[docs/remote-multicloud-setup-guide.md](remote-multicloud-setup-guide.md)** (eesti keeles: **[docs/et/remote-multicloud-setup-guide.md](et/remote-multicloud-setup-guide.md)**)
*   **Pilveserverisse paigaldamine:** `./scripts/deploy-remote.sh --host <AZURE_IP> --user azureuser --key ~/.ssh/id_rsa --blueprint 10 --wallet ~/Downloads/Wallet_FREEADB.zip`
*   **Automaatne Multi-Cloud valideerimistest:** `./tests/test-remote-multicloud.sh --azure-ip <AZURE_IP> --oci-ip <OCI_IP> --db-alias DB_ADB_ADMIN`

> 💡 *Üksikasjaliku kirjelduse kõigi skriptide parameetrite ja lisalipude kohta leiad failist **[scripts/README.md](../scripts/README.md)**.*

