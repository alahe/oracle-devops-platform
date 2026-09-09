[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🛠️ Manuaalisesti lisätyt sertifikaatit (custom certificate drop-in)

Kehittäjä tai ylläpitäjä voi kopioida tähän hakemistoon olemassa olevan SSL/TLS-sertifikaatin ja yksityisen avaimen, joita järjestelmä käyttää ensisijaisena prioriteettina (**Vaihe 0**).

## Tiedostojen Nimeämissäännöt:
Aseta tähän hakemistoon seuraavat tiedostot:
* **Sertifikaatti:** `tls.crt` (tai `cert.crt`, `fullchain.pem`)
* **Yksityinen avain:** `tls.key` (tai `key.key`, `privkey.pem`)
* *(Valinnainen)* **CA-ketju:** `ca.crt` (tai `chain.pem`)

## Järjestelmän Automaattinen tunnistus:
1. Kun hakemistosta löytyy `.crt`- ja `.key`-tiedostot, TLS-tilaksi asetetaan automaattisesti:
   `RESOLVED_TLS_MODE=CUSTOM_CERT`
2. ORDS, Analytics Publisher ja verkkopalvelut ottavat sertifikaatin käyttöön välittömästi.
3. Hakemiston sisältö on suojattu `.gitignore`-tiedostolla eikä päädy Git-versionhallintaan.
