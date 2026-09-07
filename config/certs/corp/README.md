[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🏢 Corporate Internal PKI Certificates

This directory stores or synchronizes certificates from the organization's internal PKI infrastructure:
* `corp_cert.crt` — Corporate server certificate
* `corp_key.key` — Private key for the certificate
* `corp_ca.crt` — Corporate Root CA / Intermediate CA chain

## Synchronization
To sync certificates from the internal corporate repository, run:
```bash
./scripts/certs/sync-corp-cert.sh
```
