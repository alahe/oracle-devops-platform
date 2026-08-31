# Oracle Forms & Reports Modernisointi ja Siirtyminen Oracle APEXiin

[ 🇬🇧 English ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/forms-to-apex-migration-guide.md) | [ 🇪🇪 Eesti ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/et/forms-to-apex-migration-guide.md) | [ 🇫🇮 Suomi ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/fi/forms-to-apex-migration-guide.md) | [ 🇸🇪 Svenska ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/sv/forms-to-apex-migration-guide.md) | [ 🇱🇻 Latviešu ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/lv/forms-to-apex-migration-guide.md) | [ 🇱🇹 Lietuvių ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/lt/forms-to-apex-migration-guide.md)

---

## 1. Johdon Yhteenveto & Liiketoimintaperusteet 2026

Käytätkö edelleen Oracle Forms & Reports -järjestelmiä vuonna 2026? Tärkein syy siirtyä Oracle APEXiin ei ole enää pelkkä teknologia — **se on KUSTANNUSTEHOKKUUS, ketteryys ja ylläpidon helppous.**

### Oracle Forms -ympäristön Haasteet
- ❌ **Raskas Väliohjelmisto:** Vaatii erilliset WebLogic Server -klusterit ja RCU-tietokantaskeemat.
- ❌ **Korkeat Infrastruktuurikustannukset:** Useita gigatavuja muistia per palvelin ja hitaat käynnistysajat.
- ❌ **Monimutkaiset Käyttöönotot:** Binääristen `.fmx`-tiedostojen kääntäminen ja versiointi.
- ❌ **Käyttöliittymän Rajoitteet:** Riippuvuus Java Web Startista tai työpöytäistunnoista.

### Oracle APEXin Edut
- ✅ **Ei Erillistä Väliohjelmistoa:** APEX suoritetaan suoraan Oracle-tietokannan ytimessä.
- ✅ **Sisältyy Tietokantalisenssiin:** Ei erillisiä lisenssikustannuksia.
- ✅ **100 % PL/SQL-Liiketoimintalogiikan Uudelleenkäyttö:** Olemassa olevia paketteja ja proseduureja ei tarvitse kirjoittaa uudelleen.
- ✅ **Moderni Responsiivinen UX:** Universal Theme tukee mobiililaitteita ja modernia verkkoteknologiaa.

---

## 2. Miksi APEX on Ylivoimainen Generatiivisen Tekoälyn (AI) Aikakaudella

*(Justin Millerin, Oracle, arkkitehtuurianalyysin pohjalta)*

Generatiivisessa tekoälyssä on kaksi tapaa rakentaa sovelluksia LLM-malleilla:

1. **Suora Generointi (Direct Generation - Valinta 1):** Pyydetään tekoälyä luomaan tuhansia rivejä suoraa koodia (React, Node, manuaalinen istuntohallinta). Tuloksena on valtava määrä hallusinaatioita, tietoturva-aukkoja ja lukukelvottomia koodikatselmointeja.
2. **Epäsuora Generointi (Indirect Generation - Valinta 2):** Pyydetään tekoälyä luomaan vain **10 riviä deklaratiivista APEXlang (`.apx`) DSL -koodia**, joka ilmaisee käyttäjän tarkoituksen (*intent*). Vakiintunut **Oracle APEX -suoritusmoottori** huolehtii istuntohallinnasta, tietoturvasta ja suorituskyvystä.

> **Tulos:** 100x parempi arkkitehtuurinen luotettavuus ja 1000x helpompi ihmisluettavuus koodikatselmoinneissa.

---

## 3. Modulaarisen Monoliitin Edut: Miksi Välttää Mikropalvelujen Monimutkaisuusloukku

*(Anton Martyniukin arkkitehtuurianalyysin pohjalta)*

Kun perinteisiä järjestelmiä modernisoidaan, monet tiimit jakavat sovelluksen ennenaikaisesti kymmeniin mikropalveluihin:
- **Mikropalvelujen haasteet:** Hajautetut transaktiot (Saga), verkkolatenssi jokaisessa kutsussa, tietojen synkronoinnin pettäminen ja viikkoja kestävä kehitysympäristön pystytys.
- **Oracle APEXin In-Database Modulaarinen Monoliitti:**
  1. Yhtenäinen käyttöönotettava kokonaisuus ilman verkkoveroja.
  2. Natiivit ACID-transaktiot ja monimallituki (relaatiot, JSON Duality, AI Vector).
  3. Nopea REST-rajapintojen avaaminen **ORDS AutoREST** -toiminnolla tarpeen mukaan ilman arkkitehtuurin uudelleenkirjoitusta.

---

## 4. Strateginen Päätöskehys: APEX vs. Next.js vs. Hybridimigraatio

*(Marcio Ramon ja Wojciech Bielawskin arkkitehtuurianalyysin pohjalta)*

Kun modernisoidaan satoja näyttöjä sisältävää Forms-kokonaisuutta:
- **Täysi uudelleenkirjoitus (Next.js/React):** Erittäin kallis ja riskialtis tapa "löytää uudelleen" 20 vuoden aikana PL/SQL-paketteihin kertyneet liiketoimintasäännöt. Pelkkä käyttöliittymän siirto ei poista Oracle-riippuvuutta, vaan lisää välikerroksen hallintataakkaa.
- **Oracle APEX (Natiivi tietokantasovellus):** Nopein ja pienimmän riskin polku, joka mahdollistaa PL/SQL-pakettien 100 % suoran taaskäytön.
- **Hybridistrategia (Kuristajakuvio / Strangler Fig):** Modernisoi kriittiset moduulit ensin APEXiin, samalla kun Forms toimii rinnalla saman tietokantamallin päällä.

---

## 5. 5-Vaiheinen Migraatioprosessi

```bash
# 1. Muunna FMB-binaarit XML-muotoon:
./scripts/forms/form-to-xml.sh forms_apps/orders.fmb

# 2. Eristä PL/SQL-liiketoimintalogiikka tietokantapaketiksi:
./scripts/forms/extract-forms-plsql.sh forms_apps/orders.xml

# 3. Luo APEX-migraatiopaketti:
./scripts/forms/export-forms-for-apex.sh

# 4. Tuo paketti APEX Application Migration Workshopiin ja generoi sovellus.
# 5. Viimeistele sovellus tekoälyn ja APEXlang DSL:n avulla.
```
