Oracle Autonomous AI Database Free Container Image Documentation
Oracle Autonomous AI Database Free Container image supports 2 types of database workload types - Lakehouse and Transaction Processing similar to the Oracle Autonomous AI Database in Cloud.

Following key features are supported:

Oracle Rest Data Services (ORDS)
APEX
Database Actions
Mongo API
Oracle Estate Explorer (OEE)
The storage size is limited to 20 GB for each Database

Using this image
Database versions
From the released images, choose the database version and corresponding image to work with.

We use the following naming convention:

Database version	Latest image tag	Specific release image tag	Supported Arch
26ai	latest-26ai	26.2.4.2-26ai	linux/arm64 and linux/amd64
23ai	latest-23ai	25.9.3.2-23ai	linux/arm64 and linux/amd64
19c	latest	26.2.4.2	linux/amd64
> [!NOTE]
> ADBS-25.9.3.2-23ai was the last 23ai release version. We now publish only 26ai and 19c adb-free images.

> [!NOTE]
> Often, images will have an additional “important feature” tag alongside release version tags.
> For e.g. adb-free:select_ai_agent

Container CPU/memory requirements
Oracle Autonomous AI Database Free container needs 4 CPUs and 8 GiB memory

Install podman
Please refer the official documentation to install podman on Linux, Windows or Mac

Start podman machine on MacOS or Windows
Containers need the Linux kernel. Run following commands to start a podman virtual machine

podman machine init
podman machine set --cpus 4 --memory 8192
podman machine start
> [!NOTE]
> 26ai images are multi-arch i.e. images are natively built for ARM64 and AMD64 platforms.
> 19c image is natively built for linux/amd64 platform only. To run a 19c adb-free container on ARM machines you will need colima emulation
> Read FAQ for instructions on how to setup Colima VMs

Starting an ADB Free container
> Note: Although the instructions use podman, the image format is compliant with both Open Container Initiative (OCI) and Docker.
> ADB container works seamlessly with both OCI and Docker container runtimes. You can also use docker to start the container.

To start an Oracle Autonomous AI Database Free container for ATP workload, run the following command

podman run -d \
-p 1521:1522 \
-p 1522:1522 \
-p 8443:8443 \
-p 27017:27017 \
-e WORKLOAD_TYPE=ATP \
-e WALLET_PASSWORD=*** \
-e ADMIN_PASSWORD=*** \
--cap-add SYS_ADMIN \
--device /dev/fuse \
--name adb-free \
container-registry.oracle.com/database/adb-free:latest-26ai
> Note: Use container-registry.oracle.com/database/adb-free:latest for 19c

On first startup of the container:
User mandatorily has to change the admin passwords. Please specify the password using the environment variable
ADMIN_PASSWORD

Wallet is generated using the wallet password WALLET_PASSWORD

Following table explains the environment variables passed to the container

Environment variable	Description
WORKLOAD_TYPE	Can be either ATP for transaction processing or ADW for Lakehouse. Default value is ATP
DATABASE_NAME	Database name should contain only alphanumeric characters. if not provided, the Database will be called either MYATP or MYADW depending on the passed workload type
ADMIN_PASSWORD	Admin user password must be between 12 and 30 characters long and must include at least one uppercase letter, one lowercase letter, and one numeric. The password cannot contain username
WALLET_PASSWORD	Wallet password must have a minimum length of eight characters and contain alphabetic characters combined with numbers or special characters.
ENABLE_ARCHIVE_LOG	To enable archive logging in the database. Default value is True. To turn off archive logging set the value to False
> Note: For OFS mount, container should start with SYS_ADMIN capability. Also, virtual device /dev/fuse should be accessible

Ports
Note the following ports which are forwarded to the container process

Port	Description
1521	TLS
1522	mTLS
8443	HTTPS port for ORDS / APEX and Database Actions
27017	Mongo API
HTTP proxy
If you are behind a corporate proxy, there are 2 ways to configure the database
to use the proxy settings

Set the HTTP_PROXY database property. This is used by packages like DBMS_CLOUD
exec DBMS_CLOUD_CONTAINER_ADMIN.set_database_property('HTTP_PROXY', 'www-my-corp-proxy.com:80/');
Use UTL_HTTP.set_proxy to set proxy for HTTP requests sent using UTL_HTTP
exec UTL_HTTP.SET_PROXY('www-my-corp-proxy.com');
adb-cli
adb-cli can be used to perform database operations after container is up and running

To use adb-cli, you can define the following alias for convenience

alias adb-cli="podman exec <container_name> adb-cli"
Available commands
&gt;&gt; adb-cli --help

Usage: adb-cli [OPTIONS] COMMAND [ARGS]...

  ADB-S Command Line Interface (CLI) to perform container-runtime database
  operations

Options:
  -v, --version  Show the version and exit.
  --help         Show this message and exit.

Commands:
  add-database
  change-password
Add Database
You can add a database using the add-database command

adb-cli add-database --workload-type "ADW" --admin-password "Welcome_1234"
Change Password
To change password for Admin user, use the following command

adb-cli change-password --database-name "MYADW" --old-password "Welcome_1234" --new-password "Welcome_12345"
Migrating data across containers
Mount Volume
To persist data across container restarts and removals, you should mount a volume at /u01/data and follow the steps mentioned in the documentation to migrate PDB data across containers

podman run -d \
-p 1521:1522 \
-p 1522:1522 \
-p 8443:8443 \
-p 27017:27017 \
-e WORKLOAD_TYPE=ATP \
-e WALLET_PASSWORD=*** \
-e ADMIN_PASSWORD=*** \
--cap-add SYS_ADMIN \
--device /dev/fuse \
--name adb-free \
--volume adb_container_volume:/u01/data \
container-registry.oracle.com/database/adb-free:latest-26ai
Connecting to Oracle Autonomous AI Database Free container
ORDS/APEX/Database Actions
Container hostname is used to generate self-signed SSL certs to serve HTTPS traffic on port 8443. APEX and Database Actions can be accessed using the container host (or simply localhost)

Application	URL
APEX	https://localhost:8443/ords/apex
Database Actions	https://localhost:8443/ords/sql-developer
> Note: For additional databases plugged in using adb-cli add-database command, please use the URL formats https://localhost:8443/ords/{database_name}/apex and https://localhost:8443/ords/{database_name}/sql-developer to access APEX and Database Actions respectively.

Wallet Setup
In the container, TLS wallet is generated at location /u01/app/oracle/wallets/tls_wallet

Copy wallet to your host.

podman cp adb-free:/u01/app/oracle/wallets/tls_wallet /scratch/tls_wallet
In this example, wallet is copied to /scratch/tls_wallet folder

Point TNS_ADMIN environment variable to the wallet directory

export TNS_ADMIN=/scratch/tls_wallet
If you want to connect to a remote host where the ADB free container is running, replace localhost in $TNS_ADMIN/tnsnames.ora with the remote host FQDN

sed -i 's/localhost/my.host.com/g' $TNS_ADMIN/tnsnames.ora
Available TNS aliases
Similar to Autonomous AI Database in Cloud, use any one of the following aliases to connect to ADB free container.

MYATP TNS aliases
For mTLS use the following
- myatp_medium
- myatp_high
- myatp_low
- myatp_tp
- myatp_tpurgent

For TLS use the following

myatp_medium_tls
myatp_high_tls
myatp_low_tls
myatp_tp_tls
myatp_tpurgent_tls
MYADW TNS aliases
For mTLS use the following
- myadw_medium
- myadw_high
- myadw_low

For TLS use the following
- myadw_medium_tls
- myadw_high_tls
- myadw_low_tls

TNS alias mappings to their connect string can be found in$TNS_ADMIN/tnsnames.ora file.

TLS walletless connection
To connect without a wallet, you need to update your client’s truststore with the self-signed certificate generated at container start

Linux system truststore
Copy /u01/app/oracle/wallets/tls_wallet/adb_container.cert from container and update your system truststore

podman cp adb-free:/u01/app/oracle/wallets/tls_wallet/adb_container.cert adb_container.cert
sudo cp adb_container.cert /etc/pki/ca-trust/source/anchors
sudo update-ca-trust
MacOS system trustsore
For MacOS, please refer the support guide to add certificate to keychain

JDK truststore
For JDK truststore update, you can use keytool

Linux example:

sudo keytool -import -alias adb_container_certificate -keystore $JAVA_HOME/lib/security/cacerts -file adb_container.cert
MacOS example:

sudo keytool -import -alias adb_container_certificate -file adb_container.cert -keystore  /Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home/lib/security/cacerts
SQL Developer Desktop application
Copy the wallet from the container and zip it

podman cp adb-free:/u01/app/oracle/wallets/tls_wallet /scratch/tls_wallet

zip -j /scratch/tls_wallet.zip /scratch/tls_wallet/*
Once you zip the Wallet, open SQLDeveloper and follow the below steps:

Click on File -> New -> Database Connection

Enter username / password

From “Connection Type” dropdown choose “Cloud Wallet”

Under “Configuration file” browse path to your wallet.zip

Select Service from the dropdown

Click on Connect

SQL*Plus
In this example, we connect using the alias myatp_low

sqlplus admin/<myatp_admin_password>@myatp_low

SQL*Plus: Release 21.0.0.0.0 - Production on Wed Jul 26 22:38:27 2023
Version 21.9.0.0.0

Copyright (c) 1982, 2022, Oracle.  All rights reserved.

Last Successful login time: Wed Jul 26 2023 16:36:16 +00:00

Connected to:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.20.0.1.0

SQL&gt;
Python
Install the python-oracledb driver for Oracle Database

python3 -m pip install oracledb
import oracledb
conn = oracledb.connect(user="admin", password="<myadw_admin_password>", dsn="myadw_medium", config_dir="/scratch/tls_wallet", wallet_location="/scratch/tls_wallet", wallet_password="***")
cr = conn.cursor()
r = cr.execute("SELECT 1 FROM DUAL")
print(r.fetchall())

&gt;&gt; [(1,)]
Create an app user
Connect as Admin

sqlplus admin/<myatp_admin_password>@myatp_medium
Create user as shown below:

CREATE USER APP_USER IDENTIFIED BY "<my_app_user_password>" QUOTA UNLIMITED ON DATA;

-- ADD ROLES
GRANT CONNECT TO APP_USER;
GRANT CONSOLE_DEVELOPER TO APP_USER;
GRANT DWROLE TO APP_USER;
GRANT RESOURCE TO APP_USER;  


-- ENABLE REST
BEGIN
    ORDS.ENABLE_SCHEMA(
        p_enabled =&gt; TRUE,
        p_schema =&gt; 'APP_USER',
        p_url_mapping_type =&gt; 'BASE_PATH',
        p_url_mapping_pattern =&gt; 'app_user',
        p_auto_rest_auth=&gt; TRUE
    );
    commit;
END;
/

-- QUOTA
ALTER USER APP_USER QUOTA UNLIMITED ON DATA;
Oracle Estate Explorer (OEE)
Oracle Estate Explorer is a tool that enables customers to
programmatically evaluate groups of Oracle databases for migration readiness to Oracle’s Autonomous AI Database. The output from OEE
provides a high-level estate overview of the tested group of databases, ranks them according to their alignment with ADB pre-requisites and
delivers a graded relative effort of any remediation required.

The OEE APEX app is installed in the adb-free images and is available to use out-of-the-box

Following steps are required to launch the OEE app:

Login as Database admin and set a password for the MPACK_OEE user
ALTER USER MPACK_OEE IDENTIFIED BY <password>
Visit the APEX URL using https://localhost:8443/ords/apex

Login to the MPACK_OEE APEX workspace using the password set in Step 1

Change the MPACK_OEE’s APEX account password. A warning page will be displayed after changing the MPACK_OEE’s APEX account password, please ignore it and click on Application Builder to launch the OEE application.

On the application home page, click “Run Application” to open the OEE app in a new browser tab.

F.A.Q
How can I run 19c Oracle Autonomous AI Database Free container on ARM64 arch i.e. machines with M1/M2 chips ?
> [!IMPORTANT]
> 23ai images are multi-arch and natively built for both linux/arm64 and linux/amd64 CPU architectures

Use colima + docker to emulate x86_64 arch. Replace podman with docker in all commands.

How can I install colima and docker on machines with M1/M2 chips ?
brew install docker
brew install docker-compose
brew install colima
brew reinstall qemu
How can I start Colima x86_64 Virtual Machine with minimum memory/cpu requirements for 19c ?
> [!IMPORTANT]
> Running x86_64 arch containers can have issues translating instructions for ARM. We give higher memory to the VM to avoid such issues

colima start --cpu 4 --memory 10 --arch x86_64
How can I start Colima x86_64 Virtual Machine using Apple’s new virtualization framework - Rosetta for 19c ?
> [!IMPORTANT]
> Running x86_64 arch containers can have issues translating instructions for ARM. We give higher memory to the VM to avoid such issues

softwareupdate --install-rosetta
colima stop
colima delete
colima start --cpu 4 --memory 10 --arch x86_64 --vm-type vz --vz-rosetta

# Verify if Colima is using the new profile
docker context ls
colima status
How can I start podman VM on Mac with minimum memory/cpu requirements ?
podman machine init
podman machine set --cpus 4 --memory 8192
podman machine start
Contributing
This project welcomes contributions from the community. Before submitting a pull request, please review our contribution guide

Security
Please consult the security guide for our responsible security vulnerability disclosure process

License
Copyright (c) 2026 Oracle and/or its affiliates.

Released under the Universal Permissive License v1.0 as shown at
.

Short URL for Repo
https://container-registry.oracle.com/ords/ocr/ba/database/adb-free
Other Open Source Licenses
The container image you have selected and all of the software that it contains is licensed under the Oracle Free Use Terms and Conditions which is provided in the container image. Your use of the container is subject to the terms of Oracle Free Use Terms and Conditions license.
Pull Command for Latest
docker pull
container-registry.oracle.com/database/adb-free:latest
Search Tag Name
Tags
Download Mirror

Default
Tag	OS/Architecture	Size	Pull Command	Last Updated	Image ID
latest-26ai	linux/amd64	2.77 GB	docker pull container-registry.oracle.com/database/adb-free:latest-26ai	2 weeks ago	5ca062725019
26.7.4.1-26ai-amd64	linux/amd64	2.77 GB	docker pull container-registry.oracle.com/database/adb-free:26.7.4.1-26ai-amd64	2 weeks ago	5ca062725019
26.7.4.1-26ai	linux/amd64	2.77 GB	docker pull container-registry.oracle.com/database/adb-free:26.7.4.1-26ai	2 weeks ago	5ca062725019
latest	linux/amd64	2.1 GB	docker pull container-registry.oracle.com/database/adb-free:latest	2 weeks ago	ad7274f98109
26.7.4.1	linux/amd64	2.1 GB	docker pull container-registry.oracle.com/database/adb-free:26.7.4.1	2 weeks ago	ad7274f98109
latest-26ai	linux/arm64	2.66 GB	docker pull container-registry.oracle.com/database/adb-free:latest-26ai	2 weeks ago	189d5809b7a9
26.7.4.1-26ai-arm64	linux/arm64	2.66 GB	docker pull container-registry.oracle.com/database/adb-free:26.7.4.1-26ai-arm64	2 weeks ago	189d5809b7a9
26.7.4.1-26ai	linux/arm64	2.66 GB	docker pull container-registry.oracle.com/database/adb-free:26.7.4.1-26ai	2 weeks ago	189d5809b7a9
26.5.4.2-26ai-arm64	linux/arm64	2.62 GB	docker pull container-registry.oracle.com/database/adb-free:26.5.4.2-26ai-arm64	2 months ago	e5d25f8a7926
26.5.4.2-26ai	linux/arm64	2.62 GB	docker pull container-registry.oracle.com/database/adb-free:26.5.4.2-26ai	2 months ago	e5d25f8a7926
26.5.4.2-26ai-amd64	linux/amd64	2.77 GB	docker pull container-registry.oracle.com/database/adb-free:26.5.4.2-26ai-amd64	2 months ago	1e3f3433cdec
26.5.4.2-26ai	linux/amd64	2.77 GB	docker pull container-registry.oracle.com/database/adb-free:26.5.4.2-26ai	2 months ago	1e3f3433cdec
26.2.4.2	linux/amd64	2.01 GB	docker pull container-registry.oracle.com/database/adb-free:26.2.4.2	5 months ago	fb83e526fdf3
26.2.4.2-26ai-amd64	linux/amd64	2.68 GB	docker pull container-registry.oracle.com/database/adb-free:26.2.4.2-26ai-amd64	5 months ago	3b8cbb48ef89
26.2.4.2-26ai	linux/amd64	2.68 GB	docker pull container-registry.oracle.com/database/adb-free:26.2.4.2-26ai	5 months ago	3b8cbb48ef89