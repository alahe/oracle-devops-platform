## Kuidas Importida Ühendused VS Code SQL Developer UI-sse

Oracle SQL Developer Extension for VS Code laienduses saab kõik 4 ühendust korraga sisse importida failist **`sqldev-connections.json`**:

### Samm-sammuline juhend:
1. Ava VS Code-is vasakult külgribalt **Oracle SQL Developer** vahekaart (Oracle logo).
2. **Database Connections** paneeli päises vajuta nuppudele **`...`** (More Actions) või teosta paremklõps ja vali **`Import Connections`**.
3. Avanenud faili sirvimise aknas navigeeri selle projekti kausta:
   `Oracle/oracle-free-db-in-prod/connections/sqldev-connections.json`
4. Vali fail `sqldev-connections.json` ja vajuta **Import**.
5. Kõik 4 ühendust ilmuvad koheselt teie **Database Connections** nimekirja!

---

## Kuidas Lisada Käsitsi (Käsitsi sisestamisel)

Kui soovid lisada ühenduse käsitsi `+` nupuga (nt DBeaver, IntelliJ, Basic-ühendus), saad jooksvad paroolid turvaliselt teada abiskriptiga:
*   **APEX Admin (ADMIN) parool:**
    ```bash
    ./scripts/internal/view-wallet-credential.sh APEX_ADMIN
    ```
*   **APEX Proxy SYS parool:**
    ```bash
    ./scripts/internal/view-wallet-credential.sh DB_APEX_PROXY_SYS
    ```
*   **Publisher SYS parool:**
    ```bash
    ./scripts/internal/view-wallet-credential.sh DB_PUBLISHER_SYS
    ```
*   **Arendaja TEST_DEV parool:**
    ```bash
    ./scripts/internal/view-wallet-credential.sh DB_TEST_DEV
    ```
*   **Veebikasutaja TEST_WEB_USER parool:**
    ```bash
    ./scripts/internal/view-wallet-credential.sh TEST_WEB_USER
    ```

- **Publisher DB (SYS):** Host `localhost`, Port `1531`, Service `FREEPDB1`, User `sys` (Role: `SYSDBA`), Password `<Skripti_Väljund>`
- **APEX Proxy DB (SYS):** Host `localhost`, Port `1532`, Service `FREEPDB1`, User `sys` (Role: `SYSDBA`), Password `<Skripti_Väljund>`
- **APEX Proxy DB (Developer User):** Host `localhost`, Port `1532`, Service `FREEPDB1`, User `TEST_DEV` (Role: `NORMAL`), Password `<Skripti_Väljund>`
  *Märkus: Kasutajale on määratud süsteemne roll **`DB_DEVELOPER_ROLE`**, mis tagab vajalikud õigused arendustöödeks.*

---

## Automaatne registreerimine SQLcl abil (Soovituslik lokaalselt)

Projekti juurest leiad abiskriptid, mis registreerivad andmebaasi ühendused automaatselt otse VS Code SQL Developer Connection Manageri:

1.  **Süsteemsed ühendused (`sys`/`admin` ja skeemid):**
    ```bash
    ./scripts/internal/register-connections-sqlcl.sh
    ```
    See tuvastab automaatselt VS Code laienduse sees asuva SQLcl binääri ja registreerib ühendused kaustapõhiselt (`/APEX` või `/MYATP` ning `/Publisher`).

2.  **Isiklikud arendajate ühendused (`create-developer.sh`):**
    Kui arendaja loob endale isikliku konto (kas käsitsi või `./scripts/setup-all.sh` paigalduse lõpus), registreerib skript uue arendaja ühenduse (`5. Dev <KASUTAJANIMI>`) automaatselt SQLcl-i abil kausta `/APEX` või `/MYATP`. Arendaja ei pea mingeid andmeid käsitsi kopeerima.

### Automaatne käivitamine projekti avamisel (`.vscode/tasks.json`)

Et ühendused tekitataks automaatselt iga kord, kui projekti kaust VS Code-is avatakse, on loodud task failis **`.vscode/tasks.json`**:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Auto-Register Oracle Connections",
      "type": "shell",
      "command": "./scripts/internal/register-connections-sqlcl.sh",
      "runOptions": {
        "runOn": "folderOpen"
      },
      "presentation": {
        "reveal": "silent"
      },
      "problemMatcher": []
    }
  ]
}
```

---

## 🔐 Paroolivaba Ühendus Oracle Wallet (SEPS) Abil

Kohalikus arenduskeskkonnas on andmebaasi ja kliendi vaheline autentimine täielikult turvatud **Oracle Walleti** ja **SEPS (Secure External Password Store)** abil. See võimaldab teha andmebaasi ühendusi ilma plaintext paroolide sisestamiseta või koodi/skripti sisse kirjutamiseta.

### Eeltingimused host-masinas:
1. `TNS_ADMIN` keskkonnamuutuja peab viitama hoidlas olevale `config/tns_admin` kataloogile:
   ```bash
   export TNS_ADMIN=$(pwd)/config/tns_admin
   ```

### 🐳 TNS & Wallet Konteinerite Fallback režiimis
Kui lokaalne host-süsteem ei oma SQLcl tarkvara või see on piiratud (näiteks VS Code SQL Developer laienduse sise-SQLcl, millel puudub PKI walleti tugi), kasutavad paigaldusskriptid automaatselt **SQLcl konteineri fallbacki**.
Konteineri jaoks genereeritakse automaatselt isoleeritud konfiguratsiooni kaust **`config/tns_admin_container`**, mis:
1. Kaardistab TNS aliased (nt `DB_APEX_PROXY_SCHEMA`) otse konteinerite sisevõrgu hostinimedele (`oracle-db-apex-proxy:1521`).
2. Määrab walleti otsinguteeks `/tns` kausta konteineri sees, vältides hosti ja VM-i vahelise failisüsteemi overlay ja inode-ide caching probleeme Java käivitusel.

### 🔌 Ühendamine SQLcl abil (Host-masinast)
Kui `TNS_ADMIN` on seadistatud, saad andmebaasi sisse logida paroolivabalt kasutades järgmisi aliaseid:

*   **APEX Proxy DB (SYS):**
    ```bash
    sql /@db_apex_proxy_sys as sysdba
    ```
*   **Publisher DB (SYS):**
    ```bash
    sql /@db_publisher_sys as sysdba
    ```
*   **APEX Proxy DB (Test Arendaja `TEST_DEV`):**
    ```bash
    sql /@db_test_dev
    ```

### 📂 Ühendamine VS Code SQL Developer Extensionis (TNS & Wallet)
VS Code SQL Developer extension toetab paroolivaba Wallet ühendust. Selleks:
1. Ava VS Code-is **Oracle SQL Developer** laiendus.
2. Ava **Database Connections** paneel ja vajuta uue ühenduse lisamiseks **`+`**.
3. Ühenduse seadistused:
   *   **Connection Type:** Vali **`TNS`** (mitte `Basic`).
   *   **Network Alias:** Vali rippmenüüst soovitud alias (nt `db_apex_proxy_sys` või `db_test_dev`).
   *   **Authentication:** Vali **`External`** (see ütleb laiendusele, et kasutajanimi ja parool loetakse automaatselt Walletist).
   *   **TNS_ADMIN path:** Kui küsitakse, sisesta oma projekti `config/tns_admin` kataloogi täielik absoluutne tee.
4. Testi ja salvesta ühendus!

---

## 🔒 Windows Host ja Korporatiivvõrgu SSL/TLS sertifikaatide usaldamine

Kui arendad Windows masinas (WSL2 kaudu) ja soovid, et lokaalne HTTPS (ORDS-i isesekreeritud sertifikaat) oleks sinu veebibrauseris (Edge/Chrome/Chrome-headless) usaldatud ilma SSL-i hoiatusteta:

### 1. ORDS-i lokaalse sertifikaadi usaldamine Windowsis (ilma administraatori õigusteta)
Kuna Windows nõuab Root CA-de lisamisel interaktiivset kinnitusakent, saab üksiku serveri sertifikaadi usaldada headless-režiimis (ilma kinnituseta ja ilma admin-õigusteta) Windowsi käsurealt:
```cmd
certutil -user -addstore TrustedPeople ssl/cert.crt
```
*(Käivita Windowsi Command Promptist või PowerShellist projekti juurkaustast. See teeb `localhost:8448` ühenduse brauseris roheliseks).*

### 2. Podman VM-i (WSL) seadistamine sisevõrgu CA usaldamiseks (kui sise-Artifactory pulls ebaõnnestuvad SSL veaga)
Kui su ettevõte kasutab sisevõrgu CA-d ja Podman VM ei saa pilte alla laadida SSL-vea tõttu, saad CA sertifikaadi kopeerida ja aktiveerida Podmani virtuaalmasinas järgmiselt:
```bash
# Kopeeri CA sertifikaat Podman VM-i anchors kausta:
podman machine ssh sudo cp /mnt/c/tee/ca.crt /etc/pki/ca-trust/source/anchors/

# Uuenda usaldatavate CA-de nimekirja virtuaalmasinas:
podman machine ssh sudo update-ca-trust
```
