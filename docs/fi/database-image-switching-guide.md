[ 🇬🇧 English ](../database-image-switching-guide.md) | [ 🇪🇪 Eesti ](../et/database-image-switching-guide.md) | [ 🇫🇮 Suomi ](database-image-switching-guide.md) | [ 🇸🇪 Svenska ](../sv/database-image-switching-guide.md) | [ 🇱🇻 Latviešu ](../lv/database-image-switching-guide.md) | [ 🇱🇹 Lietuvių ](../lt/database-image-switching-guide.md)

# 🔄 Tietokantakonttikuvien vaihto ja monitoimittajaopas

Tämä opas selittää, kuinka vaihtaa Oracle 23ai -konttikuvia, testata yhteisö- vs. virallisia versioita, lukita sisäiset tietokantaliittymät ja säästää välimuistia.

## 🚀 Kuvan vaihto (Blueprint #7)
Testaa vaihtoehtoista Docker Hub -yhteisökuvaa:
```bash
./scripts/deploy-blueprint.sh 7
```
