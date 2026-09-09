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
    JAVA_TOOL_OPTIONS=-Doracle.net.tns_admin=/config/.oracle/tns_admin \
    EXTENSIONS_GALLERY='{"serviceUrl":"https://marketplace.visualstudio.com/_apis/public/gallery","itemUrl":"https://marketplace.visualstudio.com/items"}'

# 1. Install Base Packages (OpenJDK 21, Git, Python3, Pip, Venv, PyYAML, Yamllint, Shellcheck, Curl, Unzip)
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-21-jdk-headless \
    git \
    python3 \
    python3-yaml \
    python3-pip \
    python3-venv \
    yamllint \
    shellcheck \
    curl \
    unzip \
    ca-certificates \
    jq \
    && (for j in /usr/lib/jvm/java-21-openjdk-*; do [ -d "$j" ] && ln -sf "$j" /usr/lib/jvm/default-java && ln -sf "$j" /usr/lib/jvm/java-21-openjdk-amd64 && ln -sf "$j" /usr/lib/jvm/java-21-openjdk-arm64 && break; done) \
    && rm -rf /var/lib/apt/lists/*

# 2. Install GitHub CLI (gh)
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update && apt-get install -y gh && rm -rf /var/lib/apt/lists/* || true

# 3. Install Nektos 'act' CLI & 'actionlint' for local offline GitHub Actions simulation and security linting
RUN curl -s https://raw.githubusercontent.com/nektos/act/master/install.sh | bash -s -- -b /usr/local/bin || true && \
    bash -c 'bash <(curl -s https://raw.githubusercontent.com/rhysd/actionlint/main/scripts/download-actionlint.bash)' 2>/dev/null && \
    mv -f ./actionlint /usr/local/bin/actionlint 2>/dev/null || true

# 4. Download and Install Oracle SQLcl
RUN mkdir -p /opt/sqlcl && \
    curl -sL "https://download.oracle.com/otn_sqldev/sqlcl/sqlcl-latest.zip" -o /tmp/sqlcl.zip && \
    unzip -q /tmp/sqlcl.zip -d /opt/ && \
    rm -f /tmp/sqlcl.zip && \
    chmod +x /opt/sqlcl/bin/sql || true

# 5. Pre-configure default VS Code settings for Oracle SQL Developer, Antigravity, Python & GitHub Actions
RUN mkdir -p /config/data/User /config/.local/share/code-server/User /root/.local/share/code-server/User /config/extensions && \
    SETTINGS_JSON='{"oracle.sql.developer.tnsAdmin":"/config/.oracle/tns_admin","oracle.sql.developer.javaPath":"/usr/lib/jvm/default-java","python.defaultInterpreterPath":"/usr/bin/python3","python.testing.pytestEnabled":true,"files.associations":{"*.sql":"oracle-sql","*.pls":"oracle-plsql","*.pks":"oracle-plsql","*.pkb":"oracle-plsql"},"workbench.editorAssociations":{"*.sql":"oracle.sql-developer.editor","*.pls":"oracle.sql-developer.editor"},"redhat.telemetry.enabled":false,"workbench.colorTheme":"Default Dark Modern","workbench.startupEditor":"none"}' && \
    echo "$SETTINGS_JSON" > /config/data/User/settings.json && \
    echo "$SETTINGS_JSON" > /config/.local/share/code-server/User/settings.json && \
    echo "$SETTINGS_JSON" > /root/.local/share/code-server/User/settings.json

# 6. Pre-install Official Extensions (Oracle SQL Developer, Antigravity, Microsoft Python, GitHub Actions, Red Hat YAML)
RUN /app/code-server/bin/code-server --extensions-dir /config/extensions --install-extension Oracle.sql-developer 2>/dev/null || true && \
    /app/code-server/bin/code-server --extensions-dir /config/extensions --install-extension google.google-antigravity 2>/dev/null || /app/code-server/bin/code-server --extensions-dir /config/extensions --install-extension google.antigravity 2>/dev/null || true && \
    /app/code-server/bin/code-server --extensions-dir /config/extensions --install-extension ms-python.python 2>/dev/null || true && \
    /app/code-server/bin/code-server --extensions-dir /config/extensions --install-extension ms-python.vscode-pylance 2>/dev/null || true && \
    /app/code-server/bin/code-server --extensions-dir /config/extensions --install-extension ms-python.debugpy 2>/dev/null || true && \
    /app/code-server/bin/code-server --extensions-dir /config/extensions --install-extension github.vscode-github-actions 2>/dev/null || true && \
    /app/code-server/bin/code-server --extensions-dir /config/extensions --install-extension redhat.vscode-yaml 2>/dev/null || true && \
    chown -R 911:911 /config /config/extensions /config/data 2>/dev/null || true

# 7. Pre-configure Antigravity & SQLcl alias in user profiles
RUN echo 'export TNS_ADMIN=/config/.oracle/tns_admin' >> /etc/bash.bashrc && \
    echo 'export JAVA_TOOL_OPTIONS="-Doracle.net.tns_admin=/config/.oracle/tns_admin"' >> /etc/bash.bashrc && \
    echo 'alias sql="/opt/sqlcl/bin/sql"' >> /etc/bash.bashrc

WORKDIR /workspace
