[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🏢 Uzņēmuma Iekšējās PKI Sertifikāti (Corporate PKI)

Šajā direktorijā tiek glabāti vai sinhronizēti organizācijas iekšējās PKI infrastruktūras sertifikāti:
* `corp_cert.crt` — Uzņēmuma servera sertifikāts
* `corp_key.key` — Sertifikāta privātā atslēga
* `corp_ca.crt` — Uzņēmuma Root CA / starpsertifikātu ķēde

## Sinhronizācija
Lai sinhronizētu sertifikātus no uzņēmuma iekšējās krātuves, palaidiet:
```bash
./scripts/certs/sync-corp-cert.sh
```
