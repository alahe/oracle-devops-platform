# Stsenaariumi 9 Testiaruanne (2026-08-26 23:58:01)

- **Aeg ja Kuupäev:** 2026-08-26 23:58:01
- **Kogu Paigalduse Kestus:** 8m 15s
- **Stsenaariumi Profiilifail:** `tests/scenarios/.env.9-*`

---

## 1. ⏱ Ajakulu ja Tervisekontroll (Duration & Health)
- **Tulemus:** ✅ Paigaldus ja tervisekontrollid läbitud 100% korrektselt.
- **Kestus kokku:** 8m 15s

---

## 2. 💻 Konteinerite Mälukasutus & CPU (RAM / CPU Metrics)

| Konteineri Nimi | CPU % | Mälukasutus / Limiit | RAM % |
| :--- | :--- | :--- | :--- |
| web-ide-dev | 0.27% | 91.5MB / 8.297GB | 1.10% |
| db-alise | 82.16% | 698.1MB / 3.221GB | 21.67% |
| app-ords | 48.88% | 544.5MB / 1.074GB | 50.71% |

---

## 3. 💾 Kettamaht (Podman Volumes & Storage)

| Voluumi Nimi | Kettamaht |
| :--- | :--- |
| oracle-free-db-in-prod_web_ide_data | N/A |
| oracle-free-db-in-prod_lis_oradata | N/A |
| oracle-free-db-in-prod_apex_images_26_1 | N/A |

---

## 4. 🗄️ Aktiivsed Konteinerid ja Pordid (Active Containers)

| Konteineri Nimi | Staatus | Pordid |
| :--- | :--- | :--- |
| web-ide-dev | Up 8 minutes (starting) | 0.0.0.0:8090->8443/tcp, 0.0.0.0:8091->8091/tcp, 0.0.0.0:8449->8443/tcp |
| db-alise | Up 8 minutes (healthy) | 127.0.0.1:1533->1521/tcp |
| app-ords | Up 42 seconds (starting) | 127.0.0.1:8088->8080/tcp, 127.0.0.1:8448->8443/tcp |

---

## 5. 🌐 Veebiteenuste URL Audit (URL Health Matrix)

| Veebiteenuse Nimi | Kontrollitud URL | HTTP Vastuse Kood | Staatus |
| :--- | :--- | :--- | :--- |
| ORDS Root HTTP | `http://localhost:8088/ords/` | `HTTP 302` | ✅ OK |
| ORDS Root HTTPS | `https://localhost:8448/ords/` | `HTTP 302` | ✅ OK |
| ORDS Database Actions | `https://localhost:8448/ords/_/landing` | `HTTP 200` | ✅ OK |
| ORDS LIS Pool | `https://localhost:8448/ords/lis/_/landing` | `HTTP 200` | ✅ OK |
| Web IDE (HTTP) | `http://localhost:8090` | `HTTP 302` | ✅ OK |

---

## 6. 🔑 SEPS Paroolivabade Oracle Wallet Ühenduste Audit (SEPS Wallet Connection Audit)

> 🛡️ **Turvalisus:** Aruanne ei sisalda avatud kujul ega salvestatud paroole. Kõik ühendused teostati SEPS (Simple Explicit Password Security) paroolivaba Walleti kaudu.

| SEPS Walleti Alias | Ühenduse Staatus | Tuvastatud Kasutaja & Baas |
| :--- | :--- | :--- |
| `DB_DB_ALISE_DBA_ADMIN` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_DB_ALISE_DEV` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_DB_ALISE_SCHEMA` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_DB_ALISE_SYS` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_DB_ALISE_VIEWER` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_ALISE_APP` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_ALISE_SYS` | ✅ Ühendus Õnnestus | `SYS@FREE` |

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
