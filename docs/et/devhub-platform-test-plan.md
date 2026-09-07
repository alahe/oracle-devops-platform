# 🧪 Dev Hub & Platvormi Uuenduste Testimisplaan

[ 🇬🇧 English ](../devhub-platform-test-plan.md) | [ 🇪🇪 Eesti ](devhub-platform-test-plan.md) | [ 🇫🇮 Suomi ](../fi/devhub-platform-test-plan.md) | [ 🇸🇪 Svenska ](../sv/devhub-platform-test-plan.md) | [ 🇱🇻 Latviešu ](../lv/devhub-platform-test-plan.md) | [ 🇱🇹 Lietuvių ](../lt/devhub-platform-test-plan.md)

---

## 1. Ülevaade ja Eesmärgid

Käesolev testimisplaan määratleb verifitseerimisstrateegia ja standardsed kontrolljuhtumid Developer Hubi (`docs/dev-hub.html`) ning platvormi orkestreerimise uuendustele.

### Peamised Testimiseesmärgid:
1. **Täpne ja Autonoomne Staatuste Tuvastus:** Tagada, et Dev Hub tuvastab korrektselt aktiivsed blueprintid (sh mitme blueprinti samaaegne käitus) ega näita ekslikult seisatud keskkondi (nt BP #3 ja BP #4) aktiivsena.
2. **Ressursimonitori Usaldusväärsus:** Kontrollida, et ülariba RAM arvestus (`X GB / 16 GB`) liidab ainult tegelikult töös olevate konteinerite ressursse.
3. **3-Vahelehelise Modaalakna Funktsionaalsus:** Verifitseerida sujuv liikumine vahelehtede (`Arhitektuur`, `Kasutajad`, `Käivitused & Haldus`) vahel, Mermaid võrgugraafikud, kontoandmed ja reaalajas elutsükli stopper.
4. **Database Actions & APEX Launchpad:** Testida 5-otspunkti nuppe, soojenemise (*warmup*) teavitust ja paroolide automaatset lõikelauale kopeerimist.
5. **Zero-Trust Turvalisus ja SEPS Wallet:** Tõendada, et salasõnad loetakse mälupõhiselt ja krüpteeritult, ilma ketta vahemäludesse lekkimata.
6. **Haldurid ja Filtrid:** Kontrollida profiilide ja blueprintide nimekirju, kloonimist, redigeerimist ning filtrite (`Aktiivsed`, `Remote`, jne) toimimist.
7. **Mitmekeelsus (i18n):** Tagada täielik sünkroonsus kõigi 6 toetatud keele lõikes (🇬🇧 EN, 🇪🇪 ET, 🇫🇮 FI, 🇸🇪 SV, 🇱🇻 LV, 🇱🇹 LT).

---

## 2. Testipüramiid ja Katvusmaatriks

| Tase | Valdkond | Tööriistad | Kestus | Käivitussagedus |
| :--- | :--- | :--- | :--- | :--- |
| **Tase 1** | Kood & Kompileerimine | Python 3, `test-dev-hub-generation.sh` | ~5–10s | Iga koodimuudatus |
| **Tase 2** | Integratsioon & Wallet | `check-urls.sh`, `check-wallet.sh` | ~10–20s | Pärast teenuste käivitust |
| **Tase 3** | UI / Funktsionaalsus | Veebibrauser, DevTools, Clipboard API | ~3–5 min | Enne reliisi |
| **Tase 4** | Elutsükkel & Taastus | `setup-all.sh`, `restore-golden-snapshots.sh` | ~15–45s | Blueprintide vahetamisel |

---

## 3. Üksikasjalikud Testjuhtumid

### Rühm A: Staatuse Tuvastus ja Ressursimonitor

- **TC-STATUS-01: Üksiku Blueprinti Tuvastus (BP #0)**
  - *Eeldus:* Käivitatud `./scripts/setup-all.sh --blueprint 0`.
  - *Oodatav tulemus:* BP #0 on roheline `Aktiivne`. BP #1, #2, #3, #4, #5 on hallid `Seisatud`. Ülaribal kuvatakse `(1 aktiivne)` ja RAM kasutus vastab BP 0 limiidile.
- **TC-STATUS-02: BP #3 ja BP #4 Isolatsioon**
  - *Eeldus:* Käivitatud BP #1 (`db-alise` ja `app-ords` on töös).
  - *Oodatav tulemus:* BP #1 on `Aktiivne` (`db-alise`). BP #3 (`db-gvenzl`) ja BP #4 (`db-adb`) on `Seisatud`. Ülaribal ei loeta BP 3 ja BP 4 RAM-i.
- **TC-STATUS-03: Mitme Blueprinti Samaaegne Käitus**
  - *Eeldus:* Käivitatud BP #0 ja lisaks BP #8.
  - *Oodatav tulemus:* Mõlemad on rohelised märgisega `Aktiivne`. Ülaribal kuvatakse `(2 aktiivne)` ning aktiivsed kaardid sorteeritakse ettepoole.

### Rühm B: 3-Vahelehega Modaalaken & Elutsükli Kontroller

- **TC-MODAL-01: Vahelehtede Navigatsioon**
  - *Sammud:* Ava kaardilt `📐 Arhitektuur ↗` või `⚡ Haldus ↗`. Vaheta vahelehti: `📐 Arhitektuur`, `🔑 Kasutajad`, `⚡ Käivitused & Haldus`.
  - *Oodatav tulemus:* Vahelehed vahetuvad viivituseta, päise rippmenüüst saab vahetada vaadeldavat blueprinti.
- **TC-MODAL-02: Mermaid Topoloogia ja Arhitektuur**
  - *Oodatav tulemus:* Kuvatakse Mermaid SVG diagramm, tehnilised pordid ja konteinerite tabel.
- **TC-MODAL-03: Käivitused & Haldus (Ühtne Kaartide Võrgustik & Reaalajas Konsool)**
  - *Sammud:* Vahelehel "Käivitused & Haldus" kontrolli ühtset tegevuste võrgustikku (Aktiviseeri & Juuruta, Kiirtaaste Golden Snapshotist, Taaskäivita & Uuenda, Süvapuhastus, Peata teenused, Salvesta hetkeseis). Klõpsa mis tahes nupul (nt `⚡ Aktiviseeri` või `⚡ Taasta Golden Snapshot`).
  - *Oodatav tulemus:* Igal kaardil kuvatakse selgitus, kopeeritav terminalikäsk ja nupp. Reaalajas edenemisriba ja konsool (`modal-ops-console`) avaneb vahetult kaartide alla ja kerib automaatselt fookusesse koos elava stopperiga (`⏱️ 00:01`...). Dubleeriv eraldiseisev käsuriba akna all on eemaldatud.

### Rühm C: Kaardid ja Database Actions (DB Actions) Launchpad

- **TC-LAUNCH-01: 5 Otspunkti Nuppude Kontroll**
  - *Oodatav tulemus:* Andmebaasikaartidel on 5 nuppu: `🛠️ APEX Workspace (DEV)`, `⚙️ APEX Admin (ADMIN)`, `📊 DB Actions (DEV)`, `📊 DB Actions (DBA_ADMIN)`, `🌐 ORDS (<pool>)`.
- **TC-LAUNCH-02: DB Actions Soojenemise Teavitus (Warmup Toast) & Parool**
  - *Sammud:* Klõpsa `📊 DB Actions (DEV)`.
  - *Oodatav tulemus:* Ilmub teavitus lehe laadimisaja kohta (~10–15s), parool kopeeritakse lõikelauale, avaneb õige URL.
- **TC-LAUNCH-03: APEX Workspace Parooli Kopeerimine**
  - *Sammud:* Klõpsa `🛠️ APEX Workspace (DEV)`.
  - *Oodatav tulemus:* Arendaja parool kopeeritakse lõikelauale ja avaneb APEXi sisselogimisleht.

### Rühm D: Oracle SEPS Wallet Credential Matrix

- **TC-WALLET-01: Dünaamiline Kontode Koondamine**
  - *Oodatav tulemus:* Kõigi YAML profiilide kontod kuvatakse tabelis vastavate andmebaaside ja portide juures.
- **TC-WALLET-02: Multi-Action Nupud Tabelis**
  - *Oodatav tulemus:* Nupud `[ 🔑 Parool ]`, `[ 📋 Alias ]`, `[ 💻 SQLcl ]`, `[ 📊 DB Actions ]` sooritavad vastava toimingu ja kuvavad kinnitusteavituse.
- **TC-WALLET-03: Zero-Trust Turvakontroll**
  - *Oodatav tulemus:* Paroolid ei ole HTML lähtekoodis nähtavad, vaid päritakse reaalajas mälupõhiselt.

### Rühm E: Haldurid ja Filtrid

- **TC-MGR-01: Profiilide Haldur**
  - *Oodatav tulemus:* Vasakul list, paremal YAML sisu, kloonimise ja muutmise võimalus.
- **TC-MGR-02: Blueprintide Haldur**
  - *Oodatav tulemus:* Vasakul list, paremal sisu, kloonimise ja lisamise vorm.
- **TC-MGR-03: Kaardiruudustik ja Filtrid**
  - *Oodatav tulemus:* Filtrid `Aktiivsed`, `Remote` jne töötavad viivituseta, kaardid asetsevad 3-veerulises ruudustikus.

### Rühm F: Mitmekeelsus (i18n)

- **TC-I18N-01: 6 Keele Dünaamiline Lülitus**
  - *Oodatav tulemus:* Päise lipunupud lülitavad kogu kasutajaliidese korrektselt (EN, ET, FI, SV, LV, LT).

---

## 4. Automatiseeritud Testide Käivitamise Käsud

```bash
# 1. Dev Hub kompileerimise ja 6 keele ühikutestid
bash tests/unit/test-dev-hub-generation.sh

# 2. SEPS Wallet ja ühenduste diagnostika
./scripts/check-wallet.sh

# 3. Teenuste otspunktide ja URL-ide diagnostika
./scripts/check-urls.sh

# 4. Blueprintide parameetrite ja profiilide terviklikkuse test
bash tests/unit/test-cli-blueprint-params.sh

# 5. Golden Snapshot kiire taastamise regressioonitest
bash tests/unit/test-script-restore-golden-snapshots.sh
```
