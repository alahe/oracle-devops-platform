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
    JAVA_HOME=/usr/lib/jvm/java-17-openjdk \
    PATH=/usr/lib/jvm/java-17-openjdk/bin:/u01/oracle/bin:$PATH \
    DOMAIN_NAME="${BI_DOMAIN_NAME:-bi}" \
    DOMAINS_DIR=/u01/oracle/user_projects/domains \
    DOMAIN_HOME=/u01/oracle/user_projects/domains/${BI_DOMAIN_NAME:-bi}

USER root

# Install OS dependencies and OpenJDK 17
RUN dnf -y install java-17-openjdk-devel unzip hostname libnsl libaio tar gzip procps findutils && \
    dnf clean all && \
    mkdir -p /u01/oracle /u01/oracle/.inventory && \
    groupadd -g 1000 oracle && \
    useradd -u 1000 -g oracle -d /u01/oracle oracle && \
    chown -R oracle:oracle /u01

USER oracle
WORKDIR /u01

# Copy installer response files and archives
COPY --chown=oracle:oracle install.file oraInst.loc createAndStartDomain.sh wait_for_db.sh /u01/
COPY --chown=oracle:oracle *.zip /u01/

# Install FMW Infrastructure & Analytics Server
RUN set -e && \
    INFRA_ZIP=$(ls -1 /u01/V1045135-01.zip /u01/fmw*.zip 2>/dev/null | head -n 1 || true) && \
    OAS_ZIP=$(ls -1 /u01/V1055080-01.zip /u01/Oracle_Analytics_Server*.zip 2>/dev/null | head -n 1 || true) && \
    if [ -n "$INFRA_ZIP" ] && [ -f "$INFRA_ZIP" ]; then \
      echo "📦 Installing Fusion Middleware Infrastructure..." && \
      unzip -q "$INFRA_ZIP" -d /u01/infra_extract && \
      INFRA_JAR=$(find /u01/infra_extract -name "*.jar" | head -n 1) && \
      java -jar "$INFRA_JAR" -silent -responseFile /u01/install.file -invPtrLoc /u01/oraInst.loc -ignoreSysPrereqs -force -novalidation ORACLE_HOME="$ORACLE_HOME" && \
      rm -rf /u01/infra_extract "$INFRA_ZIP"; \
    fi && \
    if [ -n "$OAS_ZIP" ] && [ -f "$OAS_ZIP" ]; then \
      echo "📦 Installing Oracle Analytics Server / Publisher..." && \
      unzip -q "$OAS_ZIP" -d /u01/oas_extract && \
      OAS_JAR=$(find /u01/oas_extract -name "Oracle_Analytics_Server*.jar" | head -n 1) && \
      java -jar "$OAS_JAR" -silent -responseFile /u01/install.file -invPtrLoc /u01/oraInst.loc -ignoreSysPrereqs -force -novalidation ORACLE_HOME="$ORACLE_HOME" INSTALL_TYPE="Oracle Analytics" && \
      rm -rf /u01/oas_extract "$OAS_ZIP"; \
    fi && \
    chmod +x /u01/createAndStartDomain.sh /u01/wait_for_db.sh

WORKDIR $ORACLE_HOME
EXPOSE 9502 9503 9500-9999

CMD ["/u01/createAndStartDomain.sh"]
