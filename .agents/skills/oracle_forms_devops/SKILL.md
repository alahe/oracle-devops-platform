---
name: oracle_forms_devops
description: Juhised Oracle Forms 14c (Fusion Middleware 14.1.2 / Forms Services) kohalikuks paigaldamiseks, profiilide juhtimiseks, RCU skeemide halduseks, testvormide deployks ja DevOps automatisatsiooniks.
---

# Oracle Forms 14c (14.1.2): Paigaldus, Testvormid & DevOps Automatisatsioon

See skill juhendab, kuidas kasutada **Oracle Forms 14c (Forms Services 14.1.2)** teenust meie profiilipõhises DevOps keskkonnas.

---

## 1. Arhitektuur ja Profiilid

Forms 14c on integreeritud meie andmebaasi profiilisüsteemi (`config/profiles/databases/db-forms-oracle.yaml` ja `db-forms-gvenzl.yaml`):

- **Forms Runtime:** `http://localhost:9001/forms/frmservlet`
- **Forms Testvorm:** `http://localhost:9001/forms/frmservlet?form=test.fmx`
- **Forms Builder Web GUI (HTML5 noVNC):** `http://localhost:6082/vnc.html`
- **WebLogic Admin:** `http://localhost:7001/console`
- **Andmebaas (db-forms):** Port `1534`, PDB `FREEPDB1`, RCU eesliide `FORMS_*`

---

## 2. Forms Builder 14c ja CLI Tööriistad

- **`./scripts/forms/launch-builder.sh [moodul.fmb]`**: Avab Forms Builder 14c veebibrauseris HTML5 noVNC liidesena pordil `6082` või lokaalselt X11 aknas.
- **`./scripts/forms/compile-form.sh <fail.fmb>`**: Kompileerib `.fmb`, `.mmb` või `.pll` binaarseks käivitusfailiks ilma GUI-ta.
- **`./scripts/forms/form-to-xml.sh <fail.fmb>`**: Kahesuunaline konverteerimine Forms binaaride ja XML vahel Git versionihalduseks.
- **`./scripts/forms/export-forms-for-apex.sh`**: Koostab 1-klikiga `apex_migration_bundle.zip` faili Oracle APEX Application Migration Workshopi jaoks.
- **`./scripts/forms/extract-forms-plsql.sh <fail.xml>`**: Eraldab vormide triggerid ja program unitid andmebaasi paketiks (`PKG_<VORM>_FORMS_LOGIC.sql`).

---

## 3. Ametlikud Forms 14.1.2 Paigaldusreeglid

1. **Inventory:** `/etc/oraInst.loc` määrab `inst_group=oracle` ja `inventory_loc=/u01/oracle/oraInventory`.
2. **Kaheetapiline Silent Paigaldus:**
   - Esmalt FMW Infrastructure 14.1.2 (`V1045135-01.zip`).
   - Seejärel Forms and Reports 14.1.2 (`V1045121-01.zip`) silent režiimis vastusefailiga `forms_install.file`.
3. **RCU 14c Repositooriumi Skeemid:**
   - Initsialiseeritakse `FORMS_STB`, `FORMS_OPSS`, `FORMS_IAU`, `FORMS_WLS` skeemid.
4. **Rakenduste Tarne:**
   - Rakenduste failid paigutatakse kausta `/u01/oracle/forms_apps/` ja seotakse konfiguratsioonis `formsweb.cfg`.
