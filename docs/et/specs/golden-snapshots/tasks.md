# Kuldsete hetktõmmiste katastroofitaastus — teostusülesanded (Implementation Tasks)

- **Domeen (SCS):** `golden-snapshots`
- **Viidatud Nõuded:** `docs/specs/golden-snapshots/requirements.md`
- **Viidatud Disain:** `docs/specs/golden-snapshots/design.md`
- **Metoodika:** Thomas Dohmke (Agentic Assembly Line) & Julian Wood (Tasks Traceability)

---

## 1. Ülesannete Jälgitavuse Maatriks (Traceability Matrix)

| Task ID | Nõue | Komponent / Fail | Verifitseerimise Käsk | Staatus |
| :--- | :--- | :--- | :--- | :--- |
| **TSK-SNAP-01** | `[REQ-SNAP-01]` | `scripts/snapshots/create-golden-snapshots.sh` | `./scripts/snapshots/create-golden-snapshots.sh --check` | ✅ Valmis |
| **TSK-SNAP-02** | `[REQ-SNAP-02]` | `scripts/snapshots/restore-golden-snapshots.sh` | `./scripts/setup-all.sh -s -y` | ✅ Valmis |
| **TSK-SNAP-03** | `[REQ-SNAP-03]` | `scripts/snapshots/clean-golden-snapshots.sh` | `./scripts/snapshots/clean-golden-snapshots.sh --dry-run` | ✅ Valmis |

---

## 2. Aatomülesannete Teostuse Ajalugu

- [x] **TSK-SNAP-01:** Kuldse tõmmise loomise skripti loomine koos tehingulise quiesce ja SHA-256 kontrollsummadega.
- [x] **TSK-SNAP-02:** FastStart taastamise skripti optimeerimine ~15-20s sihtmärgile.
- [x] **TSK-SNAP-03:** Vanade tõmmiste ja ajutiste kettaköidete turvalise puhastuse skript.

---

## 3. Autonoomne Verifitseerimise Tsükkel (Ralph Loop Invariant)

Vastavalt Rule 19 reeglile teostatakse kõigi ülesannete valideerimine autonoomse Ralph Loop tsüklina:
1. **Käivita:** Käivita seotud komponendi test või lokaalne CI.
2. **Hinda:** Kui test ebaõnnestub, analüüsi ebaõnnestumise logi kontekstis.
3. **Paranda:** Vii koodis sisse parandus ilma inimsekkumist nõudmata.
4. **Verifitseeri:** Korda tsüklit kuni 100% testidest läbivad roheliselt (exit code 0).
5. **Väravad:** Kinnita tulemus läbi 5 Kvaliteedivärava (Turvalisus, Funktsionaalsus, Mitmekeelsus, Porditavus, Jõudlus).
