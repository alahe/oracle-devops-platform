# [TASK-005]: Ristplatvormne SSL Juursertifikaadi Automaatne Usaldamine (0-Admin)

**Staatus:** `DONE`  
**Prioriteet:** `HIGH`  
**Valdkond:** `Security`  
**Dokumentatsioon:** [scripts/certs/README.md](../../scripts/certs/README.md), [docs/turvalisus.md](../../docs/turvalisus.md)  

---

## 1. Probleemi Kirjeldus ja Kontekst
Brauser kuvab kohalike HTTPS teenuste avamisel "Not Secure" hoiatusi. Tavakasutajal puuduvad sageli administraatori või root (sudo) õigused masinas.

## 2. Eesmärk ja Oodatav Tulemus
Usaldada kohalik CA sertifikaat kasutaja isiklikus hoidlas (macOS `login.keychain-db`, Windows `Cert:\CurrentUser\Root`) ilma administraatori õigusteta.

## 3. Tehniline Teostus
- Skriptid `scripts/certs/trust-local-cert-mac.sh`, `scripts/certs/trust-local-cert.ps1`, `scripts/certs/trust-local-cert.cmd`.
- `scripts/internal/resolve-tls-mode.sh` ja `generate-local-certs.sh`.

## 4. Verifitseerimine
- Automaattest [`tests/test-tls-scenarios.sh`](../../tests/test-tls-scenarios.sh) (8/8 PASS).
