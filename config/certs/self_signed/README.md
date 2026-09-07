[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# ⚠️ Ephemeral Self-Signed Certificates (Option 4 Fallback)

This directory contains dynamically generated self-signed certificates (`self_signed.crt` and `self_signed.key`).

## Status & Browser Experience:
* **Tier:** **Option 4 (Lowest Untrusted Fallback)**
* **Status:** ⚠️ **Untrusted**
* **Browser Result:** Browsers display a *"Not Secure / Your connection is not private"* warning.
* **Usage:** Automatic emergency fallback only when public domain, corporate PKI, or local CA trust cannot be utilized (`TLS_ALLOWED_LEVEL=permissive`).
