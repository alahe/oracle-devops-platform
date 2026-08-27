# APEX Rakenduste Kaust (`binaries/apex_apps/`)

Siia kausta saavad arendajad ja CI/CD torud asetada paigaldatavad Oracle APEX rakenduste ekspordifailid.

## 📦 Toetatud Failiformaadid:
- Klassikalised SQL ekspordid: `f100.sql`, `f101.sql` jne.
- Uued APEXlang zip/pakendatud rakendused: `f100.apex`, `app_crm.apex` jne.

## ⚙️ Automaatne Paigaldus:
- Skript `scripts/internal/deploy-apex-apps.sh` (käivitatakse ka `setup-all.sh` sammus 8) otsib siit kaustast faile ja impordib need tähestikulises/numbrilises järjekorras aktiivsesse APEX keskkonda.
- Täpsem kasutusjuhend: [`docs/apex-apps-deployment.md`](../../docs/apex-apps-deployment.md).
