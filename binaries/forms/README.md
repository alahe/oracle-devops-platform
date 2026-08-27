# Oracle Forms 14c Paigaldusfailide Kaust (`binaries/forms/`)

Sellesse kausta talletatakse Oracle Forms 14c, WebLogic 14c ja nendega seotud paigalduspaketid (`TASK-029`).

## 📦 Oodatavad Failid:
- `V1055080-01.zip` / Forms 14c paigaldusarhiivid
- `fmw_14.1.2.0.0_wls.jar` / WebLogic 14c installerid
- JDK 21 / 17 RPM või tar.gz paketid

## ⚙️ Kuidas Töötab:
- Forms konteineri ehitamisel või kohalikul initsialiseerimisel otsitakse binaare esmalt siit kaustast, vältides Oracle e-Delivery korduvat allalaadimist.
