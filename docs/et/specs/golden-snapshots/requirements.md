# Kuldsete Hetktõmmiste Katastroofitaastus — Nõuete Spetsifikatsioon (Requirements)

- **Domeen (SCS):** `golden-snapshots`
- **Versioon:** `1.0.0`
- **Staatus:** `Kinnitatud / Tootmises`
- **Metoodika:** Julian Wood (Spec-Driven Development — SDD) & Simon Martinelli (SCS)

---

## 1. Äriline Kontekst ja Eesmärk

Kuldsete hetktõmmiste (Golden Snapshots) katastroofitaastus võimaldab arendajatel ja automatiseeritud testidel taastada täieliku Oracle 23ai andmebaasi, APEX-i ja ORDS-i keskkonna teadaolevasse puhtasse olekusse ~15–20 sekundiga ilma aeganõudva külmpaigalduseta (~5-8 min).

### Kasutajarollid (Personas):
1. **Tarkvaraarendaja:** Soovib pärast vigast migratsiooni või katsetust taastada baasi algseisu sekunditega (`./scripts/setup-all.sh -s`).
2. **CI/CD Insener:** Vajab puhast, identset andmebaasi iga integratsioonitesti jooksu eel.
3. **AI Agent (Copilot / Antigravity):** Kasutab hetktõmmist turvavõrguna enne suuremahulisi refaktoreerimisi.

---

## 2. Domeenisõnastik (Glossary — Ühene Keel)

| Mõiste | Definitsioon | Piirangud / Sünonüümid |
| :--- | :--- | :--- |
| **Golden Snapshot** | Tihendatud tõmmis andmebaasi andmefailidest puhtas algseisus. | Asub kaustas `snapshots/`. |
| **FastStart (-s)** | Paigalduse kiirenduslipp, mis taastab baasi tõmmisest. | Ei tohi kombineerida `--fresh` lipuga. |
| **Quiesce** | Andmebaasi viimine tehinguliselt puhtasse seisu enne tõmmise loomist. | Tagab failisüsteemi konsistentsi. |

---

## 3. Funktsionaalsed Nõuded ja Vastuvõtukriteeriumid (Acceptance Criteria)

### [REQ-SNAP-01]: Deterministlik Kuldse Tõmmise Loomine
- **Kirjeldus:** Süsteem peab võimaldama luua terve andmebaasi andmefailidest tihendatud tõmmise käsu `./scripts/snapshots/create-golden-snapshots.sh` abil.
- **Vastuvõtukriteerium (Given/When/Then):**
  - **Given:** Andmebaas on terve ja initsialiseeritud.
  - **When:** Käivitatakse `create-golden-snapshots.sh`.
  - **Then:** Kausta `snapshots/` tekib arhiiv ja metaandmete fail SHA-256 kontrollsummaga.

### [REQ-SNAP-02]: ~15-20s Kiirtaastus (FastStart)
- **Kirjeldus:** Käsk `./scripts/setup-all.sh -s` või Dev Hubi FastStart nupp peab taastama baasi alla 30 sekundi.
- **Vastuvõtukriteerium:**
  - **Given:** Kehtiv kuldne hetktõmmis on olemas.
  - **When:** Käivitatakse `./scripts/setup-all.sh -s -y`.
  - **Then:** Andmeköide asendatakse tõmmisega, konteiner käivitub ja tervisekontroll kinnitab valmisolekut alla 30s.

### [REQ-SNAP-03]: Tõmmiste Terviklikkuse ja Versioonikontroll
- **Kirjeldus:** Tõmmise taastamisel kontrollitakse selle vastavust aktiivse andmebaasi versioonile (23ai Free) ja blueprinti konfiguratsioonile.
- **Vastuvõtukriteerium:**
  - **Given:** Tõmmis on rikutud või vale versiooniga.
  - **When:** Käivitatakse taastus.
  - **Then:** Taastus peatatakse veateatega ja pakutakse külmpaigaldust (`--fresh`).

---

## 4. Loogiliste Vastuolude Analüüs (Contradiction Analysis)

| Nõue A | Nõue B | Potentsiaalne Konflikt | Lahendus / Prioriteet |
| :--- | :--- | :--- | :--- |
| **[REQ-SNAP-02] (FastStart taastus)** | **Fresh paigaldus** | Mis juhtub, kui kasutaja annab korraga `-s` ja `--fresh`? | Skriptid ja Dev Hub Setup Studio välistavad need lipud vastastikku (Mutual Exclusion). |
