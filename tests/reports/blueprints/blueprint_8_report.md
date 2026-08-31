# Stsenaariumi 8 Testiaruanne (2026-08-26 23:35:15)

- **Aeg ja Kuupäev:** 2026-08-26 23:35:15
- **Kogu Paigalduse Kestus:** 31s
- **Stsenaariumi Profiilifail:** `tests/scenarios/.env.8-*`

---

## 1. ⏱ Ajakulu ja Tervisekontroll (Duration & Health)
- **Tulemus:** ✅ Paigaldus ja tervisekontrollid läbitud 100% korrektselt.
- **Kestus kokku:** 31s

---

## 2. 💻 Konteinerite Mälukasutus & CPU (RAM / CPU Metrics)

| Konteineri Nimi | CPU % | Mälukasutus / Limiit | RAM % |
| :--- | :--- | :--- | :--- |
| db-alise | 76.90% | 657.5MB / 3.221GB | 20.41% |

---

## 3. 💾 Kettamaht (Podman Volumes & Storage)

| Voluumi Nimi | Kettamaht |
| :--- | :--- |
| oracle-free-db-in-prod_lis_oradata | N/A |
| oracle-free-db-in-prod_apex_images_26_1 | N/A |

---

## 4. 🗄️ Aktiivsed Konteinerid ja Pordid (Active Containers)

| Konteineri Nimi | Staatus | Pordid |
| :--- | :--- | :--- |
| db-alise | Up 33 seconds (healthy) | 127.0.0.1:1534->1521/tcp |

---

## 5. 🌐 Veebiteenuste URL Audit (URL Health Matrix)

Ei ole aktiivseid veebiteenuse URL-e

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
| `DB_INFRA_RCU` | ℹ️ Vahele Jäetud | `Infra profiil pole aktiivne` |
| `DB_INFRA_SYS` | ℹ️ Vahele Jäetud | `Infra profiil pole aktiivne` |

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
