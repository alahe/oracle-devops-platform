# Session Trail: Dev Hub Light Theme Ultra-High Contrast & Hardcoded Grey Elimination (v2.5.0.16)

- **Kuupäev:** 2026-09-13
- **Versioon:** `2.5.0.16`
- **Autor:** Antigravity (AI Pair Programmer)

## 1. Probleemi Kirjeldus & Kasutaja Tagasiside
Kasutaja laadis üles ekraanipildi Blueprint #1 modal Diagnostics & Testing sakist koos teatega:
> "Veel on probleem hele halli tekstiga, natuke liiga raske on lugeda."
> "Lisa skilli sisse et rakendus peab pakkuma dark ja light võimalust. Esimene valik on ikkagi dark."

### Tuvastatud kitsaskohad ekraanipildil ja koodibaasis:
1. **Hardcoded inline värvid JavaScriptis (`app.js`):**
   - Kuigi CSS klassid lisati eelmises versioonis, olid elementidel `<p class="bp-action-card-desc">` ja `<p class="bp-diag-card-desc">` inline stiilid `style="color: #cbd5e1;"`. Brauser prioritiseeris inline stiili CSS selektorite ees, jättes teksti heledal taustal tuhmiks halliks.
   - Stop-kaardi pealkiri (`cardStop`): kui tegemist ei olnud core-pinnuga, oli määratud `color: #cbd5e1;` inline.
2. **Käsublokkide (`.code-box`) kontrast:**
   - `.code-box` stiilis oli hardcoded `color: #38bdf8;` (taevassinine), mis heledal taustal `--code-bg: #f1f5f9` omas madalat kontrasti ja oli raskesti loetav.
3. **Kirjelduste ja tekstide kontrastsus heledas teemas:**
   - Slate-700 (`#334155`) tundus teatud ekraanidel ja heledal foonil liiga pehme; vajalik oli sügav, terav ja selge paberilaadne süsimust/antratsiit (`#0f172a` / slate-900).
4. **Dev Hub arhitektuurioskuse täiendus:**
   - Reegel, et rakendus peab toetama nii Dark kui Light teemat, kusjuures vaikimisi esimene valik on alati Dark Theme (`dark-first`), polnud oskuse juhendisse selgesõnaliselt talletatud.

---

## 2. Tehtud Muudatused

### 1. Oskuse ja arhitektuurireeglite täiendus (`.agents/skills/devhub_architecture/SKILL.md`)
- Oskuse metainfosse lisatud: `dark/light dual-theme support (dark default)`.
- Lisatud jaotis **4.12 Dual-Theme Support (Dark & Light) & Dark-First Default Invariant**:
  - Sätestatud, et Dev Hub toetab alati nii tumedat (Dark) kui heledat (Light) vaadet.
  - Vaikimisi esmane valik peab alati olema Dark Theme (`dark`).
  - Värviskeemi vahetamine (Päike/Kuu ikoon ja `Alt+T`) salvestab valiku `localStorage.getItem('dev_hub_theme')`.
  - Heleda teema kontrastinõue: WCAG AAA tase, mustad/süsimustad kirjeldused (`#0f172a` / font-weight: 500).
  - Terminalid ja CLI aknad säilitavad alati tumeda tausta (`#030712`).

### 2. Hardcoded inline stiilide eemaldamine (`scripts/internal/dev_hub/assets/app.js`)
- Eemaldatud `color: #cbd5e1;` järgmistelt elementidelt:
  - `cardStop`: muudetud `color: ${isCore ? '#fbbf24' : 'var(--text-main)'};`
  - `cardRapidRestore` (`.bp-action-card-desc`)
  - `cardRotate` (`.bp-action-card-desc`)
  - `cardCustomSnap` (`.bp-action-card-desc`)
  - `cardDeepReset` (`.bp-action-card-desc`)
  - Specific Tests grid (`.bp-diag-card-desc`)
  - General Platform Diagnostics grid (`.bp-diag-card-desc`)

### 3. Heleda teema ultra-kõrge kontrastsuse reeglid (`scripts/internal/dev_hub/assets/style.css`)
- Uuendatud `[data-theme="light"]` reeglid:
  - Kõik modali kirjeldused ja lõigud (`.bp-modal-subtitle-desc`, `.bp-quickstart-step-desc`, `.bp-comp-desc`, `.bp-action-card-desc`, `.bp-diag-card-desc`, `.bp-tab-content p`) on määratud sügavale antratsiit-mustale: `color: #0f172a !important; font-weight: 500 !important;`.
  - Käsublokkide `.code-box` kontrast heledas teemas:
    `background: #f1f5f9 !important; border-color: #cbd5e1 !important; color: #0369a1 !important; font-weight: 600 !important;` (sügav ookeanisinine, kristallselge loetavus).
  - Kopeerimisnupud `.code-box .copy-btn`: valge taust `#ffffff`, ääris `#cbd5e1`, tekst `#334155` / hover `#0f172a`.
  - Staatusemärgid (`[id^="test-status-badge-"]`, `[id^="diag-status-badge-"]`): taust `#f1f5f9`, tekst `#1e293b`, ääris `#cbd5e1`, rasvane kiri.
  - Kaartide pealkirjade aktsentvärvid kohandatud heleda režiimi heaks (WCAG-nõuetele vastav tumedam küllastus):
    - Sinine: `#0284c7`
    - Roheline: `#16a34a`
    - Kollane/merevaik: `#b45309`
    - Lilla: `#7e22ce`
  - Vihjekastid ja mõõdikud: `.bp-diag-hint-box` ja `#bp-modal-benchmarks` on heledal taustal puhta helehalli fooniga `#f8fafc` ja süsimusta tekstiga `#0f172a`.

### 4. Layout malli täiendus (`scripts/internal/dev_hub/assets/templates/layout.html`)
- Lisatud semantiline klass `bp-diag-hint-box` testide ja logide kiirnavigeerimise sektsioonile.

### 5. Versioonitõste ja kompileerimine
- `VERSION` tõstetud väärtusele `2.5.0.16`.
- Kompileeritud `docs/dev-hub.html` (`python3 scripts/internal/generate_dev_hub.py`).

---

## 3. Testide Verifitseerimine
- `tests/unit/test-devhub-theme.sh`: 11/11 PASSED
- `tests/unit/test-dev-hub-generation.sh`: PASSED
- `tests/unit/test-filename-portability.sh`: 2091 repository paths PASSED (Rule 13)
- `tests/test-multilingual-support.sh`: 16/16 PASSED (Rule 9)
