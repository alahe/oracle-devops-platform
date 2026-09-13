[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📐 Driftskript för Oracle Forms 14c (`scripts/forms/`)

Denna katalog tillhandahåller verktyg för hantering av Oracle Forms 14c runtime-miljö, kompilering från kommandoraden, dubbelriktad XML-konvertering, roundtrip-verifiering, diagnostik av WebLogic-domän och applikationsdriftsättning.

---

## 🛠️ Tillgängliga Skript

- **`build-forms-image.sh`:** Bygger den lokala containeravbildningen `localhost/oracle-forms:14.1.2`.
  ```bash
  ./scripts/forms/build-forms-image.sh
  ```
- **`compile-form.sh`:** Kompilerar en binär `.fmb`-källform till en körbar `.fmx`-fil via CLI.
  ```bash
  ./scripts/forms/compile-form.sh /sökväg/form.fmb
  ```
- **`form-to-xml.sh`:** Dubbelriktad FMB ↔ XML-konverterare (kompatibel med Git diff och APEX Migration Workshop).
  ```bash
  ./scripts/forms/form-to-xml.sh forms_apps/orders.fmb            # FMB -> XML
  ./scripts/forms/form-to-xml.sh --to-fmb forms_apps/orders.xml   # XML -> FMB
  ```
- **`test-fmb-xml-roundtrip.sh`:** Kör 2-pass roundtrip-verifiering (`FMB -> XML(1) -> temp.fmb -> XML(2)`) och utför semantisk AST-jämförelse.
  ```bash
  ./scripts/forms/test-fmb-xml-roundtrip.sh forms_apps/test.fmb
  ```
- **`deploy-forms-apps.sh`:** Driftsätter kompilerade formulär och menyer till `/u01/oracle/forms_apps` i containern.
  ```bash
  ./scripts/forms/deploy-forms-apps.sh
  ```
- **`status-forms.sh`:** Kontrollerar hälsan för körtidstjänsterna i Oracle Forms 14c och WebLogic.
  ```bash
  ./scripts/forms/status-forms.sh
  ```
