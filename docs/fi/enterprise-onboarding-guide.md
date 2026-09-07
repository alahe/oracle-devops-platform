# Yrityksen perehdytys ja rekisteripeilien asennusopas

[ 🇬🇧 English ](../enterprise-onboarding-guide.md) | [ 🇪🇪 Eesti ](../et/enterprise-onboarding-guide.md) | [ 🇫🇮 Suomi ](enterprise-onboarding-guide.md) | [ 🇸🇪 Svenska ](../sv/enterprise-onboarding-guide.md) | [ 🇱🇻 Latviešu ](../lv/enterprise-onboarding-guide.md) | [ 🇱🇹 Lietuvių ](../lt/enterprise-onboarding-guide.md)

---

## 1. Yleiskatsaus ja tarkoitus

Yritysympäristöissä kehittäjien työpisteet ja tuotantopalvelimet toimivat suljetuissa sisäverkoissa ilman suoraa pääsyä julkisiin konttirekistereihin (`container-registry.oracle.com`, `docker.io`, `ghcr.io`). Tietoturvakäytäntöjen mukaan konttikuvat on ladattava **sisäisestä Artifactory- tai Harbor-peilistä**, ja ulospäin suuntautuva liikenne ohjataan TLS-välityspalvelimen kautta.

Tämä opas neuvoo:
1. Miten yrityksen infrastruktuuri määritetään tiedostossa [`config/enterprise.yaml`](../../config/enterprise.yaml).
2. Miten käytetään työkalua [`scripts/onboard-enterprise.sh`](../../scripts/onboard-enterprise.sh).
3. Miten profiili-YAMLit muokataan suoraan levyllä (`--patch-profiles`).
4. Miten profiilit palautetaan alkuperäisiin julkisiin rekistereihin (`--revert`).
5. Miten välityspalvelimet ja varmenteet määritetään.

---

## 2. Yrityksen keskitetty konfiguraatio (`config/enterprise.yaml`)

```bash
cp config/enterprise.yaml.example config/enterprise.yaml
```

Profiilien muokkaus suoraan levyllä:
```bash
./scripts/onboard-enterprise.sh --patch-profiles
./scripts/onboard-enterprise.sh --status
./scripts/onboard-enterprise.sh --revert
```
