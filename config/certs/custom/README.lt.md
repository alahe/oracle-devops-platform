[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🛠️ Pritaikyti SSL/TLS sertifikatai (custom certificate drop-in)

Kūrėjai ar administratoriai čia gali nukopijuoti esamą SSL/TLS sertifikatą ir privatų raktą, kurį sistema automatiškai laiko aukščiausiu prioritetu (**Žingsnis 0**).

## Failų pavadinimų Taisyklės:
Į šį katalogą įkelkite šiuos failus:
* **Sertifikatas:** `tls.crt` (arba `cert.crt`, `fullchain.pem`)
* **Privatus raktas:** `tls.key` (arba `key.key`, `privkey.pem`)
* *(Pasirinktinai)* **CA grandinė:** `ca.crt` (arba `chain.pem`)

## Automatinis aptikimas:
1. Aptikus `.crt` ir `.key` failus, TLS režimas automatiškai nustatomas į:
   `RESOLVED_TLS_MODE=CUSTOM_CERT`
2. ORDS, Analytics Publisher ir žiniatinklio paslaugos iš karto naudoja šį sertifikatą.
3. Šio katalogo failai yra apsaugoti `.gitignore` ir niekada nepatenka į Git versijų kontrolę.
