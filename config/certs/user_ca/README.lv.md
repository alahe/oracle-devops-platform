[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🔒 Lietotāja līmenī uzticama vietējā CA (variants 3)

Šajā direktorijā atrodas lokāli ģenerēts Root CA sertifikāts (`localCA.pem`) un tā parakstīts servera sertifikāts (`localhost.crt` / `localhost.key`).

## Statuss un Pārlūka Darbība:
* **Līmenis:** **Variants 3 (Izstrādātāja vietējais uzticamais režīms)**
* **Statuss:** 🟢 **Uzticams lietotāja krātuvē (0-Root / No Sudo)**
* **Rezultāts Pārlūkā:** Pārlūkprogrammas atver HTTPS saites ar **zaļu slēdzeni bez brīdinājumiem**.
* **Instalācijas Skripti:**
  * macOS: `./scripts/certs/trust-local-cert-mac.sh` (`login.keychain-db`)
  * Windows: `./scripts/certs/trust-local-cert.ps1` (`Cert:\CurrentUser\Root`)
  * Linux: `./scripts/certs/trust-local-cert-linux.sh`
