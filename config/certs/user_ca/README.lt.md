[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🔒 Vartotojo Lygiu Patikima Vietinė CA (Variantas 3)

Šiame kataloge yra vietoje sugeneruotas Root CA sertifikatas (`localCA.pem`) ir jo pasirašytas serverio sertifikatas (`localhost.crt` / `localhost.key`).

## Būsena ir Naršyklės Patirtis:
* **Lygis:** **Variantas 3 (Kūrėjo vietinis patikimas režimas)**
* **Būsena:** 🟢 **Patikimas vartotojo saugykloje (0-Root / No Sudo)**
* **Rezultatas Naršyklėje:** Naršyklės atveria HTTPS nuorodas su **žalia spyna be jokių įspėjimų**.
* **Diegimo Scenarijai:**
  * macOS: `./scripts/certs/trust-local-cert-mac.sh` (`login.keychain-db`)
  * Windows: `./scripts/certs/trust-local-cert.ps1` (`Cert:\CurrentUser\Root`)
  * Linux: `./scripts/certs/trust-local-cert-linux.sh`
