# 🤖 GitHub Copilot Juhend: Oracle BI Publisher Mallide Kujundamine VS Code'is

Käesolev juhend õpetab, kuidas kasutada **VS Code GitHub Copilotit** (`Chat` ja `Inline Edits` `Cmd+I` / `Ctrl+I`) Oracle Analytics Publisheri RTF aruandemallide (`templates/publisher/**/*.rtf`) kiireks ja täpseks muutmiseks.

---

## 1. Kuidas Copilot Töötab

Tänu failile [`.github/copilot-instructions.md`](../../.github/copilot-instructions.md) teab GitHub Copilot automaatselt:
1. Oracle BI Publisheri XDO süntaksit (`<?for-each:LINE?>`, `<?format-number(...)?>`, `<?if:...?>`).
2. Testandmete XML faili struktuuri: [`templates/publisher/samples/arve_test_andmed.xml`](samples/arve_test_andmed.xml).
3. RTF faili struktuuri reegleid.

---

## 2. Reaalajas Töövoog (Hot-Reload)

1. **Käivita terminalis taustavaatleja:**
   Ava VS Code integreeritud terminal ja käivita:
   ```bash
   ./scripts/publisher/watch-render-host.sh
   ```
2. **Ava mall redaktoris:**
   Ava [`templates/publisher/samples/arve_test_standard.rtf`](samples/arve_test_standard.rtf).
3. **Küsi Copilotilt muudatus:**
   Vajuta `Cmd+I` (või ava Copilot Chat `Cmd+Shift+I`) ja sisesta oma soov.
4. **Vajuta `Cmd+S` (Salvesta):**
   Taustavaatleja tuvastab salvestuse vähem kui 0.5 sekundiga, genereerib PDF-i ja värskendab ekraanil faili `valmis_test_arve.pdf`!

---

## 3. Valmis Prompt-Näidised Copilotile

Kopeerige ja kohandage järgmisi prompt-e Copilot Chatis:

### 💡 Näidis 1: Uue veeru lisamine toodete tabelisse
> *"Vaata arve_test_standard.rtf toodete tabelit. Lisa veeru 'Kogus' järele veerg 'Ühik' väljaga <?UNIT?> ja nihuta tabeli veerulaiuseid (cellx) vastavalt."*

### 💡 Näidis 2: Tingimuslik allahindluse kuvamine
> *"Lisa toodete tabelisse veerg 'Allahindlus %' ja kuva väärtust ainult siis, kui DISCOUNT_PCT > 0, kasutades tingimusplokki <?if:DISCOUNT_PCT > 0?>."*

### 💡 Näidis 3: Maksetingimuste ja panga rekvisiitide lisamine jalusesse
> *"Lisa arve jalusesse panga andmed väljadest <?SELLER/BANK_NAME?>, <?SELLER/IBAN?> ja <?SELLER/SWIFT_BIC?>, ning viitenumber <?INVOICE_METADATA/PAYMENT_REFERENCE?>."*

### 💡 Näidis 4: Käibemaksu eraldi ridade plokk
> *"Tee kokkuvõtte plokki selge käibemaksu rida: Vahesumma, Käibemaks (<?TOTALS/VAT_RATE?>) <?TOTALS/VAT_AMOUNT?> EUR ja Kokku tasuda <?TOTALS/GRAND_TOTAL?> EUR rasvases kirjas."*

### 💡 Näidis 5: Süntaksivigade parandamine
> *"Java XDO mootor andis veateate: 'Unclosed for-each loop'. Kontrolli arve_test_standard.rtf tabelit ja veendu, et igal <?for-each:LINE?> sildil on vastav <?end for-each?> lahtri lõpus."*

---

## 4. Oracle XDO Süntaksispikker

| Toiming | Oracle RTF / XDO Süntaks | Kirjeldus |
| :--- | :--- | :--- |
| **Välja väärtus** | `<?INVOICE_NUM?>` | Kuvab XML elemendi väärtuse |
| **Pesastatud väli** | `<?SELLER/COMPANY_NAME?>` | Kuvab alamelemendi väärtuse |
| **Korduv tsükkel** | `<?for-each:LINES/LINE?>` ... `<?end for-each?>` | Itereerib üle XML reamassiivi |
| **Arvuvorming** | `<?format-number(PRICE, '#,##0.00')?>` | Formaadib komakohad (nt 1,250.50) |
| **Kuupäevavorming** | `<?format-date(INVOICE_DATE, 'YYYY-MM-DD')?>` | Formaadib ISO kuupäeva |
| **Tingimuslik plokk**| `<?if:TOTAL > 0?>` ... `<?end if?>` | Kuvab ploki vaid tingimuse kehtimisel |
| **Summa arvutus** | `<?sum(LINE_TOTAL)?>` | Liidab kokku kõigi ridade summad |
