FROM ubuntu:24.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Prague

# Install system dependencies
RUN apt-get update && apt-get install -y \
    # Basic utilities
    curl \
    wget \
    git \
    vim \
    nano \
    unzip \
    zip \
    ca-certificates \
    software-properties-common \
    gnupg \
    lsb-release \
    # Build tools
    build-essential \
    pkg-config \
    # Network tools
    net-tools \
    iputils-ping \
    telnet \
    # Process management
    htop \
    procps \
    # Development tools
    jq \
    tree \
    fd-find \
    ripgrep \
    # Sudo for Nix installation
    sudo \
    # Locale support
    locales \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set up locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Create a non-root user
RUN useradd -m -s /bin/bash developer && \
    usermod -aG sudo developer && \
    echo 'developer ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Set working directory
WORKDIR /workspace

# Prepare for Nix installation (as root)
RUN mkdir -m 0755 /nix && chown developer /nix

# Copy setup script (as root)
COPY setup-tools.sh /usr/local/bin/setup-tools.sh
RUN chmod +x /usr/local/bin/setup-tools.sh

# Switch to non-root user
USER developer

# Install package managers
# Nix package manager (single-user mode)
RUN curl -L https://nixos.org/nix/install | sh \
    && echo '. /home/developer/.nix-profile/etc/profile.d/nix.sh' >> ~/.bashrc \
    && echo 'export PATH="$HOME/.nix-profile/bin:$PATH"' >> ~/.bashrc

# Coursier (Scala toolchain)
RUN mkdir -p ~/.local/bin \
    && curl -fL https://github.com/coursier/launchers/raw/master/cs-x86_64-pc-linux.gz | gzip -d > ~/.local/bin/cs \
    && chmod +x ~/.local/bin/cs \
    && echo 'export PATH="$HOME/.local/bin:$HOME/.local/share/coursier/bin:$PATH"' >> ~/.bashrc

# Mise (runtime manager)
RUN curl https://mise.run | sh \
    && echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc

# Create cache directories
RUN mkdir -p ~/.cache/nix ~/.cache/coursier ~/.cache/mise ~/.cache/npm

# Set up shell environment
RUN echo 'export PS1="\[\e[32m\]\u@\h:\w\[\e[0m\]$ "' >> ~/.bashrc

# Default command
CMD ["/bin/bash"]
