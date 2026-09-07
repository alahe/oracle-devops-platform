[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📐 Oracle Forms rakenduste kaust (`forms_apps/`)

See kaust on automaatselt seotud Oracle Forms 14c konteineri teekonnaga `/u01/oracle/forms_apps` lugemis- ja kirjutusrežiimis (`rw`).

---

## 🚀 Kasutamine

- **Paigutus:** Aseta oma `.fmb` (lähtekood) või `.fmx` (kompileeritud) failid siia kausta.
- **Käsurea kompileerimine:**
  ```bash
  ./scripts/forms/compile-form.sh forms_apps/minuvorm.fmb
  ```
- **Käivitamine brauseris:**
  `http://localhost:9001/forms/frmservlet?form=minuvorm.fmx`
