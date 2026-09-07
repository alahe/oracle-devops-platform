[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🩹 Oracle pataisų katalogas (`patches/`)

Šis katalogas išlaikomas atgaliniam suderinamumui ir universalioms pataisoms. Produktams būdingos pataisos yra atitinkamuose pakatalogiuose:

- **Oracle APEX:** [`binaries/apex/patches/`](../binaries/apex/patches/)
- **Oracle Forms 14c:** [`binaries/forms/patches/`](../binaries/forms/patches/)
- **Oracle Analytics Publisher:** [`binaries/publisher/patches/`](../binaries/publisher/patches/)
- **Oracle Middleware / WebLogic:** [`binaries/middleware/patches/`](../binaries/middleware/patches/)
- **Oracle Java / JDK:** [`binaries/java/patches/`](../binaries/java/patches/)

---

## 🚀 Pataisų diegimo komandos

```bash
# Įdiegti APEX Bundle Patch:
./scripts/internal/apply-apex-patch.sh binaries/apex/patches/p39179920_261_Generic.zip

# Įdiegti Analytics Publisher OPatch:
./scripts/internal/apply-publisher-patch.sh binaries/publisher/patches/<patch_failas>.zip
```
