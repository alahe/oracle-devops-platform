# 📈 Oracle DevOps Platform — Repositooriumi Statistiline Aruanne
> Genereeritud: **2026-09-09 10:34:57** | Analüüsi kestus: **453 ms**

## 1. Koodibaasi Kokkuvõte ja Hallatav Lähtekood
| Mõõdik | Väärtus | Kirjeldus |
|---|---|---|
| **Hallatav Lähtekood (SLOC)** | **73,375 rida** | Reaalne kood ilma tühikute ja kommentaarideta |
| **Hallatavad Failid** | **524 tk** | Lähtekood (`scripts/`, `tests/`, `config/`, `docker/`) |
| **Funktsionaalne Kood (SLOC)** | **61,772 rida** | Tuumikfunktsioonid ja automatiseerimine |
| **Testikood (SLOC)** | **11,603 rida** | 118 automaattesti ja simulaatorit |
| **Testide Tihedus (Test Density)** | **18.8%** | Testide suhtarv funktsionaalse koodi kohta |
| **Keskmine faili maht** | **140.0 SLOC** | Mediaani lähedane tasakaalustatud jaotus |
| **Bruto Repositoorium** | **1,955 faili / 289,712 rida** | Sh `docs/dev-hub.html` ja `metrics/` ajalugu |

## 2. Koodijaotus Keelte Kaupa (Maintainable Code)
| Programmeerimiskeel / Tüüp | Failid | Kokku ridasid | SLOC (puhas kood) | Osa koodibaasist |
|---|---|---|---|---|
| **Shell / Bash** | 246 | 40,355 | 31,888 | **43.5%** |
| **Web Templates (HTML/JS/CSS)** | 5 | 23,777 | 22,128 | **30.2%** |
| **Python** | 16 | 10,862 | 10,177 | **13.9%** |
| **Markdown Docs** | 180 | 8,160 | 6,204 | **8.5%** |
| **SQL / PLSQL** | 7 | 1,415 | 1,219 | **1.7%** |
| **YAML Configuration** | 23 | 1,012 | 849 | **1.2%** |
| **Other** | 31 | 369 | 329 | **0.4%** |
| **Container / Docker** | 5 | 379 | 271 | **0.4%** |
| **Windows Scripts** | 5 | 282 | 216 | **0.3%** |
| **JSON Data/Specs** | 6 | 94 | 94 | **0.1%** |

## 3. Arhitektuuri ja Komponentide Loendus
- 🏛️ **Arhitektuuri Blueprintid:** 12 tk (`config/blueprints/.env.*`)
- 🗄️ **Andmebaasi Profiilid:** 11 tk (`config/profiles/databases/*.yaml`)
- 🛠️ **Kasutaja CLI Tööriistad:** 27 tk (`scripts/*.sh`)
- ⚙️ **Sisemised Mootorid & Init:** 49 tk (`scripts/internal/`)
- 🧪 **Testiskriptid:** 172 tk (`tests/`)

## 4. Kvaliteet, Testid ja Mitmekeelsus (i18n)
- **Testide Edukusprotsent:** **100.0%** (ajaloolistest jooksudest)
- **Automaattestide Skripte:** **144 tk**
- **Toetatud Keeled:** EN, ET, FI, SV, LV, LT (6 keelt)
- **Tõlkevõtmete Arv:** 922 unikaalset võtit (100% Synchronized)

## 5. Git & Versioonihaldus
- **Commitide Koguarv:** 79
- **Viimane Commit:** `0cbc8d0c` (2026-09-08 poolt lahe)
- **Sõnum:** *feat: APEXlang slide expansion, 6-lang glossary with verified links, zero-download link checker, and enterprise windows suite*
- **Aktiivsed Harud / Tagid:** 3 haru / 0 tagi

## 6. Mahukaimad Lähtekoodifailid (Top 5 Outliers)
| Failitee | Keel | SLOC | Kokku Ridu |
|---|---|---|---|
| `scripts/internal/dev_hub/assets/app.js` | Web Templates (HTML/JS/CSS) | **9,413** | 10,682 |
| `scripts/internal/dev_hub/assets/i18n.js` | Web Templates (HTML/JS/CSS) | **5,035** | 5,044 |
| `scripts/internal/dev_hub/assets/style.css` | Web Templates (HTML/JS/CSS) | **4,624** | 4,767 |
| `scripts/internal/dev_hub/catalog.py` | Python | **2,809** | 2,819 |
| `scripts/internal/dev_hub/assets/templates/layout.html` | Web Templates (HTML/JS/CSS) | **2,715** | 2,894 |
