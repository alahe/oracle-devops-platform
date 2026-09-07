[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🛠️ Pielāgoti SSL/TLS Sertifikāti (Custom Certificate Drop-In)

Izstrādātāji vai administratori šeit var iekopēt esošu SSL/TLS sertifikātu un privāto atslēgu, ko sistēma automātiski nosaka ar visaugstāko prioritāti (**Solis 0**).

## Failu Nosaukumu Noteikumi:
Ievietojiet šajā direktorijā šādus failus:
* **Sertifikāts:** `tls.crt` (vai `cert.crt`, `fullchain.pem`)
* **Privātā atslēga:** `tls.key` (vai `key.key`, `privkey.pem`)
* *(Neobligāti)* **CA ķēde:** `ca.crt` (vai `chain.pem`)

## Automātiskā Noteikšana:
1. Konstatējot `.crt` un `.key` failus, TLS režīms automātiski kļūst par:
   `RESOLVED_TLS_MODE=CUSTOM_CERT`
2. ORDS, Analytics Publisher un tīmekļa pakalpojumi nekavējoties izmanto šo sertifikātu.
3. Faili šajā direktorijā ir aizsargāti ar `.gitignore` un netiek iekļauti Git versiju kontrolē.
