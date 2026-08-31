# Oracle Forms Rakenduste Kaust (Local Mounted Folder)

See kaust on automaatselt seotud Forms konteineri teekonnaga `/u01/oracle/forms_apps` (`rw` režiimis).

- **Kasutus:** Aseta oma `.fmb` või `.fmx` failid siia kausta.
- **Kompileerimine:** `./scripts/forms/compile-form.sh forms_apps/minuvorm.fmb`
- **Käivitamine brauseris:** `http://localhost:9001/forms/frmservlet?form=minuvorm.fmx`
