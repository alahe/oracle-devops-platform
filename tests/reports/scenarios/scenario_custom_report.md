# Blueprinti custom Testiaruanne (2026-08-28 09:53:33)

- **Aeg ja Kuupäev:** 2026-08-28 09:53:33
- **Kogu Paigalduse Kestus:** 52s
- **Blueprinti Fail:** `config/blueprints/.env.custom-*`

---

## 1. ⏱ Ajakulu ja Tervisekontroll (Duration & Health)
- **Tulemus:** ✅ Paigaldus ja tervisekontrollid läbitud 100% korrektselt.
- **Kestus kokku:** 52s

---

## 2. 💻 Konteinerite Mälukasutus & CPU (RAM / CPU Metrics)

| Konteineri Nimi | CPU % | Mälukasutus / Limiit | RAM % |
| :--- | :--- | :--- | :--- |
| db-forms | 50.12% | 497.8MB / 3.221GB | 15.45% |
| app-forms | 14.75% | 103.3MB / 8.297GB | 1.25% |

---

## 3. 💾 Kettamaht (Podman Volumes & Storage)

| Voluumi Nimi | Kettamaht |
| :--- | :--- |
| oracle-free-db-in-prod_forms_oradata | N/A |
| oracle-free-db-in-prod_apex_images_26_1 | N/A |

---

## 4. 🗄️ Aktiivsed Konteinerid ja Pordid (Active Containers)

| Konteineri Nimi | Staatus | Pordid |
| :--- | :--- | :--- |
| db-forms | Up About a minute (healthy) | 127.0.0.1:1534->1521/tcp |
| app-forms | Up 14 seconds (starting) | 127.0.0.1:6082->6082/tcp, 127.0.0.1:7001->7001/tcp, 127.0.0.1:9001-9002->9001-9002/tcp |

---

## 5. 🌐 Veebiteenuste URL Audit (URL Health Matrix)

| Veebiteenuse Nimi | Kontrollitud URL | HTTP Kood | TLS Usaldus | Staatus |
| :--- | :--- | :--- | :--- | :--- |
| Forms Runtime (HTTP) | `http://localhost:9001/forms/frmservlet` | `HTTP 200` | N/A | ✅ OK |
| Forms Test Form (HTTP) | `http://localhost:9001/forms/frmservlet?form=test.fmx` | `HTTP 200` | N/A | ✅ OK |
| Forms WebLogic Console (HTTP) | `http://localhost:7001/console` | `HTTP 200` | N/A | ✅ OK |
| Forms Builder Web GUI (HTTP) | `http://localhost:6082/vnc.html` | `HTTP 200` | N/A | ✅ OK |

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
| `DB_FORMS_DBA_ADMIN` | ✅ Ühendus Õnnestus | `DBA_ADMIN@FREEPDB1        ` |
| `DB_FORMS_DEV` | ✅ Ühendus Õnnestus | `TEST_DEV@FREEPDB1         ` |
| `DB_FORMS_SCHEMA` | ✅ Ühendus Õnnestus | `APEX_PROXY_SCHEMA@FREEPDB1    ` |
| `DB_FORMS_SYS` | ✅ Ühendus Õnnestus | `SYS@FREEPDB1              ` |
| `DB_FORMS_VIEWER` | ✅ Ühendus Õnnestus | `TEST_VIEWER@FREEPDB1      ` |

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
