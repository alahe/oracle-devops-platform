# Copyright (c) 2025-2026 Oracle and/or its affiliates.
#
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
#
# ORACLE DOCKERFILES PROJECT
# --------------------------
# Dockerfile for Oracle Analytics Server 2026 (8.2 / Fusion Middleware 14c)
# 

FROM docker.io/oraclelinux:8

LABEL maintainer="Oracle DevOps Platform <allan.lahe@swedbank.ee>"

ENV ORACLE_HOME=/u01/oracle \
    JAVA_HOME=/usr/java/default \
    PATH=/usr/java/default/bin:/u01/oracle/bin:$PATH \
    DOMAIN_NAME="${BI_DOMAIN_NAME:-bi}" \
    DOMAINS_DIR=/u01/oracle/user_projects/domains \
    DOMAIN_HOME=/u01/oracle/user_projects/domains/${BI_DOMAIN_NAME:-bi} \
    SKIP_LABEL_CHECK=true \
    DISABLE_TMPDIR_CHECK=true \
    CV_ASSUME_DISTID=OL8

USER root

# Copy local Oracle JDK 17 RPM if present for offline installation
COPY jdk-17*.rpm /tmp/

# Install OS dependencies and Official Oracle JDK 17 (Supported by Oracle)
RUN JDK_RPM=$(ls -1 /tmp/jdk-17*.rpm 2>/dev/null | head -n 1 || true) && \
    if [ -n "$JDK_RPM" ] && [ -f "$JDK_RPM" ]; then \
      JDK_TARGET="$JDK_RPM"; \
    else \
      ARCH=$(uname -m) && \
      if [ "$ARCH" = "aarch64" ]; then \
        JDK_TARGET="https://download.oracle.com/java/17/archive/jdk-17.0.12_linux-aarch64_bin.rpm"; \
      else \
        JDK_TARGET="https://download.oracle.com/java/17/archive/jdk-17.0.12_linux-x64_bin.rpm"; \
      fi; \
    fi && \
    dnf -y install "$JDK_TARGET" unzip hostname libnsl libaio tar gzip procps findutils coreutils && \
    dnf clean all && \
    rm -f /tmp/jdk-17*.rpm && \
    mkdir -p /u01/oracle /u01/oracle/.inventory && \
    groupadd -g 1000 oracle && \
    useradd -u 1000 -g oracle -d /u01/oracle oracle && \
    chown -R root:root /tmp /var/tmp && \
    chmod 1777 /tmp /var/tmp && \
    chown -R oracle:oracle /u01

USER oracle
WORKDIR /u01

# Copy installer response files and archives
COPY --chown=oracle:oracle install.file oraInst.loc createAndStartDomain.sh wait_for_db.sh /u01/
COPY --chown=oracle:oracle *.zip /u01/

# Install FMW Infrastructure & Analytics Server using Official Oracle JDK 17
RUN set -e && \
    INFRA_ZIP=$(ls -1 /u01/V1045135-01.zip /u01/fmw*.zip 2>/dev/null | head -n 1 || true) && \
    OAS_ZIP=$(ls -1 /u01/V1055080-01.zip /u01/Oracle_Analytics_Server*.zip 2>/dev/null | head -n 1 || true) && \
    if [ -n "$INFRA_ZIP" ] && [ -f "$INFRA_ZIP" ]; then \
      echo "📦 Installing Fusion Middleware Infrastructure with Official Oracle JDK 17..." && \
      unzip -q "$INFRA_ZIP" -d /u01/infra_extract && \
      rm -f "$INFRA_ZIP" && \
      INFRA_JAR=$(find /u01/infra_extract -name "*.jar" | head -n 1) && \
      java -Xms512m -Xmx1024m -jar "$INFRA_JAR" -silent -responseFile /u01/install.file -invPtrLoc /u01/oraInst.loc -ignoreSysPrereqs -force -novalidation ORACLE_HOME="$ORACLE_HOME" INSTALL_TYPE="Fusion Middleware Infrastructure" && \
      rm -rf /u01/infra_extract; \
    fi && \
    if [ -n "$OAS_ZIP" ] && [ -f "$OAS_ZIP" ]; then \
      echo "📦 Installing Oracle Analytics Server / Publisher with Official Oracle JDK 17..." && \
      unzip -q "$OAS_ZIP" -d /u01/oas_extract && \
      rm -f "$OAS_ZIP" && \
      OAS_JAR=$(find /u01/oas_extract -name "Oracle_Analytics_Server*.jar" ! -name "*2.jar" | head -n 1) && \
      java -Xms512m -Xmx1024m -Dos.arch=amd64 -Doracle.installer.os_arch=x86_64 -jar "$OAS_JAR" -silent -responseFile /u01/install.file -invPtrLoc /u01/oraInst.loc -ignoreSysPrereqs -force -novalidation -J-Dos.arch=amd64 -J-Doracle.installer.os_arch=x86_64 ORACLE_HOME="$ORACLE_HOME" INSTALL_TYPE="Oracle Analytics" && \
      rm -rf /u01/oas_extract; \
    fi && \
    chmod +x /u01/createAndStartDomain.sh /u01/wait_for_db.sh

USER oracle

WORKDIR $ORACLE_HOME
EXPOSE 9502 9503 9500-9999

CMD ["/u01/createAndStartDomain.sh"]
