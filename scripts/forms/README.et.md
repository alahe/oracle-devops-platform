[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📐 Oracle Forms 14c operatsioonide skriptid (`scripts/forms/`)

Käesolev kataloog sisaldab tööriistu Oracle Forms 14c käitussüsteemi, käsurea kompileerimise, kahesuunalise XML konverteerimise, roundtrip verifitseerimise, WebLogic domeeni diagnostika ja vormirakenduste tarne haldamiseks.

---

## 🛠️ Saadaolevad skriptid

- **`build-forms-image.sh`:** Ehitab kohaliku `localhost/oracle-forms:14.1.2` konteineripildi.
  ```bash
  ./scripts/forms/build-forms-image.sh
  ```
- **`compile-form.sh`:** Kompileerib `.fmb` binaarse vormiallika käsurealt käivitatavaks `.fmx` failiks.
  ```bash
  ./scripts/forms/compile-form.sh /asukoht/vorm.fmb
  ```
- **`form-to-xml.sh`:** Kahesuunaline FMB ↔ XML konverter (Git diff ja APEX Migration Workshop ühilduv).
  ```bash
  ./scripts/forms/form-to-xml.sh forms_apps/orders.fmb            # FMB -> XML
  ./scripts/forms/form-to-xml.sh --to-fmb forms_apps/orders.xml   # XML -> FMB
  ```
- **`test-fmb-xml-roundtrip.sh`:** Käivitab 2-pass roundtrip kontrolli (`FMB -> XML(1) -> temp.fmb -> XML(2)`) ja teeb semantilise süvavõrdluse.
  ```bash
  ./scripts/forms/test-fmb-xml-roundtrip.sh forms_apps/test.fmb
  ```
- **`deploy-forms-apps.sh`:** Tarnib kompileeritud vormid ja menüüd konteinerisse kataloogi `/u01/oracle/forms_apps`.
  ```bash
  ./scripts/forms/deploy-forms-apps.sh
  ```
- **`status-forms.sh`:** Kontrollib Forms 14c ja WebLogic käitusteenuste tervist ja toimimist.
  ```bash
  ./scripts/forms/status-forms.sh
  ```
