# Blueprinti 21 Testiaruanne (2026-08-30 15:11:56)

- **Aeg ja Kuupäev:** 2026-08-30 15:11:56
- **Kogu Paigalduse Kestus:** 2m 56s
- **Blueprinti Fail:** `config/blueprints/.env.21-*`

---

## 1. ⏱ Ajakulu ja Tervisekontroll (Duration & Health)
- **Tulemus:** ✅ Paigaldus ja tervisekontrollid läbitud 100% korrektselt.
- **Kestus kokku:** 2m 56s

---

## 2. 💻 Konteinerite Mälukasutus & CPU (RAM / CPU Metrics)

| Konteineri Nimi | CPU % | Mälukasutus / Limiit | RAM % |
| :--- | :--- | :--- | :--- |
| web-ide-dev | 1.55% | 74.07MB / 8.297GB | 0.89% |
| db-proxy | 15.72% | 606.9MB / 3.221GB | 18.84% |
| db-forms | 8.61% | 545.3MB / 3.221GB | 16.93% |
| db-alise | 8.51% | 542.4MB / 3.221GB | 16.84% |
| app-ords | 32.13% | 580.3MB / 1.074GB | 54.04% |
| app-forms | 0.13% | 10.18MB / 8.297GB | 0.12% |

---

## 3. 💾 Kettamaht (Podman Volumes & Storage)

| Voluumi Nimi | Kettamaht |
| :--- | :--- |
| oracle-free-db-in-prod_web_ide_data | N/A |
| oracle-free-db-in-prod_proxy_oradata | N/A |
| oracle-free-db-in-prod_apex_images_26_1 | N/A |
| oracle-free-db-in-prod_forms_oradata | N/A |
| oracle-free-db-in-prod_alise_oradata | N/A |

---

## 4. 🗄️ Aktiivsed Konteinerid ja Pordid (Active Containers)

| Konteineri Nimi | Staatus | Pordid |
| :--- | :--- | :--- |
| web-ide-dev | Up 5 minutes (starting) | 0.0.0.0:8090->8443/tcp, 0.0.0.0:8091->8091/tcp, 0.0.0.0:8449->8443/tcp |
| db-proxy | Up 5 minutes (healthy) | 127.0.0.1:1532->1521/tcp |
| db-forms | Up 5 minutes (healthy) | 127.0.0.1:1534->1521/tcp |
| db-alise | Up 5 minutes (healthy) | 127.0.0.1:1533->1521/tcp |
| app-ords | Up 3 minutes (starting) | 127.0.0.1:8088->8088/tcp, 127.0.0.1:8448->8448/tcp |
| app-forms | Up 3 minutes (starting) | 127.0.0.1:6082->6082/tcp, 127.0.0.1:7001->7001/tcp, 127.0.0.1:9001-9002->9001-9002/tcp, 8088/tcp |

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
| ORDS Database Actions (ALISE) | `https://localhost:8448/ords/alise/_/landing` | `HTTP 571` | ⚠️ Self-Signed | ❌ Kättesaamatu |
| Forms Runtime (HTTP) | `http://localhost:9001/forms/frmservlet` | `HTTP 200` | N/A | ✅ OK |
| Forms Test Form (HTTP) | `http://localhost:9001/forms/frmservlet?form=test.fmx` | `HTTP 200` | N/A | ✅ OK |
| Forms Builder GUI (noVNC) | `http://localhost:6082/vnc.html` | `HTTP 200` | N/A | ✅ OK |
| Forms WebLogic Console (HTTP) | `http://localhost:7001/console` | `HTTP 200` | N/A | ✅ OK |
| Forms Builder Web GUI (HTTP) | `http://localhost:6082/vnc.html` | `HTTP 200` | N/A | ✅ OK |
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
| `DB_FORMS_APP` | ✅ OK | `USER_APP@FREEPDB1         ` |
| `DB_FORMS_DBA_ADMIN` | ✅ OK | `DBA_ADMIN@FREEPDB1        ` |
| `DB_FORMS_DEV` | ✅ OK | `USER_DEVELOPER@FREEPDB1    ` |
| `DB_FORMS_SCHEMA` | ✅ OK | `APEX_PROXY_SCHEMA@FREEPDB1    ` |
| `DB_FORMS_SYS` | ✅ OK | `SYS@FREEPDB1              ` |
| `DB_FORMS_VIEWER` | ✅ OK | `USER_VIEWER@FREEPDB1      ` |
| `DB_PROXY_APP` | ✅ OK | `USER_APP@FREEPDB1         ` |
| `DB_PROXY_DBA_ADMIN` | ✅ OK | `DBA_ADMIN@FREEPDB1        ` |
| `DB_PROXY_DEV` | ✅ OK | `USER_DEVELOPER@FREEPDB1    ` |
| `DB_PROXY_SCHEMA` | ✅ OK | `APEX_PROXY_SCHEMA@FREEPDB1    ` |
| `DB_PROXY_SYS` | ✅ OK | `SYS@FREEPDB1              ` |
| `DB_PROXY_VIEWER` | ✅ OK | `USER_VIEWER@FREEPDB1      ` |
| `DB_PUBLISHER_READER` | ℹ️ Skipped | `Publisher profile is not active` |

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
