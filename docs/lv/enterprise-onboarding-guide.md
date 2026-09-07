# Uzņēmuma ievadīšana un reģistru spoguļu uzstādīšanas rokasgrāmata
[ 🇬🇧 English ](../enterprise-onboarding-guide.md) | [ 🇪🇪 Eesti ](../et/enterprise-onboarding-guide.md) | [ 🇫🇮 Suomi ](../fi/enterprise-onboarding-guide.md) | [ 🇸🇪 Svenska ](../sv/enterprise-onboarding-guide.md) | [ 🇱🇻 Latviešu ](enterprise-onboarding-guide.md) | [ 🇱🇹 Lietuvių ](../lt/enterprise-onboarding-guide.md)

---

## 1. Pārskats un mērķis
Uzņēmumu IT vidē darbstacijas un serveri darbojas slēgtos tīklos bez tiešas piekļuves publiskajiem konteineru reģistriem. Attēli ir jālejupielādē no **uzņēmuma iekšējā Artifactory vai Harbor spoguļa**.

Šī rokasgrāmata izskaidro:
1. Konfigurāciju [`config/enterprise.yaml`](../../config/enterprise.yaml).
2. CLI rīka [`scripts/onboard-enterprise.sh`](../../scripts/onboard-enterprise.sh) lietošanu.
3. Profilu YAML atjaunināšanu diskā (`--patch-profiles`).
4. Atgriešanos pie publiskajiem reģistriem (`--revert`).

---

## 2. Ātrās komandas
```bash
cp config/enterprise.yaml.example config/enterprise.yaml
./scripts/onboard-enterprise.sh --patch-profiles
./scripts/onboard-enterprise.sh --status
./scripts/onboard-enterprise.sh --revert
```
