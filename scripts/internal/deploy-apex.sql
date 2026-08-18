-- ============================================================================
-- APEX Application Automated Deployment Script (IaC / GitOps)
-- Uses apex_application_install package to import APEX application
-- ============================================================================

   SET DEFINE OFF;
SET ECHO ON;
SET SERVEROUTPUT ON SIZE UNLIMITED;

pro    *** Setting up APEX Workspace Context ***
begin
   wwv_flow_api.set_security_group_id(p_security_group_id => apex_util.find_security_group_id(p_workspace => 'PROXY_WORKSPACE'
   ));
end;
/

pro    *** Configuring Automated Application Install Parameters ***
begin
   apex_application_install.set_workspace_id(p_workspace_id => apex_util.find_security_group_id(p_workspace => 'PROXY_WORKSPACE'
   ));
  
  -- Hardcode or override Application ID (e.g. App 100)
   apex_application_install.set_application_id(100);
   apex_application_install.set_schema('APEX_PROXY_SCHEMA');
   apex_application_install.generate_offset;
end;
/

pro    *** Installing APEX Proxy Application Source ***
-- If app SQL or JSON is exported, run the export script
@apex_app/f100.sql

pro    *** Configuring Azure Entra-ID OIDC Web Credentials in Runtime ***
begin
  -- Inject production Azure Entra-ID credentials dynamically from CI environment secrets
   apex_credential.set_persistent_credentials(
      p_credential_static_id => 'AZURE_ENTRA_ID_CRED',
      p_client_id            => '&1',
      p_client_secret        => '&2'
   );
   commit;
end;
/

pro    *** APEX Application Deployment Completed Successfully ***
EXIT;