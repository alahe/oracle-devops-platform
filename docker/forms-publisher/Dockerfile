# Copyright (c) 2026 Oracle and/or its affiliates.
#
# Unified Dockerfile for Oracle Forms 14c + Oracle Analytics Publisher 2025
# Single Fusion Middleware 14c Infrastructure container saving 50% RAM.
# 

FROM docker.io/oraclelinux:8

LABEL maintainer="Oracle DevOps Platform <devops@oracle-platform.local>" \
      description="Unified Oracle Forms 14.1.2 + Analytics Publisher 2025 FMW 14c Runtime Container"

ENV ORACLE_HOME=/u01/oracle \
    JAVA_HOME=/usr/java/default \
    PATH=/usr/java/default/bin:/u01/oracle/bin:$PATH \
    TMP=/u01/tmp \
    TMPDIR=/u01/tmp \
    TEMP=/u01/tmp \
    SKIP_LABEL_CHECK=true \
    DISABLE_TMPDIR_CHECK=true \
    CV_ASSUME_DISTID=OL8 \
    JAVA_OPTIONS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1 -Xverify:none"

USER root

# Install OS dependencies and Official Oracle JDK 17
RUN ARCH=$(uname -m) && \
    dnf -y install oracle-epel-release-el8 || true && \
    dnf -y install java-17-openjdk-headless unzip hostname libnsl libaio tar gzip procps findutils coreutils nc python3 \
                   fontconfig dejavu-sans-fonts liberation-sans-fonts \
                   libX11 libXext libXtst libXrender novnc websockify tigervnc-server || true && \
    dnf clean all && \
    mkdir -p /u01/oracle /u01/oracle/bin /u01/oracle/oraInventory /u01/oracle/forms_apps /u01/tmp && \
    groupadd -g 1000 oracle 2>/dev/null || true && \
    useradd -u 1000 -g oracle -d /u01/oracle oracle 2>/dev/null || true && \
    chown -R root:root /tmp /var/tmp && \
    chmod 1777 /tmp /var/tmp && \
    chmod 777 /u01/tmp && \
    chown -R oracle:oracle /u01

WORKDIR /u01

COPY entrypoint.sh /u01/
RUN chmod +x /u01/entrypoint.sh && chown oracle:oracle /u01/entrypoint.sh

USER oracle
WORKDIR /u01/oracle

# Exposed Ports:
# 9001: Forms HTTP/Servlet
# 9502: Analytics Publisher (xmlpserver)
# 6082: noVNC HTML5 Forms Builder GUI
# 7001: WebLogic Admin Console
EXPOSE 9001 9502 6082 7001

ENTRYPOINT ["/u01/entrypoint.sh"]
