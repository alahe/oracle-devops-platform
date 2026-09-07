# Copyright (c) 2026 Oracle DevOps Platform
# Oracle Analytics Publisher Desktop (Template Builder for Word) & Pixel-Perfect Workstation
# Runs inside Podman with browser-based HTML5 noVNC GUI (Port 6083) and in-container Java XDO CLI engine.

FROM docker.io/library/ubuntu:22.04

LABEL maintainer="Oracle DevOps Platform <devops@oracle-platform.local>" \
      description="Oracle Analytics Publisher Desktop & MS Word Pixel-Perfect Designer Container"

ENV DEBIAN_FRONTEND=noninteractive \
    ORACLE_HOME=/u01/oracle \
    JAVA_HOME=/usr/lib/jvm/default-java \
    PATH=/usr/lib/jvm/default-java/bin:/u01/oracle/bin:$PATH \
    DISPLAY=:1 \
    VNC_PORT=5900 \
    NOVNC_PORT=6080 \
    WINEPREFIX=/u01/oracle/.wine \
    WINEDEBUG=-all \
    WINEARCH=win64 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

USER root

# 1. Install System, X11, VNC, noVNC, Fonts, Java, and Desktop dependencies
RUN set -eux && \
    ARCH="$(dpkg --print-architecture)" && \
    if [ "$ARCH" = "amd64" ]; then \
        dpkg --add-architecture i386 || true; \
    fi && \
    apt-get update && \
    COMMON_PKGS="ca-certificates curl wget gnupg2 software-properties-common \
        locales fontconfig fonts-dejavu fonts-liberation \
        xvfb x11vnc tigervnc-standalone-server tigervnc-common \
        novnc websockify \
        xfce4 xfce4-terminal dbus-x11 \
        default-jre-headless openjdk-17-jdk-headless \
        cabextract zenity unzip tar gzip procps net-tools nano \
        libxml2-utils xsltproc \
        libreoffice-writer libreoffice-calc libreoffice-java-common" && \
    if [ "$ARCH" = "amd64" ]; then \
        apt-get install -y --no-install-recommends $COMMON_PKGS wine64 wine32 winetricks || \
        apt-get install -y --no-install-recommends $COMMON_PKGS; \
    else \
        apt-get install -y --no-install-recommends $COMMON_PKGS; \
    fi && \
    ln -sfn /usr/lib/jvm/java-17-openjdk-* /usr/lib/jvm/default-java || true && \
    locale-gen en_US.UTF-8 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 2. Setup oracle developer user and directory tree
RUN mkdir -p /u01/oracle /u01/oracle/bin /u01/oracle/xdo/lib /u01/templates /u01/logs && \
    groupadd -g 1000 oracle 2>/dev/null || true && \
    useradd -u 1000 -g oracle -d /u01/oracle -s /bin/bash oracle 2>/dev/null || true && \
    chown -R oracle:oracle /u01 && \
    chmod -R 775 /u01

WORKDIR /u01

COPY entrypoint.sh /u01/
COPY render-template.sh /u01/oracle/bin/render-template.sh

RUN chmod +x /u01/entrypoint.sh /u01/oracle/bin/render-template.sh && \
    chown oracle:oracle /u01/entrypoint.sh /u01/oracle/bin/render-template.sh

USER oracle
WORKDIR /u01/oracle

# Exposed Ports:
# 6080: HTML5 noVNC web browser portal
# 5900: TigerVNC direct protocol
EXPOSE 6080 5900

ENTRYPOINT ["/u01/entrypoint.sh"]
