# Blueprinti 2 Testiaruanne (2026-08-31 00:33:31)

- **Aeg ja Kuupäev:** 2026-08-31 00:33:31
- **Kogu Paigalduse Kestus:** 2m 8s
- **Blueprinti Fail:** `config/blueprints/.env.2-*`

---

## 1. ⏱ Ajakulu ja Tervisekontroll (Duration & Health)
- **Tulemus:** ✅ Paigaldus ja tervisekontrollid läbitud 100% korrektselt.
- **Kestus kokku:** 2m 8s

---

## 2. 💻 Konteinerite Mälukasutus & CPU (RAM / CPU Metrics)

| Konteineri Nimi | CPU % | Mälukasutus / Limiit | RAM % |
| :--- | :--- | :--- | :--- |
| db-alise | 46.02% | 546MB / 3.221GB | 16.95% |
| app-ords | 10.74% | 961.1MB / 1.074GB | 89.51% |

---

## 3. 💾 Kettamaht (Podman Volumes & Storage)

| Voluumi Nimi | Kettamaht |
| :--- | :--- |
| oracle-free-db-in-prod_alise_oradata | N/A |
| oracle-free-db-in-prod_apex_images_26_1 | N/A |

---

## 4. 🗄️ Aktiivsed Konteinerid ja Pordid (Active Containers)

| Konteineri Nimi | Staatus | Pordid |
| :--- | :--- | :--- |
| db-alise | Up 5 minutes (healthy) | 127.0.0.1:1533->1521/tcp |
| app-ords | Up 3 minutes (starting) | 127.0.0.1:8088->8088/tcp, 127.0.0.1:8448->8448/tcp |

---

## 5. 🌐 Veebiteenuste URL Audit (URL Health Matrix)

| Veebiteenuse Nimi | Kontrollitud URL | HTTP Kood | TLS Usaldus | Staatus |
| :--- | :--- | :--- | :--- | :--- |
| ORDS Root HTTP | `http://localhost:8088/ords/` | `HTTP 574` | N/A | ❌ Kättesaamatu |
| Developer Hub (HTTPS) | `https://localhost:8448/dev-hub.html` | `HTTP 200` | ⚠️ Self-Signed | ✅ OK |
| ORDS Root HTTPS | `https://localhost:8448/ords/` | `HTTP 574` | ⚠️ Self-Signed | ❌ Kättesaamatu |
| ORDS Database Actions (Default) | `https://localhost:8448/ords/_/landing` | `HTTP 574` | ⚠️ Self-Signed | ❌ Kättesaamatu |
| APEX Builder (ALISE) | `https://localhost:8448/ords/alise/r/apex/workspace-sign-in/oracle-apex-sign-in` | `HTTP 574` | ⚠️ Self-Signed | ❌ Kättesaamatu |
| APEX Instance Admin (ALISE) | `https://localhost:8448/ords/alise/apex_admin` | `HTTP 574` | ⚠️ Self-Signed | ❌ Kättesaamatu |
| ORDS Database Actions (ALISE) | `https://localhost:8448/ords/alise/_/landing` | `HTTP 574` | ⚠️ Self-Signed | ❌ Kättesaamatu |

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
