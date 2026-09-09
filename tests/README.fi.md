[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🧪 Automaattitestaus ja blueprint-testaussarja (`tests/`)

Tämä hakemisto sisältää Oracle DevOps Platformin automaattitestausinfrastruktuurin, suorituskykyraportit ja arkkitehtuuritarkistukset.

Kaikki 12 kanonista arkkitehtuurimallia on määritelty keskitetysti hakemistossa **[`config/blueprints/`](../config/blueprints/)**.

---

## 📁 Hakemistorakenne

- **`config/blueprints/`** ➔ 12 kanonista arkkitehtuurimallia (`.env.0-*` - `.env.11-*`).
- **`tests/reports/`** ➔ Testiraportit ja suorituskykymatriisi ([`blueprint_benchmark_matrix.md`](reports/blueprint_benchmark_matrix.md)).
- **`tests/reports/blueprints/`** ➔ Automaattisesti luodut raportit (`blueprint_0_report.md` - `blueprint_11_report.md`).
- **`tests/unit/`
  - **`tests/unit/test-glossary-links.sh` / `.cmd`** ➔ 57 sanaston ja Wikipedian ulkoisen linkin nollalataustarkistus (muistipohjainen HTTP HEAD, tyhjälaite NUL / /dev/null).** ➔ Yksikkötestit CLI-vakaudelle ja tietoturvalle.

---

## 🚀 Komentorivikäynnistys

Testien suorittaminen puhtaalta pöydältä (automaattisella `reset-all.sh -y` -nollauksella):

```bash
# 1. Yksittäisen blueprintin testaus:
./scripts/setup-all.sh -tb 3

# 2. Valitun luettelon testaus:
./scripts/setup-all.sh -tb 1,5,8,10

# 3. KAIKKIEN 12 blueprintin testaus peräkkäin:
./scripts/setup-all.sh -tb all

# 4. Monikielisyyden ja i18n-tarkistus:
./tests/test-multilingual-support.sh --all

# 5. Monipilvitestit:
./tests/test-remote-multicloud.sh --dry-run

# 6. Arkkitehtuurikuvien ja profiilien eheyden tarkistus:
./tests/unit/test-blueprint-profiles-integrity.sh

# 7. Tietovaraston tilastot ja koodikannan mittarit:
./tests/report-repo-stats.sh
```

---

## 🔍 Validointiinvarianssit

Jokainen testiajo tarkistaa:
1. **🌐 Verkkopalveluiden HTTP-Terveys (`scripts/check-urls.sh`):** HTTP/HTTPS-vastaukset (200/302).
2. **🔑 SEPS Walletin Salasanaton Yhteys (`scripts/check-wallet.sh`):** SQLcl-yhteydet ilman salasanoja.
3. **📊 Suorituskykymittaukset (Sääntö 1):** Vaiheiden kestot tallennetaan tiedostoon `metrics/setup_benchmarks.json`.
