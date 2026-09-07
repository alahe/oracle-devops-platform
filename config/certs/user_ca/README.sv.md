[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🔒 Användarbetrodd Lokal CA (Alternativ 3)

Denna katalog innehåller lokalt genererat Root CA-certifikat (`localCA.pem`) och det servercertifikat som signerats av detta (`localhost.crt` / `localhost.key`).

## Status & Webbläsarbeteende:
* **Nivå:** **Alternativ 3 (Utvecklarens lokala betrodda läge)**
* **Status:** 🟢 **Betrodd i användarens certifikatarkiv (0-Root / No Sudo)**
* **Webbläsarresultat:** Webbläsare öppnar HTTPS-anslutningar med **grönt hänglås utan varningar**.
* **Installationsskript:**
  * macOS: `./scripts/certs/trust-local-cert-mac.sh` (`login.keychain-db`)
  * Windows: `./scripts/certs/trust-local-cert.ps1` (`Cert:\CurrentUser\Root`)
  * Linux: `./scripts/certs/trust-local-cert-linux.sh`
