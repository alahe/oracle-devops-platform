# [TASK-011]: WebLogic REST API & Publisher HTTPS Reverse Proxy

**Staatus:** `DONE`  
**Prioriteet:** `MEDIUM`  
**Valdkond:** `Security`  

---

## 1. Probleemi Kirjeldus ja Kontekst
WebLogic AdminServer ja Publisher töötavad siseselt krüpteerimata HTTP pordil ning vajavad turvalist TLS 1.3 reverse proxyt.

## 2. Eesmärk ja Oodatav Tulemus
Nginx baasil TLS reverse proxy, mis vahendab turvaliselt HTTPS päringuid ja suunab HTTP pordid ümber HTTPS-ile.

## 3. Tehniline Teostus
- Loodud konfiguratsioon [`config/nginx/publisher-ssl-proxy.conf`](../../config/nginx/publisher-ssl-proxy.conf).

## 4. Verifitseerimine
- Kontrollitud HTTPS ühendust pordil `9503` (TLS 1.3).
