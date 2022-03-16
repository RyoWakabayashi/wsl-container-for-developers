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
    gawk \
    fzf \
    peco \
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

ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP:ja
ENV LC_ALL=ja_JP.UTF-8

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

# Install GitHub CLI
# hadolint ignore=DL3008
RUN export GITHUB_GPG_KEY=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    export GITHUB_URL=https://cli.github.com/packages &&\
    curl -fsSL "${GITHUB_URL}/githubcli-archive-keyring.gpg" | \
    dd of="${GITHUB_GPG_KEY}" && \
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=${GITHUB_GPG_KEY}] ${GITHUB_URL} stable main" | \
    tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update -q && \
    apt-get install --no-install-recommends -y gh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install AWS CLI
# hadolint ignore=DL3059
RUN export ZIP_FILE=./awscliv2.zip && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "${ZIP_FILE}" && \
    unzip "${ZIP_FILE}" && \
    ./aws/install

# Add WSL config
RUN echo "[user]" >> /etc/wsl.conf && \
    echo "default=${USER}" >> /etc/wsl.conf

USER ${USER}

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

# Install ASDF
# hadolint ignore=DL3059
RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf && \
    echo "" >> ~/.zshrc && \
    echo "# Enable ASDF" >> ~/.zshrc && \
    echo ". $HOME/.asdf/asdf.sh" >> ~/.zshrc

# Install Node.js via ASDF
# hadolint ignore=SC1091
RUN . "${HOME}/.asdf/asdf.sh" && \
    asdf plugin add nodejs && \
    asdf install nodejs 17.6.0 && \
    asdf global nodejs 17.6.0

# Install Python via ASDF
# hadolint ignore=SC1091,DL3013
RUN . "${HOME}/.asdf/asdf.sh" && \
    asdf plugin add python && \
    asdf install python 3.10.2 && \
    asdf global python 3.10.2 && \
    pip install --upgrade --no-cache-dir pip

COPY --chown=$UID:$GID scripts ${HOME}/scripts
COPY --chown=$UID:$GID configs ${HOME}/configs
COPY --chown=$UID:$GID dotfiles ${HOME}

WORKDIR ${HOME}

# Install ZI
RUN export zi_home="${HOME}/.zi" && \
    mkdir -p $zi_home && \
    git clone https://github.com/z-shell/zi.git "${zi_home}/bin" && \
    echo '' >> ${HOME}/.zshrc && \
    echo 'source ~/.zi_zshrc' >> ${HOME}/.zshrc && \
    export TERM=xterm && \
    zsh -ic "source ${HOME}/.zi_plugins"

# Run Docker on login
RUN echo '' >> ~/.zshrc && \
    echo '# Start Docker service' >> ~/.zshrc && \
    echo 'service docker status > /dev/null 2>&1' >> ~/.zshrc && \
    echo 'if [ $? != 0 ]; then' >> ~/.zshrc && \
    echo '  sudo service docker start' >> ~/.zshrc && \
    echo 'fi' >> ~/.zshrc

# SSH Agent
# hadolint ignore=SC2016
RUN echo "" >> ~/.zshrc && \
    echo "# Start ssh-agent" >> ~/.zshrc && \
    echo 'eval $(ssh-agent)' >> ~/.zshrc

RUN find ${HOME}/scripts -type f -name "*.sh" -print0 | \
    xargs -0 chmod +x
