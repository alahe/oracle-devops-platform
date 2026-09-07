# 🧪 Dev Hub & Alustan Uudistusten Testaussuunnitelma

[ 🇬🇧 English ](../devhub-platform-test-plan.md) | [ 🇪🇪 Eesti ](../et/devhub-platform-test-plan.md) | [ 🇫🇮 Suomi ](devhub-platform-test-plan.md) | [ 🇸🇪 Svenska ](../sv/devhub-platform-test-plan.md) | [ 🇱🇻 Latviešu ](../lv/devhub-platform-test-plan.md) | [ 🇱🇹 Lietuvių ](../lt/devhub-platform-test-plan.md)

---

## 1. Yleiskatsaus ja Tavoitteet

Tämä testaussuunnitelma määrittelee Developer Hubin (`docs/dev-hub.html`) ja alustan orkestroinnin uudistusten tarkastusstrategian ja standardoidut testitapaukset.

### Ensisijaiset Testaussuunnitelman Tavoitteet:
1. **Tarkka ja Autonominen Tilantunnistus:** Varmistaa, että Dev Hub tunnistaa aktiiviset blueprintit oikein (mukaan lukien useiden blueprinttien samanaikainen käyttö) eikä koskaan näytä pysäytettyjä pinoja (kuten BP #3 ja BP #4) virheellisesti aktiivisina.
2. **Resurssimonitorin Luotettavuus:** Varmistaa, että yläpalkin RAM-mittari (`X GB / 16 GB`) laskee yhteen vain todellisuudessa käynnissä olevien konttien muistirajat.
3. **3-Välilehtisen Modaalidialogin Toiminta:** Vahvistaa saumattoman siirtymisen välilehtien (`Arkkitehtuuri`, `Käyttäjät & Turvallisuus`, `Käynnistykset & Hallinta`) välillä, interaktiiviset Mermaid-topologiakaaviot, SEPS Wallet -tunnukset ja reaaliaikaisen suoritusajastimen.
4. **Database Actions & APEX Launchpad:** Testata 5 päätepistepainiketta, JVM/ORDS-lämpenemisilmoitus (*warmup toast*) ja salasanojen automaattinen kopiointi leikepöydälle.
5. **Zero-Trust -Turvallisuus & SEPS Wallet:** Todistaa, että salasanat luetaan suoraan muistipohjaisesti salatusta lompakosta eikä niitä koskaan kirjoiteta selväkielisenä DOM- tai levyvälimuisteihin.
6. **Hallintapaneelit ja Suodattimet:** Vahvistaa profiilien ja blueprinttien listat, kloonaus, muokkaus sekä suodattimien (`Aktiiviset`, `Remote` jne.) toiminta.
7. **Monikielisyys (i18n):** Taata täydellinen synkronointi kaikkien 6 tuetun kielen välillä (🇬🇧 EN, 🇪🇪 ET, 🇫🇮 FI, 🇸🇪 SV, 🇱🇻 LV, 🇱🇹 LT).

---

## 2. Testauspyramidi ja Kattavuusmatriisi

| Taso | Alue | Työkalut | Kesto | Tiheys |
| :--- | :--- | :--- | :--- | :--- |
| **Taso 1** | Koodi & Kääntäminen | Python 3, `test-dev-hub-generation.sh` | ~5–10s | Jokainen koodimuutos |
| **Taso 2** | Integraatio & Wallet | `check-urls.sh`, `check-wallet.sh` | ~10–20s | Konttien käynnistyksen jälkeen |
| **Taso 3** | UI / Toiminnallisuus | Web-selain, DevTools, Clipboard API | ~3–5 min | Ennen julkaisua |
| **Taso 4** | Elinkaari & Palautus | `setup-all.sh`, `restore-golden-snapshots.sh` | ~15–45s | Blueprinttien vaihdossa |

---

## 3. Yksityiskohtaiset Testitapaukset

### Ryhmä A: Tilantunnistus ja Resurssimonitori

- **TC-STATUS-01: Yksittäisen Blueprintin Tunnistus (BP #0)**
  - *Edellytys:* Suoritettu `./scripts/setup-all.sh --blueprint 0`.
  - *Odotettu tulos:* BP #0 on vihreä `Aktiivinen`. BP #1, #2, #3, #4, #5 ovat harmaita `Pysäytetty`. Yläpalkissa näkyy `(1 aktiivinen)` ja RAM vastaa BP 0:n rajaa (~3.0 GB).
- **TC-STATUS-02: BP #3:n ja BP #4:n Eristäminen**
  - *Edellytys:* BP #1 on käynnissä (`db-alise` ja `app-ords` käynnissä).
  - *Odotettu tulos:* BP #1 on `Aktiivinen` (`db-alise`). BP #3 (`db-gvenzl`) ja BP #4 (`db-adb`) ovat `Pysäytetty`. BP 3/4 RAM-muistia ei lisätä yläpalkin summaan.
- **TC-STATUS-03: Useiden Blueprinttien Samanaikainen Käyttö**
  - *Edellytys:* BP #0 ja BP #8 käynnissä.
  - *Odotettu tulos:* Molemmat näkyvät vihreinä `Aktiivinen`. Yläpalkissa näkyy `(2 aktiivinen)` ja RAM lasketaan molempien summana. Aktiiviset kortit lajitellaan ensimmäisiksi.

### Ryhmä B: 3-Välilehtinen Modaalidialogi & Elinkaariohjain

- **TC-MODAL-01: Välilehtien Navigointi**
  - *Askeleet:* Napsauta kortilla `📐 Arkkitehtuuri ↗` tai `⚡ Hallinta ↗`. Vaihda välilehtiä: `📐 Arkkitehtuuri`, `🔑 Käyttäjät`, `⚡ Käynnistykset & Hallinta`.
  - *Odotettu tulos:* Välilehdet vaihtuvat välittömästi ilman sivun uudelleenlatausta; yläpalkin pudotusvalikko mahdollistaa blueprintin vaihtamisen.
- **TC-MODAL-02: Mermaid-Topologia ja Arkkitehtuuri**
  - *Odotettu tulos:* Mermaid SVG -kaavio renderöityy virheettömästi, tekniset portit ja kontit näkyvät oikein.
- **TC-MODAL-03: Käynnistykset & Hallinta (Yhtenäinen Toimintoruudukko & Live-Konsoli)**
  - *Askeleet:* Tarkasta "Käynnistykset & Hallinta" -välilehdellä yhtenäinen toimintokorttiruudukko (Ota käyttöön & Vaihda, Nopea Palautus Kultaisesta Vedoksesta, Käynnistä uudelleen, Syvä Puhdistus, Pysäytä palvelut, Tallenna tila). Napsauta mitä tahansa toimintopainiketta (esim. `⚡ Aktivoi` tai `⚡ Palauta Kultainen Vedos`).
  - *Odotettu tulos:* Jokainen kortti sisältää kuvauksen, kopioitavan shell-komentolaatikon ja painikkeen. Reaaliaikainen edistymiskonsoli (`modal-ops-console`) avautuu suoraan korttien alapuolelle ja vierittyy automaattisesti näkyviin live-ajastimella (`⏱️ 00:01`...). Päällekkäinen erillinen komentolaatikko ikkunan alaosassa on poistettu.

### Ryhmä C: Palvelukortit ja Database Actions (DB Actions) Launchpad

- **TC-LAUNCH-01: 5 Päätepistepainikkeen Tarkastus**
  - *Odotettu tulos:* Tietokantakorteilla on 5 painiketta: `🛠️ APEX Workspace (DEV)`, `⚙️ APEX Admin (ADMIN)`, `📊 DB Actions (DEV)`, `📊 DB Actions (DBA_ADMIN)`, `🌐 ORDS (<pool>)`.
- **TC-LAUNCH-02: DB Actions Lämpenemisilmoitus & Salasana**
  - *Askeleet:* Napsauta `📊 DB Actions (DEV)`.
  - *Odotettu tulos:* Ilmoitus latausajasta (~10–15s) ilmestyy, salasana kopioituu leikepöydälle, oikea URL avautuu.
- **TC-LAUNCH-03: APEX Workspace Salasanan Kopiointi**
  - *Askeleet:* Napsauta `🛠️ APEX Workspace (DEV)`.
  - *Odotettu tulos:* Kehittäjän salasana kopioituu leikepöydälle ja APEX-kirjautumissivu avautuu.

### Ryhmä D: Oracle SEPS Wallet Credential Matrix

- **TC-WALLET-01: Dynaaminen Tunnusten Yhdistäminen**
  - *Odotettu tulos:* Kaikkien YAML-profiilien tilit näkyvät taulukossa vastaavien tietokantojen ja porttien kohdalla.
- **TC-WALLET-02: Toimintopainikkeet Taulukossa**
  - *Odotettu tulos:* Painikkeet `[ 🔑 Salasana ]`, `[ 📋 Alias ]`, `[ 💻 SQLcl ]`, `[ 📊 DB Actions ]` suorittavat toimenpiteen ja näyttävät ilmoituksen.
- **TC-WALLET-03: Zero-Trust -Tarkastus**
  - *Odotettu tulos:* Salasanat eivät näy HTML-lähdekoodissa; ne haetaan reaaliaikaisesti muistipohjaisesti lompakosta.

### Ryhmä E: Hallintapaneelit ja Suodattimet

- **TC-MGR-01: Profiilien Hallinta**
  - *Odotettu tulos:* Vasemmalla lista, oikealla YAML-sisältö, kloonaus- ja muokkaustoiminnot.
- **TC-MGR-02: Blueprintien Hallinta**
  - *Odotettu tulos:* Vasemmalla lista, oikealla konfiguraatio, lisäyslomake toimii.
- **TC-MGR-03: Korttiruudukko ja Suodattimet**
  - *Odotettu tulos:* Suodattimet (`Aktiiviset`, `Remote` jne.) toimivat viiveettä, 3 sarakkeen asettelu toimii.

### Ryhmä F: Monikielisyys (i18n)

- **TC-I18N-01: 6 Kielen Dynaaminen Vaihto**
  - *Odotettu tulos:* Yläpalkin liput vaihtavat käyttöliittymän kielen virheettömästi (EN, ET, FI, SV, LV, LT).

---

## 4. Automaattiset Testikomennot

```bash
# 1. Dev Hub kääntäminen ja 6 kielen yksikkötestit
bash tests/unit/test-dev-hub-generation.sh

# 2. SEPS Wallet ja yhteyksien diagnostiikka
./scripts/check-wallet.sh

# 3. Palveluiden päätepisteiden diagnostiikka
./scripts/check-urls.sh

# 4. Blueprint CLI -parametrien tarkistus
bash tests/unit/test-cli-blueprint-params.sh

# 5. Golden Snapshot nopean palautuksen regressiotesti
bash tests/unit/test-script-restore-golden-snapshots.sh
```
