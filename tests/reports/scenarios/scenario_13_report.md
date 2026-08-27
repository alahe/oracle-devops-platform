# Stsenaariumi 13 Testiaruanne (2026-08-27 00:46:35)

- **Aeg ja Kuupäev:** 2026-08-27 00:46:35
- **Kogu Paigalduse Kestus:** 7m 58s
- **Stsenaariumi Profiilifail:** `tests/scenarios/.env.13-*`

---

## 1. ⏱ Ajakulu ja Tervisekontroll (Duration & Health)
- **Tulemus:** ✅ Paigaldus ja tervisekontrollid läbitud 100% korrektselt.
- **Kestus kokku:** 7m 58s

---

## 2. 💻 Konteinerite Mälukasutus & CPU (RAM / CPU Metrics)

| Konteineri Nimi | CPU % | Mälukasutus / Limiit | RAM % |
| :--- | :--- | :--- | :--- |
| web-ide-dev | 0.24% | 93.87MB / 8.297GB | 1.13% |
| db-publisher | 11.87% | 532.6MB / 3.221GB | 16.53% |
| db-proxy | 59.79% | 625.3MB / 3.221GB | 19.41% |
| db-lis | 11.12% | 532.9MB / 3.221GB | 16.54% |
| app-ords | 12.73% | 508.8MB / 1.074GB | 47.38% |

---

## 3. 💾 Kettamaht (Podman Volumes & Storage)

| Voluumi Nimi | Kettamaht |
| :--- | :--- |
| oracle-free-db-in-prod_web_ide_data | N/A |
| oracle-free-db-in-prod_publisher_oradata | N/A |
| oracle-free-db-in-prod_apex_images_26_1 | N/A |
| oracle-free-db-in-prod_proxy_oradata | N/A |
| oracle-free-db-in-prod_lis_oradata | N/A |

---

## 4. 🗄️ Aktiivsed Konteinerid ja Pordid (Active Containers)

| Konteineri Nimi | Staatus | Pordid |
| :--- | :--- | :--- |
| web-ide-dev | Up 10 minutes (starting) | 0.0.0.0:8090->8443/tcp, 0.0.0.0:8091->8091/tcp, 0.0.0.0:8449->8443/tcp |
| db-publisher | Up 3 minutes (healthy) | 127.0.0.1:1531->1521/tcp |
| db-proxy | Up 10 minutes (healthy) | 127.0.0.1:1532->1521/tcp |
| db-lis | Up 3 minutes (healthy) | 127.0.0.1:1534->1521/tcp |
| app-ords | Up 2 minutes (starting) | 127.0.0.1:8088->8080/tcp, 127.0.0.1:8448->8443/tcp |

---

## 5. 🌐 Veebiteenuste URL Audit (URL Health Matrix)

| Veebiteenuse Nimi | Kontrollitud URL | HTTP Vastuse Kood | Staatus |
| :--- | :--- | :--- | :--- |
| ORDS Root HTTP | `http://localhost:8088/ords/` | `HTTP 302` | ✅ OK |
| ORDS Root HTTPS | `https://localhost:8448/ords/` | `HTTP 302` | ✅ OK |
| ORDS Database Actions | `https://localhost:8448/ords/_/landing` | `HTTP 571` | ❌ Kättesaamatu |
| ORDS Proxy Pool | `https://localhost:8448/ords/proxy/_/landing` | `HTTP 571` | ❌ Kättesaamatu |
| ORDS LIS Pool | `https://localhost:8448/ords/lis/_/landing` | `HTTP 571` | ❌ Kättesaamatu |
| Web IDE (HTTP) | `http://localhost:8090` | `HTTP 302` | ✅ OK |

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
| `DB_INFRA_RCU` | ℹ️ Vahele Jäetud | `Infra profiil pole aktiivne` |
| `DB_INFRA_SYS` | ℹ️ Vahele Jäetud | `Infra profiil pole aktiivne` |
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
