<!-- [ 🇬🇧 English ](quick-login-guide.md) | [ 🇪🇪 Eesti ](et/quick-login-guide.md) | [ 🇸🇪 Svenska ](quick-login-guide.md) | [ 🇱🇻 Latviešu ](quick-login-guide.md) | [ 🇱🇹 Lietuvių ](quick-login-guide.md) -->

# 🚀 Quick Login & Zero-Friction Access Guide

This guide describes the fastest, most secure workflow to access all active web services, database tools, and management consoles in the Oracle DevOps Platform.

---

## ⚡ Fastest 2-Step Login Method (Clipboard Helper `-c`)

Instead of searching for or typing passwords on screen, copy passwords directly to your OS clipboard (`pbcopy` / `xclip` / `wl-copy` / `clip.exe`) without displaying plaintext credentials:

```bash
# 1. Copy password to clipboard in 1 second:
./scripts/get-password.sh <ALIAS> -c

# 2. Paste directly into the browser password field:
# Cmd+V (macOS) or Ctrl+V (Windows/Linux)
```

---

## 🌐 Quick Access Matrix

| Service / Portal | Direct Web URL (Auto-Prefilled) | Default User / Workspace | Password Command (Instant Copy) |
| :--- | :--- | :--- | :--- |
| **🛠️ APEX Builder** | [Open APEX Workspace (Prefilled)](https://localhost:8448/ords/proxy/r/apex/workspace-sign-in/oracle-apex-sign-in?f4550_p1_company=PROXY_WORKSPACE&f4550_p1_username=DEV) | Workspace: `PROXY_WORKSPACE`<br/>User: `DEV` *(Auto-prefilled)* | `./scripts/get-password.sh DB_PROXY_DEV -c` |
| **⚙️ APEX Instance Admin** | [Open APEX Admin (Prefilled)](https://localhost:8448/ords/proxy/r/apex/workspace-sign-in/administration-sign-in?p10_username=ADMIN) | Workspace: `INTERNAL`<br/>User: `ADMIN` *(Auto-prefilled)* | `./scripts/get-password.sh DB_PROXY_APEX_ADMIN -c` |
| **📊 Database Actions (SDW)** | [Open SQL Developer Web](https://localhost:8448/ords/proxy/user_developer/sign-in?r=_sdw) | Schema: `user_developer`<br/>User: `USER_DEVELOPER` | `./scripts/get-password.sh DB_PROXY_DEV -c` |
| **📑 Analytics Publisher** | [Open Analytics Publisher](http://localhost:9502/xmlpserver) | User: `weblogic` | `./scripts/get-password.sh DB_PUBLISHER_SYS -c` |
| **📐 Forms 14c Services** | [Open Forms Test Form](http://localhost:9001/forms/frmservlet?form=test.fmx) | Runtime / `test.fmx` | None required |
| **🎨 Forms Builder GUI** | [Open Forms Builder Web GUI](http://localhost:6082/vnc.html) | HTML5 noVNC Client | None required |
| **💻 VS Code Web IDE** | [Open Web IDE Workspace](http://localhost:8090/?folder=/workspace) | User: `developer` | None (Passwordless) |
| **⚙️ WebLogic Admin Console** | [Open WebLogic Console](http://localhost:7001/console) | User: `weblogic` | `./scripts/get-password.sh DB_FORMS_SYS -c` |

> [!TIP]
> **Database Actions (SQL Developer Web) Login:**
> Use the direct URL `https://localhost:8448/ords/<pool>/user_developer/sign-in?r=_sdw` which automatically routes to SQL Developer Web upon sign-in.

> [!TIP]
> **Developer Hub (`https://localhost:8448/dev-hub.html`):** The Command Center pealeht embeds this entire table with 1-click `[📋 Copy]` buttons and clickable TNS alias badges for every single database user and service.

---

## 💾 CLI Quick Access (Oracle SQLcl via SEPS Wallet)

To connect directly to the database without typing passwords in `ps aux`:

```bash
# Connect as Developer
sql /@DB_PROXY_DEV

# Connect as DBA Administrator
sql /@DB_PROXY_DBA_ADMIN

# Connect as SYSDBA
sql /@DB_PROXY_SYS as sysdba
```

## 🧪 Automated End-to-End Login Verification

To verify that credentials, workspaces, and web login endpoints function properly by simulating real form POST authentication:

```bash
./scripts/test-browser-login.sh
```

This validates:
1. **APEX Instance Admin:** Authenticates `ADMIN` in `INTERNAL` workspace.
2. **APEX Workspace Builder:** Authenticates `DEV` in active workspace.
3. **Database Actions:** Authenticates `USER_DEVELOPER` via HTTP session.

---

## 🔄 Rotating Passwords

To rotate passwords across Database, Podman Secrets, and SEPS Wallet seamlessly:

```bash
# Rotate developer password for specific database
./scripts/rotate-password.sh db-proxy dev

# Rotate all credentials in the entire environment
./scripts/rotate-password.sh all
```

---

## 💡 Troubleshooting & Session Cookie Isolation

> [!NOTE]
> **APEX Session Isolation (`INTERNAL` vs Workspace):**
> When testing both APEX Admin (`INTERNAL`) and APEX Builder (`<WORKSPACE>`) simultaneously on `localhost:8448`, open one in a regular tab and the other in an **Incognito / Private Window** (`Cmd+Shift+N`) to prevent browser session cookie collisions (`Your session has ended`).

