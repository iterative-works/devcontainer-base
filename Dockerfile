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

# Set development environment variables
ENV SBT_TPOLECAT_DEV=1

# Create a non-root user with UID 1000 (handle existing user if needed)
RUN if id 1000 >/dev/null 2>&1; then userdel -r $(id -un 1000); fi && \
    useradd -m -s /bin/bash -u 1000 developer && \
    usermod -aG sudo developer && \
    echo 'developer ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Set working directory
WORKDIR /workspace

# Switch to non-root user
USER developer

# Coursier (Scala toolchain)
RUN mkdir -p ~/.local/bin \
    && curl -fL https://github.com/coursier/launchers/raw/master/cs-x86_64-pc-linux.gz | gzip -d > ~/.local/bin/cs \
    && chmod +x ~/.local/bin/cs \
    && echo 'export PATH="$HOME/.local/bin:$HOME/.local/share/coursier/bin:$PATH"' >> ~/.bashrc

# Mise (runtime manager) - using GitHub releases
RUN curl -L "https://mise.jdx.dev/mise-latest-linux-x64" -o ~/.local/bin/mise \
    && chmod +x ~/.local/bin/mise \
    && echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc

# Create cache directories and local share directories (to prevent Docker from creating them as root)
RUN mkdir -p ~/.cache/nix ~/.cache/coursier ~/.cache/mise ~/.cache/npm ~/.claude \
    && mkdir -p ~/.local/share/mise ~/.local/share/coursier

# Set up shell environment
RUN echo 'export PS1="\[\e[32m\]\u@\h:\w\[\e[0m\]$ "' >> ~/.bashrc

# Copy setup script (as developer)
COPY --chown=developer:developer --chmod=0755 setup-tools.sh /home/developer/.local/bin/setup-tools.sh

# Add tool check script to bashrc
RUN echo '' >> ~/.bashrc \
    && echo '# Check if development tools are installed and notify user' >> ~/.bashrc \
    && echo 'if [ -t 1 ] && [ "$SHLVL" -eq 1 ]; then' >> ~/.bashrc \
    && echo '  if ! command -v scala &> /dev/null || ! command -v node &> /dev/null || ! command -v claude &> /dev/null; then' >> ~/.bashrc \
    && echo '    echo ""' >> ~/.bashrc \
    && echo '    echo "🔧 Development tools not fully installed."' >> ~/.bashrc \
    && echo '    echo "💡 Run the setup script to install missing tools:"' >> ~/.bashrc \
    && echo '    echo "   ~/.local/bin/setup-tools.sh"' >> ~/.bashrc \
    && echo '    echo ""' >> ~/.bashrc \
    && echo '  fi' >> ~/.bashrc \
    && echo 'fi' >> ~/.bashrc

# Default command
CMD ["/bin/bash"]
