# [Feature / SCS Name] — Nõuete Spetsifikatsioon (Requirements Specification)

- **Domeen (SCS):** `[nt: devops-portal, alis-core, publisher]`
- **Versioon:** `1.0.0`
- **Staatus:** `[Kavand | Kinnitatud | Teostuses | Tootmises]`
- **Metoodika:** Julian Wood (Spec-Driven Development — SDD) & Simon Martinelli (SCS)

---

## 1. Äriline Kontekst ja Eesmärk

Kirjelda lühidalt ärilist probleemi, mida see süsteem või moodul lahendab, ja miks seda tehakse.

### Kasutajarollid (Personas):
1. **[Roll 1, nt: APEX Arendaja]:** Vajab...
2. **[Roll 2, nt: DBA / DevOps Insener]:** Vajab...
3. **[Roll 3, nt: AI Paarisprogrammeerija (Copilot / Antigravity)]:** Vajab...

---

## 2. Domeenisõnastik (Glossary — Ühene Keel)

Iga mõiste peab olema üheselt defineeritud, et välistada AI ja meeskonnaliikmete vahelisi väärtõlgendusi:

| Mõiste | Definitsioon | Piirangud / Sünonüümid |
| :--- | :--- | :--- |
| **[Termin 1]** | Mida see termin selles süsteemis täpselt tähendab. | Mitte segi ajada [Teise Asjaga]. |
| **[Termin 2]** | ... | ... |

---

## 3. Funktsionaalsed Nõuded ja Vastuvõtukriteeriumid (Acceptance Criteria)

Iga nõue omab unikaalset identifikaatorit `[REQ-XX]` ja formaalset käitumuslikku kirjeldust (*Given / When / Then*):

### [REQ-01]: [Nõude lühinimi]
- **Kirjeldus:** Süsteem peab...
- **Vastuvõtukriteerium (Gherkin):**
  - **Given (Eeldus):** ...
  - **When (Kui toimub sündmus):** ...
  - **Then (Siis on tulemus):** ...
- **Negatiivne voog / Servajuhud (Edge Cases):**
  - Kui sisend on vigane või teenus kättesaamatu, siis...

### [REQ-02]: [Teise nõude nimi]
- **Kirjeldus:** ...
- **Vastuvõtukriteerium:**
  - **Given:** ...
  - **When:** ...
  - **Then:** ...

---

## 4. Loogiliste Vastuolude Analüüs (Contradiction Analysis)

Enne koodi kirjutamist teostatav analüüs: kas nõuete vahel esineb vastastikuseid välistusi, matemaatiliselt võimatuid kombinatsioone või SLA vastuolusid?

| Nõue A | Nõue B | Potentsiaalne Konflikt | Lahendus / Prioriteet |
| :--- | :--- | :--- | :--- |
| **[REQ-01]** | **[REQ-02]** | Nt parameetrite samaaegne kasutamine. | Reegel: A välistab B automaatselt. |

---

## 5. Mittefunktsionaalsed Nõuded (NFR) ja Piirangud

1. **Turvalisus (Zero-Trust):** Paroole ei salvestata kettale ega logidesse (Reegel 5). Sisend valideeritakse range regexiga.
2. **Jõudluse SLA:** Toimingu kestus $\le$ [X] sekundit.
3. **Kontekstiakna Piirang (SCS Context Budget):** Spetsifikatsioon ja selle mooduli kood peab tervikuna mahtuma $\le$ [N] rea ulatuses ühte AI kontekstiaknasse.
