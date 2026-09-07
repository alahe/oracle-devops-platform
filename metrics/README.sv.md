[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📊 Katalog för Prestandamätningar (`metrics/`)

I denna katalog lagras och versionshanteras installationsstegens tidsmätningar (Regel 1).

---

## 📁 Nyckelfiler

- **`setup_benchmarks.json`**: Exakt tidsåtgång för installationsstegen i sekunder (JSON-format).
- **`setup_benchmarks.env`**: Tidsmätningar som miljövariabler.
- **`devhub_browser_blueprints_benchmarks.json`**: Mätvärden för E2E-webbläsartester och API.

*(Obs: Detaljerade felsökningsloggar sparas endast lokalt i `install_logs/` och inkluderas inte i Git).*
