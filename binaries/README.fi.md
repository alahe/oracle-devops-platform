[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📦 Paikalliset ohjelmistopaketit ja binaarivälimuisti (`binaries/`)

Tämä hakemisto toimii paikallisena välimuistina offline-asennuksille ja yrityksen Artifactory-peileille (ZIP, RPM, JAR, VSIX, SQL).

---

## 📁 Alihakemistot ja tarkoitus

| Alihakemisto | Kuvaus ja Tiedostot | Päivityshakemisto | Komentosarjat / Käyttö |
| :--- | :--- | :--- | :--- |
| **[`apex/`](apex/README.fi.md)** | Oracle APEX -asennuspaketit (`apex-latest.zip`, `apex_*.zip`) | [`apex/patches/`](apex/patches/README.fi.md) | `scripts/setup-all.sh`, `scripts/internal/install-apex.sh` |
| **[`ords/`](ords/README.fi.md)** | Oracle REST Data Services -paketit (`ords-latest.zip`, `ords-*.zip`) | — | `scripts/setup-all.sh`, `scripts/internal/install-ords-standalone.sh` |
| **[`java/`](java/README.fi.md)** | Jaetut Java JDK RPM -paketit (`jdk-17*.rpm`) Publisherille ja Formsille | [`java/patches/`](java/patches/README.fi.md) | `docker/publisher/`, `docker/forms/` |
| **[`middleware/`](middleware/README.fi.md)** | Oracle FMW / WebLogic 14c -paketit (`V1045135-01.zip`) | [`middleware/patches/`](middleware/patches/README.fi.md) | `docker/publisher/`, `docker/forms/` |
| **[`forms/`](forms/README.fi.md)** | Oracle Forms 14c -jakelupaketit (`V1045121-01.zip`) | [`forms/patches/`](forms/patches/README.fi.md) | `scripts/forms/`, `docker/forms/` |
| **[`publisher/`](publisher/README.fi.md)** | Analytics Publisher (BIP) -jakelupaketit (`V1055080-01.zip`) | [`publisher/patches/`](publisher/patches/README.fi.md) | `scripts/publisher/`, `docker/publisher/` |
| **[`apex_apps/`](apex_apps/README.fi.md)** | APEX-sovellukset automaattiseen käyttöönottoon (`f100.sql`) | — | `scripts/internal/deploy-apex-apps.sh` |
| **[`extensions/`](extensions/README.fi.md)** | Verkko-IDE:n paikalliset VS Code `.vsix` -laajennukset | — | `scripts/internal/init-web-ide.sh` |

---

## 🔒 Git-versiohallintaperiaate

- Kaikki binaaritiedostot (`*.zip`, `*.rpm`, `*.jar`, `*.vsix`) ovat tiedostossa `.gitignore` ja pysyvät **vain paikallisina**.
- Hakemistorakenne ja `README*.md`-oppaat ovat versionhallinnassa.
