[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📐 Oracle Forms programų katalogas (`forms_apps/`)

Šis katalogas automatiškai prijungiamas prie Oracle Forms 14c konteinerio kelio `/u01/oracle/forms_apps` skaitymo ir rašymo režimu (`rw`).

---

## 🚀 Naudojimas

- **Talpinimas:** Įdėkite savo `.fmb` (šaltinio) arba `.fmx` (sukompiliuotus) failus į šį katalogą.
- **Kompiliavimas iš komandinės eilutės:**
  ```bash
  ./scripts/forms/compile-form.sh forms_apps/forma.fmb
  ```
- **Paleidimas naršyklėje:**
  `http://localhost:9001/forms/frmservlet?form=forma.fmx`
