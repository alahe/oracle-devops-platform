# Variant 3: Kasutajataseme Usaldatud Lokaalne CA (User-Space Trusted CA)

See kataloog sisaldab kohapeal genereeritud lokaalset juursertifikaati (`localCA.pem`) ja sellega allkirjastatud serveri sertifikaati (`localhost.crt` / `localhost.key`).

## Omadused ja Olek:
* **Tase:** **Variant 3 (Arendaja lokaalne usaldatud režiim)**.
* **Staatus:** 🟢 **Usaldatud kasutajahoidlas (0-Root / No Sudo)**.
* **Tulemus Brauseris:** Brauser (Chrome, Edge, Safari) avab HTTPS lingid **rohelise tabalukuga ilma hoiatusteta**.
* **Paigaldus:**
  * macOS: `./scripts/certs/trust-local-cert-mac.sh` (`login.keychain-db`)
  * Windows: `./scripts/certs/trust-local-cert.ps1` (`Cert:\CurrentUser\Root`)
