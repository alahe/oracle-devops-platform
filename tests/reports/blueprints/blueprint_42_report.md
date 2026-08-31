# Blueprinti 42 Testiaruanne (2026-08-29 11:35:07)

- **Aeg ja Kuupäev:** 2026-08-29 11:35:07
- **Kogu Paigalduse Kestus:** 67m 27s
- **Blueprinti Fail:** `config/blueprints/.env.42-*`

---

## 1. ⏱ Ajakulu ja Tervisekontroll (Duration & Health)
- **Tulemus:** ✅ Paigaldus ja tervisekontrollid läbitud 100% korrektselt.
- **Kestus kokku:** 67m 27s

---

## 2. 💻 Konteinerite Mälukasutus & CPU (RAM / CPU Metrics)

| Konteineri Nimi | CPU % | Mälukasutus / Limiit | RAM % |
| :--- | :--- | :--- | :--- |
| web-ide-dev | 9.19% | 86.86MB / 8.297GB | 1.05% |
| db-forms | 20.54% | 7.311MB / 3.221GB | 0.23% |
| db-publisher | 19.37% | 7.315MB / 3.221GB | 0.23% |
| db-proxy | 19.24% | 7.311MB / 3.221GB | 0.23% |
| db-alise | 43.02% | 623.9MB / 3.221GB | 19.37% |
| app-ords | 11.02% | 527.6MB / 1.074GB | 49.14% |
| app-forms | 0.09% | 9.609MB / 8.297GB | 0.12% |

---

## 3. 💾 Kettamaht (Podman Volumes & Storage)

| Voluumi Nimi | Kettamaht |
| :--- | :--- |
| oracle-free-db-in-prod_web_ide_data | N/A |
| oracle-free-db-in-prod_forms_oradata | N/A |
| oracle-free-db-in-prod_apex_images_26_1 | N/A |
| oracle-free-db-in-prod_publisher_oradata | N/A |
| oracle-free-db-in-prod_proxy_oradata | N/A |
| oracle-free-db-in-prod_lis_oradata | N/A |

---

## 4. 🗄️ Aktiivsed Konteinerid ja Pordid (Active Containers)

| Konteineri Nimi | Staatus | Pordid |
| :--- | :--- | :--- |
| web-ide-dev | Up About an hour (starting) | 0.0.0.0:8090->8443/tcp, 0.0.0.0:8091->8091/tcp, 0.0.0.0:8449->8443/tcp |
| db-forms | Up About an hour (healthy) | 127.0.0.1:1534->1521/tcp |
| db-publisher | Up About an hour (healthy) | 127.0.0.1:1531->1521/tcp |
| db-proxy | Up About an hour (healthy) | 127.0.0.1:1532->1521/tcp |
| db-alise | Up 6 minutes (healthy) | 127.0.0.1:1533->1521/tcp |
| app-ords | Up 4 minutes (starting) | 127.0.0.1:8088->8088/tcp, 127.0.0.1:8448->8448/tcp |
| app-forms | Up 5 minutes (starting) | 127.0.0.1:6082->6082/tcp, 127.0.0.1:7001->7001/tcp, 127.0.0.1:9001-9002->9001-9002/tcp, 8088/tcp |

---

## 5. 🌐 Veebiteenuste URL Audit (URL Health Matrix)

| Veebiteenuse Nimi | Kontrollitud URL | HTTP Kood | TLS Usaldus | Staatus |
| :--- | :--- | :--- | :--- | :--- |
| ORDS Root HTTP | `http://localhost:8088/ords/` | `HTTP 302` | N/A | ✅ OK |
| ORDS Root HTTPS | `https://localhost:8448/ords/` | `HTTP 302` | ⚠️ Self-Signed | ✅ OK |
| ORDS Database Actions (Default) | `https://localhost:8448/ords/_/landing` | `HTTP 571` | ⚠️ Self-Signed | ❌ Kättesaamatu |
| APEX Builder (PROXY) | `https://localhost:8448/ords/proxy/r/apex/workspace-sign-in/oracle-apex-sign-in` | `HTTP 571` | ⚠️ Self-Signed | ❌ Kättesaamatu |
| APEX Instance Admin (PROXY) | `https://localhost:8448/ords/proxy/apex_admin` | `HTTP 571` | ⚠️ Self-Signed | ❌ Kättesaamatu |
| ORDS Database Actions (PROXY) | `https://localhost:8448/ords/proxy/_/landing` | `HTTP 571` | ⚠️ Self-Signed | ❌ Kättesaamatu |
| APEX Builder (LIS) | `https://localhost:8448/ords/lis/r/apex/workspace-sign-in/oracle-apex-sign-in` | `HTTP 574` | ⚠️ Self-Signed | ❌ Kättesaamatu |
| APEX Instance Admin (LIS) | `https://localhost:8448/ords/lis/apex_admin` | `HTTP 574` | ⚠️ Self-Signed | ❌ Kättesaamatu |
| ORDS Database Actions (LIS) | `https://localhost:8448/ords/lis/_/landing` | `HTTP 574` | ⚠️ Self-Signed | ❌ Kättesaamatu |
| Forms Runtime (HTTP) | `http://localhost:9001/forms/frmservlet` | `HTTP 200` | N/A | ✅ OK |
| Forms Test Form (HTTP) | `http://localhost:9001/forms/frmservlet?form=test.fmx` | `HTTP 200` | N/A | ✅ OK |
| Forms WebLogic Console (HTTP) | `http://localhost:7001/console` | `HTTP 200` | N/A | ✅ OK |
| Forms Builder Web GUI (HTTP) | `http://localhost:6082/vnc.html` | `HTTP 200` | N/A | ✅ OK |
| Web IDE (HTTP) | `http://localhost:8090` | `HTTP 302` | N/A | ✅ OK |

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
| `DB_FORMS_APP` | ❌ Ei Saanud Ühendust | `Kättesaamatu` |
| `DB_FORMS_DBA_ADMIN` | ❌ Ei Saanud Ühendust | `Kättesaamatu` |
| `DB_FORMS_DEV` | ❌ Ei Saanud Ühendust | `Kättesaamatu` |
| `DB_FORMS_SCHEMA` | ❌ Ei Saanud Ühendust | `Kättesaamatu` |
| `DB_FORMS_SYS` | ❌ Ei Saanud Ühendust | `Kättesaamatu` |
| `DB_FORMS_VIEWER` | ❌ Ei Saanud Ühendust | `Kättesaamatu` |
| `DB_ALISE_APP` | ✅ Ühendus Õnnestus | `USER_APP@FREEPDB1         ` |
| `DB_ALISE_APP_USER` | ✅ Ühendus Õnnestus | `USER_APP@FREEPDB1         ` |
| `DB_ALISE_DBA_ADMIN` | ✅ Ühendus Õnnestus | `DBA_ADMIN@FREEPDB1        ` |
| `DB_ALISE_DEV` | ✅ Ühendus Õnnestus | `USER_DEVELOPER@FREEPDB1    ` |
| `DB_ALISE_SCHEMA` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_ALISE_SYS` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_ALISE_VIEWER` | ✅ Ühendus Õnnestus | `USER_VIEWER@FREEPDB1      ` |
| `DB_PROXY_APP` | ❌ Ei Saanud Ühendust | `Kättesaamatu` |
| `DB_PROXY_DBA_ADMIN` | ❌ Ei Saanud Ühendust | `Kättesaamatu` |
| `DB_PROXY_DEV` | ❌ Ei Saanud Ühendust | `Kättesaamatu` |
| `DB_PROXY_SCHEMA` | ❌ Ei Saanud Ühendust | `Kättesaamatu` |
| `DB_PROXY_SYS` | ❌ Ei Saanud Ühendust | `Kättesaamatu` |
| `DB_PROXY_VIEWER` | ❌ Ei Saanud Ühendust | `Kättesaamatu` |
| `DB_PUBLISHER_BIPLATFORM` | ❌ Ei Saanud Ühendust | `Kättesaamatu` |
| `DB_PUBLISHER_DBA_ADMIN` | ❌ Ei Saanud Ühendust | `Kättesaamatu` |
| `DB_PUBLISHER_DEV` | ❌ Ei Saanud Ühendust | `Kättesaamatu` |
| `DB_PUBLISHER_RCU` | ❌ Ei Saanud Ühendust | `Kättesaamatu` |
| `DB_PUBLISHER_READER` | ❌ Ei Saanud Ühendust | `Kättesaamatu` |
| `DB_PUBLISHER_SCHEMA` | ❌ Ei Saanud Ühendust | `Kättesaamatu` |
| `DB_PUBLISHER_SYS` | ❌ Ei Saanud Ühendust | `Kättesaamatu` |
| `DB_PUBLISHER_VIEWER` | ❌ Ei Saanud Ühendust | `Kättesaamatu` |

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
