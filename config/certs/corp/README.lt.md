[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🏢 Įmonės Vidinės PKI sertifikatai (corporate PKI)

Šiame kataloge saugomi arba sinchronizuojami organizacijos vidinės PKI infrastruktūros sertifikatai:
* `corp_cert.crt` — Įmonės serverio sertifikatas
* `corp_key.key` — Sertifikato privatus raktas
* `corp_ca.crt` — Įmonės Root CA / tarpinių sertifikatų grandinė

## Sinchronizavimas
Norėdami sinchronizuoti sertifikatus iš įmonės vidinės saugyklos, paleiskite:
```bash
./scripts/certs/sync-corp-cert.sh
```
