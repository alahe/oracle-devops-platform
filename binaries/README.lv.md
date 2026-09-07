[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📦 Lokālo Programmatūras Pakešu Un Bināro failu Kešatmiņa (`binaries/`)

Šis direktorijs kalpo kā lokālā kešatmiņa bezsaistes instalācijām un uzņēmuma Artifactory spoguļiem (ZIP, RPM, JAR, VSIX, SQL).

---

## 📁 Apakšdirektoriji Un Mērķis

| Apakšdirektorijs | Apraksts un Faili | Ielāpu Direktorijs | Skripti / Izmanto |
| :--- | :--- | :--- | :--- |
| **[`apex/`](apex/README.lv.md)** | Oracle APEX instalācijas pakotnes (`apex-latest.zip`, `apex_*.zip`) | [`apex/patches/`](apex/patches/README.lv.md) | `scripts/setup-all.sh`, `scripts/internal/install-apex.sh` |
| **[`ords/`](ords/README.lv.md)** | Oracle REST Data Services pakotnes (`ords-latest.zip`, `ords-*.zip`) | — | `scripts/setup-all.sh`, `scripts/internal/install-ords-standalone.sh` |
| **[`java/`](java/README.lv.md)** | Koplietotās Java JDK RPM pakotnes (`jdk-17*.rpm`) | [`java/patches/`](java/patches/README.lv.md) | `docker/publisher/`, `docker/forms/` |
| **[`middleware/`](middleware/README.lv.md)** | Oracle FMW / WebLogic 14c pakotnes (`V1045135-01.zip`) | [`middleware/patches/`](middleware/patches/README.lv.md) | `docker/publisher/`, `docker/forms/` |
| **[`forms/`](forms/README.lv.md)** | Oracle Forms 14c instalācijas pakotnes (`V1045121-01.zip`) | [`forms/patches/`](forms/patches/README.lv.md) | `scripts/forms/`, `docker/forms/` |
| **[`publisher/`](publisher/README.lv.md)** | Analytics Publisher instalācijas faili (`V1055080-01.zip`) | [`publisher/patches/`](publisher/patches/README.lv.md) | `scripts/publisher/`, `docker/publisher/` |
| **[`apex_apps/`](apex_apps/README.lv.md)** | APEX lietotnes automatizētai ieviešanai (`f100.sql`) | — | `scripts/internal/deploy-apex-apps.sh` |
| **[`extensions/`](extensions/README.lv.md)** | Web IDE lokālie VS Code `.vsix` paplašinājumi | — | `scripts/internal/init-web-ide.sh` |

---

## 🔒 Git versiju kontroles noteikumi

- Visi binārie faili (`*.zip`, `*.rpm`, `*.jar`, `*.vsix`) ir iekļauti `.gitignore` un paliek **tikai lokāli**.
- Direktorija struktūra un `README*.md` rokasgrāmatas tiek uzturētas versiju kontrolē.
