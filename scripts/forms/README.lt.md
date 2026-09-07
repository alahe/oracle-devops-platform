[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📐 Oracle Forms 14c Veiklos Scenarijai (`scripts/forms/`)

Šiame kataloge pateikiami įrankiai, skirti valdyti Oracle Forms 14c vykdymo aplinką, kompiliavimą iš komandinės eilutės, WebLogic domeno diagnostiką ir programų diegimą.

---

## 🛠️ Prieinami Scenarijai

- **`build-forms-image.sh`:** Sukuria vietinį `localhost/oracle-forms:14.1.2` konteinerio atvaizdą.
  ```bash
  ./scripts/forms/build-forms-image.sh
  ```
- **`compile-form.sh`:** Kompiliuoja dvejetainį `.fmb` šaltinio formos failą į vykdomąjį `.fmx` failą iš komandinės eilutės.
  ```bash
  ./scripts/forms/compile-form.sh /kelias/forma.fmb
  ```
- **`deploy-forms-apps.sh`:** Įdiegia sukompiliuotas formas ir meniu į konteinerio katalogą `/u01/oracle/forms_apps`.
  ```bash
  ./scripts/forms/deploy-forms-apps.sh
  ```
- **`status-forms.sh`:** Tikrina Oracle Forms 14c ir WebLogic vykdymo paslaugų būseną.
  ```bash
  ./scripts/forms/status-forms.sh
  ```
