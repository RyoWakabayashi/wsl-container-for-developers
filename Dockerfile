FROM ubuntu:20.04

ARG PROXY

ARG USERNAME=ubuntu
ARG GROUPNAME=ubuntu
ARG UID=1000
ARG GID=1000

ENV http_proxy $PROXY
ENV https_proxy $PROXY
ENV HTTP_PROXY $PROXY
ENV HTTPS_PROXY $PROXY

ENV DEBIAN_FRONTEND=noninteractive
ENV USER $USERNAME
ENV HOME /home/${USER}
ENV PW ubuntu

# hadolint ignore=DL4006
RUN :  \
    && { \
    echo 'Acquire::http:proxy "'${http_proxy}'";'; \
    echo 'Acquire::https:proxy "'${https_proxy}'";'; \
    } | tee /etc/apt/apt.conf

# Set root proxy
RUN echo "export http_proxy=$http_proxy" >> /root/.bashrc && \
    echo "export https_proxy=$http_proxy" >> /root/.bashrc && \
    echo "export HTTP_PROXY=$http_proxy" >> /root/.bashrc && \
    echo "export HTTPS_PROXY=$http_proxy" >> /root/.bashrc

# Install essentials
# hadolint ignore=DL3008
RUN apt-get update -q && \
    apt-get install --no-install-recommends -y \
    build-essential \
    file \
    procps \
    gnupg \
    lsb-release \
    libbz2-dev \
    libdb-dev \
    libreadline-dev \
    libffi-dev \
    libgdbm-dev \
    liblzma-dev \
    libncursesw5-dev \
    libsqlite3-dev \
    libssl-dev \
    zlib1g-dev \
    uuid-dev \
    tk-dev\
    openssh-client \
    locales \
    unzip \
    less \
    sudo \
    ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install tools
# hadolint ignore=DL3008
RUN apt-get update -q && \
    apt-get install --no-install-recommends -y \
    ubuntu-wsl \
    iputils-ping \
    net-tools \
    dnsutils \
    netcat \
    git \
    curl \
    wget \
    vim \
    stow && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set laguage to Japanese
# hadolint ignore=DL3008
RUN apt-get update -q && \
    apt-get install --no-install-recommends -y language-pack-ja && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    update-locale LANG=ja_JP.UTF8

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Setup User
RUN groupadd -g $GID $GROUPNAME && \
    useradd -l -m -s /bin/bash -u $UID -g $GID $USERNAME && \
    gpasswd -a ${USER} sudo && \
    echo "${USER}:${PW}" | chpasswd && \
    sed -i.bak -r s#${HOME}:\(.+\)#${HOME}:/bin/zsh# /etc/passwd && \
    echo "${USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install zsh
# hadolint ignore=DL3008
RUN apt-get update -q && \
    apt-get install --no-install-recommends -y zsh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Docker
# hadolint ignore=DL3008
RUN export DOCKER_GPG_KEY=/usr/share/keyrings/docker-archive-keyring.gpg && \
    export DOCKER_URL=https://download.docker.com/linux/ubuntu &&\
    curl -fsSL "${DOCKER_URL}/gpg" | \
    gpg --dearmor -o "${DOCKER_GPG_KEY}" && \
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=${DOCKER_GPG_KEY}] ${DOCKER_URL} $(lsb_release -cs) stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update -q && \
    apt-get install --no-install-recommends -y \
    docker-ce \
    docker-ce-cli \
    docker-compose \
    containerd.io && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    usermod -aG docker ${USER}

# Set docker proxy
RUN export DOCKER_DEFAULT=/etc/default/docker && \
    echo "export http_proxy=$http_proxy" >> $DOCKER_DEFAULT && \
    echo "export https_proxy=$http_proxy" >> $DOCKER_DEFAULT

# Add WSL config
RUN echo "[user]" >> /etc/wsl.conf && \
    echo "default=${USER}" >> /etc/wsl.conf

USER ${USER}

# Install oh-my-zsh
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Set user proxy
RUN echo "export http_proxy=$http_proxy" >> ~/.zshrc && \
    echo "export https_proxy=$http_proxy" >> ~/.zshrc && \
    echo "export HTTP_PROXY=$http_proxy" >> ~/.zshrc && \
    echo "export HTTPS_PROXY=$http_proxy" >> ~/.zshrc

# Set docker proxy
RUN mkdir ~/.docker && \
    export DOCKER_CONFIG=~/.docker/config.json && \
    echo "{" >> $DOCKER_CONFIG && \
    echo "  \"proxies\": {" >> $DOCKER_CONFIG && \
    echo "    \"default\": {" >> $DOCKER_CONFIG && \
    echo "      \"httpProxy\": \"${http_proxy}\"," >> $DOCKER_CONFIG && \
    echo "      \"httpsProxy\": \"${http_proxy}\"" >> $DOCKER_CONFIG && \
    echo "    }" >> $DOCKER_CONFIG && \
    echo "  }" >> $DOCKER_CONFIG && \
    echo "}" >> $DOCKER_CONFIG

# Install Homebrew
# hadolint ignore=DL3059
RUN /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && \
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" && \
    echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.zshrc

ENV PATH "/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin+:$PATH"

# SSH Agent
RUN echo "eval $(ssh-agent)" >> ~/.zshrc

# Install AWS CLI
# hadolint ignore=DL3059
RUN brew install awscli

# Install ASDF
# hadolint ignore=DL3059
RUN brew install asdf && \
    echo "source $(brew --prefix asdf)/asdf.sh" >> ~/.zshrc

# Install GitHub CLI
# hadolint ignore=DL3059
RUN brew install gh

# Run Docker on login
RUN echo 'service docker status > /dev/null 2>&1' >> ~/.zshrc && \
    echo 'if [ $? != 0 ]; then' >> ~/.zshrc && \
    echo '  sudo service docker start' >> ~/.zshrc && \
    echo 'fi' >> ~/.zshrc

COPY scripts ${HOME}/scripts

RUN chmod +x ${HOME}/scripts/copy_git_config.sh && \
    chmod +x ${HOME}/scripts/copy_ssh_config.sh

WORKDIR ${HOME}
