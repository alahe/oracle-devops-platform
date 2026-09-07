[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📐 Oracle Forms -sovellusten hakemisto (`forms_apps/`)

Tämä hakemisto liitetään automaattisesti Oracle Forms 14c -säilön polkuun `/u01/oracle/forms_apps` luku- ja kirjoitustilassa (`rw`).

---

## 🚀 Käyttö

- **Sijoittaminen:** Aseta `.fmb`- (lähdekoodi) tai `.fmx`- (käännetyt) tiedostosi tähän hakemistoon.
- **Komentorivikääntäminen:**
  ```bash
  ./scripts/forms/compile-form.sh forms_apps/lomake.fmb
  ```
- **Käynnistys selaimessa:**
  `http://localhost:9001/forms/frmservlet?form=lomake.fmx`
