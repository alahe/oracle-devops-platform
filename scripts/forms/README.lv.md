[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📐 Oracle Forms 14c Darbības skripti (`scripts/forms/`)

Šis direktorijs nodrošina rīkus Oracle Forms 14c izpildlaika vides, komandrindas kompilēšanas, WebLogic domēna diagnostikas un lietotņu ieviešanas pārvaldībai.

---

## 🛠️ Pieejamie skripti

- **`build-forms-image.sh`:** Izveido lokālo `localhost/oracle-forms:14.1.2` konteinera attēlu.
  ```bash
  ./scripts/forms/build-forms-image.sh
  ```
- **`compile-form.sh`:** Kompilē bināro `.fmb` avota formu izpildāmā `.fmx` failā no komandrindas.
  ```bash
  ./scripts/forms/compile-form.sh /ceļš/forma.fmb
  ```
- **`deploy-forms-apps.sh`:** Ievieš kompilētās formas un izvēlnes konteinerā mapē `/u01/oracle/forms_apps`.
  ```bash
  ./scripts/forms/deploy-forms-apps.sh
  ```
- **`status-forms.sh`:** Pārbauda Oracle Forms 14c un WebLogic izpildlaika pakalpojumu veselību.
  ```bash
  ./scripts/forms/status-forms.sh
  ```
