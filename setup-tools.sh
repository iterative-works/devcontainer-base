#!/bin/bash
set -e

echo "🔧 Setting up development tools..."

# Source environment
source ~/.bashrc

# Install tools via Nix
echo "📦 Installing direnv via Nix..."
if ! command -v direnv &> /dev/null; then
    nix-env -iA nixpkgs.direnv
fi

# Add direnv hook to bash
echo "🔗 Setting up direnv bash hook..."
if ! grep -q "direnv hook bash" ~/.bashrc; then
    echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
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
    mise install node@lts
    mise global node@lts
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