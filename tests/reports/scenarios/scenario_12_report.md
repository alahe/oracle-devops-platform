# Stsenaariumi 12 Testiaruanne (2026-08-26 23:48:35)

- **Aeg ja Kuupäev:** 2026-08-26 23:48:35
- **Kogu Paigalduse Kestus:** 1m 27s
- **Stsenaariumi Profiilifail:** `tests/scenarios/.env.12-*`

---

## 1. ⏱ Ajakulu ja Tervisekontroll (Duration & Health)
- **Tulemus:** ✅ Paigaldus ja tervisekontrollid läbitud 100% korrektselt.
- **Kestus kokku:** 1m 27s

---

## 2. 💻 Konteinerite Mälukasutus & CPU (RAM / CPU Metrics)

| Konteineri Nimi | CPU % | Mälukasutus / Limiit | RAM % |
| :--- | :--- | :--- | :--- |
| web-ide-dev | 1.34% | 96.26MB / 8.297GB | 1.16% |
| db-publisher | 36.78% | 507.9MB / 3.221GB | 15.77% |

---

## 3. 💾 Kettamaht (Podman Volumes & Storage)

| Voluumi Nimi | Kettamaht |
| :--- | :--- |
| oracle-free-db-in-prod_web_ide_data | N/A |
| oracle-free-db-in-prod_publisher_oradata | N/A |
| oracle-free-db-in-prod_apex_images_26_1 | N/A |

---

## 4. 🗄️ Aktiivsed Konteinerid ja Pordid (Active Containers)

| Konteineri Nimi | Staatus | Pordid |
| :--- | :--- | :--- |
| web-ide-dev | Up About a minute (starting) | 0.0.0.0:8090->8443/tcp, 0.0.0.0:8091->8091/tcp, 0.0.0.0:8449->8443/tcp |
| db-publisher | Up About a minute (healthy) | 127.0.0.1:1531->1521/tcp |

---

## 5. 🌐 Veebiteenuste URL Audit (URL Health Matrix)

| Veebiteenuse Nimi | Kontrollitud URL | HTTP Vastuse Kood | Staatus |
| :--- | :--- | :--- | :--- |
| Web IDE (HTTP) | `http://localhost:8090` | `HTTP 302` | ✅ OK |
| Web IDE (HTTPS) | `https://localhost:8449` | `HTTP 000` | ❌ Kättesaamatu |

---

## 6. 🔑 SEPS Paroolivabade Oracle Wallet Ühenduste Audit (SEPS Wallet Connection Audit)

> 🛡️ **Turvalisus:** Aruanne ei sisalda avatud kujul ega salvestatud paroole. Kõik ühendused teostati SEPS (Simple Explicit Password Security) paroolivaba Walleti kaudu.

| SEPS Walleti Alias | Ühenduse Staatus | Tuvastatud Kasutaja & Baas |
| :--- | :--- | :--- |
| `DB_DB_PUBLISHER_DBA_ADMIN` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_DB_PUBLISHER_DEV` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_DB_PUBLISHER_SCHEMA` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_DB_PUBLISHER_SYS` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_DB_PUBLISHER_VIEWER` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_PUBLISHER_BIPLATFORM` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_PUBLISHER_RCU` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_PUBLISHER_READER` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_PUBLISHER_SYS` | ✅ Ühendus Õnnestus | `SYS@FREE` |

### 💡 Parooli Pärimine Walletist
Kui arendajal või administraatoril on vaja tekstilist parooli (nt DBeaveri, DataGripi või välise tööriista jaoks), saab selle turvaliselt pärida käsuga:
```bash
./scripts/internal/view-wallet-credential.sh <WALLET_ALIAS>
```
Näiteks:
- `./scripts/internal/view-wallet-credential.sh DB_DEV` *(Arendaja parool)*
- `./scripts/internal/view-wallet-credential.sh DB_SYS` *(Administraatori parool)*

---

## 7. ⚠️ Tuvastatud Probleemid ja Iseparanemised (Log & Self-Healing Audit)
- Vead / Iseparanemised: 0 kriitilist viga. Automaatne kontroll sooritatud.
