[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# Pasyvios Pagrindinės Duomenų Bazės ir DMZ Proxy Architektūra (Transactional Outbox Pattern)

Šis architektūros šablonas įgyvendina griežtą saugumo modelį, kuriame pagrindinė duomenų bazė neinicijuoja išeinančių ryšių.

---

## 1. Saugumo principas: Pagrindinė duomenų bazė NĖRA išeinantis veikėjas

- **Pagrindinė duomenų bazė (`db-alise`):** Izoliuota vidiniame tinkle. Užkardos draudžia išeinančius TCP, HTTP ar Kafka ryšius.
- **DMZ Proxy duomenų bazė (`db-proxy` / ORDS):** Tarpiniame lygmenyje veikianti DB, kuriai leidžiama atlikti išorinius REST ir Kafka iškvietimus.
