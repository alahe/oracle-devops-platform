# 📈 Oracle DevOps Platform — Repositooriumi Statistiline Aruanne
> Genereeritud: **2026-09-08 00:11:22** | Analüüsi kestus: **188 ms**

## 1. Koodibaasi Kokkuvõte ja Hallatav Lähtekood
| Mõõdik | Väärtus | Kirjeldus |
|---|---|---|
| **Hallatav Lähtekood (SLOC)** | **59,960 rida** | Reaalne kood ilma tühikute ja kommentaarideta |
| **Hallatavad Failid** | **496 tk** | Lähtekood (`scripts/`, `tests/`, `config/`, `docker/`) |
| **Funktsionaalne Kood (SLOC)** | **50,714 rida** | Tuumikfunktsioonid ja automatiseerimine |
| **Testikood (SLOC)** | **9,246 rida** | 118 automaattesti ja simulaatorit |
| **Testide Tihedus (Test Density)** | **18.2%** | Testide suhtarv funktsionaalse koodi kohta |
| **Keskmine faili maht** | **120.9 SLOC** | Mediaani lähedane tasakaalustatud jaotus |
| **Bruto Repositoorium** | **1,889 faili / 253,187 rida** | Sh `docs/dev-hub.html` ja `metrics/` ajalugu |

## 2. Koodijaotus Keelte Kaupa (Maintainable Code)
| Programmeerimiskeel / Tüüp | Failid | Kokku ridasid | SLOC (puhas kood) | Osa koodibaasist |
|---|---|---|---|---|
| **Shell / Bash** | 226 | 35,036 | 27,812 | **46.4%** |
| **Web Templates (HTML/JS/CSS)** | 5 | 16,869 | 15,735 | **26.2%** |
| **Python** | 13 | 8,123 | 7,600 | **12.7%** |
| **Markdown Docs** | 179 | 8,044 | 6,104 | **10.2%** |
| **SQL / PLSQL** | 7 | 1,415 | 1,219 | **2.0%** |
| **YAML Configuration** | 23 | 977 | 817 | **1.4%** |
| **Container / Docker** | 5 | 364 | 257 | **0.4%** |
| **Other** | 30 | 272 | 245 | **0.4%** |
| **JSON Data/Specs** | 5 | 88 | 88 | **0.1%** |
| **Windows Scripts** | 3 | 106 | 83 | **0.1%** |

## 3. Arhitektuuri ja Komponentide Loendus
- 🏛️ **Arhitektuuri Blueprintid:** 12 tk (`config/blueprints/.env.*`)
- 🗄️ **Andmebaasi Profiilid:** 10 tk (`config/profiles/databases/*.yaml`)
- 🛠️ **Kasutaja CLI Tööriistad:** 27 tk (`scripts/*.sh`)
- ⚙️ **Sisemised Mootorid & Init:** 49 tk (`scripts/internal/`)
- 🧪 **Testiskriptid:** 155 tk (`tests/`)

## 4. Kvaliteet, Testid ja Mitmekeelsus (i18n)
- **Testide Edukusprotsent:** **100.0%** (ajaloolistest jooksudest)
- **Automaattestide Skripte:** **133 tk**
- **Toetatud Keeled:** EN, ET, FI, SV, LV, LT (6 keelt)
- **Tõlkevõtmete Arv:** 710 unikaalset võtit (100% Synchronized)

## 5. Git & Versioonihaldus
- **Commitide Koguarv:** 78
- **Viimane Commit:** `92f7b123` (2026-09-07 poolt lahe)
- **Sõnum:** *feat(arch): add financial enterprise distributed architecture, jira backlog, and devhub menu*
- **Aktiivsed Harud / Tagid:** 3 haru / 0 tagi

## 6. Mahukaimad Lähtekoodifailid (Top 5 Outliers)
| Failitee | Keel | SLOC | Kokku Ridu |
|---|---|---|---|
| `scripts/internal/dev_hub/assets/app.js` | Web Templates (HTML/JS/CSS) | **6,508** | 7,370 |
| `scripts/internal/dev_hub/assets/i18n.js` | Web Templates (HTML/JS/CSS) | **3,830** | 3,839 |
| `scripts/internal/dev_hub/catalog.py` | Python | **2,842** | 2,850 |
| `scripts/internal/dev_hub/assets/style.css` | Web Templates (HTML/JS/CSS) | **2,834** | 2,898 |
| `scripts/internal/dev-hub-bridge.py` | Python | **2,400** | 2,647 |
