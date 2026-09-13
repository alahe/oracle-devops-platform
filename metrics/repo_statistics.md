# 📈 Oracle DevOps Platform — Repositooriumi Statistiline Aruanne
> Genereeritud: **2026-09-14 00:44:14** | Analüüsi kestus: **194 ms**

## 1. Koodibaasi Kokkuvõte ja Hallatav Lähtekood
| Mõõdik | Väärtus | Kirjeldus |
|---|---|---|
| **Hallatav Lähtekood (SLOC)** | **99,308 rida** | Reaalne kood ilma tühikute ja kommentaarideta |
| **Hallatavad Failid** | **570 tk** | Lähtekood (`scripts/`, `tests/`, `config/`, `docker/`) |
| **Funktsionaalne Kood (SLOC)** | **85,566 rida** | Tuumikfunktsioonid ja automatiseerimine |
| **Testikood (SLOC)** | **13,742 rida** | 118 automaattesti ja simulaatorit |
| **Testide Tihedus (Test Density)** | **16.1%** | Testide suhtarv funktsionaalse koodi kohta |
| **Keskmine faili maht** | **174.2 SLOC** | Mediaani lähedane tasakaalustatud jaotus |
| **Bruto Repositoorium** | **2,073 faili / 363,637 rida** | Sh `docs/dev-hub.html` ja `metrics/` ajalugu |

## 2. Koodijaotus Keelte Kaupa (Maintainable Code)
| Programmeerimiskeel / Tüüp | Failid | Kokku ridasid | SLOC (puhas kood) | Osa koodibaasist |
|---|---|---|---|---|
| **Shell / Bash** | 277 | 45,950 | 36,231 | **36.5%** |
| **Web Templates (HTML/JS/CSS)** | 5 | 38,046 | 35,132 | **35.4%** |
| **Python** | 28 | 19,796 | 18,371 | **18.5%** |
| **Markdown Docs** | 182 | 8,354 | 6,361 | **6.4%** |
| **SQL / PLSQL** | 7 | 1,415 | 1,219 | **1.2%** |
| **YAML Configuration** | 25 | 1,194 | 1,000 | **1.0%** |
| **Other** | 30 | 464 | 412 | **0.4%** |
| **Container / Docker** | 5 | 380 | 272 | **0.3%** |
| **Windows Scripts** | 5 | 282 | 216 | **0.2%** |
| **JSON Data/Specs** | 6 | 94 | 94 | **0.1%** |

## 3. Arhitektuuri ja Komponentide Loendus
- 🏛️ **Arhitektuuri Blueprintid:** 12 tk (`config/blueprints/.env.*`)
- 🗄️ **Andmebaasi Profiilid:** 11 tk (`config/profiles/databases/*.yaml`)
- 🛠️ **Kasutaja CLI Tööriistad:** 31 tk (`scripts/*.sh`)
- ⚙️ **Sisemised Mootorid & Init:** 53 tk (`scripts/internal/`)
- 🧪 **Testiskriptid:** 191 tk (`tests/`)

## 4. Kvaliteet, Testid ja Mitmekeelsus (i18n)
- **Testide Edukusprotsent:** **100.0%** (ajaloolistest jooksudest)
- **Automaattestide Skripte:** **164 tk**
- **Toetatud Keeled:** EN, ET, FI, SV, LV, LT (6 keelt)
- **Tõlkevõtmete Arv:** 1259 unikaalset võtit (100% Synchronized)

## 5. Git & Versioonihaldus
- **Commitide Koguarv:** 84
- **Viimane Commit:** `d4aa3cd9` (2026-09-13 poolt lahe)
- **Sõnum:** *feat(devhub): fix specs triad switching, add 2-stage recipe safety inspector & testing AI button (v2.5.0.5)*
- **Aktiivsed Harud / Tagid:** 3 haru / 0 tagi

## 6. Mahukaimad Lähtekoodifailid (Top 5 Outliers)
| Failitee | Keel | SLOC | Kokku Ridu |
|---|---|---|---|
| `scripts/internal/dev_hub/assets/app.js` | Web Templates (HTML/JS/CSS) | **13,944** | 15,906 |
| `scripts/internal/dev_hub/assets/style.css` | Web Templates (HTML/JS/CSS) | **9,689** | 10,295 |
| `scripts/internal/dev_hub/assets/i18n.js` | Web Templates (HTML/JS/CSS) | **6,878** | 6,893 |
| `scripts/internal/dev_hub/assets/templates/layout.html` | Web Templates (HTML/JS/CSS) | **4,280** | 4,562 |
| `scripts/internal/dev-hub-bridge.py` | Python | **3,521** | 3,927 |
