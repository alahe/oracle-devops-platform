# [TASK-024]: WAF & OAuth2 / OIDC Entra-ID Lõiming REST API-dele

**Staatus:** `TODO`  
**Prioriteet:** `HIGH`  
**Valdkond:** `Security`  

---

## 1. Probleemi Kirjeldus ja Kontekst
ORDS REST teenused ja APEX rakendused vajavad kaitset väliste rünnakute vastu (SQL Injection, XSS) ning tsentraalset Azure Entra-ID OAuth2 token-autentimist.

## 2. Eesmärk ja Oodatav Tulemus
Nginx WAF / ModSecurity integreerimine ning automaatne ORDS REST OAuth2 kliendi registreerimine.

## 3. Tehniline Teostus
- Täiendatud Nginx konfiguratsioon ja ORDS REST turvareeglid.

## 4. Verifitseerimine
- REST API päringute testimine kehtiva ja kehtetu Bearer tokeniga.
