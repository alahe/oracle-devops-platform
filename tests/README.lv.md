[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🧪 Automatizētā testēšana un projektējumu verifikācija (`tests/`)

Šis direktorijs satur automatizētās testēšanas infrastruktūru, etalonu pārskatus un verifikācijas komplektus Oracle DevOps platformai.

Visi 12 kanoniskie arhitektūras projektējumi ir centralizēti definēti mapē **[`config/blueprints/`](../config/blueprints/)**.

---

## 📁 Direktorija Struktūra

- **`config/blueprints/`** ➔ 12 kanoniskie arhitektūras projektējumi (`.env.0-*` līdz `.env.11-*`).
- **`tests/reports/`** ➔ Arhitektūras pārskati un etalonu matrica ([`blueprint_benchmark_matrix.md`](reports/blueprint_benchmark_matrix.md)).
- **`tests/reports/blueprints/`** ➔ Automātiski ģenerēti pārskati (`blueprint_0_report.md` līdz `blueprint_11_report.md`).
- **`tests/unit/`
  - **`tests/unit/test-glossary-links.sh` / `.cmd`** ➔ 57 glosārija un Vikipēdijas ārējo saišu pārbaude bez lejupielādes (atmiņā balstīts HTTP HEAD, nulles ierīce NUL / /dev/null).** ➔ Vienības testi CLI stabilitātei un drošībai.

---

## 🚀 Izpilde no komandrindas

Lai palaistu testus no tīra stāvokļa (ar automātisku `reset-all.sh -y`):

```bash
# 1. Testēt atsevišķu modeli:
./scripts/setup-all.sh -tb 3

# 2. Testēt konkrētu modeļu sarakstu:
./scripts/setup-all.sh -tb 1,5,8,10

# 3. Testēt VISUS 12 modeļus pēc kārtas:
./scripts/setup-all.sh -tb all

# 4. Daudzvalodu un i18n atbilstības pārbaude:
./tests/test-multilingual-support.sh --all

# 5. Multi-mākoņu testi:
./tests/test-remote-multicloud.sh --dry-run

# 6. Arhitektūras rasējumu un profilu integritātes audits:
./tests/unit/test-blueprint-profiles-integrity.sh

# 7. Krātuves statistikas un koda bāzes metrikas atskaite:
./tests/report-repo-stats.sh
```

---

## 🔍 Validācijas Invarianti

Katrs automatizētais tests pārbauda:
1. **🌐 Tīmekļa Pakalpojumu HTTP Veselība (`scripts/check-urls.sh`):** HTTP/HTTPS atbildes (200/302).
2. **🔑 SEPS Wallet Bezparoles Savienojumi (`scripts/check-wallet.sh`):** SQLcl pieslēgumi bez parolēm.
3. **📊 Veiktspējas Rādītāji (1. noteikums):** Laika mērījumi tiek saglabāti `metrics/setup_benchmarks.json`.
