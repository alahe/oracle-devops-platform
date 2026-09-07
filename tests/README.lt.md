[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🧪 Automatizuotas Testavimas ir Projektų Patikra (`tests/`)

Šiame kataloge yra Oracle DevOps platformos testavimo infrastruktūra, etalonų ataskaitos ir projektų tikrinimo rinkiniai.

Visi 12 kanoninių architektūros projektų centralizuotai aprašyti kataloge **[`config/blueprints/`](../config/blueprints/)**.

---

## 📁 Katalogo Struktūra

- **`config/blueprints/`** ➔ 12 kanoninių architektūros projektų (`.env.0-*` iki `.env.11-*`).
- **`tests/reports/`** ➔ Architektūros ataskaitos ir etalonų matrica ([`blueprint_benchmark_matrix.md`](reports/blueprint_benchmark_matrix.md)).
- **`tests/reports/blueprints/`** ➔ Automatiškai sugeneruotos ataskaitos (`blueprint_0_report.md` iki `blueprint_11_report.md`).
- **`tests/unit/`** ➔ Moduliniai vienetų testai CLI stabilumui ir saugumui.

---

## 🚀 Vykdymas iš Komandinės Eilutės

Norint paleisti testus iš švarios pradinės būsenos (su automatiniu `reset-all.sh -y`):

```bash
# 1. Testuoti atskirą projektą:
./scripts/setup-all.sh -tb 3

# 2. Testuoti pasirinktų projektų sąrašą:
./scripts/setup-all.sh -tb 1,5,8,10

# 3. Testuoti VISUS 12 projektų iš eilės:
./scripts/setup-all.sh -tb all

# 4. Daugiakalbystės ir i18n patikra:
./tests/test-multilingual-support.sh --all

# 5. Kelių debesų testai:
./tests/test-remote-multicloud.sh --dry-run
```

---

## 🔍 Patvirtinimo Invariantai

Kiekvienas testas patikrina:
1. **🌐 Žiniatinklio Paslaugų HTTP Sveikata (`scripts/check-urls.sh`):** HTTP/HTTPS atsakai (200/302).
2. **🔑 SEPS Wallet Ryšiai Be Slaptažodžio (`scripts/check-wallet.sh`):** SQLcl prisijungimai be slaptažodžio.
3. **📊 Našumo Rodikliai (1 taisyklė):** Trukmės matavimai išsaugomi `metrics/setup_benchmarks.json`.
