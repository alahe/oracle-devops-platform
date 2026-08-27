# Stsenaariumi 7 Testiaruanne (2026-08-27 01:25:18)

- **Aeg ja Kuupäev:** 2026-08-27 01:25:18
- **Kogu Paigalduse Kestus:** 14m 42s
- **Stsenaariumi Profiilifail:** `tests/scenarios/.env.7-*`

---

## 1. ⏱ Ajakulu ja Tervisekontroll (Duration & Health)
- **Tulemus:** ✅ Paigaldus ja tervisekontrollid läbitud 100% korrektselt.
- **Kestus kokku:** 14m 42s

---

## 2. 💻 Konteinerite Mälukasutus & CPU (RAM / CPU Metrics)

| Konteineri Nimi | CPU % | Mälukasutus / Limiit | RAM % |
| :--- | :--- | :--- | :--- |
| db-publisher | 12.77% | 485.9MB / 3.221GB | 15.09% |
| db-proxy | 12.84% | 517.8MB / 3.221GB | 16.08% |
| db-lis | 59.66% | 657.5MB / 3.221GB | 20.41% |
| app-ords | 12.61% | 503.8MB / 1.074GB | 46.92% |

---

## 3. 💾 Kettamaht (Podman Volumes & Storage)

| Voluumi Nimi | Kettamaht |
| :--- | :--- |
| oracle-free-db-in-prod_publisher_oradata | N/A |
| oracle-free-db-in-prod_apex_images_26_1 | N/A |
| oracle-free-db-in-prod_proxy_oradata | N/A |
| oracle-free-db-in-prod_lis_oradata | N/A |

---

## 4. 🗄️ Aktiivsed Konteinerid ja Pordid (Active Containers)

| Konteineri Nimi | Staatus | Pordid |
| :--- | :--- | :--- |
| db-publisher | Up 3 minutes (healthy) | 127.0.0.1:1531->1521/tcp |
| db-proxy | Up 3 minutes (healthy) | 127.0.0.1:1532->1521/tcp |
| db-lis | Up 9 minutes (healthy) | 127.0.0.1:1533->1521/tcp |
| app-ords | Up 2 minutes (starting) | 127.0.0.1:8088->8080/tcp, 127.0.0.1:8448->8443/tcp |

---

## 5. 🌐 Veebiteenuste URL Audit (URL Health Matrix)

| Veebiteenuse Nimi | Kontrollitud URL | HTTP Vastuse Kood | Staatus |
| :--- | :--- | :--- | :--- |
| ORDS Root HTTP | `http://localhost:8088/ords/` | `HTTP 302` | ✅ OK |
| ORDS Root HTTPS | `https://localhost:8448/ords/` | `HTTP 302` | ✅ OK |
| ORDS Database Actions | `https://localhost:8448/ords/_/landing` | `HTTP 200` | ✅ OK |
| ORDS Proxy Pool | `https://localhost:8448/ords/proxy/_/landing` | `HTTP 200` | ✅ OK |
| ORDS LIS Pool | `https://localhost:8448/ords/lis/_/landing` | `HTTP 200` | ✅ OK |

---

## 6. 🔑 SEPS Paroolivabade Oracle Wallet Ühenduste Audit (SEPS Wallet Connection Audit)

> 🛡️ **Turvalisus:** Aruanne ei sisalda avatud kujul ega salvestatud paroole. Kõik ühendused teostati SEPS (Simple Explicit Password Security) paroolivaba Walleti kaudu.

| SEPS Walleti Alias | Ühenduse Staatus | Tuvastatud Kasutaja & Baas |
| :--- | :--- | :--- |
| `APEX_PROXY_SCHEMA` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_APEX_PROXY_SCHEMA` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_APEX_PROXY_SYS` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_DBA_ADMIN` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_DB_LIS_DBA_ADMIN` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_DB_LIS_DEV` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_DB_LIS_SCHEMA` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_DB_LIS_SYS` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_DB_LIS_VIEWER` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_DB_PROXY_DBA_ADMIN` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_DB_PROXY_DEV` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_DB_PROXY_SCHEMA` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_DB_PROXY_SYS` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_DB_PROXY_VIEWER` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_DB_PUBLISHER_DBA_ADMIN` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_DB_PUBLISHER_DEV` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_DB_PUBLISHER_SCHEMA` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_DB_PUBLISHER_SYS` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_DB_PUBLISHER_VIEWER` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_LIS_APP` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_LIS_SYS` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_PUBLISHER_BIPLATFORM` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_PUBLISHER_RCU` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_PUBLISHER_READER` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_PUBLISHER_SYS` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_TEST_DEV` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_TEST_VIEWER` | ✅ Ühendus Õnnestus | `SYS@FREE` |

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
