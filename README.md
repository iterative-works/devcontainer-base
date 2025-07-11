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

## Installed Tools (via setup-tools.sh)

- **direnv** (via Nix)
- **Scala ecosystem** (via Coursier): scala, sbt, scala-cli, metals
- **Node.js** (via Mise)
- **Claude Code CLI** (via npm)