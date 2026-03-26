# Contenedor de desarrollo aislado con VS Code Server
FROM debian:bookworm

ARG NODE_VERSION=20.20.0

# Evitar prompts interactivos durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias base
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    ripgrep \
    fd-find \
    jq \
    yq \
    fzf \
    tree \
    unzip \
    zip \
    xz-utils \
    less \
    procps \
    lsof \
    net-tools \
    iproute2 \
    dnsutils \
    tmux \
    bat \
    openssh-server \
    sudo \
    locales \
    ca-certificates \
    build-essential \
    python3 \
    python3-pip \
    python3-venv \
    nano \
    zstd \
    && apt-get update \
    && rm -rf /var/lib/apt/lists/*

# # Configurar locale
# RUN locale-gen en_US.UTF-8
# ENV LANG=en_US.UTF-8 \
#     LANGUAGE=en_US:en \
#     LC_ALL=en_US.UTF-8

# Crear usuario no-root
RUN useradd -m -s /bin/bash -G sudo developer && \
    echo "developer:developer" | chpasswd && \
    echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# # Instalar Node.js (necesario para muchos proyectos)
# RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
#     apt-get install -y nodejs && \
#     npm install -g npm@latest

# Cambiar a usuario developer
USER developer

WORKDIR /home/developer

RUN echo "alias l=\"ls -la\"\n" >> ./.bash_aliases && \
    echo "alias ll=\"ls -l\"\n" >> ./.bash_aliases && \
    echo "\n" >> ./.bash_aliases && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash && \
    echo "\nNVM_DIR='/home/developer/.nvm'\n" >> ./.bashrc && \
    echo "[ -s \"\$NVM_DIR/nvm.sh\" ] && \. \"\$NVM_DIR/nvm.sh\"\n" >> ./.profile && \
    echo "\nPS1='\${debian_chroot:+(\$debian_chroot)}\\w ➜ '\n" >> ./.bashrc && \
    echo "\n" >> ./.profile && \
    echo "\nnvm install > /dev/null 2>&1 || nvm install ${NODE_VERSION} > /dev/null 2>&1\n" >> ./.bashrc && \
    echo "\nnpm install -g @openai/codex > /dev/null\n" >> ./.bashrc && \
    echo "\nnvm use > /dev/null 2>&1" && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y && \
    curl -fsSL https://opencode.ai/install | bash

ENV PATH="/home/developer/.cargo/bin:${PATH}"

WORKDIR /home/developer/dev/$(basename ${PWD})

# Mantener el contenedor activo
CMD ["tail", "-f", "/dev/null"]
