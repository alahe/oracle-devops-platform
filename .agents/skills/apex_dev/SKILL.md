---
name: apex_dev_sso_troubleshooting
description: Juhised APEX arendajakontode loomiseks, paroolide taastamiseks ja Azure Entra-ID (SSO/OIDC) integreerimiseks APEX Builderiga.
---

# APEX Workspace Haldus, Arendajad ja SSO (Azure Entra-ID)

See skill kirjeldab parimaid praktikaid ja PL/SQL lahendusi APEX arendajate autentimiseks, kasutajate haldamiseks ning ühekordse sisselogimise (SSO / Azure Entra-ID) seadistamiseks nii lokaalses arenduses kui ka TEST/PROD keskkondades.

---

## 1. APEX Workspace Arendajate Haldus (PL/SQL)

Arenduskeskkonnas on soovitatav vältida ühise `ADMIN` konto kasutamist. Iga arendaja peaks omama isiklikku arendajakontot.

### Kasutaja loomine konkreetses tööruumis (Workspace)
Selleks, et luua arendajakonto ilma `INTERNAL` vaatesse sisenemata, tuleb esmalt tuvastada tööruumi ID ja see aktiivseks määrata:

```sql
DECLARE
  v_workspace_id NUMBER;
BEGIN
  -- 1. Leia tööruumi ID
  v_workspace_id := APEX_UTIL.find_security_group_id('PROXY_WORKSPACE');
  
  -- 2. Vali tööruum aktiivseks
  APEX_UTIL.set_security_group_id(v_workspace_id);
  
  -- 3. Loo kasutaja arendaja (DEVELOPER) õigustes
  APEX_UTIL.create_user(
      p_user_name                    => 'allan.lahe',
      p_email_address                => 'allan@company.com',
      p_web_password                 => 'ArendajaParool2026!',
      p_developer_privs              => 'CREATE:DATA_LOADER:EDIT:HELP:MONITOR:VARIABLE', -- Ilma ADMIN rollita
      p_change_password_on_first_use => 'N'
  );
  COMMIT;
END;
/
```

### Parooli lähtestamine (Reset Password)
Kui arendaja parool on lukus või kadunud, saab seda administraatorina lähtestada käsuga:

```sql
DECLARE
  v_workspace_id NUMBER;
BEGIN
  v_workspace_id := APEX_UTIL.find_security_group_id('PROXY_WORKSPACE');
  APEX_UTIL.set_security_group_id(v_workspace_id);
  
  APEX_UTIL.reset_password (
      p_user_name                    => 'allan.lahe',
      p_old_password                 => NULL, -- Ei nõua vana parooli
      p_new_password                 => 'UusTugevParool2026!',
      p_change_password_on_first_use => 'N'
  );
  COMMIT;
END;
/
```

---

## 2. APEX Builder SSO (Azure Entra-ID / OIDC)

Tootmiskeskkondades (TEST, UAT, PROD) on parimaks praktikaks siduda APEX Builder (tööruumidesse sisselogimine) ettevõtte keskse identiteedihalduriga (Azure Entra-ID / Microsoft AD).

### Seadistamise põhisammud:
1.  **Azure App Registration:** Registreeri Azure portaalis uus rakendus (App Registration).
    *   **Redirect URI:** Määra APEX-i tagasiside aadress: `https://<domeen>/ords/apex_authentication.callback`
2.  **Web Credentials:** Loo APEX-is (`Shared Components`) uus turvakonteiner, mis hoiab Azure-st saadud `Client ID` ja `Client Secret` väärtusi.
3.  **Development Environment Authentication Scheme:** 
    *   Logi sisse `INTERNAL` tööruumi -> **Manage Instance** -> **Security**.
    *   Vali autentimise tüübiks **Social Sign-In** (OpenID Connect).
    *   Määra Discovery URL: `https://login.microsoftonline.com/{tenant_id}/v2.0/.well-known/openid-configuration`

---

## 3. Lokaalne arendus ja SSO möödapääs (Throttling / Lockout bypass)

Kuna iga arendaja kohalik localhost port võib erineda, on keeruline registreerida kõiki kohalikke URI-sid ettevõtte Azure portaalis. Seetõttu kasutatakse lokaalses arenduses järgmist hübriid-lähenemist:

### 1. SSO möödapääs URL parameetriga
Kui lokaalses arenduses on SSO sisse lülitatud, kuid Azure ühendus pole kättesaadav (nt VPN on maas või arendaja töötab offline), saab APEX-i sisselogimisel SSO-st mööda minna, lisades sisselogimise aadressi lõppu parameetri `&fsp_sso_login_override=y`:
```text
http://localhost:8088/ords/f?p=4550:1:::&fsp_sso_login_override=y
```
See kuvab vaikimisi sisselogimise vormi, kus arendaja saab sisse logida oma lokaalse andmebaasi kasutajakontoga.

### 2. Autentimise lähtestamine andmebaasist (Emergency Fallback)
Kui SSO seadistus on vigane ja sa oled APEX Builderist välja lukustatud, saab autentimise lähtestada tagasi tavaliste APEX kontode peale otse andmebaasist (sysdba rollis):

```sql
ALTER SESSION SET CONTAINER = FREEPDB1;
BEGIN
    apex_instance_admin.set_parameter('APEX_BUILDER_AUTHENTICATION', 'APEX');
    COMMIT;
END;
/
```
