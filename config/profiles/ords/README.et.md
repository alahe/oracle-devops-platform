[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🌐 ORDS lüüsi profiilid (`config/profiles/ords/`)

Selles kaustas asuvad **ORDS-i deklareeritud profiilid (Explicit ORDS Profiles)**, mis kirjeldavad ORDS-i käitusmudeleid ja võrguseadistusi vastavalt Rule 11 nõuetele.

## 📂 Saadaval profiilid
1. **`ords-image.yaml`** (id: `app-ords-image`)
   - Ametlikul Oracle OCR konteineripildil (`container-registry.oracle.com/database/ords:latest`) põhinev tsentraalne multi-pool ORDS server.
   - Pordid: HTTP `8088`, HTTPS `8448`.
2. **`ords-local-custom.yaml`** (id: `app-ords-local-custom`)
   - Lokaalne skriptipõhine paigaldus allalaaditud ORDS zip-arhiivist konteineri failisüsteemi (`/tmp`).
   - Pordid: HTTP `8088`, HTTPS `8448`.
3. **`ords-remote-custom.yaml`** (id: `app-ords-remote-custom`)
   - Kaugserveri ORDS paigaldus eraldiseisvasse vahevara serverisse.
   - Pordid: HTTP `8088`, HTTPS `8448`.
4. **`ords-standalone.yaml`** (id: `app-ords-standalone`)
   - Eraldiseisev autonoomne ORDS testimiseks ja servalüüsiks isoleeritud portidel `8085` / `8445`.
