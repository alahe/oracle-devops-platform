[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🛠️ Käsitsi Lisatud Sertifikaadid (Custom Certificate Drop-In)

Sellesse kataloogi saab arendaja või administraator kopeerida oma olemasoleva SSL/TLS sertifikaadi ja privaatvõtme, mida süsteem kasutab automaatselt esmase prioriteedina (**Samm 0**).

## Failide Nimetamise Reeglid:
Paiguta siia kausta järgmised failid:
* **Sertifikaat:** `tls.crt` (või `cert.crt`, `fullchain.pem`)
* **Privaatvõti:** `tls.key` (või `key.key`, `privkey.pem`)
* *(Valikuline)* **CA Ahel:** `ca.crt` (või `chain.pem`)

## Kuidas süsteem seda kasutab:
1. Kui kaustas on `.crt` ja `.key` failid, lülitub TLS režiimiks automaatselt:
   `RESOLVED_TLS_MODE=CUSTOM_CERT`
2. ORDS, Analytics Publisher ja veebiteenused võtavad automaatselt kasutusele antud sertifikaadi.
3. Failid selles kataloogis on `.gitignore` poolt kaitstud ning ei satu kunagi Giti versioonihaldusse.
