[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🔒 SSL/tls-sertifikaattien ja luottamuksen hallintamoduuli (zero-admin / non-root)

Tämä moduuli vastaa suojattujen HTTPS- ja TCPS-yhteyksien luomisesta, sertifikaattien valinnasta ja automaattisesta luottamuksesta macOS- ja Windows-ympäristöissä ilman järjestelmänvalvojan (`root` / `sudo`) oikeuksia.

---

## 🧭 5-tasoinen hierarkkinen tls-ratkaisuketju (priority chain)

Käynnistyksen ja määrityksen aikana [`scripts/internal/resolve-tls-mode.sh`](../internal/resolve-tls-mode.sh) tunnistaa automaattisesti sopivimman sertifikaatin:

1. **Vaihe 0 (Manuaalisesti kopioitu sertifikaatti - `config/certs/custom/`):**
   * Jos kopioit olemassa olevan sertifikaatin (`tls.crt` ja `tls.key`) hakemistoon `config/certs/custom/`, sitä käytetään heti korkeimmalla prioriteetilla.
2. **Vaihe 1 (Vaihtoehto 1 - Julkinen FQDN ja Let's Encrypt / Julkinen CA - `config/certs/public/`):**
   * Aktiivinen, kun `USE_PUBLIC_CA_CERTS=true` tiedostossa `.env` ja sertifikaatti sijaitsee polussa `config/certs/public/public_cert.crt`.
3. **Vaihe 2 (Vaihtoehto 2 - Yrityksen Sisäinen PKI - `config/certs/corp/`):**
   * Aktiivinen, kun `CORP_PKI_ENABLED=true` tiedostossa `.env` ja sertifikaatti sijaitsee polussa `config/certs/corp/corp_cert.crt`.
4. **Vaihe 3 (Vaihtoehto 3 - Käyttäjätason paikallinen CA - `config/certs/user_ca/`):**
   * Paikallinen CA lisätään käyttäjän henkilökohtaiseen avainnippuun (**0 root/admin-oikeutta**), mikä takaa vihreän lukkosymbolin selaimissa.
5. **Vaihe 4 (Vaihtoehto 4 - Dynaamisesti luotu Itseallekirjoitettu sertifikaatti - `config/certs/self_signed/`):**
   * ⚠️ **Matalin taso (Untrusted fallback):** Aiheuttaa selaimessa *"Not Secure"* -varoituksen. Sallittu vain, kun `TLS_ALLOWED_LEVEL=permissive`.

---

## 💻 Käyttäjätason Komentosarjat ilman admin-oikeuksia

* **macOS:**
  * [`trust-local-cert-mac.sh`](trust-local-cert-mac.sh): Lisää CA:n avainnippuun `~/Library/Keychains/login.keychain-db` ilman `sudo`-oikeuksia.
  * [`untrust-local-cert-mac.sh`](untrust-local-cert-mac.sh): Poistaa CA:n avainnipusta.
* **Windows (PowerShell):**
  * [`trust-local-cert.ps1`](trust-local-cert.ps1): Lisää CA:n säilöön `Cert:\CurrentUser\Root` ilman admin-oikeuksia.
* **Windows (CMD):**
  * [`trust-local-cert.cmd`](trust-local-cert.cmd): Suorittaa PowerShell-komentosarjan tavallisen käyttäjän oikeuksin.
  * [`untrust-local-cert.cmd`](untrust-local-cert.cmd): Poistaa CA:n Windows-säilöstä.
* **Alustariippumaton Puhdistus (All OS):**
  * [`clean-certs.sh`](clean-certs.sh) (CLI wrapper: `./scripts/clean-certs.sh`): Puhdistaa vanhat sertifikaatit avainnipusta ja levyltä.
  * Tukee valitsimia: `--all`, `--keychain-only`, `--files-only`, `--regenerate`, `-y`.
  * Integroitu nollaukseen: `./scripts/reset-all.sh --clean-certs`.

---

## 🧪 Tls-testaus
```bash
./tests/test-tls-scenarios.sh
```
