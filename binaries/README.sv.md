[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📦 Lokala Programvarupaket och Binär Cache (`binaries/`)

Denna katalog fungerar som lokal cache för offlineinstallationer och företags Artifactory-speglingar (ZIP, RPM, JAR, VSIX, SQL).

---

## 📁 Underkataloger och Syfte

| Underkatalog | Beskrivning & Filer | Patchkatalog | Skript / Används av |
| :--- | :--- | :--- | :--- |
| **[`apex/`](apex/README.sv.md)** | Oracle APEX-installationspaket (`apex-latest.zip`, `apex_*.zip`) | [`apex/patches/`](apex/patches/README.sv.md) | `scripts/setup-all.sh`, `scripts/internal/install-apex.sh` |
| **[`ords/`](ords/README.sv.md)** | Oracle REST Data Services-paket (`ords-latest.zip`, `ords-*.zip`) | — | `scripts/setup-all.sh`, `scripts/internal/install-ords-standalone.sh` |
| **[`java/`](java/README.sv.md)** | Delade Java JDK RPM-paket (`jdk-17*.rpm`) för Publisher & Forms | [`java/patches/`](java/patches/README.sv.md) | `docker/publisher/`, `docker/forms/` |
| **[`middleware/`](middleware/README.sv.md)** | Oracle FMW / WebLogic 14c-paket (`V1045135-01.zip`) | [`middleware/patches/`](middleware/patches/README.sv.md) | `docker/publisher/`, `docker/forms/` |
| **[`forms/`](forms/README.sv.md)** | Oracle Forms 14c distributionspaket (`V1045121-01.zip`) | [`forms/patches/`](forms/patches/README.sv.md) | `scripts/forms/`, `docker/forms/` |
| **[`publisher/`](publisher/README.sv.md)** | Analytics Publisher distributionspaket (`V1055080-01.zip`) | [`publisher/patches/`](publisher/patches/README.sv.md) | `scripts/publisher/`, `docker/publisher/` |
| **[`apex_apps/`](apex_apps/README.sv.md)** | APEX-applikationer för automatiserad import (`f100.sql`) | — | `scripts/internal/deploy-apex-apps.sh` |
| **[`extensions/`](extensions/README.sv.md)** | Webb-IDE lokala VS Code `.vsix`-tillägg | — | `scripts/internal/init-web-ide.sh` |

---

## 🔒 Git-Versionshanteringspolicy

- Alla binärfiler (`*.zip`, `*.rpm`, `*.jar`, `*.vsix`) finns i `.gitignore` och förblir **strikt lokala**.
- Katalogstrukturen och `README*.md`-guiderna är versionshanterade.
