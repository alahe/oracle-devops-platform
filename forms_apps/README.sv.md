[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📐 Katalog för Oracle Forms applikationer (`forms_apps/`)

Denna katalog monteras automatiskt i Oracle Forms 14c-containern på sökvägen `/u01/oracle/forms_apps` i läs- och skrivläge (`rw`).

---

## 🚀 Användning

- **Placering:** Placera dina `.fmb`- (källkod) eller `.fmx`- (kompilerade) filer här.
- **Kompilering från kommandorad:**
  ```bash
  ./scripts/forms/compile-form.sh forms_apps/formular.fmb
  ```
- **Körning i webbläsare:**
  `http://localhost:9001/forms/frmservlet?form=formular.fmx`
