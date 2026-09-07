[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📦 Kohalike tarkvarapakettide ja binaarfailide kataloog (`binaries/`)

See kataloog on ette nähtud kohalike ja allalaaditud paigalduspakettide (ZIP, JAR, RPM, VSIX, SQL) ning tootespetsiifiliste patchide puhverdamiseks, võimaldades võrguvaba (offline) või ettevõtte sise-Artifactory tuge.

---

## 📁 Alamkataloogide struktuur ja otstarve

| Alamkataloog | Kirjeldus ja Toetatud Failid | Patchide Kataloog | Skriptid / Kasutuskoht |
| :--- | :--- | :--- | :--- |
| **[`apex/`](apex/README.et.md)** | Oracle APEX paigalduspaketid (`apex-latest.zip`, `apex_*.zip`) | [`apex/patches/`](apex/patches/README.et.md) | `scripts/setup-all.sh`, `scripts/internal/install-apex.sh` |
| **[`ords/`](ords/README.et.md)** | Oracle REST Data Services paketid (`ords-latest.zip`, `ords-*.zip`) | — | `scripts/setup-all.sh`, `scripts/internal/install-ords-standalone.sh` |
| **[`java/`](java/README.et.md)** | Jagatud Java JDK RPM paketid (`jdk-17*.rpm`) Publisherile ja Formsile | [`java/patches/`](java/patches/README.et.md) | `docker/publisher/`, `docker/forms/` |
| **[`middleware/`](middleware/README.et.md)** | Oracle Fusion Middleware / WebLogic 14c infrastruktuur (`V1045135-01.zip`) | [`middleware/patches/`](middleware/patches/README.et.md) | `docker/publisher/`, `docker/forms/` |
| **[`forms/`](forms/README.et.md)** | Oracle Forms 14c paigalduspaketid (`V1045121-01.zip`) | [`forms/patches/`](forms/patches/README.et.md) | `scripts/forms/`, `docker/forms/` |
| **[`publisher/`](publisher/README.et.md)** | Oracle Analytics Publisheri paigaldusfailid (`V1055080-01.zip`) | [`publisher/patches/`](publisher/patches/README.et.md) | `scripts/publisher/`, `docker/publisher/` |
| **[`apex_apps/`](apex_apps/README.et.md)** | Automaatselt imporditavad APEX rakendused (`f100.sql`, `app.apex`) | — | `scripts/internal/deploy-apex-apps.sh` |
| **[`extensions/`](extensions/README.et.md)** | Web IDE kohalikud VS Code `.vsix` laienduste paketid | — | `scripts/internal/init-web-ide.sh` |

---

## 🔒 Git versioonihalduse reeglid

- Kõik binaarfailid (`*.zip`, `*.rpm`, `*.jar`, `*.vsix`) on `.gitignore` failis ning jäävad **ainult lokaalseks**.
- Kataloogide struktuur ja `README*.md` juhendid on versioonihaldusega tagatud.
