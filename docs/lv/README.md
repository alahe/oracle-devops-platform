[ 🇬🇧 English ](../../README.md) | [ 🇪🇪 Eesti ](../et/README.md) | [ 🇫🇮 Suomi ](../fi/README.md) | [ 🇸🇪 Svenska ](../sv/README.md) | [ 🇱🇻 Latviešu ](README.md) | [ 🇱🇹 Lietuvių ](../lt/README.md)

# Oracle DevOps Platforma (Latviešu Rokasgrāmata)

> **Ražošanai gatava, bez licences maksas (0 €) un 100% bezparoļu (SEPS Wallet) Oracle 23ai, APEX 26, Forms 14c, Publisher un Web IDE izstrādes un DevOps platforma.**

---

## 🎯 Kāpēc mēs to darām un kādi ir ieguvumi?

1. 💰 **Ievērojams Izmaksu Ietaupījums (0 € licences maksa):** Izmantojam Oracle Database Free 23ai jaunākās tehnoloģijas (JSON-Relational Duality, Kafka, APEX 26.1).
2. 🔒 **100% Bezparoļu un Droša (SEPS Wallet):** Oracle Wallet (SEPS) un Podman Secrets novērš paroļu noplūdi žurnālos vai skriptos.
3. ⚡ **Gatavs Sekundēs (Iepriekš Sagatavoti Attēli):** Pilna uzņēmuma vide startē **1–2 minūtēs, nevis 15 minūtēs**.

---

## 🚀 Ātrā Palaišana (Quickstart CLI)

```bash
# 1. Palaist izvēlēto blueprint (piemēram, BP 30):
./scripts/setup-all.sh -b 30 --lang lv

# 2. Droši iegūt paroli no SEPS Wallet:
./scripts/get-password.sh DB_DEV

# 3. Pārbaudīt aktīvo tīmekļa pakalpojumu URL:
./scripts/check-urls.sh --lang lv

# 4. Palaist daudzvalodu (i18n) verifikācijas testu (9. noteikums: EN, ET, FI, SV, LV, LT):
./tests/test-multilingual-support.sh

# 5. Notīrīt žurnālus un atiestatīt vidi:
./scripts/clean-logs.sh -y
./scripts/reset-all.sh -y
```

---

## 📑 Lietotāja Rokasgrāmatas

- 🚀 **[docs/lv/forms-to-apex-migration-guide.md](forms-to-apex-migration-guide.md):** **Oracle Forms $\rightarrow$ APEX Modernizācijas un Pārejas Rokasgrāmata** — Biznesa pamatojums, TCO salīdzinājums, 5 posmu automatizēta darba plūsma un [Oracle APEXlang DSL](https://docs.oracle.com/en/database/oracle/apex/26.1/apxln/).
- 📐 **[docs/forms-setup.md](../../docs/forms-setup.md):** Oracle Forms 14c Rokasgrāmata.
- 📑 **[docs/publisher-setup.md](../../docs/publisher-setup.md):** Analytics Publisher Rokasgrāmata.
- 💻 **[docs/web-ide-artifactory.md](../../docs/web-ide-artifactory.md):** Web IDE Rokasgrāmata.
- 🌐 **[docs/dev-hub.html](../../docs/dev-hub.html):** **Developer & DevOps Command Center** (`http://localhost:8088/` un `http://localhost:6082/vnc.html`).
- 📊 **[config/blueprints/README.md](../../config/blueprints/README.md):** Blueprint Katalogs.
- 📖 **[Oracle APEX 26.1 APEXlang Reference Manual](https://docs.oracle.com/en/database/oracle/apex/26.1/apxln/):** Oficiālā specifikācija deklaratīvajai `.apx` sintaksei un kompilatora komandām.
