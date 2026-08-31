# Modernisering och Migreringsguide: Från Oracle Forms & Reports till Oracle APEX

[ 🇬🇧 English ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/forms-to-apex-migration-guide.md) | [ 🇪🇪 Eesti ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/et/forms-to-apex-migration-guide.md) | [ 🇫🇮 Suomi ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/fi/forms-to-apex-migration-guide.md) | [ 🇸🇪 Svenska ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/sv/forms-to-apex-migration-guide.md) | [ 🇱🇻 Latviešu ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/lv/forms-to-apex-migration-guide.md) | [ 🇱🇹 Lietuvių ](file:///Users/allanlahe/Oracle/oracle-free-db-in-prod/docs/lt/forms-to-apex-migration-guide.md)

---

## 1. Sammanfattning & Affärsnytta 2026

Kör du fortfarande Oracle Forms & Reports under 2026? Den främsta anledningen till att företag moderniserar till Oracle APEX är **KOSTNAD, flexibilitet och minskat infrastrukturunderhåll.**

### Utmaningar med Oracle Forms
- ❌ **Tung Middleware:** Kräver dedikerade WebLogic Server-kluster och RCU-scheman.
- ❌ **Höga Infrastrukturkostnader:** Kräver stora mängder minne och har långsamma uppstartstider.
- ❌ **Klientberoenden:** Beroende av Java Web Start eller noVNC-skrivbordsbryggor.

### Fördelar med Oracle APEX
- ✅ **Ingen Separat Middleware:** Körs direkt i Oracle-databasmotorn med ORDS.
- ✅ **Ingen Extra Licenskostnad:** Ingår i Oracle Database-licensen.
- ✅ **100 % Återanvändning av PL/SQL:** Befintlig affärslogik och procedurer återanvänds utan omskrivning.
- ✅ **Modernt Responssivt UI:** Universal Theme ger fullt stöd för mobila enheter och moderna webbläsare.

---

## 2. Varför APEX är Överlägset i Dagens AI-Värld

*(Baserat på Justin Millers arkitekturanalys, Oracle)*

I dagens generativa AI-värld finns två sätt att bygga applikationer med LLM:
1. **Direkt Generering (Val 1):** AI genererar tusentals rader rå full-stack-kod (React, Node, manuell sessionshantering). Detta leder till hallucinationer och svårgranskad kod.
2. **Indirekt Generering (Val 2):** AI genererar endast **10 rader deklarativ APEXlang (`.apx`) DSL** som anger avsikten (*intent*). Den beprövade **Oracle APEX-motorn** hanterar säkerhet, sessioner och prestanda.

> **Resultat:** 100x högre arkitektonisk korrekthet och 1000x bättre läsbarhet för människor.

---

## 3. Fördelarna med en Modulär Monolit: Undvik Mikrotjänstfällan

*(Baserat på Anton Martyniuks arkitekturanalys)*

Vid modernisering av äldre system delar många team upp applikationen i dussintals mikrotjänster:
- **Mikrotjänsternas baksida:** Distribuerade transaktioner (Saga), nätverkslatens vid varje anrop, dataurspårning och komplex felsökning.
- **Oracle APEX som Modulär Monolit:**
  1. Enhetlig driftsättning utan nätverksfördröjning (in-memory SQL/PLSQL).
  2. Inbyggda ACID-transaktioner och multi-modell (relationer, JSON Duality, AI Vector).
  3. Direkt publicering av REST-API:er via **ORDS AutoREST** vid behov.

---

## 4. Strategiskt Beslutsramverk: APEX vs. Next.js vs. Hybridmigrering

*(Baserat på Marcio Ramos och Wojciech Bielawskis arkitekturanalys)*

Vid modernisering av stora Forms-miljöer:
- **Total omskrivning (Next.js/React):** Mycket dyrt och riskfyllt sätt att "återupptäcka" 20 års PL/SQL-affärsregler. Att bara flytta UI minskar inte Oracle-beroendet utan ökar komplexiteten i mellanskiktet.
- **Oracle APEX (Databasnära applikationer):** Snabbaste vägen med lägst risk som tillåter 100 % återanvändning av PL/SQL-paket.
- **Hybridstrategi (Strangler Fig):** Modernisera affärskritiska moduler till APEX först, medan Forms körs parallellt på samma databasschema.

---

## 5. 5-Stegs Migreringsprocess

```bash
# 1. Konvertera FMB-binärer till XML:
./scripts/forms/form-to-xml.sh forms_apps/orders.fmb

# 2. Extrahera PL/SQL-affärslogik till databasen:
./scripts/forms/extract-forms-plsql.sh forms_apps/orders.xml

# 3. Skapa APEX-migreringspaket:
./scripts/forms/export-forms-for-apex.sh

# 4. Importera paketet till APEX Application Migration Workshop.
# 5. Förfina applikationen med AI och APEXlang DSL.
```
