[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📐 Oracle Forms 14c toiminnalliset komentosarjat (`scripts/forms/`)

Tämä hakemisto tarjoaa työkalut Oracle Forms 14c -suoritusympäristön, komentorivikääntämisen, kaksisuuntaisen XML-muunnoksen, roundtrip-varmennuksen, WebLogic-toimialueen diagnostiikan ja sovellusten käyttöönoton hallintaan.

---

## 🛠️ Käytettävissä Olevat komentosarjat

- **`build-forms-image.sh`:** Rakentaa paikallisen `localhost/oracle-forms:14.1.2`-säilökuvan.
  ```bash
  ./scripts/forms/build-forms-image.sh
  ```
- **`compile-form.sh`:** Kääntää `.fmb`-binaarilähdelomakkeen suoritettavaksi `.fmx`-tiedostoksi komentoriviltä.
  ```bash
  ./scripts/forms/compile-form.sh /polku/lomake.fmb
  ```
- **`form-to-xml.sh`:** Kaksisuuntainen FMB ↔ XML -muunnin (Git diff- ja APEX Migration Workshop -yhteensopiva).
  ```bash
  ./scripts/forms/form-to-xml.sh forms_apps/orders.fmb            # FMB -> XML
  ./scripts/forms/form-to-xml.sh --to-fmb forms_apps/orders.xml   # XML -> FMB
  ```
- **`test-fmb-xml-roundtrip.sh`:** Suorittaa 2-pass roundtrip -varmennuksen (`FMB -> XML(1) -> temp.fmb -> XML(2)`) ja tekee semanttisen vertailun.
  ```bash
  ./scripts/forms/test-fmb-xml-roundtrip.sh forms_apps/test.fmb
  ```
- **`deploy-forms-apps.sh`:** Ottaa käyttöön käännetyt lomakkeet ja valikot säilön hakemistoon `/u01/oracle/forms_apps`.
  ```bash
  ./scripts/forms/deploy-forms-apps.sh
  ```
- **`status-forms.sh`:** Tarkistaa Oracle Forms 14c:n ja WebLogicin suorituspalveluiden terveyden.
  ```bash
  ./scripts/forms/status-forms.sh
  ```
