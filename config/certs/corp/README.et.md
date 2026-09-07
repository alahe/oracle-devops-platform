[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🏢 Ettevõtte Sise-pki sertifikaadid (corporate PKI)

Sellesse kataloogi laetakse või sünkroniseeritakse ettevõtte sise-PKI sertifikaadid:
* `corp_cert.crt` — Ettevõtte serveri sertifikaat
* `corp_key.key` — Sertifikaadi privaatvõti
* `corp_ca.crt` — Ettevõtte Root CA / vaheahela sertifikaat

## Sünkroniseerimine
Sünkroniseerimiseks ettevõtte sisehoidlast kasuta käsku:
```bash
./scripts/certs/sync-corp-cert.sh
```
