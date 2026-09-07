<!-- [ 🇬🇧 English ](../devhub-browser-testing-plan.md) | [ 🇪🇪 Eesti ](../et/devhub-browser-testing-plan.md) | [ 🇱🇹 Lietuvių ](devhub-browser-testing-plan.md) -->

# 🧪 Dev-Hub naršyklės planų E2E testavimo ir gyvavimo ciklo vadovas

Šis vadovas aprašo išsamų visapusišką testavimo procesą, skirtą paleisti, valdyti ir patvirtinti architektūros planus tiesiogiai per **Developer Hub naudotojo sąsają** (`https://localhost:8448/dev-hub` arba `http://localhost:8088/dev-hub`) ir jos Bridge API.

---

## 🎯 Architektūra ir tikslai

1. **Naršykle valdomas planų valdymas:**
   - Valdykite visus 12 architektūros planų (#0 iki #11) per Dev Hub žiniatinklio sąsają arba Dev Hub Bridge REST API (`http://localhost:8089/api/toggle`).
2. **Paslaugų URL patikrinimas:**
   - Tikrina tinklo ryšį (HTTP 200/301/302) visoms aktyvioms paslaugoms: APEX Workspace, APEX Admin, Database Actions, Analytics Publisher, Forms 14c ir Web IDE.
3. **Kredencialų gavimas atmintyje ir prisijungimo imitavimas:**
   - Griežtai laikomasi **5 taisyklės (Zero-Trust SEPS Wallet)**.
   - Slaptažodžiai nuskaitomi tiesiai į atmintį ir įvedami į žiniatinklio formas be įrašymo į diską.
4. **RAM stebėjimas ir senesnių konteinerių sustabdymas:**
   - Stebi laisvą operatyviąją atmintį (riba: 2500 MB).
   - **Bazinio branduolio apsauga:** Planas #0 (`db-proxy` prievadas 1532 ir `app-ords` prievadas 8088/8448) **NIEKADA NESUSTABDOMAS**.

---

## 🚀 Testų paketo vykdymas

### 1. Vykdymas terminale (CLI)

```bash
# Testuoti visus 12 planų iš eilės:
./tests/test-devhub-browser-blueprints.sh --all

# Testuoti pilną 3 žingsnių gyvavimo ciklą (Start -> Stop -> Fast-Start) per Dev-Hub:
./tests/test-devhub-browser-blueprints.sh --all --lifecycle --dry-run
./tests/test-devhub-browser-blueprints.sh -b 1 --lifecycle

# Specialus Dev-Hub pilno gyvavimo ciklo (planai 0-9) testavimo modulis:
./tests/test-devhub-lifecycle-full.sh --all --dry-run
./tests/test-devhub-lifecycle-full.sh -b 1
./tests/test-devhub-lifecycle-full.sh -b 0,1,8 --dry-run

# Testuoti vieną planą:
./tests/test-devhub-browser-blueprints.sh -b 0
./tests/test-devhub-browser-blueprints.sh -b 9

# Dry-run imitavimas:
./tests/test-devhub-browser-blueprints.sh --dry-run
```

### 2. 1 paspaudimo vykdymas per Developer Hub sąsają

1. Atidarykite Dev Hub: **`https://localhost:8448/dev-hub`**
2. Pereikite į skirtuką **"DevOps Console"** arba **"Testavimo centras"** (Skirtukas 5.5).
3. Spustelėkite **"Test DevHub Blueprints"** arba **"Dev-Hub planų 0-9 gyvavimo ciklo testas"**.
4. Stebėkite realaus laiko terminalo išvestį tiesiogiai naršyklėje!

---

## 📊 Ataskaitos ir rezultatai

- **Naršyklės planų ataskaita:** `tests/reports/devhub_browser_blueprints_test_report.md`
- **Naršyklės planų metrika (JSON):** `metrics/devhub_browser_blueprints_benchmarks.json`
- **Pilno gyvavimo ciklo ataskaita (planai 0-9):** `tests/reports/devhub_lifecycle_full_report.md`
- **Pilno gyvavimo ciklo metrika (JSON):** `metrics/devhub_lifecycle_full_benchmarks.json`
- **Pilnas žurnalo failas:** `install_logs/devhub_lifecycle_full_YYYYMMDD_HHMMSS.log`
