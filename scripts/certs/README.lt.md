[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🔒 SSL/TLS Sertifikatų ir Pasitikėjimo Valdymo Modulis (Zero-Admin / Non-Root)

Šis modulis valdo saugius HTTPS ir TCPS ryšius, sertifikatų parinkimą ir automatinį pasitikėjimo diegimą macOS ir Windows aplinkose be administratoriaus (`root` / `sudo`) teisių.

---

## 🧭 5 Lygių Hierarchinė TLS Prioritetų Grandinė (Priority Chain)

Paleidimo ir konfigūravimo metu [`scripts/internal/resolve-tls-mode.sh`](../internal/resolve-tls-mode.sh) automatiškai nustato tinkamiausią sertifikatą:

1. **Žingsnis 0 (Rankiniu būdu nukopijuotas sertifikatas - `config/certs/custom/`):**
   * Nukopijavus esamą sertifikatą (`tls.crt` ir `tls.key`) į `config/certs/custom/`, jis naudojamas iš karto su aukščiausiu prioritetu.
2. **Žingsnis 1 (1 variantas - Viešasis FQDN ir Let's Encrypt / Viešasis CA - `config/certs/public/`):**
   * Aktyvus, kai `.env` nurodyta `USE_PUBLIC_CA_CERTS=true` ir sertifikatas yra `config/certs/public/public_cert.crt`.
3. **Žingsnis 2 (2 variantas - Įmonės Vidinis PKI - `config/certs/corp/`):**
   * Aktyvus, kai `.env` nurodyta `CORP_PKI_ENABLED=true` ir sertifikatas yra `config/certs/corp/corp_cert.crt`.
4. **Žingsnis 3 (3 variantas - Vartotojo lygio vietinis CA - `config/certs/user_ca/`):**
   * Vietinis CA pridedamas prie vartotojo asmeninės saugyklos (**0 root/admin teisių**), užtikrinant žalią spynelę naršyklėse.
5. **Žingsnis 4 (4 variantas - Dinamiškai sugeneruotas Savarankiškai pasirašytas sertifikatas - `config/certs/self_signed/`):**
   * ⚠️ **Žemiausias lygis (Untrusted fallback):** Naršyklėje rodo įspėjimą *"Not Secure"*. Leidžiama tik tada, kai `TLS_ALLOWED_LEVEL=permissive`.

---

## 💻 Vartotojo Lygio Scenarijai Be Administratoriaus Teisių

* **macOS:**
  * [`trust-local-cert-mac.sh`](trust-local-cert-mac.sh): Prideda CA į raktinę `~/Library/Keychains/login.keychain-db` be `sudo`.
  * [`untrust-local-cert-mac.sh`](untrust-local-cert-mac.sh): Pašalina CA iš raktinės.
* **Windows (PowerShell):**
  * [`trust-local-cert.ps1`](trust-local-cert.ps1): Prideda CA į saugyklą `Cert:\CurrentUser\Root` be administratoriaus teisių.
* **Windows (CMD):**
  * [`trust-local-cert.cmd`](trust-local-cert.cmd): Paleidžia PowerShell scenarijų standartinio vartotojo teisėmis.
  * [`untrust-local-cert.cmd`](untrust-local-cert.cmd): Pašalina CA iš Windows saugyklos.
* **Kelių Platformų Valymas (All OS):**
  * [`clean-certs.sh`](clean-certs.sh) (CLI wrapper: `./scripts/clean-certs.sh`): Išvalo senus sertifikatus iš raktinės ir disko.
  * Palaiko vėliavėles: `--all`, `--keychain-only`, `--files-only`, `--regenerate`, `-y`.
  * Integruotas į aplinkos atstatymą: `./scripts/reset-all.sh --clean-certs`.

---

## 🧪 TLS Testavimas
```bash
./tests/test-tls-scenarios.sh
```
