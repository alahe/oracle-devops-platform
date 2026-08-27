# Analytics Publisher Paigaldusfailide Kaust (`binaries/publisher/`)

Sellesse kausta talletatakse Oracle Analytics Publisheri (BIP / OAS) ametlikud paigalduspaketid ja binaarid.

## 📦 Toetatud Failid:
- `Oracle_Analytics_Server_Linux_2026.zip`
- `Oracle_Analytics_Server_Linux_2024.zip`
- `Oracle_Analytics_Server*.jar`
- `bieeconfiglogs*.zip`

## ⚙️ Kuidas Töötab:
- Utiliit `scripts/internal/download-publisher-binary.sh` laeb puudumisel paketi siia kausta.
- Kujutise ehitamisel (`docker/publisher/build-publisher-image.sh`) kopeeritakse failid siit automaatselt ehituskonteksti.
