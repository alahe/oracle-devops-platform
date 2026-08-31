# ============================================================================
# Web IDE Container (code-server + Oracle Developer Tools + CI/CD Tools)
# Enterprise Artifactory Mirror Registry Compatible
# ============================================================================
ARG ARTIFACTORY_REGISTRY=""
FROM ${ARTIFACTORY_REGISTRY:+$ARTIFACTORY_REGISTRY/}lscr.io/linuxserver/code-server:latest

# Environment & Default Ports
ENV DEBIAN_FRONTEND=noninteractive \
    JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64 \
    PATH=/usr/lib/jvm/java-21-openjdk-amd64/bin:/opt/sqlcl/bin:$PATH \
    TNS_ADMIN=/config/.oracle/tns_admin \
    JAVA_TOOL_OPTIONS=-Doracle.net.tns_admin=/config/.oracle/tns_admin

# 1. Install Base Packages (OpenJDK 21, Git, Python3, PyYAML, Curl, Unzip)
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-21-jdk-headless \
    git \
    python3 \
    python3-yaml \
    python3-pip \
    curl \
    unzip \
    ca-certificates \
    jq \
    && rm -rf /var/lib/apt/lists/*

# 2. Install GitHub CLI (gh)
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update && apt-get install -y gh && rm -rf /var/lib/apt/lists/* || true

# 3. Install Nektos 'act' CLI for local offline GitHub Actions simulation
RUN curl -s https://raw.githubusercontent.com/nektos/act/master/install.sh | bash -s -- -b /usr/local/bin || true

# 4. Download and Install Oracle SQLcl
RUN mkdir -p /opt/sqlcl && \
    curl -sL "https://download.oracle.com/otn_sqldev/sqlcl/sqlcl-latest.zip" -o /tmp/sqlcl.zip && \
    unzip -q /tmp/sqlcl.zip -d /opt/ && \
    rm -f /tmp/sqlcl.zip && \
    chmod +x /opt/sqlcl/bin/sql || true

# 5. Pre-configure default VS Code settings for Oracle SQL Developer & Antigravity
RUN mkdir -p /config/.local/share/code-server/User /root/.local/share/code-server/User && \
    SETTINGS_JSON='{"oracle.sql.developer.tnsAdmin":"/config/.oracle/tns_admin","oracle.sql.developer.javaPath":"/usr/lib/jvm/java-21-openjdk-amd64","redhat.telemetry.enabled":false,"workbench.colorTheme":"Default Dark Modern","workbench.startupEditor":"none"}' && \
    echo "$SETTINGS_JSON" > /config/.local/share/code-server/User/settings.json && \
    echo "$SETTINGS_JSON" > /root/.local/share/code-server/User/settings.json

# 6. Pre-install Official Extensions (Oracle SQL Developer, Antigravity, GitHub Actions, Red Hat YAML)
RUN /app/code-server/bin/code-server --install-extension Oracle.sql-developer-for-vscode 2>/dev/null || true && \
    /app/code-server/bin/code-server --install-extension google.antigravity 2>/dev/null || true && \
    /app/code-server/bin/code-server --install-extension github.vscode-github-actions 2>/dev/null || true && \
    /app/code-server/bin/code-server --install-extension redhat.vscode-yaml 2>/dev/null || true && \
    chown -R 1000:1000 /config 2>/dev/null || true

# 7. Pre-configure Antigravity & SQLcl alias in user profiles
RUN echo 'export TNS_ADMIN=/config/.oracle/tns_admin' >> /etc/bash.bashrc && \
    echo 'export JAVA_TOOL_OPTIONS="-Doracle.net.tns_admin=/config/.oracle/tns_admin"' >> /etc/bash.bashrc && \
    echo 'alias sql="/opt/sqlcl/bin/sql"' >> /etc/bash.bashrc

WORKDIR /workspace
