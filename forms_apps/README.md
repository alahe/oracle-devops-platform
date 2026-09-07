[ 🇬🇧 English ](README.md) | [ 🇪🇪 Eesti ](README.et.md) | [ 🇫🇮 Suomi ](README.fi.md) | [ 🇸🇪 Svenska ](README.sv.md) | [ 🇱🇻 Latviešu ](README.lv.md) | [ 🇱🇹 Lietuvių ](README.lt.md)

# 📐 Oracle Forms Applications Directory (`forms_apps/`)

This directory is automatically mounted into the Oracle Forms 14c container path `/u01/oracle/forms_apps` in read-write (`rw`) mode.

---

## 🚀 Usage

- **Placement:** Place your `.fmb` (binary source) or `.fmx` (compiled executable) form files here.
- **Headless Compilation:**
  ```bash
  ./scripts/forms/compile-form.sh forms_apps/myform.fmb
  ```
- **Browser Execution:**
  `http://localhost:9001/forms/frmservlet?form=myform.fmx`
