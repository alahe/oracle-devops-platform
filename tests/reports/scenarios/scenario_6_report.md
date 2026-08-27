# Stsenaariumi 6 Testiaruanne (2026-08-26 23:33:28)

- **Aeg ja Kuupäev:** 2026-08-26 23:33:28
- **Kogu Paigalduse Kestus:** 7m 52s
- **Stsenaariumi Profiilifail:** `tests/scenarios/.env.6-*`

---

## 1. ⏱ Ajakulu ja Tervisekontroll (Duration & Health)
- **Tulemus:** ✅ Paigaldus ja tervisekontrollid läbitud 100% korrektselt.
- **Kestus kokku:** 7m 52s

---

## 2. 💻 Konteinerite Mälukasutus & CPU (RAM / CPU Metrics)

| Konteineri Nimi | CPU % | Mälukasutus / Limiit | RAM % |
| :--- | :--- | :--- | :--- |
| db-proxy | 78.07% | 688.7MB / 3.221GB | 21.38% |
| app-ords | 39.00% | 544.1MB / 1.074GB | 50.67% |

---

## 3. 💾 Kettamaht (Podman Volumes & Storage)

| Voluumi Nimi | Kettamaht |
| :--- | :--- |
| oracle-free-db-in-prod_proxy_oradata | N/A |
| oracle-free-db-in-prod_apex_images_26_1 | N/A |

---

## 4. 🗄️ Aktiivsed Konteinerid ja Pordid (Active Containers)

| Konteineri Nimi | Staatus | Pordid |
| :--- | :--- | :--- |
| db-proxy | Up 8 minutes (healthy) | 127.0.0.1:1532->1521/tcp |
| app-ords | Up 57 seconds (starting) | 127.0.0.1:8088->8080/tcp, 127.0.0.1:8448->8443/tcp |

---

## 5. 🌐 Veebiteenuste URL Audit (URL Health Matrix)

| Veebiteenuse Nimi | Kontrollitud URL | HTTP Vastuse Kood | Staatus |
| :--- | :--- | :--- | :--- |
| ORDS Root HTTP | `http://localhost:8088/ords/` | `HTTP 302` | ✅ OK |
| ORDS Root HTTPS | `https://localhost:8448/ords/` | `HTTP 302` | ✅ OK |
| ORDS Database Actions | `https://localhost:8448/ords/_/landing` | `HTTP 200` | ✅ OK |
| ORDS Proxy Pool | `https://localhost:8448/ords/proxy/_/landing` | `HTTP 404` | ✅ OK |

---

## 6. 🔑 SEPS Paroolivabade Oracle Wallet Ühenduste Audit (SEPS Wallet Connection Audit)

> 🛡️ **Turvalisus:** Aruanne ei sisalda avatud kujul ega salvestatud paroole. Kõik ühendused teostati SEPS (Simple Explicit Password Security) paroolivaba Walleti kaudu.

| SEPS Walleti Alias | Ühenduse Staatus | Tuvastatud Kasutaja & Baas |
| :--- | :--- | :--- |
| `APEX_PROXY_SCHEMA` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_APEX_PROXY_SCHEMA` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_APEX_PROXY_SYS` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_DBA_ADMIN` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_DB_PROXY_DBA_ADMIN` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_DB_PROXY_DEV` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_DB_PROXY_SCHEMA` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_DB_PROXY_SYS` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_DB_PROXY_VIEWER` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_PUBLISHER_READER` | ℹ️ Vahele Jäetud | `Publisher profiil pole aktiivne` |
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
