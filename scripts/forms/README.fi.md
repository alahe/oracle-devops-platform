[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📐 Oracle Forms 14c Toiminnalliset Komentosarjat (`scripts/forms/`)

Tämä hakemisto tarjoaa työkalut Oracle Forms 14c -suoritusympäristön, komentorivikääntämisen, WebLogic-toimialueen diagnostiikan ja sovellusten käyttöönoton hallintaan.

---

## 🛠️ Käytettävissä Olevat Komentosarjat

- **`build-forms-image.sh`:** Rakentaa paikallisen `localhost/oracle-forms:14.1.2`-säilökuvan.
  ```bash
  ./scripts/forms/build-forms-image.sh
  ```
- **`compile-form.sh`:** Kääntää `.fmb`-binaarilähdelomakkeen suoritettavaksi `.fmx`-tiedostoksi komentoriviltä.
  ```bash
  ./scripts/forms/compile-form.sh /polku/lomake.fmb
  ```
- **`deploy-forms-apps.sh`:** Ottaa käyttöön käännetyt lomakkeet ja valikot säilön hakemistoon `/u01/oracle/forms_apps`.
  ```bash
  ./scripts/forms/deploy-forms-apps.sh
  ```
- **`status-forms.sh`:** Tarkistaa Oracle Forms 14c:n ja WebLogicin suorituspalveluiden terveyden.
  ```bash
  ./scripts/forms/status-forms.sh
  ```
