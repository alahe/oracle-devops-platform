# DevOps Juhtpaneel — Nõuete Spetsifikatsioon (Requirements Specification)

- **Domeen (SCS):** `devops-portal` (Dev Hub vahekaart `⚡ DevOps`)
- **Versioon:** `1.1.0`
- **Staatus:** `Kinnitatud / Tootmises (v2.4.2)`
- **Metoodika:** Julian Wood (Spec-Driven Development — SDD) & Simon Martinelli (SCS)

---

## 1. Äriline Kontekst ja Eesmärk

DevOps juhtpaneel on **Oracle DevOps Platformi** keskne operatsiooniline tööriist, mis võimaldab arendajatel ja administraatoritel hallata konteinerite, andmebaaside, SEPS Walleti, sertifikaatide ja hetktõmmiste elutsüklit ilma käsitsi CLI süntaksit pähe õppimata.

### Kasutajarollid (Personas):
1. **APEX / Andmebaasi Arendaja:** Vajab kiiret, 1-klõpsuga lokaalset keskkonda (FastStart ~15s), kasutajate lisamist (`create-developer.sh`) ja kiiret ligipääsu SQLcl terminalile.
2. **DevOps / Süsteemiadministraator:** Vajab süsteemi sügavlähtestust (`reset-all.sh --system`), sertifikaatide genereerimist ja CI/CD ettevalmistust.
3. **AI Paarisprogrammeerija (Copilot / Antigravity):** Suhtleb juhtpaneeli sillaga (`dev-hub-bridge.py`), diagnoosib logisid ja viib läbi automaatseid tõrkeparandusi (Ralph Loop).

---

## 2. Domeenisõnastik (Glossary — Ühene Keel)

| Mõiste | Definitsioon | Piirangud / Sünonüümid |
| :--- | :--- | :--- |
| **FastStart (-s)** | Andmebaasi taastamine eelsalvestatud kuldsest hetktõmmisest (~15-20s). | Ei tohi segada `--fresh` paigaldusega. |
| **Fresh Start (--fresh)** | Külm paigaldus täiesti puhtalt lehelt ilma hetktõmmisteta. | Kustutab olemasolevad andmeköited enne paigaldust. |
| **Dry-Run (--dry-run)** | Ainult pordi- ja konfiguratsioonitest ilma konteinereid käivitamata. | Ei tee süsteemis püsivaid muudatusi. |
| **Deep Reset (--system)** | Kõikide platvormi konteinerite, andmeköidete ja võrkude hävitamine (Zero-Trace). | Nõuab 2-astmelist kinnitust. |
| **Docked Console** | Ekraani allosast väljalibisev, reguleeritava kõrgusega terminali aken. | Ei katke vahelehtede vahetamisel. |

---

## 3. Funktsionaalsed Nõuded ja Vastuvõtukriteeriumid (Acceptance Criteria)

### [REQ-01]: Ülesannete Eraldatus (Single Responsibility)
- **Kirjeldus:** Vahekaart `⚡ DevOps` sisaldab eranditult **platvormi halduse, elutsükli ja diagnostika käske**. Kõik CI testid ja raportid asuvad vahekaardil `🧪 Testimine`.
- **Vastuvõtukriteerium (Given/When/Then):**
  - **Given:** Arendaja avab Dev Hubi vahekaardi `⚡ DevOps`.
  - **When:** Vaadeldakse kuvatavaid tööriistu ja kaarte.
  - **Then:** Kuvatakse ainult elutsükli, walleti, tuumiktööriistade, hetktõmmiste ja diagnostika toimingud.

### [REQ-02]: 3-Tasemeline Adaptiivne Logiliides (Docked Console)
- **Kirjeldus:** Kaardid ei tohi logi tõttu ebaühtlaselt venida. Kogu reaalajas logivoog suunatakse ekraani allosas asuvasse dokitavasse terminali.
- **Vastuvõtukriteerium:**
  - **Given:** Arendaja käivitab mis tahes DevOps käsu.
  - **When:** Käsk hakkab täituma.
  - **Then:** Ekraani allosast libiseb välja dokitud terminal `#devops-docked-terminal`, stopper näitab aktiivset aega ja logi kuvatakse reaalajas ANSI värvidega.
  - **And:** Arendaja saab vabalt liikuda teistele vahelehtedele ilma logivoo katkemiseta.

### [REQ-03]: Juhendatud Command Studiod (Setup & Reset)
- **Kirjeldus:** Vastastikku välistavad lipud (nt `-s` vs `--fresh`) peavad olema esitatud selgete raadiopillidena koos reaalajas käsu ja mõju eelvaatega.
- **Vastuvõtukriteerium:**
  - **Given:** Arendaja avab Setup Studio.
  - **When:** Arendaja valib `FastStart (-s)`.
  - **Then:** Reaalajas CLI eelvaade uueneb (`./scripts/setup-all.sh -s -y`) ja mõju tekst kinnitab tõmmisest taastamist.

### [REQ-04]: Semantiline Ohutushierarhia ja 2-Astmeline Kinnituskaitse
- **Kirjeldus:** Hävitavad toimingud (`reset-all.sh --system`) omavad punast hoiatusäärist ja nõuavad eksplitsiitset märkeruutu enne käivitusnupu aktiveerumist.
- **Vastuvõtukriteerium:**
  - **Given:** Arendaja valib Reset Studios režiimi `Sügav süsteemipuhastus (--system)`.
  - **When:** Kinnitusmärkeruut on valimata.
  - **Then:** Käivitusnupp on deaktiveeritud (disabled) ja avaneb hoiatuskast `#reset-studio-confirm-gate`.

### [REQ-05]: 1-Kliki AI Lahendus (Copilot & Antigravity)
- **Kirjeldus:** Tõrke korral peab terminal pakkuma kohest 1-kliki võimalust avada AI abi koos logilõiguga.
- **Vastuvõtukriteerium:**
  - **Given:** Käsu täitmisel tekib tõrge (`exit_code != 0` või `ORA-*`).
  - **When:** Kasutaja klikib terminali päises nupule `🤖 Küsi AI-lt lahendust`.
  - **Then:** Avaneb Copiloti või Antigravity sahtel, kuhu on ette täidetud käsu nimi, viimased 25 logirida ja paranduspäring.

### [REQ-06]: 4-Kohaline Tööiteratsioon ja Automaatne Semantiline Reliis (Rule 16)
- **Kirjeldus:** Iga arendusetapp tõstab failis `VERSION` neljandat numbrit (`2.5.0.X`), kompileerib Dev Hubi taustal ning kuvab reaalajas iteratsiooni indikaatorit. Ametlikul `git push` tegevusel viiakse läbi Conventional Commits mõjuanalüüs ning kinnitatakse 3-kohaline SemVer versioon (`vX.Y.Z`) koos Git tagi ja `CHANGELOG.md` sissekandega.
- **Vastuvõtukriteerium (Given/When/Then):**
  - **Given:** Arendaja viib ellu koodimuudatuse või ülesande sammu.
  - **When:** Käivitatakse `./scripts/bump-iteration.sh`.
  - **Then:** Fail `VERSION` suureneb ühe võrra (`2.5.0.1` -> `2.5.0.2`) ja Dev Hubi HTML kompileeritakse taustal.
  - **And:** `git push` eelselt analüüsib pre-push hook commite ja arvutab uue SemVer versiooni (`feat` -> Minor, `fix` -> Patch).

### [REQ-07]: Vaikimisi Avavaate Kinnitamine ja Nutikas Adaptiivne Maandumine (Lahendus 4)
- **Kirjeldus:** Kogenud arendaja ei tohi iga kord portaali avades (`https://localhost:8448`) sattuda algajate alustusjuhendi peale. Süsteem pakub 4-astmelist maandumishierarhiat (URL parameeter > Kinnitatud koduleht 📌 > Viimati külastatud vaheleht > Juhtpaneel) ning võimalust vahelehte 1-klõpsuga avavaateks kinnitada.
- **Vastuvõtukriteerium (Given/When/Then):**
  - **Given:** Arendaja avab `https://localhost:8448` ilma URL-i parameetrita.
  - **When:** Arendaja on eelnevalt klõpsanud `📌 Kinnita avavaateks` (nt `Juhtpaneel` või `DevOps`).
  - **Then:** Portaal avaneb koheselt kinnitatud vahelehel, kuvades vahelehel nööpnõela märki `📌`.
  - **When:** Arendaja pole konkreetset vahelehte kinnitanud, kuid töötas eelmisel sessioonil vahelehel `⚡ DevOps`.
  - **Then:** Portaal taastab automaatselt viimati aktiivse vahelehe (`Smart Context Memory`).
  - **When:** Esmaskülastus või tühi vahemälu.
  - **Then:** Portaal avab vaikimisi elusa `🚀 Juhtpaneeli` (mitte staatilise dokumentatsiooni).

---

## 4. Loogiliste Vastuolude Analüüs (Contradiction Analysis)

| Nõue A | Nõue B | Potentsiaalne Vastuolu | Lahendus / Reegel |
| :--- | :--- | :--- | :--- |
| **FastStart (-s)** | **Puhas algus (--fresh)** | Tõmmisest taastamine ja samaaegne tõmmise eiramine on loogiliselt vastuolulised. | Raadiopillide režiim tagab, et saab valida ainult ühe. Lisaks kontrollib `setup-all.sh` CLI tasemel ja katkestab veaga, kui mõlemad antakse. |
| **Simulatsioon (--dry-run)** | **Puhas algus (--fresh)** | Simulatsioon ei tohi kustutada andmeköiteid. | `--dry-run` režiimis ignoreeritakse `--fresh` kustutusloogikat; CLI tasemel blokeeritud. |

---

## 5. Mittefunktsionaalsed Nõuded (NFR)

1. **Turvalisus (Zero-Trust):** Rangelt keelatud paroolide kettale kirjutamine. Kasutajanimi valideeritakse regexiga `^[a-zA-Z0-9_]{3,30}$`.
2. **Brauseri Mälu (DOM Ring-Buffer):** Terminal hoiab mälus maksimaalselt 1500 rida.
3. **Kohalik Logi (Reegel 1.2):** Täislogi kirjutatakse kohalikule kettale `install_logs/` (ei lähe Giti).
