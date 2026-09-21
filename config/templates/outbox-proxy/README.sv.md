[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# Passiv Kärndatabas och DMZ Proxy-arkitektur (Transactional Outbox Pattern)

Detta arkitekturmönster upprätthåller en strikt säkerhetsmodell där kärndatabasen aldrig initierar utgående anslutningar.

---

## 1. Säkerhetsprincip: Kärndatabasen är INTE en utgående aktör

- **Kärndatabas (`db-alise`):** Isolerad i det interna nätverket. Brandväggar förbjuder utgående TCP-, HTTP- eller Kafka-anslutningar.
- **DMZ Proxy-databas (`db-proxy` / ORDS):** Placerad i mellanskiktet med behörighet att kommunicera utåt mot externa REST API:er och Kafka.
