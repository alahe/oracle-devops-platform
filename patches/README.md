# Oracle APEX Patches Directory (`./patches`)

Sellesse kataloogi saab panna Oracle APEXi paigalduspakettide (Bundle Patch / PSE / One-off Patch) `.zip` failid ja lahtipakitud paigaldusfailid.

## Kataloogi struktuur

```
patches/
├── README.md                     # Käesolev juhend
└── p39179920_261_Generic.zip     # APEX 26.1.4 PSE Bundle Patch (Bug 39179920)
```

## APEXi Patchi Paigaldamise Juhend

1. Pane APEXi patchi `.zip` fail sellesse `./patches` kataloogi (nt `patches/p39179920_261_Generic.zip`).
2. Käivita automaatne paigaldusskript või lase sellel käivituda automaatselt `setup-all.sh` käigus:

```bash
./scripts/internal/apply-apex-patch.sh patches/p39179920_261_Generic.zip
```

Skript teostab automaatselt järgmised sammud:
- Tuvastab dünaamiliselt profiilipõhise primaarse andmebaasikonteineri (nt `db-alise`, `db-proxy`).
- Kopeerib patchi paigaldusfailid konteinerisse ja käivitab `@catpatch.sql` / `@apxpatch.sql` andmebaasis `SYSDBA` õigustes (tõstab APEX versiooni 26.1.0 -> 26.1.4).
- Uuendab automaatselt `apex_images` volume-is asuvad staatilised pildid ja stiilid (sünkroniseerimine toimub ka juhul, kui SQL patch on andmebaasis juba varasemalt rakendatud).
- Taaskäivitab dünaamiliselt ORDS teenuse konteineri uute failide ja lahenduste rakendamiseks.
