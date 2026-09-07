[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🏢 Yrityksen Sisäiset PKI-Sertifikaatit (Corporate PKI)

Tähän hakemistoon tallennetaan tai synkronoidaan organisaation sisäisen PKI-infrastruktuurin sertifikaatit:
* `corp_cert.crt` — Yrityksen palvelinsertifikaatti
* `corp_key.key` — Sertifikaatin yksityinen avain
* `corp_ca.crt` — Yrityksen Root CA / välivarmenteiden ketju

## Synkronointi
Synkronoi sertifikaatit yrityksen sisäisestä arkistosta komennolla:
```bash
./scripts/certs/sync-corp-cert.sh
```
