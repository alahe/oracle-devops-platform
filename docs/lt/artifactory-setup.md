[ 🇬🇧 English ](../artifactory-setup.md) | [ 🇪🇪 Eesti ](../et/artifactory-setup.md) | [ 🇫🇮 Suomi ](../fi/artifactory-setup.md) | [ 🇸🇪 Svenska ](../sv/artifactory-setup.md) | [ 🇱🇻 Latviešu ](../lv/artifactory-setup.md) | [ 🇱🇹 Lietuvių ](artifactory-setup.md)

# 🏢 Įmonės Artifactory Saugykla, Produktų Katalogas ir Zero-Trust Metaduomenys

Uždarose įmonių aplinkose platforma nukreipia binarinius paketus, pataisas ir momentines kopijas į **JFrog Artifactory**, **Harbor** arba **Nexus**.

---

## 🎯 1. Pagrindiniai Privalumai ir LAN Greitasis Atkūrimas

1. **🚀 ~15s LAN Greitasis Atkūrimas:** Momentinių kopijų atsisiuntimas vietiniame tinkle per kelias sekundes.
2. **📑 Lengva `.meta.json` Patikra:** Versijų suderinamumo patikra prieš atsisiuntimą.
3. **🔒 Zero-Trust Autentifikavimas:** JIT prieigos raktas iš **Azure Key Vault** arba **SEPS Wallet**.
4. **🛡️ 1 prie 1 Simetrija:** Identiška struktūra Artifactory ir vietiniame diske.

---

## 🚀 2. Universalus Publikavimo Įrankis (`./scripts/publish-to-artifactory.sh`)

```bash
./scripts/publish-to-artifactory.sh --product blueprints --blueprint 3
```
