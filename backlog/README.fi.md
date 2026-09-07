[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📋 Oracle DevOps Platform — Kehitys- ja Tehtäväluettelo (Backlog)

Tämä hakemisto sisältää alustan modulaarisen **tehtäväjärjestelmän (Backlog)**, jossa arkkitehtuuripäivitykset, ominaisuudet ja tietoturvakomponentit dokumentoidaan Markdown-tiedostoina.

---

## 🧭 Rakenne ja Elinkaarisäännöt

```text
backlog/
├── README.md               # Säännöt ja tilamatriisi
├── template.md             # Vakiomalli uusille tehtäville
├── todo/                   # Suunnitteilla ja työn alla olevat tehtävät
└── done/                   # Toteutetut ja testatut ominaisuudet
```

### Työnkulku:
1. **Uusi tehtävä:** Kopioi `template.md` kansioon `todo/` nimellä `TASK-XXX-[nimi].md`.
2. **Aloitus:** Merkitse tilaksi `IN_PROGRESS`.
3. **Valmistuminen:** Siirrä tiedosto kansioon `done/` (`mv backlog/todo/TASK-XXX-*.md backlog/done/`).
