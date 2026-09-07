[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🏢 Företagets Interna PKI-Certifikat (Corporate PKI)

I denna katalog lagras eller synkroniseras certifikat från organisationens interna PKI-infrastruktur:
* `corp_cert.crt` — Företagets servercertifikat
* `corp_key.key` — Privat nyckel för certifikatet
* `corp_ca.crt` — Företagets Root CA / mellanliggande certifikatkedja

## Synkronisering
För att synkronisera certifikat från företagets interna arkiv, kör:
```bash
./scripts/certs/sync-corp-cert.sh
```
