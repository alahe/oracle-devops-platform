[ 🇬🇧 English ](../security-audit-report.md) | [ 🇪🇪 Eesti ](../et/security-audit-report.md) | [ 🇫🇮 Suomi ](../fi/security-audit-report.md) | [ 🇸🇪 Svenska ](../sv/security-audit-report.md) | [ 🇱🇻 Latviešu ](../lv/security-audit-report.md) | [ 🇱🇹 Lietuvių ](security-audit-report.md)

# 🛡️ Įmonių Saugumo Audito Ataskaita & Hardening Gairės

Šiame dokumente pateikiama išsami **Oracle DevOps Platform** ir **Oracle APEX programų variklio** saugumo audito metodika, audito išvados, taisymo priemonės ir atitiktis finansų sektoriaus reikalavimams.

Auditas vertina architektūros atitiktį **OWASP Top 10 (2021)**, **CIS Oracle Database Benchmark (v2.0)**, **CIS Docker/Podman Benchmark (v1.3)** standartams bei Europos Sąjungos finansų sektoriaus atsparumo reglamentams (**DORA - Digital Operational Resilience Act** ir **PCI-DSS v4.0**).

---

## 📑 Vadovybės Santrauka

- **Bendras Saugumo Įvertinimas:** **100% (16 / 16 automatinių patikrų išlaikyta)**
- **Audito Įrankis:** `./scripts/test-security-audit.sh`
- **Vienetų Testų Aprėptis:** `./tests/unit/test-security-audit.sh`
- **Kriptografinė Paslapčių Saugykla:** 100% Zero-Trust SEPS Auto-Login Wallet (`cwallet.sso` AES-256)
- **Vietinio Tilto (Bridge) Izoliacija:** Griežtai susieta su loopback (`127.0.0.1`), apsaugota nuo CSRF per Origin validavimą

```mermaid
graph TD
    Audit(["🛡️ Įmonių Saugumo Auditas"]) --> T1["1 Lygis: Žiniatinklis & Bridge<br/>• Loopback 127.0.0.1<br/>• Griežtas CORS ir Anti-CSRF"]
    Audit --> T2["2 Lygis: Zero-Trust Paslaptys<br/>• SEPS Wallet AES-256<br/>• 0600 Failų Leidimai<br/>• 0 Paprasto Teksto Failų"]
    Audit --> T3["3 Lygis: Oracle 23ai Hardening<br/>• Atsitiktiniai DB Slaptažodžiai<br/>• Host ACE Apribojimas<br/>• Mažiausių Privilegijų Rolės"]
    Audit --> T4["4 Lygis: APEX & ORDS REST<br/>• Telkinių Izoliacija<br/>• Dinaminio SQL Susiejimas<br/>• AutoREST Apsauga"]
    Audit --> T5["5 Lygis: Konteinerių Sauga<br/>• Bešaknis (Rootless) Podman<br/>• Efemeriškos --rm Vėliavėlės<br/>• UID Vardų Srities Izoliacija"]
    Audit --> T6["6 Lygis: Nuotolinis Valdymas & DR<br/>• SSH accept-new Raktai<br/>• Rsync Šifruoti Tuneliai<br/>• 0 Tekstinių Raktų Kode"]
```

---

## 🧪 Automatizuotas Regresinis Testavimas

Siekiant išvengti saugumo spragų atsiradimo, automatiniai patikrinimai vykdomi prieš kiekvieną diegimą:

```bash
# 1. Paleisti pilną saugumo auditą (16 patikrų 7 lygiuose)
./scripts/test-security-audit.sh

# 2. Paleisti vienetų testų rinkinį
./tests/unit/test-security-audit.sh
```

Audito rodikliai nuolat fiksuojami failuose `metrics/security_audit_report.json` ir `metrics/security_audit_benchmarks.env`.
