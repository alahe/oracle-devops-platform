# 📈 Oracle DevOps Platform — Repositooriumi Statistiline Aruanne
> Genereeritud: **2026-09-14 08:25:29** | Analüüsi kestus: **357 ms**

## 1. Koodibaasi Kokkuvõte ja Hallatav Lähtekood
| Mõõdik | Väärtus | Kirjeldus |
|---|---|---|
| **Hallatav Lähtekood (SLOC)** | **102,536 rida** | Reaalne kood ilma tühikute ja kommentaarideta |
| **Hallatavad Failid** | **592 tk** | Lähtekood (`scripts/`, `tests/`, `config/`, `docker/`) |
| **Funktsionaalne Kood (SLOC)** | **87,019 rida** | Tuumikfunktsioonid ja automatiseerimine |
| **Testikood (SLOC)** | **15,517 rida** | 118 automaattesti ja simulaatorit |
| **Testide Tihedus (Test Density)** | **17.8%** | Testide suhtarv funktsionaalse koodi kohta |
| **Keskmine faili maht** | **173.2 SLOC** | Mediaani lähedane tasakaalustatud jaotus |
| **Bruto Repositoorium** | **2,189 faili / 374,929 rida** | Sh `docs/dev-hub.html` ja `metrics/` ajalugu |

## 2. Koodijaotus Keelte Kaupa (Maintainable Code)
| Programmeerimiskeel / Tüüp | Failid | Kokku ridasid | SLOC (puhas kood) | Osa koodibaasist |
|---|---|---|---|---|
| **Shell / Bash** | 296 | 49,492 | 38,885 | **37.9%** |
| **Web Templates (HTML/JS/CSS)** | 5 | 38,046 | 35,132 | **34.3%** |
| **Python** | 31 | 20,483 | 18,936 | **18.5%** |
| **Markdown Docs** | 182 | 8,361 | 6,368 | **6.2%** |
| **SQL / PLSQL** | 7 | 1,415 | 1,219 | **1.2%** |
| **YAML Configuration** | 25 | 1,194 | 1,000 | **1.0%** |
| **Other** | 30 | 466 | 414 | **0.4%** |
| **Container / Docker** | 5 | 380 | 272 | **0.3%** |
| **Windows Scripts** | 5 | 282 | 216 | **0.2%** |
| **JSON Data/Specs** | 6 | 94 | 94 | **0.1%** |

## 3. Arhitektuuri ja Komponentide Loendus
- 🏛️ **Arhitektuuri Blueprintid:** 12 tk (`config/blueprints/.env.*`)
- 🗄️ **Andmebaasi Profiilid:** 11 tk (`config/profiles/databases/*.yaml`)
- 🛠️ **Kasutaja CLI Tööriistad:** 31 tk (`scripts/*.sh`)
- ⚙️ **Sisemised Mootorid & Init:** 53 tk (`scripts/internal/`)
- 🧪 **Testiskriptid:** 205 tk (`tests/`)

## 4. Kvaliteet, Testid ja Mitmekeelsus (i18n)
- **Testide Edukusprotsent:** **100.0%** (ajaloolistest jooksudest)
- **Automaattestide Skripte:** **164 tk**
- **Toetatud Keeled:** EN, ET, FI, SV, LV, LT (6 keelt)
- **Tõlkevõtmete Arv:** 1259 unikaalset võtit (100% Synchronized)

## 5. Git & Versioonihaldus
- **Commitide Koguarv:** 88
- **Viimane Commit:** `d913a93d` (2026-09-14 poolt lahe)
- **Sõnum:** *fix(i18n): support inline --lang=<code/all> flag and update test execution metrics*
- **Aktiivsed Harud / Tagid:** 3 haru / 0 tagi

## 6. Mahukaimad Lähtekoodifailid (Top 5 Outliers)
| Failitee | Keel | SLOC | Kokku Ridu |
|---|---|---|---|
| `scripts/internal/dev_hub/assets/app.js` | Web Templates (HTML/JS/CSS) | **13,944** | 15,906 |
| `scripts/internal/dev_hub/assets/style.css` | Web Templates (HTML/JS/CSS) | **9,689** | 10,295 |
| `scripts/internal/dev_hub/assets/i18n.js` | Web Templates (HTML/JS/CSS) | **6,878** | 6,893 |
| `scripts/internal/dev_hub/assets/templates/layout.html` | Web Templates (HTML/JS/CSS) | **4,280** | 4,562 |
| `scripts/internal/dev-hub-bridge.py` | Python | **3,531** | 3,937 |
