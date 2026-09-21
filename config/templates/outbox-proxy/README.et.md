[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# Passiivne Äriandmebaas ja DMZ Proxy Arhitektuur (Transactional Outbox Pattern)

See arhitektuurimuster jõustab ranget finantssüsteemide turvamudelit, kus äribaas ei algata välisühendusi.

---

## 1. Turvapõhimõte: Äribaas EI OLE väljaminev aktor

Kõrge turvalisusega finantstaristus:
- **Äriandmebaas (`db-alise`):** Asub isoleeritud sisevõrgus. Tulemüüripoliitikad keelavad äribaasist väljaminevad TCP-, HTTP- või sõnumivahendaja (Kafka/RabbitMQ) ühendused.
- **DMZ / Middleware Proxy andmebaas (`db-proxy` / ORDS):** Asub vahekihis ja omab luba teha väljaminevaid päringuid partnerite REST API-desse ja Kafka klastritesse.

---

## 2. Toimimise Voog (Transactional Outbox)

1. **Tehingu faas (Äribaas):**
   - Äriprotseduur salvestab tehingu ja kirjutab samas transaktsioonis sündmuse tabelisse `outbox_events` (`pkg_outbox.publish_event`).
   - Kui tehing katkeb, sündmust ei salvestata. Välistatud on "kummitussõnumid".
2. **Tõmbamise ja saatmise faas (Proxy andmebaas):**
   - Proxy andmebaasis töötav `DBMS_SCHEDULER` loeb perioodiliselt ootel sündmusi ja teeb tegeliku väljamineva REST/Kafka päringu.
3. **Kinnituse faas:**
   - Eduka saatmise järel uuendab Proxy andmebaas sündmuse staatuseks `'PUBLISHED'`.
