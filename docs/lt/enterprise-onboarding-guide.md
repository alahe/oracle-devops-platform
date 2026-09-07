# Įmonės konfigūravimas ir registrų veidrodžių diegimo vadovas
[ 🇬🇧 English ](../enterprise-onboarding-guide.md) | [ 🇪🇪 Eesti ](../et/enterprise-onboarding-guide.md) | [ 🇫🇮 Suomi ](../fi/enterprise-onboarding-guide.md) | [ 🇸🇪 Svenska ](../sv/enterprise-onboarding-guide.md) | [ 🇱🇻 Latviešu ](../lv/enterprise-onboarding-guide.md) | [ 🇱🇹 Lietuvių ](enterprise-onboarding-guide.md)

---

## 1. Apžvalga ir tikslas
Įmonių IT aplinkoje kūrėjų darbo vietos ir serveriai veikia uždaruose tinkluose be tiesioginės prieigos prie viešų konteinerių registrų. Pagal taisykles atvaizdai turi būti siunčiami per **vidinį Artifactory arba Harbor veidrodį**.

Šiame vadove paaiškinama:
1. Konfigūracija faile [`config/enterprise.yaml`](../../config/enterprise.yaml).
2. CLI įrankio [`scripts/onboard-enterprise.sh`](../../scripts/onboard-enterprise.sh) naudojimas.
3. Tiesioginis profilių YAML modifikavimas diske (`--patch-profiles`).
4. Atkūrimas į viešus registrus (`--revert`).

---

## 2. Greitosios komandos

```bash
cp config/enterprise.yaml.example config/enterprise.yaml
./scripts/onboard-enterprise.sh --patch-profiles
./scripts/onboard-enterprise.sh --status
./scripts/onboard-enterprise.sh --revert
```
