[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🔒 Modul för SSL/TLS-certifikat och förtroendehantering (zero-admin / non-root)

Denna modul hanterar säkra HTTPS- och TCPS-anslutningar, certifikatval och automatisk installation av förtroende i macOS- och Windows-miljöer utan administratörsbehörighet (`root` / `sudo`).

---

## 🧭 5-Nivåers Hierarkisk tls-prioritetskedja (priority chain)

Under uppstart och konfiguration identifierar [`scripts/internal/resolve-tls-mode.sh`](../internal/resolve-tls-mode.sh) automatiskt det lämpligaste certifikatet:

1. **Steg 0 (Manuellt kopierat certifikat - `config/certs/custom/`):**
   * Om du kopierar ett befintligt certifikat (`tls.crt` och `tls.key`) till `config/certs/custom/` används det omedelbart med högsta prioritet.
2. **Steg 1 (Alternativ 1 - Publik FQDN och Let's Encrypt / Publik CA - `config/certs/public/`):**
   * Aktivt när `USE_PUBLIC_CA_CERTS=true` i `.env` och certifikatet finns på `config/certs/public/public_cert.crt`.
3. **Steg 2 (Alternativ 2 - Företagets Interna PKI - `config/certs/corp/`):**
   * Aktivt när `CORP_PKI_ENABLED=true` i `.env` och certifikatet finns på `config/certs/corp/corp_cert.crt`.
4. **Steg 3 (Alternativ 3 - Lokal CA på användarnivå - `config/certs/user_ca/`):**
   * Lokal CA läggs till i användarens personliga nyckelring (**0 root/admin-behörighet**) och ger grönt hänglås i webbläsare.
5. **Steg 4 (Alternativ 4 - Dynamiskt genererat Självsignerat certifikat - `config/certs/self_signed/`):**
   * ⚠️ **Lägsta nivå (Untrusted fallback):** Ger varningen *"Not Secure"* i webbläsaren. Tillåtet endast när `TLS_ALLOWED_LEVEL=permissive`.

---

## 💻 Skript på Användarnivå utan Admin-Rättigheter

* **macOS:**
  * [`trust-local-cert-mac.sh`](trust-local-cert-mac.sh): Lägger till CA i nyckelringen `~/Library/Keychains/login.keychain-db` utan `sudo`.
  * [`untrust-local-cert-mac.sh`](untrust-local-cert-mac.sh): Tar bort CA från nyckelringen.
* **Windows (PowerShell):**
  * [`trust-local-cert.ps1`](trust-local-cert.ps1): Lägger till CA i arkivet `Cert:\CurrentUser\Root` utan administratörsrättigheter.
* **Windows (CMD):**
  * [`trust-local-cert.cmd`](trust-local-cert.cmd): Kör PowerShell-skriptet under standardbehörigheter.
  * [`untrust-local-cert.cmd`](untrust-local-cert.cmd): Tar bort CA från Windows-arkivet.
* **Plattformsoberoende Rensning (All OS):**
  * [`clean-certs.sh`](clean-certs.sh) (CLI wrapper: `./scripts/clean-certs.sh`): Rensar gamla certifikat från nyckelring och disk.
  * Stöder flaggor: `--all`, `--keychain-only`, `--files-only`, `--regenerate`, `-y`.
  * Integrerat i miljöåterställning: `./scripts/reset-all.sh --clean-certs`.

---

## 🧪 Tls-testning
```bash
./tests/test-tls-scenarios.sh
```
