# 🧪 Dev Hub & plattform modernisering testplan

[ 🇬🇧 English ](../devhub-platform-test-plan.md) | [ 🇪🇪 Eesti ](../et/devhub-platform-test-plan.md) | [ 🇫🇮 Suomi ](../fi/devhub-platform-test-plan.md) | [ 🇸🇪 Svenska ](devhub-platform-test-plan.md) | [ 🇱🇻 Latviešu ](../lv/devhub-platform-test-plan.md) | [ 🇱🇹 Lietuvių ](../lt/devhub-platform-test-plan.md)

---

## 1. Översikt och mål

Denna testplan definierar verifieringsstrategin och standardiserade testfall för Developer Hub (`docs/dev-hub.html`) och plattformsorkestreringens moderniseringar.

### Primära testmål:
1. **Exakt och Autonom Statusidentifiering:** Säkerställa att Dev Hub identifierar aktiva blueprints korrekt (inklusive samtidig körning av flera blueprints) och aldrig felaktigt visar stoppade miljöer (såsom BP #3 och BP #4) som aktiva.
2. **Resursmonitorns Pålitlighet:** Verifiera att RAM-mätaren i sidhuvudet (`X GB / 16 GB`) summerar enbart minnesgränser från faktiskt körande containrar.
3. **3-Flikars Modaldialogens Funktionalitet:** Bekräfta sömlös växling mellan flikarna (`Arkitektur`, `Användare & Säkerhet`, `Körningar & Hantering`), interaktiva Mermaid-topologidiagram, SEPS Wallet-uppgifter och realtidsstoppur.
4. **Database Actions & APEX Launchpad:** Testa 5 slutpunktsknappar, JVM/ORDS-uppvärmningsavisering (*warmup toast*) och automatisk kopiering av lösenord till urklipp.
5. **Zero-Trust Säkerhet & SEPS Wallet:** Bevisa att lösenord läses uteslutande minnesbaserat från den krypterade plånboken och aldrig exponeras i klartext i DOM eller diskcache.
6. **Hanterare och Filter:** Verifiera profiler och blueprints listor, kloning, redigering samt filter (`Aktiva`, `Remote` etc.).
7. **Flerspråkighet (i18n):** Garantera 100% paritet över alla 6 språk som stöds (🇬🇧 EN, 🇪🇪 ET, 🇫🇮 FI, 🇸🇪 SV, 🇱🇻 LV, 🇱🇹 LT).

---

## 2. Testpyramid och täckningsmatris

| Nivå | Område | Verktyg | Varaktighet | Frekvens |
| :--- | :--- | :--- | :--- | :--- |
| **Nivå 1** | Kod & Kompilering | Python 3, `test-dev-hub-generation.sh` | ~5–10s | Varje kodändring |
| **Nivå 2** | Integration & Wallet | `check-urls.sh`, `check-wallet.sh` | ~10–20s | Efter containerstart |
| **Nivå 3** | UI / Funktionalitet | Webbläsare, DevTools, Clipboard API | ~3–5 min | Före release |
| **Nivå 4** | Livscykel & Återställning | `setup-all.sh`, `restore-golden-snapshots.sh` | ~15–45s | Vid blueprintbyte |

---

## 3. Detaljerade testfall

### Grupp a: Statusidentifiering och resursövervakning

- **TC-STATUS-01: Identifiering av Enskild Blueprint (BP #0)**
  - *Förutsättning:* Körde `./scripts/setup-all.sh --blueprint 0`.
  - *Förväntat resultat:* BP #0 är grön `Aktiv`. BP #1, #2, #3, #4, #5 är grå `Stoppad`. Sidhuvudet visar `(1 aktiv)` och RAM motsvarar gränsen för BP 0 (~3.0 GB).
- **TC-STATUS-02: Isolering av BP #3 och BP #4**
  - *Förutsättning:* BP #1 körs (`db-alise` och `app-ords` är igång).
  - *Förväntat resultat:* BP #1 är `Aktiv` (`db-alise`). BP #3 (`db-gvenzl`) och BP #4 (`db-adb`) är `Stoppad`. BP 3/4 RAM adderas inte till mätaren.
- **TC-STATUS-03: Samtidig Körning av Flera Blueprints**
  - *Förutsättning:* BP #0 och BP #8 körs samtidigt.
  - *Förväntat resultat:* Båda visas som gröna `Aktiv`. Sidhuvudet visar `(2 aktiva)` och RAM beräknas som summan av båda. Aktiva kort sorteras först.

### Grupp b: 3-flikars modaldialog & livscykelkontroll

- **TC-MODAL-01: Fliknavigering**
  - *Steg:* Klicka på kortet `📐 Arkitektur ↗` eller `⚡ Hantering ↗`. Växla mellan `📐 Arkitektur`, `🔑 Användare`, `⚡ Körningar & Hantering`.
  - *Förväntat resultat:* Omedelbar flikväxling utan sidomladdning; rullgardinsmenyn tillåter byte av blueprint.
- **TC-MODAL-02: Mermaid Topologi och Arkitektur**
  - *Förväntat resultat:* Mermaid SVG renderas korrekt, tekniska portar och containertabell visas felfritt.
- **TC-MODAL-03: Körningar & Hantering (Enhetligt Åtgärdsrutnät & Realtidskonsol)**
  - *Steg:* Kontrollera det enhetliga åtgärdsrutnätet på fliken "Körningar & Hantering" (Distribuera & Växla, Snabbåterställning från Golden Snapshot, Starta om, Djuprensning, Stoppa tjänster, Spara tillstånd). Klicka på valfri åtgärdsknapp (t.ex. `⚡ Aktivera` eller `⚡ Återställ Golden Snapshot`).
  - *Förväntat resultat:* Varje kort visar beskrivning, kopierbar skalkommandoruta och åtgärdsknapp. Realtidsförloppskonsolen (`modal-ops-console`) öppnas direkt under kortrutnätet och rullar automatiskt till vyn med en aktiv timer (`⏱️ 00:01`...). Den duplicerade kommandorutan längst ned har tagits bort.

### Grupp c: Tjänstekort och database Actions (DB Actions) launchpad

- **TC-LAUNCH-01: Kontroll av 5 Slutpunktsknappar**
  - *Förväntat resultat:* Databaskort har 5 knappar: `🛠️ APEX Workspace (DEV)`, `⚙️ APEX Admin (ADMIN)`, `📊 DB Actions (DEV)`, `📊 DB Actions (DBA_ADMIN)`, `🌐 ORDS (<pool>)`.
- **TC-LAUNCH-02: DB Actions Uppvärmningsavisering & Lösenord**
  - *Steg:* Klicka på `📊 DB Actions (DEV)`.
  - *Förväntat resultat:* Avisering om laddningstid (~10–15s) visas, lösenord kopieras till urklipp, rätt URL öppnas.
- **TC-LAUNCH-03: APEX Workspace Lösenordskopiering**
  - *Steg:* Klicka på `🛠️ APEX Workspace (DEV)`.
  - *Förväntat resultat:* Utvecklarlösenord kopieras till urklipp och APEX-inloggningssidan öppnas.

### Grupp d: Oracle SEPS Wallet credential matrix

- **TC-WALLET-01: Dynamisk Kontosamling**
  - *Förväntat resultat:* Alla YAML-profilers konton visas i tabellen under respektive databas och port.
- **TC-WALLET-02: Åtgärdsknappar i Tabell**
  - *Förväntat resultat:* Knapparna `[ 🔑 Lösenord ]`, `[ 📋 Alias ]`, `[ 💻 SQLcl ]`, `[ 📊 DB Actions ]` fungerar och visar bekräftelseavisering.
- **TC-WALLET-03: Zero-Trust Granskning**
  - *Förväntat resultat:* Lösenord exponeras inte i HTML-källkoden; de hämtas minnesbaserat i realtid.

### Grupp e: Hanterare och filter

- **TC-MGR-01: Profilhanterare**
  - *Förväntat resultat:* Vänster lista, höger YAML-innehåll, klonings- och redigeringsfunktion.
- **TC-MGR-02: Blueprinthanterare**
  - *Förväntat resultat:* Vänster lista, höger innehåll, formulär för att lägga till blueprint fungerar.
- **TC-MGR-03: Kortrutnät och Filter**
  - *Förväntat resultat:* Filter (`Aktiva`, `Remote` etc.) fungerar direkt, 3-kolumners layout visas på breda skärmar.

### Grupp f: Flerspråkighet (i18n)

- **TC-I18N-01: Dynamisk Växling Mellan 6 Språk**
  - *Förväntat resultat:* Flaggknappar i sidhuvudet växlar hela användargränssnittet korrekt (EN, ET, FI, SV, LV, LT).

---

## 4. Automatiserade testkommandon

```bash
# 1. Dev Hub kompilering och 6-språks enhetstester
bash tests/unit/test-dev-hub-generation.sh

# 2. SEPS Wallet och anslutningsdiagnostik
./scripts/check-wallet.sh

# 3. Tjänsternas slutpunktsdiagnostik
./scripts/check-urls.sh

# 4. Blueprint CLI-parametrars kontroll
bash tests/unit/test-cli-blueprint-params.sh

# 5. Golden Snapshot snabb återställning regressionstest
bash tests/unit/test-script-restore-golden-snapshots.sh
```
