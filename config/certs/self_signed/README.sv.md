[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# ⚠️ Tillfälligt Självsignerat Certifikat (Alternativ 4 Fallback)

Denna katalog innehåller ett dynamiskt genererat självsignerat certifikat (`self_signed.crt` och `self_signed.key`).

## Status & Webbläsarbeteende:
* **Nivå:** **Alternativ 4 (Lägsta opålitliga reservläge)**
* **Status:** ⚠️ **Icke-betrodd (Untrusted)**
* **Webbläsarresultat:** Webbläsaren visar en varning *"Inte säker / Anslutningen är inte privat"*.
* **Användning:** Automatisk nödfallback endast när publik domän, företags-PKI eller lokal CA inte kan användas (`TLS_ALLOWED_LEVEL=permissive`).
