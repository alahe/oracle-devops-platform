# Blueprints ja dünaamiline porditopoloogia — nõuete spetsifikatsioon (Requirements)

- **Domeen (SCS):** `blueprints-topology`
- **Versioon:** `1.0.0`
- **Staatus:** `Kinnitatud / Tootmises`
- **Metoodika:** Julian Wood (Spec-Driven Development — SDD) & Simon Martinelli (SCS)

---

## 1. Äriline Kontekst ja Eesmärk

Platvorm pakub 12 kanoonilist arhitektuurilist blueprinti (`config/blueprints/.env.*`), mis võimaldavad arendusmeeskondadel deklaratiivselt konfigureerida erinevaid teenuseid (APEX, ORDS, Analytics Publisher, Forms 14c, Web-IDE). Dünaamiline porditopoloogia tagab, et pordikonfliktid host-masinas lahendatakse automaatselt enne konteinerite käivitamist.

### Kasutajarollid (Personas):
1. **Süsteemiarhitekt:** Valib projekti vajadustele vastava pinu (nt BP 3 APEX Dev, BP 6 Publisher, BP 7 Forms).
2. **DevOps Insener:** Lülitab pinusid ümber (`module-toggle.sh`) ilma tuumikbaasi andmekadu riskimata.
3. **AI Agent:** Loeb blueprinti `.env` faili ja genereerib vastava `podman-compose.override.yml`.

---

## 2. Domeenisõnastik (Glossary — Ühene Keel)

| Mõiste | Definitsioon | Piirangud / Sünonüümid |
| :--- | :--- | :--- |
| **Blueprint** | Deklaratiivne keskkonna konfiguratsioonifail (`config/blueprints/.env.bp*`). | Ei sisalda paroole ega pordinumbreid. |
| **Core Base Protection** | Printsiip, kus tuumikandmebaas (db-oracle) säilib blueprintide vahetamisel. | Kaitseb andmeid kustutamise eest. |
| **Dynamic Port Topology** | Skriptipõhine host-portide eraldamine ja kontroll (`resolve-topology.sh`). | Väldib `bind: address already in use` vigu. |

---

## 3. Funktsionaalsed Nõuded ja Vastuvõtukriteeriumid (Acceptance Criteria)

### [REQ-BP-01]: 12 Kanoonilise Blueprinti Tugi
- **Kirjeldus:** Süsteem peab toetama 12 kanoonilist blueprinti (0 kuni 11), mis katavad APEX-i, ORDS-i, Publisheri, Formsi ja Web-IDE kombinatsioone.
- **Vastuvõtukriteerium (Given/When/Then):**
  - **Given:** Arendaja valib suvalise blueprinti (0–11).
  - **When:** Käivitatakse `./scripts/module-toggle.sh bp<N>`.
  - **Then:** Konfiguratsioon `.env` lingitakse vastavale blueprintile ja `generate-compose-override.sh` genereerib kehtiva compose-faili.

### [REQ-BP-02]: Dünaamiline Porditopoloogia ja Konfliktikaitse
- **Kirjeldus:** Enne konteinerite käivitamist kontrollib `resolve-topology.sh`, et vajalikud host-pordid (1521, 8088, 8448, 9001 jne) on vabad.
- **Vastuvõtukriteerium:**
  - **Given:** Port on hõivatud teise rakenduse poolt.
  - **When:** Käivitatakse pordikontroll.
  - **Then:** Süsteem hoiatab kasutajat ja eraldab alternatiivse vaba pordi või annab selge juhise.

### [REQ-BP-03]: Tuumikbaasi Puutumatus (Core Base Protection)
- **Kirjeldus:** Blueprinti vahetamisel ei tohi tuumikandmebaasi andmeköidet (`oracle-data`) ega kasutajate skeeme kustutada.
- **Vastuvõtukriteerium:**
  - **Given:** Andmebaasis on loodud arendaja tabelid.
  - **When:** Blueprint vahetatakse BP 3-lt BP 6-le.
  - **Then:** Andmed säilivad ja uus teenus ühendub olemasoleva baasiga.

---

## 4. Loogiliste Vastuolude Analüüs (Contradiction Analysis)

| Nõue A | Nõue B | Potentsiaalne Konflikt | Lahendus / Prioriteet |
| :--- | :--- | :--- | :--- |
| **[REQ-BP-01] (12 Blueprinti)** | **[REQ-BP-02] (Pordid)** | Mitme teenuse samaaegsel käivitamisel võivad pordid kattuda. | Igal blueprintil on rangelt isoleeritud pordivahemikud ja virtuaalsed profiilid. |
