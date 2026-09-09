[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📦 Vietinių programinės įrangos paketų ir dvejetainių talpykla (`binaries/`)

Šis katalogas naudojamas kaip vietinė talpykla diegimams be interneto ir įmonės Artifactory veidrodžiams (ZIP, RPM, JAR, VSIX, SQL).

---

## 📁 Pakatalogiai ir paskirtis

| Pakatalogis | Aprašymas ir Failai | Pataisų Katalogas | Scenarijai / Kur Naudojama |
| :--- | :--- | :--- | :--- |
| **[`apex/`](apex/README.lt.md)** | Oracle APEX diegimo paketai (`apex-latest.zip`, `apex_*.zip`) | [`apex/patches/`](apex/patches/README.lt.md) | `scripts/setup-all.sh`, `scripts/internal/install-apex.sh` |
| **[`ords/`](ords/README.lt.md)** | Oracle REST Data Services paketai (`ords-latest.zip`, `ords-*.zip`) | — | `scripts/setup-all.sh`, `scripts/internal/install-ords-standalone.sh` |
| **[`java/`](java/README.lt.md)** | Bendri Java JDK RPM paketai (`jdk-17*.rpm`) | [`java/patches/`](java/patches/README.lt.md) | `docker/publisher/`, `docker/forms/` |
| **[`middleware/`](middleware/README.lt.md)** | Oracle FMW / WebLogic 14c paketai (`V1045135-01.zip`) | [`middleware/patches/`](middleware/patches/README.lt.md) | `docker/publisher/`, `docker/forms/` |
| **[`forms/`](forms/README.lt.md)** | Oracle Forms 14c diegimo paketai (`V1045121-01.zip`) | [`forms/patches/`](forms/patches/README.lt.md) | `scripts/forms/`, `docker/forms/` |
| **[`publisher/`](publisher/README.lt.md)** | Analytics Publisher diegimo failai (`V1055080-01.zip`) | [`publisher/patches/`](publisher/patches/README.lt.md) | `scripts/publisher/`, `docker/publisher/` |
| **[`apex_apps/`](apex_apps/README.lt.md)** | APEX programos automatizuotam diegimui (`f100.sql`) | — | `scripts/internal/deploy-apex-apps.sh` |
| **[`extensions/`](extensions/README.lt.md)** | Web IDE vietiniai VS Code `.vsix` plėtiniai | — | `scripts/internal/init-web-ide.sh` |

---

## 🔒 Git versijų Kontrolės Taisyklės

- Visi dvejetainiai failai (`*.zip`, `*.rpm`, `*.jar`, `*.vsix`) yra `.gitignore` faile ir lieka **tik vietiškai**.
- Katalogo struktūra ir `README*.md` vadovai yra valdomi versijų kontrolės.
