# 🧪 Dev Hub ir platformos modernizavimo testavimo planas

[ 🇬🇧 English ](../devhub-platform-test-plan.md) | [ 🇪🇪 Eesti ](../et/devhub-platform-test-plan.md) | [ 🇫🇮 Suomi ](../fi/devhub-platform-test-plan.md) | [ 🇸🇪 Svenska ](../sv/devhub-platform-test-plan.md) | [ 🇱🇻 Latviešu ](../lv/devhub-platform-test-plan.md) | [ 🇱🇹 Lietuvių ](devhub-platform-test-plan.md)

---

## 1. Apžvalga ir tikslai

Šis testavimo planas apibrėžia Developer Hub (`docs/dev-hub.html`) ir platformos orkestravimo atnaujinimų patikros strategiją bei standartizuotus testavimo atvejus.

### Pagrindiniai testavimo tikslai:
1. **Tikslus ir Autonomiškas Būsenos Nustatymas:** Užtikrinti, kad Dev Hub teisingai atpažįsta aktyvius blueprintus (įskaitant kelių blueprintų lygiagretų vykdymą) ir niekada klaidingai nerodo sustabdytų aplinkų (pvz., BP #3 ir BP #4) kaip aktyvių.
2. **Išteklių Monitoriaus Patikimumas:** Patikrinti, kad antraštės RAM matuoklis (`X GB / 16 GB`) sumuoja tik faktiškai veikiančių konteinerių atminties ribas.
3. **3 Kortelių Modalinio Lango Funkcionalumas:** Patvirtinti sklandų perjungimą tarp kortelių (`Architektūra`, `Vartotojai ir Saugumas`, `Vykdymai ir Valdymas`), interaktyvias Mermaid topologijos diagramas, SEPS Wallet kredencialus ir realaus laiko vykdymo laikmatį.
4. **Database Actions ir APEX Paleidimo Pultas:** Išbandyti 5 galinių taškų mygtukus, JVM/ORDS apšilimo pranešimą (*warmup toast*) ir automatinį slaptažodžio kopijavimą į iškarpinę.
5. **Zero-Trust Saugumas ir SEPS Wallet:** Įrodyti, kad slaptažodžiai nuskaitomi išskirtinai atmintyje iš šifruotos piniginės ir niekada neišsaugomi atviru tekstu DOM ar disko podėlyje.
6. **Valdytojai ir Filtrai:** Patikrinti profilių ir blueprintų sąrašus, klonavimą, redagavimą ir filtrų (`Aktyvūs`, `Remote` ir kt.) veikimą.
7. **Daugiakalbystė (i18n):** Užtikrinti 100% paritetą visomis 6 palaikomomis kalbomis (🇬🇧 EN, 🇪🇪 ET, 🇫🇮 FI, 🇸🇪 SV, 🇱🇻 LV, 🇱🇹 LT).

---

## 2. Testavimo piramidė ir aprėpties matrica

| Lygis | Sritis | Įrankiai | Trukmė | Dažnumas |
| :--- | :--- | :--- | :--- | :--- |
| **1 lygis** | Kodas ir Kompiliavimas | Python 3, `test-dev-hub-generation.sh` | ~5–10s | Kiekvienas kodo pakeitimas |
| **2 lygis** | Integracija ir Wallet | `check-urls.sh`, `check-wallet.sh` | ~10–20s | Paleidus konteinerius |
| **3 lygis** | UI / Funkcionalumas | Naršyklė, DevTools, Clipboard API | ~3–5 min | Prieš leidimą |
| **4 lygis** | Gyvavimo Ciklas ir Atkūrimas | `setup-all.sh`, `restore-golden-snapshots.sh` | ~15–45s | Keičiant blueprintus |

---

## 3. Išsamūs testavimo atvejai

### A grupė: Būsenos nustatymas ir išteklių stebėsena

- **TC-STATUS-01: Pavienio Blueprinto Nustatymas (BP #0)**
  - *Sąlyga:* Paleistas `./scripts/setup-all.sh --blueprint 0`.
  - *Laukiamas rezultatas:* BP #0 yra žalias `Aktyvus`. BP #1, #2, #3, #4, #5 yra pilki `Sustabdytas`. Antraštėje rodoma `(1 aktyvus)` ir RAM atitinka BP 0 limitą (~3.0 GB).
- **TC-STATUS-02: BP #3 ir BP #4 Izoliavimas**
  - *Sąlyga:* BP #1 veikia (`db-alise` ir `app-ords` paleisti).
  - *Laukiamas rezultatas:* BP #1 yra `Aktyvus` (`db-alise`). BP #3 (`db-gvenzl`) ir BP #4 (`db-adb`) yra `Sustabdytas`. BP 3/4 RAM nepridedamas prie matuoklio.
- **TC-STATUS-03: Kelių Blueprintų Lygiagretus Vykdymas**
  - *Sąlyga:* BP #0 ir BP #8 veikia lygiagrečiai.
  - *Laukiamas rezultatas:* Abu rodomi žaliai `Aktyvus`. Antraštėje rodoma `(2 aktyvūs)` ir RAM apskaičiuojamas kaip abiejų suma. Aktyvios kortelės rūšiuojamos priekyje.

### B grupė: 3 kortelių modalinis langas ir valdiklis

- **TC-MODAL-01: Kortelių Naršymas**
  - *Žingsniai:* Spustelėkite kortelėje `📐 Architektūra ↗` arba `⚡ Valdymas ↗`. Perjunkite tarp `📐 Architektūra`, `🔑 Vartotojai`, `⚡ Vykdymai ir Valdymas`.
  - *Laukiamas rezultatas:* Momentinis kortelių perjungimas be puslapio perkrovimo; išskleidžiamasis meniu leidžia perjungti blueprintą.
- **TC-MODAL-02: Mermaid Topologija ir Architektūra**
  - *Laukiamas rezultatas:* Mermaid SVG atvaizduojamas nepriekaištingai, techniniai prievadai ir konteinerių lentelė yra tikslūs.
- **TC-MODAL-03: Vykdymai ir Valdymas (Vieningas Veiksmų Tinklelis & Realaus Laiko Konsolė)**
  - *Žingsniai:* Skirtuke "Vykdymai ir Valdymas" patikrinkite vieningą veiksmų kortelių tinklelį (Įdiegti & Perjungti, Greitas atkūrimas iš Auksinės kopijos, Paleisti iš naujo, Gilus išvalymas, Sustabdyti paslaugas, Išsaugoti būseną). Spustelėkite bet kurį veiksmo mygtuką (pvz., `⚡ Aktyvuoti` arba `⚡ Atkurti Auksinę Kopiją`).
  - *Laukiamas rezultatas:* Kiekvienoje kortelėje pateikiamas paaiškinimas, nukopijuojamas apvalkalo komandos laukas ir mygtukas. Realaus laiko eigos konsolė (`modal-ops-console`) atsidaro tiesiai po kortelėmis ir automatiškai slenka į vaizdą su veikiančiu laikmačiu (`⏱️ 00:01`...). Pasikartojantis komandų blokas lango apačioje yra pašalintas.

### C grupė: Paslaugų kortelės ir database Actions paleidimo pultas

- **TC-LAUNCH-01: 5 Galinių Taškų Mygtukų Patikra**
  - *Laukiamas rezultatas:* Duomenų bazių kortelėse yra 5 mygtukai: `🛠️ APEX Workspace (DEV)`, `⚙️ APEX Admin (ADMIN)`, `📊 DB Actions (DEV)`, `📊 DB Actions (DBA_ADMIN)`, `🌐 ORDS (<pool>)`.
- **TC-LAUNCH-02: DB Actions Apšilimo Pranešimas ir Slaptažodis**
  - *Žingsniai:* Spustelėkite `📊 DB Actions (DEV)`.
  - *Laukiamas rezultatas:* Pasirodo pranešimas apie įkėlimo laiką (~10–15s), slaptažodis nukopijuojamas į iškarpinę, atidaromas teisingas URL.
- **TC-LAUNCH-03: APEX Workspace Slaptažodžio Kopijavimas**
  - *Žingsniai:* Spustelėkite `🛠️ APEX Workspace (DEV)`.
  - *Laukiamas rezultatas:* Kūrėjo slaptažodis nukopijuojamas į iškarpinę ir atidaromas APEX prisijungimo puslapis.

### D grupė: Oracle SEPS Wallet credential matrix

- **TC-WALLET-01: Dinaminis Paskyrų Sujungimas**
  - *Laukiamas rezultatas:* Visi YAML profilių vartotojai rodomi lentelėje prie atitinkamų duomenų bazių ir prievadų.
- **TC-WALLET-02: Veiksmų Mygtukai Lentelėje**
  - *Laukiamas rezultatas:* Mygtukai `[ 🔑 Slaptažodis ]`, `[ 📋 Alias ]`, `[ 💻 SQLcl ]`, `[ 📊 DB Actions ]` atlieka veiksmą ir rodo patvirtinimo pranešimą.
- **TC-WALLET-03: Zero-Trust Saugumo Patikra**
  - *Laukiamas rezultatas:* Slaptažodžiai nėra matomi HTML kode; jie gaunami realiu laiku atmintyje iš piniginės.

### E grupė: Valdytojai ir filtrai

- **TC-MGR-01: Profilių Valdytojas**
  - *Laukiamas rezultatas:* Kairėje sąrašas, dešinėje YAML turinys, klonavimo ir redagavimo galimybė.
- **TC-MGR-02: Blueprintų Valdytojas**
  - *Laukiamas rezultatas:* Kairėje sąrašas, dešinėje konfigūracija, pridėjimo forma veikia.
- **TC-MGR-03: Kortelių Tinklelis ir Filtrai**
  - *Laukiamas rezultatas:* Filtrai (`Aktyvūs`, `Remote` ir kt.) veikia nedelsiant, 3 stulpelių išdėstymas veikia.

### F grupė: Daugiakalbystė (i18n)

- **TC-I18N-01: 6 Kalbų Dinaminis Perjungimas**
  - *Laukiamas rezultatas:* Vėliavėlių mygtukai nepriekaištingai perjungia sąsajos kalbą (EN, ET, FI, SV, LV, LT).

---

## 4. Automatizuotos testavimo komandos

```bash
# 1. Dev Hub kompiliavimas ir 6 kalbų vienetų testai
bash tests/unit/test-dev-hub-generation.sh

# 2. SEPS Wallet ir ryšių diagnostika
./scripts/check-wallet.sh

# 3. Paslaugų galinių taškų diagnostika
./scripts/check-urls.sh

# 4. Blueprint CLI parametrų patikra
bash tests/unit/test-cli-blueprint-params.sh

# 5. Golden Snapshot greito atkūrimo regresijos testas
bash tests/unit/test-script-restore-golden-snapshots.sh
```
