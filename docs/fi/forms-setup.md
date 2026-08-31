[ 🇬🇧 English ](../forms-setup.md) | [ 🇪🇪 Eesti ](../et/forms-setup.md) | [ 🇫🇮 Suomi ](forms-setup.md) | [ 🇸🇪 Svenska ](../sv/README.md) | [ 🇱🇻 Latviešu ](../lv/README.md) | [ 🇱🇹 Lietuvių ](../lt/README.md)

# Oracle Forms 14c (14.1.2) Asennus-, Kehitys- ja Käyttöohje

Tämä ohje kuvaa **Oracle Forms 14c:n (Fusion Middleware 14.1.2 / Forms Services)** asennuksen, arkkitehtuurin, kehittäjän työnkulut, tiedostojen siirron konttiin, tilannevedosten hallinnan sekä Forms-sovellusten ajamisen ja APEX-migraation.

---

## 1. Arkkitehtuuri ja Porttijako

| Komponentti | Portti | Kuvaus |
| :--- | :--- | :--- |
| 📐 **Forms Runtime** | `9001` / `9002` | Forms Services -servletti (`/forms/frmservlet`) ja reaaliaikaiset verkkolomakkeet (`/forms/frmservlet?form=test.fmx`). |
| 🌐 **Forms Developer Hub** | `6082` | Kehittäjän verkkokeskus ja noVNC-työasema (`http://localhost:6082/vnc.html`). |
| ⚙️ **WebLogic Console** | `7001` | WebLogic AdminServer -hallintaliittymä (`/console`). |
| 🗄️ **Forms DB (`db-forms`)** | `1534` | Oracle 23ai Free -tietokanta RCU-skeemoilla (`FORMS_STB`, `FORMS_OPSS`, `FORMS_IAU`, `FORMS_WLS`). |
| 🗄️ **Mukautettu DB (`db-alise`)** | `1533` | Mukautetun sovelluksen tietokanta (data, taulut, paketit). |
| 🚀 **ORDS & APEX** | `8088` / `8448` | Oracle REST Data Services ja APEX App Builder. |

---

## 2. Arkkitehtuuri: Forms Builder (GUI) vs Kontin Headless Runtime

### Miksi Forms Builderia (GUI) ei voi avata natiivisti Macissa/Linuxissa?
1. **Perinteinen Motif-graafinen kehys:** Linuxin Forms Builder (`frmbld`) perustuu 1990-luvun **Motif / OpenMotif** -kehykseen, joka vaatii vanhoja X11-laajennuksia. Nykyaikainen macOS XQuartz tai Linux Wayland/Xorg ei tue näitä 30 vuotta vanhoja standardeja (`FRM-91111: internal error: window system startup failure`).
2. **Oracle virallinen tuotedokumentaatio:**
   > *Form Builder (GUI-visuaalinen editori) on virallisesti tuettu VAIN Microsoft Windows -käyttöjärjestelmässä (`frmbld.exe`). Linux-jakelut sisältävät Forms Compilerin (`frmcmp_batch`), Forms Services Runtime -palvelimen (`frmweb` / WebLogic `WLS_FORMS`) ja migraatiotyökalut (`Forms2XML`).*

### Kontin Rooli ja Käyttötarkoitus
Konttia käytetään **Headless DevOps-, Käännös- ja Suoritusympäristönä**:
- **Sovellusten Suoritus:** Käännetyt lomakkeet (`.fmx`) ajetaan verkkopalvelimen kautta (`http://localhost:9001/forms/frmservlet?form=<lomake.fmx>`).
- **Eräkäännös (CLI):** `.fmb`-lomakkeiden kääntäminen `.fmx`:ksi tapahtuu komentoriviltä sekunnissa komennolla `./scripts/forms/compile-form.sh`.
- **APEX-Migraatio:** Lomakkeiden muuntaminen XML-muotoon ja APEX Migration Workshop ZIP -paketin vienti.

---

## 3. Forms-Tiedostojen Siirtäminen Konttiin

Forms-tiedostojen toimittamiseen on **4 joustavaa menetelmää**:

### Menetelmä A (Suositeltu): Paikallinen Liitetty Kansio (`forms_apps/`)
- Projektin juurihakemistossa sijaitseva kansio **`forms_apps/`** on automaattisesti liitetty konttiin polkuun `/u01/oracle/forms_apps` reaaliajassa (`rw`-tilassa).
- **Käyttö:**
  1. Kopioi tai vedä `.fmb`- tai `.fmx`-tiedostot suoraan kansioon `forms_apps/`.
  2. Tiedostot näkyvät **välittömästi kontissa** ilman uudelleenkäynnistystä.
  3. Käännä komentoriviltä: `./scripts/forms/compile-form.sh forms_apps/lomake.fmb`
  4. Avaa selaimessa: `http://localhost:9001/forms/frmservlet?form=lomake.fmx`

### Menetelmä B: Virallinen Jakeluskripti (`deploy-forms-apps.sh`)
```bash
# Yksittäisen lomakkeen jakelu:
./scripts/forms/deploy-forms-apps.sh /polku/tilaukset.fmb

# Koko kansiopuun jakelu valikoineen (.mmb) ja kirjastoineen (.pll):
./scripts/forms/deploy-forms-apps.sh /polku/vanhat_lomakkeet/
```

### Menetelmä C: Podman / Docker Kopiointikomento (`podman cp`)
```bash
podman cp /polku/lomake.fmb app-forms:/u01/oracle/forms_apps/
```

---

## 4. APEX-Modernisointi ja Työnkulku

1. **Käännä Forms XML-muotoon:**
   ```bash
   ./scripts/forms/convert-to-xml.sh forms_apps/lomake.fmb
   ```
2. **Luo APEX Migration Workshop ZIP:**
   ```bash
   ./scripts/forms/export-apex-zip.sh
   ```
3. **Tuo APEXiin:** Avaa APEX Builder -> *App Builder* -> *Migration Workshop* -> *Upload Project*.
