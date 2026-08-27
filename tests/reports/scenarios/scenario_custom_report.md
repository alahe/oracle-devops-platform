# Blueprinti custom Testiaruanne (2026-08-27 12:33:30)

- **Aeg ja Kuupäev:** 2026-08-27 12:33:30
- **Kogu Paigalduse Kestus:** 13m 20s
- **Blueprinti Fail:** `config/blueprints/.env.custom-*`

---

## 1. ⏱ Ajakulu ja Tervisekontroll (Duration & Health)
- **Tulemus:** ✅ Paigaldus ja tervisekontrollid läbitud 100% korrektselt.
- **Kestus kokku:** 13m 20s

---

## 2. 💻 Konteinerite Mälukasutus & CPU (RAM / CPU Metrics)

| Konteineri Nimi | CPU % | Mälukasutus / Limiit | RAM % |
| :--- | :--- | :--- | :--- |
| db-proxy | 22.28% | 532MB / 3.221GB | 16.51% |
| db-lis | 72.65% | 665.3MB / 3.221GB | 20.65% |
| app-ords | 30.20% | 554.2MB / 1.074GB | 51.62% |

---

## 3. 💾 Kettamaht (Podman Volumes & Storage)

| Voluumi Nimi | Kettamaht |
| :--- | :--- |
| oracle-free-db-in-prod_proxy_oradata | N/A |
| oracle-free-db-in-prod_apex_images_26_1 | N/A |
| oracle-free-db-in-prod_lis_oradata | N/A |

---

## 4. 🗄️ Aktiivsed Konteinerid ja Pordid (Active Containers)

| Konteineri Nimi | Staatus | Pordid |
| :--- | :--- | :--- |
| db-proxy | Up About a minute (healthy) | 127.0.0.1:1532->1521/tcp |
| db-lis | Up 7 minutes (healthy) | 127.0.0.1:1533->1521/tcp |
| app-ords | Up About a minute (starting) | 127.0.0.1:8088->8088/tcp, 127.0.0.1:8448->8448/tcp |

---

## 5. 🌐 Veebiteenuste URL Audit (URL Health Matrix)

| Veebiteenuse Nimi | Kontrollitud URL | HTTP Kood | TLS Usaldus | Staatus |
| :--- | :--- | :--- | :--- | :--- |
| ORDS Root HTTP | `http://localhost:8088/ords/` | `HTTP 302` | N/A | ✅ OK |
| ORDS Root HTTPS | `https://localhost:8448/ords/` | `HTTP 302` | ⚠️ Self-Signed | ✅ OK |
| ORDS Database Actions (Default) | `https://localhost:8448/ords/_/landing` | `HTTP 200` | ⚠️ Self-Signed | ✅ OK |
| APEX Builder (PROXY) | `https://localhost:8448/ords/proxy/r/apex/workspace-sign-in/oracle-apex-sign-in` | `HTTP 400` | ⚠️ Self-Signed | ✅ OK |
| APEX Instance Admin (PROXY) | `https://localhost:8448/ords/proxy/apex_admin` | `HTTP 200` | ⚠️ Self-Signed | ✅ OK |
| ORDS Database Actions (PROXY) | `https://localhost:8448/ords/proxy/_/landing` | `HTTP 200` | ⚠️ Self-Signed | ✅ OK |
| APEX Builder (LIS) | `https://localhost:8448/ords/lis/r/apex/workspace-sign-in/oracle-apex-sign-in` | `HTTP 400` | ⚠️ Self-Signed | ✅ OK |
| APEX Instance Admin (LIS) | `https://localhost:8448/ords/lis/apex_admin` | `HTTP 200` | ⚠️ Self-Signed | ✅ OK |
| ORDS Database Actions (LIS) | `https://localhost:8448/ords/lis/_/landing` | `HTTP 200` | ⚠️ Self-Signed | ✅ OK |

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
| `APEX_PROXY_SCHEMA` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_APEX_PROXY_SCHEMA` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_APEX_PROXY_SYS` | ✅ Ühendus Õnnestus | `SYS@FREE` |
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
| `DB_DBA_ADMIN` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_LIS_APP` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_LIS_SYS` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_PUBLISHER_READER` | ℹ️ Vahele Jäetud | `Publisher profiil pole aktiivne` |
| `DB_TEST_DEV` | ✅ Ühendus Õnnestus | `SYS@FREE` |
| `DB_TEST_VIEWER` | ✅ Ühendus Õnnestus | `SYS@FREE` |

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
