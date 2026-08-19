# ============================================================================
# Standalone Google Antigravity IDE GUI Container (X11 / Desktop GUI)
# Runs native desktop Antigravity IDE inside an isolated Podman sandbox container.
# ============================================================================

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# 1. Install System Dependencies & X11 GTK GUI libraries
RUN apt-get update && apt-get install -y \
    curl \
    git \
    wget \
    unzip \
    ca-certificates \
    libgtk-3-0 \
    libx11-xcb1 \
    libxcb-dri3-0 \
    libdrm2 \
    libgbm1 \
    libasound2 \
    libnss3 \
    libxss1 \
    libxtst6 \
    libxkbfile1 \
    libsecret-1-0 \
    dbus-x11 \
    xdg-utils \
    fonts-liberation \
    libcanberra-gtk3-module \
    && rm -rf /var/lib/apt/lists/*

# 2. Create non-root developer user
RUN useradd -m -s /bin/bash developer && \
    mkdir -p /workspace /home/developer/.config /home/developer/.ssh && \
    chown -R developer:developer /workspace /home/developer

# 3. Install Standalone Google Antigravity IDE
RUN curl -fsSL https://antigravity.google/install.sh | bash || \
    (curl -fsSL https://raw.githubusercontent.com/google/antigravity/main/install.sh | bash || true)

USER developer
WORKDIR /workspace

CMD ["antigravity", "--no-sandbox"]
