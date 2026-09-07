[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 🧩 VS code -laajennusten Välimuisti (`binaries/extensions/`)

Tämä hakemisto toimii **tason 1 offline-välimuistina** VS Coden `.vsix`-laajennuspaketeille.

---

## 4-tasoinen laajennusten ratkaisuhierarkia

```
1. 📁 binaries/extensions/*.vsix         ➔ Paikallinen offline-välimuisti (Korkein prioriteetti)
2. 📁 $HOME/.vscode/extensions/          ➔ Synkronoi työpöytä-VS Coden laajennukset
3. 🌐 download_url profiili-YAMLissa     ➔ Lataa Artifactory-peilistä
4. 🌐 code-server --install-extension    ➔ Kysyy marketplace-kauppapaikalta
```
