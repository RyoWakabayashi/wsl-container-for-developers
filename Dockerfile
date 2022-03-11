FROM ubuntu:20.04

ARG USERNAME=ubuntu
ARG GROUPNAME=ubuntu
ARG UID=1000
ARG GID=1000

ENV DEBIAN_FRONTEND=noninteractive
ENV USER $USERNAME
ENV HOME /home/${USER}
ENV PW ubuntu

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
    git \
    curl \
    wget \
    vim \
    stow && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set lagugae to Japanese
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
    sed -i.bak -r s#${HOME}:\(.+\)#${HOME}:/bin/bash# /etc/passwd && \
    sed -i.bak -r s#${HOME}:\(.+\)#${HOME}:/usr/local/bin/zsh# /etc/passwd && \
    echo "${USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install zsh
# hadolint ignore=DL3008
RUN apt-get update -q && \
    apt-get install --no-install-recommends -y zsh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER ${USER}

# Install oh-my-zsh
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

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

WORKDIR ${HOME}
