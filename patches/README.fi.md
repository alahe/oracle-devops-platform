[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🩹 Oracle-Päivitysten Hakemisto (`patches/`)

Tämä hakemisto säilytetään taaksepäin yhteensopivuuden ja yleisten päivitysten vuoksi. Tuotekohtaiset päivitykset sijaitsevat omissa alihakemistoissaan:

- **Oracle APEX:** [`binaries/apex/patches/`](../binaries/apex/patches/)
- **Oracle Forms 14c:** [`binaries/forms/patches/`](../binaries/forms/patches/)
- **Oracle Analytics Publisher:** [`binaries/publisher/patches/`](../binaries/publisher/patches/)
- **Oracle Middleware / WebLogic:** [`binaries/middleware/patches/`](../binaries/middleware/patches/)
- **Oracle Java / JDK:** [`binaries/java/patches/`](../binaries/java/patches/)

---

## 🚀 Päivitysten Asennuskomennot

```bash
# APEX Bundle Patchin Asennus:
./scripts/internal/apply-apex-patch.sh binaries/apex/patches/p39179920_261_Generic.zip

# Analytics Publisher OPatchin Asennus:
./scripts/internal/apply-publisher-patch.sh binaries/publisher/patches/<patch_tiedosto>.zip
```
