[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📦 Local Software Packages & Binary Cache (`binaries/`)

This directory serves as the local cache for offline installations and enterprise Artifactory mirrors, caching ZIP, RPM, JAR, VSIX, and SQL files without requiring continuous internet downloads.

---

## 📁 Subdirectories & Purpose

| Subdirectory | Description & Files | Patches Directory | Scripts / Used By |
| :--- | :--- | :--- | :--- |
| **[`apex/`](apex/README.md)** | Oracle APEX distribution packages (`apex-latest.zip`, `apex_*.zip`) | [`apex/patches/`](apex/patches/README.md) | `scripts/setup-all.sh`, `scripts/internal/install-apex.sh` |
| **[`ords/`](ords/README.md)** | Oracle REST Data Services packages (`ords-latest.zip`, `ords-*.zip`) | — | `scripts/setup-all.sh`, `scripts/internal/install-ords-standalone.sh` |
| **[`java/`](java/README.md)** | Shared Java JDK RPM packages (`jdk-17*.rpm`) for Publisher & Forms | [`java/patches/`](java/patches/README.md) | `docker/publisher/`, `docker/forms/` |
| **[`middleware/`](middleware/README.md)** | Oracle Fusion Middleware / WebLogic 14c packages (`V1045135-01.zip`) | [`middleware/patches/`](middleware/patches/README.md) | `docker/publisher/`, `docker/forms/` |
| **[`forms/`](forms/README.md)** | Oracle Forms 14c distribution packages (`V1045121-01.zip`) | [`forms/patches/`](forms/patches/README.md) | `scripts/forms/`, `docker/forms/` |
| **[`publisher/`](publisher/README.md)** | Analytics Publisher (BIP) distribution packages (`V1055080-01.zip`) | [`publisher/patches/`](publisher/patches/README.md) | `scripts/publisher/`, `docker/publisher/` |
| **[`apex_apps/`](apex_apps/README.md)** | APEX applications for automated deployment (`f100.sql`, `app.apex`) | — | `scripts/internal/deploy-apex-apps.sh` |
| **[`extensions/`](extensions/README.md)** | Web IDE local VS Code `.vsix` extension cache | — | `scripts/internal/init-web-ide.sh` |

---

## 🔒 Git Version Control Policy

- All binary files (`*.zip`, `*.rpm`, `*.jar`, `*.vsix`) are listed in `.gitignore` and remain **strictly local**.
- Directory structure and `README*.md` documentation are version-controlled.
