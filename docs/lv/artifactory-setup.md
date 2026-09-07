[ 🇬🇧 English ](../artifactory-setup.md) | [ 🇪🇪 Eesti ](../et/artifactory-setup.md) | [ 🇫🇮 Suomi ](../fi/artifactory-setup.md) | [ 🇸🇪 Svenska ](../sv/artifactory-setup.md) | [ 🇱🇻 Latviešu ](artifactory-setup.md) | [ 🇱🇹 Lietuvių ](../lt/artifactory-setup.md)

# 🏢 Uzņēmuma artifactory krātuve, produktu katalogs un zero-trust metadati

Ierobežotās uzņēmumu vidēs platforma novirza bināros failus, ielāpus un momentuzņēmumus uz **JFrog Artifactory**, **Harbor** vai **Nexus**.

---

## 🎯 1. Galvenās priekšrocības un LAN ātrā atjaunošana

1. **🚀 ~15s LAN Ātrā Atjaunošana:** Momentuzņēmumu lejupielāde lokālajā tīklā sekundēs.
2. **📑 Viegla `.meta.json` Pārbaude:** Versiju saderības pārbaude pirms lejupielādes.
3. **🔒 Zero-Trust Autentifikācija:** JIT marķieris no **Azure Key Vault** vai **SEPS Wallet**.
4. **🛡️ 1-pret-1 Symmetrija:** Identiska struktūra Artifactory un lokāli.

---

## 🚀 2. Universālais publicēšanas rīks (`./scripts/publish-to-artifactory.sh`)

```bash
./scripts/publish-to-artifactory.sh --product blueprints --blueprint 3
```
