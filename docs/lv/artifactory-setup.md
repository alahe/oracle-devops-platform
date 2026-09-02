[ 🇬🇧 English ](../artifactory-setup.md) | [ 🇪🇪 Eesti ](../et/artifactory-setup.md) | [ 🇫🇮 Suomi ](../fi/artifactory-setup.md) | [ 🇸🇪 Svenska ](../sv/artifactory-setup.md) | [ 🇱🇻 Latviešu ](artifactory-setup.md) | [ 🇱🇹 Lietuvių ](../lt/artifactory-setup.md)

# 🏢 Uzņēmuma Artifactory Krātuve, Produktu Katalogs un Zero-Trust Metadati

Ierobežotās uzņēmumu vidēs platforma novirza bināros failus, ielāpus un momentuzņēmumus uz **JFrog Artifactory**, **Harbor** vai **Nexus**.

---

## 🎯 1. Galvenās Priekšrocības un LAN Ātrā Atjaunošana

1. **🚀 ~15s LAN Ātrā Atjaunošana:** Momentuzņēmumu lejupielāde lokālajā tīklā sekundēs.
2. **📑 Viegla `.meta.json` Pārbaude:** Versiju saderības pārbaude pirms lejupielādes.
3. **🔒 Zero-Trust Autentifikācija:** JIT marķieris no **Azure Key Vault** vai **SEPS Wallet**.
4. **🛡️ 1-pret-1 Symmetrija:** Identiska struktūra Artifactory un lokāli.

---

## 🚀 2. Universālais Publicēšanas Rīks (`./scripts/publish-to-artifactory.sh`)

```bash
./scripts/publish-to-artifactory.sh --product blueprints --blueprint 3
```
