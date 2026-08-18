# GitHub Actions CI/CD Töövoog & Lokaalne Offline Testimine (SQLcl Projects)

See juhend kirjeldab, kuidas seadistada ja käitada automaatset CI/CD tarnet (deployment) nii päris **GitHub.com serverites** kui ka **lokaalselt ja offline režiimis arendaja arvutis/konteineris** ilma ühegi koodi pushimata.

---

## 1. Arhitektuur & SQLcl Projects

Andmebaasi skeemi versioonihaldus põhineb **Oracle SQLcl Projects (`project`)** tehnoloogial:
- **`project.config.json`** (`.dbtools/project.config.json`): Projekti konfiguratsioon ja skeemid.
- **`project.filters`** (`.dbtools/filters/project.filters`): Objektide välistamise reeglid (nt `TEMP_%` tabelid).
- **`src/`**: Arendusbaasist eksporditud DDL koodibaas.
- **`artifact/`**: Genereritud reliisi ZIP arhiivid (`artifact/*.zip`).

Tarne sooritatakse SQLcl ephemerealse konteineri kaudu käskudega:
```sql
project deploy -file artifact/*.zip
```

---

## 2. Lokaalne Offline Testimine Arendaja Arvutis (`./scripts/test-local-ci.sh`)

Arendaja saab testida tarnet oma masinas ilma internetita ja ilma koodi pushimata.

### Käivituskäsud:

```bash
# 1. Kontrolli workflow süntaksit ja sammusid (Kuivkäivitus / Dry-run):
./scripts/test-local-ci.sh --dry-run

# 2. Käivita täielik lokaalne tarne simulaator oma andmebaasi vastu:
./scripts/test-local-ci.sh

# 3. Käivita lokaalne tarne Nektos 'act' CLI või visuaalse Dashboardi abil:
act -W .github/workflows/deploy-apex.yml
```

### Kuidas paroolid ja Wallet automaatselt toimivad?
Skript `./scripts/test-local-ci.sh` loeb sinu kohalikust SEPS Walletist rekvisiidid ja genereerib automaatselt ajutise `.env.secrets` faili. Arendaja ei pea paroole ega Walleti võtmeid käsitsi sisestama.

---

## 3. GitHub.com CI/CD Seadistamine

Selleks, et tarned töötaksid automaatselt GitHub.com keskkonnas koodi pushimisel `main` harusse:

### 1. Ekspordi lokaalne SEPS Wallet Base64 võtmena:
Käivita utiliit:
```bash
./scripts/internal/export-ci-secrets.sh
```

### 2. Lisa võti GitHub Secrets hoidlasse:
Kopeeri väljastatud Base64 sõne oma GitHub repositooriumi seadetesse:
- **Settings** -> **Secrets and variables** -> **Actions** -> **New repository secret**
- Nimi: `DB_WALLET_BASE64`
- Väärtus: `<kopeeritud_base64_sõne>`

*(Valikuline GitHub CLI käsk: `gh secret set DB_WALLET_BASE64 -b"<base64_sõne>"`)*

---

## 4. Töövoogude Failid (`.github/workflows/`)

| Fail | Kirjeldus | Päästik |
| :--- | :--- | :--- |
| **`deploy-apex.yml`** | SQLcl Projects tarne (`project deploy`) ja APEX rakenduste import. | Push `main`/`release/*` või manuaalne trigger. |
| **`ci-test-suite.yml`** | Kogu süsteemi automaattestide ja kvaliteedivärava käitamine. | Pull Requestid (PR). |
