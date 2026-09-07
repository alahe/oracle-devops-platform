[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🌐 ORDS Šliuzo Profiliai (`config/profiles/ords/`)

Šiame kataloge yra aiškūs **ORDS (Oracle REST Data Services)** profiliai pagal 11 taisyklę.

## 📂 Galimi Profiliai
1. **`ords-image.yaml`** (id: `app-ords-image`)
   - Centrinis kelių telkinių ORDS serveris, pagrįstas oficialiu Oracle OCR atvaizdu.
   - Prievadai: HTTP `8088`, HTTPS `8448`.
2. **`ords-local-custom.yaml`** (id: `app-ords-local-custom`)
   - Vietinis diegimas konteinerio failų sistemoje (`/tmp`).
   - Prievadai: HTTP `8088`, HTTPS `8448`.
3. **`ords-remote-custom.yaml`** (id: `app-ords-remote-custom`)
   - Nuotolinis ORDS šliuzas įmonės duomenų bazėms.
   - Prievadai: HTTP `8088`, HTTPS `8448`.
4. **`ords-standalone.yaml`** (id: `app-ords-standalone`)
   - Atskiras ORDS izoliuotuose prievaduose `8085` / `8445`.
