# Zero-Trust SEPS Wallet — nõuete spetsifikatsioon (Requirements Specification)

- **Domeen (SCS):** `wallet-security`
- **Versioon:** `1.0.0`
- **Staatus:** `Kinnitatud / Tootmises`
- **Metoodika:** Julian Wood (Spec-Driven Development — SDD) & Simon Martinelli (SCS)

---

## 1. Äriline Kontekst ja Eesmärk

Oracle SEPS (Secure External Password Store) auto-login wallet on platvormi keskne turvakomponent, mis võimaldab arendajatel, skriptidel, CI/CD konveieritel ja Dev Hubil suhelda andmebaasiga täielikult paroolivabalt ja krüpteeritult. Süsteem kõrvaldab paroolide salvestamise konfiguratsioonifailidesse või keskkonnamuutujatesse, tagades Zero-Trust arhitektuuri vastavuse.

### Kasutajarollid (Personas):
1. **APEX / Andmebaasi Arendaja:** Logib andmebaasi sisse paroolivabalt käsurealt (`./scripts/sqlcl.sh /@DB_DEV`) või VS Code laienduse kaudu ilma paroole teadmata või kopeerimata.
2. **DBA / Turvajuht:** Nõuab, et saladusi hoitakse krüpteeritult kettal (AES-256) ja dekrüpteeritakse ainult käitusajal mälus (JIT in-memory).
3. **AI Paarisprogrammeerija (Copilot / Antigravity):** Loeb volitusi lokaalsest rahakotist käsu `./scripts/get-password.sh <alias>` abil ilma plaintext-faile kettale tekitamata.

---

## 2. Domeenisõnastik (Glossary — Ühene Keel)

| Mõiste | Definitsioon | Piirangud / Sünonüümid |
| :--- | :--- | :--- |
| **SEPS Wallet** | Oracle Secure External Password Store automaatse sisselogimise rahakott (`cwallet.sso`). | Mitte segi ajada TLS/SSL sertifikaatide rahakotiga. |
| **cwallet.sso** | Sümmeetriliselt krüpteeritud auto-login fail, mida Oracle kliendid kasutavad paroolivabaks ühenduseks. | Asub rangelt kataloogis `wallet/`. |
| **ewallet.p12** | PKCS#12 formaadis põhirahakott, mida kaitseb Wallet Master Password. | Kasutatakse uute volituste lisamiseks ja muutmiseks (`mkstore`). |
| **Zero-Trust Rule 5** | Reegel, mis keelab paroolide salvestamise plaintext-failidesse (`.env`, `.json`, `.txt`). | Rangelt jõustatud CI ja lokaalsete testidega. |
| **Credential Rotation** | Tuumikparoolide asendamine uute kõrge entroopiaga saladustega ilma süsteemi seisakuta. | `./scripts/internal/rotate-credentials.sh`. |

---

## 3. Funktsionaalsed Nõuded ja Vastuvõtukriteeriumid (Acceptance Criteria)

### [REQ-SEC-01]: Krüpteeritud Hoiustamine Kettal (AES-256 Encryption at Rest)
- **Kirjeldus:** Kõik andmebaasi kasutajate paroolid ja ühendusatribuudid peavad kettal asuma rangelt krüpteeritud Oracle SEPS Walletis (`cwallet.sso` / `ewallet.p12`) või Podman krüpteeritud saladuste hoidlas.
- **Vastuvõtukriteerium (Given/When/Then):**
  - **Given:** Süsteem seadistatakse käsu `./scripts/setup-all.sh` või Dev Hubi kaudu.
  - **When:** Rahakott genereeritakse skriptiga `create-wallet.sh`.
  - **Then:** Kataloogi `wallet/` tekivad `cwallet.sso` ja `ewallet.p12` õigustega `0600`.
  - **And:** Kettale ei teki ühtegi plaintext `.txt`, `.json` või `.env` paroolifaili.

### [REQ-SEC-02]: Dünaamiline Mälusisene Lugemine (JIT In-Memory Decryption)
- **Kirjeldus:** Rakendused ja abiskriptid tohivad parooli küsida ainult vajaduse tekkimisel mälus käsu `./scripts/get-password.sh <alias>` kaudu.
- **Vastuvõtukriteerium:**
  - **Given:** Arendaja või skript vajab konkreetse aliase parooli.
  - **When:** Käivitatakse `./scripts/get-password.sh DB_DEV`.
  - **Then:** Skript dekrüpteerib parooli `mkstore` abil otse mällu ja väljastab standardväljundisse.
  - **And:** Vahepealseid ajutisi faile kettale ei looda.

### [REQ-SEC-03]: Paroolivaba SQLcl ja VS Code Ühenduvus
- **Kirjeldus:** SQLcl CLI ja VS Code Oracle laiendus peavad suutma andmebaasiga ühenduda parooli sisestamata, kasutades TNS aliast ja SEPS Walletit (`/@ALIAS`).
- **Vastuvõtukriteerium:**
  - **Given:** SEPS Wallet on genereeritud ja `TNS_ADMIN` viitab kaustale `wallet/`.
  - **When:** Käivitatakse `./scripts/sqlcl.sh /@DB_DEV`.
  - **Then:** Ühendus õnnestub koheselt ilma parooli küsimata (`Connected to: Oracle Database 23ai Free`).

### [REQ-SEC-04]: Null-Seisakuga Paroolide Roteerimine (Zero-Downtime Rotation)
- **Kirjeldus:** Paroolide vahetamisel uuendatakse esmalt andmebaasi kasutaja parool ja seejärel vastav kirje SEPS Walletis ilma teisi ühendusi katkestamata.
- **Vastuvõtukriteerium:**
  - **Given:** Süsteem töötab ja ühendused toimivad.
  - **When:** Käivitatakse volituste roteerimise skript.
  - **Then:** Andmebaasis ja SEPS Walletis uuendatakse parool ning uus paroolivaba ühendus testitakse edukalt.

---

## 4. Loogiliste Vastuolude Analüüs (Contradiction Analysis)

| Nõue A | Nõue B | Potentsiaalne Konflikt | Lahendus / Prioriteet |
| :--- | :--- | :--- | :--- |
| **[REQ-SEC-01] (Krüpteeritud ketas)** | **[REQ-SEC-03] (Paroolivaba ühendus)** | Kuidas ühenduda parooli sisestamata, kui fail on krüpteeritud? | Oracle SEPS `cwallet.sso` auto-login mehhanism dekrüpteerib faili masina lokaalse võtme abil mälus. |
| **[REQ-SEC-02] (Mälusisene lugemine)** | **[REQ-SEC-04] (Roteerimine)** | Roteerimise ajal võib vana parool olla mälus vahemälus. | Skript tühjendab koheselt mälumuutujad ja kontrollib uue parooli kehtivust otse baasis. |
