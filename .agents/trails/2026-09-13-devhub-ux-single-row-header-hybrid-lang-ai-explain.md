# Agentic Assembly Line Session Trail: Dev Hub UX Refinement & Single-Row Header

**Kuupäev:** 2026-09-13  
**Fookus:** Dev Hub UX viimistlus, päise ühereastamine, hübriidne keelevalik, kõigile DevOps kaartidele "Explain with AI", lemmikute süsteem ja Mermaid renderduse parandus.  
**Inseneri roll:** UX Guru, Vanem Tarkvarainsener, Kasutaja ja Turvaekspert.

---

## 1. Probleemi ja Kavatsuse Määratlus

Kasutaja tuvastas Dev Hubis mitmed kriitilised UX kitsaskohad:
1. **Päise lagunemine teisele reale:** Kitsamatel ekraanidel või pikkade keelevalikute tõttu tekkis päisesse lisarida otsingu ja keeltega.
2. **Liigne müra päises:** Versioonimärk ja tekstiline "Värskenda" nupp võtsid tarbetut ruumi; "Tagasi" nupp päises oli muutunud üleliigseks nüüd, mil brauseri natiivne tagasiliikumine (`popstate`) töötab usaldusväärselt.
3. **Keelevaliku ebamugavus:** Kuus eraldiseisvat nuppu võtsid palju horisontaalset ruumi. Vajadus oli luua intelligentne hübriidvalik: kaks peamist keelt (EN + lokaalne lemmikkeel, nt ET) alati 1-kliki kaugusel, ülejäänud keeled elegantses lipukestega rippmenüüs.
4. **Kiire ligipääs avavaatele (Home):** Vajadus saada igast vaatest üheainsa klikiga kasutaja eelistatud avavaatele.
5. **AI selgitused DevOps käskudel:** "✨ Explain with AI" nupp oli olemas vaid Setup ja Reset Studios, puududes ülejäänud 27 käsu kaardilt.
6. **DevOps lemmikute süsteem:** Lemmikute täheke oli tuhm ja kasutajale arusaamatu; puudus kategooriate ja lemmikute filterriba.
7. **Mermaid renderdusviga (`spec-devops-portal-des`):** Sekventsidiagrammis tekitasid tekstisisesed jutumärgid süntaksivea, mis Mermaid v10 DOM manipuleerimisel päädis veaga `Cannot read properties of null (reading 'firstChild')`.

---

## 2. Teostatud Muudatused

### 2.1. Päise Ühereastamine & Hübriidne Keelevalik
- **Kompaktne vasakpoolne plokk:** Brändi logo `🚀 Oracle DevOps Platform` muudeti interaktiivseks lingiks (`#brand-home-link`), mis viib kasutaja otse tema kinnitatud avavaatele (`navigateToPinnedHome()`, toetab ka kiirklahvi `Alt+H`).
- **Versiooni viimine jalusesse:** Versioonimärk (`v%PLATFORM_VERSION%`) ja sildserveri staatus viidi päisest rakenduse jalusesse (`footer.hub-footer`), säilitades klikitava Version & Cache Inspectori.
- **Ikoonipõhine "Värskenda":** Tekstiline nupp asendati elegantse ikooninupuga `[ 🔄 ]` koos tooltipiga `Värskenda vahemäluta (⇧R)`.
- **Hübriidne Keelelüliti (`.lang-hybrid-switcher`):**
  - Kaks peamist nuppu: `[ 🇬🇧 EN ]` (kanooniline inglise keel) ja `[ 🇪🇪 ET ]` (lokaalne lemmikkeel).
  - Rippmenüü nupp `[ 🌐 ▼ ]`, mis avab sujuva menüü: `🇫🇮 Suomi (FI)`, `🇸🇪 Svenska (SV)`, `🇱🇻 Latviešu (LV)`, `🇱🇹 Lietuvių (LT)`.
  - Kui kasutaja valib menüüst keele (nt `FI`), saab sellest automaatselt uus sekundaarne kiirvalik ja valik salvestub `localStorage('dev_hub_secondary_lang')`.
- **Eemaldatud liigne "Tagasi" nupp:** Globaalsest päisest eemaldati nupp `[ ◀ Tagasi ]`, toetudes brauseri standardsele ajaloole ja süvavaadete leivapurudele.

### 2.2. DevOps Kaardid: "✨ Explain with AI" ja Lemmikute Filterriba
- Kõigile 27 DevOps käsu kaardile lisati nupp:
  `<button type="button" class="btn btn-secondary btn-sm btn-explain-ai" onclick="explainDevOpsCardWithAi(this)"><span>✨</span> <span data-i18n="studio_btn_explain_ai">Selgita AI-ga</span></button>`.
- `explainDevOpsCardWithAi(btn)` ekstraktib automaatselt kaardi pealkirja, kirjelduse ja bash-käsu ning genereerib vastavalt aktiivsele keelele (EN, ET, FI, SV, LV, LT) täpse selgituspäringu ja avab selle Copiloti / Antigravity sahtlis.
- **Lemmikute süsteem:**
  - Igal kaardil on selge täheke: märkimata kujul diskreetne `☆`, märgitud kujul särav kuldne `⭐` koos kaardi kuldse äärejoonega (`.card.is-pinned`).
  - DevOps vahelehe ülaossa lisati tööriistariba filtrirežiimidega:
    `[ 🌟 Kõik (29) ]`, `[ ⭐ Lemmikud (N) ]`, `[ 🔄 Elutsükkel ]`, `[ 🔐 Wallet & Turvalisus ]`, `[ 🛠️ Tuumiktööriistad ]`, `[ 📸 Snapshotid ]`, `[ 🩺 Tervis & Diag ]` ja kiirfiltri otsinguriba.

### 2.3. Mermaid Diagrammi ja DOM Struktuuriparandused
- Failis `scripts/internal/dev_hub/assets/templates/layout.html` parandati real 1660 liigne `</div>` silt.
- Failis `docs/specs/devops-portal/design.md` parandati sekventsidiagrammis tekstisisesed jutumärgid (`Klikk: 🤖 Küsi AI-lt lahendust`) ja regex sümbolid, välistades parseri krahhi.
- Failides `docs/spec-driven-development-and-assembly-line.md` ja `docs/et/spec-driven-development-and-assembly-line.md` poolitati `GATES` tekst plokis `<br/>` abil vastavalt Reeglile 10 (max 48 sümbolit rea kohta).
- Funktsioonis `renderMermaidInContainer` lisati diagrammi eelkontroll `await mermaid.parse(rawCode)`, mis püüab süntaksivead kinni ja kuvab viisaka hoiatuse lähtekoodiga ilma brauseri DOM vigu tekitamata.
- Testskripti `tests/unit/test-devhub-mermaid-rendering.sh` täiendati automaatse sekventsidiagrammide jutumärkide valideerimisreegliga.

---

## 3. Kvaliteediväravate Tulemused (5 Gates)

1. **Turvalisus (Security Gate):** Kõik käsud ja AI selgitused toetuvad rangelt SEPS auto-login Walletile (`scripts/get-password.sh`). Ei mingeid lihttekstina paroole ega turvariske.
2. **Testid (Tests Gate):**
   - `./tests/unit/test-devhub-mermaid-rendering.sh` — 8/8 sammu läbitud edukalt (100% PASS).
   - `./tests/unit/test-filename-portability.sh` — 2088 faili kontrollitud (100% PASS).
3. **Mitmekeelsus (i18n Gate - Reegel 9):**
   - `./tests/test-multilingual-support.sh` — 12/12 testi läbitud (100% PASS). Kõik 6 keelt (EN, ET, FI, SV, LV, LT) sümmeetriliselt toetatud.
4. **Porditavus (Portability Gate - Reegel 13):** Failinimed ja teed ristplatvormiliselt puhtad Windowsi, macOS-i ja Linuxi jaoks.
5. **Koodi terviklikkus:** `node --check` läbitud ilma vigadeta; HTML DOM tagide tasakaal 100% suletud ja sümmeetriline.
