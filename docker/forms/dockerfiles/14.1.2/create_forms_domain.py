# -*- coding: utf-8 -*-
# ============================================================================
# WLST Script: Create and Configure Oracle Forms 14c Domain
# ============================================================================
import os
import sys

domain_dir = os.environ.get('DOMAIN_HOME', '/u01/oracle/user_projects/domains/forms_domain')
oracle_home = os.environ.get('ORACLE_HOME', '/u01/oracle')
admin_username = os.environ.get('ADMIN_USERNAME', 'weblogic')
admin_password = os.environ.get('ADMIN_PASSWORD', 'Welcome1')
admin_port = int(os.environ.get('FORMS_ADMIN_PORT', '7001'))
forms_http_port = int(os.environ.get('FORMS_HTTP_PORT', '9001'))
forms_https_port = int(os.environ.get('FORMS_HTTPS_PORT', '9002'))

print('[INFO] Creating Oracle Forms 14c WebLogic Domain in ' + domain_dir)

try:
    selectTemplate('Basic WebLogic Server Domain')
    loadTemplates()
except:
    wls_tpl = None
    for p in [oracle_home + '/wlserver/common/templates/wls/wls.jar',
              '/u01/oracle/wlserver/common/templates/wls/wls.jar',
              oracle_home + '/oracle_common/common/templates/wls/oracle.fmw_template.jar']:
        if os.path.isfile(p):
            wls_tpl = p
            break
    if wls_tpl:
        readTemplate(wls_tpl)
    else:
        selectTemplate('Basic WebLogic Server Domain')
        loadTemplates()

# Configure AdminServer
cd('/Security/base_domain/User/' + admin_username)
cmo.setPassword(admin_password)

cd('/Server/AdminServer')
cmo.setName('AdminServer')
cmo.setListenAddress('')
cmo.setListenPort(admin_port)

# Add Forms template if available
forms_template = oracle_home + '/forms/common/templates/wls/forms_template.jar'
if os.path.isfile(forms_template):
    print('[INFO] Applying Forms Template: ' + forms_template)
    addTemplate(forms_template)

# Create Managed Server WLS_FORMS
cd('/')
try:
    create('WLS_FORMS', 'Server')
except:
    pass

cd('/Server/WLS_FORMS')
cmo.setListenAddress('')
cmo.setListenPort(forms_http_port)

# Write domain to disk
setOption('OverwriteDomain', 'true')
writeDomain(domain_dir)
closeTemplate()

print('[SUCCESS] Oracle Forms 14c Domain successfully generated!')
exit()
