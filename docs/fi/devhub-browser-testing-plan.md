<!-- [ 🇬🇧 English ](../devhub-browser-testing-plan.md) | [ 🇪🇪 Eesti ](../et/devhub-browser-testing-plan.md) | [ 🇫🇮 Suomi ](devhub-browser-testing-plan.md) -->

# 🧪 Dev-Hub -selainmallien E2E-testaus ja elinkaariopas

Tämä opas kuvaa täydellisen kokonaisvaltaisen testauksen arkkitehtuurimallien käynnistämiseen, hallintaan ja validointiin suoraan **Developer Hubin käyttöliittymän** (`https://localhost:8448/dev-hub` tai `http://localhost:8088/dev-hub`) ja Bridge API:n kautta.

---

## 🎯 Arkkitehtuuri ja tavoitteet

1. **Selainpohjainen blueprinttien hallinta:**
   - Hallitse kaikkia 12 arkkitehtuurimallia (#0 - #11) Dev Hub -verkkoliittymän tai Dev Hub Bridge REST API:n (`http://localhost:8089/api/toggle`) kautta.
2. **Palvelu-URL-osoitteiden tarkistus:**
   - Testaa verkkoyhteydet (HTTP 200/301/302) kaikille aktiivisille palveluille: APEX Workspace, APEX Admin, Database Actions, Analytics Publisher, Forms 14c ja Web IDE.
3. **Muistipohjainen tunnistetietojen haku & kirjautumisen simulointi:**
   - Noudattaa ehdottomasti **Sääntöä 5 (Zero-Trust SEPS Wallet)**.
   - Salasanat haetaan suoraan muistiin (`get-password.sh`) ja syötetään verkkolomakkeisiin.
4. **RAM Watchdog ja vanhempien konttien deaktivointi:**
   - Valvoo vapaata muistia (oletuskynnys: 2500 MB).
   - **Perusytimen suojaus:** Blueprint #0 (`db-proxy` portti 1532 ja `app-ords` portti 8088/8448) **EI KOSKAAN PYSÄHDY**.

---

## 🚀 Testipaketin käynnistäminen

### 1. Käynnistäminen komentoriviltä (CLI)

```bash
# Testaa kaikki 12 blueprinttiä peräkkäin:
./tests/test-devhub-browser-blueprints.sh --all

# Testaa täysi 3-vaiheinen elinkaari (käynnistys -> pysäytys -> pikakäynnistys):
./tests/test-devhub-browser-blueprints.sh --all --lifecycle --dry-run
./tests/test-devhub-browser-blueprints.sh -b 1 --lifecycle

# Erillinen Dev-Hub täyden elinkaaren (blueprintit 0-9) testimoduuli:
./tests/test-devhub-lifecycle-full.sh --all --dry-run
./tests/test-devhub-lifecycle-full.sh -b 1
./tests/test-devhub-lifecycle-full.sh -b 0,1,8 --dry-run

# Testaa yksittäistä blueprinttiä:
./tests/test-devhub-browser-blueprints.sh -b 0
./tests/test-devhub-browser-blueprints.sh -b 9

# Dry-run -simulaatio:
./tests/test-devhub-browser-blueprints.sh --dry-run
```

### 2. 1-klikkauksella suoritus Dev Hub -verkkokonsolista

1. Avaa Dev Hub: **`https://localhost:8448/dev-hub`**
2. Siirry välilehdelle **"DevOps Console"** tai **"Testauskeskus"** (Tab 5.5).
3. Napsauta **"Test DevHub Blueprints"** tai **"Dev-Hub blueprinttien 0-9 elinkaaritesti"**.
4. Seuraa reaaliaikaista tulostetta suoraan selaimessa!

---

## 📊 Raportit ja tulokset

- **Selainmallien raportti:** `tests/reports/devhub_browser_blueprints_test_report.md`
- **Selainmallien mittarit (JSON):** `metrics/devhub_browser_blueprints_benchmarks.json`
- **Täyden elinkaaren raportti (blueprintit 0-9):** `tests/reports/devhub_lifecycle_full_report.md`
- **Täyden elinkaaren mittarit (JSON):** `metrics/devhub_lifecycle_full_benchmarks.json`
- **Täydellinen lokitiedosto:** `install_logs/devhub_lifecycle_full_YYYYMMDD_HHMMSS.log`
