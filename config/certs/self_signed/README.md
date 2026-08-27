# Variant 4: Jooksvalt Genereeritud Iseallkirjastatud Sertifikaat (Self-Signed / Untrusted Fallback)

See kataloog sisaldab jooksvalt genereeritud lihtsat iseallkirjastatud sertifikaati (`self_signed.crt` ja `self_signed.key`).

## Omadused ja Olek:
* **Tase:** **Variant 4 (Kõige madalam varuvariant)**.
* **Staatus:** ⚠️ **Mitte-usaldatud (Untrusted)**.
* **Tulemus Brauseris:** Brauser kuvab *"Not Secure / Your connection is not private"* hoiatuse.
* **Kasutusala:** Automaatne varuvariant ainult juhul, kui arendaja masinas ei saa kasutada avalikku domeeni, ettevõtte PKI-d ega kohaliku CA usaldamist (`TLS_ALLOWED_LEVEL=permissive`).
