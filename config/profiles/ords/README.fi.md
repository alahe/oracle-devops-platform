[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🌐 ORDS-yhdyskäytävän profiilit (`config/profiles/ords/`)

Tämä hakemisto sisältää **ORDS (Oracle REST Data Services)** -profiilit, jotka määrittävät verkkokokoonpanot Rule 11 -sääntöjen mukaisesti.

## 📂 Saatavilla olevat profiilit
1. **`ords-image.yaml`** (id: `app-ords-image`)
   - Viralliseen Oracle OCR -kuvaan perustuva keskitetty multi-pool ORDS -palvelin.
   - Portit: HTTP `8088`, HTTPS `8448`.
2. **`ords-local-custom.yaml`** (id: `app-ords-local-custom`)
   - Paikallinen asennus konttitiedostojärjestelmään (`/tmp`).
   - Portit: HTTP `8088`, HTTPS `8448`.
3. **`ords-remote-custom.yaml`** (id: `app-ords-remote-custom`)
   - Etäpalvelimen ORDS-yhdyskäytävä yritystietokannoille.
   - Portit: HTTP `8088`, HTTPS `8448`.
4. **`ords-standalone.yaml`** (id: `app-ords-standalone`)
   - Erillinen ORDS-yhdyskäytävä eristetyissä porteissa `8085` / `8445`.
