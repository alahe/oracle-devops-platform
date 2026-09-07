# 🔒 SSL/TLS Sertifikaatide ja Usaldamise Moodul (Zero-Admin / Non-Root)

See moodul vastutab HTTPS ja TCPS turvaliste ühenduste loomise, sertifikaatide valiku ja automaatse usaldamise eest macOS ja Windows keskkondades ilma administraatori (root / sudo) õigusteta.

---

## 🧭 5-Astmeline Hierarhiline TLS Lahendusahel (Priority Chain)

Iga käivituse ja seadistuse ajal tuvastab [`scripts/internal/resolve-tls-mode.sh`](../internal/resolve-tls-mode.sh) automaatselt sobivaima sertifikaadi:

1. **Samm 0 (Käsitsi kopeeritud sertifikaat - `config/certs/custom/`):**
   * Kui kopeerid olemasoleva sertifikaadi (`tls.crt` ja `tls.key`) kausta `config/certs/custom/`, võetakse see koheselt esmase prioriteedina kasutusse.
2. **Samm 1 (Variant 1 - Avalik FQDN ja Let's Encrypt / Avalik CA - `config/certs/public/`):**
   * Kui `.env` failis on `USE_PUBLIC_CA_CERTS=true` ja sertifikaat asub `config/certs/public/public_cert.crt`.
3. **Samm 2 (Variant 2 - Ettevõtte Sise-PKI - `config/certs/corp/`):**
   * Kui `.env` failis on `CORP_PKI_ENABLED=true` ja sertifikaat asub `config/certs/corp/corp_cert.crt`.
4. **Samm 3 (Variant 3 - Kasutajataseme lokaalne CA - `config/certs/user_ca/`):**
   * Lokaalne CA lisatakse kasutaja isiklikku hoidlasse (**0 root/admin õigust**) ja tagab rohelise tabaluku.
5. **Samm 4 (Variant 4 - Jooksvalt genereeritud Iseallkirjastatud sertifikaat - `config/certs/self_signed/`):**
   * ⚠️ **Madalaim tase (Untrusted fallback):** Tekitab brauseris *"Not Secure"* hoiatuse. Lubatud ainult siis, kui `TLS_ALLOWED_LEVEL=permissive`. Kui nõutakse `trusted_local` või rangemat, peatub paigaldus veaga.

---

## 💻 Kasutajataseme Mitte-Admin Skriptid (User-Space Trust)

* **macOS:**
  * [`trust-local-cert-mac.sh`](trust-local-cert-mac.sh): Lisab CA kasutaja võtmehoidlasse `~/Library/Keychains/login.keychain-db` ilma `sudo` õigusteta.
  * [`untrust-local-cert-mac.sh`](untrust-local-cert-mac.sh): Eemaldab CA kasutaja võtmehoidjast.
* **Windows (PowerShell):**
  * [`trust-local-cert.ps1`](trust-local-cert.ps1): Lisab CA kasutaja isiklikku hoidlasse `Cert:\CurrentUser\Root` ilma administraatori või UAC kinnituseta.
* **Windows (CMD):**
  * [`trust-local-cert.cmd`](trust-local-cert.cmd): Käivitab PowerShell skripti tavakasutaja õigustes.
  * [`untrust-local-cert.cmd`](untrust-local-cert.cmd): Eemaldab CA Windowsi kasutaja hoidlast.
* **Platvormiülene Puhastus (All OS):**
  * [`clean-certs.sh`](clean-certs.sh) (CLI wrapper: `./scripts/clean-certs.sh`): Puhastab vanad sertifikaadid nii OS võtmehoidjast kui kettalt (`config/certs/`, `config/wallet-*/`).
  * Toetab lippe: `--all`, `--keychain-only`, `--files-only`, `--regenerate`, `-y`.
  * Integreeritud ka keskkonna lähtestamisse: `./scripts/reset-all.sh --clean-certs`.

---

## 🧪 TLS Režiimide ja Poliitikate Testimine
```bash
# Käivita automaatne TLS testikomplekt:
./tests/test-tls-scenarios.sh
```
