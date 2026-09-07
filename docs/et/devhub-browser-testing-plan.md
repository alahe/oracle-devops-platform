<!-- [ 🇬🇧 English ](../devhub-browser-testing-plan.md) | [ 🇪🇪 Eesti ](devhub-browser-testing-plan.md) -->

# 🧪 Dev-Hub brauseri blueprintide E2E testimise ja haldamise juhend

See juhend kirjeldab täielikku töövoogu arhitektuuri blueprintide käivitamiseks, haldamiseks ning teenustesse sisselogimise testimiseks otse **Developer Hub veebiliidese kaudu** (`https://localhost:8448/dev-hub` või `http://localhost:8088/dev-hub`).

---

## 🎯 Arhitektuur ja eesmärgid

1. **Brauseripõhine Blueprintide Haldus:**
   - Kõigi 12 arhitektuurse blueprinti (#0 kuni #11) juhtimine läbi Dev Hub veebiliidese või taustal töötava Dev Hub Bridge REST API (`http://localhost:8089/api/toggle`).
2. **Teenuste URL-ide Tervisekontroll:**
   - Kontrollib veebiühendust (HTTP 200/301/302) kõigi aktiivsete teenuste otspunktide vastu:
     - APEX Workspace (`/ords/<pool>/r/apex/workspace-sign-in/oracle-apex-sign-in`)
     - APEX Instance Admin (`/ords/<pool>/apex_admin`)
     - Database Actions / SQL Developer Web (`/ords/<pool>/user_developer/sign-in?r=_sdw`)
     - Analytics Publisher (`http://localhost:9502/xmlpserver`)
     - Forms 14c Runtime (`http://localhost:9001/forms/frmservlet?form=test.fmx`)
     - Forms noVNC Web GUI (`http://localhost:6082/vnc.html`)
     - VS Code Web IDE (`http://localhost:8090/?folder=/workspace`)
     - Template Designer Studio (`http://localhost:6083/`)
3. **Mälupõhine Parooli Lugemine ja Vormi Kleepimine (Zero-Trust):**
   - Järgib rangelt **Reeglit 5 (Zero-Trust SEPS Wallet)**.
   - Paroole ei kirjutata kettale ega saadeta lahtise URL parameetrina.
   - Parool loetakse SEPS Walletist otse mällu (`./scripts/get-password.sh <ALIAS> -p`) ja esitatakse veebivormi autentimisväljale, simuleerides täpselt arendaja tegevust Dev Hubi 1-kliki lõikelaua nupuga ja kleebituna (`Cmd+V`) parooli lahtrisse.
4. **RAM Watchdog ja Vanemate Konteinerite Deaktiveerimine:**
   - Jälgib masina ja Podmani vaba mälu (vaikimisi ohutuslävi: 2500 MB).
   - Kui vaba mälu langeb uue raske andmebaasi käivitamisel alla läve:
     - **Tuumbaasi puutumatus (Core Base Invariant):** Blueprint #0 (`db-proxy` pordil 1532 ja `app-ords` pordil 8448/8088) **EI PEATATA KUNAGI**. Dev Hub jääb kogu aeg avatuks!
     - Peatatakse vanemad mitte-kriitilised konteinerid (`db-alise`, `db-publisher`, `app-forms`, `web-ide-dev`, `app-publisher-designer`).
     - **Katkematu jätkamine (Auto-Resume):** Testimist jätkatakse koheselt täpselt poolelijäänud blueprinti kohast.

---

## 🚀 Testipaketi käivitamine

### 1. Käivitamine terminalist (CLI)

```bash
# Testi kõiki 12 blueprinti järjestikku (käivitus, URL-id ja veebivormi sisselogimine):
./tests/test-devhub-browser-blueprints.sh --all

# Testi täielikku 3-etapilist elutsüklit (käivitus -> seiskamine -> kiirkäivitus) läbi Dev Hubi:
./tests/test-devhub-browser-blueprints.sh --all --lifecycle --dry-run
./tests/test-devhub-browser-blueprints.sh -b 1 --lifecycle

# Spetsiaalne Dev-Hub täieliku elutsükli (blueprintid 0-9) testmootor:
./tests/test-devhub-lifecycle-full.sh --all --dry-run
./tests/test-devhub-lifecycle-full.sh -b 1
./tests/test-devhub-lifecycle-full.sh -b 0,1,8 --dry-run

# Testi üksikut blueprinti (nt Blueprint #0 Tuum või Blueprint #9 Designer):
./tests/test-devhub-browser-blueprints.sh -b 0
./tests/test-devhub-browser-blueprints.sh -b 9

# Dry-run režiim (valideerib blueprintid, URL-id ja Wallet aliased konteinereid käivitamata):
./tests/test-devhub-browser-blueprints.sh --dry-run

# Kohandatud RAM lävi (nt 3000 MB):
./tests/test-devhub-browser-blueprints.sh --all --min-ram 3000
```

### 2. 1-klikiga käivitamine Dev Hub veebiliidesest

1. Ava Dev Hub: **`https://localhost:8448/dev-hub`**
2. Vali sakk **"DevOps Console"** või **"Testimiskeskus"** (Tab 5.5).
3. Klõpsa nupule **"Test DevHub Blueprints"** (`test-devhub-blueprints`) või **"Dev-Hub blueprintide 0-9 elutsükli test"** (`test-devhub-lifecycle-dryrun`).
4. Jälgi reaalajas terminali väljundit otse brauseris!

---

## 📊 Raportid ja tulemused

Testitulemused ja mõõdikud salvestatakse automaatselt:
- **Brauseri blueprintide raport:** `tests/reports/devhub_browser_blueprints_test_report.md`
- **Brauseri blueprintide mõõdikud (JSON):** `metrics/devhub_browser_blueprints_benchmarks.json`
- **Täieliku elutsükli raport (blueprintid 0-9):** `tests/reports/devhub_lifecycle_full_report.md`
- **Täieliku elutsükli mõõdikud (JSON):** `metrics/devhub_lifecycle_full_benchmarks.json`
- **Täielik logifail:** `install_logs/devhub_lifecycle_full_YYYYMMDD_HHMMSS.log`
