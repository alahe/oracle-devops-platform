[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🔒 User-Space Trusted Local CA (Option 3)

This directory contains the locally generated Developer Root CA certificate (`localCA.pem`) and the server certificate signed by it (`localhost.crt` / `localhost.key`).

## Status & Browser Experience:
* **Tier:** **Option 3 (Developer Local Trusted Mode)**
* **Status:** 🟢 **Trusted in User Trust Store (0-Root / No Sudo)**
* **Browser Result:** Browsers (Chrome, Edge, Safari) open HTTPS endpoints with a **green padlock without warnings**.
* **Installation Scripts:**
  * macOS: `./scripts/certs/trust-local-cert-mac.sh` (`login.keychain-db`)
  * Windows: `./scripts/certs/trust-local-cert.ps1` (`Cert:\CurrentUser\Root`)
  * Linux: `./scripts/certs/trust-local-cert-linux.sh`
