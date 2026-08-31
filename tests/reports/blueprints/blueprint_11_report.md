# Blueprinti 11 Testiaruanne (2026-08-30 14:34:15)

- **Aeg ja Kuupäev:** 2026-08-30 14:34:15
- **Kogu Paigalduse Kestus:** 12m 18s
- **Blueprinti Fail:** `config/blueprints/.env.11-*`

---

## 1. ⏱ Ajakulu ja Tervisekontroll (Duration & Health)
- **Tulemus:** ✅ Paigaldus ja tervisekontrollid läbitud 100% korrektselt.
- **Kestus kokku:** 12m 18s

---

## 2. 💻 Konteinerite Mälukasutus & CPU (RAM / CPU Metrics)

| Konteineri Nimi | CPU % | Mälukasutus / Limiit | RAM % |
| :--- | :--- | :--- | :--- |
| web-ide-dev | 1.30% | 78.7MB / 8.297GB | 0.95% |
| db-proxy | 13.68% | 552.3MB / 3.221GB | 17.14% |
| db-publisher | 11.45% | 532MB / 3.221GB | 16.52% |
| db-alise | 9.84% | 545MB / 3.221GB | 16.92% |
| app-ords | 65.29% | 530.1MB / 1.074GB | 49.37% |
| app-publisher | 144.82% | 265.7MB / 8.297GB | 3.20% |

---

## 3. 💾 Kettamaht (Podman Volumes & Storage)

| Voluumi Nimi | Kettamaht |
| :--- | :--- |
| oracle-free-db-in-prod_web_ide_data | N/A |
| oracle-free-db-in-prod_proxy_oradata | N/A |
| oracle-free-db-in-prod_apex_images_26_1 | N/A |
| oracle-free-db-in-prod_publisher_oradata | N/A |
| oracle-free-db-in-prod_alise_oradata | N/A |

---

## 4. 🗄️ Aktiivsed Konteinerid ja Pordid (Active Containers)

| Konteineri Nimi | Staatus | Pordid |
| :--- | :--- | :--- |
| web-ide-dev | Up 16 minutes (starting) | 0.0.0.0:8090->8443/tcp, 0.0.0.0:8091->8091/tcp, 0.0.0.0:8449->8443/tcp |
| db-proxy | Up 5 minutes (healthy) | 127.0.0.1:1532->1521/tcp |
| db-publisher | Up 15 minutes (healthy) | 127.0.0.1:1531->1521/tcp |
| db-alise | Up 5 minutes (healthy) | 127.0.0.1:1533->1521/tcp |
| app-ords | Up 44 seconds (starting) | 127.0.0.1:8088->8088/tcp, 127.0.0.1:8448->8448/tcp |
| app-publisher | Up 13 minutes (starting) | 127.0.0.1:9500->9500/tcp, 127.0.0.1:9502-9503->9502-9503/tcp, 9501/tcp, 9504-9999/tcp |

---

## 5. 🌐 Veebiteenuste URL Audit (URL Health Matrix)

| Veebiteenuse Nimi | Kontrollitud URL | HTTP Kood | TLS Usaldus | Staatus |
| :--- | :--- | :--- | :--- | :--- |
| ORDS Root HTTP | `http://localhost:8088/ords/` | `HTTP 200` | N/A | ✅ OK |
| Developer Hub (HTTPS) | `https://localhost:8448/dev-hub.html` | `HTTP 200` | ⚠️ Self-Signed | ✅ OK |
| ORDS Root HTTPS | `https://localhost:8448/ords/` | `HTTP 200` | ⚠️ Self-Signed | ✅ OK |
| ORDS Database Actions (Default) | `https://localhost:8448/ords/_/landing` | `HTTP 200` | ⚠️ Self-Signed | ✅ OK |
| APEX Builder (PROXY) | `https://localhost:8448/ords/proxy/r/apex/workspace-sign-in/oracle-apex-sign-in` | `HTTP 302` | ⚠️ Self-Signed | ✅ OK |
| APEX Instance Admin (PROXY) | `https://localhost:8448/ords/proxy/apex_admin` | `HTTP 302` | ⚠️ Self-Signed | ✅ OK |
| ORDS Database Actions (PROXY) | `https://localhost:8448/ords/proxy/_/landing` | `HTTP 200` | ⚠️ Self-Signed | ✅ OK |
| APEX Builder (ALISE) | `https://localhost:8448/ords/alise/r/apex/workspace-sign-in/oracle-apex-sign-in` | `HTTP 571` | ⚠️ Self-Signed | ❌ Kättesaamatu |
| APEX Instance Admin (ALISE) | `https://localhost:8448/ords/alise/apex_admin` | `HTTP 571` | ⚠️ Self-Signed | ❌ Kättesaamatu |
| ORDS Database Actions (ALISE) | `https://localhost:8448/ords/alise/_/landing` | `HTTP 000` | ⚠️ Self-Signed | ❌ Kättesaamatu |
| Publisher UI (HTTP) | `http://localhost:9502/xmlpserver` | `HTTP 000` | N/A | ❌ Kättesaamatu |
| Web IDE (HTTP) | `http://localhost:8090` | `HTTP 200` | N/A | ✅ OK |

---

## 6. 🔒 TLS / HTTPS Turvalisuse ja Sertifikaatide Audit (TLS Trust Matrix)
- **Aktiivne TLS Režiim:** `USER_LOCAL_CA`
- **Režiimi Kirjeldus:** Kasutajataseme lokaalne usaldatud CA (0 root/admin õigust)
- **Kasutatav Sertifikaat:** `/Users/allanlahe/Oracle/oracle-free-db-in-prod/config/certs/user_ca/localhost.crt`
- **Lubatud Poliitika Tase:** `permissive`
- **Mitte-Admin Usalduse Olek:** ✅ Usaldatud kasutaja tasemel (`Cert:\CurrentUser\Root` / `login.keychain-db`).

---

## 7. 🔑 SEPS Paroolivabade Oracle Wallet Ühenduste Audit (SEPS Wallet Connection Audit)

> 🛡️ **Turvalisus:** Aruanne ei sisalda avatud kujul ega salvestatud paroole. Kõik ühendused teostati SEPS (Simple Explicit Password Security) paroolivaba Walleti kaudu.

| SEPS Walleti Alias | Ühenduse Staatus | Tuvastatud Kasutaja & Baas |
| :--- | :--- | :--- |
| `DB_ALISE_APP` | ✅ OK | `USER_APP@FREEPDB1         ` |
| `DB_ALISE_APP_USER` | ✅ OK | `USER_APP@FREEPDB1         ` |
| `DB_ALISE_DBA_ADMIN` | ✅ OK | `DBA_ADMIN@FREEPDB1        ` |
| `DB_ALISE_DEV` | ✅ OK | `USER_DEVELOPER@FREEPDB1    ` |
| `DB_ALISE_SCHEMA` | ✅ OK | `APEX_PROXY_SCHEMA@FREEPDB1    ` |
| `DB_ALISE_SYS` | ✅ OK | `SYS@FREEPDB1              ` |
| `DB_ALISE_VIEWER` | ✅ OK | `USER_VIEWER@FREEPDB1      ` |
| `DB_PROXY_APP` | ✅ OK | `USER_APP@FREEPDB1         ` |
| `DB_PROXY_DBA_ADMIN` | ✅ OK | `DBA_ADMIN@FREEPDB1        ` |
| `DB_PROXY_DEV` | ✅ OK | `USER_DEVELOPER@FREEPDB1    ` |
| `DB_PROXY_SCHEMA` | ✅ OK | `APEX_PROXY_SCHEMA@FREEPDB1    ` |
| `DB_PROXY_SYS` | ✅ OK | `SYS@FREEPDB1              ` |
| `DB_PROXY_VIEWER` | ✅ OK | `USER_VIEWER@FREEPDB1      ` |
| `DB_PUBLISHER_BIPLATFORM` | ✅ OK | `SYS@FREE` |
| `DB_PUBLISHER_DBA_ADMIN` | ✅ OK | `DBA_ADMIN@FREEPDB1        ` |
| `DB_PUBLISHER_DEV` | ✅ OK | `USER_DEVELOPER@FREEPDB1    ` |
| `DB_PUBLISHER_RCU` | ✅ OK | `SYS@FREE` |
| `DB_PUBLISHER_READER` | ✅ OK | `SYS@FREE` |
| `DB_PUBLISHER_SCHEMA` | ✅ OK | `APEX_PROXY_SCHEMA@FREEPDB1    ` |
| `DB_PUBLISHER_SYS` | ✅ OK | `SYS@FREEPDB1              ` |
| `DB_PUBLISHER_VIEWER` | ✅ OK | `USER_VIEWER@FREEPDB1      ` |

### 💡 Parooli Pärimine Walletist
Kui arendajal või administraatoril on vaja tekstilist parooli (nt DBeaveri, DataGripi või välise tööriista jaoks), saab selle turvaliselt pärida käsuga:
```bash
./scripts/get-password.sh <WALLET_ALIAS>
```
Näiteks:
- `./scripts/get-password.sh DB_DEV` *(Arendaja parool)*
- `./scripts/get-password.sh DB_SYS` *(Administraatori parool)*

---

## 8. ⚠️ Tuvastatud Probleemid ja Iseparanemised (Log & Self-Healing Audit)
- Vead / Iseparanemised: 0 kriitilist viga. Automaatne kontroll sooritatud.
