#!/bin/bash
set -e

echo "🔧 Setting up development tools..."

# Install Nix if not already present
if ! command -v nix &> /dev/null; then
    echo "📦 Installing Nix package manager..."
    
    # Create nix directory if it doesn't exist (for volume mount)
    sudo mkdir -p /nix
    sudo chown developer:developer /nix
    
    # Install Nix in single-user mode
    curl -L https://nixos.org/nix/install | sh
    
    # Add Nix to bashrc
    echo '. /home/developer/.nix-profile/etc/profile.d/nix.sh' >> ~/.bashrc
    echo 'export PATH="$HOME/.nix-profile/bin:$PATH"' >> ~/.bashrc
    
    # Configure Nix (create system-wide config as root)
    sudo mkdir -p /etc/nix
    sudo tee /etc/nix/nix.conf > /dev/null <<EOF
substituters = https://cache.nixos.org/
trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
build-use-substitutes = true
experimental-features = nix-command flakes
sandbox = false
EOF
    
    echo "✅ Nix installation complete"
else
    echo "✅ Nix already installed"
fi

# Source Nix environment directly to make it available in this session
if [ -f /home/developer/.nix-profile/etc/profile.d/nix.sh ]; then
    . /home/developer/.nix-profile/etc/profile.d/nix.sh
fi

# Install tools via Nix
echo "📦 Installing direnv via Nix..."
if ! command -v direnv &> /dev/null; then
    nix-env -iA nixpkgs.direnv
fi

# Add direnv hook to bash
echo "🔗 Setting up direnv bash hook..."
if ! grep -q "direnv hook bash" ~/.bashrc; then
    echo 'eval "$(~/.nix-profile/bin/direnv hook bash)"' >> ~/.bashrc
    echo "✅ Added direnv bash hook to ~/.bashrc"
else
    echo "✅ direnv bash hook already configured"
fi

# Install Scala tools via Coursier
echo "⚡ Installing Scala tools via Coursier..."
if ! command -v scala &> /dev/null; then
    cs install scala
fi

if ! command -v sbt &> /dev/null; then
    cs install sbt
fi

if ! command -v scala-cli &> /dev/null; then
    cs install scala-cli
fi

if ! command -v metals &> /dev/null; then
    cs install metals
fi

# Install Node.js via Mise
echo "🟢 Installing Node.js via Mise..."
if ! command -v node &> /dev/null; then
    mise use --global node@lts
    # Reload mise to get node/npm in PATH
    eval "$(mise activate bash)"
fi

# Install Claude Code CLI
echo "🤖 Installing Claude Code CLI..."
if ! command -v claude &> /dev/null; then
    # Ensure mise environment is active for npm
    eval "$(mise activate bash)"
    npm install -g @anthropic-ai/claude-code
fi

echo "Installing Playwright dependencies..."
cs launch com.microsoft.playwright:playwright:1.52.0 -M com.microsoft.playwright.CLI -- install-deps

echo "✅ Development tools setup complete!"
echo ""
echo "Available tools:"
echo "  - direnv: $(which direnv 2>/dev/null || echo 'not found')"
echo "  - scala: $(which scala 2>/dev/null || echo 'not found')"
echo "  - sbt: $(which sbt 2>/dev/null || echo 'not found')"
echo "  - scala-cli: $(which scala-cli 2>/dev/null || echo 'not found')"
echo "  - metals: $(which metals 2>/dev/null || echo 'not found')"
echo "  - node: $(which node 2>/dev/null || echo 'not found')"
echo "  - claude: $(which claude 2>/dev/null || echo 'not found')"

if [ -e ".envrc" ]; then
	echo "Now restart bash and run direnv allow to load project env."
fi
