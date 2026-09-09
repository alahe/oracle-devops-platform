[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🔒 Käyttäjätason luotettu paikallinen CA (vaihtoehto 3)

Tämä hakemisto sisältää paikallisesti luodun kehittäjän Root CA -sertifikaatin (`localCA.pem`) ja sen allekirjoittaman palvelinsertifikaatin (`localhost.crt` / `localhost.key`).

## Ominaisuudet ja tila:
* **Taso:** **Vaihtoehto 3 (Kehittäjän paikallinen luotettu tila)**
* **Tila:** 🟢 **Luotettu käyttäjäsäilössä (0-Root / No Sudo)**
* **Selainkokemus:** Selaimet avaavat HTTPS-osoitteet **vihreällä lukkokuvakkeella ilman varoituksia**.
* **Asennusskriptit:**
  * macOS: `./scripts/certs/trust-local-cert-mac.sh` (`login.keychain-db`)
  * Windows: `./scripts/certs/trust-local-cert.ps1` (`Cert:\CurrentUser\Root`)
  * Linux: `./scripts/certs/trust-local-cert-linux.sh`
