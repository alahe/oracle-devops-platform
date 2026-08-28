# Kohalike Tarkvarapakettide ja Binaarfailide Kataloog (`binaries/`)

See kataloog on ette nähtud kohalike ja allalaaditud paigalduspakettide (ZIP, JAR, RPM, VSIX, SQL) puhverdamiseks, et võimaldada **võrguvaba (offline)** või **ettevõtte sise-Artifactory** tuge ilma korduva internetiliikluseta.

---

## 📁 Alamkataloogide Struktuur ja Otstarve

| Alamkataloog | Kirjeldus ja Toetatud Failid | Skriptid / Kasutuskoht |
| :--- | :--- | :--- |
| **[`binaries/apex/`](apex/README.md)** | Oracle APEX paigalduspaketid (`apex-latest.zip`, `apex_*.zip`) | `scripts/setup-all.sh`, `scripts/internal/install-apex.sh` |
| **[`binaries/ords/`](ords/README.md)** | Oracle REST Data Services paketid (`ords-latest.zip`, `ords-*.zip`) | `scripts/setup-all.sh`, `scripts/internal/install-ords-standalone.sh` |
| **[`binaries/java/`](java/README.md)** | Jagatud Java JDK RPM/tar.gz paketid (`jdk-17*.rpm`) Publisherile ja Formsile | `docker/publisher/`, `docker/forms/` |
| **[`binaries/middleware/`](middleware/README.md)** | Oracle Fusion Middleware / WebLogic 14c infrastruktuur (`V1045135-01.zip`) | `docker/publisher/`, `docker/forms/` |
| **[`binaries/forms/`](forms/README.md)** | Oracle Forms 14c paigalduspaketid (`V1045121-01.zip`) | `scripts/forms/`, `docker/forms/`, `TASK-029` |
| **[`binaries/publisher/`](publisher/README.md)** | Oracle Analytics Publisheri (OAS / BIP) paigaldusfailid (`V1055080-01.zip`) | `scripts/publisher/`, `docker/publisher/` |
| **[`binaries/apex_apps/`](apex_apps/README.md)** | Automaatselt imporditavad APEX rakendused (`f100.sql`, `app.apex`) | `scripts/internal/deploy-apex-apps.sh` |
| **[`binaries/extensions/`](extensions/README.md)** | Web IDE kohalikud VS Code `.vsix` laienduste paketid | `scripts/internal/init-web-ide.sh`, `scripts/internal/install-web-ide-extensions.sh` |

---

## 🔒 Git Versioonihalduse Reeglid

- Kõik binaarfailid (`*.zip`, `*.rpm`, `*.jar`, `*.vsix`) on `.gitignore` failis ning jäävad **ainult lokaalseks**.
- Kataloogide struktuur ja `README.md` juhendid on versioonihaldusega tagatud.
