# 🧪 Dev-Hub Browser Blueprints E2E Testiraport

- **Aeg:** 2026-09-07 12:50:56 EEST
- **Testitud Blueprintide arv:** 12
- **Õnnestus:** 12
- **Ebaõnnestus:** 0
- **Kogukestus:** 26s
- **Tuumbaasi puutumatus:** ✅ Tagatud (Blueprint #0: `db-proxy` ja `app-ords` jäid alati aktiivseks)
- **Zero-Trust paroolihaldus:** ✅ Tagatud (Paroolid ainult protsessi mälus, mitte kunagi kettal)

## Tulemuste Koondtabel

| Blueprint | Nimi & Profiil | Kestus | Olek | Märkused |
| :---: | :--- | :---: | :---: | :--- |
| **#0** | 0-default-proxy-ords | 9s | ✅ **PASS** | URLs & Mälupõhine Login OK |
| **#1** | 1-standalone-alise-db | 3s | ✅ **PASS** | URLs & Mälupõhine Login OK |
| **#2** | 2-standalone-proxy-db | 7s | ✅ **PASS** | URLs & Mälupõhine Login OK |
| **#3** | 3-standalone-gvenzl-db | 2s | ✅ **PASS** | URLs & Mälupõhine Login OK |
| **#4** | 4-standalone-autonomous-db | 1s | ✅ **PASS** | URLs & Mälupõhine Login OK |
| **#5** | 5-standalone-publisher | 1s | ✅ **PASS** | URLs & Mälupõhine Login OK |
| **#6** | 6-standalone-forms | 0s | ✅ **PASS** | URLs & Mälupõhine Login OK |
| **#7** | 7-consolidated-forms-publisher | 2s | ✅ **PASS** | URLs & Mälupõhine Login OK |
| **#8** | 8-standalone-web-ide | 1s | ✅ **PASS** | URLs & Mälupõhine Login OK |
| **#9** | 9-standalone-publisher-designer | 0s | ✅ **PASS** | URLs & Mälupõhine Login OK |
| **#10** | 10-remote-ords | 0s | ✅ **PASS** | URLs & Mälupõhine Login OK |
| **#11** | 11-remote-publisher | 0s | ✅ **PASS** | URLs & Mälupõhine Login OK |

## 🧠 Ressursihaldus ja RAM Watchdog Sündmused

✅ Kõik blueprintid mahtusid süsteemi mällu ilma vanemate konteinerite sundpeatamiseta.

## 🛡️ Arhitektuursed Tagatised

1. **Tuumbaasi puutumatus (Core Base Invariant):** Blueprint #0 konteinereid ei peatatud kordagi, tagades Dev-Hub veebiliidese kättesaadavuse kogu testimise vältel.
2. **Parooli mälust kleepimine:** Autentimine toimus otse SEPS Walletist mällu loetud paroolidega, simuleerides täpselt kasutaja tegevust Dev Hubi 1-kliki lõikelaua nupuga.
3. **Katkematu jätkamine (Auto-Resume):** Mälu vabastamise järel jätkati testimist täpselt poolelijäänud blueprinti kohast.
