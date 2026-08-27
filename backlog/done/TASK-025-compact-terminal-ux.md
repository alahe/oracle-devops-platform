# [TASK-025]: Terminali Progressi, Ajakulu ja Blueprintide Ajalooliste Mõõdikute Süsteem

**Staatus:** `DONE`  
**Prioriteet:** `MEDIUM`  
**Valdkond:** `Tooling` | `Performance`  
**Seotud Blueprintid / Profiilid:** Kõik blueprintid (1–13)  
**Dokumentatsioon:** [scripts/README.md](../../scripts/README.md), [config/blueprints/README.md](../../config/blueprints/README.md)  

---

## 1. Probleemi Kirjeldus ja Kontekst
Pikkade paigaldus- ja hooldusoperatsioonide ajal (APEX mootor, ORDS, Analytics Publisher, andmebaasi tervislikkuse ootamine) kippus terminali väljund risustuma sadade korduvate ridadega või vilkuma liiga sagedase ekraanile kirjutamise tõttu. Samuti puudus võimalus näha konkreetse blueprinti (1 kuni 13) mõõdetud ajaloolist keskmist, minimaalset ja maksimaalset ajakulu.

---

## 2. Eesmärk ja Realiseeritud Tulemus

### 2.1 Reaalajas Kohapeal Uuenev TTY Staatusriba
- Funktsioonid `run_with_live_timer` ja `print_progress` uuendavad täpselt ühte rida kohapeal (`\r\033[K`) koos spinneri, progressiriba ja sekundiloenduriga.
- **Konfigureeritav Taimeri Uuendussamm:** `LIVE_TIMER_INTERVAL` (vaikimisi `3` sekundit, toetab ka `7` sekundit ja teisi väärtusi) vähendab CPU koormust ja terminali virvendust.

### 2.2 Blueprint-Spetsiifilised Ajaloolised Mõõdikud (`metrics/blueprint_<N>_benchmarks.json`)
- Iga blueprinti kohta peetakse failis `metrics/blueprint_<N>_benchmarks.json` mõõtmiste ajalugu ja arvutatakse:
  - `runs_count` (mõõtmiste arv)
  - `average_duration_seconds` (keskmine kestus)
  - `min_duration_seconds` ja `max_duration_seconds`
- Enne käivitust ja sammude päises kuvatakse:
  `📊 Ajalooline ooteaeg Blueprint 3 jaoks: keskmine: 3m 45s (min: 3m 15s, max: 4m 15s, mõõtmisi: 4)`

### 2.3 Kompaktne Alam-sammude Puuhierarhia (`run_substep`)
- Mitmeosalised alamprotsessid kuvatakse selge puuna:
  `├─ 🚀 [Alamsamm 4.1]: Käivitan konteinerid... ✅ [Valmis: 12s]`
  `└─ 🔑 [Alamsamm 4.2]: Initsialiseerin SEPS Walleti... ✅ [Valmis: 2s]`

### 2.4 Kursori ja CI/CD Isoleeritus
- TTY režiimis peidetakse kursor (`tput civis`) ja taastatakse automaatselt trap-iga (`tput cnorm`).
- CI/CD / logidesse suunamisel välditakse ANSI juhtkoodide prügi.

---

## 3. Verifitseerimine ja Testid
- **Ühiktest:** [`tests/unit/test-compact-terminal-ux.sh`](../../tests/unit/test-compact-terminal-ux.sh) (PASS).
- **Kogu testikomplekt:** Kõik 59 ühiktesti läbitud edukalt (`All 59 unit tests OK`).
