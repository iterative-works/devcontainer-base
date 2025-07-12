# Development Container Aliases

This document contains useful shell aliases for working with development containers based on the `iterative-works/devcontainer-base` image.

## Fish Shell Aliases

Add these aliases to your Fish shell configuration (`~/.config/fish/config.fish`) or home-manager configuration:

```fish
# Development Container Management
alias dev-up "docker compose -f .devcontainer/docker-compose.yml up -d"
alias dev-down "docker compose -f .devcontainer/docker-compose.yml down"
alias dev-build "docker compose -f .devcontainer/docker-compose.yml build && docker compose -f .devcontainer/docker-compose.yml up -d"
alias dev-rebuild "docker compose -f .devcontainer/docker-compose.yml down && docker compose -f .devcontainer/docker-compose.yml build --no-cache && docker compose -f .devcontainer/docker-compose.yml up -d"
alias dev-exec "docker compose -f .devcontainer/docker-compose.yml exec dev-container"
alias dev-claude "docker compose -f .devcontainer/docker-compose.yml exec dev-container claude"
alias dev-bash "docker compose -f .devcontainer/docker-compose.yml exec dev-container bash"
alias dev-logs "docker compose -f .devcontainer/docker-compose.yml logs -f dev-container"
```

## Bash/Zsh Aliases

Add these aliases to your shell configuration (`~/.bashrc`, `~/.zshrc`):

```bash
# Development Container Management
alias dev-up='docker compose -f .devcontainer/docker-compose.yml up -d'
alias dev-down='docker compose -f .devcontainer/docker-compose.yml down'
alias dev-build='docker compose -f .devcontainer/docker-compose.yml build && docker compose -f .devcontainer/docker-compose.yml up -d'
alias dev-rebuild='docker compose -f .devcontainer/docker-compose.yml down && docker compose -f .devcontainer/docker-compose.yml build --no-cache && docker compose -f .devcontainer/docker-compose.yml up -d'
alias dev-exec='docker compose -f .devcontainer/docker-compose.yml exec dev-container'
alias dev-claude='docker compose -f .devcontainer/docker-compose.yml exec dev-container claude'
alias dev-bash='docker compose -f .devcontainer/docker-compose.yml exec dev-container bash'
alias dev-logs='docker compose -f .devcontainer/docker-compose.yml logs -f dev-container'
```

## Alias Descriptions

| Alias | Description |
|-------|-------------|
| `dev-up` | Start the development container in detached mode |
| `dev-down` | Stop and remove the development container |
| `dev-build` | Rebuild the container (with cache) and restart |
| `dev-rebuild` | Rebuild the container from scratch (stops, rebuilds with --no-cache, starts) |
| `dev-exec` | Execute a command in the running container (e.g., `dev-exec ls -la`) |
| `dev-claude` | Start Claude Code CLI inside the container |
| `dev-bash` | Open an interactive bash shell in the container |
| `dev-logs` | Follow the container logs in real-time |

## Usage Examples

```bash
# Start your development environment
dev-up

# Open a shell in the container
dev-bash

# Run Claude Code inside the container
dev-claude

# Execute a one-off command
dev-exec ls -la /workspace

# Check container logs
dev-logs

# Rebuild container (fast, with cache) after minor changes
dev-build

# Rebuild container from scratch (slow, no cache) for major changes
dev-rebuild

# Stop the environment when done
dev-down
```

## Home Manager Configuration

If you're using Nix Home Manager, add the aliases to your `home.nix`:

```nix
programs.fish = {
  enable = true;
  shellAliases = {
    dev-up = "docker compose -f .devcontainer/docker-compose.yml up -d";
    dev-down = "docker compose -f .devcontainer/docker-compose.yml down";
    dev-build = "docker compose -f .devcontainer/docker-compose.yml build && docker compose -f .devcontainer/docker-compose.yml up -d";
    dev-rebuild = "docker compose -f .devcontainer/docker-compose.yml down && docker compose -f .devcontainer/docker-compose.yml build --no-cache && docker compose -f .devcontainer/docker-compose.yml up -d";
    dev-exec = "docker compose -f .devcontainer/docker-compose.yml exec dev-container";
    dev-claude = "docker compose -f .devcontainer/docker-compose.yml exec dev-container claude";
    dev-bash = "docker compose -f .devcontainer/docker-compose.yml exec dev-container bash";
    dev-logs = "docker compose -f .devcontainer/docker-compose.yml logs -f dev-container";
  };
};
```

## Project-Specific Variations

For different projects, you may need to adjust the container name or compose file path:

```bash
# If your container service has a different name
alias dev-exec='docker compose -f .devcontainer/docker-compose.yml exec my-custom-service'

# If your compose file is in a different location
alias dev-up='docker compose -f docker/dev-compose.yml up -d'
```

## Additional Useful Aliases

Consider adding these project-specific aliases:

```bash
# Build and test commands
alias dev-build='dev-exec sbtn compile'
alias dev-test='dev-exec sbtn test'
alias dev-dev='dev-exec yarn dev'

# Git operations in container
alias dev-git='dev-exec git'

# Package management
alias dev-nix='dev-exec nix-env'
alias dev-cs='dev-exec cs'
alias dev-mise='dev-exec mise'

# Environment management
alias dev-direnv='dev-exec direnv'
```

## Important Notes

### Direnv Integration

The base image includes direnv with proper bash hook integration. When you enter a directory with a `.envrc` file inside the container, direnv will automatically load the environment. This is particularly useful for:

- Loading project-specific environment variables
- Activating language versions (via mise)
- Setting up development paths
- Loading secrets from external sources

Example `.envrc` usage:
```bash
# In your project's .envrc file
export NODE_ENV=development
use mise
```

### Project-Specific Environment Variables

Some projects may require credentials or other environment variables to be passed from the host system. For example, this project requires:

```bash
# Set these in your host environment before starting containers
export EBS_NEXUS_USERNAME="your-username"
export EBS_NEXUS_PASSWORD="your-password"

# Then start the container (variables will be passed through)
dev-up
```

These variables can be set:
- In your shell profile (`~/.bashrc`, `~/.zshrc`)
- In a `.envrc` file in your project directory (requires direnv)
- Temporarily for a single session: `EBS_NEXUS_USERNAME=user EBS_NEXUS_PASSWORD=pass dev-up`