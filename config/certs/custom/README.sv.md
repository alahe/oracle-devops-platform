[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🛠️ Anpassade SSL/tls-certifikat (custom certificate drop-in)

Utvecklare eller administratörer kan placera befintliga SSL/TLS-certifikat och privata nycklar här, vilket plattformen automatiskt prioriterar högst (**Steg 0**).

## Filnamnsregler:
Placera följande filer i denna katalog:
* **Certifikat:** `tls.crt` (eller `cert.crt`, `fullchain.pem`)
* **Privat nyckel:** `tls.key` (eller `key.key`, `privkey.pem`)
* *(Valfritt)* **CA-kedja:** `ca.crt` (eller `chain.pem`)

## Automatisk detektering:
1. När `.crt`- och `.key`-filer detekteras växlar läget automatiskt till:
   `RESOLVED_TLS_MODE=CUSTOM_CERT`
2. ORDS, Analytics Publisher och webbtjänster använder certifikatet omedelbart.
3. Filerna i denna katalog ignoreras av `.gitignore` och sparas inte i Git.
