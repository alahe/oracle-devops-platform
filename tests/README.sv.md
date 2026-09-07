[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🧪 Automatiserad testning och arkitekturverifiering (`tests/`)

Denna katalog rymmer testinfrastrukturen, automatiserade prestandarapporter och verifieringssviter för Oracle DevOps Platform.

Alla 12 kanoniska arkitekturritningar definieras centralt i **[`config/blueprints/`](../config/blueprints/)**.

---

## 📁 Katalogstruktur

- **`config/blueprints/`** ➔ 12 kanoniska arkitekturritningar (`.env.0-*` till `.env.11-*`).
- **`tests/reports/`** ➔ Testrapporter och prestandamatris ([`blueprint_benchmark_matrix.md`](reports/blueprint_benchmark_matrix.md)).
- **`tests/reports/blueprints/`** ➔ Automatiskt genererade testrapporter (`blueprint_0_report.md` till `blueprint_11_report.md`).
- **`tests/unit/`
  - **`tests/unit/test-glossary-links.sh` / `.cmd`** ➔ Nollnedladdningsgranskning av 57 externa ordliste- och Wikipedialänkar (minnesbaserat HTTP HEAD, nollenhet NUL / /dev/null).** ➔ Enhetstester för CLI-stabilitet och säkerhet.

---

## 🚀 Körning från Kommandoraden

För att köra tester från en ren startpunkt (med automatisk `reset-all.sh -y`):

```bash
# 1. Testa en enskild ritning:
./scripts/setup-all.sh -tb 3

# 2. Testa vald sekvens av ritningar:
./scripts/setup-all.sh -tb 1,5,8,10

# 3. Testa ALLA 12 ritningar i följd:
./scripts/setup-all.sh -tb all

# 4. Verifiering av flerspråkighet och i18n:
./tests/test-multilingual-support.sh --all

# 5. Multi-molntester:
./tests/test-remote-multicloud.sh --dry-run
```

---

## 🔍 Valideringsinvarianter

Varje automatiserat test validerar:
1. **🌐 HTTP-Hälsokontroll för Webbtjänster (`scripts/check-urls.sh`):** HTTP/HTTPS-status (200/302).
2. **🔑 Lösenordsfria SEPS Wallet-Anslutningar (`scripts/check-wallet.sh`):** SQLcl-anslutningar utan lösenord.
3. **📊 Prestandamätningar (Regel 1):** Tidsåtgång sparas i `metrics/setup_benchmarks.json`.
