# Zero-Trust SEPS Wallet — Teostusülesanded ja Verifitseerimine (Implementation Tasks)

- **Domeen (SCS):** `wallet-security`
- **Viidatud Nõuded:** `docs/specs/wallet-security/requirements.md`
- **Viidatud Disain:** `docs/specs/wallet-security/design.md`
- **Metoodika:** Thomas Dohmke (Agentic Assembly Line) & Julian Wood (Tasks Traceability)

---

## 1. Ülesannete Jälgitavuse Maatriks (Traceability Matrix)

| Task ID | Nõue | Komponent / Fail | Verifitseerimise Käsk | Staatus |
| :--- | :--- | :--- | :--- | :--- |
| **TSK-SEC-01** | `[REQ-SEC-01]` | `scripts/internal/create-wallet.sh` | `./tests/unit/test-wallet-encryption.sh` | ✅ Valmis |
| **TSK-SEC-02** | `[REQ-SEC-02]` | `scripts/get-password.sh` | `./scripts/get-password.sh DB_DEV` | ✅ Valmis |
| **TSK-SEC-03** | `[REQ-SEC-03]` | `scripts/sqlcl.sh` / `wallet/` | `./scripts/check-wallet.sh` | ✅ Valmis |
| **TSK-SEC-04** | `[REQ-SEC-04]` | `scripts/internal/rotate-credentials.sh` | `./tests/unit/test-credential-rotation.sh` | ✅ Valmis |

---

## 2. Aatomülesannete Teostuse Ajalugu

- [x] **TSK-SEC-01:** SEPS auto-login rahakoti loomise automatiseerimine (`create-wallet.sh`), failiõiguste määramine `0600`.
- [x] **TSK-SEC-02:** Just-In-Time mälusisese volituste lugemise skripti `get-password.sh` realiseerimine `mkstore` abil ilma kettale kirjutamata.
- [x] **TSK-SEC-03:** Paroolivaba SQLcl ühenduse konfigureerimine ja ühenduse testimise skripti `check-wallet.sh` loomine.
- [x] **TSK-SEC-04:** Null-seisakuga paroolide roteerimise skripti `rotate-credentials.sh` loomine ja verifitseerimine.

---

## 3. Autonoomne Verifitseerimise Tsükkel (Ralph Loop Invariant)

Vastavalt Rule 19 reeglile teostatakse kõigi ülesannete valideerimine autonoomse Ralph Loop tsüklina:
1. **Käivita:** Käivita seotud komponendi test (`./scripts/check-wallet.sh` või unit test).
2. **Hinda:** Kui test ebaõnnestub, analüüsi ebaõnnestumise logi kontekstis.
3. **Paranda:** Vii koodis sisse parandus ilma inimsekkumist nõudmata.
4. **Verifitseeri:** Korda tsüklit kuni 100% testidest läbivad roheliselt (exit code 0).
5. **Väravad:** Kinnita tulemus läbi 5 Kvaliteedivärava (Turvalisus, Funktsionaalsus, Mitmekeelsus, Porditavus, Jõudlus).
