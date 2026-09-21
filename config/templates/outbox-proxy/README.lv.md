[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# Pasīvās Pamatdatubāzes un DMZ Proxy Arhitektūra (Transactional Outbox Pattern)

Šis arhitektūras modelis nodrošina stingru finanšu sistēmu drošības modeli, kurā pamatdatubāze neuzsāk izejošos savienojumus.

---

## 1. Drošības princips: Pamatdatubāze NAV izejošais dalībnieks

- **Pamatdatubāze (`db-alise`):** Izolēta iekšējā tīklā. Ugunsmūri aizliedz izejošos TCP, HTTP vai Kafka savienojumus.
- **DMZ Proxy datubāze (`db-proxy` / ORDS):** Izvietota starpslānī un drīkst veikt ārējos REST un Kafka izsaukumus.
