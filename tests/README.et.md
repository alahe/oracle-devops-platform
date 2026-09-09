[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🧪 Keskkonna automaattestimise ja blueprintide juhend (`tests/`)

Antud kaust koondab projekti kogu automaattestimise taristu: testiraportid, automaatsed mõõdikud ja arhitektuuri kontrollid.

Kõik 12 ametlikku kanoonilist arhitektuurset blueprinti asuvad keskse tõeallikana kaustas **[`config/blueprints/`](../config/blueprints/)**.

---

## 📁 Kataloogi struktuur

- **`config/blueprints/`** ➔ 12 ametlikku arhitektuurset blueprinti (`.env.0-*` kuni `.env.11-*`).
- **`tests/reports/`** ➔ Arhitektuuriraportid ja koondmaatriks ([`blueprint_benchmark_matrix.md`](reports/blueprint_benchmark_matrix.md)).
- **`tests/reports/blueprints/`** ➔ Automaatselt genereeritud testiaruanded (`blueprint_0_report.md` kuni `blueprint_11_report.md`).
- **`tests/unit/`
  - **`tests/unit/test-glossary-links.sh` / `.cmd`** ➔ 57 glossaari ja Vikipeedia välislingi null-allalaadimisega audit (mälupõhine HTTP HEAD, tühiseade NUL / /dev/null).** ➔ Ühiktestid CLI stabiilsuse, DevHubi generaatorite ja turvalisuse verifitseerimiseks.

---

## 🚀 Käivitamine Käsuliinilt (Terminal)

Testide käivitamiseks puhtalt lehelt (automaatse `reset-all.sh -y` ja verifitseerimisega):

```bash
# 1. Automaatne testimine (Üksik blueprint):
./scripts/setup-all.sh -tb 3

# 2. Konkreetse nimekirja testimine (Koma eraldajaga):
./scripts/setup-all.sh -tb 1,5,8,10

# 3. KÕIGI 12 blueprinti automaatne laustestimine järjestikku:
./scripts/setup-all.sh -tb all

# 4. Mitmekeelsuse ja i18n kontroll:
./tests/test-multilingual-support.sh --all

# 5. Kaugpaigalduse Multi-Cloud testid:
./tests/test-remote-multicloud.sh --dry-run

# 6. Arhitektuursete Blueprintide ja profiilide terviklikkuse audit:
./tests/unit/test-blueprint-profiles-integrity.sh

# 7. Repositooriumi statistika ja koodibaasi mõõdikute raport:
./tests/report-repo-stats.sh
```

---

## 🔍 Verifitseerimise invariandid

Iga automaatne test valideerib:
1. **🌐 Veebiteenuste HTTP Health Audit (`scripts/check-urls.sh`):** Kontrollib tegelike HTTP/HTTPS päringutega staatust (200/302).
2. **🔑 SEPS Paroolivaba Walleti Audit (`scripts/check-wallet.sh`):** Paroolivaba SQLcl ühenduse kontroll (`SELECT status FROM v$instance`).
3. **📊 Ressursi ja Kestuse Mõõdikud (Reegel 1):** Sammude ajakulu salvestatakse faili `metrics/setup_benchmarks.json`.
