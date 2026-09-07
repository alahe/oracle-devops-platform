[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🌐 ORDS Vārtejas Profilu Katalogs (`config/profiles/ords/`)

Šajā direktorijā atrodas **ORDS (Oracle REST Data Services)** profili atbilstoši 11. noteikumam.

## 📂 Pieejamie Profila Varianti
1. **`ords-image.yaml`** (id: `app-ords-image`)
   - Centralizēts multi-pool ORDS serveris uz oficiālā Oracle OCR attēla bāzes.
   - Porti: HTTP `8088`, HTTPS `8448`.
2. **`ords-local-custom.yaml`** (id: `app-ords-local-custom`)
   - Lokāla instalācija konteinera failu sistēmā (`/tmp`).
   - Porti: HTTP `8088`, HTTPS `8448`.
3. **`ords-remote-custom.yaml`** (id: `app-ords-remote-custom`)
   - Attālināta starpprogrammatūras ORDS vārteja uzņēmuma datubāzēm.
   - Porti: HTTP `8088`, HTTPS `8448`.
4. **`ords-standalone.yaml`** (id: `app-ords-standalone`)
   - Atsevišķs ORDS izolētos portos `8085` / `8445`.
