[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🛠️ Custom Certificate Drop-In (Priority Step 0)

Developers or system administrators can place an existing SSL/TLS certificate and private key here, which the platform automatically detects as top priority (**Step 0**).

## File Naming Conventions:
Place the following files in this directory:
* **Certificate:** `tls.crt` (or `cert.crt`, `fullchain.pem`)
* **Private Key:** `tls.key` (or `key.key`, `privkey.pem`)
* *(Optional)* **CA Chain:** `ca.crt` (or `chain.pem`)

## Automatic Platform Detection:
1. When `.crt` and `.key` files are detected, the system sets:
   `RESOLVED_TLS_MODE=CUSTOM_CERT`
2. ORDS, Analytics Publisher, and web services automatically bind this certificate.
3. Directory contents are protected by `.gitignore` and never committed to Git.
