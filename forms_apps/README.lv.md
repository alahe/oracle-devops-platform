[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📐 Oracle Forms Lietotņu Direktorijs (`forms_apps/`)

Šis direktorijs tiek automātiski pievienots Oracle Forms 14c konteinera ceļam `/u01/oracle/forms_apps` lasīšanas un rakstīšanas režīmā (`rw`).

---

## 🚀 Lietošana

- **Izvietošana:** Ievietojiet savus `.fmb` (avota) vai `.fmx` (kompilētos) failus šajā mapē.
- **Kompilēšana no komandrindas:**
  ```bash
  ./scripts/forms/compile-form.sh forms_apps/forma.fmb
  ```
- **Palaišana pārlūkprogrammā:**
  `http://localhost:9001/forms/frmservlet?form=forma.fmx`
