# Project Setup Guide

This guide explains how to set up a new project using the `iterative-works/devcontainer-base` image.

## Quick Setup

1. **Create `.devcontainer` directory** in your project root:
   ```bash
   mkdir .devcontainer
   ```

2. **Copy example files** from this directory:
   ```bash
   cp /path/to/tools/devcontainer-base/docker-compose.example.yml .devcontainer/docker-compose.yml
   cp /path/to/tools/devcontainer-base/Dockerfile.example .devcontainer/Dockerfile
   cp /path/to/tools/devcontainer-base/devcontainer.example.json .devcontainer/devcontainer.json
   ```

3. **Create project naming** (optional but recommended):
   ```bash
   echo "COMPOSE_PROJECT_NAME=your-project-name" > .devcontainer/.env
   ```

4. **Set up shell aliases** (see [ALIASES.md](./ALIASES.md))

5. **Start your development environment**:
   ```bash
   dev-up  # or docker compose -f .devcontainer/docker-compose.yml up -d
   ```

## Customization Guide

### 1. Docker Compose Configuration

Edit `.devcontainer/docker-compose.yml`:

#### **Volume Mounts**
- **Required**: Cache directories (significant performance improvement)
- **Recommended**: Tool installations, build caches
- **Optional**: Development tools, SSH keys, project-specific mounts

#### **Environment Variables**
Add project-specific environment variables:
```yaml
environment:
  # Required PATH (don't modify)
  - PATH=/home/developer/.local/bin:/home/developer/.local/share/coursier/bin:/home/developer/.nix-profile/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
  
  # Project-specific variables
  - DATABASE_URL=${DATABASE_URL:-}
  - API_KEY=${API_KEY:-}
  - CUSTOM_VAR=${CUSTOM_VAR:-default_value}
```

### 2. Dockerfile Customization

Edit `.devcontainer/Dockerfile` to add:

#### **System Packages**
```dockerfile
USER root
RUN apt-get update && apt-get install -y \\
    postgresql-client \\
    redis-tools \\
    && apt-get clean \\
    && rm -rf /var/lib/apt/lists/*
USER developer
```

#### **Development Tools**
```dockerfile
# Via Nix
RUN nix-env -iA nixpkgs.postgresql

# Via Coursier (Scala tools)
RUN cs install bloop

# Via Mise (runtime versions)
RUN mise install python@3.11
```

#### **Project Configuration**
```dockerfile
# Copy configuration files
COPY .tool-versions /workspace/.tool-versions
COPY project-setup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/project-setup.sh
```

### 3. VS Code DevContainer

Edit `.devcontainer/devcontainer.json`:

#### **Extensions**
Add project-specific VS Code extensions:
```json
"extensions": [
  "scalameta.metals",           // Always include for Scala
  "ms-python.python",          // For Python projects
  "bradlc.vscode-tailwindcss",  // For web projects
  "your-org.custom-extension"   // Organization-specific
]
```

#### **Port Forwarding**
```json
"forwardPorts": [3000, 8080, 5432]
```

#### **Settings**
```json
"settings": {
  "python.defaultInterpreterPath": "/home/developer/.local/share/mise/installs/python/3.11.0/bin/python"
}
```

## Project Types

### Scala/JVM Projects
- Include all build tool caches (`.m2`, `.ivy2`, `.sbt`)
- Add Metals VS Code extension
- Consider adding specific JVM tools via Coursier

### Full-Stack Web Projects
- Add Node.js specific cache mounts
- Include web development VS Code extensions
- Forward web server ports (3000, 8080, etc.)

### Data Science Projects
- Install Python via Mise in Dockerfile
- Add Jupyter/data science VS Code extensions
- Mount data directories as needed

### Multi-Language Projects
- Use Mise for multiple runtime versions
- Include language-specific VS Code extensions
- Configure PATH for all required tools

## Environment Variables

### Required by Project
Set these in your host environment before starting containers:

```bash
# Option 1: In shell profile (~/.bashrc, ~/.zshrc)
export DATABASE_URL="postgresql://localhost:5432/mydb"
export API_KEY="your-api-key"

# Option 2: In project .envrc (requires direnv)
echo 'export DATABASE_URL="postgresql://localhost:5432/mydb"' > .envrc
echo 'export API_KEY="your-api-key"' >> .envrc
direnv allow

# Option 3: Temporary for single session
DATABASE_URL="postgresql://localhost:5432/mydb" dev-up
```

### Provided by Base Image
These are automatically available:
- `SBT_TPOLECAT_DEV=1` - Enables development mode for tpolecat SBT plugin
- `PATH` - Includes all tool directories
- Standard locale variables (`LANG`, `LC_ALL`, etc.)

## Common Patterns

### 1. Monorepo Setup
```yaml
volumes:
  # Mount entire monorepo
  - ../..:/workspace:cached
working_dir: /workspace/projects/current-project
```

### 2. Shared Dependencies
```yaml
volumes:
  # Share dependency caches across projects
  - ~/shared-cache/m2:/home/developer/.m2:cached
```

### 3. Multiple Services
```yaml
services:
  dev-container:
    # ... main container config
  
  database:
    image: postgres:15
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: developer
      POSTGRES_PASSWORD: password
```

## Troubleshooting

### Permission Issues
- Ensure base image uses UID 1000
- Check cache directory ownership: `ls -la ~/.cache`
- Verify user mapping: `id` in container should show UID 1000

### Tool Installation Issues
- Run setup script manually: `/usr/local/bin/setup-tools.sh`
- Check tool availability: `which scala node claude`
- Verify PATH includes tool directories

### Container Naming Conflicts
- Use unique `COMPOSE_PROJECT_NAME` in `.env` file
- Check running containers: `docker ps`

### VS Code Integration Issues
- Ensure DevContainer extension is installed
- Check `.devcontainer/devcontainer.json` syntax
- Verify Docker Compose file is valid

## Best Practices

1. **Always use cache mounts** for significant performance improvement
2. **Set unique project names** to avoid container conflicts
3. **Use environment variable defaults** (`${VAR:-}`) to avoid warnings
4. **Keep sensitive data in host environment**, not in container images
5. **Document required environment variables** in your project README
6. **Use the setup script** to install development tools
7. **Test your configuration** with a fresh container build occasionally