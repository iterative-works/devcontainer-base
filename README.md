# DevContainer Base Image

A comprehensive development container base image with package managers and development tools.

## Features

- **Base**: Ubuntu 24.04 LTS
- **Package Managers**: Nix, Coursier, Mise
- **Essential Tools**: fd-find, ripgrep, git, build tools
- **Development Tools Setup Script**: Installs direnv, Scala tools, Node.js, Claude Code

## Usage

### Building the Image

```bash
# Build locally
./build.sh

# Build and push to registry
./build.sh --push

# Build with specific tag
./build.sh --tag v1.0 --push
```

### Using the Image

```bash
# Run container
docker run -it iterative-works/devcontainer-base

# Inside container, install development tools
setup-tools.sh
```

### In Projects

Use as base image in your project's `.devcontainer/Dockerfile`:

```dockerfile
FROM iterative-works/devcontainer-base:latest

# Add project-specific setup
COPY . /workspace
RUN setup-tools.sh
```

## Cache Optimization

The image includes cache directories for:
- Nix: `~/.cache/nix`
- Coursier: `~/.cache/coursier`  
- Mise: `~/.cache/mise`
- NPM: `~/.cache/npm`

Mount these from host for faster tool installation:

```yaml
volumes:
  - ~/.cache/nix:/home/developer/.cache/nix:cached
  - ~/.cache/coursier:/home/developer/.cache/coursier:cached
  - ~/.cache/mise:/home/developer/.cache/mise:cached
  - ~/.cache/npm:/home/developer/.cache/npm:cached
```

## Tool Installation

The base image includes an installation script at `/usr/local/bin/setup-tools.sh` that installs:

- **direnv** (via Nix) - Environment management with bash hook
- **Scala ecosystem** (via Coursier): scala, sbt, scala-cli, metals
- **Node.js** (via Mise) - Latest LTS version
- **Claude Code CLI** (via npm) - AI-powered development assistant

### Automatic Setup Notification

When you start a shell in the container, it automatically checks if development tools are installed and provides a helpful notification if any are missing:

```
🔧 Development tools not fully installed.
💡 Run the setup script to install missing tools:
   /usr/local/bin/setup-tools.sh
```

This check only runs on interactive shells and won't interfere with non-interactive usage.

## Project Setup

For setting up new projects with this base image:

1. **Quick Start**: See [PROJECT_SETUP.md](./PROJECT_SETUP.md) for detailed setup instructions
2. **Templates**: Use the example files in this directory:
   - `docker-compose.example.yml` - Docker Compose configuration template
   - `Dockerfile.example` - Dockerfile template for customization
   - `devcontainer.example.json` - VS Code DevContainer configuration template
3. **Aliases**: See [ALIASES.md](./ALIASES.md) for convenient shell aliases to manage containers

### Quick Setup
```bash
# In your project directory
mkdir .devcontainer
cp /path/to/tools/devcontainer-base/docker-compose.example.yml .devcontainer/docker-compose.yml
cp /path/to/tools/devcontainer-base/Dockerfile.example .devcontainer/Dockerfile
cp /path/to/tools/devcontainer-base/devcontainer.example.json .devcontainer/devcontainer.json
echo "COMPOSE_PROJECT_NAME=your-project-name" > .devcontainer/.env
```