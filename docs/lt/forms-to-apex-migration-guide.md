# Oracle Forms ir Reports Modernizavimo bei Perkėlimo į Oracle APEX Vadovas

[ 🇬🇧 English ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/forms-to-apex-migration-guide.md) | [ 🇪🇪 Eesti ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/et/forms-to-apex-migration-guide.md) | [ 🇫🇮 Suomi ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/fi/forms-to-apex-migration-guide.md) | [ 🇸🇪 Svenska ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/sv/forms-to-apex-migration-guide.md) | [ 🇱🇻 Latviešu ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/lv/forms-to-apex-migration-guide.md) | [ 🇱🇹 Lietuvių ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/lt/forms-to-apex-migration-guide.md)

---

## 1. Santrauka ir Verslo Paskatos 2026 Metais

Ar 2026 metais vis dar naudojate Oracle Forms & Reports? Pagrindinė priežastis pereiti prie Oracle APEX yra **KAŠTŲ MAŽINIMAS, lankstumas ir infrastruktūros supaprastinimas.**

### Oracle Forms Iššūkiai
- ❌ **Sunki Vidurinioji Įranga (Middleware):** Reikalingi atskiri WebLogic serveriai ir RCU schemos.
- ❌ **Aukšti Infrastruktūros Kaštai:** Didelis operatyviosios atminties (RAM) poreikis ir lėtas startas.
- ❌ **Kliento Apribojimai:** Priklausomybė nuo Java Web Start ar nuotolinio darbalaukio.

### Oracle APEX Privalumai
- ✅ **Nėra Atskiros Vidurinės Įrangos:** APEX veikia tiesiogiai Oracle duomenų bazės branduolyje kartu su ORDS.
- ✅ **Įtraukta į Duomenų Bazės Licenciją:** Jokių papildomų licencijavimo mokesčių.
- ✅ **100 % PL/SQL Logikos Pakartotinis Panaudojimas:** Esamos verslo taisyklės ir paketai išsaugomi be perrašymo.
- ✅ **Šiuolaikinis Prisitaikantis UX:** Universal Theme užtikrina puikią vartotojo patirtį mobiliuosiuose ir stacionariuose įrenginiuose.

---

## 2. Kodėl APEX yra Pranašesnis Šiuolaikiniame Generatyvinio AI Pasaulyje

*(Parengta pagal Justin Miller, Oracle, architektūrinę analizę)*

Generatyvinio AI eroje egzistuoja du būdai kurti taikomąsias programas naudojant LLM:
1. **Tiesioginis Generavimas (1 pasirinkimas):** AI generuoja tūkstančius eilučių tiesioginio kodo (React, Node, sesijų valdymas), sukuriant daug klaidų ir nesuprantamų kodo peržiūrų.
2. **Netiesioginis Generavimas (2 pasirinkimas):** AI sugeneruoja vos **10 eilučių deklaratyvaus APEXlang (`.apx`) DSL kodo**, kuris nurodo ketinimą (*intent*). **Oracle APEX vykdymo variklis** užtikrina saugumą, sesijas ir stabilumą.

> **Privalumas:** 100x didesnis architektūrinis patikimumas ir 1000x lengvesnis kodo supratimas žmogui.

---

## 3. Modulinio Monolito Privalumai: Kaip Išvengti Mikropaslaugų Spąstų

*(Parengta pagal Anton Martyniuk architektūrinę analizę)*

Modernizuojant senąsias sistemas, daugelis komandų per anksti suskaido kodą į dešimtis mikropaslaugų:
- **Mikropaslaugų trūkumai:** Paskirstytos transakcijos (Saga), tinklo vėlavimas kiekviename kreipimesi ir duomenų nesuderinamumas.
- **Oracle APEX kaip Modulinis Monolitas:**
  1. Vientisas diegiamas vienetas be tinklo mokesčių (in-memory SQL/PLSQL).
  2. Nativios ACID transakcijos ir daugiamodelė parama (reliacinė, JSON Duality, AI Vector).
  3. Greitas REST API atvėrimas naudojant **ORDS AutoREST** be architektūros griovimo.

---

## 4. Strateginė Sprendimų Priėmimo Struktūra: APEX vs. Next.js vs. Hibridinė Migracija

*(Parengta pagal Marcio Ramo ir Wojciech Bielawski architektūrinę analizę)*

Modernizuojant dideles Forms sistemas:
- **Visiškas perrašymas (Next.js/React):** Labai brangus ir rizikingas būdas "iš naujo atrasti" per 20 metų PL/SQL paketuose sukauptą verslo logiką. Vien vartotojo sąsajos perkėlimas nepanaikina Oracle priklausomybės, o sukuria papildomą tarpinio sluoksnio palaikymo naštą.
- **Oracle APEX (Natyvi duomenų bazės aplinka):** Greičiausias ir mažiausios rizikos kelias su 100 % tiesioginiu PL/SQL paketų pakartotiniu panaudojimu.
- **Hibridinė Strategija (Strangler Fig modelis):** Pirmiausia modernizuokite kritinius modulius į APEX, kol Forms veikia lygiagrečiai toje pačioje duomenų bazės schemoje.

---

## 5. 5 Žingsnių Migracijos Procesas

```bash
# 1. Konvertuoti FMB failus į XML:
./scripts/forms/form-to-xml.sh forms_apps/orders.fmb

# 2. Išskirti PL/SQL verslo logiką į duomenų bazės paketus:
./scripts/forms/extract-forms-plsql.sh forms_apps/orders.xml

# 3. Sukurti APEX migracijos paketą:
./scripts/forms/export-forms-for-apex.sh

# 4. Importuoti paketą į APEX Application Migration Workshop.
# 5. Patobulinti taikomąją programą naudojant AI ir APEXlang DSL.
```
