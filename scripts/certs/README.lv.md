[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🔒 SSL/TLS Sertifikātu un Uzticamības Pārvaldības Modulis (Zero-Admin / Non-Root)

Šis modulis pārvalda drošus HTTPS un TCPS savienojumus, sertifikātu atlasi un automātisku uzticamības instalēšanu macOS un Windows vidēs bez administratora (`root` / `sudo`) tiesībām.

---

## 🧭 5 Līmeņu Hierarhiskā TLS Prioritāšu Ķēde (Priority Chain)

Palaišanas un konfigurēšanas laikā [`scripts/internal/resolve-tls-mode.sh`](../internal/resolve-tls-mode.sh) automātiski nosaka piemērotāko sertifikātu:

1. **Solis 0 (Manuāli kopēts sertifikāts - `config/certs/custom/`):**
   * Ja iekopējat esošu sertifikātu (`tls.crt` un `tls.key`) mapē `config/certs/custom/`, tas tiek izmantots nekavējoties ar augstāko prioritāti.
2. **Solis 1 (1. variants - Publiskais FQDN un Let's Encrypt / Publiskā CA - `config/certs/public/`):**
   * Aktīvs, ja failā `.env` ir `USE_PUBLIC_CA_CERTS=true` un sertifikāts atrodas `config/certs/public/public_cert.crt`.
3. **Solis 2 (2. variants - Uzņēmuma Iekšējā PKI - `config/certs/corp/`):**
   * Aktīvs, ja failā `.env` ir `CORP_PKI_ENABLED=true` un sertifikāts atrodas `config/certs/corp/corp_cert.crt`.
4. **Solis 3 (3. variants - Lietotāja līmeņa lokālā CA - `config/certs/user_ca/`):**
   * Lokālā CA tiek pievienota lietotāja personīgajai atslēgu glabātuvei (**0 root/admin tiesības**), nodrošinot zaļo piekaramo atslēgu pārlūkprogrammās.
5. **Solis 4 (4. variants - Dinamiski ģenerēts Pašparakstīts sertifikāts - `config/certs/self_signed/`):**
   * ⚠️ **Zemākais līmenis (Untrusted fallback):** Pārlūkprogrammā rada brīdinājumu *"Not Secure"*. Atļauts tikai tad, ja `TLS_ALLOWED_LEVEL=permissive`.

---

## 💻 Lietotāja Līmeņa Skripti Bez Administratora Tiesībām

* **macOS:**
  * [`trust-local-cert-mac.sh`](trust-local-cert-mac.sh): Pievieno CA atslēgu glabātuvei `~/Library/Keychains/login.keychain-db` bez `sudo`.
  * [`untrust-local-cert-mac.sh`](untrust-local-cert-mac.sh): Noņem CA no atslēgu glabātuves.
* **Windows (PowerShell):**
  * [`trust-local-cert.ps1`](trust-local-cert.ps1): Pievieno CA glabātuvei `Cert:\CurrentUser\Root` bez administratora tiesībām.
* **Windows (CMD):**
  * [`trust-local-cert.cmd`](trust-local-cert.cmd): Izpilda PowerShell skriptu ar parastā lietotāja tiesībām.
  * [`untrust-local-cert.cmd`](untrust-local-cert.cmd): Noņem CA no Windows glabātuves.
* **Starpplatformu Tīrīšana (All OS):**
  * [`clean-certs.sh`](clean-certs.sh) (CLI wrapper: `./scripts/clean-certs.sh`): Notīra vecos sertifikātus no atslēgu glabātuves un diska.
  * Atbalsta karodziņus: `--all`, `--keychain-only`, `--files-only`, `--regenerate`, `-y`.
  * Integrēts vides atiestatīšanā: `./scripts/reset-all.sh --clean-certs`.

---

## 🧪 TLS Testēšana
```bash
./tests/test-tls-scenarios.sh
```
