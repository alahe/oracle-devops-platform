# Oracle Forms & Reports Modernizācijas un Pārejas uz Oracle APEX Rokasgrāmata

[ 🇬🇧 English ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/forms-to-apex-migration-guide.md) | [ 🇪🇪 Eesti ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/et/forms-to-apex-migration-guide.md) | [ 🇫🇮 Suomi ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/fi/forms-to-apex-migration-guide.md) | [ 🇸🇪 Svenska ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/sv/forms-to-apex-migration-guide.md) | [ 🇱🇻 Latviešu ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/lv/forms-to-apex-migration-guide.md) | [ 🇱🇹 Lietuvių ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/lt/forms-to-apex-migration-guide.md)

---

## 1. Kopsavilkums un Biznesa Pamatojums 2026. Gadā

Vai 2026. gadā joprojām izmantojat Oracle Forms & Reports? Galvenais iemesls pārejai uz Oracle APEX ir **IZMAKSAS, elastība un infrastruktūras vienkāršošana.**

### Oracle Forms Trūkumi
- ❌ **Sarežģīta Starpnodrošinājuma (Middleware) Struktūra:** Nepieciešami atsevišķi WebLogic serveri un RCU shēmas.
- ❌ **Augstas Uzturēšanas Izmaksas:** Liels operatīvās atmiņas patēriņš un lēna palaišana.
- ❌ **Klienta Ierobežojumi:** Atkarība no Java Web Start vai attālās darbvirsmas risinājumiem.

### Oracle APEX Priekšrocības
- ✅ **Nav Nepieciešams Papildu Middleware:** APEX darbojas tieši Oracle datubāzes kodolā ar ORDS.
- ✅ **Iekļauts Datubāzes Licencē:** Nav papildu licenču maksas.
- ✅ **100% PL/SQL Loģikas Pārtēriņa:** Esošā biznesa loģika tiek saglabāta bez pārrakstīšanas.
- ✅ **Mūsdienīgs Pielāgojams UX:** Universal Theme nodrošina pilnu atbalstu mobilajām un darbvirsmas ierīcēm.

---

## 2. Kāpēc APEX ir Pārāks Mūsdienu Ģeneratīvā AI Laikmetā

*(Balstoties uz Džastina Millera, Oracle, arhitektūras analīzi)*

Ģeneratīvā AI pasaulē pastāv divi veidi, kā izstrādāt lietotnes ar LLM:
1. **Tiešā Ģenerēšana (1. variants):** AI ģenerē tūkstošiem rindu nepastarpināta koda (React, Node, sesiju pārvaldība), radot kļūdas un nesaprotamus koda pārskatus.
2. **Netiešā Ģenerēšana (2. variants):** AI ģenerē tikai **10 rindiņas deklaratīva APEXlang (`.apx`) DSL koda**, kas norāda nolūku (*intent*). **Oracle APEX dzinējs** nodrošina drošību, transakcijas un sesiju pārvaldību.

> **Ieguvums:** 100x augstāka arhitektūras pareizība un 1000x labāka koda lasāmība cilvēkam.

---

## 3. Modulārā Monolīta Priekšrocības: Kā Izvairīties no Mikropakalpojumu Lamatām

*(Balstoties uz Antona Martinjuka arhitektūras analīzi)*

Modernizējot mantotās sistēmas, daudzas komandas priekšlaicīgi sadala kodu desmitos mikropakalpojumu:
- **Mikropakalpojumu trūkumi:** Sadalītās transakcijas (Saga), tīkla aizture katrā izsaukumā un datu sinhronizācijas problēmas.
- **Oracle APEX kā Modulārais Monolīts:**
  1. Vienota izvietojama vienība bez tīkla aiztures (in-memory SQL/PLSQL).
  2. Nacionālas ACID transakcijas un daudzmodeļu atbalsts (relācijas, JSON Duality, AI Vector).
  3. Ātra REST API atvēršana ar **ORDS AutoREST** pēc nepieciešamības.

---

## 4. Stratēģiskā Lēmumu Pieņemšanas Struktūra: APEX vs. Next.js vs. Hibrīdā Migrācija

*(Balstoties uz Marcio Ramo un Voiceha Bjelavska analīzi)*

Modernizējot lielas Forms sistēmas:
- **Pilnīga pārrakstīšana (Next.js/React):** Dārgs un riskants veids, kā "no jauna atklāt" 20 gadu PL/SQL biznesa loģiku. Saskarnes pārvietošana neatceļ atkarību no Oracle, bet rada papildu starpslāņa uzturēšanas slogu.
- **Oracle APEX (Nacionāla datubāzes vide):** Ātrākais un zemākā riska ceļš ar 100% tiešu PL/SQL pakešu atkārtotu izmantošanu.
- **Hibrīdā Stratēģija (Strangler Fig modelis):** Vispirms modernizējiet kritiskos moduļus uz APEX, kamēr Forms turpina darboties uz tās pašas datubāzes shēmas.

---

## 5. 5 Posmu Migrācijas Process

```bash
# 1. Konvertēt FMB bināros failus uz XML:
./scripts/forms/form-to-xml.sh forms_apps/orders.fmb

# 2. Izvilkt PL/SQL biznesa loģiku datubāzes pakotnēs:
./scripts/forms/extract-forms-plsql.sh forms_apps/orders.xml

# 3. Izveidot APEX migrācijas arhīvu:
./scripts/forms/export-forms-for-apex.sh

# 4. Importēt arhīvu APEX Application Migration Workshop vidē.
# 5. Pilnveidot lietotni ar AI un APEXlang DSL palīdzību.
```
