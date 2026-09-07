# Tee analüüs ja koosta plaan: Konfiguratsioon ja elutsükkel

Meil on olnud väga palju probleeme konteinerite konfiga ja nendega seotud paroolidega. Me peaksime üle vaatama kogu konfiguratsiooni, et teha konfiguratsioon läbipaistvaks ja selgemini mõistetavaks ning kasutajale ja koodile lihtsamini hallatavaks. Võib-olla on kõik ok, aga analüüsime selle korra veel üle ja vaatame, kas saame midagi lihtsustada.

## Tuvastatud kitsaskohad ja küsimused

- Ka praegu on probleem: `./scripts/setup-all.sh -tb 41` ei vasta:
  - `Testing ORDS Database Actions (Default) [https://localhost:8448/ords/_/landing]... ❌ UNRESPONSIVE [HTTP 574] (Connection timed out / error)`
  - `Testing APEX Builder (PROXY) [https://localhost:8448/ords/proxy/r/apex/workspace-sign-in/oracle-apex-sign-in]... ❌ UNRESPONSIVE [HTTP 574] (Connection timed out / error)`
  - `Testing APEX Instance Admin (PROXY) [https://localhost:8448/ords/proxy/apex_admin]... ❌ UNRESPONSIVE [HTTP 574] (Connection timed out / error)`
  - `Testing ORDS Database Actions (PROXY) [https://localhost:8448/ords/proxy/_/landing]... ❌ UNRESPONSIVE [HTTP 574] (Connection timed out / error)`

---

## Konfiguratsiooni hierarhia analüüs

Täna peaks olema hierarhiline konfiguratsioon:

1. **Kõige kõrgemal tasemel on blueprint**, mida me oleme nimetanud `.env`:
   - Eelkonfigureeritud Blueprintid asuvad `config/blueprints/`
2. **Profiilid**, mis asuvad `config/profiles/`:
   - Seal on kataloogid: `database`, `ords`, `web-ide`.
   - Puudu oleks nagu `forms` ja `publisher`, aga kuna nad vajavad kindlasti andmebaasi, siis on nad lisatud andmebaaside kataloogi.
   - Samuti tuleb luua võimalus, et Publisher ja Forms installeeritakse ettevõtte Linuxi või Windowsi serverisse.
   - Tekib küsimus: ORDS, mis vajab samuti andmebaasi. ORDS kataloogis on viidatud Oracle'i enda konteinerregistrisse. Samuti peab saama ära määrata ettevõttesisese serveri, kuhu on plaanis installeerida või on installeeritud ORDS.
   - Lisaks tuleb arvestada, et me soovime salvestada image nii eraldi Formsi ja Publisheri jaoks kui ka ühise, kui nad asuvad ühes WebLogicu konteineris. Kuidas programm peab tuvastama, milline image mis blueprindile on juba olemas ja kuidas seda identifitseerida, et seda saaks kasutada (kiirendada taastamist)? Seda ka teiste kombinatsioonide puhul, mis meil täna on.
   - Automaatika: alati peale keskkonna seadmist tehakse kas snapshot või image. Kui selline on olemas (1. ketta peal või 2. ettevõtte artifactoris), siis tuleb seda kasutada; kui ei ole, siis luua kohalikule kettale. Selleks peab olema image üheselt identifitseeritav. Samuti peab olema võimalus ketta peal olev image kustutada või käsitsi sundida uuesti looma. Protsess peab olema kasutajale võimalikult mugav.


