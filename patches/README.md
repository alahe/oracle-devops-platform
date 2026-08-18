# Oracle APEX Patches Directory (`./patches`)

Sellesse kataloogi saab panna Oracle APEXi paigalduspakettide (Bundle Patch / PSE / One-off Patch) `.zip` failid ja lahtipakitud paigaldusfailid.

## Kataloogi struktuur

```
patches/
├── README.md               # Käesolev juhend
└── <patch_id>.zip          # Näiteks p36000000_2610_Generic.zip
```

## APEXi Patchi Paigaldamise Juhend

1. Pane APEXi patchi `.zip` fail sellesse `./patches` kataloogi.
2. Lahtipaki `.zip` fail samasse kataloogi või käivita automaatne paigaldusskript:

```bash
./scripts/internal/apply-apex-patch.sh patches/<patch_filename>.zip
```

Skript teostab automaatselt järgmised sammud:
- Tuvastab dünaamiliselt profiilipõhise primaarse andmebaasikonteineri (nt `db-dev-full`).
- Kopeerib patchi paigaldusfailid konteinerisse ja käivitab `@catpatch.sql` / `@apxpatch.sql` andmebaasis `SYSDBA` õigustes.
- Uuendab automaatselt `apex_images` volume-is asuvad staatilised pildid (nt versioon 26.1.2) ja stiilid (sünkroniseerimine toimub ka juhul, kui SQL patch on andmebaasis juba varasemalt rakendatud).
- Taaskäivitab dünaamiliselt ORDS teenuse konteineri uute failide ja lahenduste rakendamiseks.
