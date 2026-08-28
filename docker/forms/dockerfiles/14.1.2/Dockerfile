# Copyright (c) 2026 Oracle and/or its affiliates.
#
# Dockerfile for Oracle Forms and Reports 14c (14.1.2 / Fusion Middleware 14c)
# 

FROM --platform=linux/amd64 docker.io/oraclelinux:8

LABEL maintainer="Oracle DevOps Platform <allan.lahe@swedbank.ee>"

ENV ORACLE_HOME=/u01/oracle \
    JAVA_HOME=/usr/java/default \
    PATH=/usr/java/default/bin:/u01/oracle/bin:$PATH \
    DOMAIN_NAME="${FORMS_DOMAIN_NAME:-forms_domain}" \
    DOMAINS_DIR=/u01/oracle/user_projects/domains \
    DOMAIN_HOME=/u01/oracle/user_projects/domains/${FORMS_DOMAIN_NAME:-forms_domain} \
    TMP=/u01/tmp \
    TMPDIR=/u01/tmp \
    TEMP=/u01/tmp \
    SKIP_LABEL_CHECK=true \
    DISABLE_TMPDIR_CHECK=true \
    CV_ASSUME_DISTID=OL8

USER root

# Copy local Oracle JDK 17 RPM if present
COPY jdk-17*.rpm /tmp/

# Install OS dependencies and Official Oracle JDK 17
RUN JDK_RPM=$(ls -1 /tmp/jdk-17*x64*.rpm /tmp/jdk-17*x86_64*.rpm 2>/dev/null | head -n 1 || true) && \
    if [ -z "$JDK_RPM" ]; then \
      JDK_RPM=$(ls -1 /tmp/jdk-17*.rpm 2>/dev/null | head -n 1 || true); \
    fi && \
    dnf -y install oracle-epel-release-el8 || true && \
    dnf -y install "$JDK_RPM" unzip hostname libnsl libaio tar gzip procps findutils coreutils nc python3 python3-pip \
                   xorg-x11-server-Xvfb motif fontconfig dejavu-sans-fonts liberation-sans-fonts \
                   libX11 libXext libXtst libXrender libXcomposite x11vnc openbox || true && \
    pip3 install websockify 2>/dev/null || true && \
    dnf clean all && \
    rm -f /tmp/jdk-17*.rpm && \
    mkdir -p /u01/oracle /u01/oracle/bin /u01/oracle/oraInventory /u01/oracle/forms_apps /u01/novnc /u01/tmp && \
    groupadd -g 1000 oracle && \
    useradd -u 1000 -g oracle -d /u01/oracle oracle && \
    chown -R root:root /tmp /var/tmp && \
    chmod 1777 /tmp /var/tmp && \
    chmod 777 /u01/tmp && \
    chown -R oracle:oracle /u01

WORKDIR /u01

# Copy installer response files and scripts
COPY install.file forms_install.file oraInst.loc createAndStartFormsDomain.sh create_forms_domain.py wait_for_db.sh start_builder_vnc.sh extract_forms_builder.py /u01/
COPY *.zip /u01/

# Install FMW Infrastructure & Oracle Forms 14.1.2 Builder and Runtime
RUN set -e && \
    python3 /u01/extract_forms_builder.py /u01 && \
    rm -f /u01/*.zip /u01/*.jar /u01/*.bin && \
    chmod +x /u01/oracle/bin/* /u01/createAndStartFormsDomain.sh /u01/wait_for_db.sh /u01/start_builder_vnc.sh /u01/extract_forms_builder.py 2>/dev/null || true && \
    chown -R oracle:oracle /u01

USER oracle
WORKDIR $ORACLE_HOME

EXPOSE 7001 9001 9002 6082

VOLUME ["/u01/oracle/forms_apps"]

CMD ["/u01/createAndStartFormsDomain.sh"]
