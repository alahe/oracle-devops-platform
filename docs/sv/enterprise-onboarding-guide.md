# Företagsonboarding och guide för registerspegling
[ 🇬🇧 English ](../enterprise-onboarding-guide.md) | [ 🇪🇪 Eesti ](../et/enterprise-onboarding-guide.md) | [ 🇫🇮 Suomi ](../fi/enterprise-onboarding-guide.md) | [ 🇸🇪 Svenska ](enterprise-onboarding-guide.md) | [ 🇱🇻 Latviešu ](../lv/enterprise-onboarding-guide.md) | [ 🇱🇹 Lietuvių ](../lt/enterprise-onboarding-guide.md)

---

## 1. Översikt och syfte
I företagsmiljöer körs utvecklingsarbetsstationer och servrar ofta i slutna nätverk utan direkt åtkomst till publika containerregister (`container-registry.oracle.com`, `docker.io`). Företagspolicy kräver att containeravbildningar hämtas via **interna Artifactory- eller Harbor-speglar**.

Denna guide beskriver:
1. Konfiguration i [`config/enterprise.yaml`](../../config/enterprise.yaml).
2. Användning av CLI-verktyget [`scripts/onboard-enterprise.sh`](../../scripts/onboard-enterprise.sh).
3. Explicit uppdatering av profil-YAML på disk (`--patch-profiles`).
4. Återställning till publika register (`--revert`).

---

## 2. Snabbkommandon

```bash
cp config/enterprise.yaml.example config/enterprise.yaml
./scripts/onboard-enterprise.sh --patch-profiles
./scripts/onboard-enterprise.sh --status
./scripts/onboard-enterprise.sh --revert
```
