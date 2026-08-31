[ 🇬🇧 English ](../../README.md) | [ 🇪🇪 Eesti ](../et/README.md) | [ 🇫🇮 Suomi ](../fi/README.md) | [ 🇸🇪 Svenska ](../sv/README.md) | [ 🇱🇻 Latviešu ](../lv/README.md) | [ 🇱🇹 Lietuvių ](README.md)

# Oracle DevOps Platforma (Lietuvių Vadovas)

> **Gamybai paruošta, be licencijos mokesčių (0 €) ir 100% beslaptažodė (SEPS Wallet) Oracle 23ai, APEX 26, Forms 14c, Publisher ir Web IDE kūrimo bei DevOps platforma.**

---

## 🎯 Kodėl mes tai darome ir kokia nauda?

1. 💰 **Didelis Išlaidų Taupymas (0 € licencija):** Naudojame nemokamą Oracle Database Free 23ai (JSON-Relational Duality, Kafka, APEX 26.1).
2. 🔒 **100% Beslaptažodė ir Saugi (SEPS Wallet):** Oracle Wallet (SEPS) ir Podman Secrets neleidžia slaptažodžiams patekti į žurnalus.
3. ⚡ **Paruošta per Kelias Sekundes:** Pilna aplinka pasileidžia per **1–2 minutes vietoj 15 minučių**.

---

## 🚀 Greitas Paleidimas (Quickstart CLI)

```bash
# 1. Paleisti pasirinktą blueprint (pvz., BP 30):
./scripts/setup-all.sh -b 30 --lang lt

# 2. Saugiai gauti slaptažodį iš SEPS Wallet:
./scripts/get-password.sh DB_DEV

# 3. Patikrinti aktyvių paslaugų URL:
./scripts/check-urls.sh --lang lt

# 4. Paleisti daugiakalbystės (i18n) patikros testą (9 taisyklė: EN, ET, FI, SV, LV, LT):
./tests/test-multilingual-support.sh

# 5. Išvalyti žurnalus ir atstatyti aplinką:
./scripts/clean-logs.sh -y
./scripts/reset-all.sh -y
```

---

## 📑 Vartotojo Vadovai

- 🚀 **[docs/lt/forms-to-apex-migration-guide.md](forms-to-apex-migration-guide.md):** **Oracle Forms $\rightarrow$ APEX Modernizavimo bei Perkėlimo Vadovas** — Verslo paskatos, TCO kaštų palyginimas, 5 žingsnių automatizuotas procesas ir [Oracle APEXlang DSL](https://docs.oracle.com/en/database/oracle/apex/26.1/apxln/).
- 📐 **[docs/forms-setup.md](../../docs/forms-setup.md):** Oracle Forms 14c Vadovas.
- 📑 **[docs/publisher-setup.md](../../docs/publisher-setup.md):** Analytics Publisher Vadovas.
- 💻 **[docs/web-ide-artifactory.md](../../docs/web-ide-artifactory.md):** Web IDE Vadovas.
- 🌐 **[docs/dev-hub.html](../../docs/dev-hub.html):** **Developer & DevOps Command Center** (`http://localhost:8088/` ir `http://localhost:6082/vnc.html`).
- 📊 **[config/blueprints/README.md](../../config/blueprints/README.md):** Blueprint Katalogas.
- 📖 **[Oracle APEX 26.1 APEXlang Reference Manual](https://docs.oracle.com/en/database/oracle/apex/26.1/apxln/):** Oficiali deklaratyvios `.apx` gramatikos ir kompiliatoriaus komandų specifikacija.
