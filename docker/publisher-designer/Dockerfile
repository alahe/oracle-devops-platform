# Copyright (c) 2026 Oracle DevOps Platform
# Oracle Analytics Publisher Desktop (Template Builder for Word) & Pixel-Perfect Workstation
# Runs inside Podman with browser-based HTML5 noVNC GUI (Port 6083) and in-container Java XDO CLI engine.
# Full Multi-Language (EN, ET, FI, SV, LV, LT) Support

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
    WINEARCH=win32 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    APP_LANG=et

USER root

# 1. Install System, X11, VNC, noVNC, Fonts, Java, Wine, LibreOffice, and 6-language packs
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
        cabextract zenity xdotool wmctrl xclip unzip tar gzip procps net-tools nano \
        libxml2-utils xsltproc inotify-tools poppler-utils python3-tk python3-uno \
        libreoffice-writer libreoffice-calc libreoffice-java-common evince \
        libreoffice-l10n-et libreoffice-l10n-fi libreoffice-l10n-sv libreoffice-l10n-lv libreoffice-l10n-lt \
        elementary-xfce-icon-theme tango-icon-theme" && \
    if [ "$ARCH" = "amd64" ]; then \
        apt-get install -y --no-install-recommends $COMMON_PKGS wine64 wine32 winetricks || \
        apt-get install -y --no-install-recommends $COMMON_PKGS; \
    else \
        apt-get install -y --no-install-recommends $COMMON_PKGS; \
    fi && \
    ln -sfn /usr/lib/jvm/java-17-openjdk-* /usr/lib/jvm/default-java || true && \
    locale-gen en_US.UTF-8 et_EE.UTF-8 fi_FI.UTF-8 sv_SE.UTF-8 lv_LV.UTF-8 lt_LT.UTF-8 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 2. Setup oracle developer user and directory tree
RUN mkdir -p /u01/oracle /u01/oracle/bin /u01/oracle/xdo/lib /u01/templates /u01/binaries /u01/logs && \
    groupadd -g 1000 oracle 2>/dev/null || true && \
    useradd -u 1000 -g oracle -d /u01/oracle -s /bin/bash oracle 2>/dev/null || true && \
    chown -R oracle:oracle /u01 && \
    chmod -R 775 /u01

WORKDIR /u01

COPY entrypoint.sh /u01/
COPY render-template.sh /u01/oracle/bin/render-template.sh
COPY install-word-bip.sh /u01/oracle/bin/install-word-bip.sh
COPY launch-word.sh /u01/oracle/bin/launch-word.sh
COPY launch-studio.sh /u01/oracle/bin/launch-studio.sh
COPY arrange-studio-windows.sh /u01/oracle/bin/arrange-studio-windows.sh
COPY export-accessible-pdf.py /u01/oracle/bin/export-accessible-pdf.py
COPY xml-field-inspector.py /u01/oracle/bin/xml-field-inspector.py
COPY xdo-preprocessor.py /u01/oracle/bin/xdo-preprocessor.py
COPY setup-libreoffice-profile.sh /u01/oracle/bin/setup-libreoffice-profile.sh
COPY xfce-applications.menu /u01/oracle/bin/xfce-applications.menu

RUN chmod +x /u01/entrypoint.sh \
             /u01/oracle/bin/*.sh \
             /u01/oracle/bin/*.py && \
    chown -R oracle:oracle /u01

USER oracle
WORKDIR /u01/oracle

# Exposed Ports:
# 6080: HTML5 noVNC web browser portal
# 5900: TigerVNC direct protocol
EXPOSE 6080 5900

ENTRYPOINT ["/u01/entrypoint.sh"]
